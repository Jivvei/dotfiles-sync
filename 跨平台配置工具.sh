#!/bin/bash

# 跨平台配置工具
# 解决 macOS 只读文件系统和不同平台 shell 路径差异问题

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}[信息]${NC} $1"; }
log_success() { echo -e "${GREEN}[成功]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1"; }

# 检测系统类型
detect_system() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 智能检测最佳 shell 路径
detect_smart_shell_path() {
    local shell_name="$1"
    
    case "$shell_name" in
        "fish")
            # 优先级：用户本地软链接 > Homebrew > 系统默认
            local paths=(
                "$HOME/.local/bin/fish"
                "/usr/local/bin/fish"      # Intel Mac Homebrew
                "/opt/homebrew/bin/fish"   # Apple Silicon Homebrew  
                "/usr/bin/fish"            # 系统默认
                "/bin/fish"
            )
            ;;
        "zsh")
            local paths=(
                "/usr/local/bin/zsh"
                "/opt/homebrew/bin/zsh"
                "/usr/bin/zsh"
                "/bin/zsh"
            )
            ;;
        "bash")
            local paths=(
                "/usr/local/bin/bash"
                "/opt/homebrew/bin/bash"
                "/usr/bin/bash"
                "/bin/bash"
            )
            ;;
    esac
    
    # 查找第一个存在且可执行的路径
    for path in "${paths[@]}"; do
        if [ -x "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    # 如果都不存在，使用 which 命令
    if command_exists "$shell_name"; then
        which "$shell_name"
    else
        echo "/bin/sh"  # 最后的备选方案
    fi
}

# 创建软链接以提高兼容性（避免只读文件系统问题）
create_cross_platform_symlinks() {
    local system=$(detect_system)
    
    log_info "设置跨平台软链接..."
    
    if [[ "$system" == "macos" ]]; then
        # 创建用户本地 bin 目录
        mkdir -p "$HOME/.local/bin"
        
        # 为 fish 创建软链接
        if command_exists fish; then
            local fish_path=$(which fish)
            if [[ "$fish_path" == "/usr/local/bin/fish" || "$fish_path" == "/opt/homebrew/bin/fish" ]]; then
                if [ ! -e "$HOME/.local/bin/fish" ]; then
                    ln -sf "$fish_path" "$HOME/.local/bin/fish"
                    log_success "已创建 fish 软链接: ~/.local/bin/fish -> $fish_path"
                fi
            fi
        fi
        
        # 确保 ~/.local/bin 在 PATH 中
        setup_local_bin_path
    fi
}

# 设置用户本地 bin 路径
setup_local_bin_path() {
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        log_info "将 ~/.local/bin 添加到 PATH..."
        export PATH="$HOME/.local/bin:$PATH"
        
        # 添加到各种 shell 配置文件
        local shell_configs=(
            "$HOME/.bashrc"
            "$HOME/.zshrc" 
            "$HOME/.profile"
            "$HOME/.bash_profile"
        )
        
        for shell_rc in "${shell_configs[@]}"; do
            if [ -f "$shell_rc" ]; then
                if ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$shell_rc"; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
                    log_info "已添加 PATH 设置到 $(basename "$shell_rc")"
                fi
            fi
        done
        
        # 如果存在 fish 配置，也添加到 fish
        if [ -f "$HOME/.config/fish/config.fish" ]; then
            if ! grep -q "set -gx PATH \$HOME/.local/bin \$PATH" "$HOME/.config/fish/config.fish" 2>/dev/null; then
                echo 'set -gx PATH $HOME/.local/bin $PATH' >> "$HOME/.config/fish/config.fish"
                log_info "已添加 PATH 设置到 fish 配置"
            fi
        fi
    fi
}

# 更新 alacritty 配置中的 shell 路径
update_alacritty_shell() {
    local config_file="${1:-$HOME/.config/alacritty/alacritty.toml}"
    local preferred_shell="${2:-fish}"
    
    if [ ! -f "$config_file" ]; then
        log_error "配置文件不存在: $config_file"
        return 1
    fi
    
    local shell_path=$(detect_smart_shell_path "$preferred_shell")
    log_info "更新 alacritty 配置中的 shell 路径: $shell_path"
    
    # 创建备份
    cp "$config_file" "$config_file.bak.$(date +%Y%m%d_%H%M%S)"
    
    # 使用 sed 替换 shell 路径 - 支持不同的配置格式
    if grep -q "^shell = " "$config_file"; then
        # 新格式: shell = "/path/to/shell"
        if [[ "$(detect_system)" == "macos" ]]; then
            sed -i '' "s|^shell = .*|shell = \"$shell_path\"|g" "$config_file"
        else
            sed -i "s|^shell = .*|shell = \"$shell_path\"|g" "$config_file"
        fi
    elif grep -q "^\[terminal\]" "$config_file"; then
        # 老格式: [terminal] 部分
        if [[ "$(detect_system)" == "macos" ]]; then
            sed -i '' "/^\[terminal\]/,/^\[/ s|shell = .*|shell = \"$shell_path\"|" "$config_file"
        else
            sed -i "/^\[terminal\]/,/^\[/ s|shell = .*|shell = \"$shell_path\"|" "$config_file"
        fi
    else
        log_warn "未找到 shell 配置项，需要手动添加"
        return 1
    fi
    
    log_success "已更新 alacritty shell 路径"
}

