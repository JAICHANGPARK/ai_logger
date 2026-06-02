# ai_logger_core

Pure Dart logging, diagnostics, and AI-ready report generation for
AI-assisted development.

`ai_logger_core` captures structured Dart app-level events and turns them into
formats that are easy for an AI to read or for a developer to copy into an AI
chat:

- compact JSONL source events
- AI-friendly Markdown reports
- compact JSON exports
- Rust-style diagnostics with source frames
- `dart analyze` / `flutter analyze` output conversion

## Usage

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
