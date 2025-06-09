#!/bin/bash

# 配置文件同步更新脚本
# 使用方法: ./update.sh

set -e

echo "🔄 开始从本地更新配置文件到仓库..."

# 更新 tmux 配置
if [ -f "$HOME/.tmux.conf" ]; then
    cp "$HOME/.tmux.conf" tmux/
    echo "   ✓ 更新 tmux 配置"
    
    # 更新 tmux 脚本和插件
    if [ -d "$HOME/.tmux/scripts" ]; then
        cp -r "$HOME/.tmux/scripts" tmux/
        echo "   ✓ 更新 tmux 脚本"
    fi
    
    if [ -d "$HOME/.tmux/plugins" ]; then
        cp -r "$HOME/.tmux/plugins" tmux/
        echo "   ✓ 更新 tmux 插件"
    fi
else
    echo "   ⚠️ tmux 配置文件不存在"
fi

# 更新 alacritty 配置
if [ -d "$HOME/.config/alacritty" ]; then
    cp -r "$HOME/.config/alacritty"/* alacritty/
    echo "   ✓ 更新 alacritty 配置"
else
    echo "   ⚠️ alacritty 配置目录不存在"
fi

# 更新 fish 配置
if [ -d "$HOME/.config/fish" ]; then
    cp -r "$HOME/.config/fish"/* fish/
    echo "   ✓ 更新 fish 配置"
else
    echo "   ⚠️ fish 配置目录不存在"
fi

# 更新 starship 配置
if [ -f "$HOME/.config/starship.toml" ]; then
    cp "$HOME/.config/starship.toml" starship/
    echo "   ✓ 更新 starship 配置"
else
    echo "   ⚠️ starship 配置文件不存在"
fi

# 更新 neofetch 配置
if [ -d "$HOME/.config/neofetch" ] && [ "$(ls -A $HOME/.config/neofetch 2>/dev/null)" ]; then
    cp -r "$HOME/.config/neofetch"/* neofetch/
    echo "   ✓ 更新 neofetch 配置"
else
    echo "   ⚠️ neofetch 配置目录不存在或为空"
fi

echo ""
echo "✅ 配置文件更新完成！"
echo ""
echo "🚀 接下来可以提交到 Git："
echo "   git add ."
echo "   git commit -m \"更新配置文件 $(date '+%Y-%m-%d %H:%M:%S')\""
echo "   git push" 