# 更新 tmux 配置中的 shell 设置
update_tmux_shell() {
    local config_file="${1:-$HOME/.tmux.conf}"
    local preferred_shell="${2:-fish}"
    
    if [ ! -f "$config_file" ]; then
        log_error "配置文件不存在: $config_file"
        return 1
    fi
    
    local shell_path=$(detect_smart_shell_path "$preferred_shell")
    log_info "更新 tmux 配置中的 shell 路径: $shell_path"
    
    # 创建备份
    cp "$config_file" "$config_file.bak.$(date +%Y%m%d_%H%M%S)"
    
    # 替换 default-shell 设置
    if [[ "$(detect_system)" == "macos" ]]; then
        sed -i '' "s|set-option -g default-shell.*|set-option -g default-shell \"$shell_path\"|g" "$config_file"
    else
        sed -i "s|set-option -g default-shell.*|set-option -g default-shell \"$shell_path\"|g" "$config_file"
    fi
    
    log_success "已更新 tmux shell 路径"
}

# 一键修复所有配置文件
fix_all_configs() {
    local preferred_shell="${1:-fish}"
    
    log_info "开始修复所有配置文件的 shell 路径..."
    
    # 创建软链接
    create_cross_platform_symlinks
    
    # 更新 alacritty 配置
    if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
        update_alacritty_shell "$HOME/.config/alacritty/alacritty.toml" "$preferred_shell"
    fi
    
    # 更新 tmux 配置
    if [ -f "$HOME/.tmux.conf" ]; then
        update_tmux_shell "$HOME/.tmux.conf" "$preferred_shell"
    fi
    
    log_success "所有配置文件修复完成！"
    echo
    log_info "建议操作："
    echo "  1. 重新启动终端应用"
    echo "  2. 运行 'tmux kill-server' 重启所有 tmux 会话"
    echo "  3. 重新打开 alacritty"
}

# 显示当前系统信息
show_system_info() {
    echo "=== 系统信息 ==="
    echo "系统类型: $(detect_system)"
    echo "当前 Shell: $SHELL"
    echo
    
    echo "=== Shell 路径检测 ==="
    for shell in fish zsh bash; do
        if command_exists "$shell"; then
            echo "$shell: $(detect_smart_shell_path "$shell")"
        else
            echo "$shell: 未安装"
        fi
    done
    echo

    echo "=== PATH 信息 ==="
    echo "$PATH" | tr ':' '\n' | head -5
    echo
}

# 主函数
main() {
    local action="$1"
    local target="$2" 
    local shell_type="${3:-fish}"
    
    case "$action" in
        "info"|"检测")
            show_system_info
            ;;
        "symlink"|"软链接")
            create_cross_platform_symlinks
            ;;
        "alacritty")
            local config_path="${target:-$HOME/.config/alacritty/alacritty.toml}"
            update_alacritty_shell "$config_path" "$shell_type"
            ;;
        "tmux")
            local config_path="${target:-$HOME/.tmux.conf}"
            update_tmux_shell "$config_path" "$shell_type"
            ;;
        "fix"|"修复")
            fix_all_configs "$shell_type"
            ;;
        "help"|"帮助"|*)
            cat << EOF
跨平台配置工具 - 解决 shell 路径兼容性问题

用法: $0 <action> [options]

Actions:
  info, 检测         - 显示系统和 shell 信息
  symlink, 软链接    - 创建跨平台软链接（解决 macOS 只读文件系统问题）
  alacritty [路径]   - 更新 alacritty 配置中的 shell 路径
  tmux [路径]        - 更新 tmux 配置中的 shell 路径  
  fix, 修复 [shell]  - 一键修复所有配置文件
  help, 帮助         - 显示此帮助信息

Shell Types:
  fish (默认)        - Fish shell
  zsh               - Z shell  
  bash              - Bash shell

示例:
  $0 info                                    # 查看系统信息
  $0 symlink                                 # 创建软链接
  $0 fix fish                                # 修复所有配置使用 fish
  $0 alacritty ~/.config/alacritty/alacritty.toml fish
  $0 tmux ~/.tmux.conf zsh

说明:
  此工具通过创建用户本地软链接（~/.local/bin/）来解决 macOS 系统级目录
  只读的问题，同时提供跨平台的 shell 路径兼容性。
EOF
            ;;
    esac
}

# 执行主函数
main "$@" 