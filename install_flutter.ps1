param(
    [string]$InstallDir = "E:\src\flutter",
    [string]$Version = "3.27.4"
)

$ErrorActionPreference = "Stop"

# --- Prerequisites ---
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "Installing Git for Windows..."
    winget install --id Git.Git -e --source winget --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";$env:Path"
}

# --- Download SDK ---
$zipPath = "$env:TEMP\flutter_windows_$Version-stable.zip"
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$Version-stable.zip"

if (-not (Test-Path $zipPath)) {
    Write-Host "Downloading Flutter SDK $Version..."
    Import-Module BitsTransfer -ErrorAction SilentlyContinue
    Start-BitsTransfer -Source $url -Destination $zipPath -Priority High
}

# --- Extract ---
Write-Host "Extracting to $InstallDir..."
if (Test-Path $InstallDir) { Remove-Item -Recurse -Force $InstallDir }
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
Expand-Archive -LiteralPath $zipPath -DestinationPath $InstallDir\..
# The zip creates a flutter/ subfolder; move if needed
if (Test-Path "$InstallDir\..\flutter") {
    Move-Item -Path "$InstallDir\..\flutter\*" -Destination $InstallDir -Force
    Remove-Item -Recurse -Force "$InstallDir\..\flutter"
}

# --- Add to PATH ---
$binPath = "$InstallDir\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$binPath*") {
    Write-Host "Adding $binPath to user PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binPath", "User")
    $env:Path = "$env:Path;$binPath"
}

# --- Verify ---
Write-Host "`nVerifying installation..."
flutter --version
Write-Host "`nRunning flutter doctor (errors expected if Android Studio / VS not installed)..."
flutter doctor
