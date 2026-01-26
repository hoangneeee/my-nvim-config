#!/bin/bash

# ============================================================================
# Neovim Config Updater for macOS/Linux
# ============================================================================
# Usage:
#   ./update-config.sh              # Update config from GitHub
#   ./update-config.sh --restore    # Restore from backup
#   ./update-config.sh --help       # Show help
# ============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="hoangneeee/my-nvim-config"
GITHUB_BRANCH="master"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"
TEMP_DIR="/tmp/nvim-config-update"

# Functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  Neovim Config Updater - macOS/Linux                ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    cat << EOF
Neovim Config Updater

USAGE:
    ./update-config.sh [OPTIONS]

OPTIONS:
    --restore       Restore config from most recent backup
    --help, -h      Show this help message

EXAMPLES:
    # Update config from GitHub
    ./update-config.sh

    # Restore from backup
    ./update-config.sh --restore

DESCRIPTION:
    This script downloads the latest Neovim configuration from GitHub
    and updates your local config. It automatically backs up your current
    config before updating.

REPOSITORY:
    https://github.com/$GITHUB_REPO
EOF
    exit 0
}

backup_current_config() {
    print_info "Backing up current config..."

    if [ -d "$NVIM_CONFIG_DIR" ]; then
        cp -r "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        print_success "Backup created: $BACKUP_DIR"
    else
        print_warning "No existing config found, skipping backup"
    fi
}

download_config() {
    print_info "Downloading latest config from GitHub..."

    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"

    # Download using curl
    local ARCHIVE_URL="https://github.com/$GITHUB_REPO/archive/refs/heads/$GITHUB_BRANCH.tar.gz"

    if curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TEMP_DIR" --strip-components=1; then
        print_success "Config downloaded successfully"
    else
        print_error "Failed to download config"
        exit 1
    fi
}

update_config() {
    print_info "Updating Neovim config..."

    # Create config directory if it doesn't exist
    mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"

    # Remove old config
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        rm -rf "$NVIM_CONFIG_DIR"
    fi

    # Copy new config
    if [ -d "$TEMP_DIR/nvim" ]; then
        cp -r "$TEMP_DIR/nvim" "$NVIM_CONFIG_DIR"
        print_success "Config updated: $NVIM_CONFIG_DIR"
    else
        print_error "nvim directory not found in downloaded archive"
        exit 1
    fi

    # Clean up
    rm -rf "$TEMP_DIR"
}

restore_from_backup() {
    print_info "Looking for backups..."

    # Find most recent backup
    local LATEST_BACKUP=$(ls -dt "$HOME/.config/nvim-backup-"* 2>/dev/null | head -n1)

    if [ -z "$LATEST_BACKUP" ]; then
        print_error "No backup found"
        exit 1
    fi

    print_info "Found backup: $LATEST_BACKUP"
    read -p "Restore from this backup? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup current config before restoring
        if [ -d "$NVIM_CONFIG_DIR" ]; then
            local RESTORE_BACKUP="$HOME/.config/nvim-before-restore-$(date +%Y%m%d-%H%M%S)"
            cp -r "$NVIM_CONFIG_DIR" "$RESTORE_BACKUP"
            print_info "Current config backed up to: $RESTORE_BACKUP"
        fi

        # Restore
        rm -rf "$NVIM_CONFIG_DIR"
        cp -r "$LATEST_BACKUP" "$NVIM_CONFIG_DIR"
        print_success "Config restored from backup"
    else
        print_info "Restore cancelled"
        exit 0
    fi
}

list_backups() {
    print_info "Available backups:"
    echo ""
    ls -lht "$HOME/.config/nvim-backup-"* 2>/dev/null | awk '{print "  " $6, $7, $8, $9}' || echo "  No backups found"
    echo ""
}

# Main script
main() {
    print_header

    # Parse arguments
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --restore)
            restore_from_backup
            exit 0
            ;;
        --list-backups)
            list_backups
            exit 0
            ;;
        "")
            # Continue with update
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac

    # Update process
    print_info "This will update your Neovim config from GitHub"
    print_warning "Your current config will be backed up first"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Update cancelled"
        exit 0
    fi

    backup_current_config
    download_config
    update_config

    echo ""
    print_success "✨ Config updated successfully!"
    echo ""
    print_info "Backup location: $BACKUP_DIR"
    print_info "Config location: $NVIM_CONFIG_DIR"
    echo ""
    print_info "Next steps:"
    echo "  1. Open Neovim: nvim"
    echo "  2. Wait for plugins to install"
    echo "  3. Restart Neovim"
    echo ""
    print_info "To restore from backup, run:"
    echo "  ./update-config.sh --restore"
    echo ""
}

# Run main function
main "$@"
