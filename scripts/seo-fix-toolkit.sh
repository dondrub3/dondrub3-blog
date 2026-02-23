#!/bin/bash
# SEO修复工具库 - 自动修复常见SEO问题

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查并修复robots.txt
fix_robots_txt() {
    log_info "检查robots.txt..."
    
    if [ ! -f "static/robots.txt" ]; then
        log_warning "robots.txt不存在，创建中..."
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
        log_success "robots.txt已创建"
    else
        log_success "robots.txt已存在"
    fi
    
    # 检查内容
    if ! grep -q "Sitemap:" static/robots.txt; then
        log_warning "robots.txt缺少sitemap引用，修复中..."
        echo -e "\n# 网站地图\nSitemap: https://dondrub3.com/sitemap.xml" >> static/robots.txt
        log_success "sitemap引用已添加"
    fi
}

# 检查并修复sitemap.xml
check_sitemap() {
    log_info "检查sitemap.xml..."
    
    if [ ! -f "public/sitemap.xml" ]; then
        log_warning "sitemap.xml不存在，重新构建网站..."
        hugo --minify
    fi
    
    if [ -f "public/sitemap.xml" ]; then
        sitemap_size=$(wc -l < public/sitemap.xml)
        log_success "sitemap.xml存在，包含 $sitemap_size 行"
    else
        log_error "sitemap.xml生成失败"
    fi
}

# 检查结构化数据
check_structured_data() {
    log_info "检查结构化数据..."
    
    if [ ! -f "layouts/partials/head/seo.html" ]; then
        log_error "SEO模板不存在，需要手动创建"
        return 1
    fi
    
    # 检查关键schema
    if grep -q "schema.org" layouts/partials/head/seo.html; then
        log_success "结构化数据模板存在"
    else
        log_error "结构化数据模板不完整"
    fi
}

# 检查文章元数据
check_post_metadata() {
    log_info "检查文章元数据..."
    
    missing_meta=0
    for post in content/posts/*.md; do
        if [ -f "$post" ]; then
            # 检查必要的元数据
            if ! grep -q "^description:" "$post"; then
                log_warning "$post 缺少description"
                missing_meta=$((missing_meta + 1))
            fi
            
            if ! grep -q "^keywords:" "$post"; then
                log_warning "$post 缺少keywords"
                missing_meta=$((missing_meta + 1))
            fi
            
            if ! grep -q "^image:" "$post"; then
                log_warning "$post 缺少image"
                missing_meta=$((missing_meta + 1))
            fi
        fi
    done
    
    if [ $missing_meta -eq 0 ]; then
        log_success "所有文章元数据完整"
    else
        log_warning "发现 $missing_meta 个元数据问题"
    fi
}

# 检查内部链接
check_internal_links() {
    log_info "检查内部链接..."
    
    # 检查是否有404链接
    broken_links=0
    for html_file in public/*.html public/**/*.html 2>/dev/null; do
        if [ -f "$html_file" ]; then
            # 简单检查图片链接
            img_links=$(grep -o 'src="[^"]*"' "$html_file" | cut -d'"' -f2 | grep -v "^http" | grep -v "^//")
            for img in $img_links; do
                if [ ! -f "public/$img" ] && [ ! -f "$img" ]; then
                    log_warning "图片链接可能损坏: $html_file -> $img"
                    broken_links=$((broken_links + 1))
                fi
            done
        fi
    done
    
    if [ $broken_links -eq 0 ]; then
        log_success "未发现损坏的内部链接"
    else
        log_warning "发现 $broken_links 个可能损坏的链接"
    fi
}

# 检查页面速度（简化版）
check_page_speed() {
    log_info "检查页面速度..."
    
    # 检查HTML文件大小
    large_files=0
    for html_file in public/*.html public/**/*.html 2>/dev/null; do
        if [ -f "$html_file" ]; then
            file_size=$(wc -c < "$html_file")
            if [ $file_size -gt 200000 ]; then
                log_warning "文件过大: $html_file ($file_size 字节)"
                large_files=$((large_files + 1))
            fi
        fi
    done
    
    if [ $large_files -eq 0 ]; then
        log_success "页面大小正常"
    else
        log_warning "发现 $large_files 个过大的页面文件"
    fi
}

# 生成SEO报告
generate_seo_report() {
    log_info "生成SEO报告..."
    
    report_file="memory/seo-report-$(date +%Y-%m-%d).md"
    
    cat > "$report_file" << EOF
# SEO优化报告 - $(date +%Y-%m-%d)

## 执行时间
$(date)

## 检查项目

### 1. robots.txt
$(if [ -f "static/robots.txt" ]; then echo "✅ 存在"; else echo "❌ 缺失"; fi)

### 2. sitemap.xml
$(if [ -f "public/sitemap.xml" ]; then echo "✅ 存在"; else echo "❌ 缺失"; fi)

### 3. 结构化数据
$(if [ -f "layouts/partials/head/seo.html" ]; then echo "✅ 模板存在"; else echo "❌ 模板缺失"; fi)

### 4. 文章元数据
文章数量: $(ls content/posts/*.md 2>/dev/null | wc -l)

### 5. 内部链接
$(if [ $broken_links -eq 0 ]; then echo "✅ 未发现损坏链接"; else echo "⚠️ 发现 $broken_links 个可能损坏的链接"; fi)

### 6. 页面速度
$(if [ $large_files -eq 0 ]; then echo "✅ 页面大小正常"; else echo "⚠️ 发现 $large_files 个过大的页面文件"; fi)

## 修复操作
$(if [ -f "static/robots.txt" ] && [ ! -f "static/robots.txt.bak" ]; then echo "- 创建/修复了robots.txt"; fi)

## 建议
1. 定期运行此检查脚本
2. 监控Google Search Console
3. 持续优化内容质量
4. 建立外链策略

## 下次检查
建议下次检查时间: $(date -d "+7 days" +%Y-%m-%d)
EOF
    
    log_success "SEO报告已生成: $report_file"
}

# 主函数
main() {
    log_info "开始SEO检查与修复..."
    
    # 进入博客目录
    cd /root/.openclaw/workspace/dondrub3-blog || {
        log_error "无法进入博客目录"
        exit 1
    }
    
    # 执行各项检查
    fix_robots_txt
    check_sitemap
    check_structured_data
    check_post_metadata
    check_internal_links
    check_page_speed
    
    # 重新构建网站
    log_info "重新构建网站..."
    hugo --minify 2>/dev/null || {
        log_error "网站构建失败"
        exit 1
    }
    
    # 生成报告
    generate_seo_report
    
    log_success "SEO检查与修复完成！"
}

# 执行主函数
main "$@"