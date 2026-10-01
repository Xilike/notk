import 'dart:math';
import 'game_data.dart';
import 'lesson_data.dart';

enum ShadowMatchKind { animal, letter, number }

class MatchChoice {
  final String id;
  final String display;
  final String spoken;
  final bool isEmoji;
  final String? imageAsset;
  const MatchChoice(
      {required this.id,
      required this.display,
      required this.spoken,
      this.isEmoji = false,
      this.imageAsset});
}

class MatchingRound {
  final MatchChoice target;
  final List<MatchChoice> options;
  MatchingRound(this.target, List<MatchChoice> options)
      : options = List.unmodifiable(options);
  bool matches(MatchChoice choice) => target.id == choice.id;

  static MatchingRound generate(
      {required ShadowMatchKind kind,
      required bool kg2,
      required Random random,
      int unlockedLetters = 28,
      int? maximumNumber}) {
    final count = kg2 ? 4 : 3;
    final pool = switch (kind) {
      ShadowMatchKind.animal => animals
          .map((e) => MatchChoice(
              id: e.name,
              display: e.emoji,
              spoken: e.spokenName,
              isEmoji: true,
              imageAsset: e.imageAsset))
          .toList(),
      ShadowMatchKind.letter => lessons
          .take(unlockedLetters.clamp(4, 28))
          .map((e) =>
              MatchChoice(id: e.letter, display: e.letter, spoken: e.soundCue))
          .toList(),
      ShadowMatchKind.number => List.generate(
          maximumNumber ?? (kg2 ? 10 : 5),
          (i) => MatchChoice(
              id: '${i + 1}',
              display: arabicNumber(i + 1),
              spoken: spokenArabicNumber(i + 1))),
    };
    final target = pool[random.nextInt(pool.length)];
    final rest = pool.where((e) => e.id != target.id).toList()..shuffle(random);
    if (kg2 && kind == ShadowMatchKind.letter) {
      const groups = ['بتث', 'جحخ', 'دذ', 'رز', 'سش', 'صض', 'طظ', 'عغ', 'فق'];
      final group = groups.where((g) => g.contains(target.id)).firstOrNull;
      if (group != null) {
        rest.sort((a, b) => (group.contains(b.id) ? 1 : 0)
            .compareTo(group.contains(a.id) ? 1 : 0));
      }
    }
    final options = [target, ...rest.take(count - 1)]..shuffle(random);
    return MatchingRound(target, options);
  }
}
