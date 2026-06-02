# 2026-06-02 Static Analysis Reports

## 작업 범위

- `StaticAnalysisParser`와 `StaticAnalysisReport`를 추가했다.
- `dart analyze`/`flutter analyze` text output을 파싱해 AI-friendly Markdown, compact JSON, Rust-style diagnostic으로 변환한다.
- `dart run ai_logger_core analyze --project . --format diagnostic` CLI를 추가했다.
- `--tool dart|flutter`로 분석 도구를 선택할 수 있게 했다.
- analyzer exit code를 보존해 CI 실패 조건을 유지한다.

## 목표 대응

- AI가 정적분석 오류를 바로 이해할 수 있게 `severity[code]`, location, source frame, suggested fix를 함께 제공한다.
- 런타임 에러뿐 아니라 정적분석 결과도 같은 복붙/자동 읽기 흐름에 포함한다.

## 예시 출력

```txt
error[undefined_identifier]: Undefined name 'missingName'.
 --> lib/main.dart:3:9
 1 | void main() {
 2 |   final unused = 1;
 3 |   print(missingName);
   |         ^ undefined_identifier
 help: Try correcting the name to one that is defined, or defining the name.
```
