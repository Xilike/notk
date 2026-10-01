# تأسيس النطق V1.6 — implementation and build report

Version: 1.6.0+16. Existing project and Android scaffold preserved. Application ID remains com.tasis.tasis_alnotq.

## 1. Modified files (14 manually edited files)

- [lib/data/game_data.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/data/game_data.dart)
- [lib/screens/games_screens.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/screens/games_screens.dart)
- [lib/screens/letters_screen.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/screens/letters_screen.dart)
- [lib/screens/practice_screens.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/screens/practice_screens.dart)
- [lib/screens/onboarding_screen.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/screens/onboarding_screen.dart)
- [lib/screens/parent_screens.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/screens/parent_screens.dart)
- [lib/services/app_state.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/services/app_state.dart)
- [lib/services/speech_service.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/services/speech_service.dart)
- [lib/services/recording_service.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/services/recording_service.dart)
- [test/content_test.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/test/content_test.dart)
- [pubspec.yaml](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/pubspec.yaml)
- [VOICE_PACK.md](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/VOICE_PACK.md)
- [tool/generate_voice_pack_azure.ps1](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/tool/generate_voice_pack_azure.ps1)
- [BUILD_APK.ps1](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/BUILD_APK.ps1)

Flutter additionally updates android/local.properties versionName/versionCode during the build and regenerates normal build metadata. Gradle configuration, manifests, application ID, and dependency constraints were not changed. content_test.dart was formatted without changing its existing test intent.

## 2. Created files (22)

- [lib/models/child_profile.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/models/child_profile.dart)
- [lib/services/child_profile_service.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/services/child_profile_service.dart)
- [lib/services/child_speech_text.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/services/child_speech_text.dart)
- [lib/services/reward_service.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/services/reward_service.dart)
- [lib/services/voice_asset_catalog.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/services/voice_asset_catalog.dart)
- [lib/data/matching_round.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/lib/data/matching_round.dart)
- [test/profile_rewards_matching_test.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/test/profile_rewards_matching_test.dart)
- [test/matching_widget_test.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/test/matching_widget_test.dart)
- [test/speech_interaction_test.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/test/speech_interaction_test.dart)
- [test/voice_asset_catalog_test.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/test/voice_asset_catalog_test.dart)
- [tool/export_voice_catalog.dart](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/tool/export_voice_catalog.dart)
- [assets/audio/animals/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/animals/README.txt)
- [assets/audio/boy/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/boy/README.txt)
- [assets/audio/feedback/boy/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/feedback/boy/README.txt)
- [assets/audio/feedback/girl/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/feedback/girl/README.txt)
- [assets/audio/girl/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/girl/README.txt)
- [assets/audio/instructions/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/instructions/README.txt)
- [assets/audio/letters/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/letters/README.txt)
- [assets/audio/numbers/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/numbers/README.txt)
- [assets/audio/shapes/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/shapes/README.txt)
- [assets/audio/words/README.txt](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/assets/audio/words/README.txt)
- [V1_6_REPORT.md](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/V1_6_REPORT.md)

## 3. Implemented features

