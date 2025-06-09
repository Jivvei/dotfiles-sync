# 🌍 跨平台配置文件同步工具

这是一个智能的跨平台配置文件同步工具，支持 Linux 和 macOS 系统的自动适配。

## 🎯 主要特性

### 智能平台检测
- **自动系统识别**: 支持 macOS、Fedora、Ubuntu、Arch Linux
- **Shell 路径智能检测**: 自动找到最佳的 fish/zsh/bash 路径
- **剪贴板工具适配**: macOS 使用 pbcopy/pbpaste，Linux 使用 xclip/xsel

### 配置文件智能适配
- **占位符系统**: 使用占位符在安装时自动替换为系统特定的配置
- **无需手动修改**: 一套配置文件适配所有支持的平台
- **向后兼容**: 保持与原有配置的兼容性

## 🚀 使用方法

### 快速开始

```bash
# 1. 克隆仓库
git clone <your-repo-url>
cd dotfiles-sync

# 2. 安装所有配置（推荐）
./install.sh

# 3. 或者仅应用配置（不安装软件）
./apply.sh
```

### 高级用法

```bash
# 仅应用 tmux 配置
./apply.sh -t

# 应用配置并重新加载
./apply.sh -t -r

# 强制应用所有配置（跳过确认）
./apply.sh --force

# 查看帮助
./apply.sh -h
```

## 📁 项目结构

```
dotfiles-sync/
├── install.sh              # 完整安装脚本（安装软件+配置）
├── apply.sh                 # 配置应用脚本（仅应用配置）
├── update.sh                # 配置同步脚本（本地→仓库）
├── tmux/
│   ├── .tmux.conf          # tmux 配置（含智能占位符）
│   ├── scripts/            # tmux 脚本
│   └── plugins/            # tmux 插件
├── alacritty/              # Alacritty 终端配置
├── fish/                   # Fish shell 配置
├── starship/               # Starship 提示符配置
└── neofetch/               # Neofetch 系统信息配置
```

## 🔧 技术实现

### 占位符系统

配置文件中使用特殊占位符，在安装时自动替换：

```bash
# tmux 配置中的占位符
set -g default-shell "FISH_PATH_PLACEHOLDER"
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'CLIPBOARD_COPY_PLACEHOLDER'
```

### 智能路径检测

```bash
# Fish shell 路径检测优先级
paths=(
    "$HOME/.local/bin/fish"      # 用户本地
    "/usr/local/bin/fish"        # Intel Mac Homebrew
    "/opt/homebrew/bin/fish"     # Apple Silicon Homebrew  
    "/usr/bin/fish"              # 系统默认
    "/bin/fish"                  # 备选
)
```

### 剪贴板工具适配

```bash
# macOS
copy_cmd="pbcopy"
paste_cmd="pbpaste"

# Linux
copy_cmd="xclip -in -selection clipboard"
paste_cmd="xclip -o -sel clipboard"
```

## 🛠️ 故障排除

### tmux 问题

如果 tmux 在 macOS 上有问题，通常是以下原因：

1. **Shell 路径错误**: 使用 `./apply.sh -t` 重新应用配置
2. **剪贴板不工作**: 确保已安装 pbcopy/pbpaste（macOS 内置）
3. **符号链接问题**: 脚本会自动处理符号链接

### 验证配置

```bash
# 检查 shell 路径
grep "default-shell" ~/.tmux.conf

# 检查剪贴板工具
grep "pbcopy\|xclip" ~/.tmux.conf

# 测试 tmux 配置
tmux source-file ~/.tmux.conf
```

## 🔄 配置同步

### 从本地同步到仓库

```bash
./update.sh
```

### 从仓库应用到本地

```bash
./apply.sh
```

## 🌟 支持的系统

| 系统 | 版本 | 状态 |
|------|------|------|
| macOS | 10.15+ | ✅ 完全支持 |
| Fedora | 35+ | ✅ 完全支持 |
| Ubuntu | 20.04+ | ✅ 完全支持 |
| Arch Linux | 最新 | ✅ 完全支持 |

## 📝 配置说明

### tmux 配置特性

- **跨平台兼容**: 自动适配不同系统的 shell 和剪贴板工具
- **增强快捷键**: Vim 风格导航 + 鼠标支持
- **智能复制粘贴**: 与系统剪贴板无缝集成
- **美观状态栏**: 显示系统信息和会话状态
- **插件支持**: 预配置常用插件

### 主要快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b \|` | 垂直分割窗格 |
| `Ctrl+b -` | 水平分割窗格 |
| `Ctrl+b h/j/k/l` | Vim 风格窗格导航 |
| `Ctrl+b r` | 重新加载配置 |
| `Ctrl+b F1` | 显示帮助 |

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## �� 许可证

MIT License 