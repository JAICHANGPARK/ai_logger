# 2026-06-02 Example App

## 작업 범위

- `packages/ai_logger/example` Flutter 앱을 추가했다.
- Android, iOS, macOS, web, Linux, Windows runner를 포함해 일반 Flutter package 예제 구조를 갖췄다.
- 예제 화면에서 직접 로그, `print`, `debugPrint`, Flutter error, async error를 발생시킬 수 있게 했다.
- 수집된 이벤트를 화면에 표시하고, 마지막 reportable event를 AI Markdown report로 만들어 클립보드에 복사하고 화면에 렌더링하게 했다.

## 목표 대응

- 개발자가 실제 앱에서 어떤 로그가 어떻게 잡히는지 바로 확인할 수 있다.
- AI에게 붙여넣기 좋은 Markdown report가 UI에서 생성되는 흐름을 보여준다.
