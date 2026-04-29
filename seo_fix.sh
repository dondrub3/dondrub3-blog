#!/bin/bash
# SEO深度优化脚本
# 修复博客的SEO问题

cd /root/.openclaw/workspace/dondrub3-blog

echo "=== SEO优化开始 ==="

# 1. 删除重复标题的文章 - 保留每个重复组的最新版本
echo "1. 清理重复标题文章..."

# 删除重复的锂矿文章（保留4月27日的最新版本）
rm -f content/posts/2026-04-22-锂矿企业重启赚钱模式天齐锂业盈利最高预增18倍盐湖股份藏格矿.md
rm -f content/posts/2026-04-23-锂矿企业重启赚钱模式天齐锂业盈利最高预增18倍盐湖股份藏格矿.md
rm -f content/posts/2026-04-26-锂矿企业重启赚钱模式天齐锂业盈利最高预增18倍盐湖股份藏格矿.md
rm -f content/posts/2026-04-22-18.md  # 这是另一个重复的锂矿文章

# 删除重复的AI蛋白质折叠文章（只保留3月28日的最新版本）
rm -f content/posts/2026-03-23-ai-breakthrough-in-protein-fol-1036.md
rm -f content/posts/2026-03-23-ai-breakthrough-in-protein-fol-1038.md
rm -f content/posts/2026-03-23-ai-breakthrough-in-protein-fol.md
rm -f content/posts/2026-03-24-ai-breakthrough-in-protein-fol-0631.md
rm -f content/posts/2026-03-24-ai-breakthrough-in-protein-fol.md
rm -f content/posts/2026-03-25-ai-breakthrough-in-protein-fol.md
rm -f content/posts/2026-03-26-ai-breakthrough-in-protein-fol-0631.md
rm -f content/posts/2026-03-26-ai-breakthrough-in-protein-fol.md
rm -f content/posts/2026-03-27-ai-breakthrough-in-protein-fol.md

# 删除重复的Open Source LLM文章（只保留3月28日的最新版本）
rm -f content/posts/2026-03-23-open-source-llm-surpasses-gpt-.md
rm -f content/posts/2026-03-25-open-source-llm-surpasses-gpt.md
rm -f content/posts/2026-03-27-open-source-llm-surpasses-gpt.md

echo "   已删除重复文章"

# 2. 统计剩余文章数量
echo "2. 统计文章..."
ARTICLE_COUNT=$(ls content/posts/*.md | wc -l)
echo "   当前文章数量: $ARTICLE_COUNT"

# 3. 重新构建网站
echo "3. 重新构建Hugo网站..."
hugo --gc --minify

# 4. 检查sitemap
echo "4. 检查sitemap..."
URL_COUNT=$(grep -c "<url>" public/sitemap.xml)
echo "   Sitemap URL数量: $URL_COUNT"

# 5. 显示重复标题检查结果
echo "5. 重复标题检查结果..."
cd content/posts
echo "   锂矿相关文章:"
grep -l "锂矿企业重启" *.md 2>/dev/null | wc -l
echo "   AI蛋白质折叠相关文章:"
grep -l "AI Breakthrough in Protein Folding" *.md 2>/dev/null | wc -l
echo "   Open Source LLM相关文章:"
grep -l "Open Source LLM Surpasses GPT-4" *.md 2>/dev/null | wc -l

echo "=== SEO优化完成 ==="
