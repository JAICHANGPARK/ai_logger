# CHANGELOG

## 2026.6.3

- Preserved parent-zone `print()` output while still capturing guarded prints.
- Fixed report generation when `recentSignalLimit` is zero.
- Aligned CLI `report --last` selection with warning/error/fatal reportable
  events.
- Applied Dart dot shorthand syntax where the static type context is clear.
- Bumped package version for pub.dev publishing after runtime diagnostic,
  recent signal filtering, and README metadata updates.

## 2026.6.2

- Added `recentEventsWhere(levels: ...)` and `Options.recentSignalLevels` for
  selecting which captured levels are queried or included as report context.
- Expanded pub.dev README guidance and package metadata.
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
