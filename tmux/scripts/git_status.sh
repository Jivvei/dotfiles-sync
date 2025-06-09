#!/bin/bash

# Git状态查看和操作脚本
# 用于快速Git操作

echo "🔧 Git 状态和操作"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查是否在Git仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 当前目录不是Git仓库"
    echo ""
    read -p "是否初始化Git仓库? [y/N]: " init_git
    if [[ $init_git =~ ^[Yy]$ ]]; then
        git init
        echo "✅ Git仓库已初始化"
    fi
    echo ""
    echo "按任意键继续..."
    read
    exit 0
fi

# 显示基本Git信息
echo "📁 仓库信息:"
echo "   路径: $(pwd)"
echo "   分支: $(git branch --show-current 2>/dev/null || echo '未知')"
echo "   远程: $(git remote get-url origin 2>/dev/null || echo '无远程仓库')"

echo ""

# 显示Git状态
echo "📊 当前状态:"
git_status=$(git status --porcelain)
if [ -z "$git_status" ]; then
    echo "   ✅ 工作目录干净"
else
    echo "   📝 有未提交的更改:"
    git status --short | head -10
    [ $(git status --porcelain | wc -l) -gt 10 ] && echo "   ... 还有更多文件"
fi

echo ""

# 显示最近的提交
echo "📈 最近提交:"
git log --oneline -5 2>/dev/null | while read line; do
    echo "   $line"
done

echo ""
echo "选择操作:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) 📊 查看详细状态      - git status"
echo "2) 📈 查看提交历史      - git log"
echo "3) 🔍 查看文件差异      - git diff"
echo "4) 📥 拉取远程更新      - git pull"
echo "5) 📤 推送到远程        - git push"
echo "6) 💾 快速提交          - add + commit"
echo "7) 🌿 分支管理          - 分支操作"
echo "8) 🔄 同步操作          - pull + push"
echo "9) 🏷️  标签管理          - tag操作"
echo "0) ❌ 退出"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "请选择操作 [0-9]: " choice

case $choice in
    1)
        echo ""
        echo "📊 详细Git状态:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        git status
        ;;
    2)
        echo ""
        echo "📈 提交历史:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        read -p "显示多少条记录? [默认20]: " log_count
        log_count=${log_count:-20}
        git log --oneline --graph -$log_count
        ;;
    3)
        echo ""
        echo "🔍 文件差异:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1) 工作目录 vs 暂存区"
        echo "2) 暂存区 vs 最新提交"
        echo "3) 指定文件差异"
        read -p "选择差异类型 [1-3]: " diff_type
        case $diff_type in
            1) git diff ;;
            2) git diff --cached ;;
            3) 
                read -p "请输入文件名: " filename
                if [ -n "$filename" ]; then
                    git diff "$filename"
                fi
                ;;
        esac
        ;;
    4)
        echo ""
        echo "📥 拉取远程更新..."
        git pull
        ;;
    5)
        echo ""
        echo "📤 推送到远程..."
        current_branch=$(git branch --show-current)
        git push origin "$current_branch"
        ;;
    6)
        echo ""
        echo "💾 快速提交:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # 显示将要添加的文件
        echo "将要添加的文件:"
        git status --porcelain | head -10
        echo ""
        
        read -p "是否添加所有更改? [Y/n]: " add_all
        if [[ ! $add_all =~ ^[Nn]$ ]]; then
            git add .
            echo "✅ 文件已添加到暂存区"
        fi
        
        read -p "请输入提交信息: " commit_msg
        if [ -n "$commit_msg" ]; then
            git commit -m "$commit_msg"
            echo "✅ 提交完成"
            
            read -p "是否推送到远程? [y/N]: " push_now
            if [[ $push_now =~ ^[Yy]$ ]]; then
                current_branch=$(git branch --show-current)
                git push origin "$current_branch"
            fi
        else
            echo "❌ 提交信息不能为空"
        fi
        ;;
    7)
        echo ""
        echo "🌿 分支管理:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "当前分支: $(git branch --show-current)"
        echo ""
        echo "所有分支:"
        git branch -a
        echo ""
        echo "1) 创建新分支"
        echo "2) 切换分支"
        echo "3) 删除分支"
        echo "4) 合并分支"
        read -p "选择操作 [1-4]: " branch_op
        case $branch_op in
            1)
                read -p "新分支名称: " new_branch
                if [ -n "$new_branch" ]; then
                    git checkout -b "$new_branch"
                fi
                ;;
            2)
                read -p "要切换的分支名: " switch_branch
                if [ -n "$switch_branch" ]; then
                    git checkout "$switch_branch"
                fi
                ;;
            3)
                read -p "要删除的分支名: " delete_branch
                if [ -n "$delete_branch" ]; then
                    git branch -d "$delete_branch"
                fi
                ;;
            4)
                read -p "要合并的分支名: " merge_branch
                if [ -n "$merge_branch" ]; then
                    git merge "$merge_branch"
                fi
                ;;
        esac
        ;;
    8)
        echo ""
        echo "🔄 同步操作..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # 检查是否有未提交的更改
        if [ -n "$(git status --porcelain)" ]; then
            echo "⚠️  检测到未提交的更改"
            read -p "是否先提交这些更改? [Y/n]: " commit_first
            if [[ ! $commit_first =~ ^[Nn]$ ]]; then
                read -p "提交信息: " auto_commit_msg
                commit_msg=${auto_commit_msg:-"Auto commit before sync"}
                git add .
                git commit -m "$commit_msg"
            fi
        fi
        
        echo "📥 拉取远程更新..."
        git pull
        
        echo "📤 推送本地更改..."
        current_branch=$(git branch --show-current)
        git push origin "$current_branch"
        
        echo "✅ 同步完成"
        ;;
    9)
        echo ""
        echo "🏷️ 标签管理:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "现有标签:"
        git tag -l | head -10
        echo ""
        echo "1) 创建标签"
        echo "2) 删除标签"
        echo "3) 推送标签"
        read -p "选择操作 [1-3]: " tag_op
        case $tag_op in
            1)
                read -p "标签名称: " tag_name
                read -p "标签说明 (可选): " tag_msg
                if [ -n "$tag_name" ]; then
                    if [ -n "$tag_msg" ]; then
                        git tag -a "$tag_name" -m "$tag_msg"
                    else
                        git tag "$tag_name"
                    fi
                fi
                ;;
            2)
                read -p "要删除的标签名: " delete_tag
                if [ -n "$delete_tag" ]; then
                    git tag -d "$delete_tag"
                fi
                ;;
            3)
                read -p "要推送的标签名 (留空推送所有): " push_tag
                if [ -n "$push_tag" ]; then
                    git push origin "$push_tag"
                else
                    git push origin --tags
                fi
                ;;
        esac
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