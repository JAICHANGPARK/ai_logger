import 'dart:convert';
import 'dart:io';

import 'package:ai_logger_core/ai_logger_core.dart' as ailog;
import 'package:logger/logger.dart' as logger_pkg;
import 'package:logging/logging.dart' as logging_pkg;
import 'package:test/test.dart';

void main() {
  test('captures only events at or above the configured level', () {
    final sink = ailog.MemorySink();
    final logger = ailog.AiLogger(
      options: const ailog.Options(captureLevel: ailog.Level.warning),
      sinks: [sink],
    );

    logger.log(ailog.Level.info, 'hidden');
    logger.log(ailog.Level.error, 'visible');

    expect(sink.events, hasLength(1));
    expect(sink.events.single.message, 'visible');
  });

  test('serializes compact JSONL fields and restores events', () {
    final sinkLines = <String>[];
    final logger = ailog.AiLogger(
      sinks: [ailog.JsonlStringSink(sinkLines.add)],
    );
    logger.context.setRoute('/login');

    final event = logger.log(
      ailog.Level.error,
      'token=abc123 failed for user@example.com',
      error: StateError('apiKey=secret'),
      kind: 'login_error',
      file: 'lib/login.dart',
      line: 12,
    );

    expect(event, isNotNull);
    final decoded = jsonDecode(sinkLines.single) as Map<String, Object?>;
    expect(decoded['lv'], 'E');
    expect(decoded['src'], 'app');
    expect(decoded['kind'], 'login_error');
    expect(decoded['msg'], contains('[REDACTED_SECRET]'));
    expect(decoded['msg'], contains('[REDACTED_EMAIL]'));

    final restored = ailog.LogEvent.fromJson(decoded);
    expect(restored.level, ailog.Level.error);
    expect(restored.file, 'lib/login.dart');
    expect(restored.context['route'], '/login');
  });

  test('filters framework stack frames and keeps primary app frame', () {
    final stack = StackTrace.fromString('''
#0      RenderObject.layout (package:flutter/src/rendering/object.dart:100:1)
#1      ProfileHeader.build (package:demo/features/profile/profile_header.dart:31:12)
''');

    final frames = ailog.filterAppFrames(ailog.StackTraceParser.parse(stack));

    expect(frames, hasLength(1));
    expect(
      frames.single.normalizedPath,
      'lib/features/profile/profile_header.dart',
    );
    expect(frames.single.line, 31);
  });

  test('generates AI-friendly markdown with recent signals', () {
    final info = ailog.LogEvent(
      timestamp: DateTime(2026, 6, 2, 10),
      level: ailog.Level.info,
      message: 'loaded profile',
      context: const {'route': '/profile'},
    );
    final error = ailog.LogEvent(
      timestamp: DateTime(2026, 6, 2, 10, 1),
      level: ailog.Level.error,
      source: 'flutter',
      message: 'RenderFlex overflowed by 42px',
      kind: 'render_flex_overflow',
      file: 'lib/profile.dart',
      line: 31,
      likelyWidget: 'Row',
      probableCause: 'A Row child is wider than the available width.',
      suggestedFix: 'Wrap the wide child with Expanded or Flexible.',
    );

    final report = ailog.ReportGenerator().build(error, [info, error]);
    final markdown = report.toMarkdown();

    expect(markdown, contains('# Flutter Error'));
    expect(markdown, contains('Kind: render_flex_overflow'));
    expect(markdown, contains('# Recent Signals'));
    expect(markdown, contains('route=/profile'));
  });

  test('renders Rust-style source diagnostics when source is available', () {
    final event = ailog.LogEvent(
      timestamp: DateTime(2026, 6, 2),
      level: ailog.Level.error,
      message: 'Row overflowed by 42px on the right',
      kind: 'render_flex_overflow',
      file: 'lib/profile_header.dart',
      line: 3,
      column: 5,
      probableCause: 'this child is probably unconstrained',
      suggestedFix: 'wrap the wide child with Expanded or Flexible',
    );

    final rendered = ailog.DiagnosticRenderer().render(
      event,
      sourceLoader: (_) => '''
return Row(
  children: [
    Text(user.name),
    IconButton(onPressed: save),
  ],
);''',
    );

    expect(rendered, contains('error[render_flex_overflow]'));
    expect(rendered, contains('--> lib/profile_header.dart:3:5'));
    expect(rendered, contains('^ this child is probably unconstrained'));
    expect(rendered, contains('help: wrap the wide child'));
  });

  test('guard captures print output as info events', () {
    final sink = ailog.MemorySink();
    final logger = ailog.AiLogger(sinks: [sink]);

    ailog.guard<void>(() {
      print('server started');
    }, target: logger);

    expect(sink.events, hasLength(1));
    expect(sink.events.single.source, 'print');
    expect(sink.events.single.message, 'server started');
  });

  test('builds a last report from recent logger events', () {
    final logger = ailog.AiLogger(
      options: const ailog.Options(reportLevel: ailog.Level.warning),
    );

    logger.log(ailog.Level.info, 'loaded profile');
    logger.log(
      ailog.Level.error,
      'RenderFlex overflowed by 42px',
      kind: 'render_flex_overflow',
      file: 'lib/profile.dart',
      line: 31,
      probableCause: 'A Row child is wider than the available width.',
      suggestedFix: 'Wrap it with Expanded.',
    );

    final markdown = logger.formatLastReport(ailog.ReportFormat.markdown);

    expect(markdown, isNotNull);
    expect(markdown, contains('# Runtime Event'));
    expect(markdown, contains('Kind: render_flex_overflow'));
    expect(markdown, contains('# Suggested Fix'));
  });

  test('persists and reads JSONL events from a file sink', () {
    final directory = Directory.systemTemp.createTempSync('ai_logger_test_');
    addTearDown(() {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    final sink = ailog.FileJsonlSink('${directory.path}/events.jsonl');
    final logger = ailog.AiLogger(sinks: [sink]);

    logger.log(ailog.Level.warning, 'warning for AI report');
    logger.log(ailog.Level.error, 'error for AI report', kind: 'example_error');

    final events = sink.readEvents();

    expect(events, hasLength(2));
    expect(events.last.kind, 'example_error');
  });

  test('captures package:logging records', () async {
    final sink = ailog.MemorySink();
    final logger = ailog.AiLogger(
      options: const ailog.Options(captureLevel: ailog.Level.trace),
      sinks: [sink],
    );
    final subscription = ailog.captureLoggingPackage(target: logger);
    addTearDown(subscription.cancel);

    logging_pkg.Logger('example.service').warning(
      'from package logging',
      StateError('bad state'),
      StackTrace.current,
    );
    await Future<void>.delayed(Duration.zero);

    expect(sink.events, hasLength(1));
    expect(sink.events.single.level, ailog.Level.warning);
    expect(sink.events.single.source, 'package:logging:example.service');
    expect(sink.events.single.error, contains('bad state'));
  });

  test('captures package:logger output', () async {
    final sink = ailog.MemorySink();
    final logger = ailog.AiLogger(
      options: const ailog.Options(captureLevel: ailog.Level.trace),
      sinks: [sink],
    );
    final packageLogger = logger_pkg.Logger(
      output: ailog.AiLoggerOutput(target: logger),
      printer: logger_pkg.SimplePrinter(printTime: false, colors: false),
      level: logger_pkg.Level.trace,
    );

    packageLogger.e(
      'from package logger',
      error: StateError('logger error'),
      stackTrace: StackTrace.current,
    );
    await packageLogger.close();

    expect(sink.events, hasLength(1));
    expect(sink.events.single.level, ailog.Level.error);
    expect(sink.events.single.source, 'package:logger');
    expect(sink.events.single.message, 'from package logger');
  });

  test('parses dart analyze output and renders AI-friendly diagnostics', () {
    const analyzerOutput = '''
Analyzing demo...

  error - lib/main.dart:3:9 - Undefined name 'missingName'. Try correcting the name to one that is defined, or defining the name. - undefined_identifier
warning - lib/main.dart:2:9 - The value of the local variable 'unused' isn't used. Try removing the variable or using it. - unused_local_variable

2 issues found.
''';

    final issues = const ailog.StaticAnalysisParser().parse(analyzerOutput);
    final report = ailog.StaticAnalysisReport(issues);

    expect(issues, hasLength(2));
    expect(issues.first.severity, ailog.AnalysisSeverity.error);
    expect(issues.first.code, 'undefined_identifier');
    expect(issues.first.correction, startsWith('Try correcting'));

    final markdown = report.toMarkdown();
    expect(markdown, contains('# Static Analysis'));
    expect(markdown, contains('2 total, 1 error, 1 warning, 0 info'));
    expect(markdown, contains('Suggested fix: Try removing'));

    final diagnostic = report.toDiagnostic(
      sourceLoader: (_) => '''
void main() {
  final unused = 1;
  print(missingName);
}
''',
    );
    expect(diagnostic, contains('error[undefined_identifier]'));
    expect(diagnostic, contains('--> lib/main.dart:3:9'));
    expect(diagnostic, contains('^ undefined_identifier'));
    expect(diagnostic, contains('help: Try correcting'));
  });
}
