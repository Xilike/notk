param(
  [string]$Key = $env:AZURE_SPEECH_KEY,
  [string]$Region = $env:AZURE_SPEECH_REGION
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Key) -or [string]::IsNullOrWhiteSpace($Region)) {
  throw "Set AZURE_SPEECH_KEY and AZURE_SPEECH_REGION first."
}

$root = Split-Path -Parent $PSScriptRoot
$outRoot = Join-Path $root 'assets\audio'
New-Item -ItemType Directory -Force $outRoot | Out-Null
# Export the actual app content so gender phrases cannot drift from the APK.
$catalogJson = & dart run (Join-Path $PSScriptRoot 'export_voice_catalog.dart')
if ($LASTEXITCODE -ne 0) { throw 'Could not export the app voice catalog.' }
$catalog = ($catalogJson -join "`n") | ConvertFrom-Json

function Escape-Xml([string]$Text) {
  return [System.Security.SecurityElement]::Escape($Text)
}

function Generate-Group([string]$Gender,[string]$Voice,[array]$Texts) {
  $folder = Join-Path $outRoot $Gender
  New-Item -ItemType Directory -Force $folder | Out-Null
  $map = [ordered]@{}
  $i = 0
  foreach ($text in ($Texts | Select-Object -Unique)) {
    $i++
    $name = '{0:D4}.mp3' -f $i
    $file = Join-Path $folder $name
    $escaped = Escape-Xml $text
    $ssml = "<speak version='1.0' xml:lang='ar-EG'><voice name='$Voice'><prosody rate='-8%'>$escaped</prosody></voice></speak>"
    $headers = @{
      'Ocp-Apim-Subscription-Key' = $Key
      'Content-Type' = 'application/ssml+xml'
      'X-Microsoft-OutputFormat' = 'audio-24khz-48kbitrate-mono-mp3'
      'User-Agent' = 'TasisAlNotqVoicePack'
    }
    Invoke-WebRequest -Uri "https://$Region.tts.speech.microsoft.com/cognitiveservices/v1" -Method Post -Headers $headers -Body ([Text.Encoding]::UTF8.GetBytes($ssml)) -OutFile $file
    $map[$text] = "audio/$Gender/$name"
    Write-Host "[$Gender] $i/$($Texts.Count) $text"
  }
  return $map
}

$boyMap = Generate-Group 'boy' 'ar-EG-ShakirNeural' @($catalog.boy)
$girlMap = Generate-Group 'girl' 'ar-EG-SalmaNeural' @($catalog.girl)
$manifest = [ordered]@{ boy = $boyMap; girl = $girlMap }
$manifest | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $outRoot 'voice_manifest.json') -Encoding UTF8
Write-Host "Voice pack generated in $outRoot"
