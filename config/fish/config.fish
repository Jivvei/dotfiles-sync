alias xs='/data/apps/autossh/autossh 1'
alias ah='/data/apps/autossh/autossh 2'
alias ssh='TERM=xterm-256color /usr/bin/ssh'
if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Homebrew 环境变量配置
if test -d /home/linuxbrew/.linuxbrew
    # eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# 明确设置 PATH 顺序，确保系统路径优先
set -gx PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin $HOME/.local/bin $HOME/bin /home/linuxbrew/.linuxbrew/sbin /home/linuxbrew/.linuxbrew/bin
set -x GTK_IM_MODULE ibus
set -x QT_IM_MODULE ibus
set -x XMODIFIERS @im=ibus
# Fish shell 配置文件

# 智能tmux启动
if status is-interactive
    # 检查是否已经在tmux中或通过SSH连接
    if not set -q TMUX; and not set -q SSH_TTY
        # 检查是否是Alacritty终端
        if test "$TERM_PROGRAM" = "alacritty"; or test "$TERM" = "alacritty"
            # 尝试附加到现有的main会话，如果不存在则创建
            exec tmux new-session -A -s main
        end
    end
end

# Fish shell 增强配置
if status is-interactive
    # 设置别名
    alias ll='ls -alF'
    alias la='ls -A' 
    alias l='ls -CF'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias grep='grep --color=auto'
    
    # tmux 相关别名
    alias tmux='tmux -2'
    alias tmuxa='tmux attach'
    alias tmuxl='tmux list-sessions'
    alias tmuxk='tmux kill-session'
    
    # 设置更好的提示符颜色
    set fish_greeting ""
    
    # 自动补全增强
    set -g fish_autosuggestion_enabled 1
    
    # 初始化 starship 提示符
    if command -v starship >/dev/null 2>&1
        # 设置 starship 配置文件路径
        set -gx STARSHIP_CONFIG ~/.config/starship.toml
        starship init fish | source
    end
end
