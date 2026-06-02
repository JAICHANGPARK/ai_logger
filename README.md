# ai_logger

**AI-friendly logger for Flutter and Dart.**

`ai_logger` is a Flutter-first logging monorepo for AI-assisted app
development. It captures Flutter/Dart app-level runtime logs and errors, then
converts them into compact, structured reports that an AI can read directly or
a developer can copy into an AI chat.

The goal is to turn noisy runtime output into useful debugging context:

- structured log events with level, source, route, context, error, and stack
- compact Markdown, JSON, and diagnostic reports built for AI review
- Flutter app hooks for errors, prints, debug output, and route breadcrumbs
- Dart-only APIs for packages, CLIs, services, and tests

Dart-only projects can use `ai_logger_core`; Flutter apps use `ai_logger`,
which re-exports the core API and installs Flutter-specific hooks.

## Installation

For Flutter apps:

```bash
flutter pub add ai_logger
```

For Dart-only projects:

```bash
dart pub add ai_logger_core
```

## Packages

```txt
packages/
  ai_logger_core/   # pure Dart logging, events, reports, diagnostics, CLI
  ai_logger/        # Flutter hooks, error classifier, route breadcrumbs
```

This is a Flutter package, not a native platform plugin. It does not include
root `android/`, `ios/`, `macos/`, or other platform implementation folders
because v1 focuses on Dart/Flutter app-level signals. The
`packages/ai_logger/example` app includes full platform runner folders.

## Quick Start

### Flutter

```dart
import 'package:ai_logger/ai_logger.dart' as ailog;

void main() {
  ailog.runApp(
    const MyApp(),
    options: const ailog.Options(
      captureLevel: ailog.Level.debug,
      reportLevel: ailog.Level.warning,
    ),
  );
}
```

`ai_logger` captures:

- direct `ailog.t/d/i/w/e/f(...)` calls
- `print()` inside the guarded `ailog.runApp` app zone
- `FlutterError.onError` as `error`
- `PlatformDispatcher.onError` as `fatal`
- `debugPrint()` as `debug`
- route changes through `AiLoggerRouteObserver`
- `package:logging` records through `captureLoggingPackage()`
- `package:logger` records through `AiLoggerOutput`

Generate a copyable AI report from the most recent warning/error/fatal event:

```dart
final markdown = ailog.formatLastReport(ailog.ReportFormat.markdown);
```

By default, warning/error/fatal runtime events also print a Rust-style
diagnostic immediately:

```text
error[render_flex_overflow]: RenderFlex overflowed by 42 pixels.
 --> lib/profile_header.dart:31:12
 help: Wrap the overflowing child with Expanded or Flexible.
```

Markdown reports include the same diagnostic in a final `# Diagnostic` block.
Disable automatic console reports with `Options(printReports: false)`.

Persist raw events as JSONL on `dart:io` platforms:

```dart
ailog.configure(
  sinks: [ailog.FileJsonlSink('.ai_logger/events.jsonl')],
);
```

Adapter examples:

```dart
final subscription = ailog.captureLoggingPackage();

final logger = Logger(
  output: ailog.AiLoggerOutput(),
);
```

Native OS logs such as Android Logcat and iOS OSLog are not captured by this
package. Those require a native/federated plugin and should be added as an
optional package when that product scope is needed.

### Dart

```dart
import 'package:ai_logger_core/ai_logger_core.dart' as ailog;

void main() {
  ailog.guard(() {
    ailog.i('server started');
  });
}
```

Common logging API:

```dart
ailog.t('trace');
ailog.d('debug');
ailog.i('info');
ailog.w('warning');
ailog.e('error', error: error, stackTrace: stackTrace);
ailog.f('fatal', error: error, stackTrace: stackTrace);

ailog.breadcrumb('tap_login_button');
ailog.context.setRoute('/login');
ailog.context.set('screen_width', 390);
```

## Configuration Examples

### How Levels Work

`captureLevel` decides what gets stored. `reportLevel` decides what becomes an
automatic AI-readable report.

