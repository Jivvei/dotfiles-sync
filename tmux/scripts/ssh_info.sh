#!/bin/bash

# SSH连接信息检测脚本
# 用于tmux状态栏显示SSH主机IP信息

get_ssh_info() {
    # 本地检测SSH连接状态，无需修改服务器
    HOSTNAME=$(hostname -s)
    LOCAL_IP=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' 2>/dev/null || hostname -I | awk '{print $1}')
    
    # 检查tmux当前窗格是否在SSH会话中
    SSH_SERVER=""
    SSH_USER=""
    
            # 优先检查手动设置的覆盖变量（用于堡垒机等复杂情况）
        # 先尝试从文件加载
        if [ -f ~/.tmux_ssh_override ]; then
            source ~/.tmux_ssh_override
        fi
        
        if [ -n "$SSH_TARGET_OVERRIDE" ]; then
            if [[ "$SSH_TARGET_OVERRIDE" == *"@"* ]]; then
                SSH_USER=$(echo "$SSH_TARGET_OVERRIDE" | cut -d@ -f1)
                SSH_SERVER=$(echo "$SSH_TARGET_OVERRIDE" | cut -d@ -f2)
            else
                SSH_SERVER="$SSH_TARGET_OVERRIDE"
                SSH_USER="$(whoami)"
            fi
        fi
    
    # 方法1: 检查tmux当前窗格的进程（支持堡垒机多层跳转）
    if command -v tmux >/dev/null 2>&1 && [ -n "$TMUX" ]; then
        # 获取当前窗格的进程ID
        PANE_PID=$(tmux display-message -p '#{pane_pid}' 2>/dev/null)
        if [ -n "$PANE_PID" ]; then
            # 收集所有SSH进程，按时间排序（最新的在前）
            SSH_PROCESSES=()
            for pid in $(pstree -p "$PANE_PID" 2>/dev/null | grep -oE "\([0-9]+\)" | tr -d "()" | sort -u); do
                cmd=$(ps -o cmd= -p "$pid" 2>/dev/null)
                if [[ "$cmd" == *" ssh "* ]]; then
                    # 获取进程启动时间来排序
                    start_time=$(ps -o lstart= -p "$pid" 2>/dev/null | tr -d ' ')
                    SSH_PROCESSES+=("$start_time|$cmd")
                fi
            done
            
            # 如果有多个SSH进程，选择最后启动的（最内层的连接）
            if [ ${#SSH_PROCESSES[@]} -gt 0 ]; then
                # 按时间排序，取最新的
                LATEST_SSH=$(printf '%s\n' "${SSH_PROCESSES[@]}" | sort | tail -1 | cut -d'|' -f2-)
                SSH_PROCESS="$LATEST_SSH"
            fi
            
            # 如果没找到，尝试检查直接子进程
            if [ -z "$SSH_PROCESS" ]; then
                SSH_PROCESS=$(ps -o cmd= --ppid "$PANE_PID" 2>/dev/null | grep "ssh " | head -1)
            fi
            
            # 从SSH命令行解析服务器信息
            if [ -n "$SSH_PROCESS" ]; then
                # 处理ProxyJump等堡垒机参数
                if [[ "$SSH_PROCESS" == *"-J "* ]] || [[ "$SSH_PROCESS" == *"ProxyJump"* ]]; then
                    # 提取最终目标（ProxyJump后面的目标）
                    SSH_CLEAN=$(echo "$SSH_PROCESS" | sed 's/.*-J[[:space:]]*[^[:space:]]*[[:space:]]*//g' | awk '{print $NF}')
                else
                    # 移除SSH选项参数，只保留目标
                    SSH_CLEAN=$(echo "$SSH_PROCESS" | sed 's/ssh[[:space:]]*\(-[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\)*//g' | awk '{print $NF}')
                fi
                
                # 进一步清理，移除端口号等
                SSH_CLEAN=$(echo "$SSH_CLEAN" | sed 's/:[0-9]*$//')
                
                if [[ "$SSH_CLEAN" == *"@"* ]]; then
                    SSH_USER=$(echo "$SSH_CLEAN" | cut -d@ -f1)
                    SSH_SERVER=$(echo "$SSH_CLEAN" | cut -d@ -f2)
                elif [[ "$SSH_CLEAN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$SSH_CLEAN" =~ ^[a-zA-Z] ]]; then
                    SSH_SERVER="$SSH_CLEAN"
                    SSH_USER="$(whoami)"
                fi
            fi
        fi
    fi
    
    # 方法2: 检查环境变量(如果在SSH会话内)
    if [ -z "$SSH_SERVER" ] && [ -n "$SSH_CONNECTION" ]; then
        # 如果有SSH_CONNECTION，说明本身就在SSH会话中
        SERVER_IP=$(echo $SSH_CONNECTION | awk '{print $3}')
        SSH_SERVER="$SERVER_IP"
    fi
    
    # 方法3: 检查当前窗格标题和命令提示符
    if [ -z "$SSH_SERVER" ] && command -v tmux >/dev/null 2>&1; then
        PANE_TITLE=$(tmux display-message -p '#{pane_title}' 2>/dev/null)
        if [[ "$PANE_TITLE" == *"@"* ]]; then
            SSH_SERVER=$(echo "$PANE_TITLE" | grep -oE "[^@]+@[^[:space:]]+" | cut -d@ -f2)
        fi
    fi
    
    # 方法4: 检查PS1提示符中的主机信息（如果通过堡垒机跳转）
    if [ -z "$SSH_SERVER" ]; then
        # 尝试从当前shell提示符获取主机信息
        if [ -n "$PS1" ]; then
            # 检查PS1中是否包含用户@主机格式
            PS1_HOST=$(echo "$PS1" | grep -oE '[a-zA-Z0-9_-]+@[a-zA-Z0-9.-]+' | tail -1)
            if [ -n "$PS1_HOST" ]; then
                SSH_USER=$(echo "$PS1_HOST" | cut -d@ -f1)
                SSH_SERVER=$(echo "$PS1_HOST" | cut -d@ -f2)
            fi
        fi
    fi
    
    # 方法5: 检查当前工作目录路径（某些堡垒机会设置特殊路径）
    if [ -z "$SSH_SERVER" ]; then
        CURRENT_PWD=$(pwd)
        # 如果当前路径包含明显的远程主机标识
        if [[ "$CURRENT_PWD" == */remote/* ]] || [[ "$CURRENT_PWD" == */servers/* ]]; then
            # 尝试从路径中提取主机信息
            POSSIBLE_HOST=$(echo "$CURRENT_PWD" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            if [ -n "$POSSIBLE_HOST" ]; then
                SSH_SERVER="$POSSIBLE_HOST"
            fi
        fi
    fi
    
    # 方法6: 检查最近的SSH历史命令（仅在确实在SSH会话中时）
    if [ -z "$SSH_SERVER" ] && [ -f ~/.bash_history ] && [ -n "$SSH_CONNECTION" ]; then
        RECENT_SSH=$(tail -20 ~/.bash_history 2>/dev/null | grep "ssh " | tail -1)
        if [ -n "$RECENT_SSH" ]; then
            # 解析最近的SSH命令
            SSH_TARGET=$(echo "$RECENT_SSH" | sed 's/ssh[[:space:]]*\(-[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*\)*//g' | awk '{print $NF}')
            if [[ "$SSH_TARGET" == *"@"* ]]; then
                SSH_USER=$(echo "$SSH_TARGET" | cut -d@ -f1)
                SSH_SERVER=$(echo "$SSH_TARGET" | cut -d@ -f2)
            elif [[ "$SSH_TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                SSH_SERVER="$SSH_TARGET"
            fi
        fi
    fi
    
    # 方法7: 检查tmux窗格标题中的用户@主机信息（针对SSH管理工具）
    if [ -z "$SSH_SERVER" ] && command -v tmux >/dev/null 2>&1 && [ -n "$TMUX" ]; then
        PANE_TITLE=$(tmux display-message -p '#{pane_title}' 2>/dev/null)
        WINDOW_NAME=$(tmux display-message -p '#{window_name}' 2>/dev/null)
        
        # 检查窗格标题或窗口名称中的连接信息
        for title in "$PANE_TITLE" "$WINDOW_NAME"; do
            if [[ "$title" == *"@"* ]]; then
                # 提取用户@主机格式
                SSH_INFO=$(echo "$title" | grep -oE '[a-zA-Z0-9_-]+@[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
                if [ -n "$SSH_INFO" ]; then
                    SSH_USER=$(echo "$SSH_INFO" | cut -d@ -f1)
                    SSH_SERVER=$(echo "$SSH_INFO" | cut -d@ -f2)
                    break
                fi
            fi
        done
    fi
    
    # 方法8: 检查当前shell的PROMPT命令或PS1变量中的主机信息
    if [ -z "$SSH_SERVER" ]; then
        # 检查当前shell环境中可能包含的主机信息
        if [ -n "$USER" ] && [ -n "$HOSTNAME" ]; then
            # 检查是否是常见的远程主机名格式
            if [[ "$HOSTNAME" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$HOSTNAME" != "$(hostname)" ]]; then
                SSH_USER="$USER"
                SSH_SERVER="$HOSTNAME"
            fi
        fi
    fi
    
    # 方法9: 检查who命令的输出（针对SSH管理工具环境）
    if [ -z "$SSH_SERVER" ]; then
        WHO_OUTPUT=$(who am i 2>/dev/null)
        if [ -n "$WHO_OUTPUT" ]; then
            # 从who输出中提取连接信息
            WHO_IP=$(echo "$WHO_OUTPUT" | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\)' | tr -d '()')
            WHO_USER=$(echo "$WHO_OUTPUT" | awk '{print $1}')
            if [ -n "$WHO_IP" ] && [ -n "$WHO_USER" ]; then
                SSH_USER="$WHO_USER"
                SSH_SERVER="$WHO_IP"
            fi
        fi
    fi
    
    # 输出结果（Alacritty兼容）
    if [ -n "$SSH_SERVER" ]; then
        # 清理服务器名称（移除端口号等）
        CLEAN_SERVER=$(echo "$SSH_SERVER" | cut -d: -f1)
        if [ -n "$SSH_USER" ] && [ "$SSH_USER" != "$(whoami)" ]; then
            echo "#[fg=cyan]SSH #[fg=default]$SSH_USER@$CLEAN_SERVER"
        else
            echo "#[fg=cyan]SSH #[fg=default]$CLEAN_SERVER"
        fi
    else
        # 本地连接
        if [ -n "$LOCAL_IP" ]; then
            echo "#[fg=blue]LOCAL #[fg=default]$HOSTNAME[$LOCAL_IP]"
        else
            echo "#[fg=blue]LOCAL #[fg=default]$HOSTNAME"
        fi
    fi
}

# 获取更详细的SSH连接信息
get_detailed_ssh_info() {
    # 检查是否在SSH会话中 (重用前面的检测逻辑)
    IS_SSH=false
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
        IS_SSH=true
    elif ps -o comm= -p $PPID 2>/dev/null | grep -q sshd; then
        IS_SSH=true
    elif who am i 2>/dev/null | grep -q '(' ; then
        IS_SSH=true
    fi
    
    if [ "$IS_SSH" = true ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🖥️  SSH 服务器信息"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if [ -n "$SSH_CONNECTION" ]; then
            CLIENT_IP=$(echo $SSH_CONNECTION | awk '{print $1}')
            CLIENT_PORT=$(echo $SSH_CONNECTION | awk '{print $2}')
            SERVER_IP=$(echo $SSH_CONNECTION | awk '{print $3}')
            SERVER_PORT=$(echo $SSH_CONNECTION | awk '{print $4}')
            
            echo "📱 你的客户端: $CLIENT_IP:$CLIENT_PORT"
            echo "🖥️  当前服务器: $SERVER_IP:$SERVER_PORT"
            echo ""
        fi
        
        echo "🏷️  服务器主机名: $(hostname -f)"
        echo "👤 登录用户: $(whoami)"
        echo "⏰ 登录时间: $(who am i 2>/dev/null | awk '{print $3, $4}' || date)"
        
        # 获取服务器的所有IP地址
        echo ""
        echo "📡 服务器网络接口:"
        ip addr show 2>/dev/null | grep -E "inet " | grep -v "127.0.0.1" | while read line; do
            ip=$(echo $line | awk '{print $2}')
            interface=$(echo $line | awk '{print $NF}')
            echo "   $ip ($interface)"
        done
        
        echo ""
        echo "🌍 SSH连接来源: ${SSH_CLIENT:-$(who am i | sed 's/.*(\(.*\)).*/\1/' 2>/dev/null || echo '本地')}"
        
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🏠 本地主机信息"  
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🏷️  主机名: $(hostname -f)"
        echo "👤 用户: $(whoami)"
        echo "📡 主IP地址: $(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' 2>/dev/null || hostname -I | awk '{print $1}')"
        echo "🌍 默认网关: $(ip route | grep default | awk '{print $3}' | head -1)"
        
        echo ""
        echo "📡 网络接口:"
        ip addr show 2>/dev/null | grep -E "inet " | grep -v "127.0.0.1" | while read line; do
            ip=$(echo $line | awk '{print $2}')
            interface=$(echo $line | awk '{print $NF}')
            echo "   $ip ($interface)"
        done
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 调试模式 - 显示所有检测信息
debug_ssh_detection() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 SSH 连接调试信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "🖥️ 基本信息:"
    echo "   主机名: $(hostname)"
    echo "   当前用户: $(whoami)"
    echo "   当前目录: $(pwd)"
    echo "   TMUX会话: ${TMUX:-未在tmux中}"
    
    echo ""
    echo "🔗 环境变量:"
    echo "   SSH_CONNECTION: ${SSH_CONNECTION:-未设置}"
    echo "   SSH_CLIENT: ${SSH_CLIENT:-未设置}"
    echo "   SSH_TTY: ${SSH_TTY:-未设置}"
    
    echo ""
    echo "🌲 进程树信息:"
    if [ -n "$TMUX" ]; then
        PANE_PID=$(tmux display-message -p '#{pane_pid}' 2>/dev/null)
        echo "   窗格PID: $PANE_PID"
        echo "   进程树:"
        pstree -p "$PANE_PID" 2>/dev/null | head -5 || echo "   无法获取进程树"
        
        echo ""
        echo "📋 SSH进程:"
        for pid in $(pstree -p "$PANE_PID" 2>/dev/null | grep -oE "\([0-9]+\)" | tr -d "()" | sort -u); do
            cmd=$(ps -o cmd= -p "$pid" 2>/dev/null)
            if [[ "$cmd" == *" ssh "* ]]; then
                echo "   PID $pid: $cmd"
            fi
        done
    else
        echo "   当前不在tmux会话中"
    fi
    
    echo ""
    echo "📜 最近SSH命令:"
    if [ -f ~/.bash_history ]; then
        tail -10 ~/.bash_history 2>/dev/null | grep "ssh " | tail -3 | while read line; do
            echo "   $line"
        done
    fi
    
    echo ""
    echo "🎯 检测结果:"
    get_ssh_info
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 根据参数执行不同功能
case "$1" in
    "brief")
        get_ssh_info
        ;;
    "detailed")
        get_detailed_ssh_info
        ;;
    "debug")
        debug_ssh_detection
        ;;
    *)
        get_ssh_info
        ;;
esac 