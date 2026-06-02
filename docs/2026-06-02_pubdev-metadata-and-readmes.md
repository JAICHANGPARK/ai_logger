# 2026-06-02 Pubdev Metadata And Readmes

## 작업 범위

- root README에 설치 방법, Flutter/Dart quick start, 자동 진단 출력, 수집/저장 방식, 출력 포맷 예시를 보강했다.
- `packages/ai_logger/README.md`에 pub.dev용 설치/quick start/수집 범위/저장 범위를 정리했다.
- `packages/ai_logger_core/README.md`에 pub.dev용 설치/quick start/CLI 설명을 정리했다.
- 두 패키지 `pubspec.yaml`에 `issue_tracker`, `documentation`, `topics`, `platforms` 메타데이터를 추가했다.

## 목표 대응

- pub.dev에서 패키지를 봤을 때 Flutter 런타임 에러 수집과 AI-friendly report 목적을 바로 이해할 수 있다.
- 패키지 메타데이터가 검색, 문서 링크, 지원 플랫폼 표기에 필요한 기본 필드를 갖춘다.
