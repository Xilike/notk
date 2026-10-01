$ErrorActionPreference = "Stop"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter غير موجود في PATH. ثبّت Flutter ثم شغّل الملف مرة أخرى."
}

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$backup = Join-Path $env:TEMP ("tasis_backup_" + $PID)
New-Item -ItemType Directory -Force -Path $backup | Out-Null
Copy-Item "$root\lib" "$backup\lib" -Recurse -Force
Copy-Item "$root\assets" "$backup\assets" -Recurse -Force
Copy-Item "$root\test" "$backup\test" -Recurse -Force
Copy-Item "$root\pubspec.yaml" "$backup\pubspec.yaml" -Force
Copy-Item "$root\analysis_options.yaml" "$backup\analysis_options.yaml" -Force

flutter create --platforms=android --org com.tasis --project-name tasis_alnotq .

Remove-Item "$root\lib" -Recurse -Force
Remove-Item "$root\assets" -Recurse -Force
Remove-Item "$root\test" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$backup\lib" "$root\lib" -Recurse -Force
Copy-Item "$backup\assets" "$root\assets" -Recurse -Force
Copy-Item "$backup\test" "$root\test" -Recurse -Force
Copy-Item "$backup\pubspec.yaml" "$root\pubspec.yaml" -Force
Copy-Item "$backup\analysis_options.yaml" "$root\analysis_options.yaml" -Force
Copy-Item "$root\tool\AndroidManifest.xml" "$root\android\app\src\main\AndroidManifest.xml" -Force

$gradleKts = "$root\android\app\build.gradle.kts"
if (Test-Path $gradleKts) {
  (Get-Content $gradleKts -Raw).Replace("minSdk = flutter.minSdkVersion", "minSdk = 23") | Set-Content $gradleKts -Encoding UTF8
}
$gradleGroovy = "$root\android\app\build.gradle"
if (Test-Path $gradleGroovy) {
  (Get-Content $gradleGroovy -Raw).Replace("minSdkVersion flutter.minSdkVersion", "minSdkVersion 23") | Set-Content $gradleGroovy -Encoding UTF8
}
Get-ChildItem "$root\android\app\src\main\res" -Directory -Filter "mipmap-*" | ForEach-Object {
  Copy-Item "$root\assets\images\app_icon.png" (Join-Path $_.FullName "ic_launcher.png") -Force
}

flutter pub get
flutter analyze
flutter test
Write-Host "`nجاهز للبناء. لإنشاء APK:" -ForegroundColor Green
Write-Host "flutter build apk --release" -ForegroundColor Yellow

