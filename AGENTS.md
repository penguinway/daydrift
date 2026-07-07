# Repository Guidelines

## Project Structure & Module Organization

This repository is a Flutter Android app for `时光 · DayDrift`, plus an optional realtime status server.

- `lib/main.dart` boots the app and theme.
- `lib/models/`, `repositories/`, and `providers/` hold JSON models, SharedPreferences persistence, and Riverpod state.
- `lib/screens/`, `widgets/`, and `services/` hold pages, reusable UI, notifications, realtime status, and usage stats.
- `test/` contains Flutter widget tests, currently `widget_test.dart`.
- `assets/` stores app assets such as launcher icons.
- `android/` contains platform configuration; `server/` contains the Node.js sync service; `docs/` contains design notes.

## Build, Test, and Development Commands

Run commands from the repository root unless noted: `flutter pub get` installs dependencies, `flutter analyze` runs `flutter_lints`, `flutter test` runs tests, and `flutter run` launches a device or emulator build. Use `flutter build apk --release --split-per-abi` for release APKs. For the server, run `cd server && npm install`, then `npm run dev` for watch mode or `npm start` for normal startup.

## Coding Style & Naming Conventions

Use Dart defaults: two-space indentation, `lowerCamelCase` members, `UpperCamelCase` types/widgets, and `snake_case.dart` filenames. Follow the existing flow: screens call providers, providers call repositories, repositories handle storage. Keep UI text in Chinese and preserve `时光 · DayDrift`.

## Testing Guidelines

Use `flutter_test` for widget and unit coverage. Name test files with `_test.dart` under `test/`. Add tests for date calculations, provider behavior, repository serialization, and important widget smoke paths when modifying those areas. Run `flutter analyze` and `flutter test` before submitting.

## Commit & Pull Request Guidelines

Recent history uses Conventional Commits, sometimes with gitmoji, for example `feat: initial release`, `docs: add design spec`, and `ci: only trigger workflow on release tag push`. Prefer `type: concise summary`; common types are `feat`, `fix`, `docs`, `test`, `refactor`, and `ci`.

For pull requests, include a short description, test results, linked issue or spec, and screenshots or screen recordings for UI changes. Release builds are created by tags matching `v*.*.*`.

## Security & Configuration Tips

The app is designed for local storage. Do not commit secrets, signing keys, or machine-specific Android files. The server keeps pair and status data in memory; document persistence or auth changes in `server/README.md`.
