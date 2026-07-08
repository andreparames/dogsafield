param(
  [string]$EmulatorAvd = "pixel_google",
  [switch]$NoBuild
)

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$DotEnv = Join-Path $ProjectRoot ".env"
$LogDir = Join-Path $PSScriptRoot "emulator_logs"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$bootLog = Join-Path $LogDir "boot_$timestamp.log"
$runLog  = Join-Path $LogDir "run_$timestamp.log"

function log($msg) { Write-Host $msg -ForegroundColor Cyan }

log "Starting emulator AVD: $EmulatorAvd"
$launchResult = flutter emulators --launch $EmulatorAvd 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
  log "Emulator may already be running. Continuing..."
}

log "Waiting for device to boot..."
$bootStart = Get-Date
$booted = $false
while (-not $booted) {
  $result = adb shell getprop sys.boot_completed 2>&1 | Out-String
  $result = $result.Trim()
  if ($result -eq "1") {
    $booted = $true
  } else {
    Start-Sleep -Seconds 3
  }
}
$bootElapsed = [math]::Round(((Get-Date) - $bootStart).TotalSeconds, 1)
"Boot completed in ${bootElapsed}s at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $bootLog

log "Emulator booted in ${bootElapsed}s. Log saved: $bootLog"

$deviceId = $null
$attempts = 0
while (-not $deviceId -and $attempts -lt 30) {
  $lines = flutter devices 2>&1 | Out-String
  $m = [regex]::Match($lines, "(emulator-\d+)")
  if ($m.Success) {
    $deviceId = $m.Groups[1].Value
  } else {
    Start-Sleep -Seconds 2
    $attempts++
  }
}

if (-not $deviceId) { throw "Could not find Android emulator device." }

log "Detected device: $deviceId"

log "Verifying device is still online..."
$verified = $false
for ($i = 0; $i -lt 15; $i++) {
  $lines = flutter devices 2>&1 | Out-String
  if ($lines -match [regex]::Escape($deviceId)) {
    $verified = $true
    break
  }
  Start-Sleep -Seconds 2
}
if (-not $verified) { throw "Device $deviceId went offline after boot." }
log "Device $deviceId verified."

if (-not $NoBuild) {
  if (-not (Test-Path $DotEnv)) {
    Write-Warning ".env not found at $DotEnv. Supabase credentials won't be set."
  }
  log "Building and running on $deviceId... Log: $runLog"
  flutter run -d $deviceId --dart-define-from-file=$DotEnv 2>&1 | Tee-Object -FilePath $runLog
  log "App exited. Full log: $runLog"
} else {
  log "Emulator ready. Run: flutter run -d $deviceId"
}
