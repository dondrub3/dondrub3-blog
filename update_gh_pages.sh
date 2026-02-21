#!/bin/bash

# 切换到 gh-pages 分支
git checkout gh-pages

# 备份当前的简单 HTML 文件
cp index.html index.html.backup
cp about.html about.html.backup

# 创建文章目录
mkdir -p posts

# 转换关于页面
echo "转换关于页面..."
pandoc content/about/_index.md -f markdown -t html -o about-new.html 2>/dev/null || {
    echo "使用简单转换..."
    cat > about-new.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>关于 - Dondrub3 | 3P实验室</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        header { border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 40px; }
        nav a { margin-right: 20px; text-decoration: none; color: #333; }
        nav a:hover { text-decoration: underline; }
        h1 { color: #333; }
        h2 { color: #555; margin-top: 30px; }
        h3 { color: #777; }
        footer { margin-top: 50px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <header>
        <h1>Dondrub3 | 3P实验室</h1>
        <nav>
            <a href="index.html">首页</a>
            <a href="about.html">关于</a>
            <a href="posts/">文章</a>
        </nav>
    </header>
    
    <main>
EOF

    # 读取 Markdown 内容并简单转换
    sed -e 's/^# \(.*\)$/<h1>\1<\/h1>/' \
        -e 's/^## \(.*\)$/<h2>\1<\/h2>/' \
        -e 's/^### \(.*\)$/<h3>\1<\/h3>/' \
        -e 's/^#### \(.*\)$/<h4>\1<\/h4>/' \
        -e 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g' \
        -e 's/\*\([^*]*\)\*/<em>\1<\/em>/g' \
        -e 's/^- \(.*\)$/<li>\1<\/li>/' \
        -e 's/^[0-9]\. \(.*\)$/<li>\1<\/li>/' \
        content/about/_index.md | \
        sed '/^---$/,/^---$/d' | \
        sed '/^$/d' >> about-new.html

    cat >> about-new.html << 'EOF'
    </main>
    
    <footer>
        <p>© 2026 Dondrub3 | 哲学 · 物理 · 心理学 | 量化交易与心智探索</p>
        <p>网站: <a href="https://dondrub3.com">https://dondrub3.com</a></p>
    </footer>
</body>
</html>
EOF
}

# 转换文章
echo "转换文章..."
ARTICLE_FILE="content/posts/2026-02-21-ai-product-psychology.md"
ARTICLE_SLUG="ai-product-psychology"

mkdir -p "posts/${ARTICLE_SLUG}"

cat > "posts/${ARTICLE_SLUG}/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>当AI产品设计遇上用户心理：智谱GLM Coding Plan事件的心理学解读 - Dondrub3</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        header { border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 40px; }
        nav a { margin-right: 20px; text-decoration: none; color: #333; }
        nav a:hover { text-decoration: underline; }
        .article-header { margin-bottom: 40px; }
        .article-meta { color: #666; font-size: 0.9em; margin-bottom: 20px; }
        .article-content h2 { color: #333; margin-top: 40px; }
        .article-content h3 { color: #555; margin-top: 30px; }
        .article-content p { margin-bottom: 20px; }
        .article-content ul, .article-content ol { margin-left: 20px; margin-bottom: 20px; }
        footer { margin-top: 50px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 0.9em; }
        .back-link { display: inline-block; margin-top: 30px; }
    </style>
</head>
<body>
    <header>
        <h1>Dondrub3 | 3P实验室</h1>
        <nav>
            <a href="../../index.html">首页</a>
            <a href="../../about.html">关于</a>
            <a href="../">文章</a>
        </nav>
    </header>
    
    <main>
        <article class="article-content">
EOF

# 提取文章标题和元数据
TITLE=$(grep -m1 '^title:' "$ARTICLE_FILE" | cut -d'"' -f2)
DATE=$(grep -m1 '^date:' "$ARTICLE_FILE" | cut -d' ' -f2)
AUTHOR=$(grep -m1 '^author:' "$ARTICLE_FILE" | cut -d'"' -f2)
CATEGORIES=$(grep -m1 '^categories:' "$ARTICLE_FILE" | cut -d'[' -f2 | cut -d']' -f1)
TAGS=$(grep -m1 '^tags:' "$ARTICLE_FILE" | cut -d'[' -f2 | cut -d']' -f1)
DESCRIPTION=$(grep -m1 '^description:' "$ARTICLE_FILE" | cut -d'"' -f2)

cat >> "posts/${ARTICLE_SLUG}/index.html" << EOF
            <div class="article-header">
                <h1>${TITLE}</h1>
                <div class="article-meta">
                    <span>作者: ${AUTHOR}</span> | 
                    <span>日期: ${DATE}</span> | 
                    <span>分类: ${CATEGORIES}</span> | 
                    <span>标签: ${TAGS}</span>
                </div>
                <p><em>${DESCRIPTION}</em></p>
            </div>
EOF

# 转换文章内容（跳过 Front Matter）
sed -n '/^---$/,/^---$/d; /^$/!p' "$ARTICLE_FILE" | \
    sed -e 's/^# \(.*\)$/<h2>\1<\/h2>/' \
        -e 's/^## \(.*\)$/<h3>\1<\/h3>/' \
        -e 's/^### \(.*\)$/<h4>\1<\/h4>/' \
        -e 's/^#### \(.*\)$/<h5>\1<\/h5>/' \
        -e 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g' \
        -e 's/\*\([^*]*\)\*/<em>\1<\/em>/g' \
        -e 's/^- \(.*\)$/<li>\1<\/li>/' \
        -e 's/^[0-9]\. \(.*\)$/<li>\1<\/li>/' \
        -e 's/`\([^`]*\)`/<code>\1<\/code>/g' \
        -e 's/\[\([^]]*\)\](\([^)]*\))/<a href="\2">\1<\/a>/g' >> "posts/${ARTICLE_SLUG}/index.html"

cat >> "posts/${ARTICLE_SLUG}/index.html" << 'EOF'
        </article>
        
        <a href="../" class="back-link">← 返回文章列表</a>
    </main>
    
    <footer>
        <p>© 2026 Dondrub3 | 哲学 · 物理 · 心理学 | 量化交易与心智探索</p>
        <p>网站: <a href="https://dondrub3.com">https://dondrub3.com</a></p>
    </footer>
</body>
</html>
EOF

# 创建文章列表页
cat > posts/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>文章 - Dondrub3 | 3P实验室</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        header { border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 40px; }
        nav a { margin-right: 20px; text-decoration: none; color: #333; }
        nav a:hover { text-decoration: underline; }
        .article-list { list-style: none; padding: 0; }
        .article-item { border-bottom: 1px solid #eee; padding: 20px 0; }
        .article-title { font-size: 1.2em; margin-bottom: 5px; }
        .article-title a { text-decoration: none; color: #333; }
        .article-title a:hover { text-decoration: underline; }
        .article-meta { color: #666; font-size: 0.9em; margin-bottom: 10px; }
        .article-excerpt { color: #555; }
        footer { margin-top: 50px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <header>
        <h1>Dondrub3 | 3P实验室</h1>
        <nav>
            <a href="../index.html">首页</a>
            <a href="../about.html">关于</a>
            <a href="index.html">文章</a>
        </nav>
    </header>
    
    <main>
        <h2>所有文章</h2>
        
        <ul class="article-list">
            <li class="article-item">
                <div class="article-title">
                    <a href="ai-product-psychology/index.html">当AI产品设计遇上用户心理：智谱GLM Coding Plan事件的心理学解读</a>
                </div>
                <div class="article-meta">
                    <span>作者: 东周</span> | 
                    <span>日期: 2026-02-21</span> | 
                    <span>分类: 心理学</span>
                </div>
                <div class="article-excerpt">
                    从心理学角度分析智谱GLM Coding Plan事件，探讨AI产品设计中的心理机制和用户信任建立。
                </div>
            </li>
        </ul>
    </main>
    
    <footer>
        <p>© 2026 Dondrub3 | 哲学 · 物理 · 心理学 | 量化交易与心智探索</p>
        <p>网站: <a href="https://dondrub3.com">https://dondrub3.com</a></p>
    </footer>
</body>
</html>
EOF

# 更新首页，添加文章链接
echo "更新首页..."
sed -i '/<h2>最新文章<\/h2>/,$d' index.html
cat >> index.html << 'EOF'
        <h2>最新文章</h2>
        <ul>
            <li><a href="posts/ai-product-psychology/index.html">当AI产品设计遇上用户心理：智谱GLM Coding Plan事件的心理学解读</a> (2026-02-21)</li>
        </ul>
        
        <h2>快速链接</h2>
        <ul>
            <li><a href="about.html">关于 3P 实验室</a></li>
            <li><a href="posts/">浏览所有文章</a></li>
        </ul>
    </main>
    
    <footer>
        <p>© 2026 Dondrub3 | 哲学 · 物理 · 心理学 | 量化交易与心智探索</p>
        <p>网站: <a href="https://dondrub3.com">https://dondrub3.com</a></p>
    </footer>
</body>
</html>
EOF

# 替换关于页面
mv about-new.html about.html

echo "更新完成！"
echo "请运行: git add . && git commit -m '添加文章内容' && git push origin gh-pages"