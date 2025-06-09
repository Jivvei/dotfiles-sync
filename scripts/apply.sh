#!/bin/bash

# 跨平台配置文件应用脚本
# 支持智能平台检测和配置适配
# 使用方法: ./apply.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# 检测系统类型
detect_system() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SYSTEM="macos"
        log_info "检测到 macOS 系统"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v dnf >/dev/null 2>&1; then
            SYSTEM="fedora"
        elif command -v apt >/dev/null 2>&1; then
            SYSTEM="ubuntu"
        elif command -v pacman >/dev/null 2>&1; then
            SYSTEM="arch"
        else
            SYSTEM="linux"
        fi
        log_info "检测到 Linux 系统: $SYSTEM"
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
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
            copy_cmd="cat"
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
            copy_cmd="cat"
            paste_cmd="echo ''"
        fi
    fi
    
    # 导出供其他函数使用
    export CLIPBOARD_COPY_CMD="$copy_cmd"
    export CLIPBOARD_PASTE_CMD="$paste_cmd"
}

# 应用 tmux 配置
apply_tmux() {
    log_step "应用 tmux 配置..."
    
    if [ ! -f "config/tmux/.tmux.conf" ]; then
        log_error "tmux 配置文件不存在"
        return 1
    fi
    
    # 备份现有配置
    if [ -e "$HOME/.tmux.conf" ]; then
        if [ -L "$HOME/.tmux.conf" ]; then
            # 如果是符号链接，备份目标文件
            TARGET=$(readlink "$HOME/.tmux.conf")
            if [ -f "$TARGET" ]; then
                cp "$TARGET" "$HOME/.tmux.conf.backup.$(date +%Y%m%d-%H%M%S)"
                log_info "已备份符号链接指向的 tmux 配置"
            fi
            rm "$HOME/.tmux.conf"
            log_info "已移除 tmux 配置符号链接"
        else
            cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d-%H%M%S)"
            log_info "已备份现有 tmux 配置"
        fi
    fi
    
    # 复制新配置
    cp "config/tmux/.tmux.conf" "$HOME/"
    
    # 智能配置适配
    if command_exists fish; then
        OPTIMAL_FISH_PATH=$(detect_smart_shell_path "fish")
        if [[ "$SYSTEM" == "macos" ]]; then
            sed -i "" "s|FISH_PATH_PLACEHOLDER|$OPTIMAL_FISH_PATH|g" "$HOME/.tmux.conf"
        else
            sed -i "s|FISH_PATH_PLACEHOLDER|$OPTIMAL_FISH_PATH|g" "$HOME/.tmux.conf"
        fi
        log_success "✅ 已设置 fish shell 路径: $OPTIMAL_FISH_PATH"
    else
        DEFAULT_SHELL=$(echo "$SHELL")
        if [[ "$SYSTEM" == "macos" ]]; then
            sed -i "" "s|FISH_PATH_PLACEHOLDER|$DEFAULT_SHELL|g" "$HOME/.tmux.conf"
        else
            sed -i "s|FISH_PATH_PLACEHOLDER|$DEFAULT_SHELL|g" "$HOME/.tmux.conf"
        fi
        log_warning "⚠️ 未找到 fish，使用默认 shell: $DEFAULT_SHELL"
    fi
    
    # 配置剪贴板工具
    if [[ "$SYSTEM" == "macos" ]]; then
        sed -i "" "s|CLIPBOARD_COPY_PLACEHOLDER|$CLIPBOARD_COPY_CMD|g" "$HOME/.tmux.conf"
        sed -i "" "s|CLIPBOARD_PASTE_PLACEHOLDER|$CLIPBOARD_PASTE_CMD|g" "$HOME/.tmux.conf"
    else
        sed -i "s|CLIPBOARD_COPY_PLACEHOLDER|$CLIPBOARD_COPY_CMD|g" "$HOME/.tmux.conf"
        sed -i "s|CLIPBOARD_PASTE_PLACEHOLDER|$CLIPBOARD_PASTE_CMD|g" "$HOME/.tmux.conf"
    fi
    
    # 复制脚本和插件
    if [ -d "tmux/scripts" ]; then
        mkdir -p "$HOME/.tmux"
        cp -r tmux/scripts "$HOME/.tmux/"
        chmod +x "$HOME/.tmux/scripts/"*.sh
        log_info "应用 tmux 脚本文件"
    fi
    
    if [ -d "tmux/plugins" ]; then
        mkdir -p "$HOME/.tmux"
        cp -r tmux/plugins "$HOME/.tmux/"
        log_info "应用 tmux 插件"
    fi
    
    # 清理临时文件
    rm -f "$HOME/.tmux.conf.tmp"
    
    log_success "tmux 配置应用完成"
}

