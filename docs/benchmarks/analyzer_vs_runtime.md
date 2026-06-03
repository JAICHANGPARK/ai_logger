# Analyzer vs Runtime Evidence

This evidence answers the common objection: "Why use `ai_logger` if a coding
agent can just run `dart analyze`?"

For Flutter apps, `flutter analyze` is the relevant static-analysis command. It
uses the Dart analyzer plus Flutter linting rules. The evidence below shows a
benchmark file that passes static analysis, then produces real Flutter runtime
errors when its widget trees are actually pumped.

## Static Analysis Result

Command:

```bash
cd packages/ai_logger
flutter analyze benchmark/real_flutter_errors_test.dart
```

Observed result:

```text
Analyzing real_flutter_errors_test.dart...
No issues found! (ran in 0.6s)
```

## Runtime Result

Command:

```bash
cd packages/ai_logger
flutter test benchmark/real_flutter_errors_test.dart
```

The test intentionally triggers and captures runtime failures, then writes the
raw Flutter output and `ai_logger` reports into markdown evidence files. The
test finishes successfully because the failures are expected benchmark inputs,
not failed assertions in the benchmark harness.

## Case Evidence

| Case | Source That Passes Analyze | Runtime Evidence | o200k Raw | o200k Diagnostic |
|---|---|---|---:|---:|
| `RenderFlex` overflow | [`Row` in a constrained box](../../packages/ai_logger/benchmark/real_flutter_errors_test.dart#L140) | [raw/report](real_flutter_errors/real_render_flex_overflow.md) | 558 | 35 |
| Unbounded vertical viewport | [`ListView` inside `Column`](../../packages/ai_logger/benchmark/real_flutter_errors_test.dart#L158) | [raw/report](real_flutter_errors/real_vertical_viewport_unbounded_height.md) | 2834 | 63 |
| Incorrect parent data | [`Expanded` under `Padding`](../../packages/ai_logger/benchmark/real_flutter_errors_test.dart#L170) | [raw/report](real_flutter_errors/real_incorrect_parent_data_widget.md) | 4381 | 58 |

The raw evidence files include the actual Flutter diagnostic text, including:

- `A RenderFlex overflowed by 140 pixels on the right.`
- `Vertical viewport was given unbounded height.`
- `Incorrect use of ParentDataWidget.`

## What This Proves

This proves that static analysis and runtime diagnosis cover different failure
classes. The analyzer checks source structure and type/lint rules before the
app runs. It does not execute a widget tree, evaluate real layout constraints,
follow runtime route/provider scope, wait for async callbacks, or observe
platform/network state.

`ai_logger` does not replace `dart analyze` or `flutter analyze`. It captures
the runtime layer after analysis has already passed, then converts the noisy
runtime output into compact AI-readable diagnostics with stable error kind,
route/recent signals when available, filtered app frames, and fix hints.

## What This Does Not Prove

This does not prove that `ai_logger` will always produce the correct fix or
that every runtime failure is classified perfectly. The benchmark measures
runtime evidence capture and prompt-token efficiency. Model fix accuracy should
be evaluated separately with an end-to-end LLM repair benchmark.
