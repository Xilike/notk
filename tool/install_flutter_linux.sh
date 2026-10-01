#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOLING="$ROOT/.tooling"
mkdir -p "$TOOLING"
if [ ! -x "$TOOLING/flutter/bin/flutter" ]; then
  echo "Resolving current Flutter stable..."
  python3 - "$TOOLING/release.txt" <<'PY'
import json, urllib.request, sys
url='https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json'
with urllib.request.urlopen(url) as r: data=json.load(r)
h=data['current_release']['stable']
rel=next(x for x in data['releases'] if x['hash']==h)
with open(sys.argv[1],'w') as f:
    f.write(data['base_url']+'/'+rel['archive']+'\n'+rel['sha256']+'\n'+rel['version']+'\n')
PY
  URL="$(sed -n '1p' "$TOOLING/release.txt")"
  SHA="$(sed -n '2p' "$TOOLING/release.txt")"
  VER="$(sed -n '3p' "$TOOLING/release.txt")"
  echo "Downloading Flutter $VER..."
  curl -fL "$URL" -o "$TOOLING/flutter.tar.xz"
  echo "$SHA  $TOOLING/flutter.tar.xz" | sha256sum -c -
  tar -xf "$TOOLING/flutter.tar.xz" -C "$TOOLING"
  rm -f "$TOOLING/flutter.tar.xz" "$TOOLING/release.txt"
fi
export PATH="$TOOLING/flutter/bin:$PATH"
flutter --version
cd "$ROOT"
[ -d android ] || ./tool/bootstrap_android.sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
echo "APK: $ROOT/build/app/outputs/flutter-apk/app-release.apk"
