import 'package:ai_logger_core/ai_logger_core.dart' as core;

class FlutterErrorClassification {
  const FlutterErrorClassification({
    required this.kind,
    required this.summary,
    this.likelyWidget,
    required this.probableCause,
    required this.suggestedFix,
  });

  final String kind;
  final String summary;
  final String? likelyWidget;
  final String probableCause;
  final String suggestedFix;

  Map<String, Object?> toJson() {
    return {
      'kind': kind,
      'summary': summary,
      if (likelyWidget != null) 'likelyWidget': likelyWidget,
      'probableCause': probableCause,
      'suggestedFix': suggestedFix,
    };
  }
}

FlutterErrorClassification classifyFlutterError(Object error) {
  final text = error.toString();
  final lower = text.toLowerCase();
  final originalSummary = _firstMeaningfulLine(text);

  if (lower.contains('renderflex overflowed')) {
    return FlutterErrorClassification(
      kind: 'render_flex_overflow',
      summary: originalSummary.contains('RenderFlex overflowed')
          ? originalSummary
          : 'RenderFlex overflowed.',
      likelyWidget: 'Row or Column',
      probableCause:
          'A flex child is wider or taller than the available space.',
      suggestedFix:
          'Wrap the wide child with Expanded/Flexible or constrain it.',
    );
  }
  if (lower.contains('renderbox was not laid out')) {
    return const FlutterErrorClassification(
      kind: 'render_box_not_laid_out',
      summary: 'RenderBox was not laid out.',
      probableCause:
          'A render object did not receive finite layout constraints.',
      suggestedFix:
          'Check parent constraints and add a bounded size where needed.',
    );
  }
  if (lower.contains('vertical viewport was given unbounded height')) {
    return const FlutterErrorClassification(
      kind: 'vertical_viewport_unbounded_height',
      summary: 'Vertical viewport received an unbounded height.',
      likelyWidget: 'ListView or GridView',
      probableCause:
          'A scrollable is placed in a parent that does not bound height.',
      suggestedFix:
          'Give the scrollable a bounded height or use shrinkWrap carefully.',
    );
  }
  if (lower.contains('incorrect use of parentdatawidget')) {
    return const FlutterErrorClassification(
      kind: 'incorrect_parent_data_widget',
      summary: 'Incorrect use of ParentDataWidget.',
      probableCause:
          'A widget such as Expanded is under an incompatible parent.',
      suggestedFix:
          'Move the ParentDataWidget under the matching layout parent.',
    );
  }
  if (lower.contains('setstate() called after dispose')) {
    return const FlutterErrorClassification(
      kind: 'set_state_after_dispose',
      summary: 'setState was called after dispose.',
      probableCause:
          'An async callback updated a widget after it was disposed.',
      suggestedFix:
          'Cancel the callback or check mounted before calling setState.',
    );
  }
  if (lower.contains('setstate() or markneedsbuild() called during build')) {
    return const FlutterErrorClassification(
      kind: 'set_state_during_build',
      summary: 'setState or markNeedsBuild was called during build.',
      probableCause:
          'State was mutated while Flutter was building the widget tree.',
      suggestedFix:
          'Defer the mutation with a post-frame callback or move it earlier.',
    );
  }
  if (lower.contains('no material widget found')) {
    return const FlutterErrorClassification(
      kind: 'no_material_widget_found',
      summary: 'No Material widget found.',
      likelyWidget: 'Material',
      probableCause:
          'A Material component is used outside a Material ancestor.',
      suggestedFix: 'Wrap the subtree with MaterialApp, Scaffold, or Material.',
    );
  }
  if (lower.contains('navigator') && lower.contains('context')) {
    return const FlutterErrorClassification(
      kind: 'navigator_context_error',
      summary: 'Navigator could not use the provided BuildContext.',
      likelyWidget: 'Navigator',
      probableCause:
          'The context does not belong to a subtree with a Navigator.',
      suggestedFix:
          'Use a context below MaterialApp/Navigator or pass a valid key.',
    );
  }
  if (lower.contains('providernotfoundexception')) {
    return const FlutterErrorClassification(
      kind: 'provider_not_found',
      summary: 'Provider was not found for the requested type.',
      likelyWidget: 'Provider',
      probableCause: 'The lookup context is outside the Provider scope.',
      suggestedFix:
          'Move the Provider above the consumer or use the right context.',
    );
  }
  if (lower.contains('lateinitializationerror')) {
    return const FlutterErrorClassification(
      kind: 'late_initialization_error',
      summary: 'A late variable was read before initialization.',
      probableCause: 'A late field or local variable was accessed too early.',
      suggestedFix: 'Initialize it before reading or make the value nullable.',
    );
  }

  return FlutterErrorClassification(
    kind: 'flutter_error',
    summary: originalSummary,
    probableCause: 'Flutter reported a runtime error.',
    suggestedFix: 'Inspect the primary app frame and recent signals.',
  );
}

String _firstMeaningfulLine(String text) {
  for (final rawLine in text.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty || line == 'FlutterError') {
      continue;
    }
    return line;
  }
  return text.trim().isEmpty ? 'Flutter error' : text.trim();
}

core.LogEvent? logClassifiedFlutterError(
  Object error, {
  StackTrace? stackTrace,
  String source = 'flutter',
}) {
  final classification = classifyFlutterError(error);
  final frames = core.filterAppFrames(core.StackTraceParser.parse(stackTrace));
  return core.logger.log(
    core.Level.error,
    classification.summary,
    error: error,
    stackTrace: stackTrace,
    source: source,
    kind: classification.kind,
    likelyWidget: classification.likelyWidget,
    probableCause: classification.probableCause,
    suggestedFix: classification.suggestedFix,
    appFrames: frames,
  );
}
