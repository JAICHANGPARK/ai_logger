import 'dart:async';

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
            .fatal,
            error,
            error: error,
            stackTrace: stackTrace,
            source: 'zone',
          );
        },
        zoneSpecification: capturePrint
            ? ZoneSpecification(
                print: (_, parent, zone, line) {
                  activeLogger.log(.info, line, source: 'print');
                  parent.print(zone, line);
                },
              )
            : null,
      )
      as R;
}
