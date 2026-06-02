class StackFrame {
  const StackFrame({
    required this.member,
    required this.uri,
    this.line,
    this.column,
  });

  final String member;
  final String uri;
  final int? line;
  final int? column;

  String get normalizedPath {
    if (uri.startsWith('package:')) {
      final slash = uri.indexOf('/');
      if (slash == -1 || slash == uri.length - 1) {
        return uri;
      }
      final rest = uri.substring(slash + 1);
      return rest.startsWith('lib/') ? rest : 'lib/$rest';
    }
    if (uri.startsWith('file:')) {
      final path = Uri.tryParse(uri)?.toFilePath();
      if (path == null) {
        return uri;
      }
      final libIndex = path.lastIndexOf('/lib/');
      return libIndex == -1 ? path : path.substring(libIndex + 1);
    }
    final libIndex = uri.lastIndexOf('/lib/');
    return libIndex == -1 ? uri : uri.substring(libIndex + 1);
  }

  Map<String, Object?> toJson() {
    return {
      'member': member,
      'uri': uri,
      if (line != null) 'line': line,
      if (column != null) 'column': column,
    };
  }

  static StackFrame fromJson(Map<String, Object?> json) {
    return StackFrame(
      member: json['member']?.toString() ?? '',
      uri: json['uri']?.toString() ?? '',
      line: _intOrNull(json['line']),
      column: _intOrNull(json['column']),
    );
  }

  @override
  String toString() {
    final location = [
      normalizedPath,
      if (line != null) line,
      if (column != null) column,
    ].join(':');
    return member.isEmpty ? location : '$location $member';
  }
}

class StackTraceParser {
  const StackTraceParser();

  static final RegExp _vmFrame = RegExp(
    r'^#\d+\s+(.+?)\s+\((.+?)(?::(\d+))?(?::(\d+))?\)$',
  );

  static final RegExp _plainFrame = RegExp(
    r'^(.+?)\s+\((.+?)(?::(\d+))?(?::(\d+))?\)$',
  );

  static List<StackFrame> parse(Object? stackTrace) {
    if (stackTrace == null) {
      return const [];
    }
    final frames = <StackFrame>[];
    for (final rawLine in stackTrace.toString().split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      final match = _vmFrame.firstMatch(line) ?? _plainFrame.firstMatch(line);
      if (match == null) {
        continue;
      }
      frames.add(
        StackFrame(
          member: match.group(1)?.trim() ?? '',
          uri: match.group(2)?.trim() ?? '',
          line: _intOrNull(match.group(3)),
          column: _intOrNull(match.group(4)),
        ),
      );
    }
    return frames;
  }
}

const Set<String> _frameworkPackages = {
  'async',
  'collection',
  'flutter',
  'flutter_test',
  'meta',
  'sky_engine',
  'stack_trace',
  'test',
  'test_api',
  'vector_math',
  'vm_service',
  'ai_logger',
  'ai_logger_core',
};

List<StackFrame> filterAppFrames(
  Iterable<StackFrame> frames, {
  Set<String> frameworkPackages = _frameworkPackages,
}) {
  return frames.where((frame) {
    final uri = frame.uri;
    if (uri.startsWith('dart:')) {
      return false;
    }
    if (uri.startsWith('package:')) {
      final slash = uri.indexOf('/');
      final packageName = slash == -1
          ? uri.substring(8)
          : uri.substring(8, slash);
      return !frameworkPackages.contains(packageName);
    }
    return uri.contains('/lib/') || uri.endsWith('.dart');
  }).toList();
}

int? _intOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  return int.tryParse(value.toString());
}
