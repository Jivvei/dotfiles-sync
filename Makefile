.PHONY: install uninstall update help clean test

# Default target
all: install

# Install dotfiles (full installation with packages)
install:
	@echo "🚀 Installing dotfiles with packages..."
	@./scripts/install.sh

# Apply configurations only (no package installation)
apply:
	@echo "⚙️  Applying configurations..."
	@./scripts/apply.sh

# Update local configurations to repository
update:
	@echo "🔄 Updating configurations..."
	@./scripts/update.sh

# Uninstall dotfiles (restore backups)
uninstall:
	@echo "🗑️  Uninstalling dotfiles..."
	@./scripts/uninstall.sh

# Clean temporary files and backups
clean:
	@echo "🧹 Cleaning temporary files..."
	@find . -name "*.backup.*" -type f -delete 2>/dev/null || true
	@find . -name "*.tmp" -type f -delete 2>/dev/null || true
	@find . -name ".DS_Store" -type f -delete 2>/dev/null || true
	@echo "✅ Cleanup complete"

# Test configurations
test:
	@echo "🧪 Testing configurations..."
	@./scripts/test.sh

# Show help
help:
	@echo "📖 Dotfiles Management Commands:"
	@echo ""
	@echo "  make install    - Install packages and apply configurations"
	@echo "  make apply      - Apply configurations only (no packages)"
	@echo "  make update     - Update local configs to repository"
	@echo "  make uninstall  - Remove dotfiles and restore backups"
	@echo "  make clean      - Clean temporary files and backups"
	@echo "  make test       - Test configuration validity"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "📝 Quick start:"
	@echo "  git clone https://github.com/Jivvei/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && make install" 