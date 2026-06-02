# ai_logger

`ai_logger` is a Flutter-first logging monorepo for AI-assisted app
development. It captures Flutter/Dart app-level runtime logs and errors, then
converts them into compact reports that an AI can read directly or a developer
can copy into an AI chat.

Dart-only projects can use `ai_logger_core`; Flutter apps use `ai_logger`,
which re-exports the core API and installs Flutter-specific hooks.

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

## Flutter

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

## Dart

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
