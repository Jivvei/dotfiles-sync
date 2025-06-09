#!/bin/bash

# 一键部署脚本 - 自动克隆仓库并安装配置
# 使用方法: curl -fsSL https://raw.githubusercontent.com/你的用户名/dotfiles-sync/main/deploy.sh | bash
# 或者: bash <(wget -qO- https://raw.githubusercontent.com/你的用户名/dotfiles-sync/main/deploy.sh)

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

# 配置
REPO_URL="https://github.com/你的用户名/dotfiles-sync.git"  # 请替换为你的仓库地址
CLONE_DIR="$HOME/dotfiles-sync"

echo "🚀 一键部署个人配置环境"
echo "=========================="
echo

# 检查 git 是否安装
if ! command -v git >/dev/null 2>&1; then
    log_info "Git 未安装，正在安装..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew >/dev/null 2>&1; then
            brew install git
        else
            log_error "请先安装 Homebrew: https://brew.sh"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y git
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y git
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm git
        else
            log_error "不支持的 Linux 发行版，请手动安装 git"
            exit 1
        fi
    else
        log_error "不支持的操作系统"
        exit 1
    fi
    
    log_success "Git 安装完成"
fi

# 克隆仓库
if [ -d "$CLONE_DIR" ]; then
    log_warning "目录 $CLONE_DIR 已存在"
    read -p "是否删除现有目录并重新克隆？ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$CLONE_DIR"
        log_info "已删除现有目录"
    else
        log_info "使用现有目录，尝试更新..."
        cd "$CLONE_DIR"
        git pull origin main || git pull origin master || log_warning "无法更新仓库"
    fi
fi

if [ ! -d "$CLONE_DIR" ]; then
    log_info "克隆配置仓库..."
    git clone "$REPO_URL" "$CLONE_DIR"
    log_success "仓库克隆完成"
fi

# 进入目录
cd "$CLONE_DIR"

# 设置脚本执行权限
chmod +x install.sh update.sh 2>/dev/null || true

# 运行安装脚本
log_info "开始安装配置..."
if [ -f "install.sh" ]; then
    ./install.sh
else
    log_error "安装脚本不存在"
    exit 1
fi

log_success "一键部署完成！🎉"

echo
echo "📖 使用说明："
echo "   - 配置文件位于: $CLONE_DIR"
echo "   - 更新配置: cd $CLONE_DIR && ./update.sh"
echo "   - 重新安装: cd $CLONE_DIR && ./install.sh"
echo
echo "�� 建议重新启动终端以确保所有配置生效" 