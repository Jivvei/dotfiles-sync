#!/bin/bash

# 快速笔记脚本
# 用于快速记录和管理笔记

NOTES_DIR="$HOME/.tmux/notes"
mkdir -p "$NOTES_DIR"

echo "📝 快速笔记管理"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) ✏️  新建笔记"
echo "2) 📋 查看笔记列表"
echo "3) 🔍 搜索笔记"
echo "4) 📝 编辑笔记"
echo "5) 🗑️  删除笔记"
echo "6) 📊 今日快记"
echo "7) 💾 备份笔记"
echo "8) 📁 打开笔记目录"
echo "0) ❌ 退出"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "请选择操作 [0-8]: " choice

case $choice in
    1)
        echo ""
        read -p "📝 请输入笔记标题: " title
        if [ -z "$title" ]; then
            title="note_$(date +%Y%m%d_%H%M%S)"
        fi
        
        # 清理标题中的特殊字符
        safe_title=$(echo "$title" | sed 's/[^a-zA-Z0-9_-]/_/g')
        note_file="$NOTES_DIR/${safe_title}.md"
        
        echo "# $title" > "$note_file"
        echo "" >> "$note_file"
        echo "创建时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$note_file"
        echo "标签: " >> "$note_file"
        echo "" >> "$note_file"
        echo "## 内容" >> "$note_file"
        echo "" >> "$note_file"
        
        echo "✅ 笔记已创建: $note_file"
        read -p "是否立即编辑? [y/N]: " edit_now
        if [[ $edit_now =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} "$note_file"
        fi
        ;;
    2)
        echo ""
        echo "📋 笔记列表:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if [ -z "$(ls -A $NOTES_DIR 2>/dev/null)" ]; then
            echo "暂无笔记"
        else
            ls -la "$NOTES_DIR"/*.md 2>/dev/null | while read line; do
                filename=$(basename "${line##* }" .md)
                modified=$(echo "$line" | awk '{print $6, $7, $8}')
                echo "📝 $filename ($modified)"
            done
        fi
        ;;
    3)
        echo ""
        read -p "🔍 请输入搜索关键词: " keyword
        if [ -n "$keyword" ]; then
            echo ""
            echo "搜索结果:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            grep -r -i "$keyword" "$NOTES_DIR"/*.md 2>/dev/null | while IFS=: read filename content; do
                note_name=$(basename "$filename" .md)
                echo "📝 $note_name: ${content:0:50}..."
            done
        fi
        ;;
    4)
        echo ""
        echo "📝 可编辑的笔记:"
        notes=($(ls "$NOTES_DIR"/*.md 2>/dev/null | xargs -n 1 basename -s .md))
        if [ ${#notes[@]} -eq 0 ]; then
            echo "暂无笔记可编辑"
        else
            for i in "${!notes[@]}"; do
                echo "$((i+1))) ${notes[i]}"
            done
            echo ""
            read -p "请选择笔记编号: " note_num
            if [[ $note_num =~ ^[0-9]+$ ]] && [ $note_num -ge 1 ] && [ $note_num -le ${#notes[@]} ]; then
                selected_note="${notes[$((note_num-1))]}"
                ${EDITOR:-nano} "$NOTES_DIR/$selected_note.md"
            else
                echo "❌ 无效选择"
            fi
        fi
        ;;
    5)
        echo ""
        echo "🗑️ 可删除的笔记:"
        notes=($(ls "$NOTES_DIR"/*.md 2>/dev/null | xargs -n 1 basename -s .md))
        if [ ${#notes[@]} -eq 0 ]; then
            echo "暂无笔记可删除"
        else
            for i in "${!notes[@]}"; do
                echo "$((i+1))) ${notes[i]}"
            done
            echo ""
            read -p "请选择要删除的笔记编号: " note_num
            if [[ $note_num =~ ^[0-9]+$ ]] && [ $note_num -ge 1 ] && [ $note_num -le ${#notes[@]} ]; then
                selected_note="${notes[$((note_num-1))]}"
                read -p "确认删除 '$selected_note'? [y/N]: " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    rm "$NOTES_DIR/$selected_note.md"
                    echo "✅ 笔记已删除"
                else
                    echo "❌ 删除已取消"
                fi
            else
                echo "❌ 无效选择"
            fi
        fi
        ;;
    6)
        today=$(date +%Y-%m-%d)
        today_note="$NOTES_DIR/daily_$today.md"
        
        if [ ! -f "$today_note" ]; then
            echo "# 每日记录 - $today" > "$today_note"
            echo "" >> "$today_note"
            echo "## 📋 今日任务" >> "$today_note"
            echo "- [ ] " >> "$today_note"
            echo "" >> "$today_note"
            echo "## 💭 想法记录" >> "$today_note"
            echo "" >> "$today_note"
            echo "## 📚 学习笔记" >> "$today_note"
            echo "" >> "$today_note"
            echo "## 🏆 今日总结" >> "$today_note"
            echo "" >> "$today_note"
        fi
        
        echo "📊 打开今日笔记: $today_note"
        ${EDITOR:-nano} "$today_note"
        ;;
    7)
        backup_dir="$HOME/.tmux/notes_backup/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$NOTES_DIR"/* "$backup_dir/" 2>/dev/null
        echo "💾 笔记已备份到: $backup_dir"
        ;;
    8)
        echo "📁 笔记目录: $NOTES_DIR"
        if command -v ranger >/dev/null 2>&1; then
            ranger "$NOTES_DIR"
        elif command -v ls >/dev/null 2>&1; then
            ls -la "$NOTES_DIR"
        else
            echo "📂 请手动打开目录: $NOTES_DIR"
        fi
        ;;
    0)
        echo "❌ 已退出"
        exit 0
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac

echo ""
echo "按任意键继续..."
read 