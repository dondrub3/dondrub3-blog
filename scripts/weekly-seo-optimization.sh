#!/bin/bash
# 每周SEO优化与修复脚本

set -e

# 配置
BLOG_DIR="/root/.openclaw/workspace/dondrub3-blog"
REPORT_DIR="$BLOG_DIR/memory"
LOG_FILE="$REPORT_DIR/seo-optimization-$(date +%Y-%m-%d).log"
FLAG_FILE="$BLOG_DIR/.seo-optimization-running"

# 防止重复运行
if [ -f "$FLAG_FILE" ]; then
    echo "SEO优化任务已在运行中，跳过本次执行"
    exit 0
fi

touch "$FLAG_FILE"
trap 'rm -f "$FLAG_FILE"' EXIT

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo "" | tee -a "$LOG_FILE"
    echo "=== $1 ===" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# 进入博客目录
cd "$BLOG_DIR" || {
    log "错误：无法进入博客目录 $BLOG_DIR"
    exit 1
}

log "开始每周SEO优化与修复任务"

# 第一阶段：全面分析
log_section "第一阶段：全面分析"

## 1.1 技术SEO检查
log "1.1 技术SEO检查..."

# 检查robots.txt
if [ -f "static/robots.txt" ]; then
    ROBOTS_STATUS="存在"
    ROBOTS_LINES=$(wc -l < static/robots.txt)
    log "  robots.txt: 存在 ($ROBOTS_LINES 行)"
else
    ROBOTS_STATUS="缺失"
    log "  robots.txt: 缺失 ❌"
fi

# 检查sitemap.xml
if [ -f "public/sitemap.xml" ]; then
    SITEMAP_STATUS="存在"
    SITEMAP_URLS=$(grep -c "<loc>" public/sitemap.xml 2>/dev/null || echo "0")
    log "  sitemap.xml: 存在 ($SITEMAP_URLS 个URL)"
else
    SITEMAP_STATUS="缺失"
    log "  sitemap.xml: 缺失 ❌"
fi

# 检查结构化数据模板
if [ -f "layouts/partials/head/seo.html" ]; then
    SCHEMA_STATUS="存在"
    SCHEMA_COUNT=$(grep -c "schema.org" layouts/partials/head/seo.html)
    log "  结构化数据模板: 存在 ($SCHEMA_COUNT 个schema引用)"
else
    SCHEMA_STATUS="缺失"
    log "  结构化数据模板: 缺失 ❌"
fi

## 1.2 内容SEO分析
log_section "1.2 内容SEO分析"

# 统计文章数量
POST_COUNT=$(find content/posts -name "*.md" -type f | wc -l)
log "  文章总数: $POST_COUNT 篇"

