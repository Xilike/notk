class WordExample {
  final String word;
  final String emoji;
  const WordExample(this.word, this.emoji);
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