```dart
options: const ailog.Options(
  captureLevel: ailog.Level.debug,
  reportLevel: ailog.Level.warning,
)
```

With this setup:

- `debug`, `info`, `warning`, `error`, and `fatal` events are captured.
- `trace` events are ignored because they are below `debug`.
- `warning`, `error`, and `fatal` events automatically print AI-readable
  reports.
- `debug` and `info` events are kept as context, but do not trigger reports by
  themselves.

To retrieve only specific captured levels, pass the levels you want:

```dart
final selected = ailog.recentEventsWhere(
  levels: const [
    ailog.Level.trace,
    ailog.Level.debug,
    ailog.Level.error,
  ],
);
```

If you want `trace` events to appear here, `captureLevel` must be
`ailog.Level.trace`; events below `captureLevel` are never stored.

### Print AI Diagnostics Automatically

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

With this configuration, `ai_logger` captures `debug` and higher events, then
prints an AI-friendly diagnostic report whenever a `warning`, `error`, or
`fatal` event is logged. The generated report uses only the listed
`recentSignalLevels` as recent context. Diagnostic output is compact and
terminal-friendly:

```text
error[render_flex_overflow]: RenderFlex overflowed by 42 pixels.
 --> lib/profile_header.dart:3:5
 1 | return Row(
 2 |   children: [
 3 |     Text(user.name),
   |     ^ this child is probably unconstrained
 4 |     IconButton(onPressed: save),
 5 |   ],
 help: wrap the wide child with Expanded or Flexible
```

### Collect First, Copy Later

```dart
ailog.configure(
  options: const ailog.Options(
    captureLevel: ailog.Level.info,
    reportLevel: ailog.Level.error,
    printReports: false,
  ),
);

ailog.i('loaded profile');
ailog.e('request failed', error: error, stackTrace: stackTrace);

final markdown = ailog.formatLastReport(ailog.ReportFormat.markdown);
```

With this configuration, events are captured but not printed automatically.
Call `formatLastReport()` when the UI, CLI, or test wants a copyable report.

## Output Formats

`ReportFormat.diagnostic` is best for terminals and CI logs:

```text
error[network_error]: Request failed.
 --> lib/api.dart:42:12
 help: check the failing endpoint and retry policy
```

`ReportFormat.markdown` is best for pasting into an AI chat:

````markdown
# Runtime Event
Request failed.

Kind: network_error
Location: lib/api.dart:42:12

# Suggested Fix
check the failing endpoint and retry policy

# Recent Signals
- info route=/profile loaded profile

# Diagnostic
```text
error[network_error]: Request failed.
 --> lib/api.dart:42:12
 help: check the failing endpoint and retry policy
```
````

`ReportFormat.compactJson` is best for tools:

```json
{
  "event": {
    "t": "2026-06-02T10:01:00.000",
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

JSONL sinks persist one compact event per line, which the CLI can later turn
back into Markdown, diagnostics, or JSON.

## CLI

From `packages/ai_logger_core`:

```bash
dart run ai_logger_core report --last
dart run ai_logger_core report --last --format markdown
dart run ai_logger_core report --last --format diagnostic
dart run ai_logger_core report --last --format json
dart run ai_logger_core analyze --project . --format markdown
dart run ai_logger_core analyze --project . --format diagnostic
dart run ai_logger_core analyze --project . --tool flutter
dart run ai_logger_core flutter-test
```

The runtime stores compact JSONL events. The CLI combines saved event locations
with local project sources to render Rust-style diagnostics when source files
are available, and falls back to compact AI-ready reports when they are not.

The `analyze` command transforms `dart analyze` or `flutter analyze` output into
the same AI-friendly formats. It keeps analyzer exit codes so CI can still fail
when static issues exist.

## Development

```bash
cd packages/ai_logger_core
dart pub get
dart test

cd ../ai_logger
flutter pub get
flutter test

cd example
flutter pub get
flutter test
```

Run the example app from `packages/ai_logger/example` to see captured events and
copyable AI Markdown reports in the UI.
