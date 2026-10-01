import 'app_state.dart';

/// One session ledger; persistence remains in the existing AppState database.
class RewardService {
  RewardService({AppState? state}) : _state = state ?? AppState.instance;
  final AppState _state;
  final Set<int> _rewardedRounds = {};
  bool _finished = false;
  Future<bool> answer(int round, bool correct) async {
    if (_finished || !correct || !_rewardedRounds.add(round)) return false;
    return _state.recordAnswer(true);
  }

  Future<void> finish(
      {required int correct,
      required int total,
      required int starsEarned}) async {
    if (_finished) return;
    _finished = true;
    await _state.recordGameResult(
        correct: correct, total: total, starsEarned: starsEarned);
  }
}
