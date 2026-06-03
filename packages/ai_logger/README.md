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

## Benchmark

The repository includes deterministic benchmarks comparing raw Flutter/Dart
runtime-error pastes with `ai_logger` report formats. In a real Flutter
widget-test benchmark that triggers `RenderFlex`, unbounded viewport, and
parent-data runtime errors, `diagnostic` output reduced `o200k_base` input from
2591.0 to 52.0 tokens on average (`-98.0%`) compared with raw
`FlutterErrorDetails` text. In five curated synthetic runtime-error fixtures,
`diagnostic` reduced `o200k_base` tokens by 59.4% (`240.8` -> `97.8`). These
numbers measure prompt cost and field-presence coverage, not model fix
accuracy.

See the
[benchmark details](https://github.com/JAICHANGPARK/ai_logger/blob/main/docs/benchmarks/README.md)
and
[analyzer-vs-runtime evidence](https://github.com/JAICHANGPARK/ai_logger/blob/main/docs/benchmarks/analyzer_vs_runtime.md)
for FAQ, fixture design, real Flutter error cases, scoring rules, tokenizer
counts, review caveats, and limitations.

## FAQ

### Why not just run `dart analyze`?

Run `dart analyze` or `flutter analyze` first. `ai_logger` is for runtime
failures those tools cannot execute: widget layout constraints, route/provider
scope, async callbacks, platform errors, network state, and user-action-driven
failures. The benchmark includes a Flutter file that passes `flutter analyze`
but still produces real `RenderFlex`, viewport, and `ParentDataWidget` runtime
errors when pumped. See the
[analyzer-vs-runtime evidence](https://github.com/JAICHANGPARK/ai_logger/blob/main/docs/benchmarks/analyzer_vs_runtime.md).

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
- `debugPrint()`, with known Flutter diagnostics promoted to errors
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

Diagnostic output is the most token-efficient format for direct AI chat input:

```text
error[render_flex_overflow]: RenderFlex overflowed by 42 pixels.
 --> lib/profile_header.dart:31:12
 help: Wrap the overflowing child with Expanded or Flexible.
```

Markdown is best when you want richer copyable context:

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
