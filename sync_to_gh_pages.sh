#!/bin/bash

echo "1. 确保在 main 分支..."
git checkout main

echo "2. 复制内容文件到临时目录..."
mkdir -p /tmp/blog_content
cp -r content/ /tmp/blog_content/

echo "3. 切换到 gh-pages 分支..."
git checkout gh-pages

echo "4. 复制内容文件..."
cp -r /tmp/blog_content/content/ .

echo "5. 运行更新脚本..."
./update_gh_pages.sh

echo "6. 清理临时文件..."
rm -rf /tmp/blog_content

echo "完成！现在可以提交和推送了。"