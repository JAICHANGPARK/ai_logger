# ai_logger

`ai_logger` is a Flutter-first logging monorepo that turns logs and runtime
errors into AI-ready diagnostic reports. Dart-only projects can use
`ai_logger_core`; Flutter apps use `ai_logger`, which re-exports the core API
and installs Flutter-specific hooks.

## Packages

```txt
packages/
  ai_logger_core/   # pure Dart logging, events, reports, diagnostics, CLI
  ai_logger/        # Flutter hooks, error classifier, route breadcrumbs
```

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

- `FlutterError.onError` as `error`
- `PlatformDispatcher.onError` as `fatal`
- `debugPrint()` as `debug`
- route changes through `AiLoggerRouteObserver`

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
dart run ai_logger_core flutter-test
```

The runtime stores compact JSONL events. The CLI combines saved event locations
with local project sources to render Rust-style diagnostics when source files
are available, and falls back to compact AI-ready reports when they are not.

## Development

```bash
cd packages/ai_logger_core
dart pub get
dart test

cd ../ai_logger
flutter pub get
flutter test
```
