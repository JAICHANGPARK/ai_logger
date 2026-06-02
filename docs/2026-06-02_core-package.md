# 2026-06-02 Core Package

## 작업 범위

- `packages/ai_logger_core` 순수 Dart 패키지를 추가했다.
- 로그 레벨, 옵션, 이벤트 모델, sink, redaction, context, breadcrumb API를 구현했다.
- `guard()` 기반 `print()` 수집과 fatal error 기록 경로를 만들었다.
- stack trace parser와 app frame filtering을 추가했다.
- AI용 Markdown, compact JSON, Rust-style diagnostic report 생성을 구현했다.
- `dart run ai_logger_core report --last` CLI를 추가했다.

## PRD 대응

- Dart-only 사용자는 `ai_logger_core`를 import할 수 있다.
- 런타임은 file/line/column과 stack frame 중심으로 이벤트를 저장한다.
- source file은 CLI에서만 읽어 diagnostic frame을 렌더링한다.
- 원본 JSONL 저장 형식과 AI-friendly report 변환 경로를 분리했다.
