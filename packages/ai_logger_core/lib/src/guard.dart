import 'dart:async';

import 'level.dart';
import 'logger.dart';
import 'options.dart';
import 'sinks.dart';

R guard<R>(
  R Function() body, {
  Options? options,
  Iterable<LogSink>? sinks,
  AiLogger? target,
}) {
  final activeLogger = target ?? logger;
  if (options != null || sinks != null) {
    activeLogger.configure(options: options, sinks: sinks);
  }
  final capturePrint = activeLogger.options.capturePrint;
  return runZonedGuarded(
        body,
        (error, stackTrace) {
          activeLogger.log(
            Level.fatal,
            error,
            error: error,
            stackTrace: stackTrace,
            source: 'zone',
          );
        },
        zoneSpecification: capturePrint
            ? ZoneSpecification(
                print: (_, __, ___, line) {
                  activeLogger.log(Level.info, line, source: 'print');
                },
              )
            : null,
      )
      as R;
}
