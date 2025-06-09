#!/bin/bash

# 快速SSH目标设置工具
# 针对SSH管理工具/堡垒机环境的快速配置

echo "🚀 快速设置SSH目标"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查是否在tmux中
if [ -z "$TMUX" ]; then
    echo "❌ 请在tmux会话中运行此工具"
    exit 1
fi

echo "选择设置方式："
echo "1) 📝 手动输入服务器信息"
echo "2) 🎯 从当前环境自动检测" 
echo "3) 📋 从剪贴板获取"
echo "4) 🗑️  清除设置"
echo "0) ❌ 退出"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "请选择 [0-4]: " choice

case $choice in
    1)
        echo ""
        echo "📝 手动设置："
        read -p "输入用户名 [root]: " input_user
        read -p "输入服务器IP: " input_server
        
        input_user=${input_user:-root}
        
        if [ -n "$input_server" ]; then
            target="$input_user@$input_server"
            echo "export SSH_TARGET_OVERRIDE='$target'" > ~/.tmux_ssh_override
            tmux rename-window "SSH:$input_server"
            echo "✅ 已设置为: $target"
            echo "🔄 正在刷新状态栏..."
            tmux refresh-client
        else
            echo "❌ 服务器IP不能为空"
        fi
        ;;
    2)
        echo ""
        echo "🎯 自动检测："
        
        # 尝试多种检测方法
        detected=""
        
        # 方法1: 检查who am i
        who_info=$(who am i 2>/dev/null)
        if [ -n "$who_info" ]; then
            who_ip=$(echo "$who_info" | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\)' | tr -d '()')
            who_user=$(echo "$who_info" | awk '{print $1}')
            if [ -n "$who_ip" ]; then
                detected="$who_user@$who_ip"
            fi
        fi
        
        # 方法2: 检查SSH_CONNECTION
        if [ -z "$detected" ] && [ -n "$SSH_CONNECTION" ]; then
            server_ip=$(echo $SSH_CONNECTION | awk '{print $3}')
            current_user=$(whoami)
            detected="$current_user@$server_ip"
        fi
        
        # 方法3: 检查环境变量
        if [ -z "$detected" ] && [ -n "$USER" ] && [ -n "$HOSTNAME" ]; then
            if [[ "$HOSTNAME" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                detected="$USER@$HOSTNAME"
            fi
        fi
        
        if [ -n "$detected" ]; then
            echo "🔍 检测到: $detected"
            read -p "确认使用此设置? [Y/n]: " confirm
            if [[ ! $confirm =~ ^[Nn]$ ]]; then
                echo "export SSH_TARGET_OVERRIDE='$detected'" > ~/.tmux_ssh_override
                server_only=$(echo "$detected" | cut -d@ -f2)
                tmux rename-window "SSH:$server_only"
                echo "✅ 已自动设置为: $detected"
                echo "🔄 正在刷新状态栏..."
                tmux refresh-client
            fi
        else
            echo "❌ 未能自动检测到服务器信息"
            echo "💡 建议使用手动输入方式"
        fi
        ;;
    3)
        echo ""
        echo "📋 从剪贴板获取："
        if command -v xclip >/dev/null 2>&1; then
            clipboard_content=$(xclip -o 2>/dev/null)
        elif command -v pbpaste >/dev/null 2>&1; then
            clipboard_content=$(pbpaste 2>/dev/null)
        else
            echo "❌ 未找到剪贴板工具 (xclip/pbpaste)"
            exit 1
        fi
        
        if [ -n "$clipboard_content" ]; then
            echo "📋 剪贴板内容: $clipboard_content"
            
            # 尝试从剪贴板内容中提取IP地址
            ip_from_clipboard=$(echo "$clipboard_content" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            user_from_clipboard=$(echo "$clipboard_content" | grep -oE '[a-zA-Z0-9_-]+@' | tr -d '@' | head -1)
            
            if [ -n "$ip_from_clipboard" ]; then
                user_from_clipboard=${user_from_clipboard:-root}
                target="$user_from_clipboard@$ip_from_clipboard"
                echo "🎯 解析结果: $target"
                read -p "确认使用此设置? [Y/n]: " confirm
                if [[ ! $confirm =~ ^[Nn]$ ]]; then
                    echo "export SSH_TARGET_OVERRIDE='$target'" > ~/.tmux_ssh_override
                    tmux rename-window "SSH:$ip_from_clipboard"
                    echo "✅ 已设置为: $target"
                    echo "🔄 正在刷新状态栏..."
                    tmux refresh-client
                fi
            else
                echo "❌ 无法从剪贴板内容中提取有效的IP地址"
            fi
        else
            echo "❌ 剪贴板为空"
        fi
        ;;
    4)
        echo ""
        echo "🗑️ 清除设置："
        rm -f ~/.tmux_ssh_override
        unset SSH_TARGET_OVERRIDE
        tmux rename-window ""
        echo "✅ 已清除SSH目标设置"
        echo "🔄 正在刷新状态栏..."
        tmux refresh-client
        ;;
    0)
        echo "👋 退出"
        exit 0
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac

# 加载设置到当前会话
if [ -f ~/.tmux_ssh_override ]; then
    source ~/.tmux_ssh_override
fi

echo ""
echo "💡 提示: 状态栏将在几秒内更新"
echo "按任意键继续..."
read 