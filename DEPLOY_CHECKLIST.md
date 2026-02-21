# GitHub Actions 部署检查清单

## 前置条件
- [x] Hugo v0.146.0+ 已安装
- [x] PaperMod 主题配置正确
- [x] 本地构建成功
- [x] GitHub Actions 工作流配置正确

## 部署步骤
1. [ ] 推送更改到 main 分支
2. [ ] 监控 GitHub Actions 运行状态
3. [ ] 验证构建成功
4. [ ] 检查 GitHub Pages 部署
5. [ ] 访问网站验证更新

## 验证项目
- [ ] 首页加载正常
- [ ] 所有文章可访问
- [ ] 导航菜单工作正常
- [ ] 响应式设计正常
- [ ] HTTPS 证书有效

## 故障排除
1. 如果 GitHub Actions 失败：
   - 检查 Hugo 版本兼容性
   - 检查主题配置
   - 查看构建日志

2. 如果网站未更新：
   - 检查 GitHub Pages 设置
   - 验证 DNS 配置
   - 清除浏览器缓存
