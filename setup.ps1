<#
.SYNOPSIS
    One-line bootstrap script for Neovim + LazyVim setup.

.DESCRIPTION
    Run this command on a new machine:
    irm https://raw.githubusercontent.com/hoangneeee/my-nvim-config/master/setup.ps1 | iex

    Or with PowerShell:
    Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hoangneeee/my-nvim-config/master/setup.ps1" -UseBasicParsing).Content
#>

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/hoangneeee/my-nvim-config.git"
$InstallDir = "$env:USERPROFILE\.nvim-setup"

function Write-Step { param($msg) Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Err { param($msg) Write-Host "   [ERROR] $msg" -ForegroundColor Red }

Write-Host @"

  ╔══════════════════════════════════════════╗
  ║   Neovim + LazyVim Quick Setup           ║
  ║   github.com/hoangneeee/my-nvim-config   ║
  ╚══════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Err "Please run as Administrator!"
    Write-Host "   Right-click PowerShell -> Run as Administrator" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check winget
Write-Step "Checking winget..."
if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Err "Winget not found!"
    Write-Host "   Please install 'App Installer' from Microsoft Store first." -ForegroundColor Yellow
    exit 1
}
Write-Success "Winget available"

# Install Git if needed
Write-Step "Checking Git..."
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "   Installing Git..."
    winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}
Write-Success "Git ready"

# Clone or update repo
Write-Step "Downloading config..."
if (Test-Path $InstallDir) {
    Write-Host "   Updating existing installation..."
    Push-Location $InstallDir
    git pull --quiet
    Pop-Location
} else {
    Write-Host "   Cloning repository..."
    git clone --quiet $RepoUrl $InstallDir
}
Write-Success "Config downloaded to $InstallDir"

# Run main installer
Write-Step "Running installer..."
$installerPath = Join-Path $InstallDir "install.ps1"
if (Test-Path $installerPath) {
    & $installerPath
} else {
    Write-Err "install.ps1 not found in repository!"
    exit 1
}

Write-Host @"

  ╔══════════════════════════════════════════╗
  ║   Setup Complete!                        ║
  ║                                          ║
  ║   1. Restart your terminal               ║
  ║   2. Run 'nvim' to start                 ║
  ║   3. Press Space to see keybindings      ║
  ╚══════════════════════════════════════════╝

"@ -ForegroundColor Green
