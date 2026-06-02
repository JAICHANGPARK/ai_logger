# ai_logger API Patterns

## Package Choice

Use `ai_logger` in Flutter apps. It re-exports `ai_logger_core` and installs
Flutter-specific hooks.

Use `ai_logger_core` in Dart-only packages, CLIs, services, and tests.

## Installation

```bash
flutter pub add ai_logger
dart pub add ai_logger_core
```

## Level Semantics

Levels are ordered:

```txt
trace < debug < info < warning < error < fatal
```

Use explicit enum names such as `ailog.Level.debug` in explanations and mixed
contexts. Dot shorthand such as `.debug` is valid when Dart can infer the
expected type.

`captureLevel` is the storage threshold. Below-threshold events are dropped.

`reportLevel` is the automatic report threshold. Above-threshold events print an
AI-readable report when `printReports` is true.

`recentSignalLevels` selects which previously captured levels can appear as
report context.

Example:

```dart
const ailog.Options(
  captureLevel: ailog.Level.trace,
  reportLevel: ailog.Level.error,
  recentSignalLevels: [
    ailog.Level.trace,
    ailog.Level.debug,
    ailog.Level.error,
  ],
)
```

This stores every level, automatically reports only `error/fatal`, and includes
only `trace/debug/error` as recent context.

## Recommended Flutter Entry Point

```dart
import 'package:ai_logger/ai_logger.dart' as ailog;

void main() {
  ailog.runApp(
    const MyApp(),
    options: const ailog.Options(
      captureLevel: ailog.Level.debug,
      reportLevel: ailog.Level.warning,
      reportFormat: ailog.ReportFormat.diagnostic,
    ),
  );
}
```

Use `AiLoggerRouteObserver` when the app already uses a navigator observer list:

```dart
final routeObserver = ailog.AiLoggerRouteObserver();

MaterialApp(
  navigatorObservers: [routeObserver],
)
```

## Silent Collection

Use this when reports should be shown in app UI or copied manually:

```dart
ailog.configure(
  options: const ailog.Options(
    captureLevel: ailog.Level.info,
    reportLevel: ailog.Level.error,
    printReports: false,
  ),
);
```

Then generate on demand:

```dart
final markdown = ailog.formatLastReport(ailog.ReportFormat.markdown);
```

## Context and Breadcrumbs

Set context when it applies to all later events:

```dart
ailog.context.setRoute('/checkout');
ailog.context.set('user_role', 'admin');
```

Use breadcrumbs for discrete actions:

```dart
ailog.breadcrumb('tap_pay_button', data: {'method': 'card'});
```

## Adapter Patterns

For `package:logging`:

```dart
final subscription = ailog.captureLoggingPackage();
```

Cancel the subscription during teardown when used in tests.

For `package:logger`:

```dart
final logger = Logger(
  output: ailog.AiLoggerOutput(),
);
```

## Output Interpretation

Diagnostic output is concise terminal text:

```text
error[network_error]: Request failed.
 --> lib/api.dart:42:12
 help: check endpoint and retry policy
```

Markdown output is best for LLM handoff. It may include:

- event title and message
- kind, likely widget, location
- probable cause and suggested fix
- app frames
- recent signals
- final diagnostic block

Compact JSON is best for tools and stable parsing. JSONL sinks store one event
per line using compact keys such as `lv`, `src`, `msg`, `file`, `line`, and
`col`.

## Common Pitfalls

- Do not expect `trace` or `debug` to appear unless `captureLevel` allows them.
- Do not use `FileJsonlSink` on platforms without `dart:io`.
- Do not remove existing crash handlers without preserving their behavior.
- Do not paste long raw logs into AI prompts when `formatLastReport()` can
  produce compact context.
- Native Android Logcat and iOS OSLog are out of scope for the current package.
