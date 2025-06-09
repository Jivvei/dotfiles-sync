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

## 📦 Supported Applications

### 🪟 Terminal Multiplexer
**tmux** - Advanced terminal session manager
- **Enhanced Features**: Vim-style navigation (`h/j/k/l`), mouse support
- **Smart Copy/Paste**: Cross-platform clipboard integration (xclip/pbcopy)
- **Beautiful UI**: Custom status bar with system info
- **Session Management**: Auto-restore sessions, quick window switching
- **Layouts**: Multiple predefined layouts, easy pane management

### 🐠 Modern Shell  
**fish** - Friendly Interactive Shell
- **Smart Features**: Auto-suggestions, syntax highlighting, tab completion
- **Enhanced Aliases**: Common command shortcuts, tmux integration
- **Auto-launch**: Intelligent tmux session management for Alacritty
- **Cross-platform**: Optimized PATH handling for different systems

### 🚀 Terminal Emulator
**alacritty** - GPU-accelerated terminal
- **High Performance**: Hardware acceleration, smooth scrolling
- **Beautiful Theme**: Tokyo Night color scheme, transparent background
- **Font Support**: Nerd Fonts with icons, customizable sizing
- **Tmux Integration**: Optimized for tmux workflow
- **Keyboard Shortcuts**: Intuitive copy/paste, font scaling

### ⭐ Command Prompt
**starship** - Cross-shell prompt customization
- **Rich Information**: Git status, language versions, system info
- **Beautiful Design**: Gruvbox Dark theme with icons
- **Performance**: Fast rendering, minimal latency
- **Language Support**: Shows versions for Node.js, Python, Rust, Go, etc.
- **Git Integration**: Branch status, ahead/behind indicators

### 🎨 System Information
**neofetch** - System info display tool  
- **Comprehensive Info**: OS, kernel, shell, packages, memory
- **Customizable**: Beautiful ASCII art, color themes
- **Performance**: Hardware specs, uptime display
- **Cross-platform**: Works on all supported systems

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
- Intelligent package manager detection (dnf/apt/pacman/brew)

### Configuration Highlights

#### 🎯 tmux Advanced Features
- **Enhanced Navigation**: Vim-style keys + mouse support + smart layouts
- **Clipboard Magic**: Seamless system clipboard integration across platforms
- **Visual Feedback**: Real-time status bar with system metrics
- **Session Persistence**: Auto-restore tmux sessions on terminal startup
- **Quick Actions**: F1 help overlay, pane synchronization, layout cycling

#### 🐠 fish Shell Optimizations  
- **Smart Auto-launch**: Automatically starts tmux in Alacritty terminal
- **Enhanced PATH**: Cross-platform binary detection and prioritization
- **Aliases & Functions**: Pre-configured shortcuts for common operations
- **Interactive Experience**: Greeting disabled, suggestions enabled

#### 🎨 Visual & Theme Integration
- **Consistent Theming**: Tokyo Night (Alacritty) + Gruvbox Dark (Starship)
- **Font Integration**: Nerd Fonts support with proper icon rendering
- **Transparency Effects**: Subtle background blur and opacity
- **Color Coordination**: Harmonized color schemes across all tools

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