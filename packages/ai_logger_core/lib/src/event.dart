import 'context.dart';
import 'level.dart';
import 'stack_trace_parser.dart';

class LogEvent {
  const LogEvent({
    required this.timestamp,
    required this.level,
    required this.message,
    this.source = 'app',
    this.kind,
    this.error,
    this.stackTrace,
    this.file,
    this.line,
    this.column,
    this.member,
    this.likelyWidget,
    this.probableCause,
    this.suggestedFix,
    this.context = const {},
    this.breadcrumbs = const [],
    this.appFrames = const [],
  });

  final DateTime timestamp;
  final Level level;
  final String source;
  final String message;
  final String? kind;
  final String? error;
  final String? stackTrace;
  final String? file;
  final int? line;
  final int? column;
  final String? member;
  final String? likelyWidget;
  final String? probableCause;
  final String? suggestedFix;
  final Map<String, Object?> context;
  final List<Breadcrumb> breadcrumbs;
  final List<StackFrame> appFrames;

  StackFrame? get primaryAppFrame => appFrames.isEmpty ? null : appFrames.first;

  String? get location {
    final path = file ?? primaryAppFrame?.normalizedPath;
    if (path == null) {
      return null;
    }
    final parts = [
      path,
      if (line ?? primaryAppFrame?.line case final int value) value,
      if (column ?? primaryAppFrame?.column case final int value) value,
    ];
    return parts.join(':');
  }

  Map<String, Object?> toJson() {
    return {
      't': timestamp.toIso8601String(),
      'lv': level.code,
      'src': source,
      'msg': message,
      if (kind != null) 'kind': kind,
      if (error != null) 'error': error,
      if (stackTrace != null) 'stack': stackTrace,
      if (file != null) 'file': file,
      if (line != null) 'line': line,
      if (column != null) 'col': column,
      if (member != null) 'member': member,
      if (likelyWidget != null) 'likelyWidget': likelyWidget,
      if (probableCause != null) 'probableCause': probableCause,
      if (suggestedFix != null) 'suggestedFix': suggestedFix,
      if (context.isNotEmpty) 'ctx': context,
      if (breadcrumbs.isNotEmpty)
        'breadcrumbs': breadcrumbs.map((item) => item.toJson()).toList(),
      if (appFrames.isNotEmpty)
        'appFrames': appFrames.map((frame) => frame.toJson()).toList(),
    };
  }

  static LogEvent fromJson(Map<String, Object?> json) {
    return LogEvent(
      timestamp:
          DateTime.tryParse(json['t']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      level: Level.parse(json['lv']),
      source: json['src']?.toString() ?? 'app',
      message: json['msg']?.toString() ?? '',
      kind: json['kind']?.toString(),
      error: json['error']?.toString(),
      stackTrace: json['stack']?.toString(),
      file: json['file']?.toString(),
      line: _intOrNull(json['line']),
      column: _intOrNull(json['col'] ?? json['column']),
      member: json['member']?.toString(),
      likelyWidget: json['likelyWidget']?.toString(),
      probableCause: json['probableCause']?.toString(),
      suggestedFix: json['suggestedFix']?.toString(),
      context: _objectMap(json['ctx']),
      breadcrumbs: _listOfMaps(
        json['breadcrumbs'],
      ).map(Breadcrumb.fromJson).toList(growable: false),
      appFrames: _listOfMaps(
        json['appFrames'],
      ).map(StackFrame.fromJson).toList(growable: false),
    );
  }
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }
  return const {};
}

List<Map<String, Object?>> _listOfMaps(Object? value) {
  if (value is! Iterable) {
    return const [];
  }
  return [
    for (final item in value)
      if (item is Map)
        {for (final entry in item.entries) entry.key.toString(): entry.value},
  ];
}

int? _intOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return int.tryParse(value.toString());
}
