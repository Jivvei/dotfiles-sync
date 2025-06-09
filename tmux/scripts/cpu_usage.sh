#!/bin/bash

# CPU使用率显示脚本
# 用于tmux状态栏

# 获取CPU使用率
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')

# 如果获取失败，使用备用方法
if [ -z "$cpu_usage" ]; then
    cpu_usage=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1); }' <(grep 'cpu ' /proc/stat; sleep 1; grep 'cpu ' /proc/stat) 2>/dev/null | head -1)
fi

# 如果还是获取失败，使用更简单的方法
if [ -z "$cpu_usage" ]; then
    cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
fi

# 确保cpu_usage是纯数字，然后统一添加%号
cpu_usage=$(echo "$cpu_usage" | sed 's/%//g')
cpu_usage="${cpu_usage}%"

# 根据使用率显示不同颜色的图标（Alacritty兼容）
if [ "${cpu_usage%.*}" -gt 80 ]; then
    echo "#[fg=red]CPU #[fg=default]$cpu_usage"
elif [ "${cpu_usage%.*}" -gt 60 ]; then
    echo "#[fg=yellow]CPU #[fg=default]$cpu_usage"
else
    echo "#[fg=green]CPU #[fg=default]$cpu_usage"
fi 