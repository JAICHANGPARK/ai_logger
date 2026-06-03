// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';

import 'package:ai_logger/ai_logger.dart' as ailog;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ailog.resetFlutterHooksForTesting();
    ailog.configure(sinks: const []);
    ailog.context.clear();
  });

  testWidgets('captures real Flutter runtime errors for benchmark', (
    tester,
  ) async {
    final cases = <RealFlutterCase>[
      await _captureCase(
        tester,
        name: 'real_render_flex_overflow',
        route: '/benchmark/flex',
        beforeTrigger: () {
          ailog.context.set('screen_width', 120);
          ailog.d('about to render a constrained Row');
        },
        trigger: _triggerRenderFlexOverflow,
      ),
      await _captureCase(
        tester,
        name: 'real_vertical_viewport_unbounded_height',
        route: '/benchmark/viewport',
        beforeTrigger: () {
          ailog.d('about to render a ListView inside Column');
        },
        trigger: _triggerUnboundedViewport,
      ),
      await _captureCase(
        tester,
        name: 'real_incorrect_parent_data_widget',
        route: '/benchmark/parent-data',
        beforeTrigger: () {
          ailog.d('about to render Expanded outside Flex');
        },
        trigger: _triggerIncorrectParentDataWidget,
      ),
    ];

    _writeArtifacts(cases);
  });
}

Future<RealFlutterCase> _captureCase(
  WidgetTester tester, {
  required String name,
  required String route,
  required void Function() beforeTrigger,
  required Future<void> Function(WidgetTester tester) trigger,
}) async {
  ailog.resetFlutterHooksForTesting();
  ailog.context.clear();
  final rawDetails = <FlutterErrorDetails>[];
  final rawDebugPrints = <String>[];

  final sink = ailog.MemorySink();
  ailog.installFlutterHooks(
    options: const ailog.Options(captureLevel: .debug, printReports: false),
    sinks: [sink],
  );
  final aiLoggerHook = FlutterError.onError;
  FlutterError.onError = (details) {
    rawDetails.add(details);
    aiLoggerHook?.call(details);
  };
  final aiLoggerDebugPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message != null) {
      rawDebugPrints.add(message);
    }
    aiLoggerDebugPrint(message, wrapWidth: wrapWidth);
  };
  ailog.context.setRoute(route);
  beforeTrigger();

  await trigger(tester);
  await tester.pump();
  while (tester.takeException() != null) {}

  ailog.resetFlutterHooksForTesting();

  if (rawDetails.isEmpty && rawDebugPrints.isEmpty) {
    fail('Expected $name to report a FlutterError or debugPrint diagnostic.');
  }
  final reportable = sink.events
      .where((event) => event.level == .error)
      .toList();
  if (reportable.isEmpty) {
    fail('Expected $name to be captured by ai_logger.');
  }

  final rawText = rawDetails.isNotEmpty
      ? _rawErrorText(rawDetails.first)
      : rawDebugPrints.join('\n');
  final event = reportable.first;
  final report = ailog.AiReport(
    event: event,
    recentSignals: sink.events
        .where((candidate) => !identical(candidate, event))
        .toList(),
  );
  final reports = {
    'markdown': report.toMarkdown(),
    'diagnostic': report.toDiagnostic(),
    'compactJson': report.toCompactJsonString(),
  };

  return RealFlutterCase(
    name: name,
    rawText: rawText,
    reports: reports,
    rawMetrics: TextMetrics.from(rawText),
    reportMetrics: {
      for (final entry in reports.entries)
        entry.key: TextMetrics.from(entry.value),
    },
  );
}

