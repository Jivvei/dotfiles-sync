#!/bin/bash

# 跨平台配置文件同步安装脚本
# 支持: Linux (Fedora/Ubuntu/Arch) 和 macOS
# 使用方法: ./install.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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

# 检测系统类型
detect_system() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SYSTEM="macos"
        log_info "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v dnf >/dev/null 2>&1; then
            SYSTEM="fedora"
            PACKAGE_MANAGER="dnf"
            INSTALL_CMD="sudo dnf install -y"
            log_info "检测到 Fedora/RHEL/CentOS 系统"
        elif command -v apt >/dev/null 2>&1; then
            SYSTEM="ubuntu"
            PACKAGE_MANAGER="apt"
            INSTALL_CMD="sudo apt install -y"
            log_info "检测到 Ubuntu/Debian 系统"
        elif command -v pacman >/dev/null 2>&1; then
            SYSTEM="arch"
            PACKAGE_MANAGER="pacman"
            INSTALL_CMD="sudo pacman -S --noconfirm"
            log_info "检测到 Arch Linux 系统"
        else
            log_error "不支持的 Linux 发行版"
            exit 1
        fi
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
# 检查 macOS 应用是否安装
macos_app_exists() {
    case "$1" in
        "alacritty")
            [ -d "/Applications/Alacritty.app" ] || command_exists alacritty
            ;;
        *)
            command_exists "$1"
            ;;
    esac
}

# 安装软件包
install_packages() {
    log_info "开始安装必需的软件..."
    
    if [[ "$SYSTEM" == "macos" ]]; then
        # macOS 使用 Homebrew
        if ! command_exists brew; then
            log_info "安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # 更新 Homebrew
        log_info "更新 Homebrew..."
        brew update
        
        # 安装软件包
        PACKAGES="tmux alacritty fish starship neofetch git"
        for package in $PACKAGES; do
            if ! macos_app_exists "$package"; then
                log_info "安装 $package..."
                if [[ "$package" == "alacritty" ]]; then
                    brew install --cask alacritty
                else
                    brew install "$package"
                fi
                log_success "已安装 $package"
            else
                log_warning "$package 已安装，跳过"
            fi
        done
        
    elif [[ "$SYSTEM" == "fedora" ]]; then
        # 更新软件包列表
        log_info "更新软件包列表..."
        sudo dnf check-update || true
        
        # 安装软件包
        PACKAGES="tmux alacritty fish starship neofetch git util-linux-user"
        for package in $PACKAGES; do
            if ! rpm -q "$package" >/dev/null 2>&1; then
                log_info "安装 $package..."
                $INSTALL_CMD "$package"
                log_success "已安装 $package"
            else
                log_warning "$package 已安装，跳过"
            fi
        done
        
    elif [[ "$SYSTEM" == "ubuntu" ]]; then
        # 更新软件包列表
        log_info "更新软件包列表..."
        sudo apt update
        
        # 安装软件包
        PACKAGES="tmux alacritty fish neofetch git curl"
        for package in $PACKAGES; do
            if ! dpkg -l | grep -q "^ii.*$package "; then
                log_info "安装 $package..."
                $INSTALL_CMD "$package"
                log_success "已安装 $package"
            else
                log_warning "$package 已安装，跳过"
            fi
        done
        
        # Ubuntu 需要单独安装 starship
        if ! command_exists starship; then
            log_info "安装 starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            log_success "已安装 starship"
        fi
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        # 更新软件包列表
        log_info "更新软件包列表..."
        sudo pacman -Sy
        
        # 安装软件包
        PACKAGES="tmux alacritty fish starship neofetch git"
        for package in $PACKAGES; do
            if ! pacman -Q "$package" >/dev/null 2>&1; then
                log_info "安装 $package..."
                $INSTALL_CMD "$package"
                log_success "已安装 $package"
            else
                log_warning "$package 已安装，跳过"
            fi
        done
    fi
    
    log_success "所有必需软件安装完成！"
}

