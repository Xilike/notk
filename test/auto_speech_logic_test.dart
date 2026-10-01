import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasis_alnotq/services/app_state.dart';
import 'package:tasis_alnotq/services/auto_speech_gate.dart';
import 'package:tasis_alnotq/services/child_speech_text.dart';
import 'package:tasis_alnotq/services/speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final spoken = <String>[];
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SpeechService.playbackOverride = (value) async {
      spoken.add(value);
    };
    SpeechService.resetTestPlayback();
    await AppState.instance.init();
    spoken.clear();
  });
  tearDown(() async {
    await SpeechService.stop();
    SpeechService.playbackOverride = null;
  });

  test('auto speech defaults on and persists independently of sound', () async {
    expect(AppState.instance.autoSpeakEnabled, true);
    await AppState.instance.setAutoSpeak(false);
    await AppState.instance.init();
    expect(AppState.instance.autoSpeakEnabled, false);
    expect(AppState.instance.soundEnabled, true);
    await AppState.instance.setAutoSpeak(true);
    await AppState.instance.init();
    expect(AppState.instance.autoSpeakEnabled, true);
  });

  test('all automatic entry APIs respect OFF while manual speech still works',
      () async {
    await AppState.instance.setAutoSpeak(false);
    await SpeechService.speakScreenEntry(['screen']);
    await SpeechService.speakLessonTarget('أ', 'أَسَد');
    await SpeechService.speakQuestion(['question']);
    await SpeechService.speakTabIntro(['tab']);
    expect(spoken, isEmpty);
    await SpeechService.speakWord('manual');
    await SpeechService.speakQuestion(['replay'], automatic: false);
    expect(spoken, ['manual', 'replay']);
  });

  test('same content never requests twice; new content and return request once',
      () {
    final gate = AutoSpeechGate()..enter();
    final first = gate.request(0)!;
    expect(gate.request(0), isNull);
    final second = gate.request(1)!;
    expect(gate.isCurrent(first), false);
    expect(gate.isCurrent(second), true);
    gate.leave();
    expect(gate.isCurrent(second), false);
    expect(gate.request(2), isNull);
    gate.enter();
    expect(gate.request(1), isNotNull);
    expect(gate.request(1), isNull);
    expect(gate.request(2, enabled: false), isNull);
  });

  test('inactive tab builds cannot trigger speech', () {
    final gate = AutoSpeechGate()
      ..selectTab(0)
      ..enter();
    expect(gate.request('letter', tab: 0), isNotNull);
    expect(gate.request('word', tab: 1), isNull);
    gate.selectTab(1);
    expect(gate.request('letter', tab: 0), isNull);
    expect(gate.request('word', tab: 1), isNotNull);
    expect(gate.request('word', tab: 1), isNull);
  });

  test('automatic instructions preserve boy/girl grammar and common questions',
      () async {
    await SpeechService.speakQuestion(
        [SpeechService.text.instruction(ChildInstruction.dragLetter)]);
    expect(spoken.single, contains('اِسْحَبِ'));
    await AppState.instance.setGender('girl');
    await SpeechService.speakQuestion(
        [SpeechService.text.instruction(ChildInstruction.dragLetter)]);
    expect(spoken.last, contains('اِسْحَبِي'));
    expect(SpeechService.whereQuestion('أَسَد'), 'أَيْنَ الأَسَد؟');
    expect(SpeechService.whereQuestion('دَائِرَة'), 'أَيْنَ الدَّائِرَة؟');
  });

  test('manual object interrupts automatic lesson including its delayed word',
      () async {
    final started = Completer<void>();
    SpeechService.playbackOverride = (value) async {
      spoken.add(value);
      if (!started.isCompleted) started.complete();
    };
    final automatic = SpeechService.speakLessonTarget('أ', 'أَسَد');
    await started.future;
    await SpeechService.speakAnimal('ثَعْلَب');
    await automatic;
    expect(spoken, ['أَ', 'ثَعْلَب']);
  });

  test(
      'turning auto OFF cancels automatic sequence but leaves manual speech alone',
      () async {
    final started = Completer<void>();
    SpeechService.playbackOverride = (value) async {
      spoken.add(value);
      if (!started.isCompleted) started.complete();
    };
    final automatic = SpeechService.speakLessonTarget('أ', 'أَسَد');
    await started.future;
    await AppState.instance.setAutoSpeak(false);
    await automatic;
    expect(spoken, ['أَ']);
    final finishManual = Completer<void>();
    SpeechService.playbackOverride = (value) => finishManual.future;
    final manual = SpeechService.speakWord('manual');
    await AppState.instance.setAutoSpeak(false);
    finishManual.complete();
    await manual;
  });
}
