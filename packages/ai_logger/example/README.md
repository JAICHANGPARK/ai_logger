# ai_logger example

This app demonstrates the Flutter app-level runtime signals captured by
`ai_logger`:

- direct `ailog.*` calls
- `print()` through the guarded `ailog.runApp`
- `debugPrint()`
- `FlutterError.reportError`
- uncaught async errors scheduled inside the guarded app zone
- route breadcrumbs through `AiLoggerRouteObserver`

Run it from this directory:

```bash
flutter run
```
