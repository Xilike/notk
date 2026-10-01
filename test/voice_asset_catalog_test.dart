import 'package:flutter_test/flutter_test.dart';
import 'package:tasis_alnotq/services/voice_asset_catalog.dart';

void main() {
  test(
      'short vowels require distinct recordings and incomplete packs fall back',
      () {
    final catalog =
        VoiceAssetCatalog({'assets/audio/letters/ب_fathah.mp3'}, {});
    expect(
        catalog.resolve('بَ', 'letters', 'boy'), 'audio/letters/ب_fathah.mp3');
    expect(catalog.resolve('بُ', 'letters', 'boy'), isNull);
    expect(catalog.resolve('بِ', 'letters', 'boy'), isNull);
    expect(VoiceAssetCatalog.key('إِ'), 'إ_kasrah');
  });
  test('partial packs prefer MP3/WAV and fall back for missing entries', () {
    final catalog = VoiceAssetCatalog({
      'assets/audio/animals/أسد.mp3',
      'assets/audio/letters/ب_fathah.wav',
    }, {});
    expect(catalog.resolve('أَسَد', 'animals', 'boy'), 'audio/animals/أسد.mp3');
    expect(
        catalog.resolve('بَ', 'letters', 'girl'), 'audio/letters/ب_fathah.wav');
    expect(catalog.resolve('ثَعْلَب', 'animals', 'boy'), isNull);
  });
  test(
      'feedback diacritics cannot select the other gender or a shared recording',
      () {
    final catalog = VoiceAssetCatalog({
      'assets/audio/feedback/boy/أحسنت.mp3',
      'assets/audio/feedback/girl/أحسنت.mp3',
      'assets/audio/feedback/أحسنت.mp3',
    }, {});
    expect(catalog.resolve('أَحْسَنْتَ!', 'feedback', 'boy', gendered: true),
        'audio/feedback/boy/أحسنت.mp3');
    expect(catalog.resolve('أَحْسَنْتِ!', 'feedback', 'girl', gendered: true),
        'audio/feedback/girl/أحسنت.mp3');
    final incomplete =
        VoiceAssetCatalog({'assets/audio/feedback/boy/أحسنت.mp3'}, {});
    expect(
        incomplete.resolve('أَحْسَنْتِ!', 'feedback', 'girl', gendered: true),
        isNull);
  });
  test('legacy manifests remain usable and a missing mapped file falls back',
      () {
    final catalog = VoiceAssetCatalog({
      'assets/audio/boy/old.mp3'
    }, {
      'boy': {'أَسَد': 'audio/boy/old.mp3', 'ثَعْلَب': 'audio/boy/missing.mp3'},
      'girl': {'أَحْسَنْتِ!': 'audio/boy/old.mp3'},
    });
    expect(catalog.resolve('أَسَد', 'animals', 'boy'), 'audio/boy/old.mp3');
    expect(catalog.resolve('ثَعْلَب', 'animals', 'boy'), isNull);
    expect(catalog.resolve('أَحْسَنْتِ!', 'feedback', 'girl', gendered: true),
        isNull);
  });
}
