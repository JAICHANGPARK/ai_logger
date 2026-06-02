import 'dart:async';

import 'package:ai_logger/ai_logger.dart' as ailog;
import 'package:ai_logger/src/flutter_hooks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    resetFlutterHooksForTesting();
    ailog.configure(sinks: const []);
  });

  test('re-exports core API', () {
    expect(ailog.Level.error.code, 'E');
    expect(ailog.Options().reportLevel, ailog.Level.warning);
    expect(ailog.Options().recentSignalLevels, isNull);
    expect(ailog.Options().printReports, isTrue);
    expect(ailog.Options().reportFormat, ailog.ReportFormat.diagnostic);
  });

  test('classifies representative Flutter errors', () {
    final overflow = ailog.classifyFlutterError(
      FlutterError('RenderFlex overflowed by 42 pixels on the right.'),
    );
    final setState = ailog.classifyFlutterError(
      FlutterError('setState() called after dispose(): ExampleState'),
    );

    expect(overflow.kind, 'render_flex_overflow');
    expect(overflow.summary, contains('42 pixels'));
    expect(overflow.suggestedFix, contains('Expanded'));
    expect(setState.kind, 'set_state_after_dispose');
  });

  test('FlutterError hook logs and preserves the previous handler', () {
    final sink = ailog.MemorySink();
    var previousCalled = false;
    final original = FlutterError.onError;
    addTearDown(() {
      FlutterError.onError = original;
    });
    FlutterError.onError = (_) {
      previousCalled = true;
    };

    ailog.installFlutterHooks(
      options: const ailog.Options(captureLevel: .debug, printReports: false),
      sinks: [sink],
    );
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: FlutterError('RenderFlex overflowed by 42 pixels.'),
        stack: StackTrace.fromString(
          '#0      Header.build (package:demo/header.dart:10:3)',
        ),
      ),
    );

    expect(previousCalled, isTrue);
    expect(sink.events, hasLength(1));
    expect(sink.events.single.kind, 'render_flex_overflow');
    expect(sink.events.single.file, 'lib/header.dart');
  });

  test('debugPrint hook records debug logs', () {
    final sink = ailog.MemorySink();

    ailog.installFlutterHooks(
      options: const ailog.Options(captureLevel: .debug, printReports: false),
      sinks: [sink],
    );
    debugPrint('loaded user profile');

    expect(sink.events, hasLength(1));
    expect(sink.events.single.level, ailog.Level.debug);
    expect(sink.events.single.source, 'debugPrint');
  });

  test('runGuarded captures print logs in the app zone', () {
    final sink = ailog.MemorySink();

    runZoned(() {
      ailog.runGuarded<void>(
        () {
          print('zone print from app');
        },
        options: const ailog.Options(captureLevel: .debug, printReports: false),
        sinks: [sink],
      );
    }, zoneSpecification: ZoneSpecification(print: (_, __, ___, _) {}));

    expect(sink.events, hasLength(1));
    expect(sink.events.single.level, ailog.Level.info);
    expect(sink.events.single.source, 'print');
    expect(sink.events.single.message, 'zone print from app');
  });
}
