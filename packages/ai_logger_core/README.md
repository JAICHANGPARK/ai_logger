# ai_logger_core

**AI-friendly logger core for Dart packages, CLIs, services, and tests.**

`ai_logger_core` captures structured Dart app-level events and turns them into
formats that are easy for an AI to read or for a developer to copy into an AI
chat:

- compact JSONL source events
- AI-friendly Markdown reports
- compact JSON exports
- Rust-style diagnostics with source frames
- `dart analyze` / `flutter analyze` output conversion

By default, warning/error/fatal events print Rust-style diagnostics as soon as
they are captured. Markdown reports include the same diagnostic in a final
`# Diagnostic` block. Use `Options(printReports: false)` when you only want to
collect events and generate reports later.

## Installation

```bash
dart pub add ai_logger_core
```

## Quick Start

```dart
import 'package:ai_logger_core/ai_logger_core.dart' as ailog;

void main() {
  ailog.guard(() {
    ailog.i('server started');
    ailog.e('request failed', error: StateError('bad state'));

    final report = ailog.formatLastReport(ailog.ReportFormat.markdown);
    print(report);
  });
}
```

## Configuration

`captureLevel` decides what gets stored. `reportLevel` decides what becomes an
automatic AI-readable report.

```dart
options: const ailog.Options(
  captureLevel: ailog.Level.debug,
  reportLevel: ailog.Level.warning,
)
```

With this setup, `debug` and higher events are captured, but only `warning` and
higher events automatically print reports. Captured lower-level events can still
appear as context in the report.

Print diagnostics automatically for warnings and errors:

```dart
ailog.configure(
  options: const ailog.Options(
    captureLevel: ailog.Level.debug,
    reportLevel: ailog.Level.warning,
    recentSignalLevels: [
      ailog.Level.debug,
      ailog.Level.info,
      ailog.Level.error,
    ],
    reportFormat: ailog.ReportFormat.diagnostic,
  ),
);
```

This produces terminal-friendly output:

```text
error[network_error]: Request failed.
 --> lib/api.dart:42:12
 help: check the failing endpoint and retry policy
```

Collect events silently and generate a copyable report later:

```dart
ailog.configure(
  options: const ailog.Options(
    captureLevel: ailog.Level.info,
    reportLevel: ailog.Level.error,
    printReports: false,
  ),
);

ailog.i('loaded profile');
ailog.e('request failed', error: StateError('bad state'));

final markdown = ailog.formatLastReport(ailog.ReportFormat.markdown);
```

Retrieve only the levels you want:

```dart
final selected = ailog.recentEventsWhere(
  levels: const [
    ailog.Level.trace,
    ailog.Level.debug,
    ailog.Level.error,
  ],
);
```

If you need `trace` events, set `captureLevel: ailog.Level.trace`; ignored
events cannot be returned later.

## Output Shapes

`ReportFormat.markdown` is best for AI chats:

```markdown
# Runtime Event
Request failed.

Kind: network_error
Location: lib/api.dart:42:12

# Recent Signals
- info route=/profile loaded profile
```

`ReportFormat.compactJson` is best for tools:

```json
{
  "event": {
    "lv": "E",
    "src": "app",
    "msg": "Request failed.",
    "kind": "network_error",
    "file": "lib/api.dart",
    "line": 42,
    "col": 12
  }
}
```

`ReportFormat.diagnostic` is best for terminals and CI logs:

```text
error[network_error]: Request failed.
 --> lib/api.dart:42:12
 help: check the failing endpoint and retry policy
```

## Persist JSONL

```dart
ailog.configure(
  sinks: [ailog.FileJsonlSink('.ai_logger/events.jsonl')],
);
```

## CLI

```bash
dart run ai_logger_core report --last --format markdown
dart run ai_logger_core report --last --format diagnostic
dart run ai_logger_core analyze --project . --format diagnostic
```

`analyze` preserves analyzer exit codes, so it can be used in CI while still
producing AI-readable output.
