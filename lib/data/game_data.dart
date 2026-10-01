class AnimalItem {
  final String name;
  final String spokenName;
  final String emoji;
  final String? imageAsset;
  const AnimalItem(this.name, this.spokenName, this.emoji, {this.imageAsset});
}

const _w = 'assets/images/words';

const animals = <AnimalItem>[
  AnimalItem('ثعلب', 'ثَعْلَب', '🦊', imageAsset: '$_w/thaalab.png'),
  AnimalItem('أسد', 'أَسَد', '🦁', imageAsset: '$_w/asad.png'),
  AnimalItem('قطة', 'قِطَّة', '🐱', imageAsset: '$_w/qitta.png'),
  AnimalItem('كلب', 'كَلْب', '🐶', imageAsset: 'assets/images/animals/kalb.png'),
  AnimalItem('أرنب', 'أَرْنَب', '🐇', imageAsset: '$_w/arnab.png'),
  AnimalItem('فيل', 'فِيل', '🐘', imageAsset: '$_w/fil.png'),
  AnimalItem('حصان', 'حِصَان', '🐴', imageAsset: '$_w/hisan.png'),
  AnimalItem('بطة', 'بَطَّة', '🦆', imageAsset: '$_w/batta.png'),
  AnimalItem('سمكة', 'سَمَكَة', '🐟', imageAsset: '$_w/samaka.png'),
  AnimalItem('جمل', 'جَمَل', '🐪', imageAsset: '$_w/gamal.png'),
  AnimalItem('زرافة', 'زَرَافَة', '🦒', imageAsset: '$_w/zarafa.png'),
  AnimalItem('دب', 'دُبّ', '🐻', imageAsset: '$_w/dubb.png'),
  AnimalItem('ضفدع', 'ضِفْدَع', '🐸', imageAsset: '$_w/difda.png'),
];

class ShapeItem {
  final String name;
  final String spokenName;
  final String symbol;
  const ShapeItem(this.name, this.spokenName, this.symbol);
}

const shapes = <ShapeItem>[
  ShapeItem('دائرة', 'دَائِرَة', '●'),
  ShapeItem('مربع', 'مُرَبَّع', '■'),
  ShapeItem('مثلث', 'مُثَلَّث', '▲'),
  ShapeItem('مستطيل', 'مُسْتَطِيل', '▭'),
  ShapeItem('نجمة', 'نَجْمَة', '★'),
  ShapeItem('قلب', 'قَلْب', '♥'),
];

String arabicNumber(int value) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  return value
      .toString()
      .split('')
      .map((c) => eastern[western.indexOf(c)])
      .join();
}

String spokenArabicNumber(int value) {
  const names = <int, String>{
    0: 'صِفْر',
    1: 'وَاحِد',
    2: 'اِثْنَان',
    3: 'ثَلَاثَة',
    4: 'أَرْبَعَة',
    5: 'خَمْسَة',
    6: 'سِتَّة',
    7: 'سَبْعَة',
    8: 'ثَمَانِيَة',
    9: 'تِسْعَة',
    10: 'عَشَرَة',
    11: 'أَحَدَ عَشَر',
    12: 'اِثْنَا عَشَر',
    13: 'ثَلَاثَةَ عَشَر',
    14: 'أَرْبَعَةَ عَشَر',
    15: 'خَمْسَةَ عَشَر',
    16: 'سِتَّةَ عَشَر',
    17: 'سَبْعَةَ عَشَر',
    18: 'ثَمَانِيَةَ عَشَر',
    19: 'تِسْعَةَ عَشَر',
    20: 'عِشْرُون',
  };
  return names[value] ?? arabicNumber(value);
}
