# 2026-06-02 Publish Prep

## 작업 범위

- `ai_logger_core`와 `ai_logger` 버전을 `2026.6.2`로 맞췄다.
- example 앱 버전을 `2026.6.2+1`로 맞췄다.
- publish 대상 패키지 각각에 `LICENSE`, `README.md`, `CHANGELOG.md`를 추가했다.
- `ai_logger`의 local path override를 publish pubspec에서 제거하고, 로컬 개발용 `pubspec_overrides.yaml`로 분리했다.
- `.pubignore`와 `.gitignore`로 local override가 publish/archive/commit에 섞이지 않게 했다.

## Publish 순서

1. `packages/ai_logger_core`에서 `dart pub publish`.
2. `ai_logger_core` `2026.6.2`가 pub.dev에 올라간 것을 확인.
3. local `packages/ai_logger/pubspec_overrides.yaml` 없이 `packages/ai_logger`에서 `flutter pub publish`.

## Dry-run 결과

- `ai_logger_core` dry-run은 필수 publish 파일 요건을 통과했다.
- `ai_logger` dry-run은 패키지 archive 구성까지 확인했다.
- 두 dry-run 모두 현재 worktree가 아직 커밋 전이라 git clean 경고가 있었다.
- `ai_logger` dry-run에는 local `pubspec_overrides.yaml` 힌트가 있었다. 실제 publish 시에는 core를 먼저 publish하고 override 없이 진행해야 한다.

## 후속 버전

- 2026-06-02 후속 작업에서 publish 대상 패키지 버전을 `2026.6.3`으로 올렸다.
- 현재 publish 순서는 `ai_logger_core 2026.6.3`을 먼저 publish한 뒤, `ai_logger 2026.6.3`을 publish하는 것이다.
- 자세한 변경은 `docs/2026-06-02_version-bump-2026-6-3.md`를 참고한다.
