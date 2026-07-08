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

# Fresh adb server to avoid stale connections
log "Restarting adb server..."
adb kill-server 2>&1 | Out-Null
adb start-server 2>&1 | Out-Null

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

# Wait for adb to show device as "device" (connected, not just booted)
log "Waiting for adb connection..."
$adbConnected = $false
for ($i = 0; $i -lt 30; $i++) {
  $devices = adb devices 2>&1 | Out-String
  if ($devices -match "emulator-\d+\s+device") {
    $adbConnected = $true
    break
  }
  Start-Sleep -Seconds 2
}
if (-not $adbConnected) { throw "ADB device did not come online." }

# Extract device ID from adb devices output
$devicesStr = adb devices 2>&1 | Out-String
$m = [regex]::Match($devicesStr, "(emulator-\d+)\s+device")
$deviceId = $m.Groups[1].Value
if (-not $deviceId) { throw "Could not find Android emulator device." }

log "Detected device: $deviceId"

# Ensure adb is fully ready
adb -s $deviceId wait-for-device 2>&1 | Out-Null

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
