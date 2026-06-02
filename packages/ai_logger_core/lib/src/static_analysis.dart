import 'dart:convert';
import 'dart:math' as math;

import 'diagnostic.dart';
import 'report.dart';

enum AnalysisSeverity {
  error,
  warning,
  info;

  static AnalysisSeverity parse(String value) {
    return switch (value.toLowerCase()) {
      'error' => AnalysisSeverity.error,
      'warning' || 'warn' => AnalysisSeverity.warning,
      _ => AnalysisSeverity.info,
    };
  }
}

class StaticAnalysisIssue {
  const StaticAnalysisIssue({
    required this.severity,
    required this.file,
    required this.line,
    required this.column,
    required this.message,
    required this.code,
    this.correction,
  });

  final AnalysisSeverity severity;
  final String file;
  final int line;
  final int column;
  final String message;
  final String code;
  final String? correction;

  Map<String, Object?> toJson() {
    return {
      'severity': severity.name,
      'file': file,
      'line': line,
      'column': column,
      'message': message,
      'code': code,
      if (correction != null) 'correction': correction,
    };
  }
}

class StaticAnalysisParser {
  const StaticAnalysisParser();

  static final RegExp _issueLine = RegExp(
    r'^\s*(error|warning|info)\s+-\s+(.+?):(\d+):(\d+)\s+-\s+(.+)\s+-\s+([A-Za-z0-9_]+)\s*$',
  );

  List<StaticAnalysisIssue> parse(String output) {
    final issues = <StaticAnalysisIssue>[];
    for (final rawLine in output.split('\n')) {
      final line = rawLine.trimRight();
      final match = _issueLine.firstMatch(line);
      if (match == null) {
        continue;
      }
      final messageParts = _splitCorrection(match.group(5)!.trim());
      issues.add(
        StaticAnalysisIssue(
          severity: AnalysisSeverity.parse(match.group(1)!),
          file: match.group(2)!.trim(),
          line: int.parse(match.group(3)!),
          column: int.parse(match.group(4)!),
          message: messageParts.$1,
          correction: messageParts.$2,
          code: match.group(6)!.trim(),
        ),
      );
    }
    return issues;
  }

  (String, String?) _splitCorrection(String message) {
    final tryIndex = message.indexOf('. Try ');
    if (tryIndex == -1) {
      return (message, null);
    }
    final summary = message.substring(0, tryIndex + 1).trim();
    final correction = message.substring(tryIndex + 2).trim();
    return (summary, correction);
  }
}

class StaticAnalysisReport {
  const StaticAnalysisReport(this.issues);

  final List<StaticAnalysisIssue> issues;

  String format(ReportFormat format, {SourceLoader? sourceLoader}) {
    return switch (format) {
      ReportFormat.markdown => toMarkdown(),
      ReportFormat.compactJson => toCompactJsonString(),
      ReportFormat.diagnostic => toDiagnostic(sourceLoader: sourceLoader),
    };
  }

  String toMarkdown() {
    if (issues.isEmpty) {
      return '# Static Analysis\nNo issues found.';
    }

    final errorCount = issues
        .where((issue) => issue.severity == AnalysisSeverity.error)
        .length;
    final warningCount = issues
        .where((issue) => issue.severity == AnalysisSeverity.warning)
        .length;
    final infoCount = issues
        .where((issue) => issue.severity == AnalysisSeverity.info)
        .length;
    final buffer = StringBuffer()
      ..writeln('# Static Analysis')
      ..writeln(
        'Issues: ${issues.length} total, $errorCount error, '
        '$warningCount warning, $infoCount info.',
      )
      ..writeln()
      ..writeln('# Issues');

    for (var index = 0; index < issues.length; index += 1) {
      final issue = issues[index];
      buffer
        ..writeln('${index + 1}. ${issue.severity.name}[${issue.code}]')
        ..writeln('   Location: ${issue.file}:${issue.line}:${issue.column}')
        ..writeln('   Message: ${issue.message}');
      if (issue.correction case final String correction) {
        buffer.writeln('   Suggested fix: $correction');
      }
    }

    return buffer.toString().trimRight();
  }

  String toDiagnostic({SourceLoader? sourceLoader}) {
    if (issues.isEmpty) {
      return 'analysis: No issues found.';
    }
    return issues
        .map((issue) => _renderIssue(issue, sourceLoader: sourceLoader))
        .join('\n\n');
  }

  String toCompactJsonString() {
    return const JsonEncoder.withIndent(
      '  ',
    ).convert({'issues': issues.map((issue) => issue.toJson()).toList()});
  }

  String _renderIssue(StaticAnalysisIssue issue, {SourceLoader? sourceLoader}) {
    final buffer = StringBuffer()
      ..writeln('${issue.severity.name}[${issue.code}]: ${issue.message}')
      ..writeln(' --> ${issue.file}:${issue.line}:${issue.column}');

    final frame = _renderSourceFrame(issue, sourceLoader);
    if (frame != null) {
      buffer.write(frame);
    }

    if (issue.correction case final String correction) {
      buffer.writeln(' help: $correction');
    }
    return buffer.toString().trimRight();
  }

  String? _renderSourceFrame(
    StaticAnalysisIssue issue,
    SourceLoader? sourceLoader,
  ) {
    if (sourceLoader == null) {
      return null;
    }
    final source = sourceLoader(issue.file);
    if (source == null) {
      return null;
    }
    final lines = source.split('\n');
    if (issue.line < 1 || issue.line > lines.length) {
      return null;
    }

    final start = math.max(1, issue.line - 2);
    final end = math.min(lines.length, issue.line + 2);
    final width = end.toString().length;
    final frame = StringBuffer();
    for (var index = start; index <= end; index += 1) {
      final code = lines[index - 1];
      frame.writeln(' ${index.toString().padLeft(width)} | $code');
      if (index == issue.line) {
        final caretOffset = math.min(
          math.max(issue.column - 1, 0),
          code.length,
        );
        frame.writeln(
          ' ${''.padLeft(width)} | ${' ' * caretOffset}^ ${issue.code}',
        );
      }
    }
    return frame.toString();
  }
}
