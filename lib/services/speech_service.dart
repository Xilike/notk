import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/game_data.dart';
import '../data/lesson_data.dart';
import 'app_state.dart';
import 'child_speech_text.dart';
import 'voice_asset_catalog.dart';

/// Bundled assets first; device Arabic TTS is the offline fallback.
/// Each new request cancels the previous sequence, including pending feedback.
class SpeechService {
  SpeechService._();
  static final _tts = FlutterTts();
  static final _player = AudioPlayer();
  static final _random = Random();
  static Future<void>? _initialization;
  static Future<void> _launch = Future.value();
  static Map<String, dynamic> _manifest = {};
  static Set<String> _assets = {};
  static int _generation = 0;
  static bool _activeAutomatic = false;
  static int _manualRevision = 0;
  static int get manualRevision => _manualRevision;
  static bool _hasOutput = false;
  static bool _offlineTtsAvailable = true;
  @visibleForTesting
  static Future<void> Function(String)? playbackOverride;
  static bool recordingActive = false;
  static Future<void> Function()? stopExternalAudio;
  static Completer<void>? _cancel;
  static ChildSpeechText get text =>
      ChildSpeechText(AppState.instance.profile.gender);

  // Widget tests use separate fake clocks; discard the previous test queue.
  @visibleForTesting
  static void resetTestPlayback() {
    assert(playbackOverride != null);
    ++_generation;
    _cancel?.complete();
    _cancel = null;
    _activeAutomatic = false;
    _launch = SynchronousFuture<void>(null);
  }

