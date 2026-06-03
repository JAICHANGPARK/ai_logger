# real_incorrect_parent_data_widget

Evidence captured by `packages/ai_logger/benchmark/real_flutter_errors_test.dart`.

| Metric | Raw Flutter Error | ai_logger Diagnostic |
|---|---:|---:|
| Rough tokens | 4623 | 48 (-99.0%) |
| Framework-line mentions | 188 | 0 |

## Raw FlutterErrorDetails

```text
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞════════════════════════
The following assertion was thrown while applying parent data.:
Incorrect use of ParentDataWidget.
The ParentDataWidget Expanded(flex: 1) wants to apply ParentData
of type FlexParentData to a RenderObject, which has been set up
to accept ParentData of incompatible type BoxParentData.
Usually, this means that the Expanded widget has the wrong
ancestor RenderObjectWidget. Typically, Expanded widgets are
placed directly inside Flex widgets.
The offending Expanded is currently placed inside a Padding
widget.
The ownership chain for the RenderObject that received the
incompatible parent data was:
  RichText ← Text ← Expanded ← Padding ← Directionality ←
_FocusInheritedScope ← _FocusScopeWithExternalFocusNode ←
_FocusInheritedScope ← Focus ← FocusTraversalGroup ← ⋯

When the exception was thrown, this was the stack:
#0      RenderObjectElement._updateParentData.<anonymous closure> (package:flutter/src/widgets/framework.dart:6882:11)
#1      RenderObjectElement._updateParentData (package:flutter/src/widgets/framework.dart:6899:6)
#2      RenderObjectElement.attachRenderObject (package:flutter/src/widgets/framework.dart:6945:7)
#3      RenderObjectElement.mount (package:flutter/src/widgets/framework.dart:6801:5)
#4      MultiChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:7271:11)
...     Normal element mounting (16 frames)
#20     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#21     Element.updateChild (package:flutter/src/widgets/framework.dart:4053:20)
#22     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#23     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#24     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#25     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#26     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#27     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#28     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#29     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#30     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#31     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#32     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#33     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#34     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#35     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#36     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#37     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#38     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#39     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#40     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#41     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#42     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#43     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#44     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#45     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#46     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#47     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#48     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#49     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#50     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#51     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#52     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#53     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#54     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#55     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#56     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#57     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#58     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#59     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#60     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#61     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#62     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#63     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#64     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#65     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#66     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#67     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#68     _RawViewElement._updateChild (package:flutter/src/widgets/view.dart:481:16)
#69     _RawViewElement.update (package:flutter/src/widgets/view.dart:568:5)
#70     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#71     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#72     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#73     StatelessElement.update (package:flutter/src/widgets/framework.dart:5895:5)
#74     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#75     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#76     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#77     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#78     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#79     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#80     RootElement._rebuild (package:flutter/src/widgets/binding.dart:2091:16)
#81     RootElement.update (package:flutter/src/widgets/binding.dart:2069:5)
#82     RootElement.performRebuild (package:flutter/src/widgets/binding.dart:2083:7)
#83     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#84     BuildScope._tryRebuild (package:flutter/src/widgets/framework.dart:2750:15)
#85     BuildScope._flushDirtyElements (package:flutter/src/widgets/framework.dart:2807:11)
#86     BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3111:18)
#87     AutomatedTestWidgetsFlutterBinding.drawFrame (package:flutter_test/src/binding.dart:2431:19)
#88     RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:509:5)
#89     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#90     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1345:9)
#91     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2260:9)
#94     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#95     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2249:27)
#96     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#99     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#100    WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#101    _triggerIncorrectParentDataWidget (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:166:16)
#102    _captureCase (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:89:16)
#103    main.<anonymous closure> (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:42:13)
<asynchronous suspension>
#104    testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#105    TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 5 frames from dart:async and package:stack_trace)
═════════════════════════════════════════════════════════════════

Stack trace:
#0      RenderObjectElement._updateParentData.<anonymous closure> (package:flutter/src/widgets/framework.dart:6882:11)
#1      RenderObjectElement._updateParentData (package:flutter/src/widgets/framework.dart:6899:6)
#2      RenderObjectElement.attachRenderObject (package:flutter/src/widgets/framework.dart:6945:7)
#3      RenderObjectElement.mount (package:flutter/src/widgets/framework.dart:6801:5)
#4      MultiChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:7271:11)
#5      Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#6      Element.updateChild (package:flutter/src/widgets/framework.dart:4059:18)
#7      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#8      Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#9      ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5799:5)
#10     ComponentElement.mount (package:flutter/src/widgets/framework.dart:5793:5)
#11     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#12     Element.updateChild (package:flutter/src/widgets/framework.dart:4059:18)
#13     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#14     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#15     ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5799:5)
#16     ComponentElement.mount (package:flutter/src/widgets/framework.dart:5793:5)
#17     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#18     Element.updateChild (package:flutter/src/widgets/framework.dart:4059:18)
#19     SingleChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:7115:14)
#20     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)
#21     Element.updateChild (package:flutter/src/widgets/framework.dart:4053:20)
#22     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#23     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#24     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#25     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#26     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#27     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#28     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#29     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#30     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#31     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#32     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#33     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#34     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#35     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#36     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#37     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#38     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#39     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#40     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#41     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#42     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#43     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#44     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#45     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#46     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#47     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#48     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#49     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#50     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#51     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#52     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#53     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#54     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#55     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#56     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#57     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#58     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#59     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#60     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#61     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#62     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#63     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#64     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#65     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#66     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)
#67     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#68     _RawViewElement._updateChild (package:flutter/src/widgets/view.dart:481:16)
#69     _RawViewElement.update (package:flutter/src/widgets/view.dart:568:5)
#70     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#71     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#72     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#73     StatelessElement.update (package:flutter/src/widgets/framework.dart:5895:5)
#74     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#75     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)
#76     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)
#77     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#78     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)
#79     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)
#80     RootElement._rebuild (package:flutter/src/widgets/binding.dart:2091:16)
#81     RootElement.update (package:flutter/src/widgets/binding.dart:2069:5)
#82     RootElement.performRebuild (package:flutter/src/widgets/binding.dart:2083:7)
#83     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)
#84     BuildScope._tryRebuild (package:flutter/src/widgets/framework.dart:2750:15)
#85     BuildScope._flushDirtyElements (package:flutter/src/widgets/framework.dart:2807:11)
#86     BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3111:18)
#87     AutomatedTestWidgetsFlutterBinding.drawFrame (package:flutter_test/src/binding.dart:2431:19)
#88     RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:509:5)
#89     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#90     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1345:9)
#91     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2260:9)
#92     _rootRun (dart:async/zone_root.dart:35:13)
#93     _CustomZone.run (dart:async/zone.dart:726:19)
#94     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#95     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2249:27)
#96     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#97     _rootRun (dart:async/zone_root.dart:35:13)
#98     _CustomZone.run (dart:async/zone.dart:726:19)
#99     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#100    WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#101    _triggerIncorrectParentDataWidget (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:166:16)
#102    _captureCase (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:89:16)
#103    main.<anonymous closure> (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:42:13)
<asynchronous suspension>
#104    testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#105    TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
#106    StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:114:42)
<asynchronous suspension>
```

