#!/bin/bash

# 终端工具选择器脚本

echo "🖥️ 终端工具选择器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) 📊 系统监控      - htop"
echo "2) 📁 文件管理      - ranger/ls"
echo "3) 🌐 网络状态      - ss/netstat"
echo "4) 🔍 进程查看      - ps"
echo "5) 📋 剪贴板        - xclip"
echo "6) ⚙️ 系统信息      - 系统详情"
echo "0) ❌ 取消"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "请选择工具 [0-6]: " choice

case $choice in
    1)
        tmux new-window 'htop'
        ;;
    2)
        if command -v ranger >/dev/null 2>&1; then
            tmux new-window 'ranger'
        else
            tmux new-window 'ls -la'
        fi
        ;;
    3)
        tmux new-window 'ss -tulpn'
        ;;
    4)
        tmux new-window 'ps aux | head -20'
        ;;
    5)
        tmux display-popup -E 'xclip -o 2>/dev/null || echo "剪贴板为空"; read'
        ;;
    6)
        tmux display-popup -E 'uname -a && echo && uptime && echo && free -h && read'
        ;;
    0)
        echo "已取消"
        ;;
    *)
        echo "无效选择"
        ;;
esac 