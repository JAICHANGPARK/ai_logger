import 'package:ai_logger_core/ai_logger_core.dart' as core;

/// A normalized explanation for a Flutter Web browser runtime error.
///
/// The fields are designed to be copied into AI prompts or reports without
/// requiring the model to infer the important failure category from a minified
/// browser console message.
class WebRuntimeErrorClassification {
  const WebRuntimeErrorClassification({
    required this.kind,
    required this.summary,
    required this.probableCause,
    required this.suggestedFix,
  });

  /// A stable machine-readable category for the error.
  final String kind;

  /// A concise one-line description of the browser runtime failure.
  final String summary;

  /// The likely root cause to include in AI-readable reports.
  final String probableCause;

  /// The next concrete debugging or code change step.
  final String suggestedFix;

  /// Converts this classification to JSON-compatible values.
  Map<String, Object?> toJson() {
    return {
      'kind': kind,
      'summary': summary,
      'probableCause': probableCause,
      'suggestedFix': suggestedFix,
    };
  }
}

/// Classifies a Flutter Web browser runtime error for AI-readable reporting.
///
/// Pass browser `error` or `unhandledrejection` event details when available so
/// the classifier can attach source-map guidance and choose a more specific
/// category.
WebRuntimeErrorClassification classifyWebRuntimeError(
  Object? error, {
  String? message,
  String? file,
  int? line,
  int? column,
  bool isUnhandledRejection = false,
}) {
  final summary = _summary(error, message);
  final lower = [
    summary,
    error?.toString() ?? '',
    file ?? '',
  ].join('\n').toLowerCase();
  final sourceMapHint = _sourceMapHint(file: file, text: lower);

  if (isUnhandledRejection) {
    return WebRuntimeErrorClassification(
      kind: 'web_unhandled_promise_rejection',
      summary: summary,
      probableCause:
          'A JavaScript promise or Dart Future completed with an error that was not handled locally.',
      suggestedFix:
          'Add local catchError/try-catch handling around the async operation and inspect the rejected reason.$sourceMapHint',
    );
  }

  if (_looksLikeNetworkError(lower)) {
    return WebRuntimeErrorClassification(
      kind: 'web_network_error',
      summary: summary,
      probableCause:
          'A browser network request failed before Flutter received a response.',
      suggestedFix:
          'Check the request URL, CORS policy, credentials, and browser Network tab.$sourceMapHint',
    );
  }

  if (_looksLikeNullOrUndefined(lower)) {
    return WebRuntimeErrorClassification(
      kind: 'web_null_reference',
      summary: summary,
      probableCause:
          'Compiled web code tried to read a null or undefined value.',
      suggestedFix:
          'Inspect the Dart call site, add null checks, and verify values from JavaScript or platform channels.$sourceMapHint',
    );
  }

  if (_looksLikeJsInterop(lower)) {
    return WebRuntimeErrorClassification(
      kind: 'web_js_interop_error',
      summary: summary,
      probableCause:
          'Dart code crossed a JavaScript interop boundary with an unexpected value or API shape.',
      suggestedFix:
          'Validate JS interop arguments, browser API availability, and any promise result before using it.$sourceMapHint',
    );
  }

  if (_looksLikeCompiledLocation(file: file, text: lower)) {
    return WebRuntimeErrorClassification(
      kind: 'web_compiled_stack_trace',
      summary: summary,
      probableCause:
          'The browser reported a compiled JavaScript location instead of the original Dart source.',
      suggestedFix:
          'Build Flutter Web with --source-maps and keep or upload the generated .map files so the stack can be mapped back to Dart.',
    );
  }

  return WebRuntimeErrorClassification(
    kind: 'web_runtime_error',
    summary: summary,
    probableCause:
        'The browser reported an uncaught Flutter Web runtime error.',
    suggestedFix:
        'Inspect the route, recent signals, browser console, and source-mapped stack frame.$sourceMapHint',
  );
}

/// Logs a classified Flutter Web browser runtime error.
///
/// This is the manual equivalent of the installed web hooks. It is useful in
/// tests, examples, and custom browser integrations that already have access to
/// `error` or `unhandledrejection` event details.
core.LogEvent? logClassifiedWebRuntimeError(
  Object? error, {
  String? message,
  StackTrace? stackTrace,
  String? file,
  int? line,
  int? column,
  String source = 'web_runtime',
  bool isUnhandledRejection = false,
  core.Level level = .error,
  core.AiLogger? target,
}) {
  final classification = classifyWebRuntimeError(
    error,
    message: message,
    file: file,
    line: line,
    column: column,
    isUnhandledRejection: isUnhandledRejection,
  );
  final activeLogger = target ?? core.logger;
  return activeLogger.log(
    level,
    classification.summary,
    error: error ?? message,
    stackTrace: stackTrace,
    source: source,
    kind: classification.kind,
    file: file,
    line: line,
    column: column,
    probableCause: classification.probableCause,
    suggestedFix: classification.suggestedFix,
  );
}

String _summary(Object? error, String? message) {
  for (final candidate in [message, error?.toString()]) {
    final text = candidate?.trim();
    if (text != null && text.isNotEmpty && text != 'null') {
      return _firstLine(text);
    }
  }
  return 'Unhandled Flutter Web runtime error.';
}

String _firstLine(String text) {
  for (final rawLine in text.split('\n')) {
    final line = rawLine.trim();
    if (line.isNotEmpty) {
      return line;
    }
  }
  return text.trim();
}

bool _looksLikeNetworkError(String text) {
  return text.contains('failed to fetch') ||
      text.contains('xmlhttprequest error') ||
      text.contains('networkerror') ||
      text.contains('cors') ||
      text.contains('load failed') ||
      text.contains('connection refused');
}

bool _looksLikeNullOrUndefined(String text) {
  return text.contains('cannot read properties of null') ||
      text.contains('cannot read property') ||
      text.contains('undefined is not') ||
      text.contains('null check operator') ||
      text.contains("type 'null' is not a subtype");
}

bool _looksLikeJsInterop(String text) {
  return text.contains('jsobject') ||
      text.contains('js_util') ||
      text.contains('javascript') ||
      text.contains('promise') ||
      text.contains('allowInterop'.toLowerCase());
}

bool _looksLikeCompiledLocation({String? file, required String text}) {
  final location = file?.toLowerCase() ?? '';
  return location.endsWith('.dart.js') ||
      location.contains('.dart.js:') ||
      text.contains('main.dart.js') ||
      text.contains('.dart.js:');
}

String _sourceMapHint({String? file, required String text}) {
  if (!_looksLikeCompiledLocation(file: file, text: text)) {
    return '';
  }
  return ' If the location points to main.dart.js, build with --source-maps and keep or upload the generated .map files.';
}
