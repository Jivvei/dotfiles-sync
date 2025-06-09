#!/bin/bash

# 系统监控脚本
# 显示系统状态信息

echo "📊 系统监控面板"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 系统基本信息
echo "🖥️  系统信息:"
echo "   主机: $(hostname -f)"
echo "   内核: $(uname -r)"
echo "   启动时间: $(uptime -s)"

echo ""

# CPU信息
echo "🔧 CPU信息:"
cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//')
cpu_cores=$(nproc)
echo "   型号: $cpu_model"
echo "   核心数: $cpu_cores"

# 当前CPU使用率
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
echo "   使用率: ${cpu_usage:-计算中...}"

echo ""

# 内存信息
echo "💾 内存信息:"
memory_total=$(free -h | awk 'NR==2{print $2}')
memory_used=$(free -h | awk 'NR==2{print $3}')
memory_free=$(free -h | awk 'NR==2{print $4}')
memory_percent=$(free | awk 'NR==2{printf "%.1f%%", $3*100/$2}')

echo "   总计: $memory_total"
echo "   已用: $memory_used ($memory_percent)"
echo "   可用: $memory_free"

echo ""

# 磁盘信息
echo "💽 磁盘使用:"
df -h | grep -E "^/dev" | head -5 | while read line; do
    echo "   $line"
done

echo ""

# 网络信息
echo "🌐 网络状态:"
# 获取主要网络接口
primary_interface=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -n "$primary_interface" ]; then
    ip_address=$(ip addr show $primary_interface | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    echo "   接口: $primary_interface"
    echo "   IP: $ip_address"
fi

# 网络连接数
connections=$(ss -t | grep ESTAB | wc -l)
echo "   活动连接: $connections"

echo ""

# 进程信息
echo "🔄 进程信息:"
process_total=$(ps aux | wc -l)
echo "   总进程数: $process_total"
echo "   CPU占用前5:"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "      %s: %.1f%%\n", $11, $3}'

echo ""

# 系统负载
echo "⚡ 系统负载:"
load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
echo "   负载: $load_avg"

echo ""

# 最后更新时间
echo "⏰ 更新时间: $(date '+%Y-%m-%d %H:%M:%S')"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "按任意键关闭..."
read 