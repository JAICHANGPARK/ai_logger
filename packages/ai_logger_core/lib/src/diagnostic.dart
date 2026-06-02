import 'dart:math' as math;

import 'event.dart';

typedef SourceLoader = String? Function(String path);

class DiagnosticRenderer {
  const DiagnosticRenderer({this.contextLines = 2});

  final int contextLines;

  String render(LogEvent event, {SourceLoader? sourceLoader}) {
    final kind = event.kind ?? 'runtime_error';
    final buffer = StringBuffer()
      ..writeln('${event.level.label}[${kind}]: ${event.message}');

    final location = event.location;
    if (location != null) {
      buffer.writeln(' --> $location');
    }

    final sourceFrame = _renderSourceFrame(event, sourceLoader);
    if (sourceFrame != null) {
      buffer.write(sourceFrame);
    }

    if (event.suggestedFix case final String fix) {
      buffer.writeln(' help: $fix');
    }
    return buffer.toString().trimRight();
  }

  String? _renderSourceFrame(LogEvent event, SourceLoader? sourceLoader) {
    final file = event.file ?? event.primaryAppFrame?.normalizedPath;
    final line = event.line ?? event.primaryAppFrame?.line;
    if (file == null || line == null || sourceLoader == null) {
      return null;
    }
    final source = sourceLoader(file);
    if (source == null) {
      return null;
    }

    final lines = source.split('\n');
    if (line < 1 || line > lines.length) {
      return null;
    }

    final start = math.max(1, line - contextLines);
    final end = math.min(lines.length, line + contextLines);
    final width = end.toString().length;
    final column = math.max(
      1,
      event.column ?? event.primaryAppFrame?.column ?? 1,
    );
    final label =
        event.probableCause ?? event.likelyWidget ?? 'primary app frame';
    final frame = StringBuffer();

    for (var index = start; index <= end; index += 1) {
      final code = lines[index - 1];
      frame.writeln(' ${index.toString().padLeft(width)} | $code');
      if (index == line) {
        final caretOffset = math.min(math.max(column - 1, 0), code.length);
        frame.writeln(' ${''.padLeft(width)} | ${' ' * caretOffset}^ $label');
      }
    }
    return frame.toString();
  }
}
