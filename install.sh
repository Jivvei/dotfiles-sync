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
    if [ -f "tmux/.tmux.conf" ]; then
        cp "tmux/.tmux.conf" "$HOME/"
        log_success "安装 tmux 配置"
    fi
    
    # 安装 alacritty 配置
    if [ -d "alacritty" ]; then
        mkdir -p "$HOME/.config/alacritty"
        cp -r alacritty/* "$HOME/.config/alacritty/"
        log_success "安装 alacritty 配置"
    fi
    
    # 安装 fish 配置
    if [ -d "fish" ]; then
        mkdir -p "$HOME/.config/fish"
        cp -r fish/* "$HOME/.config/fish/"
        log_success "安装 fish 配置"
    fi
    
    # 安装 starship 配置
    if [ -f "starship/starship.toml" ]; then
        cp "starship/starship.toml" "$HOME/.config/"
        log_success "安装 starship 配置"
    fi
    
    # 安装 neofetch 配置
    if [ -d "neofetch" ] && [ "$(ls -A neofetch 2>/dev/null)" ]; then
        mkdir -p "$HOME/.config/neofetch"
        cp -r neofetch/* "$HOME/.config/neofetch/"
        log_success "安装 neofetch 配置"
    fi
}

# 设置默认 shell
setup_fish_shell() {
    if command_exists fish; then
        FISH_PATH=$(which fish)
        
        # 检查 fish 是否在 /etc/shells 中
        if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
            log_info "将 fish 添加到 /etc/shells..."
            echo "$FISH_PATH" | sudo tee -a /etc/shells
        fi
        
        # 询问是否设置 fish 为默认 shell
        echo
        read -p "是否将 Fish 设置为默认 shell？ (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "设置 fish 为默认 shell..."
            chsh -s "$FISH_PATH"
            log_success "已设置 fish 为默认 shell（重新登录后生效）"
        fi
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