# real_render_flex_overflow

Evidence captured by `packages/ai_logger/benchmark/real_flutter_errors_test.dart`.

| Metric | Raw Flutter Error | ai_logger Diagnostic |
|---|---:|---:|
| Rough tokens | 467 | 29 (-93.8%) |
| Framework-line mentions | 0 | 0 |

## Raw FlutterErrorDetails

```text
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞══════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 140 pixels on the right.

The relevant error-causing widget was:
  Row
  Row:file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:140:18

The overflowing RenderFlex has an orientation of Axis.horizontal.
The edge of the RenderFlex that is overflowing has been marked in
the rendering with a yellow and black striped pattern. This is
usually caused by the contents being too big for the RenderFlex.
Consider applying a flex factor (e.g. using an Expanded widget)
to force the children of the RenderFlex to fit within the
available space instead of being sized to their natural size.
This is considered an error condition because it indicates that
there is content that cannot be seen. If the content is
legitimately bigger than the available space, consider clipping
it with a ClipRect widget before putting it in the flex, or using
a scrollable container rather than a Flex, like a ListView.
The specific RenderFlex in question is: RenderFlex#0dea8 OVERFLOWING:
  parentData: <none> (can use size)
  constraints: BoxConstraints(w=120.0, h=80.0)
  size: Size(120.0, 80.0)
  direction: horizontal
  mainAxisAlignment: start
  mainAxisSize: max
  crossAxisAlignment: center
  textDirection: ltr
  verticalDirection: down
  spacing: 0.0
◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
═════════════════════════════════════════════════════════════════
```

## ai_logger Diagnostic

```text
error[render_flex_overflow]: A RenderFlex overflowed by 140 pixels on the right.
 help: Wrap the wide child with Expanded/Flexible or constrain it.
```

## ai_logger Markdown Report

```markdown
# Flutter Error
A RenderFlex overflowed by 140 pixels on the right.

Kind: render_flex_overflow
Likely widget: Row or Column

# Probable Cause
A flex child is wider or taller than the available space.

# Suggested Fix
Wrap the wide child with Expanded/Flexible or constrain it.

# Recent Signals
- debug route=/benchmark/flex about to render a constrained Row

# Diagnostic
\`\`\`text
error[render_flex_overflow]: A RenderFlex overflowed by 140 pixels on the right.
 help: Wrap the wide child with Expanded/Flexible or constrain it.
\`\`\`
```

## ai_logger Compact JSON

```json
{
  "event": {
    "t": "2026-06-02T22:37:50.613816",
    "lv": "E",
    "src": "flutter",
    "msg": "A RenderFlex overflowed by 140 pixels on the right.",
    "kind": "render_flex_overflow",
    "error": "A RenderFlex overflowed by 140 pixels on the right.",
    "likelyWidget": "Row or Column",
    "probableCause": "A flex child is wider or taller than the available space.",
    "suggestedFix": "Wrap the wide child with Expanded/Flexible or constrain it.",
    "ctx": {
      "route": "/benchmark/flex",
      "screen_width": 120
    },
    "breadcrumbs": [
      {
        "name": "route",
        "t": "2026-06-02T22:37:50.586958",
        "data": {
          "route": "/benchmark/flex"
        }
      }
    ]
  },
  "recentSignals": [
    {
      "t": "2026-06-02T22:37:50.587567",
      "lv": "D",
      "src": "app",
      "msg": "about to render a constrained Row",
      "ctx": {
        "route": "/benchmark/flex",
        "screen_width": 120
      },
      "breadcrumbs": [
        {
          "name": "route",
          "t": "2026-06-02T22:37:50.586958",
          "data": {
            "route": "/benchmark/flex"
          }
        }
      ]
    }
  ]
}
```