Future<void> _triggerRenderFlexOverflow(WidgetTester tester) async {
  await tester.pumpWidget(
    _fixtureRoot(
      const Center(
        child: SizedBox(
          width: 120,
          height: 80,
          child: Row(
            children: [
              SizedBox(width: 180, child: Text('Very long profile name')),
              SizedBox(width: 80, child: Text('Save')),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _triggerUnboundedViewport(WidgetTester tester) async {
  await tester.pumpWidget(
    _fixtureRoot(
      Column(
        children: [
          const Text('Feed'),
          ListView(children: const [Text('Item 1'), Text('Item 2')]),
        ],
      ),
    ),
  );
}

Future<void> _triggerIncorrectParentDataWidget(WidgetTester tester) async {
  await tester.pumpWidget(
    _fixtureRoot(
      const Padding(
        padding: EdgeInsets.all(8),
        child: Expanded(child: Text('Expanded must be under a Flex parent')),
      ),
    ),
  );
}

Widget _fixtureRoot(Widget child) {
  return Directionality(textDirection: TextDirection.ltr, child: child);
}

String _rawErrorText(FlutterErrorDetails details) {
  final buffer = StringBuffer()..write(details.toString().trimRight());
  final stack = details.stack;
  if (stack != null) {
    buffer
      ..writeln()
      ..writeln()
      ..writeln('Stack trace:')
      ..writeln(stack);
  }
  return buffer.toString().trimRight();
}

void _writeArtifacts(List<RealFlutterCase> cases) {
  final summary = BenchmarkSummary.from(cases);
  final jsonData = {
    'metadata': {
      'benchmark': 'real_flutter_errors',
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'caseCount': cases.length,
      'fixtureType': 'real Flutter widget-test runtime errors',
      'notes': [
        'Each case triggers an actual Flutter runtime error in flutter_test.',
        'Raw text comes from FlutterErrorDetails.toString() plus stack trace.',
        'ai_logger reports come from installFlutterHooks() capturing the same FlutterError.',
      ],
    },
    'summary': summary.toJson(),
    'cases': cases.map((benchmarkCase) => benchmarkCase.toJson()).toList(),
  };

  final jsonFile = File('../../docs/benchmarks/real_flutter_errors.json');
  jsonFile.parent.createSync(recursive: true);
  jsonFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(jsonData)}\n',
  );

  final markdownFile = File('../../docs/benchmarks/real_flutter_errors.md');
  markdownFile.writeAsStringSync(_renderMarkdown(summary, cases));

  final evidenceDirectory = Directory(
    '../../docs/benchmarks/real_flutter_errors',
  );
  if (evidenceDirectory.existsSync()) {
    for (final file in evidenceDirectory.listSync().whereType<File>()) {
      file.deleteSync();
    }
  }
  evidenceDirectory.createSync(recursive: true);
  for (final benchmarkCase in cases) {
    File(
      '${evidenceDirectory.path}/${benchmarkCase.name}.md',
    ).writeAsStringSync(_renderCaseEvidence(benchmarkCase));
  }
}

String _renderMarkdown(BenchmarkSummary summary, List<RealFlutterCase> cases) {
  final buffer = StringBuffer()
    ..writeln('# Real Flutter Runtime Error Benchmark')
    ..writeln()
    ..writeln(
      'Generated by `packages/ai_logger/benchmark/real_flutter_errors_test.dart`.',
    )
    ..writeln()
    ..writeln(
      'This benchmark triggers real Flutter widget-test runtime errors, captures '
      'the raw `FlutterErrorDetails` text, and compares it with reports emitted '
      'through `ai_logger.installFlutterHooks()` for the same failure.',
    )
    ..writeln()
    ..writeln('## Summary')
    ..writeln()
    ..writeln('```mermaid')
    ..writeln('xychart-beta')
    ..writeln('  title "Real Flutter Error Rough Tokens"')
    ..writeln('  x-axis ["Raw Flutter error", "ai_logger diagnostic"]')
    ..writeln('  y-axis "Average rough tokens" 0 --> 4600')
    ..writeln(
      '  bar [${summary.averageRawTokens.toStringAsFixed(1)}, '
      '${summary.averageDiagnosticTokens.toStringAsFixed(1)}]',
    )
    ..writeln('```')
    ..writeln()
    ..writeln('| Metric | Raw Flutter error | ai_logger diagnostic | Delta |')
    ..writeln('|---|---:|---:|---:|')
    ..writeln(
      '| Average rough tokens | ${summary.averageRawTokens.toStringAsFixed(1)} '
      '| ${summary.averageDiagnosticTokens.toStringAsFixed(1)} '
      '| ${_formatPercent(summary.averageDiagnosticTokenDeltaPercent)} |',
    )
    ..writeln(
      '| Framework-line mentions | ${summary.totalRawFrameworkMentions} '
      '| ${summary.totalDiagnosticFrameworkMentions} '
      '| ${summary.totalDiagnosticFrameworkMentions - summary.totalRawFrameworkMentions} |',
    )
    ..writeln(
      '| Average structured signal fields | '
      '${summary.averageRawStructuredSignals.toStringAsFixed(1)}/8 '
      '| ${summary.averageDiagnosticStructuredSignals.toStringAsFixed(1)}/8 '
      '| ${_signedNumber(summary.averageDiagnosticStructuredSignals - summary.averageRawStructuredSignals)} |',
    )
    ..writeln()
    ..writeln('## Case Results')
    ..writeln()
    ..writeln(
      '| Case | Evidence | Raw rough tokens | Diagnostic rough tokens | Diagnostic delta | Raw framework lines | Diagnostic framework lines |',
    )
    ..writeln('|---|---|---:|---:|---:|---:|---:|');

  for (final benchmarkCase in cases) {
    final diagnostic = benchmarkCase.reportMetrics['diagnostic']!;
    final delta = _percentDelta(
      benchmarkCase.rawMetrics.roughTokens,
      diagnostic.roughTokens,
    );
    buffer.writeln(
      '| ${benchmarkCase.name} '
      '| [raw/report](real_flutter_errors/${benchmarkCase.name}.md) '
      '| ${benchmarkCase.rawMetrics.roughTokens} '
      '| ${diagnostic.roughTokens} '
      '| ${_formatPercent(delta)} '
      '| ${benchmarkCase.rawMetrics.frameworkMentions} '
      '| ${diagnostic.frameworkMentions} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Notes')
    ..writeln()
    ..writeln(
      'This is closer to the production claim than the curated fixture benchmark '
      'because the Flutter errors are actually raised by widgets. It still runs '
      'inside `flutter_test`, so raw output can differ from a device console or '
      'IDE log pane.',
    )
    ..writeln()
    ..writeln(
      '`ai_logger` classification currently covers common framework error text. '
      'Errors that are not covered fall back to `flutter_error` and still get '
      'location, stack, route context, breadcrumbs, and recent signals when '
      'those are available.',
    );

  return buffer.toString();
}

String _renderCaseEvidence(RealFlutterCase benchmarkCase) {
  final diagnostic = benchmarkCase.reports['diagnostic']!;
  final markdown = benchmarkCase.reports['markdown']!;
  final compactJson = benchmarkCase.reports['compactJson']!;
  final diagnosticMetrics = benchmarkCase.reportMetrics['diagnostic']!;
  final delta = _percentDelta(
    benchmarkCase.rawMetrics.roughTokens,
    diagnosticMetrics.roughTokens,
  );

  final buffer = StringBuffer()
    ..writeln('# ${benchmarkCase.name}')
    ..writeln()
    ..writeln(
      'Evidence captured by `packages/ai_logger/benchmark/real_flutter_errors_test.dart`.',
    )
    ..writeln()
    ..writeln('| Metric | Raw Flutter Error | ai_logger Diagnostic |')
    ..writeln('|---|---:|---:|')
    ..writeln(
      '| Rough tokens | ${benchmarkCase.rawMetrics.roughTokens} '
      '| ${diagnosticMetrics.roughTokens} (${_formatPercent(delta)}) |',
    )
    ..writeln(
      '| Framework-line mentions | ${benchmarkCase.rawMetrics.frameworkMentions} '
      '| ${diagnosticMetrics.frameworkMentions} |',
    )
    ..writeln()
    ..writeln('## Raw FlutterErrorDetails')
    ..writeln()
    ..writeln('```text')
    ..writeln(_escapeCodeFence(benchmarkCase.rawText))
    ..writeln('```')
    ..writeln()
    ..writeln('## ai_logger Diagnostic')
    ..writeln()
    ..writeln('```text')
    ..writeln(_escapeCodeFence(diagnostic))
    ..writeln('```')
    ..writeln()
    ..writeln('## ai_logger Markdown Report')
    ..writeln()
    ..writeln('```markdown')
    ..writeln(_escapeCodeFence(markdown))
    ..writeln('```')
    ..writeln()
    ..writeln('## ai_logger Compact JSON')
    ..writeln()
    ..writeln('```json')
    ..writeln(_escapeCodeFence(compactJson))
    ..writeln('```');

  return buffer.toString();
}

class RealFlutterCase {
  const RealFlutterCase({
    required this.name,
    required this.rawText,
    required this.reports,
    required this.rawMetrics,
    required this.reportMetrics,
  });

  final String name;
  final String rawText;
  final Map<String, String> reports;
  final TextMetrics rawMetrics;
  final Map<String, TextMetrics> reportMetrics;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'raw': rawMetrics.toJson(),
      'aiLogger': reportMetrics['markdown']!.toJson(),
      'aiLoggerFormats': {
        for (final entry in reportMetrics.entries)
          entry.key: entry.value.toJson(),
      },
      'rawText': rawText,
      'aiLoggerReport': reports['markdown'],
      'aiLoggerReports': reports,
    };
  }
}

class BenchmarkSummary {
  const BenchmarkSummary({
    required this.averageRawTokens,
    required this.averageDiagnosticTokens,
    required this.averageDiagnosticTokenDeltaPercent,
    required this.totalRawFrameworkMentions,
    required this.totalDiagnosticFrameworkMentions,
    required this.averageRawStructuredSignals,
    required this.averageDiagnosticStructuredSignals,
  });

  factory BenchmarkSummary.from(List<RealFlutterCase> cases) {
    final rawTokens = _average(
      cases.map((entry) => entry.rawMetrics.roughTokens),
    );
    final diagnosticTokens = _average(
      cases.map((entry) => entry.reportMetrics['diagnostic']!.roughTokens),
    );
    return BenchmarkSummary(
      averageRawTokens: rawTokens,
      averageDiagnosticTokens: diagnosticTokens,
      averageDiagnosticTokenDeltaPercent: rawTokens == 0
          ? 0
          : ((diagnosticTokens - rawTokens) / rawTokens) * 100,
      totalRawFrameworkMentions: cases.fold(
        0,
        (total, entry) => total + entry.rawMetrics.frameworkMentions,
      ),
      totalDiagnosticFrameworkMentions: cases.fold(
        0,
        (total, entry) =>
            total + entry.reportMetrics['diagnostic']!.frameworkMentions,
      ),
      averageRawStructuredSignals: _average(
        cases.map((entry) => entry.rawMetrics.structuredSignals),
      ),
      averageDiagnosticStructuredSignals: _average(
        cases.map(
          (entry) => entry.reportMetrics['diagnostic']!.structuredSignals,
        ),
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'averageRawTokens': averageRawTokens,
      'averageDiagnosticTokens': averageDiagnosticTokens,
      'averageDiagnosticTokenDeltaPercent': averageDiagnosticTokenDeltaPercent,
      'totalRawFrameworkMentions': totalRawFrameworkMentions,
      'totalDiagnosticFrameworkMentions': totalDiagnosticFrameworkMentions,
      'averageRawStructuredSignals': averageRawStructuredSignals,
      'averageDiagnosticStructuredSignals': averageDiagnosticStructuredSignals,
    };
  }

  final double averageRawTokens;
  final double averageDiagnosticTokens;
  final double averageDiagnosticTokenDeltaPercent;
  final int totalRawFrameworkMentions;
  final int totalDiagnosticFrameworkMentions;
  final double averageRawStructuredSignals;
  final double averageDiagnosticStructuredSignals;
}

class TextMetrics {
  const TextMetrics({
    required this.characters,
    required this.roughTokens,
    required this.frameworkMentions,
    required this.appMentions,
    required this.structuredSignals,
  });

  factory TextMetrics.from(String text) {
    final hasKind =
        text.contains('Kind:') ||
        RegExp(
          r'^(error|warning|fatal)\[[a-z0-9_]+\]:',
          multiLine: true,
        ).hasMatch(text);
    final hasLocation =
        text.contains('Location:') ||
        text.contains('lib/') ||
        text.contains('package:ai_logger/');
    final hasProbableCause = text.contains('# Probable Cause');
    final hasSuggestedFix =
        text.contains('# Suggested Fix') || text.contains(' help: ');
    final hasRecentSignals = text.contains('# Recent Signals');
    final hasRouteContext = text.contains('route=');
    final hasFilteredAppFrames = text.contains('# App Frames');
    final hasDiagnosticPointer = RegExp(
      r'^\s*-->\s+',
      multiLine: true,
    ).hasMatch(text);

    return TextMetrics(
      characters: text.length,
      roughTokens: _roughTokenCount(text),
      frameworkMentions: _lineCount(
        text,
        (line) =>
            line.contains('package:flutter/') ||
            line.contains('dart:async') ||
            line.contains('package:flutter_test/'),
      ),
      appMentions: _lineCount(
        text,
        (line) =>
            line.contains('package:ai_logger/') ||
            line.contains('/packages/ai_logger/') ||
            line.contains('real_flutter_errors_test.dart') ||
            line.contains('lib/'),
      ),
      structuredSignals: [
        hasKind,
        hasLocation,
        hasProbableCause,
        hasSuggestedFix,
        hasRecentSignals,
        hasRouteContext,
        hasFilteredAppFrames,
        hasDiagnosticPointer,
      ].where((value) => value).length,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'characters': characters,
      'roughTokens': roughTokens,
      'frameworkMentions': frameworkMentions,
      'appMentions': appMentions,
      'structuredSignals': structuredSignals,
    };
  }

  final int characters;
  final int roughTokens;
  final int frameworkMentions;
  final int appMentions;
  final int structuredSignals;
}

int _roughTokenCount(String text) {
  return RegExp(r'[A-Za-z0-9_]+|[^\sA-Za-z0-9_]').allMatches(text).length;
}

int _lineCount(String text, bool Function(String line) predicate) {
  return text.split('\n').where(predicate).length;
}

double _average(Iterable<num> values) {
  final list = values.toList();
  if (list.isEmpty) {
    return 0;
  }
  return list.reduce((left, right) => left + right) / list.length;
}

double _percentDelta(num oldValue, num newValue) {
  if (oldValue == 0) {
    return 0;
  }
  return ((newValue - oldValue) / oldValue) * 100;
}

String _formatPercent(double value) {
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
}

String _signedNumber(double value) {
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}';
}

String _escapeCodeFence(String value) {
  return value.replaceAll('```', r'\`\`\`');
}
