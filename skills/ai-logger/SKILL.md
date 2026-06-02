---
name: ai-logger
description: Use ai_logger when adding, configuring, debugging, documenting, or reviewing AI-friendly logging in Dart or Flutter projects. Trigger for tasks involving ai_logger, ai_logger_core, Flutter runtime error capture, Dart log events, AI-readable diagnostics, JSONL log persistence, analyzer output conversion, report formats, or package integration guidance.
---

# AI Logger

Use `ai_logger` to turn Flutter/Dart runtime signals into logs and reports that
an AI can inspect without re-discovering app context.

## First Checks

1. Detect the project type.
   - Flutter app: add/use `package:ai_logger/ai_logger.dart`.
   - Dart-only package, CLI, service, or test: add/use
     `package:ai_logger_core/ai_logger_core.dart`.
2. Prefer the package README in the active project when versions differ.
3. Use `rg "ai_logger|ailog|AiLogger|Options|FileJsonlSink"` before editing an
   existing codebase.
4. Preserve existing logging, crash reporting, and error handlers unless the
   user explicitly asks to replace them.
5. Use explicit enum names such as `ailog.Level.debug` when clarity matters;
   Dart dot shorthand such as `.debug` is also valid when the expected type is
   clear.

For API details and copyable snippets, read
`references/api-patterns.md`.

## Core Mental Model

`captureLevel` controls what is stored. Events below it are ignored and cannot
appear later.

`reportLevel` controls what automatically becomes an AI-readable report.
Captured lower-level events can still appear as recent context.

Common setup:

```dart
options: const ailog.Options(
  captureLevel: ailog.Level.debug,
  reportLevel: ailog.Level.warning,
)
```

This stores `debug/info/warning/error/fatal`, ignores `trace`, and auto-prints
reports for `warning/error/fatal`.

## Flutter Integration

Use `ailog.runApp` around the app root so Flutter hooks and guarded-zone capture
are installed:

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

This captures direct `ailog.*` calls, guarded `print()`, `debugPrint()`,
`FlutterError.onError`, `PlatformDispatcher.onError`, route breadcrumbs, and
supported adapter logs.

## Dart Integration

Use `guard` for Dart entrypoints that should capture `print()` and uncaught zone
errors:

```dart
import 'package:ai_logger_core/ai_logger_core.dart' as ailog;

void main() {
  ailog.guard(() {
    ailog.i('server started');
  });
}
```

## Logging Patterns

Use levels intentionally:

```dart
ailog.d('loaded profile state');
ailog.i('profile screen opened');
ailog.w('retrying slow request');
ailog.e('request failed', error: error, stackTrace: stackTrace);
ailog.f('fatal startup failure', error: error, stackTrace: stackTrace);
```

Add context before the risky operation:

```dart
ailog.context.setRoute('/login');
ailog.context.set('screen_width', 390);
ailog.breadcrumb('tap_login_button');
```

Retrieve only selected captured levels:

```dart
final selected = ailog.recentEventsWhere(
  levels: const [
    ailog.Level.trace,
    ailog.Level.debug,
    ailog.Level.error,
  ],
);
```

## Report Workflows

Use Markdown for AI chat handoff:

```dart
final report = ailog.formatLastReport(ailog.ReportFormat.markdown);
```

Use diagnostics for terminal and CI output:

```dart
final report = ailog.formatLastReport(ailog.ReportFormat.diagnostic);
```

Use compact JSON for tools:

```dart
final report = ailog.formatLastReport(ailog.ReportFormat.compactJson);
```

Persist JSONL on `dart:io` platforms:

```dart
ailog.configure(
  sinks: [ailog.FileJsonlSink('.ai_logger/events.jsonl')],
);
```

Then render persisted events:

```bash
dart run ai_logger_core report --last --format markdown
dart run ai_logger_core report --last --format diagnostic
dart run ai_logger_core report --last --format json
```

## Static Analysis Workflow

When asked to make analyzer output AI-readable, use:

```bash
dart run ai_logger_core analyze --project . --format markdown
dart run ai_logger_core analyze --project . --format diagnostic
dart run ai_logger_core analyze --project . --tool flutter
```

Keep analyzer exit codes meaningful in CI. Do not hide failures unless the user
explicitly asks for a non-failing reporting step.

## Validation

After code changes, run the narrowest relevant checks:

```bash
dart test
flutter test
dart analyze .
flutter analyze .
```

For this repository specifically:

```bash
cd packages/ai_logger_core && dart test
cd ../ai_logger && flutter test
```
