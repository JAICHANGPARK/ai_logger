# CHANGELOG

## 2026.6.2

- Added default Rust-style diagnostic output for warning/error/fatal events.
- Added final `# Diagnostic` sections to Markdown runtime and static analysis
  reports.
- Added report output options for choosing format, writer, and source loader.
- Added structured log events, sinks, redaction, context, breadcrumbs, guarded
  zone capture, stack trace parsing, report generation, and CLI commands.
- Added JSONL persistence through `FileJsonlSink`.
- Added `package:logging` and `package:logger` adapters.
- Added `dart run ai_logger_core analyze` for AI-friendly static analysis
  reports.
