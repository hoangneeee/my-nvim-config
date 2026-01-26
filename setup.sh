#!/bin/bash

# ============================================================================
# Neovim + LazyVim One-Line Setup for macOS/Linux
# ============================================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/hoangneeee/my-nvim-config/master/setup.sh | bash
# ============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
GITHUB_REPO="hoangneeee/my-nvim-config"
GITHUB_BRANCH="master"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TEMP_DIR="/tmp/nvim-setup-$$"

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
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║     Neovim + LazyVim Setup for macOS/Linux            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

check_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_info "Detected: macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_info "Detected: Linux"
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

check_homebrew() {
    if command -v brew &> /dev/null; then
        print_success "Homebrew installed"
        return 0
    fi

    if [[ "$OS" == "macos" ]]; then
        print_warning "Homebrew not found"
        read -p "Install Homebrew? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            print_success "Homebrew installed"
        else
            print_error "Homebrew is required for macOS setup"
            exit 1
        fi
    fi
}

install_neovim() {
    if command -v nvim &> /dev/null; then
        local version=$(nvim --version | head -n1)
        print_success "Neovim already installed: $version"
        return 0
    fi

    print_info "Installing Neovim..."

    if [[ "$OS" == "macos" ]]; then
        brew install neovim
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y neovim
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y neovim
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm neovim
        else
            print_error "Package manager not supported"
            print_info "Please install Neovim manually: https://neovim.io"
            exit 1
        fi
    fi

    print_success "Neovim installed"
}

install_dependencies() {
    print_info "Installing dependencies..."

    local deps=("git" "ripgrep" "fd" "node")

    if [[ "$OS" == "macos" ]]; then
        for dep in "${deps[@]}"; do
            if ! command -v "$dep" &> /dev/null; then
                print_info "Installing $dep..."
                case "$dep" in
                    "node")
                        brew install node
                        ;;
                    "fd")
                        brew install fd
                        ;;
                    *)
                        brew install "$dep"
                        ;;
                esac
            else
                print_success "$dep already installed"
            fi
        done

        # Install lazygit
        if ! command -v lazygit &> /dev/null; then
            print_info "Installing lazygit..."
            brew install lazygit
        else
            print_success "lazygit already installed"
        fi
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y git ripgrep fd-find nodejs npm
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git ripgrep fd-find nodejs npm
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm git ripgrep fd nodejs npm
        fi
    fi

    print_success "Dependencies installed"
}

install_font() {
    if [[ "$OS" == "macos" ]]; then
        print_info "Installing Nerd Font..."

        if brew list --cask font-jetbrains-mono-nerd-font &> /dev/null; then
            print_success "JetBrainsMono Nerd Font already installed"
        else
            brew tap homebrew/cask-fonts
            brew install --cask font-jetbrains-mono-nerd-font
            print_success "JetBrainsMono Nerd Font installed"
        fi

        print_warning "Remember to set your terminal font to 'JetBrainsMono Nerd Font'"
    fi
}

download_config() {
    print_info "Downloading Neovim config..."

    # Backup existing config
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        local backup_dir="$HOME/.config/nvim-backup-$(date +%Y%m%d-%H%M%S)"
        print_warning "Backing up existing config to: $backup_dir"
        mv "$NVIM_CONFIG_DIR" "$backup_dir"
    fi

    # Download config
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"

    local ARCHIVE_URL="https://github.com/$GITHUB_REPO/archive/refs/heads/$GITHUB_BRANCH.tar.gz"

    if curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TEMP_DIR" --strip-components=1; then
        print_success "Config downloaded"
    else
        print_error "Failed to download config"
        exit 1
    fi

    # Install config
    mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
    cp -r "$TEMP_DIR/nvim" "$NVIM_CONFIG_DIR"
    rm -rf "$TEMP_DIR"

    print_success "Config installed: $NVIM_CONFIG_DIR"
}

show_completion() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ✨ Setup Complete!                                  ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_info "Next steps:"
    echo "  1. Open Neovim: ${CYAN}nvim${NC}"
    echo "  2. Wait for LazyVim to install plugins"
    echo "  3. Restart Neovim when installation completes"
    echo ""
    print_info "Useful commands:"
    echo "  ${CYAN}<Space>${NC}     - Show all keybindings"
    echo "  ${CYAN}<Space>e${NC}   - Toggle file explorer"
    echo "  ${CYAN}<Space>ff${NC}  - Find files"
    echo "  ${CYAN}<Space>sg${NC}  - Search in files"
    echo "  ${CYAN}<Space>l${NC}   - Open Lazy plugin manager"
    echo ""
    print_info "Documentation:"
    echo "  LazyVim: ${CYAN}https://www.lazyvim.org${NC}"
    echo "  Config:  ${CYAN}https://github.com/$GITHUB_REPO${NC}"
    echo ""
    print_info "Config location: ${CYAN}$NVIM_CONFIG_DIR${NC}"
    echo ""
}

# Main setup
main() {
    print_header

    print_info "This script will install:"
    echo "  • Neovim (latest)"
    echo "  • LazyVim distribution"
    echo "  • Dependencies (git, ripgrep, fd, node)"
    echo "  • JetBrainsMono Nerd Font (macOS only)"
    echo ""

    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled"
        exit 0
    fi

    echo ""
    check_os

    if [[ "$OS" == "macos" ]]; then
        check_homebrew
    fi

    install_neovim
    install_dependencies

    if [[ "$OS" == "macos" ]]; then
        install_font
    fi

    download_config
    show_completion
}

# Run main
main "$@"
