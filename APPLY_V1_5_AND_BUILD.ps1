$ErrorActionPreference = 'Stop'

Write-Host "===== PUB GET ====="
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "PUB GET FAILED" }

Write-Host "`n===== ANALYZE ====="
flutter analyze
if ($LASTEXITCODE -ne 0) { throw "ANALYZE FAILED" }

Write-Host "`n===== TEST ====="
flutter test
if ($LASTEXITCODE -ne 0) { throw "TEST FAILED" }

Write-Host "`n===== BUILD V1.5 APK ====="
flutter build apk --release
if ($LASTEXITCODE -ne 0) { throw "BUILD FAILED" }

Write-Host "`n===== V1.5 APK READY ====="
Get-Item ".\build\app\outputs\flutter-apk\app-release.apk" | Select-Object FullName,Length
