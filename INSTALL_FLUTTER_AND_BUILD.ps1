$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$tooling = Join-Path $root ".tooling"
$flutterDir = Join-Path $tooling "flutter"
New-Item -ItemType Directory -Force -Path $tooling | Out-Null

function Get-Flutter {
  if (Test-Path (Join-Path $flutterDir "bin\flutter.bat")) {
    Write-Host "Flutter المحلي موجود بالفعل." -ForegroundColor Cyan
    return
  }
  Write-Host "جاري معرفة أحدث Flutter Stable لويندوز..." -ForegroundColor Cyan
  $manifestUrl = "https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
  $manifest = Invoke-RestMethod -Uri $manifestUrl
  $stableHash = $manifest.current_release.stable
  $release = $manifest.releases | Where-Object { $_.hash -eq $stableHash } | Select-Object -First 1
  if (-not $release) { throw "تعذر تحديد إصدار Flutter Stable." }

  $archiveUrl = "$($manifest.base_url)/$($release.archive)"
  $archive = Join-Path $tooling "flutter.zip"
  Write-Host "Flutter $($release.version) / Dart $($release.dart_sdk_version)" -ForegroundColor Green
  Write-Host "جاري تنزيل Flutter SDK..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri $archiveUrl -OutFile $archive

  $actual = (Get-FileHash -Path $archive -Algorithm SHA256).Hash.ToLowerInvariant()
  $expected = "$($release.sha256)".ToLowerInvariant()
  if ($actual -ne $expected) { Remove-Item $archive -Force; throw "SHA256 غير مطابق. تم إلغاء التثبيت." }

  Write-Host "جاري فك Flutter SDK..." -ForegroundColor Cyan
  Expand-Archive -Path $archive -DestinationPath $tooling -Force
  Remove-Item $archive -Force
}

Get-Flutter
$env:Path = "$(Join-Path $flutterDir 'bin');$env:Path"
& flutter --version

Set-Location $root
if (-not (Test-Path "$root\android\gradlew.bat")) {
  & "$root\tool\bootstrap_android.ps1"
}

Write-Host "`nفحص Android toolchain..." -ForegroundColor Cyan
$doctor = (& flutter doctor 2>&1 | Out-String)
Write-Host $doctor
if ($doctor -match "Android toolchain.*✗" -or $doctor -match "Unable to locate Android SDK") {
  throw "Flutter اتثبت بنجاح، لكن Android SDK غير موجود. ثبّت Android Studio/SDK ثم شغّل الملف مرة أخرى."
}

& flutter pub get
& flutter analyze
& flutter test
& flutter build apk --release

$apk = Join-Path $root "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apk)) { throw "انتهى البناء بدون العثور على APK المتوقع." }
Write-Host "`n✅ APK جاهز:" -ForegroundColor Green
Write-Host $apk -ForegroundColor Yellow
