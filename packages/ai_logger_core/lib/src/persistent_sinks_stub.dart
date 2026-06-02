import 'event.dart';
import 'sinks.dart';

class FileJsonlSink implements LogSink {
  FileJsonlSink(String path) : path = path {
    throw UnsupportedError(
      'FileJsonlSink is only available on dart:io platforms.',
    );
  }

  final String path;

  @override
  void add(LogEvent event) {
    throw UnsupportedError(
      'FileJsonlSink is only available on dart:io platforms.',
    );
  }

  List<LogEvent> readEvents() {
    throw UnsupportedError(
      'FileJsonlSink is only available on dart:io platforms.',
    );
  }
}