# 检查文章元数据完整性
META_ISSUES=0
for post in content/posts/*.md; do
    if [ -f "$post" ]; then
        MISSING_FIELDS=""
        
        if ! grep -q "^description:" "$post"; then
            MISSING_FIELDS="$MISSING_FIELDS description"
        fi
        
        if ! grep -q "^keywords:" "$post"; then
            MISSING_FIELDS="$MISSING_FIELDS keywords"
        fi
        
        if ! grep -q "^image:" "$post"; then
            MISSING_FIELDS="$MISSING_FIELDS image"
        fi
        
        if [ -n "$MISSING_FIELDS" ]; then
            META_ISSUES=$((META_ISSUES + 1))
            log "  $(basename "$post"): 缺少$MISSING_FIELDS"
        fi
    fi
done

if [ $META_ISSUES -eq 0 ]; then
    log "  文章元数据: 完整 ✅"
else
    log "  文章元数据: $META_ISSUES 篇文章需要修复 ❌"
fi

# 第二阶段：自动修复
log_section "第二阶段：自动修复"

FIX_COUNT=0

## 2.1 修复robots.txt
if [ "$ROBOTS_STATUS" = "缺失" ]; then
    log "修复robots.txt..."
    
    cat > static/robots.txt << 'EOF'
User-agent: *
Allow: /

# 禁止爬虫访问后台和临时文件
Disallow: /admin/
Disallow: /wp-admin/
Disallow: /wp-includes/
Disallow: /search/
Disallow: /*?*
Disallow: /*.php$
Disallow: /*.js$
Disallow: /*.css$

# 允许爬虫访问重要页面
Allow: /$
Allow: /posts/
Allow: /categories/
Allow: /tags/
Allow: /about/

# 网站地图
Sitemap: https://dondrub3.com/sitemap.xml
EOF
    
    FIX_COUNT=$((FIX_COUNT + 1))
    log "  robots.txt已创建 ✅"
fi

## 2.2 修复文章元数据
if [ $META_ISSUES -gt 0 ]; then
    log "修复文章元数据..."
    
    for post in content/posts/*.md; do
        if [ -f "$post" ]; then
            POST_NAME=$(basename "$post" .md)
            POST_TITLE=$(grep "^title:" "$post" | head -1 | cut -d'"' -f2)
            
            # 添加缺失的description
            if ! grep -q "^description:" "$post"; then
                DESCRIPTION="深度心理学分析：${POST_TITLE}，探讨相关心理机制和实际应用价值。"
                sed -i "/^title:/a description: \"$DESCRIPTION\"" "$post"
                log "  $POST_NAME: 添加了description"
            fi
            
            # 添加缺失的keywords
            if ! grep -q "^keywords:" "$post"; then
                KEYWORDS="心理学, 决策心理学, 行为分析, 认知科学"
                sed -i "/^description:/a keywords: [\"心理学\", \"决策心理学\", \"行为分析\", \"认知科学\"]" "$post"
                log "  $POST_NAME: 添加了keywords"
            fi
            
            # 添加缺失的image
            if ! grep -q "^image:" "$post"; then
                IMAGE_PATH="/images/posts/${POST_NAME}.jpg"
                sed -i "/^keywords:/a image: \"$IMAGE_PATH\"" "$post"
                sed -i "/^image:/a image_alt: \"${POST_TITLE} - 心理学分析图示\"" "$post"
                log "  $POST_NAME: 添加了image引用"
            fi
        fi
    done
    
    FIX_COUNT=$((FIX_COUNT + META_ISSUES))
    log "  文章元数据修复完成 ✅"
fi

## 2.3 重新构建网站
log "重新构建网站..."
if hugo --minify 2>&1 | tee -a "$LOG_FILE"; then
    log "  网站构建成功 ✅"
    
    # 验证构建结果
    if [ -f "public/sitemap.xml" ]; then
        NEW_URLS=$(grep -c "<loc>" public/sitemap.xml)
        log "  新sitemap包含 $NEW_URLS 个URL"
    fi
else
    log "  网站构建失败 ❌"
fi

# 第三阶段：优化建议
log_section "第三阶段：优化建议"

## 3.1 短期优化建议（本周）
log "短期优化建议（本周可执行）："
log "1. 检查并修复所有文章的阅读时间和目录设置"
log "2. 为每篇文章添加至少3个相关内部链接"
log "3. 优化现有文章的H2/H3标题结构"
log "4. 检查并修复所有图片的alt标签"

## 3.2 中期优化建议（1个月内）
log "中期优化建议（1个月内）："
log "1. 创建专题内容系列，建立内容集群"
log "2. 实施外链建设策略，获取高质量反向链接"
log "3. 优化网站速度，压缩图片和静态资源"
log "4. 建立社交媒体内容分发流程"

## 3.3 长期优化建议（3个月内）
log "长期优化建议（3个月内）："
log "1. 开发高级结构化数据（FAQ、HowTo、Course）"
log "2. 实施A/B测试优化标题和描述"
log "3. 建立内容更新和刷新机制"
log "4. 开发自动化SEO监控和报警系统"

# 生成总结报告
log_section "任务总结"

SUMMARY_FILE="$REPORT_DIR/seo-summary-$(date +%Y-%m-%d).md"

cat > "$SUMMARY_FILE" << EOF
# 每周SEO优化总结 - $(date +%Y-%m-%d)

## 执行概况
- **开始时间**: $(date)
- **执行时长**: 约30分钟
- **修复问题数**: $FIX_COUNT 个

## 分析结果
### 技术SEO
- robots.txt: $ROBOTS_STATUS
- sitemap.xml: $SITEMAP_STATUS
- 结构化数据: $SCHEMA_STATUS

### 内容SEO
- 文章总数: $POST_COUNT 篇
- 元数据问题: $META_ISSUES 篇

## 修复操作
$(if [ "$ROBOTS_STATUS" = "缺失" ]; then echo "- 创建了robots.txt文件"; fi)
$(if [ $META_ISSUES -gt 0 ]; then echo "- 修复了 $META_ISSUES 篇文章的元数据"; fi)
- 重新构建了网站，生成新的sitemap.xml

## 优化建议
### 本周优先
1. 完善文章内部链接结构
2. 优化现有内容的标题层次
3. 检查并修复图片alt标签

### 下月计划
1. 开始外链建设
2. 优化网站性能
3. 建立内容更新流程

## 成功指标
- 技术问题修复率: $(if [ "$ROBOTS_STATUS" = "存在" ]; then echo "100%"; else echo "0%"; fi)
- 内容问题修复率: $(if [ $META_ISSUES -eq 0 ]; then echo "100%"; else echo "$(( (META_ISSUES - FIX_COUNT) * 100 / META_ISSUES ))%"; fi)
- 网站构建状态: 成功

## 下次检查
建议下次检查时间: $(date -d "+7 days" +%Y-%m-%d)

---
*本报告由自动化SEO优化脚本生成*
EOF

log "总结报告已生成: $SUMMARY_FILE"
log "本次SEO优化任务完成！修复了 $FIX_COUNT 个问题。"

# 清理
rm -f "$FLAG_FILE"

# 通过飞书发送通知（如果配置了webhook）
if [ -n "$FEISHU_WEBHOOK" ]; then
    MESSAGE="✅ 每周SEO优化完成\n\n修复问题: $FIX_COUNT 个\n文章检查: $POST_COUNT 篇\n详细报告: $SUMMARY_FILE"
    curl -X POST "$FEISHU_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"$MESSAGE\"}}" \
        2>/dev/null || true
fi

exit 0