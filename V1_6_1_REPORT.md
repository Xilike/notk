# V1.6.1 — Global automatic speech

Version: `1.6.1+17`.

## Behavior

Educational pages speak their current target on entry and on returning from another route. Explicit question, example, and carousel changes speak once. Rebuilds, resize, animations, and reward changes do not restart speech.

Letter lessons speak the letter, pause 220 ms, then speak the example. Games speak each question; matching speaks the instruction and target on round one, then only subsequent targets. Manual speakers and object touches remain available and cancel older automatic sequences. Navigation cancels speech from the previous route.

Parent Dashboard now includes **النطق التلقائي**, ON by default, persisted centrally with SharedPreferences. OFF suppresses automatic speech and cancels an active automatic sequence while preserving manual speech. Existing sound/recording controls and gender-aware grammar remain in use.

## Implementation

- `lib/services/speech_service.dart`: centralized automatic entry, lesson, question, tab, cancellation, and sequence pauses.
- `lib/services/auto_speech_gate.dart`: visibility/content identity guards.
- `lib/widgets/auto_speak_page.dart`: route lifecycle and optional settled TabController integration.
- `lib/app.dart`: shared navigation observer.
- `lib/services/app_state.dart`, `lib/screens/parent_screens.dart`: persisted parent setting.
- `lib/services/child_speech_text.dart`: centralized boy/girl entry instructions.
- `lib/screens/letters_screen.dart`, `practice_screens.dart`, `games_screens.dart`: entry and explicit content-change triggers.

The existing product uses Previous/Next pages, not TabBar. TabController support is verified using a widget harness with click and swipe changes; inactive tab builds do not speak.

## Validation

- `dart format lib test`: passed.
- `flutter analyze`: No issues found.
- `flutter test`: all 60 tests passed (31 existing plus 29 automatic-speech tests).
- Coverage includes entry/return, new questions/examples, rebuild/resize suppression, tabs, persisted ON/OFF, manual interruption, gender, first/subsequent matching rounds, and route replacement cancellation.
- The existing rapid-tap regression test now holds object playback pending explicitly, ensuring it tests the answer lock deterministically.

- `flutter build apk --release`: succeeded through `BUILD_APK.ps1`.
- APK: `build/app/outputs/flutter-apk/app-release.apk` — 55,226,862 bytes.
- `aapt dump badging` verified package `com.tasis.tasis_alnotq`, versionName `1.6.1`, versionCode `17`.
- SHA256: `D83849E2A78D9AC16DE9FBB06608AA124DD3374CA46D89801D714E7151F6A03B`.
- Build uses the existing scoped JDK TCP fallback in `BUILD_APK.ps1`. Flutter emitted a future Kotlin plugin migration warning for existing `flutter_tts` and `record_android`; it did not prevent the release build.

## Device verification

Automated speech tests use mocked playback. Real-device/BlueStacks listening has not been performed. Existing offline asset-first audio and device Arabic TTS fallback are preserved; the project still has no prerecorded voice pack. No Flutter/Android scaffolding or dependency upgrades were introduced.
