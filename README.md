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

Code examples use Dart dot shorthand, such as `captureLevel: .debug`, when the
expected type is already clear. The packages require Dart `^3.12.0`.

## AI Agent Skill

This repository includes a Codex skill at [`skills/ai-logger`](skills/ai-logger)
so an AI agent can quickly understand how to install, configure, analyze, and
extend `ai_logger`.

Give that skill to Codex when you want an agent to:

- add `ai_logger` to a Flutter app or `ai_logger_core` to a Dart project
- explain `captureLevel`, `reportLevel`, report formats, and recent signals
- convert runtime logs or analyzer output into AI-readable reports
- review an integration for missing hooks, context, persistence, or tests

To install it locally for Codex discovery, copy the skill folder into your
skills directory:

```bash
cp -R skills/ai-logger "${CODEX_HOME:-$HOME/.codex}/skills/"
```

Then prompt the agent with:

```text
Use $ai-logger to add AI-friendly logging to this Flutter or Dart project.
```

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

## Benchmark

The repository includes deterministic benchmarks comparing a raw runtime-error
paste with `ai_logger` report formats:

```bash
cd packages/ai_logger_core
dart run benchmark/raw_vs_ai_report.dart
uv run --with tiktoken python benchmark/openai_token_counts.py

cd ../ai_logger
flutter test benchmark/real_flutter_errors_test.dart

cd ../ai_logger_core
uv run --with tiktoken python benchmark/openai_token_counts.py \
  --input ../../docs/benchmarks/real_flutter_errors.json \
  --markdown-output ../../docs/benchmarks/real_flutter_openai_token_counts.md \
  --json-output ../../docs/benchmarks/real_flutter_openai_token_counts.json
```

Current benchmark results are stored in
[`docs/benchmarks`](docs/benchmarks/README.md). In a real Flutter widget-test
benchmark that triggers `RenderFlex`, unbounded viewport, and parent-data
runtime errors, `diagnostic` output reduced `o200k_base` input from 2591.0 to
52.0 tokens on average (`-98.0%`) compared with raw
`FlutterErrorDetails` text.
In five curated synthetic runtime-error fixtures, `diagnostic` reduced
`o200k_base` tokens by 59.4% (`240.8` -> `97.8`). These numbers measure prompt
cost and field-presence coverage, not model fix accuracy. See the
[benchmark details](docs/benchmarks/README.md) and
[analyzer-vs-runtime evidence](docs/benchmarks/analyzer_vs_runtime.md) for the
FAQ, fixture design, real Flutter error cases, scoring rules, tokenizer counts,
review caveats, and limitations.

## FAQ

### Why not just run `dart analyze`?

Run `dart analyze` or `flutter analyze` first. `ai_logger` is for the runtime
layer those tools cannot execute: widget layout constraints, route/provider
scope, async callbacks, platform errors, network state, and user-action-driven
failures. The benchmark includes a Flutter file that passes `flutter analyze`
but still produces real `RenderFlex`, viewport, and `ParentDataWidget` runtime
errors when pumped. See the
[analyzer-vs-runtime evidence](docs/benchmarks/analyzer_vs_runtime.md).

## Quick Start

### Flutter

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

`ai_logger` captures:

- direct `ailog.t/d/i/w/e/f(...)` calls
- `print()` inside the guarded `ailog.runApp` app zone
- `FlutterError.onError` as `error`
- `PlatformDispatcher.onError` as `fatal`
- `debugPrint()` as `debug`, with known Flutter diagnostics promoted to errors
- route changes through `AiLoggerRouteObserver`
- `package:logging` records through `captureLoggingPackage()`
- `package:logger` records through `AiLoggerOutput`

Generate a copyable AI report from the most recent warning/error/fatal event:

```dart
final markdown = ailog.formatLastReport(.markdown);
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
  captureLevel: .debug,
  reportLevel: .warning,
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
    .trace,
    .debug,
    .error,
  ],
);
```

If you want `trace` events to appear here, `captureLevel` must be
`ailog.Level.trace`; events below `captureLevel` are never stored.

### Print AI Diagnostics Automatically

```dart
ailog.configure(
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
 help: wrap the wide child with Expanded or Flexible
```

When `Options.reportSourceLoader` is configured, or when the CLI can load source
files from disk, diagnostics can also include a source frame:

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
    captureLevel: .info,
    reportLevel: .error,
    printReports: false,
  ),
);

ailog.i('loaded profile');
ailog.e('request failed', error: error, stackTrace: stackTrace);

final markdown = ailog.formatLastReport(.markdown);
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
