# Illustrated asset regression fixes

Project: `C:/Users/Compumarts/Downloads/notk`.

## Tests changed

- `test/matching_widget_test.dart`: target identity comes from a keyed semantic widget, not its first Text descendant. Explicitly requires exactly one matching model id. Retains KG1/KG2 animal, letter, and number cases. Verifies wrong choice returns to its starting position, target remains unfilled, choices unlock, correct choice locks, repeated tap/drop awards only one coin, and the next round appears without widget exceptions.
- `test/speech_interaction_test.dart`: selects `animal-option-${animal.name}` rather than emoji; keeps object playback pending to verify rapid taps are ignored; verifies that animal name is spoken first, praise follows, one coin is awarded, and only question 2 appears. Uses a phone-sized viewport so all answer cards are built.
- `test/auto_speech_test.dart`: animal answer uses the same stable key.
- New `test/image_asset_integrity_test.dart`: all 84 lesson WordExample references plus 13 AnimalItem references are checked against actual project files and Flutter AssetManifest. Invalid or missing paths are collected with their model owners. Also verifies MatchChoice image propagation for all 13 animals.

## Production changes

- `lib/screens/games_screens.dart`: animal answer InkWell keys use existing unique animal names; matching target Semantics exposes a stable model id key and spoken label. The illustrated assets remain in place. A FittedBox scales down oversized matching targets, preventing the two-digit number 10 from wrapping and overflowing in KG2.
- `lib/screens/letters_screen.dart`: braces added around an existing guard after formatter exposed a lint; other changes are formatting.
- Formatting only: `lib/data/game_data.dart`, `lib/screens/achievements_screen.dart`, `lib/screens/home_screen.dart`, `lib/widgets/ui.dart`.

`pubspec.yaml` already declared `assets/images/`. Build inspection showed that its nested words/ and animals/ files were omitted, so explicit `assets/images/words/` and `assets/images/animals/` entries were added. The root entry is preserved. No images were removed or replaced. No dependencies were added or upgraded; Flutter and Android SDK installations were unchanged.

## Verification

- `dart format lib test`: passed.
- `flutter analyze`: No issues found.
- `flutter test`: 61/61 passed.
- Image references checked: 97.
- Unique image files referenced: 85.
- Missing images: 0.
- No test UI selection depends on animal emoji. The content test still checks that existing fallback metadata is nonempty; it does not use emoji to locate widgets.

- `flutter build apk --release`: succeeded after all 61 tests passed.
- APK: `build/app/outputs/flutter-apk/app-release.apk`.
- APK size: 73,118,170 bytes (69.73 MiB).
- ZIP inspection verified every one of the 85 unique referenced image files is bundled; no missing entries.
- SHA256: `26761ac088b55f5def8914abab4c0d192fe3e50c397e212b5bd37c049807e2cc`.

The existing Java TCP fallback was scoped to the build process. No SDK components were downloaded. No device listening/manual interaction verification was performed.
