/// Resolves only assets present in the APK. Missing or partial packs use TTS.
class VoiceAssetCatalog {
  VoiceAssetCatalog(this.assets, this.manifest);
  final Set<String> assets;
  final Map<String, dynamic> manifest;
  static String key(String value) {
    final trimmed = value.trim();
    // Never collapse distinct pedagogical vowel sounds to the same recording.
    final shortVowel = RegExp(r'^([ء-ي])([َُِ])$').firstMatch(trimmed);
    if (shortVowel != null) {
      final suffix = switch (shortVowel.group(2)) {
        'َ' => 'fathah',
        'ُ' => 'dammah',
        _ => 'kasrah',
      };
      return '${shortVowel.group(1)}_$suffix';
    }
    return trimmed
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'[!،.؟]'), '')
        .replaceAll(' ', '_');
  }

  String? resolve(String text, String category, String gender,
      {bool gendered = false}) {
    final group = manifest[gender];
    final mapped = group is Map ? group[text] : null;
    final filename = key(text);
    final paths = <String>[
      if (mapped is String)
        mapped.startsWith('assets/') ? mapped : 'assets/$mapped',
      if (gendered)
        for (final extension in ['mp3', 'wav'])
          'assets/audio/$category/$gender/$filename.$extension',
      if (!gendered)
        for (final folder in {
          category,
          'letters',
          'words',
          'animals',
          'shapes',
          'numbers'
        })
          for (final extension in ['mp3', 'wav'])
            'assets/audio/$folder/$filename.$extension',
    ];
    final otherGender = gender == 'boy' ? 'girl' : 'boy';
    for (final path in paths) {
      if (path.contains('/$otherGender/')) continue;
      if (assets.contains(path)) return path.substring('assets/'.length);
    }
    return null;
  }
}
