#!/bin/bash

# Bootstrap script for quick installation
# Usage: curl -fsSL <raw-url>/scripts/bootstrap.sh | bash

set -e

REPO_URL="https://github.com/YOUR_USERNAME/dotfiles.git"
INSTALL_DIR="$HOME/.dotfiles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    log_error "Git is not installed. Please install git first."
    exit 1
fi

# Remove existing installation
if [ -d "$INSTALL_DIR" ]; then
    log_warning "Existing dotfiles found at $INSTALL_DIR"
    read -p "Remove existing installation? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
        log_info "Removed existing installation"
    else
        log_error "Installation cancelled"
        exit 1
    fi
fi

# Clone repository
log_info "Cloning dotfiles repository..."
git clone "$REPO_URL" "$INSTALL_DIR"

# Change to installation directory
cd "$INSTALL_DIR"

# Make scripts executable
chmod +x scripts/*.sh

# Run installation
log_info "Starting installation..."
if command -v make >/dev/null 2>&1; then
    make install
else
    ./scripts/install.sh
fi

log_success "🎉 Dotfiles installation completed!"
log_info "Please restart your terminal or run 'source ~/.config/fish/config.fish'" 