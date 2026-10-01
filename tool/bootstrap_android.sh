#!/usr/bin/env bash
set -euo pipefail
command -v flutter >/dev/null || { echo "Flutter is not installed/in PATH"; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
BACKUP="$(mktemp -d)"
cp -R lib "$BACKUP/lib"
cp -R assets "$BACKUP/assets"
cp -R test "$BACKUP/test"
cp pubspec.yaml analysis_options.yaml "$BACKUP/"
flutter create --platforms=android --org com.tasis --project-name tasis_alnotq .
rm -rf lib assets test
cp -R "$BACKUP/lib" ./lib
cp -R "$BACKUP/assets" ./assets
cp -R "$BACKUP/test" ./test
cp "$BACKUP/pubspec.yaml" ./pubspec.yaml
cp "$BACKUP/analysis_options.yaml" ./analysis_options.yaml
cp tool/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
if [ -f android/app/build.gradle.kts ]; then
  sed -i 's/minSdk = flutter.minSdkVersion/minSdk = 23/' android/app/build.gradle.kts
fi
if [ -f android/app/build.gradle ]; then
  sed -i 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 23/' android/app/build.gradle
fi
for d in android/app/src/main/res/mipmap-*; do
  [ -d "$d" ] && cp assets/images/app_icon.png "$d/ic_launcher.png"
done
flutter pub get
flutter analyze
flutter test
echo "Ready. Build with: flutter build apk --release"
