import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'context.dart';
import 'diagnostic.dart';
import 'event.dart';
import 'level.dart';
import 'options.dart';
import 'redaction.dart';
import 'report.dart';
import 'sinks.dart';
import 'stack_trace_parser.dart';

class AiLogger {
  AiLogger({
    Options options = const Options(),
    Iterable<LogSink> sinks = const [],
    LoggerContext? context,
  }) : _options = options,
       _redactor = options.createRedactor(),
       context = context ?? LoggerContext() {
    _sinks.addAll(sinks);
  }

  Options _options;
  Redactor _redactor;
  final List<LogSink> _sinks = [];
  final Queue<LogEvent> _recent = Queue();

  final LoggerContext context;

  Options get options => _options;

  List<LogEvent> get recentEvents => List.unmodifiable(_recent);

  List<LogEvent> recentEventsWhere({Iterable<Level>? levels}) {
    if (levels == null) {
      return recentEvents;
    }
    final levelSet = levels.toSet();
    if (levelSet.isEmpty) {
      return const [];
    }
    return List.unmodifiable(
      _recent.where((event) => levelSet.contains(event.level)),
    );
  }

  LogEvent? get lastReportableEvent {
    for (final event in _recent.toList().reversed) {
      if (_options.reportLevel.allows(event.level)) {
        return event;
      }
    }
    return _recent.isEmpty ? null : _recent.last;
  }

  void configure({Options? options, Iterable<LogSink>? sinks}) {
    if (options != null) {
      _options = options;
      _redactor = options.createRedactor();
    }
    if (sinks != null) {
      _sinks
        ..clear()
        ..addAll(sinks);
    }
  }

  void addSink(LogSink sink) {
    _sinks.add(sink);
  }

  void clearSinks() {
    _sinks.clear();
  }

  LogEvent? log(
    Level level,
    Object message, {
    Object? error,
    StackTrace? stackTrace,
    String source = 'app',
    String? kind,
    String? file,
    int? line,
    int? column,
    String? member,
    String? likelyWidget,
    String? probableCause,
    String? suggestedFix,
    List<StackFrame>? appFrames,
  }) {
    if (!_options.captureLevel.allows(level)) {
      return null;
    }
    final parsedFrames =
        appFrames ?? filterAppFrames(StackTraceParser.parse(stackTrace));
    final primaryFrame = parsedFrames.isEmpty ? null : parsedFrames.first;
    final event = LogEvent(
      timestamp: DateTime.now(),
      level: level,
      source: source,
      message: _redactor.redactText(message.toString()),
      kind: kind,
      error: error == null ? null : _redactor.redactText(error.toString()),
      stackTrace: stackTrace == null
          ? null
          : _redactor.redactText(stackTrace.toString()),
      file: file ?? primaryFrame?.normalizedPath,
      line: line ?? primaryFrame?.line,
      column: column ?? primaryFrame?.column,
      member: member ?? primaryFrame?.member,
      likelyWidget: likelyWidget,
      probableCause: probableCause,
      suggestedFix: suggestedFix,
      context: _redactor.redactValue(context.values) as Map<String, Object?>,
      breadcrumbs: context.breadcrumbs,
      appFrames: parsedFrames,
    );
    _remember(event);
    for (final sink in _sinks) {
      sink.add(event);
    }
    _emitReport(event);
    return event;
  }

  String exportRecentJsonLines({Iterable<Level>? levels}) {
    return recentEventsWhere(
      levels: levels,
    ).map((event) => jsonEncode(event.toJson())).join('\n');
  }

  AiReport? buildReport({LogEvent? event}) {
    final target = event ?? lastReportableEvent;
    if (target == null) {
      return null;
    }
    return ReportGenerator(
      recentSignalLimit: _options.recentSignalLimit,
      recentSignalLevels: _options.recentSignalLevels,
    ).build(target, _recent);
  }

  String? formatLastReport(ReportFormat format, {SourceLoader? sourceLoader}) {
    return buildReport()?.format(
      format,
      sourceLoader: sourceLoader ?? _options.reportSourceLoader,
    );
  }

  void _remember(LogEvent event) {
    _recent.add(event);
    final maxEvents = _options.recentSignalLimit * 4;
    while (_recent.length > maxEvents) {
      _recent.removeFirst();
    }
  }

  void _emitReport(LogEvent event) {
    if (!_options.printReports || !_options.reportLevel.allows(event.level)) {
      return;
    }
    final generator = ReportGenerator(
      recentSignalLimit: _options.recentSignalLimit,
      recentSignalLevels: _options.recentSignalLevels,
    );
    final report = generator
        .build(event, _recent)
        .format(
          _options.reportFormat,
          sourceLoader: _options.reportSourceLoader,
        );
    final writer = _options.reportWriter ?? Zone.root.print;
    writer(report);
  }
}

final AiLogger logger = AiLogger();

LoggerContext get context => logger.context;

void configure({Options? options, Iterable<LogSink>? sinks}) {
  logger.configure(options: options, sinks: sinks);
}

List<LogEvent> recentEventsWhere({Iterable<Level>? levels}) {
  return logger.recentEventsWhere(levels: levels);
}

LogEvent? t(Object message, {String source = 'app'}) {
  return logger.log(Level.trace, message, source: source);
}

LogEvent? d(Object message, {String source = 'app'}) {
  return logger.log(Level.debug, message, source: source);
}

LogEvent? i(Object message, {String source = 'app'}) {
  return logger.log(Level.info, message, source: source);
}

LogEvent? w(
  Object message, {
  Object? error,
  StackTrace? stackTrace,
  String source = 'app',
}) {
  return logger.log(
    Level.warning,
    message,
    error: error,
    stackTrace: stackTrace,
    source: source,
  );
}

LogEvent? e(
  Object message, {
  Object? error,
  StackTrace? stackTrace,
  String source = 'app',
}) {
  return logger.log(
    Level.error,
    message,
    error: error,
    stackTrace: stackTrace,
    source: source,
  );
}

LogEvent? f(
  Object message, {
  Object? error,
  StackTrace? stackTrace,
  String source = 'app',
}) {
  return logger.log(
    Level.fatal,
    message,
    error: error,
    stackTrace: stackTrace,
    source: source,
  );
}

void breadcrumb(String name, {Map<String, Object?> data = const {}}) {
  context.addBreadcrumb(name, data: data);
}

AiReport? buildReport({LogEvent? event}) {
  return logger.buildReport(event: event);
}

String? formatLastReport(ReportFormat format, {SourceLoader? sourceLoader}) {
  return logger.formatLastReport(format, sourceLoader: sourceLoader);
}
