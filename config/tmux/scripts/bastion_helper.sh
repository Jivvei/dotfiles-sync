#!/bin/bash

# 堡垒机连接助手
# 帮助设置和管理通过堡垒机的SSH连接

echo "🏰 堡垒机连接助手"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查是否在tmux中
if [ -z "$TMUX" ]; then
    echo "⚠️  建议在tmux中运行此助手以获得最佳体验"
    echo "   请先运行: tmux"
    echo ""
fi

echo "选择操作："
echo "1) 🔧 配置堡垒机SSH"
echo "2) 🚀 快速连接到目标服务器"
echo "3) 📋 查看SSH配置模板"
echo "4) 🔍 测试当前连接检测"
echo "5) ⚙️  设置窗格标题（手动标记）"
echo "0) ❌ 退出"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "请选择 [0-5]: " choice

case $choice in
    1)
        echo ""
        echo "🔧 堡垒机SSH配置："
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "在 ~/.ssh/config 中添加以下配置："
        echo ""
        echo "# 堡垒机配置"
        echo "Host bastion"
        echo "    HostName 堡垒机IP"
        echo "    User 堡垒机用户名"
        echo "    Port 22"
        echo ""
        echo "# 目标服务器（通过堡垒机）"
        echo "Host target-server"
        echo "    HostName 目标服务器IP"
        echo "    User 目标用户名"
        echo "    ProxyJump bastion"
        echo "    Port 22"
        echo ""
        read -p "是否打开SSH配置文件编辑? [y/N]: " edit_ssh
        if [[ $edit_ssh =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} ~/.ssh/config
        fi
        ;;
    2)
        echo ""
        echo "🚀 快速连接："
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        read -p "输入堡垒机地址 (user@host): " bastion_host
        read -p "输入目标服务器地址 (user@host): " target_host
        
        if [ -n "$bastion_host" ] && [ -n "$target_host" ]; then
            echo ""
            echo "连接命令："
            echo "ssh -J $bastion_host $target_host"
            echo ""
            read -p "是否立即连接? [y/N]: " connect_now
            if [[ $connect_now =~ ^[Yy]$ ]]; then
                # 设置窗格标题以帮助识别
                if [ -n "$TMUX" ]; then
                    tmux rename-window "SSH:$(echo $target_host | cut -d@ -f2)"
                fi
                ssh -J "$bastion_host" "$target_host"
            fi
        fi
        ;;
    3)
        echo ""
        echo "📋 SSH配置模板："
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "方法1: ProxyJump 配置"
        echo "Host myserver"
        echo "    HostName 目标服务器IP"
        echo "    User root"
        echo "    ProxyJump user@堡垒机IP"
        echo ""
        echo "方法2: ProxyCommand 配置"
        echo "Host myserver"
        echo "    HostName 目标服务器IP"
        echo "    User root"
        echo "    ProxyCommand ssh -W %h:%p user@堡垒机IP"
        echo ""
        echo "方法3: 多级跳转"
        echo "Host myserver"
        echo "    HostName 目标服务器IP"
        echo "    User root"
        echo "    ProxyJump user1@堡垒机1,user2@堡垒机2"
        ;;
    4)
        echo ""
        echo "🔍 测试连接检测："
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        /home/Jiwei/.tmux/scripts/ssh_info.sh debug
        ;;
    5)
        echo ""
        echo "⚙️ 手动设置窗格标题："
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if [ -n "$TMUX" ]; then
            read -p "输入目标服务器标识 (如: root@10.20.140.220): " server_id
            if [ -n "$server_id" ]; then
                tmux rename-window "SSH:$server_id"
                # 同时设置环境变量帮助检测
                echo "export SSH_TARGET_OVERRIDE='$server_id'" >> ~/.bashrc
                echo "✅ 窗格标题已设置为: SSH:$server_id"
                echo "💡 提示: 状态栏应该会在几秒内更新显示"
            fi
        else
            echo "❌ 不在tmux会话中，无法设置窗格标题"
        fi
        ;;
    0)
        echo "👋 再见！"
        exit 0
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac

echo ""
echo "按任意键继续..."
read 