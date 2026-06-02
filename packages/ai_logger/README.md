# ai_logger

Flutter runtime logging for AI-assisted app development.

`ai_logger` captures Flutter/Dart app-level logs and errors, then converts them
into compact reports that an AI can read directly or a developer can copy into
an AI chat. It re-exports `ai_logger_core`.

## Usage

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

Captured app-level signals:

- direct `ailog.t/d/i/w/e/f(...)` calls
- `print()` inside the guarded `ailog.runApp` app zone
- `debugPrint()`
- `FlutterError.onError`
- `PlatformDispatcher.onError`
- route breadcrumbs through `AiLoggerRouteObserver`
- `package:logging` through `captureLoggingPackage()`
- `package:logger` through `AiLoggerOutput`

Generate a copyable AI report:

```dart
final markdown = ailog.formatLastReport(ailog.ReportFormat.markdown);
```

## Example

The `example/` app shows captured runtime events and a copyable AI Markdown
report panel.

## Scope

This is a Flutter package, not a native platform plugin. It does not capture
Android Logcat or iOS OSLog. Native OS log capture should be added as an
optional native/federated package when needed.