# 备份现有配置
backup_configs() {
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    log_info "备份现有配置到 $BACKUP_DIR"
    
    # 备份现有配置
    if [ -f "$HOME/.tmux.conf" ]; then
        cp "$HOME/.tmux.conf" "$BACKUP_DIR/"
        log_success "备份 tmux 配置"
    fi
    
    if [ -d "$HOME/.config/alacritty" ]; then
        cp -r "$HOME/.config/alacritty" "$BACKUP_DIR/"
        log_success "备份 alacritty 配置"
    fi
    
    if [ -d "$HOME/.config/fish" ]; then
        cp -r "$HOME/.config/fish" "$BACKUP_DIR/"
        log_success "备份 fish 配置"
    fi
    
    if [ -f "$HOME/.config/starship.toml" ]; then
        cp "$HOME/.config/starship.toml" "$BACKUP_DIR/"
        log_success "备份 starship 配置"
    fi
    
    if [ -d "$HOME/.config/neofetch" ]; then
        cp -r "$HOME/.config/neofetch" "$BACKUP_DIR/"
        log_success "备份 neofetch 配置"
    fi
    
    echo "BACKUP_DIR=$BACKUP_DIR" > .last_backup
}

# 安装配置文件
install_configs() {
    log_info "开始安装配置文件..."
    
    # 安装 tmux 配置
    if [ -f "config/tmux/.tmux.conf" ]; then
        cp "config/tmux/.tmux.conf" "$HOME/"
        
        # 安装 tmux 脚本和插件
        if [ -d "config/tmux/scripts" ]; then
            mkdir -p "$HOME/.tmux"
            cp -r config/tmux/scripts "$HOME/.tmux/"
            chmod +x "$HOME/.tmux/scripts/"*.sh
            log_info "安装 tmux 脚本文件"
        fi
        
        if [ -d "config/tmux/plugins" ]; then
            mkdir -p "$HOME/.tmux"
            cp -r config/tmux/plugins "$HOME/.tmux/"
            log_info "安装 tmux 插件"
        fi
        
        # 智能配置 tmux 以适应不同操作系统
        configure_tmux_for_platform
        
        log_success "安装 tmux 配置"
    fi
    
    # 安装 alacritty 配置  
    if [ -d "config/alacritty" ]; then
        mkdir -p "$HOME/.config/alacritty"
        cp -r config/alacritty/* "$HOME/.config/alacritty/"
        
        # 动态调整 alacritty 中的 shell 路径
        if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
            if command_exists fish; then
                OPTIMAL_FISH_PATH=$(detect_smart_shell_path "fish")
                # 替换 [terminal] 部分的 shell 设置
                if [[ "$SYSTEM" == "macos" ]]; then
                    sed -i "" "s|shell = \".*\"|shell = \"$OPTIMAL_FISH_PATH\"|g" "$HOME/.config/alacritty/alacritty.toml"
                else
                    sed -i "s|shell = \".*\"|shell = \"$OPTIMAL_FISH_PATH\"|g" "$HOME/.config/alacritty/alacritty.toml"
                fi
                log_info "已调整 alacritty 中的 shell 路径: $OPTIMAL_FISH_PATH"
            fi
        fi
        
        log_success "安装 alacritty 配置"
    fi
    
    # 安装 fish 配置
    if [ -d "config/fish" ]; then
        mkdir -p "$HOME/.config/fish"
        cp -r config/fish/* "$HOME/.config/fish/"
        log_success "安装 fish 配置"
    fi
    
    # 安装 starship 配置
    if [ -f "config/starship/starship.toml" ]; then
        cp "config/starship/starship.toml" "$HOME/.config/"
        log_success "安装 starship 配置"
    fi
    
    # 安装 neofetch 配置
    if [ -d "config/neofetch" ] && [ "$(ls -A config/neofetch 2>/dev/null)" ]; then
        mkdir -p "$HOME/.config/neofetch"
        cp -r config/neofetch/* "$HOME/.config/neofetch/"
        log_success "安装 neofetch 配置"
    fi
}

# 设置默认 shell
setup_fish_shell() {
    if command_exists fish; then
        FISH_PATH=$(which fish)
        
        # 跨平台软链接支持：创建用户本地软链接以避免只读文件系统问题
        if [[ "$SYSTEM" == "macos" ]] && [[ "$FISH_PATH" == "/usr/local/bin/fish" || "$FISH_PATH" == "/opt/homebrew/bin/fish" ]]; then
            # 创建用户本地 bin 目录
            mkdir -p "$HOME/.local/bin"
            
            # 在用户本地目录创建软链接，提供标准路径兼容
            if [ ! -e "$HOME/.local/bin/fish" ]; then
                log_info "创建 fish 软链接以提高跨平台兼容性..."
                ln -sf "$FISH_PATH" "$HOME/.local/bin/fish"
                log_success "已创建 ~/.local/bin/fish -> $FISH_PATH"
            fi
            
            # 确保 ~/.local/bin 在 PATH 中
            setup_local_bin_path
        fi
        
        # 检查 fish 是否在 /etc/shells 中
        if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
            log_info "将 fish 添加到 /etc/shells..."
            echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
        fi
        
        # 如果创建了用户本地软链接，也添加到 /etc/shells
        if [ -L "$HOME/.local/bin/fish" ] && ! grep -q "$HOME/.local/bin/fish" /etc/shells 2>/dev/null; then
            echo "$HOME/.local/bin/fish" | sudo tee -a /etc/shells >/dev/null
        fi
        
        # 询问是否设置 fish 为默认 shell
        if [[ "$CURRENT_SHELL" != *"fish"* ]]; then
            echo
            log_info "检测到当前 shell: $CURRENT_SHELL"
            read -p "是否设置 fish 为默认 shell？[y/N]: " set_fish
            if [[ "$set_fish" =~ ^[Yy]$ ]]; then
                if chsh -s "$FISH_PATH" 2>/dev/null; then
                    log_success "已设置 fish 为默认 shell"
                    log_info "请重新登录以生效"
                else
                    log_warn "设置默认 shell 失败，请手动运行: chsh -s $FISH_PATH"
                fi
            fi
        fi
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
            if ! grep -q "set -gx PATH \$HOME/.local/bin \$PATH" "$HOME/.config/fish/config.fish"; then
                echo 'set -gx PATH $HOME/.local/bin $PATH' >> "$HOME/.config/fish/config.fish"
                log_info "已添加 PATH 设置到 fish 配置"
            fi
        fi
    fi
}

# 配置 tmux 以适应不同平台
configure_tmux_for_platform() {
    if [ ! -f "$HOME/.tmux.conf" ]; then
        log_warning "tmux 配置文件不存在，跳过平台适配"
        return
    fi
    
    log_info "开始配置 tmux 跨平台适配..."
    
    # 1. 配置 Shell 路径
    if command_exists fish; then
        OPTIMAL_FISH_PATH=$(detect_smart_shell_path "fish")
        if [[ "$SYSTEM" == "macos" ]]; then
            sed -i "" "s|FISH_PATH_PLACEHOLDER|$OPTIMAL_FISH_PATH|g" "$HOME/.tmux.conf"
        else
            sed -i "s|FISH_PATH_PLACEHOLDER|$OPTIMAL_FISH_PATH|g" "$HOME/.tmux.conf"
        fi
        log_success "✅ 已设置 fish shell 路径: $OPTIMAL_FISH_PATH"
    else
        # 如果没有 fish，使用默认 shell
        DEFAULT_SHELL=$(echo "$SHELL")
        if [[ "$SYSTEM" == "macos" ]]; then
            sed -i "" "s|FISH_PATH_PLACEHOLDER|$DEFAULT_SHELL|g" "$HOME/.tmux.conf"
        else
            sed -i "s|FISH_PATH_PLACEHOLDER|$DEFAULT_SHELL|g" "$HOME/.tmux.conf"
        fi
        log_warning "⚠️ 未找到 fish，使用默认 shell: $DEFAULT_SHELL"
    fi
    
    # 2. 配置剪贴板工具
    configure_clipboard_tools
    
    # 3. 配置终端特性
    configure_terminal_features
    
    # 4. 清理备份文件
    rm -f "$HOME/.tmux.conf.bak"
    
    log_success "🎯 tmux 平台适配配置完成"
}

# 配置剪贴板工具
configure_clipboard_tools() {
    local copy_cmd=""
    local paste_cmd=""
    
    if [[ "$SYSTEM" == "macos" ]]; then
        if command_exists pbcopy && command_exists pbpaste; then
            copy_cmd="pbcopy"
            paste_cmd="pbpaste"
            log_success "📋 检测到 macOS 剪贴板工具"
        else
            log_warning "⚠️ macOS 系统但未找到 pbcopy/pbpaste"
            copy_cmd="cat"  # 备用方案
            paste_cmd="echo ''"
        fi
    else
        # Linux 系统
        if command_exists xclip; then
            copy_cmd="xclip -in -selection clipboard"
            paste_cmd="xclip -o -sel clipboard"
            log_success "📋 检测到 Linux 剪贴板工具: xclip"
        elif command_exists xsel; then
            copy_cmd="xsel --clipboard --input"
            paste_cmd="xsel --clipboard --output"
            log_success "📋 检测到 Linux 剪贴板工具: xsel"
        else
            log_warning "⚠️ 未找到剪贴板工具，建议安装 xclip 或 xsel"
            copy_cmd="cat"  # 备用方案
            paste_cmd="echo ''"
        fi
    fi
    
    # 替换占位符
    if [[ "$SYSTEM" == "macos" ]]; then
        sed -i "" "s|CLIPBOARD_COPY_PLACEHOLDER|$copy_cmd|g" "$HOME/.tmux.conf"
        sed -i "" "s|CLIPBOARD_PASTE_PLACEHOLDER|$paste_cmd|g" "$HOME/.tmux.conf"
    else
        sed -i "s|CLIPBOARD_COPY_PLACEHOLDER|$copy_cmd|g" "$HOME/.tmux.conf"
        sed -i "s|CLIPBOARD_PASTE_PLACEHOLDER|$paste_cmd|g" "$HOME/.tmux.conf"
    fi
    
    log_info "已配置剪贴板: 复制($copy_cmd) 粘贴($paste_cmd)"
}

# 配置终端特性
configure_terminal_features() {
    # 根据终端类型优化配置
    if [[ "$TERM_PROGRAM" == "Alacritty" ]] || command_exists alacritty; then
        log_info "🖥️ 检测到 Alacritty 终端，启用优化配置"
        # 可以在这里添加 Alacritty 特定的优化
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]] || [[ "$TERM_PROGRAM" == "iTerm2" ]]; then
        log_info "🖥️ 检测到 iTerm2 终端"
    elif [[ "$TERM" == *"screen"* ]] || [[ "$TERM" == *"tmux"* ]]; then
        log_info "🖥️ 检测到嵌套 tmux/screen 环境"
    fi
    
    # 检测真彩色支持
    if [[ "$COLORTERM" == "truecolor" ]] || [[ "$COLORTERM" == "24bit" ]]; then
        log_info "🌈 检测到真彩色支持"
    fi
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
    if command -v "$shell_name" >/dev/null 2>&1; then
        which "$shell_name"
    else
        echo "/bin/sh"  # 最后的备选方案
    fi
}

# 安装字体
install_fonts() {
    echo
    read -p "是否安装 Nerd Fonts（推荐用于更好的显示效果）？ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "安装 Nerd Fonts..."
        
        if [[ "$SYSTEM" == "macos" ]]; then
            brew tap homebrew/cask-fonts
            brew install --cask font-fira-code-nerd-font
        else
            # Linux 系统
            FONT_DIR="$HOME/.local/share/fonts"
            mkdir -p "$FONT_DIR"
            
            cd /tmp
            wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
            unzip -q FiraCode.zip -d "$FONT_DIR/"
            rm FiraCode.zip
            
            # 更新字体缓存
            fc-cache -fv
        fi
        
        log_success "Nerd Fonts 安装完成"
    fi
}

# 验证安装
verify_installation() {
    log_info "验证安装..."
    
    TOOLS="tmux alacritty fish starship neofetch"
    ALL_OK=true
    
    for tool in $TOOLS; do
        if command_exists "$tool"; then
            log_success "$tool 安装成功"
        else
            log_error "$tool 安装失败"
            ALL_OK=false
        fi
    done
    
    if $ALL_OK; then
        log_success "所有工具安装验证通过！"
    else
        log_warning "部分工具安装可能有问题，请检查"
    fi
}

# 显示使用说明
show_usage() {
    echo
    echo "🎉 配置安装完成！"
    echo
    echo "🔄 使配置生效："
    echo "   - 重新打开终端，或者运行:"
    echo "   - tmux: tmux source-file ~/.tmux.conf"
    echo "   - fish: exec fish"
    echo
    echo "📚 快速开始："
    echo "   - 启动 tmux: tmux"
    echo "   - 打开 Alacritty 终端"
    echo "   - 查看系统信息: neofetch"
    echo
    echo "🔧 自定义配置："
    echo "   - tmux: ~/.tmux.conf"
    echo "   - alacritty: ~/.config/alacritty/alacritty.toml"
    echo "   - fish: ~/.config/fish/config.fish"
    echo "   - starship: ~/.config/starship.toml"
    echo
    if [ -f ".last_backup" ]; then
        source .last_backup
        echo "📁 原配置已备份到: $BACKUP_DIR"
    fi
}

# 主函数
main() {
    echo "🚀 跨平台配置文件同步安装脚本"
    echo "==============================="
    echo
    
    # 检测系统
    detect_system
    
    # 安装软件包
    install_packages
    
    # 备份配置
    backup_configs
    
    # 安装配置文件
    install_configs
    
    # 设置默认 shell
    setup_fish_shell
    
    # 安装字体
    install_fonts
    
    # 验证安装
    verify_installation
    
    # 显示使用说明
    show_usage
}

# 运行主函数
main "$@" 