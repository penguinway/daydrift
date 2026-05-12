# 编辑按钮颜色修复 + 共同心愿单 设计文档

## 概述

为 love_time 应用添加两个改进：
1. 修复底部菜单编辑按钮颜色过淡的问题
2. 新增"共同心愿单"功能模块

## 一、编辑按钮颜色修复

### 问题
底部弹出菜单中"编辑"选项的图标颜色（`Color(0xFFFF9500)` 橙色）在白色背景上对比度不足，视觉上偏淡。

### 方案
将编辑选项的图标和文字改为深灰色 `Color(0xFF3C3C3C)`，与红色"删除"形成清晰的视觉层级：
- 编辑 = 中性操作 → 深灰色
- 删除 = 危险操作 → 红色

### 涉及文件
- `lib/widgets/event_card.dart` — 修改编辑 ListTile 的 icon color

## 二、共同心愿单

### 导航结构
在 app 底部添加 BottomNavigationBar，两个 tab：
- 📅 时光（现有首页 HomeScreen）
- 💫 心愿（新增 WishlistScreen）

需要一个新的 shell/scaffold 页面来承载底部导航。

### 数据模型 (WishItem)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | UUID 唯一标识 |
| title | String | 心愿标题（必填） |
| description | String? | 备注描述（可选） |
| category | String | 分类标签（旅行/美食/体验/自定义） |
| targetDate | DateTime? | 目标日期（可选） |
| status | WishStatus | 想做 → 计划中 → 已完成 |
| createdAt | DateTime | 创建时间 |

### 状态枚举 (WishStatus)
- `todo` — 想做
- `planning` — 计划中
- `completed` — 已完成

### 页面设计

#### 心愿单列表页 (WishlistScreen)
- 顶部：横向滚动分类标签筛选（全部 / 旅行 / 美食 / 体验 / 自定义...）
- 列表：心愿卡片，显示标题、分类、状态徽章、目标日期
- 已完成心愿折叠显示在底部
- 右下角 FAB 添加新心愿
- 长按心愿卡片弹出菜单：切换状态 / 编辑 / 删除

#### 添加/编辑心愿页 (AddEditWishScreen)
- 标题输入（必填）
- 备注输入（多行文本，可选）
- 分类选择（预设 + 自定义输入）
- 目标日期选择器（可选）
- 状态选择（编辑时可切换）

### 存储方案
继续使用 SharedPreferences，JSON 序列化。key: `wishes_data`

### 架构（遵循现有模式）
- `lib/models/wish_model.dart` — WishItem 数据模型 + WishStatus 枚举
- `lib/repositories/wishes_repository.dart` — SharedPreferences 持久化
- `lib/providers/wishes_provider.dart` — Riverpod StateNotifier
- `lib/screens/wishlist_screen.dart` — 心愿单列表页
- `lib/screens/add_edit_wish_screen.dart` — 添加/编辑心愿页
- `lib/widgets/wish_card.dart` — 心愿卡片组件
- `lib/screens/main_shell.dart` — 底部导航 shell 页面

### 视觉风格
- 延续现有暖色木纹风格（背景 `0xFFE8D5B0`，渐变等）
- 心愿卡片设计语言与事件卡片一致
- 状态徽章颜色：想做=橙色，计划中=蓝色，已完成=绿色
- 分类标签用 Chip 组件

### 默认分类
预设分类：旅行、美食、体验、购物、学习
用户可在添加心愿时输入自定义分类，自动记录到分类列表中。

## 技术约束
- Flutter + Riverpod 状态管理
- SharedPreferences 本地存储
- 纯本地，无网络依赖
- 保持现有代码风格和架构模式
