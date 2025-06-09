# 🌍 Cross-Platform Dotfiles

A smart cross-platform configuration management tool for terminal environments.

## ✨ Features

- **Cross-Platform**: Supports macOS, Fedora, Ubuntu, Arch Linux
- **Smart Detection**: Auto-detects system type and tool paths
- **One-Click Setup**: Automated installation and configuration
- **Safe Backup**: Automatically backs up existing configurations

## 🚀 Quick Start

### One-Line Installation
```bash
curl -fsSL https://raw.githubusercontent.com/Jivvei/dotfiles/main/scripts/bootstrap.sh | bash
```

### Manual Installation
```bash
git clone https://github.com/Jivvei/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

### Apply Configurations Only
```bash
make apply
```

## 📦 Included Tools

- **tmux**: Terminal multiplexer with enhanced keybindings
- **fish**: Modern shell with autocompletion
- **alacritty**: GPU-accelerated terminal emulator
- **starship**: Cross-shell prompt
- **neofetch**: System information display

## 🔧 Available Commands

| Command | Purpose |
|---------|---------|
| `make install` | Install software packages + apply configurations |
| `make apply` | Apply configurations only (smart cross-platform) |
| `make update` | Sync local configs back to repository |
| `make uninstall` | Remove dotfiles and restore backups |
| `make test` | Test configuration validity |
| `make clean` | Clean temporary files and backups |

## 💡 Key Features

### Smart Platform Adaptation
- Auto-detects shell paths (`/usr/bin/fish` vs `/usr/local/bin/fish`)
- Platform-specific clipboard tools (`pbcopy` on macOS, `xclip` on Linux)
- Handles symbolic links and file permissions

### Tmux Enhancements
- Vim-style navigation (`h/j/k/l`)
- Mouse support with smart copy/paste
- System clipboard integration
- Beautiful status bar

## 🌟 Supported Systems

| OS | Status |
|----|--------|
| macOS (Intel/Apple Silicon) | ✅ Full Support |
| Fedora/RHEL/CentOS | ✅ Full Support |
| Ubuntu/Debian | ✅ Full Support |
| Arch Linux | ✅ Full Support |

## 📖 Documentation

- [中文文档](README-zh.md) - Chinese documentation
- Configuration examples in each directory

## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📄 License

MIT License 