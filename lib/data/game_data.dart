class AnimalItem {
  final String name;
  final String spokenName;
  final String emoji;
  final String? imageAsset;
  const AnimalItem(this.name, this.spokenName, this.emoji, {this.imageAsset});
}

const animals = <AnimalItem>[
  AnimalItem('ثعلب', 'ثَعْلَب', '🦊'),
  AnimalItem('أسد', 'أَسَد', '🦁'),
  AnimalItem('قطة', 'قِطَّة', '🐱'),
  AnimalItem('كلب', 'كَلْب', '🐶'),
  AnimalItem('أرنب', 'أَرْنَب', '🐇'),
  AnimalItem('فيل', 'فِيل', '🐘'),
  AnimalItem('حصان', 'حِصَان', '🐴'),
  AnimalItem('بطة', 'بَطَّة', '🦆'),
  AnimalItem('سمكة', 'سَمَكَة', '🐟'),
  AnimalItem('جمل', 'جَمَل', '🐪'),
  AnimalItem('زرافة', 'زَرَافَة', '🦒'),
  AnimalItem('دب', 'دُبّ', '🐻'),
  AnimalItem('ضفدع', 'ضِفْدَع', '🐸'),
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
