# 博客部署指南

## 部署流程

本博客使用 **GitHub Actions** 自动构建和部署到 GitHub Pages。

### 重要：部署机制

- **构建方式**: GitHub Actions 工作流 (`.github/workflows/hugo.yml`)
- **触发条件**: 推送到 `main` 分支
- **部署目标**: GitHub Pages
- **构建输出**: `gh-pages` 分支（自动生成，不要手动修改）

### 正确部署步骤

#### 方法 1: 使用部署脚本（推荐）

```bash
cd /root/.openclaw/workspace/dondrub3-blog

# 部署 posts 目录的新文章
./deploy-blog.sh posts

# 部署 jibai 目录的新文章
./deploy-blog.sh jibai
```

#### 方法 2: 手动部署

```bash
cd /root/.openclaw/workspace/dondrub3-blog

# 1. 添加新文章
git add content/posts/2026-04-22-新文章.md

# 2. 提交到 main 分支
git commit -m "Add: 2026-04-22 新文章"

# 3. 推送到 main 分支（触发 GitHub Actions）
git push origin main
```

#### 方法 3: 文章生成器自动部署

```python
from article_generator import ImprovedArticleGenerator

generator = ImprovedArticleGenerator()
article = generator.generate_article(signal)

# 保存并自动部署
filepath = generator.save_article(article, signal, auto_deploy=True)
```

### 验证部署

推送后，GitHub Actions 会自动运行：

1. **查看构建状态**: https://github.com/dondrub3/dondrub3-blog/actions
2. **等待时间**: 通常 30-60 秒
3. **验证链接**: 
   - 文章页面: `https://dondrub3.com/posts/YYYY-MM-DD-文章名/`
   - 既白列表: `https://dondrub3.com/jibai/`

### 常见问题

#### Q: 为什么推送到 gh-pages 分支无效？
**A**: GitHub Pages 使用 GitHub Actions 构建，不是直接从 gh-pages 分支读取。必须通过推送 main 分支触发工作流。

#### Q: 如何强制重新部署？
**A**: 创建一个空提交并推送：
```bash
git commit --allow-empty -m "Trigger rebuild"
git push origin main
```

#### Q: 部署后文章没有显示？
**A**: 
1. 检查 GitHub Actions 是否成功运行
2. 等待 30-60 秒让缓存刷新
3. 尝试强制刷新浏览器（Ctrl+F5）

### 目录结构

```
dondrub3-blog/
├── content/
│   ├── posts/          # 3P分析文章
│   └── jibai/          # 既白产品故事
├── .github/
│   └── workflows/
│       └── hugo.yml    # GitHub Actions 工作流
├── deploy-blog.sh      # 部署脚本
└── DEPLOY.md           # 本文件
```

### 注意事项

1. **永远不要直接修改 `gh-pages` 分支** - 它会被 GitHub Actions 自动覆盖
2. **所有内容必须提交到 `main` 分支** - 这是唯一触发构建的方式
3. **不要手动运行 Hugo 构建** - GitHub Actions 会自动处理
4. **本地预览可用** - 运行 `hugo server -D` 在本地预览
