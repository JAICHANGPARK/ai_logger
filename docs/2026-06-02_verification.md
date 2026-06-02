# 2026-06-02 Verification

## 검증 명령

- `dart analyze` in `packages/ai_logger_core`
- `dart test` in `packages/ai_logger_core`
- `flutter analyze` in `packages/ai_logger`
- `flutter test` in `packages/ai_logger`
- `flutter analyze` in `packages/ai_logger/example`
- `flutter test` in `packages/ai_logger/example`
- `dart run ai_logger_core report --last --format markdown`
- `dart run ai_logger_core report --last --format diagnostic`
- `dart run ai_logger_core analyze --project /tmp/ai_logger_analyze_fixture --format diagnostic`
- `dart pub publish --dry-run` in `packages/ai_logger_core`
- `flutter pub publish --dry-run` in `packages/ai_logger`

## 확인한 출력

- Markdown report는 `# Flutter Error`, `Kind`, `Likely widget`, `Location`, `Probable Cause`, `Suggested Fix`, `Recent Signals`를 포함한다.
- Diagnostic report는 Rust-style source frame과 `help:`를 포함한다.
- Static analysis diagnostic report는 analyzer issue code, source frame,
  `help:`를 포함하고 analyzer exit code를 보존한다.
- Example widget test는 captured log list와 copyable AI report UI를 검증한다.
- Publish dry-run은 package archive와 필수 publish metadata를 검증한다.
