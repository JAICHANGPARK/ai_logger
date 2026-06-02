# CHANGELOG

## 2026.6.4

- Added web-only browser runtime hooks for `window.onerror` and
  `unhandledrejection`.
- Added Flutter Web runtime error classification for network/CORS, null or
  undefined JavaScript values, JavaScript interop, compiled `main.dart.js`
  locations, and unhandled promise rejections.
- Added redacted Web runtime context and refreshed the example with a Web error
  report path.

## 2026.6.3

- Refreshed the example app with warning events and Markdown/diagnostic/JSON
  report format selection.
- Applied Dart dot shorthand syntax where the static type context is clear.
- Bumped package version for pub.dev publishing after runtime diagnostic,
  recent signal filtering, and README metadata updates.
- Updated the `ai_logger_core` dependency constraint to `^2026.6.3`.

## 2026.6.2

- Re-exported level-filtered recent event queries and configurable recent signal
  levels from `ai_logger_core`.
- Expanded pub.dev README guidance and package metadata.
- Added default Rust-style diagnostic output for reportable Flutter runtime
  errors.
- Added final `# Diagnostic` sections to generated Markdown reports.
- Added Flutter app-level runtime capture for direct logs, `print`,
  `debugPrint`, `FlutterError.onError`, `PlatformDispatcher.onError`, route
  breadcrumbs, and adapter logs from `ai_logger_core`.
- Added guarded `runApp` and `runGuarded`.
- Added an example app with captured event display and copyable AI Markdown
  reports.
