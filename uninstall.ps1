#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Uninstall Neovim and all configurations.

.DESCRIPTION
    This script removes:
    - Neovim application
    - Neovim config (~\AppData\Local\nvim)
    - Neovim data (~\AppData\Local\nvim-data)
    - Optionally: dev tools (git, node, python, etc.)

.EXAMPLE
    .\uninstall.ps1
    .\uninstall.ps1 -KeepTools
    .\uninstall.ps1 -All
#>

param(
    [switch]$KeepTools,   # Keep dev tools (git, node, python, etc.)
    [switch]$All,         # Remove everything including dev tools
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Step { param($msg) Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "   [WARN] $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "   [ERROR] $msg" -ForegroundColor Red }

function Show-Help {
    Write-Host @"

  Neovim Uninstaller
  ==================

  Usage: .\uninstall.ps1 [options]

  Options:
    -KeepTools    Only remove Neovim, keep dev tools
    -All          Remove everything (Neovim + all dev tools)
    -Help         Show this help message

  Default: Remove Neovim + config only (same as -KeepTools)

  What gets removed:
    - Neovim application
    - Neovim config folder
    - Neovim data folder (plugins, cache)
    - With -All: Git, Node.js, Python, ripgrep, fd, fzf, lazygit

"@
}

function Remove-WithWinget {
    param([string]$PackageId, [string]$Name)

    Write-Host "   Removing $Name..." -NoNewline
    $result = winget uninstall --id $PackageId --silent 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Success "$Name removed"
        return $true
    } else {
        Write-Warn "$Name not found or already removed"
        return $false
    }
}

function Remove-NvimConfig {
    Write-Step "Removing Neovim configuration"

    $paths = @(
        "$env:LOCALAPPDATA\nvim",
        "$env:LOCALAPPDATA\nvim-data"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Host "   Removing $path..."
            Remove-Item -Path $path -Recurse -Force
            Write-Success "Removed $path"
        } else {
            Write-Warn "$path not found"
        }
    }
}

function Remove-NvimBackups {
    Write-Step "Removing Neovim backups"

    $backups = Get-ChildItem -Path $env:LOCALAPPDATA -Filter "nvim*.backup.*" -Directory -ErrorAction SilentlyContinue

    if ($backups) {
        foreach ($backup in $backups) {
            Write-Host "   Removing $($backup.FullName)..."
            Remove-Item -Path $backup.FullName -Recurse -Force
        }
        Write-Success "Removed $($backups.Count) backup(s)"
    } else {
        Write-Warn "No backups found"
    }
}

function Remove-SetupFolder {
    Write-Step "Removing setup folder"

    $setupDir = "$env:USERPROFILE\.nvim-setup"
    if (Test-Path $setupDir) {
        Remove-Item -Path $setupDir -Recurse -Force
        Write-Success "Removed $setupDir"
    } else {
        Write-Warn "Setup folder not found"
    }
}

function Remove-Neovim {
    Write-Step "Removing Neovim"
    Remove-WithWinget -PackageId "Neovim.Neovim" -Name "Neovim"
}

function Remove-DevTools {
    Write-Step "Removing development tools"

    $packages = @(
        @{ Id = "JesseDuffield.lazygit"; Name = "lazygit" },
        @{ Id = "junegunn.fzf"; Name = "fzf" },
        @{ Id = "sharkdp.fd"; Name = "fd" },
        @{ Id = "BurntSushi.ripgrep.MSVC"; Name = "Ripgrep" }
    )

    foreach ($pkg in $packages) {
        Remove-WithWinget -PackageId $pkg.Id -Name $pkg.Name
    }

    # Ask before removing major tools
    Write-Host ""
    $confirm = Read-Host "   Remove Node.js, Python, Git? (y/N)"
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        Remove-WithWinget -PackageId "OpenJS.NodeJS.LTS" -Name "Node.js"
        Remove-WithWinget -PackageId "Python.Python.3.12" -Name "Python"
        Remove-WithWinget -PackageId "Git.Git" -Name "Git"
    } else {
        Write-Warn "Skipped Node.js, Python, Git"
    }
}

function Remove-NerdFont {
    Write-Step "Removing Nerd Fonts"

    $fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

    # Remove font files
    $fonts = Get-ChildItem -Path $fontsFolder -Filter "*JetBrainsMono*Nerd*" -ErrorAction SilentlyContinue
    if ($fonts) {
        foreach ($font in $fonts) {
            Remove-Item $font.FullName -Force -ErrorAction SilentlyContinue
        }
        Write-Success "Removed font files"
    }

    # Remove registry entries
    $regFonts = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    if ($regFonts) {
        $fontKeys = $regFonts.PSObject.Properties | Where-Object { $_.Name -match "JetBrainsMono" }
        foreach ($key in $fontKeys) {
            Remove-ItemProperty -Path $regPath -Name $key.Name -ErrorAction SilentlyContinue
        }
        if ($fontKeys) {
            Write-Success "Removed font registry entries"
        }
    }
}

# ============ Main ============

if ($Help) {
    Show-Help
    exit 0
}

Write-Host @"

  ╔══════════════════════════════════════════╗
  ║   Neovim Uninstaller                     ║
  ╚══════════════════════════════════════════╝

"@ -ForegroundColor Red

# Confirm
Write-Host "   This will remove Neovim and its configurations." -ForegroundColor Yellow
if ($All) {
    Write-Host "   Also removing: dev tools, fonts" -ForegroundColor Yellow
}
Write-Host ""
$confirm = Read-Host "   Continue? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "`n   Cancelled." -ForegroundColor Yellow
    exit 0
}

# Remove Neovim
Remove-Neovim
Remove-NvimConfig
Remove-NvimBackups
Remove-SetupFolder

# Remove dev tools if -All
if ($All) {
    Remove-NerdFont
    Remove-DevTools
}

Write-Host @"

  ╔══════════════════════════════════════════╗
  ║   Uninstall Complete!                    ║
  ╚══════════════════════════════════════════╝

  Removed:
    - Neovim application
    - Config folder (~\AppData\Local\nvim)
    - Data folder (~\AppData\Local\nvim-data)
    - Setup folder (~\.nvim-setup)

"@ -ForegroundColor Green

if (-not $All) {
    Write-Host "  To also remove dev tools, run: .\uninstall.ps1 -All" -ForegroundColor Cyan
}
