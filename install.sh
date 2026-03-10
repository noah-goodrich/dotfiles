#!/usr/bin/env bash
# =============================================================================
# Dotfiles Install Script
# Safe to re-run — backs up existing files before symlinking
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[dotfiles]${NC} $1"; }
warn()    { echo -e "${YELLOW}[dotfiles]${NC} $1"; }
error()   { echo -e "${RED}[dotfiles]${NC} $1"; }

# -----------------------------------------------------------------------------
# Symlink helper — backs up existing file/dir before linking
# Usage: link <source> <target>
# -----------------------------------------------------------------------------
link() {
    local src="$1"
    local dst="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    # If target already exists and is not already our symlink
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        warn "Backing up existing $dst → $BACKUP_DIR/"
        mv "$dst" "$BACKUP_DIR/"
    fi

    # Remove stale symlink
    [ -L "$dst" ] && rm "$dst"

    ln -sf "$src" "$dst"
    info "Linked $dst → $src"
}

# -----------------------------------------------------------------------------
# Install dependencies
# Checks for required tools and installs what's missing
# -----------------------------------------------------------------------------
install_deps() {
    info "Checking dependencies..."

    # tmux
    if ! command -v tmux &>/dev/null; then
        warn "tmux not found — installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install tmux
        else
            sudo apt-get install -y tmux
        fi
    fi

    # Zsh
    if ! command -v zsh &>/dev/null; then
        warn "zsh not found — installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install zsh
        else
            sudo apt-get install -y zsh
        fi
    fi

    # Powerlevel10k
    if [ ! -d "$HOME/.config/zsh/powerlevel10k" ]; then
        info "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$HOME/.config/zsh/powerlevel10k"
    fi

    # zsh-autosuggestions
    if [ ! -d "$HOME/.config/zsh/zsh-autosuggestions" ]; then
        info "Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.config/zsh/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$HOME/.config/zsh/zsh-syntax-highlighting" ]; then
        info "Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$HOME/.config/zsh/zsh-syntax-highlighting"
    fi
}

# -----------------------------------------------------------------------------
# Link all dotfiles
# -----------------------------------------------------------------------------
link_dotfiles() {
    info "Linking dotfiles..."

    # tmux
    link "$DOTFILES_DIR/tmux/tmux.conf"   "$HOME/.config/tmux/tmux.conf"

    # zsh
    link "$DOTFILES_DIR/zsh/.zshrc"       "$HOME/.zshrc"

    # git
    link "$DOTFILES_DIR/git/config"       "$HOME/.gitconfig"
    link "$DOTFILES_DIR/git/ignore"       "$HOME/.config/git/ignore"

    # neovim
    link "$DOTFILES_DIR/nvim"             "$HOME/.config/nvim"

    # ghostty
    link "$DOTFILES_DIR/ghostty"          "$HOME/.config/ghostty"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    info "Starting dotfiles installation from $DOTFILES_DIR"

    install_deps
    link_dotfiles

    info "Done! Start a new shell or run: source ~/.zshrc"

    if [ -d "$BACKUP_DIR" ]; then
        warn "Backups saved to: $BACKUP_DIR"
    fi
}

main "$@"
