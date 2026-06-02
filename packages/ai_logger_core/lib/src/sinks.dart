import 'dart:convert';

import 'event.dart';

abstract interface class LogSink {
  void add(LogEvent event);
}

class MemorySink implements LogSink {
  final List<LogEvent> events = [];

  @override
  void add(LogEvent event) {
    events.add(event);
  }

  void clear() {
    events.clear();
  }
}

class JsonlStringSink implements LogSink {
  const JsonlStringSink(this.writeLine);

  final void Function(String line) writeLine;

  @override
  void add(LogEvent event) {
    writeLine(jsonEncode(event.toJson()));
  }
}
