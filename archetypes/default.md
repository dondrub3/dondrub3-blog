---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date.Format "2006-01-02T15:04:05+08:00" }}
draft: true

# SEO优化元数据
description: "文章摘要，控制在150-160字符之间，包含主要关键词"
keywords: ["关键词1", "关键词2", "关键词3"]
author: "东周"

# 分类和标签
tags: []
categories: []

# 特色图片（用于社交媒体分享）
image: "/images/posts/{{ .Name }}.jpg"
image_alt: "图片描述"

# 结构化数据
type: "article"  # article, tutorial, case-study, review
readingTime: true
showToc: true
tocOpen: false

# 系列文章（可选）
series: []
series_weight: 0

# 相关文章（可选）
related: []
---

## 引言

文章内容从这里开始...

<!--more-->

## 主要内容

## 结论

## 参考文献