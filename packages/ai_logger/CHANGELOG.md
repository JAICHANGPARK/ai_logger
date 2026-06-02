# CHANGELOG

## 2026.6.2

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
