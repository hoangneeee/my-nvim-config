#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Quick setup script for full development environment on Windows with LazyVim.

.DESCRIPTION
    This script installs and configures:
    - Neovim (latest) with LazyVim distribution
    - Git
    - Node.js (LTS)
    - Python
    - Ripgrep, fd, fzf (for telescope/searching)
    - Nerd Fonts (JetBrainsMono)
    - Windows Terminal configuration
    - lazygit

.EXAMPLE
    .\install.ps1
    .\install.ps1 -SkipFonts
    .\install.ps1 -NvimOnly
#>

param(
    [switch]$SkipFonts,
    [switch]$NvimOnly,
    [switch]$Check,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors for output
function Write-Step { param($msg) Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "   [WARN] $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "   [ERROR] $msg" -ForegroundColor Red }

function Show-Help {
    Write-Host @"

  Neovim Dev Environment Setup (LazyVim)
  =======================================

  Usage: .\install.ps1 [options]

  Options:
    -Check        Check if all dependencies are installed
    -SkipFonts    Skip Nerd Fonts installation
    -NvimOnly     Only install Neovim and its config
    -Help         Show this help message

  What gets installed:
    - Neovim (latest)
    - Git
    - Node.js LTS
    - Python 3
    - Ripgrep, fd, fzf
    - JetBrainsMono Nerd Font (with icons)
    - lazygit

  Examples:
    .\install.ps1           # Full installation
    .\install.ps1 -Check    # Check dependencies only
    .\install.ps1 -NvimOnly # Only Neovim + config

"@
}

function Test-Command {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-NerdFontInstalled {
    param([string]$FontName = "JetBrainsMono")

    $fontPaths = @(
        "$env:LOCALAPPDATA\Microsoft\Windows\Fonts",
        "$env:WINDIR\Fonts"
    )

    foreach ($path in $fontPaths) {
        if (Test-Path $path) {
            $found = Get-ChildItem -Path $path -Filter "*$FontName*Nerd*" -ErrorAction SilentlyContinue
            if ($found) { return $true }
        }
    }

    # Check registry
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $regFonts = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    if ($regFonts -and ($regFonts.PSObject.Properties.Name -match $FontName)) {
        return $true
    }

    return $false
}

function Test-AllDependencies {
    Write-Step "Checking installed dependencies"

    $deps = @(
        @{ Name = "Git"; Command = "git" },
        @{ Name = "Neovim"; Command = "nvim" },
        @{ Name = "Node.js"; Command = "node" },
        @{ Name = "Python"; Command = "python" },
        @{ Name = "Ripgrep"; Command = "rg" },
        @{ Name = "fd"; Command = "fd" },
        @{ Name = "fzf"; Command = "fzf" },
        @{ Name = "lazygit"; Command = "lazygit" }
    )

    $missing = @()
    foreach ($dep in $deps) {
        if (Test-Command $dep.Command) {
            Write-Success "$($dep.Name) installed"
        } else {
            Write-Warn "$($dep.Name) not found"
            $missing += $dep.Name
        }
    }

    # Check Nerd Font
    if (Test-NerdFontInstalled) {
        Write-Success "Nerd Font installed"
    } else {
        Write-Warn "Nerd Font not found"
        $missing += "Nerd Font"
    }

    # Check nvim config
    $nvimConfigPath = "$env:LOCALAPPDATA\nvim\init.lua"
    if (Test-Path $nvimConfigPath) {
        Write-Success "Neovim config exists"
    } else {
        Write-Warn "Neovim config not found"
        $missing += "Neovim config"
    }

    return $missing
}

function Install-WithWinget {
    param(
        [string]$PackageId,
        [string]$Name
    )

    if (-not (Test-Command "winget")) {
        Write-Err "Winget not found. Please install App Installer from Microsoft Store."
        return $false
    }

    Write-Host "   Installing $Name..." -NoNewline
    $result = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements 2>&1

    if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
        Write-Success "$Name installed"
        return $true
    } else {
        Write-Warn "$Name may need manual installation"
        return $false
    }
}

function Install-NerdFont {
    param([string]$FontName = "JetBrainsMono")

    Write-Step "Installing Nerd Font: $FontName"

    $fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"
    $tempZip = "$env:TEMP\$FontName.zip"
    $tempExtract = "$env:TEMP\$FontName"

    try {
        Write-Host "   Downloading $FontName Nerd Font..."
        Invoke-WebRequest -Uri $fontUrl -OutFile $tempZip -UseBasicParsing

        Write-Host "   Extracting fonts..."
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

        Write-Host "   Installing fonts..."
        $fonts = Get-ChildItem -Path $tempExtract -Filter "*.ttf" -Recurse
        foreach ($font in $fonts) {
            $destPath = Join-Path $fontsFolder $font.Name
            Copy-Item $font.FullName $destPath -Force

            # Register font
            $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $fontTitle = [System.IO.Path]::GetFileNameWithoutExtension($font.Name)
            Set-ItemProperty -Path $regPath -Name "$fontTitle (TrueType)" -Value $destPath
        }

        Write-Success "Nerd Font installed. Restart terminal to use."

        # Cleanup
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warn "Font installation failed: $_"
        Write-Host "   Manual install: https://www.nerdfonts.com/font-downloads"
    }
}

function Install-DevTools {
    Write-Step "Installing Development Tools"

    $packages = @(
        @{ Id = "Git.Git"; Name = "Git" },
        @{ Id = "Neovim.Neovim"; Name = "Neovim" },
        @{ Id = "OpenJS.NodeJS.LTS"; Name = "Node.js LTS" },
        @{ Id = "Python.Python.3.12"; Name = "Python 3.12" },
        @{ Id = "BurntSushi.ripgrep.MSVC"; Name = "Ripgrep" },
        @{ Id = "sharkdp.fd"; Name = "fd" },
        @{ Id = "junegunn.fzf"; Name = "fzf" },
        @{ Id = "JesseDuffield.lazygit"; Name = "lazygit" }
    )

    foreach ($pkg in $packages) {
        Install-WithWinget -PackageId $pkg.Id -Name $pkg.Name
    }
}

function Install-NvimOnly {
    Write-Step "Installing Neovim Only"
    Install-WithWinget -PackageId "Neovim.Neovim" -Name "Neovim"
}

function Setup-NvimConfig {
    Write-Step "Setting up LazyVim Configuration"

    $nvimConfigPath = "$env:LOCALAPPDATA\nvim"
    $nvimDataPath = "$env:LOCALAPPDATA\nvim-data"
    $sourceConfig = Join-Path $ScriptDir "nvim"

    # Backup existing config and data
    if (Test-Path $nvimConfigPath) {
        $backupPath = "$nvimConfigPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "   Backing up existing config to $backupPath"
        Move-Item $nvimConfigPath $backupPath -Force
    }

    if (Test-Path $nvimDataPath) {
        $backupDataPath = "$nvimDataPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "   Backing up existing data to $backupDataPath"
        Move-Item $nvimDataPath $backupDataPath -Force
    }

    # Copy config
    if (Test-Path $sourceConfig) {
        Write-Host "   Copying LazyVim config..."
        Copy-Item $sourceConfig $nvimConfigPath -Recurse -Force
        Write-Success "LazyVim config installed to $nvimConfigPath"
    } else {
        Write-Err "No nvim config folder found in repo!"
        Write-Host "   Please ensure the 'nvim' folder exists in the repository."
        return
    }
}

function Setup-WindowsTerminal {
    Write-Step "Configuring Windows Terminal"

    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (-not (Test-Path $wtSettingsPath)) {
        Write-Warn "Windows Terminal settings not found. Is Windows Terminal installed?"
        return
    }

    try {
        $settings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json

        # Update default profile font
        if (-not $settings.profiles.defaults) {
            $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{} -Force
        }

        $settings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{
            face = "JetBrainsMono Nerd Font"
            size = 12
        } -Force

        $settings.profiles.defaults | Add-Member -NotePropertyName "opacity" -NotePropertyValue 95 -Force
        $settings.profiles.defaults | Add-Member -NotePropertyName "useAcrylic" -NotePropertyValue $true -Force

        $settings | ConvertTo-Json -Depth 100 | Set-Content $wtSettingsPath
        Write-Success "Windows Terminal configured with Nerd Font"
    }
    catch {
        Write-Warn "Could not update Windows Terminal settings: $_"
    }
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ============ Main ============

if ($Help) {
    Show-Help
    exit 0
}

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "   Neovim Dev Environment Setup" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# Check mode - only verify dependencies
if ($Check) {
    $missing = Test-AllDependencies
    if ($missing.Count -eq 0) {
        Write-Host "`n   All dependencies installed!" -ForegroundColor Green
    } else {
        Write-Host "`n   Missing: $($missing -join ', ')" -ForegroundColor Yellow
        Write-Host "   Run .\install.ps1 to install missing dependencies." -ForegroundColor Cyan
    }
    exit 0
}

if ($NvimOnly) {
    Install-NvimOnly
} else {
    Install-DevTools
}

# Install font only if not already installed
if (-not $SkipFonts -and -not $NvimOnly) {
    if (Test-NerdFontInstalled) {
        Write-Step "Nerd Font already installed, skipping..."
    } else {
        Install-NerdFont
    }
}

Setup-NvimConfig

if (-not $NvimOnly) {
    Setup-WindowsTerminal
}

Refresh-Path

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "   Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host @"

  Next steps:
  1. Restart your terminal
  2. Run 'nvim' to start Neovim
  3. LazyVim plugins will auto-install on first launch
  4. Press Space to see available keybindings

  LazyVim Key bindings (Space = Leader):
    <Space>      - Show all keybindings (which-key)
    <Space>e     - File explorer (neo-tree)
    <Space>ff    - Find files
    <Space>/     - Live grep (search in files)
    <Space>,     - Switch buffers
    <Space>gg    - Lazygit
    <Space>l     - Lazy plugin manager

  Customize your config:
    nvim/lua/plugins/*.lua  - Add/override plugins
    nvim/lua/config/*.lua   - Options, keymaps, autocmds

  LazyVim docs: https://www.lazyvim.org

"@