- Immutable ChildProfile and one persisted JSON profile; migration from existing gender/name/level preferences preserves progress. AppState getters expose that same profile to all screens. Parent edits update the same model.
- ChildSpeechText centralizes male/female feedback and instructions. Random encouraging praise uses the selected child's grammar. Changing gender stops pending speech.
- Centralized SpeechService API for letters, words, animals, numbers, shapes, instructions, feedback, initialization, and stop. Existing screens remain routed through this service; FlutterTts exists only here.
- Bundled MP3/WAV resolution with the existing voice manifest and declared category directories. Missing files or startup playback errors use Arabic TTS. Male/female feedback paths are isolated; common unvowelled praise keys cannot select the other gender. Short-vowel files use distinct fathah/dammah/kasrah keys.
- Cached TTS setup selects an available installed offline Arabic voice, preferring ar-EG and higher quality. Known network-only or uninstalled voices are excluded. Natural pitch 1.0, speech rate 0.42. New speech cancels the previous request and pending feedback pieces. Asset startup is serialized to prevent stale playback resuming after a new request.
- Meaningful educational objects speak on touch; blank backgrounds and navigation do not trigger speech. Animal answers say their own name before evaluation and feedback. Lion and fox have explicit أَسَد / ثَعْلَب content.
- Animal Shadow, Letter Match, and Number Match use shared MatchingRound logic. KG1 has 3 choices, KG2 has 4. There are 13 animals, replaceable with imageAsset paths. Similar-letter distractors are preferred in KG2. Number ranges are 1–5 / 1–10, with data and generator support for 1–20. Wrong drops return; correct targets display success and lock before advancing.
- Letter/number targets use outlines. Matching layout scrolls when space is limited. Candidate/target sizes exceed 48dp.
- Ordering games retain current onReorderItem API and speak once on tap/drag start rather than drag movement. Wrong-answer feedback also locks the check action.
- RewardService is a session ledger over existing AppState persistence, with no second reward database. A round rewards once, sessions award bonuses once, and each tenth correct answer keeps the existing box/+5-star policy. Existing achievements, daily goal, streak, parent dashboard/gate, letters, words, sounds, recordings, and games remain.
- Answer locks activate before awaiting audio. Onboarding, parent save, lesson completion, and recording controls guard repeated requests. Speech is stopped and suppressed around recording; child's recording playback stops educational speech.
- Optional Azure voice generation reads actual current app content through the new Dart catalog exporter (240 texts per gender when verified). No Azure request or voice generation was run.
- BUILD_APK.ps1 stops on command failure and scopes the Windows JDK socket workaround to its child processes. The installed JDK's bundled PipeImpl source confirmed TCP fallback when an AF_UNIX listener cannot bind. The absent .dart_tool socket directory selects that fallback. This fixes the observed 'Unable to establish loopback connection' without replacing Java, Flutter, or Android configuration.

## 4–6. Verification results

- Initial baseline: flutter analyze clean; 4 existing tests passed.
- dart format lib test: completed.
- flutter pub get: succeeded, dependency versions retained.
- Final flutter analyze: No issues found!
- Final flutter test: 31 tests passed.
- Final flutter build apk --release: succeeded on the final source with the scoped JAVA_TOOL_OPTIONS workaround.
- BUILD_APK.ps1 was exercised end-to-end successfully. For repeat builds on this Windows host, run this script to apply the required local socket workaround.
- Tests cover legacy migration, profile persistence, grammar, random feedback, reward boxes, concurrent duplicate reward requests, session bonuses, idempotent lessons, 900 generated matching configurations, actual drag/drop behavior for all 6 game/level combinations, missing-pack TTS, cancellation of old feedback, tap-to-speak, blank taps, answer locking, asset priorities, gender-separated feedback, distinct vowels, and offline voice selection.
- Optional exporter and PowerShell voice-generator syntax checked; synthesis not run.

## 7–8. APK

Path: [C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/build/app/outputs/flutter-apk/app-release.apk](C:/Users/Compumarts/Downloads/tasis_alnotq_build/tasis_alnotq_v1_1/build/app/outputs/flutter-apk/app-release.apk)

Size: 55,194,034 bytes (55.19 MB; 52.64 MiB).

SHA-256: 48b9d58ecc522ede2771ab88e5b12536ad1b503ac9f75830f5f603d3c382571a

## 9. Remaining limitations

- Voice manifest is empty and no MP3/WAV neural pack is bundled yet. Speech uses the device's installed offline Arabic voice. Actual pronunciation quality depends on that engine. A device with no offline Arabic voice needs voice data or a bundled pack; the app does not intentionally select a known network-only voice.
- Animal artwork remains temporary emoji; the shared model/rendering supports replacement image assets.
- ADB found no attached device, so physical BlueStacks listening, microphone permission, recording quality, and on-device gameplay were not manually verified. Automated tests mock native speech; drag/drop tests use Flutter's widget runtime.
- Existing Android release configuration signs with the debug key; it was preserved. This APK is suitable for current local testing, not a newly configured store-signing workflow.
- The build emits the existing KGP migration warning for flutter_tts and record_android; it does not prevent this build. Dependencies were deliberately not upgraded.

## 10–11. Resource and dependency status

No new dependency was added. No dependency constraints were upgraded. No Flutter/Java installation or upgrade, Android Studio installation, emulator installation, system-image download, Android SDK platform/build-tools/NDK/CMake download, or Android scaffold regeneration was performed.

Android SDK component directory inventory before/after the builds was identical: platforms android-35 and android-36, build-tools 36.0.0, existing NDK 28.2.13676358, existing CMake 3.22.1. Normal compilation used these existing components.
