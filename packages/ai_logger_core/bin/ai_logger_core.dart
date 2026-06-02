import 'dart:convert';
import 'dart:io';

import 'package:ai_logger_core/ai_logger_core.dart';

void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  switch (args.first) {
    case 'report':
      _report(args.skip(1).toList());
    case 'flutter-test':
      stdout.writeln(
        'Use the ai_logger Flutter package tests for hook and classifier checks.',
      );
    default:
      stderr.writeln('Unknown command: ${args.first}');
      _printUsage();
      exitCode = 64;
  }
}

void _report(List<String> args) {
  var format = ReportFormat.markdown;
  var useLast = false;
  var jsonlPath = '.ai_logger/events.jsonl';
  var projectRoot = Directory.current.path;

  for (var index = 0; index < args.length; index += 1) {
    final arg = args[index];
    switch (arg) {
      case '--last':
        useLast = true;
      case '--format':
        index += 1;
        format = ReportFormat.parse(index < args.length ? args[index] : null);
      case '--file':
        index += 1;
        if (index < args.length) {
          jsonlPath = args[index];
        }
      case '--project':
        index += 1;
        if (index < args.length) {
          projectRoot = args[index];
        }
      default:
        stderr.writeln('Unknown option: $arg');
        exitCode = 64;
        return;
    }
  }

  final file = File(_resolvePath(jsonlPath, Directory.current.path));
  if (!file.existsSync()) {
    stderr.writeln('No JSONL log file found: ${file.path}');
    exitCode = 66;
    return;
  }

  final events = <LogEvent>[];
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        events.add(
          LogEvent.fromJson({
            for (final entry in decoded.entries)
              entry.key.toString(): entry.value,
          }),
        );
      }
    } on FormatException catch (error) {
      stderr.writeln('Skipping invalid JSONL entry: $error');
    }
  }

  if (events.isEmpty) {
    stderr.writeln('No events found in ${file.path}');
    exitCode = 66;
    return;
  }

  final event = useLast ? _lastReportable(events) : events.last;
  final report = ReportGenerator().build(event, events);
  stdout.writeln(
    report.format(
      format,
      sourceLoader: (path) => _loadSource(path, projectRoot),
    ),
  );
}

LogEvent _lastReportable(List<LogEvent> events) {
  for (final event in events.reversed) {
    if (event.level.index >= Level.error.index) {
      return event;
    }
  }
  return events.last;
}

String? _loadSource(String path, String projectRoot) {
  final candidates = <String>[];
  if (path.startsWith('package:')) {
    final slash = path.indexOf('/');
    if (slash != -1 && slash + 1 < path.length) {
      final rest = path.substring(slash + 1);
      candidates.add(
        _resolvePath(rest.startsWith('lib/') ? rest : 'lib/$rest', projectRoot),
      );
    }
  } else if (path.startsWith('file:')) {
    final uri = Uri.tryParse(path);
    if (uri != null) {
      candidates.add(uri.toFilePath());
    }
  } else {
    candidates.add(_resolvePath(path, projectRoot));
    candidates.add(path);
  }

  for (final candidate in candidates) {
    final file = File(candidate);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
  }
  return null;
}

String _resolvePath(String path, String root) {
  if (path.startsWith('/')) {
    return path;
  }
  return '$root/$path';
}

void _printUsage() {
  stdout.writeln('''
Usage:
  dart run ai_logger_core report --last [--format markdown|diagnostic|json]
  dart run ai_logger_core report --file .ai_logger/events.jsonl --project .
  dart run ai_logger_core flutter-test
''');
}