## ai_logger Diagnostic

```text
error[incorrect_parent_data_widget]: Incorrect use of ParentDataWidget.
 --> /Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:166:16
 help: Move the ParentDataWidget under the matching layout parent.
```

## ai_logger Markdown Report

```markdown
# Flutter Error
Incorrect use of ParentDataWidget.

Kind: incorrect_parent_data_widget
Location: /Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:166:16

# Probable Cause
A widget such as Expanded is under an incompatible parent.

# Suggested Fix
Move the ParentDataWidget under the matching layout parent.

# App Frames
1. /Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:166:16 _triggerIncorrectParentDataWidget
2. /Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:89:16 _captureCase
3. /Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:42:13 main.<anonymous closure>

# Recent Signals
- debug route=/benchmark/parent-data about to render Expanded outside Flex

# Diagnostic
\`\`\`text
error[incorrect_parent_data_widget]: Incorrect use of ParentDataWidget.
 --> /Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:166:16
 help: Move the ParentDataWidget under the matching layout parent.
\`\`\`
```

## ai_logger Compact JSON

```json
{
  "event": {
    "t": "2026-06-02T22:37:50.758241",
    "lv": "E",
    "src": "flutter",
    "msg": "Incorrect use of ParentDataWidget.",
    "kind": "incorrect_parent_data_widget",
    "error": "Incorrect use of ParentDataWidget.\nThe ParentDataWidget Expanded(flex: 1) wants to apply ParentData of type FlexParentData to a RenderObject, which has been set up to accept ParentData of incompatible type BoxParentData.\nUsually, this means that the Expanded widget has the wrong ancestor RenderObjectWidget. Typically, Expanded widgets are placed directly inside Flex widgets.\nThe offending Expanded is currently placed inside a Padding widget.\nThe ownership chain for the RenderObject that received the incompatible parent data was:\n  RichText ← Text ← Expanded ← Padding ← Directionality ← _FocusInheritedScope ← _FocusScopeWithExternalFocusNode ← _FocusInheritedScope ← Focus ← FocusTraversalGroup ← ⋯",
    "stack": "#0      RenderObjectElement._updateParentData.<anonymous closure> (package:flutter/src/widgets/framework.dart:6882:11)\n#1      RenderObjectElement._updateParentData (package:flutter/src/widgets/framework.dart:6899:6)\n#2      RenderObjectElement.attachRenderObject (package:flutter/src/widgets/framework.dart:6945:7)\n#3      RenderObjectElement.mount (package:flutter/src/widgets/framework.dart:6801:5)\n#4      MultiChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:7271:11)\n#5      Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)\n#6      Element.updateChild (package:flutter/src/widgets/framework.dart:4059:18)\n#7      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#8      Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#9      ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5799:5)\n#10     ComponentElement.mount (package:flutter/src/widgets/framework.dart:5793:5)\n#11     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)\n#12     Element.updateChild (package:flutter/src/widgets/framework.dart:4059:18)\n#13     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#14     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#15     ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5799:5)\n#16     ComponentElement.mount (package:flutter/src/widgets/framework.dart:5793:5)\n#17     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)\n#18     Element.updateChild (package:flutter/src/widgets/framework.dart:4059:18)\n#19     SingleChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:7115:14)\n#20     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4587:20)\n#21     Element.updateChild (package:flutter/src/widgets/framework.dart:4053:20)\n#22     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#23     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#24     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)\n#25     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#26     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#27     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#28     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)\n#29     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)\n#30     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#31     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#32     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)\n#33     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#34     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)\n#35     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#36     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#37     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#38     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)\n#39     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)\n#40     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#41     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#42     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)\n#43     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#44     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)\n#45     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#46     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#47     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)\n#48     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#49     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)\n#50     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#51     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#52     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#53     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)\n#54     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#55     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#56     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)\n#57     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#58     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)\n#59     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#60     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#61     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#62     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)\n#63     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#64     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#65     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#66     ProxyElement.update (package:flutter/src/widgets/framework.dart:6149:5)\n#67     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#68     _RawViewElement._updateChild (package:flutter/src/widgets/view.dart:481:16)\n#69     _RawViewElement.update (package:flutter/src/widgets/view.dart:568:5)\n#70     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#71     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#72     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#73     StatelessElement.update (package:flutter/src/widgets/framework.dart:5895:5)\n#74     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#75     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5841:16)\n#76     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5982:11)\n#77     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#78     StatefulElement.update (package:flutter/src/widgets/framework.dart:6007:5)\n#79     Element.updateChild (package:flutter/src/widgets/framework.dart:4037:15)\n#80     RootElement._rebuild (package:flutter/src/widgets/binding.dart:2091:16)\n#81     RootElement.update (package:flutter/src/widgets/binding.dart:2069:5)\n#82     RootElement.performRebuild (package:flutter/src/widgets/binding.dart:2083:7)\n#83     Element.rebuild (package:flutter/src/widgets/framework.dart:5529:7)\n#84     BuildScope._tryRebuild (package:flutter/src/widgets/framework.dart:2750:15)\n#85     BuildScope._flushDirtyElements (package:flutter/src/widgets/framework.dart:2807:11)\n#86     BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3111:18)\n#87     AutomatedTestWidgetsFlutterBinding.drawFrame (package:flutter_test/src/binding.dart:2431:19)\n#88     RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:509:5)\n#89     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)\n#90     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1345:9)\n#91     AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2260:9)\n#92     _rootRun (dart:async/zone_root.dart:35:13)\n#93     _CustomZone.run (dart:async/zone.dart:726:19)\n#94     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)\n#95     AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2249:27)\n#96     WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)\n#97     _rootRun (dart:async/zone_root.dart:35:13)\n#98     _CustomZone.run (dart:async/zone.dart:726:19)\n#99     TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)\n#100    WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)\n#101    _triggerIncorrectParentDataWidget (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:166:16)\n#102    _captureCase (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:89:16)\n#103    main.<anonymous closure> (file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart:42:13)\n<asynchronous suspension>\n#104    testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)\n<asynchronous suspension>\n#105    TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)\n<asynchronous suspension>\n#106    StackZoneSpecification._registerCallback.<anonymous closure> (package:stack_trace/src/stack_zone_specification.dart:114:42)\n<asynchronous suspension>\n",
    "file": "/Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart",
    "line": 166,
    "col": 16,
    "member": "_triggerIncorrectParentDataWidget",
    "probableCause": "A widget such as Expanded is under an incompatible parent.",
    "suggestedFix": "Move the ParentDataWidget under the matching layout parent.",
    "ctx": {
      "route": "/benchmark/parent-data"
    },
    "breadcrumbs": [
      {
        "name": "route",
        "t": "2026-06-02T22:37:50.753388",
        "data": {
          "route": "/benchmark/parent-data"
        }
      }
    ],
    "appFrames": [
      {
        "member": "_triggerIncorrectParentDataWidget",
        "uri": "file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart",
        "line": 166,
        "column": 16
      },
      {
        "member": "_captureCase",
        "uri": "file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart",
        "line": 89,
        "column": 16
      },
      {
        "member": "main.<anonymous closure>",
        "uri": "file:///Users/jaichang/Documents/GitHub/ai_logger/packages/ai_logger/benchmark/real_flutter_errors_test.dart",
        "line": 42,
        "column": 13
      }
    ]
  },
  "recentSignals": [
    {
      "t": "2026-06-02T22:37:50.753426",
      "lv": "D",
      "src": "app",
      "msg": "about to render Expanded outside Flex",
      "ctx": {
        "route": "/benchmark/parent-data"
      },
      "breadcrumbs": [
        {
          "name": "route",
          "t": "2026-06-02T22:37:50.753388",
          "data": {
            "route": "/benchmark/parent-data"
          }
        }
      ]
    }
  ]
}
```
