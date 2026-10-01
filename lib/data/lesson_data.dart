import '../models/lesson.dart';

const _w = 'assets/images/words';

const lessons = <LetterLessonData>[
  LetterLessonData(letter: 'أ', soundCue: 'أَ', examples: [
    WordExample('أَسَد', '🦁', imageAsset: '$_w/asad.png'),
    WordExample('أَرْنَب', '🐇', imageAsset: '$_w/arnab.png'),
    WordExample('أَنَانَاس', '🍍', imageAsset: '$_w/ananas.png')
  ]),
  LetterLessonData(letter: 'ب', soundCue: 'بَ', examples: [
    WordExample('بَطَّة', '🦆', imageAsset: '$_w/batta.png'),
    WordExample('بَاب', '🚪', imageAsset: '$_w/bab.png'),
    WordExample('بَالُون', '🎈', imageAsset: '$_w/balon.png')
  ]),
  LetterLessonData(letter: 'ت', soundCue: 'تَ', examples: [
    WordExample('تُفَّاح', '🍎', imageAsset: '$_w/tuffah.png'),
    WordExample('تَاج', '👑', imageAsset: '$_w/tag.png'),
    WordExample('تِمْسَاح', '🐊', imageAsset: '$_w/timsah.png')
  ]),
  LetterLessonData(letter: 'ث', soundCue: 'ثَ', examples: [
    WordExample('ثَعْلَب', '🦊', imageAsset: '$_w/thaalab.png'),
    WordExample('ثَوْب', '👕', imageAsset: '$_w/thawb.png'),
    WordExample('ثَلْج', '❄️', imageAsset: '$_w/thalj.png')
  ]),
  LetterLessonData(letter: 'ج', soundCue: 'جَ', examples: [
    WordExample('جَمَل', '🐪', imageAsset: '$_w/gamal.png'),
    WordExample('جَرَس', '🔔', imageAsset: '$_w/garas.png'),
    WordExample('جُبْن', '🧀', imageAsset: '$_w/gubn.png')
  ]),
  LetterLessonData(letter: 'ح', soundCue: 'حَ', examples: [
    WordExample('حِصَان', '🐴', imageAsset: '$_w/hisan.png'),
    WordExample('حُوت', '🐋', imageAsset: '$_w/hut.png'),
    WordExample('حَلِيب', '🥛', imageAsset: '$_w/halib.png')
  ]),
  LetterLessonData(letter: 'خ', soundCue: 'خَ', examples: [
    WordExample('خَرُوف', '🐑', imageAsset: '$_w/kharuf.png'),
    WordExample('خُبْز', '🍞', imageAsset: '$_w/khubz.png'),
    WordExample('خِيَار', '🥒', imageAsset: '$_w/khiyar.png')
  ]),
  LetterLessonData(letter: 'د', soundCue: 'دَ', examples: [
    WordExample('دُبّ', '🐻', imageAsset: '$_w/dubb.png'),
    WordExample('دَجَاجَة', '🐔', imageAsset: '$_w/dagaga.png'),
    WordExample('دَفْتَر', '📒', imageAsset: '$_w/daftar.png')
  ]),
  LetterLessonData(letter: 'ذ', soundCue: 'ذَ', examples: [
    WordExample('ذُرَة', '🌽', imageAsset: '$_w/dhura.png'),
    WordExample('ذِئْب', '🐺', imageAsset: '$_w/dhib.png'),
    WordExample('ذِرَاع', '💪', imageAsset: '$_w/dhiraa.png')
  ]),
  LetterLessonData(letter: 'ر', soundCue: 'رَ', examples: [
    WordExample('رُمَّان', '🍎', imageAsset: '$_w/rumman.png'),
    WordExample('رِيشَة', '🪶', imageAsset: '$_w/risha.png'),
    WordExample('رُوبُوت', '🤖', imageAsset: '$_w/robot.png')
  ]),
  LetterLessonData(letter: 'ز', soundCue: 'زَ', examples: [
    WordExample('زَرَافَة', '🦒', imageAsset: '$_w/zarafa.png'),
    WordExample('زَهْرَة', '🌼', imageAsset: '$_w/zahra.png'),
    WordExample('زَيْتُون', '🫒', imageAsset: '$_w/zaytun.png')
  ]),
  LetterLessonData(letter: 'س', soundCue: 'سَ', examples: [
    WordExample('سَمَكَة', '🐟', imageAsset: '$_w/samaka.png'),
    WordExample('سَيَّارَة', '🚗', imageAsset: '$_w/sayyara.png'),
    WordExample('سَاعَة', '⌚', imageAsset: '$_w/saa.png')
  ]),
  LetterLessonData(letter: 'ش', soundCue: 'شَ', examples: [
    WordExample('شَمْس', '☀️', imageAsset: '$_w/shams.png'),
    WordExample('شَجَرَة', '🌳', imageAsset: '$_w/shagara.png'),
    WordExample('شَمْعَة', '🕯️', imageAsset: '$_w/shamaa.png')
  ]),
  LetterLessonData(letter: 'ص', soundCue: 'صَ', examples: [
    WordExample('صَقْر', '🦅', imageAsset: '$_w/saqr.png'),
    WordExample('صُنْدُوق', '📦', imageAsset: '$_w/sanduq.png'),
    WordExample('صَابُون', '🧼', imageAsset: '$_w/sabun.png')
  ]),
  LetterLessonData(letter: 'ض', soundCue: 'ضَ', examples: [
    WordExample('ضِفْدَع', '🐸', imageAsset: '$_w/difda.png'),
    WordExample('ضِرْس', '🦷', imageAsset: '$_w/dirs.png'),
    WordExample('ضَوْء', '💡', imageAsset: '$_w/daw.png')
  ]),
  LetterLessonData(letter: 'ط', soundCue: 'طَ', examples: [
    WordExample('طَائِر', '🐦', imageAsset: '$_w/tair.png'),
    WordExample('طَمَاطِم', '🍅', imageAsset: '$_w/tamatim.png'),
    WordExample('طَبْل', '🥁', imageAsset: '$_w/tabl.png')
  ]),
  LetterLessonData(letter: 'ظ', soundCue: 'ظَ', examples: [
    WordExample('ظَرْف', '✉️', imageAsset: '$_w/zarf.png'),
    WordExample('ظِلّ', '🌤️', imageAsset: '$_w/zill.png'),
    WordExample('ظَبْي', '🦌', imageAsset: '$_w/zaby.png')
  ]),
  LetterLessonData(letter: 'ع', soundCue: 'عَ', examples: [
    WordExample('عِنَب', '🍇', imageAsset: '$_w/inab.png'),
    WordExample('عُصْفُور', '🐦', imageAsset: '$_w/usfur.png'),
    WordExample('عَيْن', '👁️', imageAsset: '$_w/ayn.png')
  ]),
  LetterLessonData(letter: 'غ', soundCue: 'غَ', examples: [
    WordExample('غَزَال', '🦌', imageAsset: '$_w/ghazal.png'),
    WordExample('غَيْمَة', '☁️', imageAsset: '$_w/ghayma.png'),
    WordExample('غُرَاب', '🐦‍⬛', imageAsset: '$_w/ghurab.png')
  ]),
  LetterLessonData(letter: 'ف', soundCue: 'فَ', examples: [
    WordExample('فِيل', '🐘', imageAsset: '$_w/fil.png'),
    WordExample('فَرَاوِلَة', '🍓', imageAsset: '$_w/farawla.png'),
    WordExample('فَرَاشَة', '🦋', imageAsset: '$_w/farasha.png')
  ]),
  LetterLessonData(letter: 'ق', soundCue: 'قَ', examples: [
    WordExample('قَمَر', '🌙', imageAsset: '$_w/qamar.png'),
    WordExample('قَلَم', '✏️', imageAsset: '$_w/qalam.png'),
    WordExample('قِطَّة', '🐱', imageAsset: '$_w/qitta.png')
  ]),
  LetterLessonData(letter: 'ك', soundCue: 'كَ', examples: [
    WordExample('كِتَاب', '📘', imageAsset: '$_w/kitab.png'),
    WordExample('كُرَة', '⚽', imageAsset: '$_w/kura.png'),
    WordExample('كُرْسِي', '🪑', imageAsset: '$_w/kursiy.png')
  ]),
  LetterLessonData(letter: 'ل', soundCue: 'لَ', examples: [
    WordExample('لَيْمُون', '🍋', imageAsset: '$_w/laymun.png'),
    WordExample('لُعْبَة', '🧸', imageAsset: '$_w/luba.png'),
    WordExample('لِسَان', '👅', imageAsset: '$_w/lisan.png')
  ]),
  LetterLessonData(letter: 'م', soundCue: 'مَ', examples: [
    WordExample('مَوْز', '🍌', imageAsset: '$_w/mawz.png'),
    WordExample('مِفْتَاح', '🔑', imageAsset: '$_w/miftah.png'),
    WordExample('مَدْرَسَة', '🏫', imageAsset: '$_w/madrasa.png')
  ]),
  LetterLessonData(letter: 'ن', soundCue: 'نَ', examples: [
    WordExample('نَجْم', '⭐', imageAsset: '$_w/najm.png'),
    WordExample('نَحْلَة', '🐝', imageAsset: '$_w/nahla.png'),
    WordExample('نَمِر', '🐯', imageAsset: '$_w/namir.png')
  ]),
  LetterLessonData(letter: 'هـ', soundCue: 'هَ', examples: [
    WordExample('هُدْهُد', '🐦', imageAsset: '$_w/hudhud.png'),
    WordExample('هِلال', '🌙', imageAsset: '$_w/hilal.png'),
    WordExample('هَدِيَّة', '🎁', imageAsset: '$_w/hadiyya.png')
  ]),
  LetterLessonData(letter: 'و', soundCue: 'وَ', examples: [
    WordExample('وَرْدَة', '🌹', imageAsset: '$_w/warda.png'),
    WordExample('وَجْه', '🙂', imageAsset: '$_w/wagh.png'),
    WordExample('وَرَق', '📄', imageAsset: '$_w/waraq.png')
  ]),
  LetterLessonData(letter: 'ي', soundCue: 'يَ', examples: [
    WordExample('يَد', '✋', imageAsset: '$_w/yad.png'),
    WordExample('يَمَامَة', '🕊️', imageAsset: '$_w/yamama.png'),
    WordExample('يَقْطِين', '🎃', imageAsset: '$_w/yaqtin.png')
  ]),
];

/// أشكال صوت الحرف بالحركات القصيرة. KG1 يستخدم الفتحة أولًا،
/// وKG2 يتدرّب على الفتحة والضمة والكسرة.
List<String> shortVowelForms(String letter) {
  if (letter == 'أ') return const ['أَ', 'أُ', 'إِ'];
  final base = letter == 'هـ' ? 'ه' : letter;
  return ['$baseَ', '$baseُ', '$baseِ'];
}

const shortVowelNames = ['فَتْحَة', 'ضَمَّة', 'كَسْرَة'];
