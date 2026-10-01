$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter غير موجود في PATH. ثبّت Flutter SDK أولًا."
}
if (-not (Test-Path "$root\android\gradlew.bat")) {
  & "$root\tool\bootstrap_android.ps1"
}
flutter run
