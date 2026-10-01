import 'dart:convert';
import 'dart:math';
import '../models/child_profile.dart';
import 'child_profile_service.dart';
import 'speech_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  late SharedPreferences _prefs;
  late ChildProfileService _profiles;
  ChildProfile get profile => _profiles.profile;
  String get childName => profile.name;
  String get childGender => profile.gender.name;
  String get level => profile.level;
  int stars = 0;
  int coins = 0;
  int rewardBoxes = 0;
  int totalCorrectAnswers = 0;
  int unlockedLetters = 4;
  Set<int> completedLetters = <int>{};
  int dailyGoalMinutes = 10;
  int dailyMinutes = 0;
  int streak = 0;
  bool soundEnabled = true;
  bool autoSpeakEnabled = true;
  bool onboarded = false;
  int gameRounds = 0;
  int gameCorrect = 0;
  int gameQuestions = 0;
  int repeatAttempts = 0;
  bool _goalCountedToday = false;
  String _todayKey = '';
  final Map<String, int> _activityHistory = <String, int>{};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _profiles = ChildProfileService(_prefs);
    await _profiles.load();
    stars = _prefs.getInt('stars') ?? 0;
    coins = _prefs.getInt('coins') ?? 0;
    rewardBoxes = _prefs.getInt('rewardBoxes') ?? 0;
    totalCorrectAnswers = _prefs.getInt('totalCorrectAnswers') ?? 0;
    unlockedLetters = _prefs.getInt('unlockedLetters') ?? 4;
    completedLetters = (_prefs.getStringList('completedLetters') ?? const [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    dailyGoalMinutes = _prefs.getInt('dailyGoalMinutes') ?? 10;
    dailyMinutes = _prefs.getInt('dailyMinutes') ?? 0;
    streak = _prefs.getInt('streak') ?? 0;
    soundEnabled = _prefs.getBool('soundEnabled') ?? true;
    autoSpeakEnabled = _prefs.getBool('autoSpeakEnabled') ?? true;
    onboarded = _prefs.getBool('onboarded') ?? false;
    gameRounds = _prefs.getInt('gameRounds') ?? 0;
    gameCorrect = _prefs.getInt('gameCorrect') ?? 0;
    gameQuestions = _prefs.getInt('gameQuestions') ?? 0;
    repeatAttempts = _prefs.getInt('repeatAttempts') ?? 0;
    _goalCountedToday = _prefs.getBool('goalCountedToday') ?? false;
    _loadHistory();

    final now = DateTime.now();
    _todayKey = _dateKey(now);
    final lastDay = _prefs.getString('lastOpenDay');
    if (lastDay == null) {
      await _prefs.setString('lastOpenDay', _todayKey);
      return;
    }
    if (lastDay != _todayKey) {
      _activityHistory[lastDay] = dailyMinutes;
      _trimHistory();
      final yesterday = _dateKey(now.subtract(const Duration(days: 1)));
      if (lastDay != yesterday || !_goalCountedToday) {
        streak = 0;
      }
      dailyMinutes = 0;
      _goalCountedToday = false;
      await _persistDayState();
      await _persistHistory();
    }
  }

  void _loadHistory() {
    _activityHistory.clear();
    final raw = _prefs.getString('activityHistory');
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is num) _activityHistory[entry.key] = value.toInt();
        }
      }
    } catch (_) {
      _activityHistory.clear();
    }
  }

  void _trimHistory() {
    final keys = _activityHistory.keys.toList()..sort();
    while (keys.length > 30) {
      _activityHistory.remove(keys.removeAt(0));
    }
  }

  Future<void> _persistHistory() =>
      _prefs.setString('activityHistory', jsonEncode(_activityHistory));

  Future<void> _persistDayState() async {
    await _prefs.setInt('dailyMinutes', dailyMinutes);
    await _prefs.setInt('streak', streak);
    await _prefs.setBool('goalCountedToday', _goalCountedToday);
    await _prefs.setString('lastOpenDay', _todayKey);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int minutesForDate(DateTime date) {
    final key = _dateKey(date);
    if (key == _todayKey) return dailyMinutes;
    return _activityHistory[key] ?? 0;
  }

  int get gameAccuracy =>
      gameQuestions == 0 ? 0 : ((gameCorrect / gameQuestions) * 100).round();

  Future<void> finishOnboarding(
    String name,
    String selectedLevel,
    String selectedGender,
  ) async {
    final gender =
        selectedGender == 'girl' ? ChildGender.girl : ChildGender.boy;
    await _profiles.save(ChildProfile(
        name: name.trim().isEmpty
            ? (gender == ChildGender.girl ? 'بطلتي' : 'بطلي')
            : name.trim(),
        gender: gender,
        level: selectedLevel == 'KG2' ? 'KG2' : 'KG1'));
    onboarded = true;
    await _prefs.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> setChildName(String name) async {
    await _profiles.save(profile.copyWith(
        name: name.trim().isEmpty
            ? (profile.gender == ChildGender.girl ? 'بطلتي' : 'بطلي')
            : name.trim()));
    notifyListeners();
  }

  Future<void> setGender(String value) async {
    await SpeechService.stop();
    final gender = value == 'girl' ? ChildGender.girl : ChildGender.boy;
    final defaultName = childName == 'بطلي' || childName == 'بطلتي';
    await _profiles.save(profile.copyWith(
        gender: gender,
        name: defaultName
            ? (gender == ChildGender.girl ? 'بطلتي' : 'بطلي')
            : childName));
    notifyListeners();
  }

  Future<void> setLevel(String value) async {
    await _profiles
        .save(profile.copyWith(level: value == 'KG2' ? 'KG2' : 'KG1'));
    notifyListeners();
  }

  Future<void> setDailyGoal(int minutes) async {
    dailyGoalMinutes = minutes.clamp(5, 30).toInt();
    await _prefs.setInt('dailyGoalMinutes', dailyGoalMinutes);
    if (!_goalCountedToday && dailyMinutes >= dailyGoalMinutes) {
      _goalCountedToday = true;
      streak += 1;
      await _persistDayState();
    }
    notifyListeners();
  }

  Future<void> setAutoSpeak(bool value) async {
    autoSpeakEnabled = value;
    if (!value) await SpeechService.stopAutomatic();
    await _prefs.setBool('autoSpeakEnabled', value);
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    soundEnabled = value;
    if (!value) await SpeechService.stop();
    await _prefs.setBool('soundEnabled', value);
    notifyListeners();
  }

  Future<void> completeLetter(int index) async {
    final firstTime = completedLetters.add(index);
    if (firstTime) {
      stars += 10;
      unlockedLetters = max(unlockedLetters, min(28, index + 2));
      await _prefs.setStringList(
          'completedLetters', completedLetters.map((e) => '$e').toList());
      await _prefs.setInt('stars', stars);
      await _prefs.setInt('unlockedLetters', unlockedLetters);
      await addLearningMinute(notify: false);
    }
    notifyListeners();
  }

  Future<void> recordGameResult({
    required int correct,
    required int total,
    required int starsEarned,
  }) async {
    gameRounds += 1;
    gameCorrect += correct;
    gameQuestions += total;
    stars += starsEarned;
    await _prefs.setInt('gameRounds', gameRounds);
    await _prefs.setInt('gameCorrect', gameCorrect);
    await _prefs.setInt('gameQuestions', gameQuestions);
    await _prefs.setInt('stars', stars);
    await addLearningMinute(notify: false);
    notifyListeners();
  }

  Future<void> rewardGame({int starsEarned = 5}) async {
    await recordGameResult(correct: 0, total: 0, starsEarned: starsEarned);
  }

  Future<bool> recordAnswer(bool correct) async {
    if (!correct) return false;
    coins += 1;
    totalCorrectAnswers += 1;
    var openedBox = false;
    if (totalCorrectAnswers % 10 == 0) {
      rewardBoxes += 1;
      stars += 5;
      openedBox = true;
    }
    await _prefs.setInt('coins', coins);
    await _prefs.setInt('rewardBoxes', rewardBoxes);
    await _prefs.setInt('totalCorrectAnswers', totalCorrectAnswers);
    await _prefs.setInt('stars', stars);
    notifyListeners();
    return openedBox;
  }

  Future<void> recordRepeatAttempt() async {
    repeatAttempts += 1;
    await _prefs.setInt('repeatAttempts', repeatAttempts);
    notifyListeners();
  }

  Future<void> addLearningMinute({bool notify = true}) async {
    dailyMinutes += 1;
    if (!_goalCountedToday && dailyMinutes >= dailyGoalMinutes) {
      _goalCountedToday = true;
      streak += 1;
    }
    await _persistDayState();
    if (notify) notifyListeners();
  }

  Future<void> resetProgress() async {
    stars = 0;
    coins = 0;
    rewardBoxes = 0;
    totalCorrectAnswers = 0;
    unlockedLetters = 4;
    completedLetters.clear();
    dailyMinutes = 0;
    streak = 0;
    gameRounds = 0;
    gameCorrect = 0;
    gameQuestions = 0;
    repeatAttempts = 0;
    _goalCountedToday = false;
    _activityHistory.clear();
    await _prefs.setInt('stars', 0);
    await _prefs.setInt('coins', 0);
    await _prefs.setInt('rewardBoxes', 0);
    await _prefs.setInt('totalCorrectAnswers', 0);
    await _prefs.setInt('unlockedLetters', 4);
    await _prefs.setStringList('completedLetters', const []);
    await _prefs.setInt('dailyMinutes', 0);
    await _prefs.setInt('streak', 0);
    await _prefs.setInt('gameRounds', 0);
    await _prefs.setInt('gameCorrect', 0);
    await _prefs.setInt('gameQuestions', 0);
    await _prefs.setInt('repeatAttempts', 0);
    await _prefs.setBool('goalCountedToday', false);
    await _prefs.remove('activityHistory');
    notifyListeners();
  }
}
