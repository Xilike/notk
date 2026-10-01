import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasis_alnotq/models/child_profile.dart';
import 'package:tasis_alnotq/services/child_profile_service.dart';
import 'package:tasis_alnotq/services/child_speech_text.dart';
import 'package:tasis_alnotq/services/app_state.dart';
import 'package:tasis_alnotq/services/reward_service.dart';
import 'package:tasis_alnotq/data/matching_round.dart';
import 'package:tasis_alnotq/data/game_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.init();
  });

  test('migrates the existing girl profile without losing progress', () async {
    SharedPreferences.setMockInitialValues({
      'childGender': 'girl',
      'childName': 'نور',
      'level': 'KG2',
      'coins': 24,
      'stars': 90,
      'completedLetters': ['0', '1']
    });
    await AppState.instance.init();
    expect(AppState.instance.profile.gender, ChildGender.girl);
    expect(AppState.instance.childName, 'نور');
    expect(AppState.instance.level, 'KG2');
    expect(AppState.instance.coins, 24);
    expect(AppState.instance.completedLetters, {0, 1});
  });

  test('boy and girl profiles persist and override stale legacy gender',
      () async {
    for (final gender in ChildGender.values) {
      final prefs = await SharedPreferences.getInstance();
      final service = ChildProfileService(prefs);
      await service
          .save(ChildProfile(name: 'نور', gender: gender, level: 'KG2'));
      await prefs.setString(
          'childGender', gender == ChildGender.boy ? 'girl' : 'boy');
      final reloaded = ChildProfileService(prefs);
      await reloaded.load();
      expect(reloaded.profile.gender, gender);
      expect(reloaded.profile.name, 'نور');
      expect(reloaded.profile.level, 'KG2');
    }
  });

  test('onboarding and parent edits share one persisted profile', () async {
    final state = AppState.instance;
    await state.finishOnboarding('', 'KG1', 'girl');
    expect(state.childName, 'بطلتي');
    await state.setGender('boy');
    await state.setLevel('KG2');
    await state.setChildName('عمر');
    await state.init();
    expect(state.profile.gender, ChildGender.boy);
    expect(state.childName, 'عمر');
    expect(state.level, 'KG2');
    expect(state.onboarded, true);
  });

  test('damaged profile migrates safely', () async {
    SharedPreferences.setMockInitialValues(
        {'childProfile': '{bad', 'childGender': 'girl'});
    final service = ChildProfileService(await SharedPreferences.getInstance());
    await service.load();
    expect(service.profile.gender, ChildGender.girl);
    expect(service.profile.name, 'بطلتي');
  });

  test('all random feedback and instructions preserve grammatical gender', () {
    final boy = ChildSpeechText(ChildGender.boy);
    final girl = ChildSpeechText(ChildGender.girl);
    expect(boy.praise, contains('أَحْسَنْتَ!'));
    expect(girl.praise, contains('أَحْسَنْتِ!'));
    expect(boy.instruction(ChildInstruction.choose), 'اِخْتَرْ');
    expect(girl.instruction(ChildInstruction.choose), 'اِخْتَارِي');
    expect(boy.wonReward, contains('فُزْتَ'));
    expect(girl.wonReward, contains('فُزْتِ'));
    final random = Random(20);
    final samples = <String>{};
    for (var i = 0; i < 100; i++) {
      final b = boy.correctPraise(random);
      final g = girl.correctPraise(random);
      samples.add(b);
      expect(boy.praise, contains(b));
      expect(girl.praise, contains(g));
      expect(b, isNot(contains('رَائِعَة')));
      expect(g, isNot(contains('أَنْتَ')));
      expect(boy.encouragement, contains(boy.tryAgain(random)));
      expect(girl.encouragement, contains(girl.tryAgain(random)));
    }
    expect(samples.length, greaterThan(1));
    for (final instruction in ChildInstruction.values) {
      expect(
          boy.instruction(instruction), isNot(girl.instruction(instruction)));
    }
  });

  test('one completed round cannot reward twice even with concurrent taps',
      () async {
    final rewards = RewardService();
    await Future.wait(List.generate(15, (_) => rewards.answer(0, true)));
    expect(AppState.instance.coins, 1);
    expect(AppState.instance.totalCorrectAnswers, 1);
    await rewards.answer(1, false);
    expect(AppState.instance.coins, 1);
    await rewards.answer(1, true);
    expect(AppState.instance.coins, 2);
  });

  test('existing reward boxes and session bonus remain compatible', () async {
    final state = AppState.instance;
    final rewards = RewardService();
    for (var i = 0; i < 10; i++) {
      expect(await rewards.answer(i, true), i == 9);
    }
    expect(state.coins, 10);
    expect(state.rewardBoxes, 1);
    expect(state.stars, 5);
    await Future.wait(List.generate(
        5, (_) => rewards.finish(correct: 6, total: 6, starsEarned: 10)));
    await rewards.answer(11, true);
    expect(state.coins, 10);
    expect(state.gameRounds, 1);
    expect(state.stars, 15);
    expect(state.dailyMinutes, 1);
    await state.init();
    expect(state.coins, 10);
    expect(state.rewardBoxes, 1);
    expect(state.stars, 15);
  });

  test('lesson completion remains idempotent', () async {
    await Future.wait(
        List.generate(10, (_) => AppState.instance.completeLetter(0)));
    expect(AppState.instance.stars, 10);
    expect(AppState.instance.completedLetters, {0});
  });

  test('every generated match has unique choices and exactly one solution', () {
    for (final kind in ShadowMatchKind.values) {
      for (final kg2 in [false, true]) {
        for (var seed = 0; seed < 150; seed++) {
          final round = MatchingRound.generate(
              kind: kind, kg2: kg2, random: Random(seed), unlockedLetters: 4);
          expect(round.options.length, kg2 ? 4 : 3);
          expect(round.options.map((e) => e.id).toSet().length,
              round.options.length);
          expect(round.options.where(round.matches).length, 1);
          if (kind == ShadowMatchKind.number) {
            expect(
                int.parse(round.target.id), inInclusiveRange(1, kg2 ? 10 : 5));
          }
        }
      }
    }
  });

  test('number architecture supports twenty and fox/lion have correct names',
      () {
    final round = MatchingRound.generate(
        kind: ShadowMatchKind.number,
        kg2: true,
        random: Random(1),
        maximumNumber: 20);
    expect(round.options.length, 4);
    expect(spokenArabicNumber(20), 'عِشْرُون');
    expect(animals.firstWhere((a) => a.name == 'ثعلب').spokenName, 'ثَعْلَب');
    expect(animals.firstWhere((a) => a.name == 'أسد').spokenName, 'أَسَد');
  });
}
