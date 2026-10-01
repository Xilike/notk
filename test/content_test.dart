import 'package:flutter_test/flutter_test.dart';
import 'package:tasis_alnotq/data/lesson_data.dart';
import 'package:tasis_alnotq/data/game_data.dart';

void main() {
  test('contains exactly 28 unique Arabic letter lessons', () {
    expect(lessons.length, 28);
    expect(lessons.map((e) => e.letter).toSet().length, 28);
  });

  test('each letter has three usable examples: 84 words total', () {
    var total = 0;
    for (final lesson in lessons) {
      expect(lesson.examples.length, 3);
      total += lesson.examples.length;
      for (final example in lesson.examples) {
        expect(example.word.trim().isNotEmpty, true);
        expect(example.emoji.trim().isNotEmpty, true);
      }
    }
    expect(total, 84);
  });

  test('short vowel forms cover fatha damma kasra', () {
    expect(shortVowelForms('ب'), ['بَ', 'بُ', 'بِ']);
    expect(shortVowelForms('أ'), ['أَ', 'أُ', 'إِ']);
    expect(shortVowelForms('هـ'), ['هَ', 'هُ', 'هِ']);
    expect(shortVowelNames.length, 3);
  });

  test('educational games have enough unique animals and shapes', () {
    expect(animals.length >= 10, true);
    expect(animals.map((e) => e.name).toSet().length, animals.length);
    expect(shapes.length >= 6, true);
    expect(shapes.map((e) => e.name).toSet().length, shapes.length);
    expect(arabicNumber(10), '١٠');
    expect(spokenArabicNumber(1), 'وَاحِد');
    expect(spokenArabicNumber(10), 'عَشَرَة');
  });
}
