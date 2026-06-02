# 2026-06-02 Runtime Diagnostic Output

## 작업 범위

- `Options.printReports` 기본값을 `true`로 추가해 `reportLevel` 이상 런타임 이벤트가 수집되면 즉시 Rust-style diagnostic을 출력하게 했다.
- `Options.reportFormat`, `Options.reportWriter`, `Options.reportSourceLoader`를 추가해 자동 출력 포맷, 출력 대상, 소스 프레임 로딩을 설정할 수 있게 했다.
- Markdown runtime report 하단에 `# Diagnostic` 코드블록을 추가했다.
- Markdown static analysis report 하단에도 같은 `# Diagnostic` 코드블록을 추가했다.
- 자동 진단 출력과 Markdown 하단 진단 블록에 대한 core/Flutter/example 테스트를 보강했다.

## 목표 대응

- Flutter 앱 런타임 에러는 기본적으로 AI가 바로 읽기 쉬운 Rust-style diagnostic 형태로 콘솔에 나온다.
- 사용자가 Markdown report를 복사하는 경우에도 하단에 같은 diagnostic 블록이 포함된다.
- 테스트나 수집 전용 환경에서는 `Options(printReports: false)`로 자동 콘솔 출력을 끌 수 있다.
