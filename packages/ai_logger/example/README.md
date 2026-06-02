# ai_logger example

This app demonstrates the Flutter app-level runtime signals captured by
`ai_logger`:

- direct `ailog.*` calls
- `print()` through the guarded `ailog.runApp`
- `debugPrint()`
- `FlutterError.reportError`
- uncaught async errors scheduled inside the guarded app zone
- route breadcrumbs through `AiLoggerRouteObserver`
- manual warning events
- simulated Flutter Web browser runtime errors
- copyable Markdown, diagnostic, and compact JSON AI reports

Run it from this directory:

```bash
flutter run
```
