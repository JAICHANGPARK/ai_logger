# CHANGELOG

## 2026-06-02

### Flutter Web runtime diagnostics

- Added Flutter Web browser error hooks for `window.onerror` and
  `unhandledrejection` through a web-only conditional import.
- Added Web runtime error classification for network/CORS failures,
  null/undefined JavaScript errors, JavaScript interop errors, compiled
  `main.dart.js` stack locations, and unhandled promise rejections.
- Added redacted Web context such as current URL, user agent, and viewport to
  captured browser runtime errors.
- Refreshed the example with a simulated Web runtime error button and tests for
  diagnostic/JSON report output.
- Bumped `ai_logger` to `2026.6.4` and the example app to `2026.6.4+3`.

### Review hardening and example refresh

- Preserved parent-zone `print()` output while still capturing guarded prints as
  log events.
- Fixed report generation when `recentSignalLimit` is zero so the current
  reportable event remains available without recent context.
- Aligned CLI `report --last` selection with warning/error/fatal reportable
  events.
- Refreshed the Flutter example with warning events and Markdown/diagnostic/JSON
  report format selection.
- Applied Dart dot shorthand syntax where the static type context is clear.

### Version bump for publish

- Bumped `ai_logger_core` and `ai_logger` package versions to `2026.6.3`.
- Bumped the example app version to `2026.6.3+2`.
- Updated `ai_logger` to depend on `ai_logger_core: ^2026.6.3`.

### Pub.dev documentation and metadata

- Expanded root and package READMEs with installation, quick start,
  configuration, output format, and persistence guidance.
- Added pub.dev metadata fields for package documentation, issue tracker,
  topics, and supported platforms.

### Runtime diagnostic output

- Added level-filtered recent event queries and configurable recent signal
  levels for AI reports.
- Added default Rust-style diagnostic output for warning/error/fatal runtime
  events as soon as they are captured.
- Added final `# Diagnostic` sections to Markdown runtime and static analysis
  reports.
- Added `Options.printReports`, `Options.reportFormat`,
  `Options.reportWriter`, and `Options.reportSourceLoader` for configuring
  automatic report output.

### Version

- Set `ai_logger_core` and `ai_logger` package versions to `2026.6.2`.
- Set the example app version to `2026.6.2+1`.

### Runtime capture and AI report completion

- Wrapped `ai_logger.runApp` with a guarded zone so Flutter apps capture
  `print()` and uncaught zone errors through the normal app entrypoint.
- Added `runGuarded`, last-report helpers, `FileJsonlSink`, and adapters for
  `package:logging` and `package:logger`.
- Added `dart run ai_logger_core analyze` to transform `dart analyze` or
  `flutter analyze` output into AI-friendly Markdown, compact JSON, and
  Rust-style diagnostics while preserving analyzer exit codes.
- Added a full `packages/ai_logger/example` Flutter app with platform runners,
  runtime capture buttons, captured event display, and copyable AI Markdown
  report output.
- Verified Markdown and diagnostic CLI output against fixture JSONL and source
  frames.

### AI Logger PRD foundation

- Added the `packages/ai_logger_core` pure Dart package with level mapping,
  structured log events, sinks, redaction, breadcrumbs/context, guarded zone
  capture, stack frame parsing, AI-ready Markdown/compact JSON reports, and
  Rust-style diagnostic rendering.
- Added the `packages/ai_logger` Flutter package with core re-export,
  `runApp` hook installation, `FlutterError.onError` preservation,
  `PlatformDispatcher.onError` fatal capture, `debugPrint` capture, route
  breadcrumbs, and representative Flutter error classification.
- Added CLI support for `dart run ai_logger_core report --last` with
  `markdown`, `diagnostic`, and compact JSON formats.
- Added focused core and Flutter tests for serialization, redaction, report
  generation, diagnostic frames, hook preservation, debugPrint capture, and
  classifier fixtures.
- Added PRD work-unit notes under `docs/`.
