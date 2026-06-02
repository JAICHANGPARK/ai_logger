import 'dart:async';

import 'package:logger/logger.dart' as logger_pkg;
import 'package:logging/logging.dart' as logging_pkg;

import 'level.dart';
import 'logger.dart';

StreamSubscription<logging_pkg.LogRecord> captureLoggingPackage({
  AiLogger? target,
  logging_pkg.Level rootLevel = logging_pkg.Level.ALL,
  String sourcePrefix = 'package:logging',
}) {
  final activeLogger = target ?? logger;
  logging_pkg.Logger.root.level = rootLevel;
  return logging_pkg.Logger.root.onRecord.listen((record) {
    activeLogger.log(
      _fromLoggingLevel(record.level),
      record.message,
      error: record.error,
      stackTrace: record.stackTrace,
      source: '$sourcePrefix:${record.loggerName}',
      member: record.loggerName,
    );
  });
}

class AiLoggerOutput extends logger_pkg.LogOutput {
  AiLoggerOutput({AiLogger? target, this.source = 'package:logger'})
    : _target = target ?? logger;

  final AiLogger _target;
  final String source;

  @override
  void output(logger_pkg.OutputEvent event) {
    _target.log(
      _fromLoggerLevel(event.origin.level),
      event.origin.message,
      error: event.origin.error,
      stackTrace: event.origin.stackTrace,
      source: source,
    );
  }
}

Level _fromLoggingLevel(logging_pkg.Level level) {
  if (level >= logging_pkg.Level.SHOUT) {
    return .fatal;
  }
  if (level >= logging_pkg.Level.SEVERE) {
    return .error;
  }
  if (level >= logging_pkg.Level.WARNING) {
    return .warning;
  }
  if (level >= logging_pkg.Level.INFO) {
    return .info;
  }
  if (level >= logging_pkg.Level.FINE) {
    return .debug;
  }
  return .trace;
}

Level _fromLoggerLevel(logger_pkg.Level level) {
  final value = level.value;
  if (value >= logger_pkg.Level.fatal.value) {
    return .fatal;
  }
  if (value >= logger_pkg.Level.error.value) {
    return .error;
  }
  if (value >= logger_pkg.Level.warning.value) {
    return .warning;
  }
  if (value >= logger_pkg.Level.info.value) {
    return .info;
  }
  if (value >= logger_pkg.Level.debug.value) {
    return .debug;
  }
  return .trace;
}
