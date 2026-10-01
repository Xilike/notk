class WordExample {
  final String word;
  final String emoji;

  /// Optional bundled illustration shown instead of [emoji] when present.
  final String? imageAsset;
  const WordExample(this.word, this.emoji, {this.imageAsset});
}

class LetterLessonData {
  final String letter;
  final String soundCue;
  final List<WordExample> examples;
  const LetterLessonData({
    required this.letter,
    required this.soundCue,
    required this.examples,
  });
}
