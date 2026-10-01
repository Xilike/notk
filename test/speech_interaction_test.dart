import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasis_alnotq/services/app_state.dart';
import 'package:tasis_alnotq/services/speech_service.dart';
import 'package:tasis_alnotq/screens/games_screens.dart';
import 'package:tasis_alnotq/screens/practice_screens.dart';
import 'package:tasis_alnotq/data/game_data.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  final spoken = <String>[];
  Completer<int>? pendingSpeech;

  test('voice selection never chooses a known network-only Arabic voice', () {
    expect(
        SpeechService.selectArabicVoice([
          {
            'name': 'Egyptian neural',
            'locale': 'ar-EG',
            'network_required': '1'
          },
          {
            'name': 'Arabic offline',
            'locale': 'ar-SA',
            'network_required': '0'
          },
        ]),
        {'name': 'Arabic offline', 'locale': 'ar-SA'});
    expect(
        SpeechService.selectArabicVoice([
          {
            'name': 'Arabic remote',
            'locale': 'ar-EG',
            'network_required': true
          },
        ]),
        isNull);
  });

  test('a single Arabic offline voice remains usable', () {
    expect(
        SpeechService.selectArabicVoice([
          {'name': 'Only voice', 'locale': 'ar-SA', 'network_required': '0'},
        ]),
        {'name': 'Only voice', 'locale': 'ar-SA'});
  });

  test('voice selection prefers quality and ignores uninstalled voices', () {
    expect(
        SpeechService.selectArabicVoice([
          {'name': 'Basic', 'locale': 'ar-EG', 'quality': 'normal'},
          {'name': 'Better', 'locale': 'ar-EG', 'quality': 'very_high'},
          {
            'name': 'Unavailable neural',
            'locale': 'ar-EG',
            'features': 'notInstalled'
          },
        ]),
        {'name': 'Better', 'locale': 'ar-EG'});
  });

  setUpAll(() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_tts'),
        (call) async {
      calls.add(call);
      if (call.method == 'getVoices') {
        return [
          {'name': 'Arabic', 'locale': 'ar-SA'},
          {'name': 'Egyptian premium', 'locale': 'ar-EG'},
        ];
      }
      if (call.method == 'speak') {
        spoken.add(call.arguments is String
            ? call.arguments as String
            : (call.arguments as Map)['text'] as String);
        return pendingSpeech?.future ?? Future.value(1);
      }
      if (call.method == 'stop' &&
          pendingSpeech != null &&
          !pendingSpeech!.isCompleted) {
        pendingSpeech!.complete(1);
        pendingSpeech = null;
      }
      return 1;
    });
    messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers.global'), (_) async => 1);
    messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers.global/events'),
        (_) async => null);
    messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'), (call) async {
      if (call.method == 'create') {
        final id = (call.arguments as Map)['playerId'];
        messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null);
      }
      return 1;
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'autoSpeakEnabled': false});
    await AppState.instance.init();
    SpeechService.playbackOverride = (value) async {};
    await SpeechService.stop();
    SpeechService.playbackOverride = null;
    spoken.clear();
  });

  test('missing voice pack falls back to cached Egyptian Arabic TTS', () async {
    await SpeechService.speakAnimal('أَسَد');
    await SpeechService.speakAnimal('ثَعْلَب');
    expect(spoken, ['أَسَد', 'ثَعْلَب']);
    expect(calls.where((c) => c.method == 'setLanguage').length, 1);
    expect(calls.firstWhere((c) => c.method == 'setVoice').arguments,
        {'name': 'Egyptian premium', 'locale': 'ar-EG'});
  });

  test('a newer utterance cancels the rest of an older feedback sequence',
      () async {
    // Initialize before installing the delayed playback response.
    await SpeechService.initialize();
    final firstStarted = Completer<void>();
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_tts'),
        (call) async {
      if (call.method == 'speak') {
        spoken.add(call.arguments is String
            ? call.arguments as String
            : (call.arguments as Map)['text'] as String);
        if (!firstStarted.isCompleted) {
          firstStarted.complete();
          pendingSpeech = Completer<int>();
          return pendingSpeech!.future;
        }
      }
      if (call.method == 'stop' &&
          pendingSpeech != null &&
          !pendingSpeech!.isCompleted) {
        pendingSpeech!.complete(1);
        pendingSpeech = null;
      }
      return 1;
    });
    final old = SpeechService.speakWrongFeedback(target: 'OLD ANSWER');
    await firstStarted.future.timeout(const Duration(seconds: 10));
    await SpeechService.speakAnimal('ثَعْلَب');
    await old;
    expect(spoken.last, 'ثَعْلَب');
    expect(spoken, isNot(contains('OLD ANSWER')));
  });

  testWidgets(
      'sounds: touching the large letter speaks; blank background does nothing',
      (tester) async {
    SpeechService.playbackOverride = (value) async {
      spoken.add(value);
    };
    addTearDown(() => SpeechService.playbackOverride = null);
    await tester.pumpWidget(
        const MaterialApp(home: WordCarouselScreen(mode: PracticeMode.sounds)));
    await tester.tapAt(const Offset(10, 70));
    await tester.pump();
    expect(spoken, isEmpty);
    await tester.runAsync(() async {
      await tester.tap(find.text('أَ'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pumpAndSettle();
    expect(spoken, ['أَ']);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(SpeechService.stop);
    await tester.pumpAndSettle();
  });

  testWidgets(
      'animal card speaks its own name before feedback; rapid taps select once',
      (tester) async {
    SpeechService.playbackOverride = (value) async {
      spoken.add(value);
    };
    addTearDown(() => SpeechService.playbackOverride = null);
    await tester.pumpWidget(const MaterialApp(home: AnimalChoiceGame()));
    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((t) => t.startsWith('أين '));
    final target = animals.firstWhere((a) => question == 'أين ${a.name}؟');
    final card = find.text(target.emoji);
    final objectFinished = Completer<void>();
    SpeechService.playbackOverride = (value) {
      spoken.add(value);
      return value == target.spokenName
          ? objectFinished.future
          : Future<void>.value();
    };
    SpeechService.resetTestPlayback();
    await tester.tap(card);
    await tester.pump();
    await tester.tap(card);
    await tester.pump();
    expect(spoken, [target.spokenName]);
    objectFinished.complete();
    await tester.pumpAndSettle();
    expect(spoken.first, target.spokenName);
    expect(spoken.length, greaterThan(1));
    expect(AppState.instance.coins, 1);
    expect(find.text('السؤال 2/8'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(SpeechService.stop);
    await tester.pumpAndSettle();
  });
}
