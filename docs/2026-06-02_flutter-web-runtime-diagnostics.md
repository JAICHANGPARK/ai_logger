# 2026-06-02 Flutter Web Runtime Diagnostics

## 작업 범위

- `ai_logger`에 web-only conditional import hook을 추가해 Flutter Web에서
  `window.onerror`와 `unhandledrejection` 이벤트를 수집한다.
- Web runtime error classifier를 추가해 browser network/CORS 오류, null 또는
  undefined JavaScript 값, JavaScript interop 오류, compiled `main.dart.js`
  location, unhandled promise rejection을 AI-friendly kind/cause/fix로 변환한다.
- Web hook이 현재 URL, user agent, viewport를 context에 추가하되 URL query의
  token/secret/password/key 값은 redaction한다.
- example 앱에 simulated `web error` 버튼을 추가해 diagnostic/JSON report에서
  Flutter Web 오류 변환 결과를 확인할 수 있게 했다.
- public API로 `classifyWebRuntimeError`와 `logClassifiedWebRuntimeError`를
  export했다.

## 목표 대응

- Flutter Web의 브라우저 콘솔 오류와 compiled JavaScript stack 위치를 그대로
  복사하지 않고, AI가 이해하기 쉬운 Rust-style diagnostic report로 변환한다.
- source map이 필요한 compiled `main.dart.js` 위치에는 `--source-maps` 안내를
  suggested fix에 포함한다.
