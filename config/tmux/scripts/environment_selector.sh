#!/bin/bash

# tmux环境选择器脚本
# 快速设置不同的工作环境

echo "🚀 tmux 环境选择器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) 💻 开发环境    - 3窗格代码开发布局"
echo "2) 📊 监控环境    - 系统监控窗口"
echo "3) 📜 日志查看    - 实时日志监控"
echo "4) 🌐 网络工具    - 网络诊断窗口"
echo "5) 🐳 Docker环境  - Docker管理"
echo "6) 🔧 系统维护    - 系统管理工具"
echo "7) 📁 文件管理    - 文件浏览器"
echo "8) 🔍 搜索环境    - 搜索和查找工具"
echo "0) ❌ 取消"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "请选择环境 [0-8]: " choice

case $choice in
    1)
        echo "🔄 设置开发环境..."
        tmux rename-window 'DEV'
        tmux split-window -h -c "#{pane_current_path}"
        tmux split-window -v -c "#{pane_current_path}"
        tmux select-pane -t 0
        echo "✅ 开发环境已设置完成"
        ;;
    2)
        echo "🔄 设置监控环境..."
        tmux rename-window 'MONITOR'
        tmux new-window -n 'HTOP' 'htop'
        tmux new-window -n 'LOGS' 'journalctl -f'
        tmux select-window -t 'MONITOR'
        echo "✅ 监控环境已设置完成"
        ;;
    3)
        echo "🔄 设置日志查看环境..."
        tmux rename-window 'LOGS'
        tmux new-window -n 'SYSLOG' 'tail -f /var/log/syslog'
        tmux split-window -h 'journalctl -f'
        echo "✅ 日志查看环境已设置完成"
        ;;
    4)
        echo "🔄 设置网络工具环境..."
        tmux rename-window 'NETWORK'
        tmux new-window -n 'NETSTAT' 'ss -tulpn'
        tmux split-window -h 'ping 8.8.8.8'
        tmux split-window -v 'watch -n 1 "ss -s"'
        echo "✅ 网络工具环境已设置完成"
        ;;
    5)
        echo "🔄 设置Docker环境..."
        tmux rename-window 'DOCKER'
        tmux new-window -n 'PS' 'watch -n 2 docker ps'
        tmux split-window -h 'docker stats'
        tmux new-window -n 'LOGS' 'docker logs -f $(docker ps -q | head -1) 2>/dev/null || echo "没有运行的容器"'
        echo "✅ Docker环境已设置完成"
        ;;
    6)
        echo "🔄 设置系统维护环境..."
        tmux rename-window 'SYSTEM'
        tmux new-window -n 'TOP' 'top'
        tmux split-window -h 'iotop'
        tmux new-window -n 'DISK' 'watch -n 2 df -h'
        echo "✅ 系统维护环境已设置完成"
        ;;
    7)
        echo "🔄 设置文件管理环境..."
        tmux rename-window 'FILES'
        if command -v ranger >/dev/null 2>&1; then
            tmux new-window -n 'RANGER' 'ranger'
        else
            tmux new-window -n 'LS' 'ls -la'
        fi
        tmux split-window -h -c "#{pane_current_path}"
        echo "✅ 文件管理环境已设置完成"
        ;;
    8)
        echo "🔄 设置搜索环境..."
        tmux rename-window 'SEARCH'
        if command -v fzf >/dev/null 2>&1; then
            tmux new-window -n 'FZF' 'fzf'
        fi
        if command -v ag >/dev/null 2>&1; then
            tmux split-window -h 'ag'
        else
            tmux split-window -h 'grep'
        fi
        echo "✅ 搜索环境已设置完成"
        ;;
    0)
        echo "❌ 已取消"
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac

echo ""
echo "按任意键继续..."
read 