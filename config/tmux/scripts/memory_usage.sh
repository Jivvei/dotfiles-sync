#!/bin/bash

# 内存使用率显示脚本
# 用于tmux状态栏

# 获取内存信息
memory_info=$(free | awk 'NR==2{printf "%.0f%%", $3*100/$2}')

# 获取具体数值用于颜色判断
memory_percent=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')

# 根据使用率显示不同颜色的图标（Alacritty兼容）
if [ "$memory_percent" -gt 80 ]; then
    echo "#[fg=red]MEM #[fg=default]$memory_info"
elif [ "$memory_percent" -gt 60 ]; then
    echo "#[fg=yellow]MEM #[fg=default]$memory_info"
else
    echo "#[fg=green]MEM #[fg=default]$memory_info"
fi 