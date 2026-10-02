import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasis_alnotq/data/game_data.dart';
import 'package:tasis_alnotq/data/matching_round.dart';
import 'package:tasis_alnotq/services/app_state.dart';
import 'package:tasis_alnotq/services/speech_service.dart';
import 'package:tasis_alnotq/widgets/auto_speak_page.dart';
import 'package:tasis_alnotq/screens/games_screens.dart';
import 'package:tasis_alnotq/screens/letters_screen.dart';
import 'package:tasis_alnotq/screens/practice_screens.dart';
import 'package:tasis_alnotq/screens/parent_screens.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
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

  // Recording widgets instantiate native services even when no recording is made.
  setUpAll(() {
    final messenger = binding.defaultBinaryMessenger;
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
    messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'), (call) async {
      if (call.method == 'create') {
        final id = (call.arguments as Map)['recorderId'];
        messenger.setMockMethodCallHandler(
            MethodChannel('com.llfbandit.record/events/$id'),
            (_) async => null);
      }
      return null;
    });
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
  }

  Widget app(Widget page) =>
      MaterialApp(navigatorObservers: [educationalRouteObserver], home: page);
  void largeView(WidgetTester tester) {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('sound entry/next speak once; rebuild and resize do not repeat',
      (tester) async {
    largeView(tester);
    await tester
        .pumpWidget(app(const WordCarouselScreen(mode: PracticeMode.sounds)));
    await settle(tester);
    expect(spoken, ['أَ']);
    await tester
        .pumpWidget(app(const WordCarouselScreen(mode: PracticeMode.sounds)));
    tester.view.physicalSize = const Size(620, 1020);
    await settle(tester);
    expect(spoken, ['أَ']);
    await tester.tap(find.text('التالي'));
    await settle(tester);
    expect(spoken, ['أَ', 'بَ']);
    await tester.tap(find.text('السابق'));
    await settle(tester);
    expect(spoken, ['أَ', 'بَ', 'أَ']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'a covered page stays silent and speaks current target once on return',
      (tester) async {
    largeView(tester);
    await tester
        .pumpWidget(app(const WordCarouselScreen(mode: PracticeMode.sounds)));
    await settle(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Parent page')))));
    await tester.pumpAndSettle();
    expect(spoken, ['أَ']);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(spoken, ['أَ', 'أَ']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('automatic animal questions advance exactly once after feedback',
      (tester) async {
    largeView(tester);
    await tester.pumpWidget(app(const AnimalChoiceGame()));
    await settle(tester);
    final question = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere((s) => s.startsWith('أين '));
    final target = animals.firstWhere((a) => question == 'أين ${a.name}؟');
    expect(spoken, [SpeechService.whereQuestion(target.spokenName)]);
    await tester.tap(find.byKey(ValueKey('animal-option-${target.name}')));
    await settle(tester);
    expect(spoken[1], target.spokenName);
    expect(spoken.where((s) => s.startsWith('أَيْنَ')).length, 2);
    expect(AppState.instance.coins, 1);
    await tester.pumpWidget(app(const AnimalChoiceGame()));
    await settle(tester);
    expect(spoken.where((s) => s.startsWith('أَيْنَ')).length, 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'OFF suppresses page entry but letter touch and replay still speak',
      (tester) async {
    largeView(tester);
    await AppState.instance.setAutoSpeak(false);
    await tester
        .pumpWidget(app(const WordCarouselScreen(mode: PracticeMode.sounds)));
    await settle(tester);
    expect(spoken, isEmpty);
    await tester.tap(find.text('أَ'));
    await settle(tester);
    expect(spoken, ['أَ']);
    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    await settle(tester);
    expect(spoken, ['أَ', 'أَ']);
    await tester.tap(find.text('التالي'));
    await settle(tester);
    expect(spoken, ['أَ', 'أَ']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'lesson speaks letter then example with a pause; next example repeats sequence',
      (tester) async {
    largeView(tester);
    await tester.pumpWidget(app(const LetterLessonScreen(index: 0)));
    await tester.pump();
    expect(spoken, ['أَ']);
    await tester.pump(const Duration(milliseconds: 100));
    expect(spoken, ['أَ']);
    await settle(tester);
    expect(spoken, ['أَ', 'أَسَد']);
    await tester.tap(find.text('التالي'));
    await settle(tester);
    expect(spoken, ['أَ', 'أَسَد', 'أَ', 'أَرْنَب']);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
  });

  testWidgets('tabs speak only the newly settled active tab', (tester) async {
    largeView(tester);
    await tester.pumpWidget(app(const _TabHarness()));
    await tester.pumpAndSettle();
    expect(spoken, ['tab 0']);
    await tester.tap(find.text('Words'));
    await tester.pumpAndSettle();
    expect(spoken, ['tab 0', 'tab 1']);
    await tester.tap(find.text('Words'));
    await tester.pumpAndSettle();
    expect(spoken, ['tab 0', 'tab 1']);
    await tester.drag(find.byType(TabBarView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(spoken, ['tab 0', 'tab 1', 'tab 2']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'matching speaks its instruction only on first round and next target once',
      (tester) async {
    largeView(tester);
    await tester
        .pumpWidget(app(const ShadowMatchGame(kind: ShadowMatchKind.letter)));
    await settle(tester);
    final instruction = spoken.first;
    final target = find.byKey(const ValueKey('match-target'));
    final display = tester
        .widgetList<Text>(
            find.descendant(of: target, matching: find.byType(Text)))
        .first
        .data;
    final choice = tester
        .widgetList<Draggable<MatchChoice>>(find.byType(Draggable<MatchChoice>))
        .firstWhere((d) => d.data!.display == display)
        .data!;
    final source = find.byKey(ValueKey('choice-${choice.id}'));
    await tester.drag(
        source, tester.getCenter(target) - tester.getCenter(source));
    await settle(tester);
    await settle(tester);
    expect(find.text('الجولة 2/6'), findsOneWidget);
    expect(spoken.where((s) => s == instruction).length, 1);
    final nextDisplay = tester
        .widgetList<Text>(
            find.descendant(of: target, matching: find.byType(Text)))
        .first
        .data!;
    expect(spoken.last, SpeechService.letterTarget(nextDisplay));
    final count = spoken.length;
    await tester
        .pumpWidget(app(const ShadowMatchGame(kind: ShadowMatchKind.letter)));
    await settle(tester);
    expect(spoken.length, count);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'replacing a route cancels its delayed word without cancelling new page speech',
      (tester) async {
    largeView(tester);
    final newLetterFinished = Completer<void>();
    SpeechService.playbackOverride = (value) {
      spoken.add(value);
      return value == 'بَ' ? newLetterFinished.future : Future<void>.value();
    };
    await tester.pumpWidget(app(const LetterLessonScreen(index: 0)));
    await tester.pump();
    expect(spoken, ['أَ']);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.pushReplacement(MaterialPageRoute<void>(
        builder: (_) => const LetterLessonScreen(index: 1))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(spoken, ['أَ', 'بَ']);
    newLetterFinished.complete();
    await settle(tester);
    expect(spoken, ['أَ', 'بَ', 'بَطَّة']);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
  });

  testWidgets('parent auto-speech switch persists and keeps sound on',
      (tester) async {
    largeView(tester);
    await tester.pumpWidget(app(const ParentDashboardScreen()));
    final setting = find.widgetWithText(SwitchListTile, 'النطق التلقائي');
    await tester.scrollUntilVisible(setting, 400);
    expect(tester.widget<SwitchListTile>(setting).value, true);
    await tester.tap(setting);
    await tester.pumpAndSettle();
    expect(AppState.instance.autoSpeakEnabled, false);
    expect(AppState.instance.soundEnabled, true);
    await AppState.instance.init();
    expect(AppState.instance.autoSpeakEnabled, false);
    await tester.pumpWidget(const SizedBox());
  });

  final cases = <String, Widget>{
    'shape': const ShapeChoiceGame(),
    'listen choose': const ListenChooseGame(),
    'first letter': const FirstLetterGame(),
    'match word': const MatchWordGame(),
    'order letters': const LetterOrderingGame(),
    'order numbers': const NumberOrderingGame(),
    'shadow animal': const ShadowMatchGame(kind: ShadowMatchKind.animal),
    'shadow letter': const ShadowMatchGame(kind: ShadowMatchKind.letter),
    'shadow number': const ShadowMatchGame(kind: ShadowMatchKind.number),
    'words': const WordCarouselScreen(mode: PracticeMode.words),
    'repeat': const RepeatPracticeScreen(),
    'letters hub': const LettersScreen(),
    'games hub': const GamesHubScreen(),
  };
  for (final entry in cases.entries) {
    testWidgets('${entry.key} speaks on entry without a speaker tap',
        (tester) async {
      largeView(tester);
      await tester.pumpWidget(app(entry.value));
      await settle(tester);
      expect(spoken, isNotEmpty);
      final count = spoken.length;
      await tester.pumpWidget(app(entry.value));
      await settle(tester);
      expect(spoken.length, count);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
    });
  }
}

class _TabHarness extends StatefulWidget {
  const _TabHarness();
  @override
  State<_TabHarness> createState() => _TabHarnessState();
}

class _TabHarnessState extends State<_TabHarness>
    with SingleTickerProviderStateMixin, AutoSpeakPage<_TabHarness> {
  late final TabController tabs;
  @override
  void initState() {
    super.initState();
    tabs = TabController(length: 3, vsync: this);
    watchAutoSpeechTabs(tabs);
  }

  @override
  Object get autoSpeechKey => tabs.index;
  @override
  Future<void> speakVisibleContent() =>
      SpeechService.speakTabIntro(['tab ${tabs.index}']);
  @override
  Widget build(BuildContext context) => Scaffold(
          body: Column(children: [
        TabBar(controller: tabs, tabs: const [
          Tab(text: 'Letters'),
          Tab(text: 'Words'),
          Tab(text: 'Sounds')
        ]),
        Expanded(
            child: TabBarView(controller: tabs, children: const [
          Text('content 0'),
          Text('content 1'),
          Text('content 2'),
        ])),
      ]));
  @override
  void dispose() {
    super.dispose();
    tabs.dispose();
  }
}
