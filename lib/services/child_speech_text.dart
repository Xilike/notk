import 'dart:math';
import '../models/child_profile.dart';

enum ChildInstruction {
  choose,
  chooseLetter,
  chooseGame,
  orderLetters,
  orderNumbers,
  dragAnimal,
  dragLetter,
  dragNumber
}

class ChildSpeechText {
  ChildSpeechText(this.gender);
  final ChildGender gender;
  bool get isGirl => gender == ChildGender.girl;
  String select(String boy, String girl) => isGirl ? girl : boy;
  List<String> get praise => isGirl
      ? const [
          'أَحْسَنْتِ!',
          'مُمْتَازَة!',
          'أَنْتِ رَائِعَة!',
          'بَطَلَة!',
          'إِجَابَةٌ صَحِيحَة!'
        ]
      : const [
          'أَحْسَنْتَ!',
          'مُمْتَاز!',
          'أَنْتَ رَائِع!',
          'بَطَل!',
          'إِجَابَةٌ صَحِيحَة!'
        ];
  List<String> get encouragement => isGirl
      ? const [
          'حَاوِلِي مَرَّةً أُخْرَى',
          'جَرِّبِي مَرَّةً ثَانِيَة',
          'أَنْتِ قَرِيبَة، حَاوِلِي مِنْ جَدِيد'
        ]
      : const [
          'حَاوِلْ مَرَّةً أُخْرَى',
          'جَرِّبْ مَرَّةً ثَانِيَة',
          'أَنْتَ قَرِيب، حَاوِلْ مِنْ جَدِيد'
        ];
  String correctPraise(Random random) => praise[random.nextInt(praise.length)];
  String tryAgain(Random random) =>
      encouragement[random.nextInt(encouragement.length)];
  String get wonReward => select(
      'مُفَاجَأَة! فُزْتَ بِصُنْدُوقِ مُكَافَأَة وَخَمْسِ نُجُوم يَا بَطَل!',
      'مُفَاجَأَة! فُزْتِ بِصُنْدُوقِ مُكَافَأَة وَخَمْسِ نُجُوم يَا بَطَلَة!');
  String instruction(ChildInstruction instruction) => switch (instruction) {
        ChildInstruction.choose => select('اِخْتَرْ', 'اِخْتَارِي'),
        ChildInstruction.chooseLetter =>
          select('اِخْتَرْ حَرْفًا', 'اِخْتَارِي حَرْفًا'),
        ChildInstruction.chooseGame =>
          select('اِخْتَرْ لُعْبَةً', 'اِخْتَارِي لُعْبَةً'),
        ChildInstruction.orderLetters => select(
            'رَتِّبِ الحُرُوفَ بِالتَّرْتِيبِ الصَّحِيح',
            'رَتِّبِي الحُرُوفَ بِالتَّرْتِيبِ الصَّحِيح'),
        ChildInstruction.orderNumbers => select(
            'رَتِّبِ الأَرْقَامَ مِنَ الأَصْغَرِ إِلَى الأَكْبَر',
            'رَتِّبِي الأَرْقَامَ مِنَ الأَصْغَرِ إِلَى الأَكْبَر'),
        ChildInstruction.dragAnimal => select(
            'اِسْحَبِ الحَيَوَانَ المُطَابِقَ إِلَى ظِلِّهِ',
            'اِسْحَبِي الحَيَوَانَ المُطَابِقَ إِلَى ظِلِّهِ'),
        ChildInstruction.dragLetter => select(
            'اِسْحَبِ الحَرْفَ المُطَابِقَ إِلَى مَكَانِهِ',
            'اِسْحَبِي الحَرْفَ المُطَابِقَ إِلَى مَكَانِهِ'),
        ChildInstruction.dragNumber => select(
            'اِسْحَبِ الرَّقْمَ المُطَابِقَ إِلَى مَكَانِهِ',
            'اِسْحَبِي الرَّقْمَ المُطَابِقَ إِلَى مَكَانِهِ'),
      };
}