# 应用其他配置
apply_alacritty() {
    log_step "应用 alacritty 配置..."
    
    if [ ! -d "alacritty" ]; then
        log_warning "alacritty 配置目录不存在，跳过"
        return
    fi
    
    mkdir -p "$HOME/.config/alacritty"
    
    # 备份现有配置
    if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
        cp "$HOME/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml.backup.$(date +%Y%m%d-%H%M%S)"
        log_info "已备份现有 alacritty 配置"
    fi
    
    cp -r alacritty/* "$HOME/.config/alacritty/"
    
    # 智能配置 shell 路径
    if [ -f "$HOME/.config/alacritty/alacritty.toml" ] && command_exists fish; then
        OPTIMAL_FISH_PATH=$(detect_smart_shell_path "fish")
        if [[ "$SYSTEM" == "macos" ]]; then
            sed -i "" "s|shell = \".*\"|shell = \"$OPTIMAL_FISH_PATH\"|g" "$HOME/.config/alacritty/alacritty.toml"
        else
            sed -i "s|shell = \".*\"|shell = \"$OPTIMAL_FISH_PATH\"|g" "$HOME/.config/alacritty/alacritty.toml"
        fi
        log_success "已配置 alacritty 的 shell 路径"
    fi
    
    log_success "alacritty 配置应用完成"
}

apply_fish() {
    log_step "应用 fish 配置..."
    
    if [ ! -d "fish" ]; then
        log_warning "fish 配置目录不存在，跳过"
        return
    fi
    
    mkdir -p "$HOME/.config/fish"
    
    # 备份现有配置
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        cp "$HOME/.config/fish/config.fish" "$HOME/.config/fish/config.fish.backup.$(date +%Y%m%d-%H%M%S)"
        log_info "已备份现有 fish 配置"
    fi
    
    cp -r fish/* "$HOME/.config/fish/"
    log_success "fish 配置应用完成"
}

apply_starship() {
    log_step "应用 starship 配置..."
    
    if [ ! -f "config/starship/starship.toml" ]; then
        log_warning "starship 配置文件不存在，跳过"
        return
    fi
    
    # 确保目录存在
    mkdir -p "$HOME/.config"
    
    # 备份现有配置
    if [ -f "$HOME/.config/starship.toml" ]; then
        cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.backup.$(date +%Y%m%d-%H%M%S)"
        log_info "已备份现有 starship 配置"
    fi
    
    cp "config/starship/starship.toml" "$HOME/.config/"
    log_success "starship 配置应用完成"
}

# 重新加载配置
reload_configs() {
    log_step "重新加载配置..."
    
    # 重新加载 tmux
    if pgrep -x tmux >/dev/null; then
        tmux source-file ~/.tmux.conf 2>/dev/null && log_success "tmux 配置已重新加载" || log_warning "tmux 配置重新加载失败"
    else
        log_info "tmux 未运行，配置将在下次启动时生效"
    fi
    
    # fish 配置会在下次启动时自动加载
    if command_exists fish; then
        log_info "fish 配置将在下次启动时生效"
    fi
}

# 显示帮助信息
show_help() {
    echo "🔧 跨平台配置文件应用脚本"
    echo ""
    echo "使用方法: ./apply.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -t, --tmux     仅应用 tmux 配置"
    echo "  -a, --alacritty 仅应用 alacritty 配置"
    echo "  -f, --fish     仅应用 fish 配置"
    echo "  -s, --starship 仅应用 starship 配置"
    echo "  -r, --reload   应用后重新加载配置"
    echo "  --force        强制应用（跳过确认）"
    echo ""
    echo "示例:"
    echo "  ./apply.sh              # 交互式应用所有配置"
    echo "  ./apply.sh -t           # 仅应用 tmux 配置"
    echo "  ./apply.sh -t -r        # 应用 tmux 并重新加载"
    echo "  ./apply.sh --force      # 强制应用所有配置"
    echo ""
    echo "🌍 支持的系统:"
    echo "  - macOS (Intel/Apple Silicon)"
    echo "  - Linux (Fedora/Ubuntu/Arch)"
    echo ""
    echo "🎯 智能适配特性:"
    echo "  - 自动检测 shell 路径"
    echo "  - 自动选择剪贴板工具"
    echo "  - 跨平台兼容性配置"
    echo ""
}

# 主函数
main() {
    local apply_tmux_only=false
    local apply_alacritty_only=false
    local apply_fish_only=false
    local apply_starship_only=false
    local reload_after_apply=false
    local force_apply=false
    local specific_config=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -t|--tmux)
                apply_tmux_only=true
                specific_config=true
                shift
                ;;
            -a|--alacritty)
                apply_alacritty_only=true
                specific_config=true
                shift
                ;;
            -f|--fish)
                apply_fish_only=true
                specific_config=true
                shift
                ;;
            -s|--starship)
                apply_starship_only=true
                specific_config=true
                shift
                ;;
            -r|--reload)
                reload_after_apply=true
                shift
                ;;
            --force)
                force_apply=true
                shift
                ;;
            *)
                log_error "未知参数: $1"
                echo "使用 -h 查看帮助信息"
                exit 1
                ;;
        esac
    done
    
    echo "🔧 跨平台配置文件应用工具"
    echo "================================"
    
    # 检测系统
    detect_system
    
    # 配置剪贴板工具
    configure_clipboard_tools
    
    # 确认应用
    if [[ "$force_apply" != true ]]; then
        echo ""
        if [[ "$specific_config" == true ]]; then
            read -p "确定要应用选定的配置吗？[y/N]: " confirm
        else
            read -p "确定要应用所有配置吗？[y/N]: " confirm
        fi
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "取消应用"
            exit 0
        fi
    fi
    
    echo ""
    log_step "开始应用配置..."
    
    # 应用配置
    if [[ "$specific_config" == true ]]; then
        [[ "$apply_tmux_only" == true ]] && apply_tmux
        [[ "$apply_alacritty_only" == true ]] && apply_alacritty
        [[ "$apply_fish_only" == true ]] && apply_fish
        [[ "$apply_starship_only" == true ]] && apply_starship
    else
        apply_tmux
        apply_alacritty
        apply_fish
        apply_starship
    fi
    
    # 重新加载
    if [[ "$reload_after_apply" == true ]]; then
        reload_configs
    fi
    
    echo ""
    log_success "🎉 配置应用完成！"
    
    # 显示后续步骤
    echo ""
    echo "📝 后续步骤:"
    echo "   - 重启终端或重新加载配置"
    echo "   - 检查各工具是否正常工作"
    echo "   - 根据需要调整个人偏好设置"
    
    if pgrep -x tmux >/dev/null; then
        echo "   - 重新加载 tmux: tmux source-file ~/.tmux.conf"
    fi
    
    echo ""
    echo "🔍 验证配置:"
    echo "   - tmux: 启动 tmux 并测试快捷键"
    echo "   - alacritty: 检查终端外观和功能"
    echo "   - fish: 检查 shell 提示和自动补全"
    echo "   - starship: 检查命令行提示符样式"
}

# 运行主函数
main "$@" 