  static Future<void> initialize() => _initialization ??= _initialize();
  static Future<void> _initialize() async {
    try {
      _assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
          .listAssets()
          .toSet();
      final raw =
          await rootBundle.loadString('assets/audio/voice_manifest.json');
      _manifest = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {/* An incomplete voice pack is supported. */}
    try {
      await _tts.setLanguage('ar-EG');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      final dynamic voices = await _tts.getVoices;
      if (voices is List) {
        final selected = selectArabicVoice(voices);
        _offlineTtsAvailable = voices.isEmpty || selected != null;
        if (selected != null) await _tts.setVoice(selected);
      }
    } catch (error) {
      debugPrint('Arabic TTS initialization: $error');
    }
  }

  @visibleForTesting
  static Map<String, String>? selectArabicVoice(List<dynamic> voices) {
    final candidates = <Map<String, String>>[];
    for (final voice in voices) {
      if (voice is! Map) continue;
      final name = voice['name']?.toString() ?? '';
      final locale = voice['locale']?.toString() ?? '';
      final network = voice['network_required']?.toString().toLowerCase();
      final features = voice['features']?.toString().toLowerCase() ?? '';
      if (name.isEmpty ||
          !locale.toLowerCase().startsWith('ar') ||
          network == '1' ||
          network == 'true' ||
          features.contains('notinstalled')) {
        continue;
      }
      candidates.add({
        'name': name,
        'locale': locale,
        'quality': voice['quality']?.toString().toLowerCase() ?? ''
      });
    }
    int score(Map<String, String> voice) {
      final locale = voice['locale']!.toLowerCase().replaceAll('_', '-');
      final name = voice['name']!.toLowerCase();
      final quality = voice['quality']!;
      return (locale == 'ar-eg' ? 100 : 50) +
          (RegExp('neural|natural|premium').hasMatch(name) ? 15 : 0) +
          (quality.contains('very_high')
              ? 20
              : quality.contains('high')
                  ? 10
                  : 0);
    }

    candidates.sort((a, b) => score(b).compareTo(score(a)));
    if (candidates.isEmpty) return null;
    return {
      'name': candidates.first['name']!,
      'locale': candidates.first['locale']!
    };
  }

  static String assetKey(String value) => VoiceAssetCatalog.key(value);

  static String? _asset(String value, String category, String gender) {
    final phrases = text;
    final gendered = phrases.praise.contains(value) ||
        phrases.encouragement.contains(value) ||
        value == phrases.wonReward;
    return VoiceAssetCatalog(_assets, _manifest)
        .resolve(value, category, gender, gendered: gendered);
  }

  static Future<void> _sequence(List<String> pieces,
      {String category = 'words',
      bool automatic = false,
      Duration pause = Duration.zero}) async {
    if ((automatic && !AppState.instance.autoSpeakEnabled) ||
        !AppState.instance.soundEnabled ||
        recordingActive ||
        pieces.every((e) => e.trim().isEmpty)) {
      return;
    }
    final ticket = ++_generation;
    _activeAutomatic = automatic;
    if (!automatic) _manualRevision++;
    _cancel?.complete();
    final cancel = Completer<void>();
    _cancel = cancel;
    final gender = AppState.instance.profile.gender.name;
    final content = pieces.where((e) => e.trim().isNotEmpty).toList();
    for (var index = 0; index < content.length; index++) {
      final piece = content[index];
      if (ticket != _generation ||
          (automatic && !AppState.instance.autoSpeakEnabled)) {
        break;
      }
      final done = Completer<void>();
      // Serialize stop/configure/start, but never hold the queue for playback.
      _launch = _launch.then((_) async {
        if (ticket != _generation) {
          done.complete();
          return;
        }
        final override = playbackOverride;
        if (override != null) {
          unawaited(override(piece).whenComplete(() {
            if (!done.isCompleted) done.complete();
          }));
          return;
        }
        _hasOutput = true;
        await initialize();
        await stopExternalAudio?.call();
        await _player.stop();
        await _tts.stop();
        if (ticket != _generation) {
          done.complete();
          return;
        }
        final path = _asset(piece, category, gender);
        if (path != null) {
          final subscription = _player.onPlayerComplete.listen((_) {
            if (!done.isCompleted) done.complete();
          });
          try {
            // Await startup so an older asset cannot resume after a newer stop.
            await _player.play(AssetSource(path));
            unawaited(Future.any([done.future, cancel.future])
                .whenComplete(subscription.cancel));
            return;
          } catch (_) {
            await subscription.cancel();
            await _player.stop();
          }
        }
        if (ticket != _generation || !_offlineTtsAvailable) {
          done.complete();
          return;
        }
        unawaited(_tts.speak(piece).catchError((Object error) {
          debugPrint('Speech playback: $error');
          return null;
        }).whenComplete(() {
          if (!done.isCompleted) done.complete();
        }));
      }).catchError((Object error) {
        debugPrint('Speech start: $error');
        if (!done.isCompleted) done.complete();
      });
      await Future.any([done.future, cancel.future]);
      if (index < content.length - 1 && pause > Duration.zero) {
        await Future.any([_pause(pause, cancel.future), cancel.future]);
      }
    }
    if (identical(_cancel, cancel)) {
      _cancel = null;
      _activeAutomatic = false;
    }
  }

  static Future<void> _pause(Duration duration, Future<void> cancellation) {
    final done = Completer<void>();
    final timer = Timer(duration, done.complete);
    return Future.any([done.future, cancellation]).whenComplete(timer.cancel);
  }

  static String whereQuestion(String target) {
    final first = target.substring(0, 1);
    final definite = 'تثدذرزسشصضطظلن'.contains(first)
        ? 'ال$firstّ${target.substring(1)}'
        : 'ال$target';
    return 'أَيْنَ $definite؟';
  }

  static String letterTarget(String value) {
    final matches = lessons.where((e) => e.letter == value);
    return matches.isEmpty ? value : matches.first.soundCue;
  }

  static Future<void> speakScreenEntry(List<String> content) =>
      _sequence(content,
          automatic: true, pause: const Duration(milliseconds: 220));
  static Future<void> speakLessonTarget(String letter, String word,
          {bool automatic = true}) =>
      _sequence([letterTarget(letter), word],
          automatic: automatic, pause: const Duration(milliseconds: 220));
  static Future<void> speakQuestion(List<String> content,
          {bool automatic = true}) =>
      _sequence(content,
          automatic: automatic, pause: const Duration(milliseconds: 180));
  static Future<void> speakTabIntro(List<String> content) =>
      speakScreenEntry(content);
  static Future<void> stopAutomatic() =>
      _activeAutomatic ? stop() : Future.value();

  static Future<void> speak(String value) {
    if (lessons.any((e) =>
        e.letter == value || shortVowelForms(e.letter).contains(value))) {
      return speakLetter(value);
    }
    if (animals.any((e) => e.spokenName == value || e.name == value)) {
      return speakAnimal(value);
    }
    if (shapes.any((e) => e.spokenName == value || e.name == value)) {
      return speakShape(value);
    }
    final number = List.generate(20, (i) => i + 1)
        .where((n) => arabicNumber(n) == value)
        .firstOrNull;
    return number == null ? speakWord(value) : speakNumber(number);
  }

  static Future<void> speakWord(String value) => _sequence([value]);
  static Future<void> speakLetter(String value) {
    final matches = lessons.where((e) => e.letter == value);
    return _sequence([matches.isEmpty ? value : matches.first.soundCue],
        category: 'letters');
  }

  static Future<void> speakAnimal(String value) =>
      _sequence([value], category: 'animals');
  static Future<void> speakShape(String value) =>
      _sequence([value], category: 'shapes');
  static Future<void> speakNumber(int value) =>
      _sequence([spokenArabicNumber(value)], category: 'numbers');
  static Future<void> speakInstruction(ChildInstruction instruction,
          {String? target}) =>
      _sequence([text.instruction(instruction), if (target != null) target],
          category: 'instructions');
  static Future<void> speakForChild(
          {required String boy, required String girl}) =>
      _sequence([text.select(boy, girl)], category: 'feedback');
  static Future<void> speakCorrectFeedback({String? target}) => _sequence([
        text.correctPraise(_random),
        if (target != null) target,
      ], category: 'feedback');
  static Future<void> speakWrongFeedback({String? target}) => _sequence([
        text.tryAgain(_random),
        if (target != null) 'الإِجَابَةُ الصَّحِيحَةُ هِيَ',
        if (target != null) target,
      ], category: 'feedback');
  static Future<void> correctAnswer({String? target}) =>
      speakCorrectFeedback(target: target);
  static Future<void> wrongAnswer({String? target}) =>
      speakWrongFeedback(target: target);
  static Future<void> rewardBox() =>
      _sequence([text.wonReward], category: 'feedback');
  static Future<void> stop() {
    ++_generation;
    _cancel?.complete();
    _cancel = null;
    if (!_hasOutput || playbackOverride != null) return Future.value();
    return _launch = _launch.then((_) async {
      await _player.stop();
      await _tts.stop();
    }).catchError((Object error) {
      debugPrint('Speech stop: $error');
    });
  }
}
