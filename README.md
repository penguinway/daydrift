# 时光 · DayDrift

> 记录每一个值得铭记的日子，见证时光流逝。

一款受 Apple "Day Matter" 启发的 Flutter 应用，以温暖木纹为底，记录你生命中每一个特殊日期距今已过了多少天。

---

## 功能特性

- **多事件记录** — 添加任意数量的特殊日期
- **双格式展示** — 同时显示总天数与年/月/日细分
- **Days Matter 风格 UI** — 橙色渐变卡片 + 暖木纹背景
- **本地持久化** — 数据保存在设备本地，无需网络
- **长按编辑/删除** — 手势操作，体验流畅
- **Android 自适应图标** — 支持 Android 8+ Adaptive Icon

---

## 截图

> ![](https://image.penguinway.space/i/2026/03/08/69ad39d07c469.png)
>
> ![](https://image.penguinway.space/i/2026/03/08/69ad39ef05bd0.png)

---

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter 3.41 | 跨平台 UI 框架 |
| Riverpod 2.x | 状态管理 |
| SharedPreferences | 本地数据持久化 |
| Google Fonts (Inter) | 字体 |
| intl | 日期格式化 |
| uuid | 唯一 ID 生成 |

---

## 本地开发

### 环境要求

- Flutter SDK >= 3.0.0
- Android Studio + Android SDK 36
- JDK 17+

### 运行步骤

```bash
# 克隆项目
git clone https://github.com/penguinway/daydrift.git
cd daydrift

# 安装依赖
flutter pub get

# 运行（需要连接设备或启动模拟器）
flutter run

# 构建 Release APK
flutter build apk --release --split-per-abi
```

### 构建产物

| 文件 | 适用设备 |
|------|------|
| `app-arm64-v8a-release.apk` | 现代 Android 手机（推荐） |
| `app-armeabi-v7a-release.apk` | 旧款 Android 手机 |
| `app-x86_64-release.apk` | 模拟器 |

---

## 项目结构

```
lib/
├── main.dart                    # 入口
├── models/
│   └── event_model.dart         # 数据模型
├── repositories/
│   └── events_repository.dart   # SharedPreferences 读写
├── providers/
│   └── events_provider.dart     # Riverpod 状态管理
├── screens/
│   ├── home_screen.dart         # 主页
│   └── add_edit_screen.dart     # 新增/编辑页
├── widgets/
│   ├── event_card.dart          # 事件卡片
│   └── days_display.dart        # 天数展示组件
└── utils/
    └── date_calculator.dart     # 日期计算工具
```

---

## License

MIT © [penguinway](https://github.com/penguinway)
