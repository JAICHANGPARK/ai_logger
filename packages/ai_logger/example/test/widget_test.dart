import 'package:ai_logger/ai_logger.dart' as ailog;
import 'package:ai_logger_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    memorySink.clear();
    ailog.configure(
      options: const ailog.Options(captureLevel: .trace, printReports: false),
      sinks: [memorySink],
    );
  });

  tearDown(() {
    ailog.resetFlutterHooksForTesting();
  });

  testWidgets('shows captured manual logs', (tester) async {
    await tester.pumpWidget(const AiLoggerExampleApp());

    expect(find.text('No captured events yet.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'ailog.i'));
    await tester.pump();

    expect(find.textContaining('[I] manual info log'), findsOneWidget);
  });

  testWidgets('shows captured debugPrint logs', (tester) async {
    ailog.installFlutterHooks(
      options: const ailog.Options(captureLevel: .trace, printReports: false),
      sinks: [memorySink],
    );
    await tester.pumpWidget(const AiLoggerExampleApp());

    await tester.tap(find.widgetWithText(FilledButton, 'debugPrint'));
    await tester.pump();

    expect(find.textContaining('[D] debugPrint() log'), findsOneWidget);
    ailog.resetFlutterHooksForTesting();
  });

  testWidgets('shows copyable AI report for a Flutter error', (tester) async {
    await tester.pumpWidget(const AiLoggerExampleApp());

    ailog.logClassifiedFlutterError(
      FlutterError('RenderFlex overflowed by 42 pixels.'),
      stackTrace: StackTrace.fromString(
        '#0      LogConsolePage.build '
        '(package:ai_logger_example/main.dart:88:12)',
      ),
    );
    expect(memorySink.events.last.kind, 'render_flex_overflow');
    expect(ailog.formatLastReport(.markdown), contains('# Flutter Error'));

    await tester.tap(find.text('copy AI report'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            (widget.data?.contains('# Flutter Error') ?? false) &&
            (widget.data?.contains('Kind: render_flex_overflow') ?? false) &&
            (widget.data?.contains('# Suggested Fix') ?? false) &&
            (widget.data?.contains('# Diagnostic') ?? false),
      ),
      findsOneWidget,
    );
  });

  testWidgets('copies diagnostic and JSON report formats', (tester) async {
    await tester.pumpWidget(const AiLoggerExampleApp());

    ailog.logClassifiedFlutterError(
      FlutterError('RenderFlex overflowed by 42 pixels.'),
      stackTrace: StackTrace.fromString(
        '#0      LogConsolePage.build '
        '(package:ai_logger_example/main.dart:88:12)',
      ),
    );

    await tester.tap(find.text('Diagnostic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('copy AI report'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            (widget.data?.contains('error[render_flex_overflow]') ?? false),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('copy AI report'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            (widget.data?.contains('"kind": "render_flex_overflow"') ?? false),
      ),
      findsOneWidget,
    );
  });
}
