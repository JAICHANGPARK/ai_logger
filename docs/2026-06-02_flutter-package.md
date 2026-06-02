# 2026-06-02 Flutter Package

## 작업 범위

- `packages/ai_logger` Flutter 패키지를 추가했다.
- `ai_logger_core`를 re-export해 Flutter 사용자가 하나의 import로 공통 API를 사용할 수 있게 했다.
- `runApp()` wrapper와 `installFlutterHooks()`를 구현했다.
- `FlutterError.onError`, `PlatformDispatcher.onError`, `debugPrint` hook을 추가했다.
- route breadcrumb 기록을 위한 `AiLoggerRouteObserver`를 추가했다.
- 대표 Flutter runtime error classifier fixture를 구현했다.

## PRD 대응

- Flutter 대표 패키지 이름은 `ai_logger`로 유지했다.
- `FlutterError.onError`는 error, `PlatformDispatcher.onError`는 fatal, `debugPrint()`는 debug로 기록한다.
- Flutter error는 `kind`, `summary`, `likelyWidget`, `probableCause`, `suggestedFix` 중심으로 정규화한다.
