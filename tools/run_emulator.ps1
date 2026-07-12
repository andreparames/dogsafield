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

function log($msg) {
  $t = Get-Date -Format "HH:mm:ss"
  Write-Host "[$t] $msg"
}

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

log "Emulator booted in ${bootElapsed}s."

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

$devicesStr = adb devices 2>&1 | Out-String
$m = [regex]::Match($devicesStr, "(emulator-\d+)\s+device")
$deviceId = $m.Groups[1].Value
if (-not $deviceId) { throw "Could not find Android emulator device." }

log "Detected device: $deviceId"

adb -s $deviceId wait-for-device 2>&1 | Out-Null
log "ADB ready."

if (-not $NoBuild) {
  if (-not (Test-Path $DotEnv)) {
    Write-Warning ".env not found at $DotEnv. Supabase credentials won't be set."
  }

  # Step 1: build APK separately
  log "Building APK..."
  $apkPath = "$ProjectRoot\build\app\outputs\flutter-apk\app-debug.apk"
  just build-apk 2>&1 | Tee-Object -FilePath $runLog
  if ($LASTEXITCODE -ne 0) { throw "Build failed." }
  log "APK built."

  # Step 2: install via adb
  log "Installing APK via adb..."
  adb -s $deviceId install -r "$apkPath" 2>&1 | Tee-Object -FilePath $runLog -Append
  $installExit = $LASTEXITCODE
  if ($installExit -ne 0) {
    log "adb install exit code: $installExit"
    throw "Install failed."
  }
  log "APK installed."

  # Step 3: launch with flutter run (it will detect existing install and attach debugger)
  log "Launching app on $deviceId... Log: $runLog"
  flutter run -d $deviceId --dart-define-from-file=$DotEnv 2>&1 | Tee-Object -FilePath $runLog -Append
  log "App exited."
} else {
  log "Emulator ready. Run: flutter run -d $deviceId"
}
