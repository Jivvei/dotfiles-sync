# 🌍 跨平台配置文件管理工具

智能的跨平台终端环境配置管理工具。

## ✨ 特性

- **跨平台支持**: 支持 macOS、Fedora、Ubuntu、Arch Linux
- **智能检测**: 自动检测系统类型和工具路径
- **一键安装**: 自动化安装和配置
- **安全备份**: 自动备份现有配置

## 🚀 快速开始

### 一键安装
```bash
curl -fsSL https://raw.githubusercontent.com/Jivvei/dotfiles/main/scripts/bootstrap.sh | bash
```

### 手动安装
```bash
git clone https://github.com/Jivvei/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

### 仅应用配置
```bash
make apply
```

## 📦 支持的应用程序

### 🪟 终端多路复用器
**tmux** - 高级终端会话管理器
- **增强功能**: Vim 风格导航（`h/j/k/l`），鼠标支持
- **智能复制粘贴**: 跨平台剪贴板集成（xclip/pbcopy）
- **美观界面**: 自定义状态栏显示系统信息
- **会话管理**: 自动恢复会话，快速窗口切换
- **布局管理**: 多种预定义布局，轻松管理窗格

### 🐠 现代化 Shell
**fish** - 友好的交互式 Shell
- **智能功能**: 自动建议，语法高亮，Tab 补全
- **增强别名**: 常用命令快捷方式，tmux 集成
- **自动启动**: Alacritty 终端智能 tmux 会话管理
- **跨平台**: 针对不同系统优化的 PATH 处理

### 🚀 终端模拟器
**alacritty** - GPU 加速终端
- **高性能**: 硬件加速，流畅滚动
- **美观主题**: Tokyo Night 配色方案，透明背景
- **字体支持**: Nerd Fonts 图标支持，自定义字体大小
- **tmux 集成**: 针对 tmux 工作流优化
- **快捷键**: 直观的复制粘贴，字体缩放

### ⭐ 命令提示符
**starship** - 跨 shell 提示符自定义
- **丰富信息**: Git 状态，编程语言版本，系统信息
- **美观设计**: Gruvbox Dark 主题配图标
- **高性能**: 快速渲染，最小延迟
- **语言支持**: 显示 Node.js、Python、Rust、Go 等版本
- **Git 集成**: 分支状态，领先/落后指示器

### 🎨 系统信息显示
**neofetch** - 系统信息展示工具
- **全面信息**: 操作系统、内核、shell、软件包、内存
- **可定制**: 精美 ASCII 艺术，彩色主题
- **性能信息**: 硬件规格，运行时间显示
- **跨平台**: 在所有支持的系统上工作

## 🔧 可用命令

| 命令 | 用途 |
|------|------|
| `make install` | 安装软件包 + 应用配置 |
| `make apply` | 仅应用配置（智能跨平台） |
| `make update` | 将本地配置同步回仓库 |
| `make uninstall` | 卸载配置并恢复备份 |
| `make test` | 测试配置文件有效性 |
| `make clean` | 清理临时文件和备份 |

## 💡 核心功能

### 智能平台适配
- 自动检测 shell 路径（`/usr/bin/fish` vs `/usr/local/bin/fish`）
- 平台特定剪贴板工具（macOS 使用 `pbcopy`，Linux 使用 `xclip`）
- 处理符号链接和文件权限
- 智能包管理器检测（dnf/apt/pacman/brew）

### 配置亮点功能

#### 🎯 tmux 高级特性
- **增强导航**: Vim 风格按键 + 鼠标支持 + 智能布局
- **剪贴板魔法**: 跨平台无缝系统剪贴板集成
- **视觉反馈**: 实时状态栏显示系统指标
- **会话持久**: 终端启动时自动恢复 tmux 会话
- **快速操作**: F1 帮助覆盖层，窗格同步，布局切换

#### 🐠 fish Shell 优化
- **智能自启**: 在 Alacritty 终端中自动启动 tmux
- **增强 PATH**: 跨平台二进制检测和优先级设置
- **别名与函数**: 预配置常用操作快捷方式
- **交互体验**: 禁用问候语，启用建议功能

#### 🎨 视觉与主题集成
- **一致主题**: Tokyo Night（Alacritty）+ Gruvbox Dark（Starship）
- **字体集成**: Nerd Fonts 支持，正确图标渲染
- **透明效果**: 微妙背景模糊和透明度
- **色彩协调**: 所有工具间统一的配色方案

## 🌟 支持系统

| 操作系统 | 状态 |
|----------|------|
| macOS (Intel/Apple Silicon) | ✅ 完全支持 |
| Fedora/RHEL/CentOS | ✅ 完全支持 |
| Ubuntu/Debian | ✅ 完全支持 |
| Arch Linux | ✅ 完全支持 |

## 🔄 配置同步工作流

### 修改配置后同步
```bash
cd ~/.dotfiles
make update    # 更新配置到仓库
git add .
git commit -m "更新配置"
git push
```

### 获取最新配置
```bash
git pull       # 获取最新配置
make apply     # 应用到本地
```

## 🛠️ 故障排查

### 重新加载配置
```bash
tmux source-file ~/.tmux.conf
exec fish
```

### 重新安装
```bash
cd dotfiles-sync
./install.sh
```

## 📖 文档

- [English Documentation](README.md) - 英文文档
- 各目录下有配置示例

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT 许可证 