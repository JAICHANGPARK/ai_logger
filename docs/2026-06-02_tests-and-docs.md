# 2026-06-02 Tests And Docs

## 작업 범위

- core 테스트를 추가해 level filtering, JSONL serialization, redaction,
  stack frame filtering, Markdown report, diagnostic rendering, print capture를 검증했다.
- Flutter 테스트를 추가해 core re-export, 대표 error classifier,
  `FlutterError.onError` handler 보존, `debugPrint` capture를 검증했다.
- 루트 `README.md`를 PRD 중심 사용법과 개발 명령으로 교체했다.
- 날짜 헤더가 있는 루트 `CHANGELOG.md`를 추가했다.

## 남은 확장 후보

- 실제 파일 기반 persistent sink는 플랫폼별 조건부 import로 분리하는 편이 좋다.
- `package:logging`와 `logger` adapter는 PRD의 v1/v1.1 확장 범위로 남겼다.
- Flutter classifier는 fixture가 늘어날수록 패턴별 primary widget 추출을 강화할 수 있다.
