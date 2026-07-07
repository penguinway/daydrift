# 时光 · DayDrift

> 记录纪念日、心愿和彼此状态的 Flutter Android 应用。

时光 · DayDrift 以温暖木纹视觉为主，保留 Days Matter 风格的纪念日统计，同时新增心愿单和「TA在干嘛」实时状态同步能力。客户端数据默认保存在本机；实时状态功能需要自建 Node.js 服务端。

---

## 当前功能

- **纪念日记录**：添加、编辑、删除多个特殊日期。
- **天数展示**：同时展示已过去的总天数和年/月/日拆分。
- **纪念日提醒**：支持当天、提前 1 天、3 天、7 天提醒，并可选择提醒时间。
- **心愿单**：记录标题、备注、分类、目标日期和状态。
- **心愿分类**：内置旅行、美食、体验、购物、学习，支持自定义分类。
- **状态流转**：心愿可在「想做 → 计划中 → 已完成」之间切换，已完成项可折叠。
- **TA在干嘛**：通过用户 ID 登录配对，展示对方当前前台 App，并通过 WebSocket 实时更新。
- **服务器设置**：App 内可配置自建服务端地址，默认 `http://10.0.2.2:3000` 适配 Android 模拟器。
- **本地持久化**：纪念日、心愿、分类、配对信息和服务端地址使用 SharedPreferences 保存。
- **Android 适配**：竖屏锁定、自适应图标、通知权限、使用情况访问权限入口。

---

## 环境状态

截至 2026-07-07，本机检查结果：

| 项目 | 状态 |
|------|------|
| Node.js | 可用，`node --version` 输出 `v24.14.0` |
| npm | 可用，`npm --version` 输出 `11.9.0`，但 PowerShell 显示全局 npm 路径权限警告 |
| 服务端依赖 | 未安装，`server/node_modules` 不存在 |
| Flutter/Dart CLI | 已解析到 `C:\dev\flutter\bin\flutter.bat` / `dart.bat`，但本次 `flutter --version`、`dart --version`、`flutter analyze`、`flutter test` 均超时，尚未完成验证 |

因此：Node 运行环境基本具备；Flutter 客户端环境还需要在本机终端里排查 CLI 启动超时后再确认。

---

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter 3.41.4 / Dart SDK `^3.11.1` | Android 客户端 |
| Riverpod 2.x | 状态管理 |
| SharedPreferences | 本地持久化 |
| flutter_local_notifications + timezone | 纪念日提醒 |
| Dio + web_socket_channel | HTTP / WebSocket 同步 |
| Android UsageStats + MethodChannel | 获取前台 App 状态 |
| Node.js + Express + ws | 实时状态同步服务端 |

---

## 安装与使用

面向用户安装、服务端启动、首次配对、权限开启和功能使用的完整步骤见 [安装使用说明](docs/installation-guide.md)。

---

## 本地开发

### 客户端

环境要求：Flutter 3.41.4+、JDK 17+、Android Studio / Android SDK。

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release --split-per-abi
```

`flutter run` 需要连接 Android 设备或启动模拟器。若使用「TA在干嘛」功能，真机需要在系统设置中授予“使用情况访问权限”；Android 13+ 还需要通知权限。

### 服务端

```bash
cd server
npm install
npm start
```

开发时可使用：

```bash
npm run dev
```

服务默认监听 `http://0.0.0.0:3000`，健康检查为：

```bash
curl http://localhost:3000/api/health
```

首次使用前需要登记配对关系：

```bash
curl -X POST http://localhost:3000/api/admin/pair \
  -H "Content-Type: application/json" \
  -d '{"user1":"alice","user2":"bob"}'
```

---

## 项目结构

```text
lib/
├── main.dart                    # 应用入口、主题、竖屏锁定
├── models/                      # Event/Wish/Pair/Status 数据模型
├── repositories/                # SharedPreferences 读写
├── providers/                   # Riverpod AsyncNotifier / StreamProvider
├── screens/                     # 时光、心愿、TA、编辑页
├── services/                    # 通知、实时同步、UsageStats 桥接
├── utils/                       # 日期计算工具
└── widgets/                     # 事件卡片、心愿卡片、天数展示

android/                         # Android 权限、Gradle、原生 MethodChannel
server/                          # Express + WebSocket 实时同步服务
test/                            # Flutter 测试
docs/superpowers/specs/          # 功能设计文档
```

---

## 发布

推送符合 `v*.*.*` 的 tag 会触发 GitHub Actions：安装依赖、运行 `flutter analyze`、运行 `flutter test`，并构建 split APK 发布到 GitHub Release。

构建产物：

| 文件 | 适用设备 |
|------|------|
| `app-arm64-v8a-release.apk` | 现代 Android 手机（推荐） |
| `app-armeabi-v7a-release.apk` | 旧款 Android 手机 |
| `app-x86_64-release.apk` | 模拟器 |

---

## License

MIT © [penguinway](https://github.com/penguinway)
