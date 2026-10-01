$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter must already be available in PATH.'
}
if (-not (Test-Path -LiteralPath "$root\android\gradlew.bat")) {
  throw 'Existing Android scaffold is missing. Build stopped without recreating it.'
}

function Invoke-FlutterChecked([string[]]$FlutterArguments) {
  & flutter @FlutterArguments
  if ($LASTEXITCODE -ne 0) {
    throw "Flutter command failed: $($FlutterArguments -join ' ') (exit $LASTEXITCODE)"
  }
}

# This JDK's Windows AF_UNIX connection fails. Its bundled PipeImpl falls back
# to TCP if the Unix-domain listener cannot bind. Keep this path absent.
# The setting applies only to this script's processes; no global Java changes.
$javaSocketFallback = Join-Path $root '.dart_tool\unavailable-unix-socket-directory'
if (Test-Path -LiteralPath $javaSocketFallback) {
  throw 'The TCP fallback path must remain absent.'
}
$previousJavaOptions = $env:JAVA_TOOL_OPTIONS
try {
  $env:JAVA_TOOL_OPTIONS = "$previousJavaOptions -Djdk.net.unixdomain.tmpdir=`"$javaSocketFallback`""
  Invoke-FlutterChecked -FlutterArguments @('pub', 'get')
  Invoke-FlutterChecked -FlutterArguments @('analyze')
  Invoke-FlutterChecked -FlutterArguments @('test')
  Invoke-FlutterChecked -FlutterArguments @('build', 'apk', '--release')
  $apk = Join-Path $root 'build\app\outputs\flutter-apk\app-release.apk'
  if (-not (Test-Path -LiteralPath $apk)) { throw 'Release APK is missing.' }
  Write-Host "APK: $apk"
  Write-Host "Bytes: $((Get-Item -LiteralPath $apk).Length)"
} finally {
  $env:JAVA_TOOL_OPTIONS = $previousJavaOptions
}
