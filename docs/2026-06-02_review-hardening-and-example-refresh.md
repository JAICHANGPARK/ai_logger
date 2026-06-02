# 2026-06-02 Review Hardening And Example Refresh

## 작업 범위

- guarded zone의 `print()` 캡처가 원래 parent zone 출력까지 보존하도록 수정했다.
- `recentSignalLimit: 0`일 때도 현재 reportable event가 recent buffer에 남아 report를 만들 수 있게 했다.
- CLI `report --last`가 warning/error/fatal 중 가장 최근 reportable event를 고르게 수정했다.
- Flutter example에 manual warning 버튼과 Markdown/Diagnostic/JSON report format 선택 UI를 추가했다.
- Dart dot shorthand 문법을 타입 문맥이 명확한 enum 인자와 README 예제에 적용했다.

## 테스트 보강

- `guard()`가 print를 캡처하면서 parent zone print도 호출하는지 테스트했다.
- `recentSignalLimit: 0`에서도 마지막 error report가 생성되는지 테스트했다.
- CLI `report --last`가 최신 warning 이벤트를 선택하는지 테스트했다.
- example이 Markdown report의 `# Diagnostic` 블록과 diagnostic/JSON format 복사를 보여주는지 테스트했다.

## 검토 결과

- native OS 로그 수집은 현재 패키지 범위 밖이며 README에 명시되어 있다.
- Flutter/Dart 앱 레벨 runtime error capture, AI-friendly Markdown, Rust-style diagnostic, compact JSON, static analysis report 변환은 테스트로 검증 가능하다.
