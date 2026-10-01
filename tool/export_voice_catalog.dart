import 'dart:convert';
import 'dart:io';
import 'package:tasis_alnotq/data/game_data.dart';
import 'package:tasis_alnotq/data/lesson_data.dart';
import 'package:tasis_alnotq/models/child_profile.dart';
import 'package:tasis_alnotq/services/child_speech_text.dart';

void main() {
  final common = <String>{
    for (final lesson in lessons) ...[
      lesson.letter,
      lesson.soundCue,
      ...shortVowelForms(lesson.letter),
      for (final example in lesson.examples) example.word,
    ],
    for (final animal in animals) animal.spokenName,
    for (final shape in shapes) shape.spokenName,
    for (var number = 0; number <= 20; number++) spokenArabicNumber(number),
    'الإِجَابَةُ الصَّحِيحَةُ هِيَ',
  };
  stdout.writeln(jsonEncode({
    for (final gender in ChildGender.values)
      gender.name: [
        ...common,
        ...ChildSpeechText(gender).praise,
        ...ChildSpeechText(gender).encouragement,
        ChildSpeechText(gender).wonReward,
        for (final instruction in ChildInstruction.values)
          ChildSpeechText(gender).instruction(instruction),
      ],
  }));
}
