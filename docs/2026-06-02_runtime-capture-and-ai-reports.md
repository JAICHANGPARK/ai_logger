# 2026-06-02 Runtime Capture And AI Reports

## 작업 범위

- `ai_logger.runApp()`을 guarded zone으로 감싸 앱 entrypoint에서 `print()`와 uncaught zone error가 수집되게 했다.
- Flutter package에 `runGuarded()`를 추가해 테스트와 앱 내부 초기화 코드에서도 같은 capture path를 사용할 수 있게 했다.
- core logger에 마지막 reportable event 기준 Markdown/compact JSON/diagnostic report helper를 추가했다.
- `FileJsonlSink`를 추가해 CLI가 읽을 수 있는 JSONL 원본 저장 경로를 만들었다.
- `package:logging` adapter와 `package:logger` output adapter를 추가했다.

## 목표 대응

- AI가 읽기 쉬운 복붙용 Markdown report를 런타임 이벤트에서 직접 만들 수 있다.
- 기존 Flutter/Dart 앱에서 흔한 `print`, `debugPrint`, `FlutterError`, `PlatformDispatcher`, `package:logging`, `package:logger`, 직접 `ailog.*` 로그를 앱 레벨에서 수집한다.
- Android Logcat/iOS OSLog 같은 native OS 로그는 v1의 Flutter package 범위가 아니며, native/federated plugin으로 분리해야 한다.
