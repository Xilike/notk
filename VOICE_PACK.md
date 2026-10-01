# Voice Pack — V1.6

Normal app use requires no cloud service. The APK checks bundled files first and uses the device Arabic TTS engine for missing or unplayable files. No recordings ship in this source project yet; the manifest is empty.

Drop MP3/WAV files into `assets/audio/letters`, `words`, `animals`, `numbers`, or `shapes`. File keys remove Arabic diacritics and punctuation and replace spaces with underscores: `أَسَد` → `animals/أسد.mp3`, `بَ` → `letters/ب_fathah.wav`, `وَاحِد` → `numbers/واحد.mp3`.

Short-vowel recordings have distinct keys: `بَ` → `ب_fathah`, `بُ` → `ب_dammah`, `بِ` → `ب_kasrah`. An absent vowel-specific file falls back to TTS instead of playing a different vowel. Exact text mappings in the manifest also preserve these distinctions.

Gender-dependent praise must be under `assets/audio/feedback/boy` or `feedback/girl`. For example, `أَحْسَنْتَ!` and `أَحْسَنْتِ!` both normalize to `أحسنت.mp3`, so separate folders are essential. Shared feedback files are deliberately ignored for gendered phrases. Opposite-gender paths are rejected.

Alternatively, `voice_manifest.json` maps exact spoken text to an asset-relative path inside the `boy` and `girl` groups. The existing manifest convention, including `audio/boy/0001.mp3`, remains supported. All supplied directories are declared in pubspec. Rebuild the APK after adding files. Corrupt/missing recordings fall back to TTS.

`SpeechService.initialize()` is cached. It selects an available Arabic voice, excluding known network-only or uninstalled voices and preferring Egyptian Arabic and high-quality voices, and uses rate 0.42 and pitch 1.0. Arabic grammar comes from `ChildSpeechText`, independent of the engine voice. A new request cancels previous playback and the remaining pieces of a previous feedback sequence. Recording and playback of the child's voice coordinate with speech.

Optional pre-generation: the existing Azure script reads current application content through `tool/export_voice_catalog.dart`, then synthesizes recordings into `assets/audio/boy` and `girl` and writes the manifest. Set AZURE_SPEECH_KEY and AZURE_SPEECH_REGION and run `tool/generate_voice_pack_azure.ps1` only when you want to generate a pack. This optional cloud generation was not run for V1.6; it is unnecessary during child use.
