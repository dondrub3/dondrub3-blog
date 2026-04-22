#!/bin/bash
# 部署博客到 GitHub Pages（通过 GitHub Actions）
# 使用方法: ./deploy-blog.sh [文章类型: posts|jibai]

set -e

BLOG_DIR="/root/.openclaw/workspace/dondrub3-blog"
CONTENT_TYPE="${1:-posts}"  # 默认为 posts，可以是 jibai

echo "========================================"
echo "博客部署脚本"
echo "========================================"
echo "博客目录: $BLOG_DIR"
echo "内容类型: $CONTENT_TYPE"
echo ""

# 1. 检查是否在正确的目录
cd "$BLOG_DIR"

# 2. 检查是否有未提交的更改
if [ -n "$(git status --porcelain content/)" ]; then
    echo "📄 发现新的内容文件，准备提交..."
    
    # 添加内容文件
    git add "content/$CONTENT_TYPE/"
    
    # 提交更改
    git commit -m "Add: $(date '+%Y-%m-%d') 新文章 - $CONTENT_TYPE"
    
    # 推送到 main 分支（触发 GitHub Actions）
    echo "🚀 推送到 main 分支..."
    git push origin main
    
    echo "✅ 已推送，GitHub Actions 将自动构建和部署"
    echo ""
    echo "部署状态检查:"
    echo "  - 等待 30-60 秒后访问: https://dondrub3.com/$CONTENT_TYPE/"
    echo "  - GitHub Actions 运行记录: https://github.com/dondrub3/dondrub3-blog/actions"
else
    echo "⚠️ 没有新的内容文件需要部署"
fi

echo ""
echo "========================================"
echo "部署脚本完成"
echo "========================================"
