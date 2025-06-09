# 🌍 跨平台配置文件管理工具

智能的跨平台终端环境配置管理工具。

## ✨ 特性

- **跨平台支持**: 支持 macOS、Fedora、Ubuntu、Arch Linux
- **智能检测**: 自动检测系统类型和工具路径
- **一键安装**: 自动化安装和配置
- **安全备份**: 自动备份现有配置

## 🚀 快速开始

```bash
# 克隆并安装
git clone <your-repo-url>
cd dotfiles-sync
./install.sh
```

或仅应用配置：
```bash
./apply.sh
```

## 📦 包含工具

- **tmux**: 终端复用器，增强快捷键
- **fish**: 现代化 shell，自动补全
- **alacritty**: GPU 加速终端模拟器
- **starship**: 跨 shell 命令提示符
- **neofetch**: 系统信息显示

## 🔧 可用脚本

| 脚本 | 用途 |
|------|------|
| `install.sh` | 安装软件包 + 应用配置 |
| `apply.sh` | 仅应用配置（智能跨平台） |
| `update.sh` | 将本地配置同步回仓库 |

## 💡 核心功能

### 智能平台适配
- 自动检测 shell 路径（`/usr/bin/fish` vs `/usr/local/bin/fish`）
- 平台特定剪贴板工具（macOS 使用 `pbcopy`，Linux 使用 `xclip`）
- 处理符号链接和文件权限

### Tmux 增强
- Vim 风格导航（`h/j/k/l`）
- 鼠标支持，智能复制粘贴
- 系统剪贴板集成
- 美观状态栏

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
cd dotfiles-sync
./update.sh    # 更新配置到仓库
git add .
git commit -m "更新配置"
git push
```

### 获取最新配置
```bash
git pull       # 获取最新配置
./apply.sh     # 应用到本地
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