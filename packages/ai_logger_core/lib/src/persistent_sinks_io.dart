import 'dart:convert';
import 'dart:io';

import 'event.dart';
import 'sinks.dart';

class FileJsonlSink implements LogSink {
  FileJsonlSink(String path) : _file = File(path) {
    final parent = _file.parent;
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }
  }

  final File _file;

  String get path => _file.path;

  @override
  void add(LogEvent event) {
    _file.writeAsStringSync(
      '${jsonEncode(event.toJson())}\n',
      mode: FileMode.append,
    );
  }

  List<LogEvent> readEvents() {
    if (!_file.existsSync()) {
      return const [];
    }
    final events = <LogEvent>[];
    for (final line in _file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        events.add(
          LogEvent.fromJson({
            for (final entry in decoded.entries)
              entry.key.toString(): entry.value,
          }),
        );
      }
    }
    return events;
  }
}
