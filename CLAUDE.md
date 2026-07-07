# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter pub get              # Install dependencies
flutter analyze              # Static analysis
flutter test                 # Run tests
flutter build apk --release  # Build release APK
flutter build apk --release --split-per-abi  # Build split APKs (for release)
```

Requires Java 17 and Flutter 3.41.4+. Android core library desugaring is enabled.

## Release Process

Push a git tag `v*.*.*` to trigger CI which builds split APKs and creates a GitHub Release.

## Architecture

**State management**: Riverpod with `AsyncNotifierProvider` pattern.

**Data flow**: Screen → Provider (AsyncNotifier) → Repository → SharedPreferences (JSON serialized).

**Layer structure**:
- `models/` — Data classes with `toJson`/`fromJson`/`copyWith`
- `repositories/` — SharedPreferences persistence (one per domain)
- `providers/` — Riverpod AsyncNotifiers (one per domain)
- `screens/` — Full-page widgets (ConsumerWidget/ConsumerStatefulWidget)
- `widgets/` — Reusable UI components
- `services/` — Singleton services (notifications, realtime status, Android usage stats)

**Navigation**: `MainShell` with `BottomNavigationBar` + `IndexedStack` (tabs: 时光, 心愿, TA). Sub-pages use imperative `Navigator.push`.

**Domains**:
1. Events (纪念日) — date tracking with day counting, optional local notification reminders
2. Wishes (心愿单) — wishlist with categories, status flow (todo → planning → completed)
3. Partner status (TA在干嘛) — paired user login, Android foreground-app reporting, WebSocket status updates via `server/`

## Visual Style

- Warm wood-grain background gradient (`#E8D5B0` → `#C8A878`)
- Orange accent: `#FF9500`
- Brown text: `#8B5E3C`
- White cards with shadows
- Font: Google Fonts Inter
- Material 3 dark theme (seed `#5C3317`)

## Key Conventions

- All UI text is in Chinese
- App name: 时光 · DayDrift
- Package: `com.ufomiao.love_time`
- Core event/wish data is local; partner status uses a self-hosted Node.js server
- Android-only (portrait locked)
- UUID v4 for entity IDs
