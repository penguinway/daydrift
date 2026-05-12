# 纪念日提醒 设计文档

## 概述

为 love_time 应用的现有事件系统添加本地通知提醒功能，支持年度循环提醒、提前提醒、用户自定义提醒时间。

## 数据模型变更

### EventModel 新增字段

| 字段 | 类型 | 说明 |
|------|------|------|
| reminderEnabled | bool | 是否开启提醒，默认 false |
| reminderDaysBefore | int | 提前几天提醒（0=当天，1/3/7 可选） |
| reminderHour | int | 提醒时间-小时（0-23） |
| reminderMinute | int | 提醒时间-分钟（0-59） |

默认提醒时间：08:00

### JSON 序列化兼容性
新字段使用可选值，旧数据加载时缺失字段取默认值（reminderEnabled=false），保证向后兼容。

## 通知调度逻辑

### 年度循环
- 计算下一个纪念日日期（今年或明年的同月同日）
- 如果 reminderDaysBefore > 0，提醒日期 = 纪念日 - reminderDaysBefore 天
- 使用 `zonedSchedule` 设置精确时间通知
- 通知触发后，需要重新调度下一年的通知（通过 app 启动时检查）

### 通知 ID
- 使用 `event.id.hashCode.abs() % 2147483647` 作为通知 ID
- 提前提醒和当天提醒使用不同 ID（hashCode 和 hashCode + 1）

### App 启动时
- 检查所有开启提醒的事件，重新调度未来的通知
- 确保通知不会因为 app 长时间未打开而丢失

## 交互设计

### 事件编辑页 (AddEditScreen)
在日期选择器下方新增提醒配置区域：
- 提醒开关（Switch）
- 开启后展开：
  - 提前天数选择（ChoiceChip: 当天 / 1天前 / 3天前 / 7天前）
  - 提醒时间选择（点击弹出 TimePicker）

### 保存逻辑
- 保存事件时，如果 reminderEnabled=true，调度通知
- 如果 reminderEnabled=false 或删除事件，取消对应通知

## 技术实现

### 新增依赖
- `flutter_local_notifications` — 本地通知
- `timezone` — 时区处理

### 新增文件
- `lib/services/notification_service.dart` — 单例服务，负责：
  - 初始化通知插件
  - 请求权限
  - 调度通知 (scheduleReminder)
  - 取消通知 (cancelReminder)
  - 重新调度所有通知 (rescheduleAll)

### 修改文件
- `lib/models/event_model.dart` — 新增提醒字段
- `lib/screens/add_edit_screen.dart` — 新增提醒配置 UI
- `lib/providers/events_provider.dart` — 保存/删除时调用通知服务
- `lib/main.dart` — 初始化通知服务，启动时 rescheduleAll
- `pubspec.yaml` — 添加依赖

### Android 配置
- `AndroidManifest.xml` 添加权限：
  - `RECEIVE_BOOT_COMPLETED`
  - `SCHEDULE_EXACT_ALARM`（Android 12+）
  - `POST_NOTIFICATIONS`（Android 13+）

## 通知内容

- 当天提醒标题：`🎉 今天是「{事件名}」纪念日！`
- 当天提醒内容：`已经 {N} 天了`
- 提前提醒标题：`📅 「{事件名}」纪念日还有 {X} 天`
- 提前提醒内容：`记得准备一下哦`

## 技术约束
- 纯本地实现，无网络依赖
- 保持现有 Riverpod + SharedPreferences 架构
- 向后兼容旧数据
