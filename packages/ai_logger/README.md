# ai_logger

**AI-friendly logger for Flutter app development.**

`ai_logger` captures Flutter/Dart app-level logs and errors, then converts them
into compact, structured reports that an AI can read directly or a developer
can copy into an AI chat. It re-exports `ai_logger_core` and adds Flutter
runtime hooks.

Code examples use Dart dot shorthand, such as `captureLevel: .debug`, when the
expected type is already clear. The package requires Dart `^3.12.0`.

For AI agents, this repository provides a Codex skill at
[`skills/ai-logger`](https://github.com/JAICHANGPARK/ai_logger/tree/main/skills/ai-logger)
with integration, configuration, report, and analysis workflows.

## Installation

```bash
flutter pub add ai_logger
```

## Quick Start

```dart
import 'package:ai_logger/ai_logger.dart' as ailog;

void main() {
  ailog.runApp(
    const MyApp(),
    options: const ailog.Options(
      captureLevel: .debug,
      reportLevel: .warning,
    ),
  );
}
```

Generate a copyable AI report from the latest warning, error, or fatal event:

```dart
final markdown = ailog.formatLastReport(.markdown);
```

By default, warning/error/fatal runtime events print Rust-style diagnostics to
the console as soon as they are captured. Markdown reports append that same
diagnostic in a final `# Diagnostic` block. Use
`Options(printReports: false)` to disable automatic console reports.

## What It Captures

Captured app-level signals:

- direct `ailog.t/d/i/w/e/f(...)` calls
- `print()` inside the guarded `ailog.runApp` app zone
- `debugPrint()`
- `FlutterError.onError`
- `PlatformDispatcher.onError`
- route breadcrumbs through `AiLoggerRouteObserver`
- `package:logging` through `captureLoggingPackage()`
- `package:logger` through `AiLoggerOutput`

## Configuration

`captureLevel` decides what gets stored. `reportLevel` decides what becomes an
automatic AI-readable report.

```dart
options: const ailog.Options(
  captureLevel: .debug,
  reportLevel: .warning,
)
```

With this setup, `debug` and higher events are captured, but only `warning` and
higher events automatically print reports. Captured lower-level events can still
appear as context in the report.

This setup keeps debug breadcrumbs, prints a diagnostic when warning/error/fatal
events happen, and stores raw events for later CLI reports on `dart:io`
platforms:

```dart
ailog.runApp(
  const MyApp(),
  options: const ailog.Options(
    captureLevel: .debug,
    reportLevel: .warning,
    recentSignalLevels: [
      .debug,
      .info,
      .error,
    ],
    reportFormat: .diagnostic,
  ),
  sinks: [ailog.FileJsonlSink('.ai_logger/events.jsonl')],
);
```

The automatic console output is short and points at the useful app frame:

```text
error[render_flex_overflow]: RenderFlex overflowed by 42 pixels.
 --> lib/profile_header.dart:31:12
 help: Wrap the overflowing child with Expanded or Flexible.
```

Use this setup when you want to collect events silently and show the report in
your own UI:

```dart
ailog.runApp(
  const MyApp(),
  options: const ailog.Options(
    captureLevel: .info,
    reportLevel: .error,
    printReports: false,
  ),
);
```

Then generate a report on demand:

```dart
final markdown = ailog.formatLastReport(.markdown);
final json = ailog.formatLastReport(.compactJson);
final diagnostic = ailog.formatLastReport(.diagnostic);
```

Retrieve only the levels you want:

```dart
final selected = ailog.recentEventsWhere(
  levels: const [
    .trace,
    .debug,
    .error,
  ],
);
```

If you need `trace` events, set `captureLevel: ailog.Level.trace`; ignored
events cannot be returned later.

## Output Shapes

Markdown is best for pasting into an AI chat:

```markdown
# Runtime Event
RenderFlex overflowed by 42 pixels.

Kind: render_flex_overflow
Location: lib/profile_header.dart:31:12

# Suggested Fix
Wrap the overflowing child with Expanded or Flexible.
```

Compact JSON is best for tools:

```json
{
  "event": {
    "lv": "E",
    "src": "flutter",
    "msg": "RenderFlex overflowed by 42 pixels.",
    "kind": "render_flex_overflow",
    "file": "lib/profile_header.dart",
    "line": 31,
    "col": 12
  }
}
```

## Persist Events

Persist raw JSONL events on `dart:io` platforms:

```dart
ailog.configure(
  sinks: [ailog.FileJsonlSink('.ai_logger/events.jsonl')],
);
```

## Example

The `example/` app shows captured runtime events and a copyable AI Markdown
report panel for AI-assisted debugging.

## Scope

This is a Flutter package, not a native platform plugin. It does not capture
Android Logcat or iOS OSLog. Native OS log capture should be added as an
optional native/federated package when needed.
