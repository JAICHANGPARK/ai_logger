# CHANGELOG

## 2026-06-02

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
