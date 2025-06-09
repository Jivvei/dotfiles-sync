#!/bin/bash

# Uninstall script for dotfiles
# Restores backups and removes symlinks

set -e

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

echo "🗑️  Dotfiles Uninstaller"
echo "======================="

# Confirm uninstallation
read -p "Are you sure you want to uninstall dotfiles? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Uninstallation cancelled"
    exit 0
fi

# Find and restore backup files
log_info "Looking for backup files..."
BACKUP_COUNT=0

for backup in "$HOME"/*.backup.*; do
    if [ -f "$backup" ]; then
        # Extract original filename
        original=$(echo "$backup" | sed 's/\.backup\.[0-9]*-[0-9]*//g')
        
        if [ -f "$original" ]; then
            log_warning "Removing current: $original"
            rm "$original"
        fi
        
        log_info "Restoring backup: $backup -> $original"
        mv "$backup" "$original"
        ((BACKUP_COUNT++))
    fi
done

# Find and restore .config backup files
for backup in "$HOME/.config"/**/*.backup.*; do
    if [ -f "$backup" ]; then
        original=$(echo "$backup" | sed 's/\.backup\.[0-9]*-[0-9]*//g')
        
        if [ -f "$original" ]; then
            log_warning "Removing current: $original"
            rm "$original"
        fi
        
        log_info "Restoring backup: $backup -> $original"
        mv "$backup" "$original"
        ((BACKUP_COUNT++))
    fi
done

if [ $BACKUP_COUNT -eq 0 ]; then
    log_warning "No backup files found to restore"
else
    log_success "Restored $BACKUP_COUNT backup files"
fi

# Remove dotfiles directory (optional)
if [ -d "$HOME/.dotfiles" ]; then
    read -p "Remove dotfiles repository from ~/.dotfiles? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.dotfiles"
        log_success "Removed ~/.dotfiles directory"
    fi
fi

# Clean up temporary files
make clean 2>/dev/null || {
    find . -name "*.backup.*" -type f -delete 2>/dev/null || true
    find . -name "*.tmp" -type f -delete 2>/dev/null || true
}

log_success "🎉 Uninstallation completed!"
log_info "Please restart your terminal to ensure all changes take effect" 