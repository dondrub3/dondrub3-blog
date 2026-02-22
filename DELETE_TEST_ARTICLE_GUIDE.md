# 删除测试GitHub Actions构建文章指南

## 问题描述
测试文章"测试 GitHub Actions 构建"仍然出现在博客的posts列表中，需要手动删除。

## 当前状态
- 本地已删除：`content/posts/test-github-actions.md`
- 本地已删除：`public/posts/test-github-actions/`
- 本地已重新构建：Hugo生成42个页面（之前51个）
- 网站仍显示：https://dondrub3.com/ 仍显示测试文章

## 解决方案

### 方案1：通过GitHub Web界面删除（推荐）
1. 访问 https://github.com/dondrub3/dondrub3-blog
2. 导航到 `content/posts/test-github-actions.md`
3. 点击"Delete"按钮删除文件
4. GitHub Actions会自动触发构建和部署
5. 等待几分钟后检查 https://dondrub3.com/

### 方案2：手动触发GitHub Actions构建
1. 访问 https://github.com/dondrub3/dondrub3-blog/actions
2. 找到"Hugo Build and Deploy"工作流
3. 点击"Run workflow"手动触发
4. 选择"main"分支
5. 等待构建完成

### 方案3：本地Git推送（如果网络允许）
```bash
# 在本地仓库执行
cd /root/.openclaw/workspace/dondrub3-blog
git push origin main
```

## 验证方法
1. 访问 https://dondrub3.com/
2. 确认测试文章不再显示
3. 访问 https://dondrub3.com/posts/
4. 确认只显示3篇心理学文章

## 预期结果
- 首页只显示3篇心理学深度分析文章
- Posts列表只包含：
  1. 《当AI产品设计遇上用户心理：智谱GLM Coding Plan事件的心理学解读》
  2. 《最高法院裁决与群体心理：当法律遇上集体情绪》
  3. 《公众人物的道德困境：从比尔·盖茨取消AI峰会演讲看决策心理学》

## 技术说明
- 测试文章文件：`content/posts/test-github-actions.md`
- 生成目录：`public/posts/test-github-actions/`
- 相关标签：GitHub Actions、Hugo、测试
- 相关分类：测试

## 创建时间
2026年2月22日 04:50 GMT+8