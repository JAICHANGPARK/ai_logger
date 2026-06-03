import 'dart:convert';
import 'dart:io';

import 'package:ai_logger_core/ai_logger_core.dart' as ailog;

void main(List<String> args) {
  final markdownPath =
      _option(args, '--markdown') ??
      '../../docs/benchmarks/raw_vs_ai_report.md';
  final jsonPath =
      _option(args, '--json') ?? '../../docs/benchmarks/raw_vs_ai_report.json';

  final results = _benchmarkCases().map(_runBenchmark).toList();
  final summary = BenchmarkSummary.from(results);

  final markdown = _renderMarkdown(summary, results);
  final json = const JsonEncoder.withIndent('  ').convert({
    'metadata': {
      'benchmark': 'raw_vs_ai_report',
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'caseCount': results.length,
      'fixtureType': 'curated synthetic runtime-error fixtures',
      'notes': [
        'Reports are equivalent AiReport objects for each raw fixture.',
        'Structured-signal coverage measures field presence, not semantic correctness.',
        'Use a separate model-level benchmark for fix accuracy.',
      ],
    },
    'summary': summary.toJson(),
    'cases': results.map((result) => result.toJson()).toList(),
  });

  _writeFile(markdownPath, markdown);
  _writeFile(jsonPath, '$json\n');

  stdout
    ..writeln('raw_vs_ai_report benchmark')
    ..writeln('cases: ${results.length}')
    ..writeln(
      'average rough tokens: raw ${summary.averageRawTokens.toStringAsFixed(1)} '
      'vs ai_logger ${summary.averageReportTokens.toStringAsFixed(1)} '
      '(${_formatPercent(summary.averageTokenDeltaPercent)})',
    )
    ..writeln(
      'average structured signal fields: raw '
      '${summary.averageRawActionability.toStringAsFixed(1)}/8 '
      'vs ai_logger ${summary.averageReportActionability.toStringAsFixed(1)}/8',
    )
    ..writeln(
      'framework-line mentions: raw ${summary.totalRawFrameworkMentions} '
      'vs ai_logger ${summary.totalReportFrameworkMentions}',
    )
    ..writeln(
      'privacy leaks: raw ${summary.totalRawPrivacyLeaks} '
      'vs ai_logger ${summary.totalReportPrivacyLeaks}',
    )
    ..writeln('wrote $markdownPath')
    ..writeln('wrote $jsonPath');
}

String? _option(List<String> args, String name) {
  for (var index = 0; index < args.length; index += 1) {
    final arg = args[index];
    if (arg == name && index + 1 < args.length) {
      return args[index + 1];
    }
    if (arg.startsWith('$name=')) {
      return arg.substring(name.length + 1);
    }
  }
  return null;
}

void _writeFile(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}

BenchmarkResult _runBenchmark(BenchmarkCase benchmarkCase) {
  final sourceLoader = benchmarkCase.sourceFiles.isEmpty
      ? null
      : (String path) => benchmarkCase.sourceFiles[path];
  final reportTexts = {
    'markdown': benchmarkCase.report.toMarkdown(sourceLoader: sourceLoader),
    'diagnostic': benchmarkCase.report.toDiagnostic(sourceLoader: sourceLoader),
    'compactJson': benchmarkCase.report.toCompactJsonString(),
  };
  final markdownText = reportTexts['markdown']!;
  return BenchmarkResult(
    name: benchmarkCase.name,
    rawText: benchmarkCase.rawText,
    reportText: markdownText,
    reportTexts: reportTexts,
    raw: TextMetrics.from(benchmarkCase.rawText),
    report: TextMetrics.from(markdownText),
    reportMetrics: {
      for (final entry in reportTexts.entries)
        entry.key: TextMetrics.from(entry.value),
    },
  );
}

List<BenchmarkCase> _benchmarkCases() {
  final createdAt = DateTime(2026, 6, 2, 10);
  return [
    BenchmarkCase(
      name: 'render_flex_overflow',
      rawText: _renderFlexRaw,
      report: ailog.AiReport(
        event: ailog.LogEvent(
          timestamp: createdAt,
          level: .error,
          source: 'flutter',
          message: 'RenderFlex overflowed by 42 pixels on the right.',
          kind: 'render_flex_overflow',
          file: 'lib/features/profile/profile_header.dart',
          line: 31,
          column: 12,
          likelyWidget: 'Row or Column',
          probableCause:
              'A flex child is wider or taller than the available space.',
          suggestedFix:
              'Wrap the wide child with Expanded/Flexible or constrain it.',
          appFrames: const [
            ailog.StackFrame(
              member: 'ProfileHeader.build',
              uri: 'package:demo/features/profile/profile_header.dart',
              line: 31,
              column: 12,
            ),
            ailog.StackFrame(
              member: 'ProfilePage.build',
              uri: 'package:demo/features/profile/profile_page.dart',
              line: 18,
              column: 9,
            ),
          ],
        ),
        recentSignals: _recentSignals(
          createdAt,
          route: '/profile',
          messages: const [
            'loaded profile for user id 42',
            'screen_width=390 avatar_loaded=true',
          ],
        ),
      ),
      sourceFiles: {
        'lib/features/profile/profile_header.dart':
            _sourceWithTargetLine(31, const [
              'return Row(',
              '  children: [',
              '    Text(user.name),',
              '    IconButton(onPressed: save, icon: const Icon(Icons.save)),',
              '  ],',
              ');',
            ]),
      },
    ),
    BenchmarkCase(
      name: 'provider_not_found',
      rawText: _providerRaw,
      report: ailog.AiReport(
        event: ailog.LogEvent(
          timestamp: createdAt.add(const Duration(minutes: 1)),
          level: .error,
          source: 'flutter',
          message: 'Provider was not found for the requested type.',
          kind: 'provider_not_found',
          file: 'lib/features/settings/settings_page.dart',
          line: 22,
          column: 18,
          likelyWidget: 'Provider',
          probableCause: 'The lookup context is outside the Provider scope.',
          suggestedFix:
              'Move the Provider above the consumer or use the right context.',
          appFrames: const [
            ailog.StackFrame(
              member: 'SettingsPage.build',
              uri: 'package:demo/features/settings/settings_page.dart',
              line: 22,
              column: 18,
            ),
          ],
        ),
        recentSignals: _recentSignals(
          createdAt.add(const Duration(minutes: 1)),
          route: '/settings',
          messages: const [
            'opened settings screen',
            'selected workspace workspace_7',
          ],
        ),
      ),
      sourceFiles: {
        'lib/features/settings/settings_page.dart':
            _sourceWithTargetLine(22, const [
              'return Column(',
              '  children: [',
              '    Text(context.watch<SettingsStore>().themeName),',
              '  ],',
              ');',
            ]),
      },
    ),
    BenchmarkCase(
      name: 'set_state_after_dispose',
      rawText: _setStateRaw,
      report: ailog.AiReport(
        event: ailog.LogEvent(
          timestamp: createdAt.add(const Duration(minutes: 2)),
          level: .error,
          source: 'flutter',
          message: 'setState was called after dispose.',
          kind: 'set_state_after_dispose',
          file: 'lib/features/search/search_page.dart',
          line: 57,
          column: 9,
          probableCause:
              'An async callback updated a widget after it was disposed.',
          suggestedFix:
              'Cancel the callback or check mounted before calling setState.',
          appFrames: const [
            ailog.StackFrame(
              member: 'SearchPageState._loadResults',
              uri: 'package:demo/features/search/search_page.dart',
              line: 57,
              column: 9,
            ),
          ],
        ),
        recentSignals: _recentSignals(
          createdAt.add(const Duration(minutes: 2)),
          route: '/search',
          messages: const [
            'query changed to "river"',
            'route changed to /home before search completed',
          ],
        ),
      ),
      sourceFiles: {
        'lib/features/search/search_page.dart':
            _sourceWithTargetLine(57, const [
              'final results = await repository.search(query);',
              '// Update the screen after the asynchronous search finishes.',
              'setState(() {',
              '  _results = results;',
              '});',
            ]),
      },
    ),
    BenchmarkCase(
      name: 'unbounded_viewport',
      rawText: _viewportRaw,
      report: ailog.AiReport(
        event: ailog.LogEvent(
          timestamp: createdAt.add(const Duration(minutes: 3)),
          level: .error,
          source: 'flutter',
          message: 'Vertical viewport received an unbounded height.',
          kind: 'vertical_viewport_unbounded_height',
          file: 'lib/features/feed/feed_page.dart',
          line: 44,
          column: 7,
          likelyWidget: 'ListView or GridView',
          probableCause:
              'A scrollable is placed in a parent that does not bound height.',
          suggestedFix:
              'Give the scrollable a bounded height or use shrinkWrap carefully.',
          appFrames: const [
            ailog.StackFrame(
              member: 'FeedPage.build',
              uri: 'package:demo/features/feed/feed_page.dart',
              line: 44,
              column: 7,
            ),
          ],
        ),
        recentSignals: _recentSignals(
          createdAt.add(const Duration(minutes: 3)),
          route: '/feed',
          messages: const ['loaded 20 feed items', 'layout mode compact=false'],
        ),
      ),
      sourceFiles: {
        'lib/features/feed/feed_page.dart': _sourceWithTargetLine(44, const [
          'return Column(',
          '  children: [',
          '    ListView.builder(',
          '      itemCount: items.length,',
          '      itemBuilder: _buildItem,',
          '    ),',
          '  ],',
          ');',
        ]),
      },
    ),
    _networkCase(createdAt.add(const Duration(minutes: 4))),
  ];
}

BenchmarkCase _networkCase(DateTime createdAt) {
  final rawStack = r'''
#0      ApiClient.fetchProfile (package:demo/api/client.dart:48:18)
#1      ProfileRepository.load (package:demo/features/profile/repository.dart:19:12)
#2      ProfileController.refresh (package:demo/features/profile/controller.dart:33:7)
#3      Future._propagateToListeners.handleValueCallback (dart:async/future_impl.dart:948:45)
#4      Future._propagateToListeners (dart:async/future_impl.dart:977:13)
''';
  final rawText = '''
Unhandled exception:
StateError: request failed for email=dev@example.com token=abc123
GET https://api.example.test/profile?email=dev@example.com
Authorization: Bearer sk-demo-secret-123
$rawStack''';

  final logger = ailog.AiLogger(
    options: const ailog.Options(captureLevel: .debug, printReports: false),
  );
  logger.context
    ..setRoute('/profile')
    ..set('account_email', 'dev@example.com');
  logger.log(.info, 'loaded cached profile for dev@example.com');
  logger.log(.debug, 'GET /profile token=abc123');
  final event = logger.log(
    .error,
    'Request failed for email=dev@example.com token=abc123.',
    error: StateError('Authorization: Bearer sk-demo-secret-123'),
    stackTrace: StackTrace.fromString(rawStack),
    source: 'app',
    kind: 'network_error',
    file: 'lib/api/client.dart',
    line: 48,
    column: 18,
    probableCause: 'The profile request failed before a response was parsed.',
    suggestedFix: 'Check the endpoint, authentication state, and retry policy.',
    appFrames: const [
      ailog.StackFrame(
        member: 'ApiClient.fetchProfile',
        uri: 'package:demo/api/client.dart',
        line: 48,
        column: 18,
      ),
      ailog.StackFrame(
        member: 'ProfileRepository.load',
        uri: 'package:demo/features/profile/repository.dart',
        line: 19,
        column: 12,
      ),
    ],
  );

  return BenchmarkCase(
    name: 'network_error_with_sensitive_values',
    rawText: rawText,
    report: logger.buildReport(event: event)!,
    sourceFiles: {
      'lib/api/client.dart': _sourceWithTargetLine(48, const [
        'final response = await client.get(',
        '  profileUri,',
        '  headers: authHeaders,',
        ');',
      ]),
    },
  );
}

List<ailog.LogEvent> _recentSignals(
  DateTime baseTime, {
  required String route,
  required List<String> messages,
}) {
  return [
    for (var index = 0; index < messages.length; index += 1)
      ailog.LogEvent(
        timestamp: baseTime.subtract(
          Duration(seconds: messages.length - index),
        ),
        level: index == 0 ? .info : .debug,
        message: messages[index],
        context: {'route': route},
      ),
  ];
}

String _sourceWithTargetLine(int targetLine, List<String> targetBlock) {
  final fillerCount = targetLine - 3;
  final lines = [
    for (var index = 1; index <= fillerCount; index += 1) '// filler $index',
    ...targetBlock,
  ];
  return lines.join('\n');
}

class BenchmarkCase {
  const BenchmarkCase({
    required this.name,
    required this.rawText,
    required this.report,
    this.sourceFiles = const {},
  });

  final String name;
  final String rawText;
  final ailog.AiReport report;
  final Map<String, String> sourceFiles;
}

class BenchmarkResult {
  const BenchmarkResult({
    required this.name,
    required this.rawText,
    required this.reportText,
    required this.reportTexts,
    required this.raw,
    required this.report,
    required this.reportMetrics,
  });

  final String name;
  final String rawText;
  final String reportText;
  final Map<String, String> reportTexts;
  final TextMetrics raw;
  final TextMetrics report;
  final Map<String, TextMetrics> reportMetrics;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'raw': raw.toJson(),
      'aiLogger': report.toJson(),
      'aiLoggerFormats': {
        for (final entry in reportMetrics.entries)
          entry.key: entry.value.toJson(),
      },
      'rawText': rawText,
      'aiLoggerReport': reportText,
      'aiLoggerReports': reportTexts,
    };
  }
}

class TextMetrics {
  const TextMetrics({
    required this.characters,
    required this.roughTokens,
    required this.stackFrameLines,
    required this.frameworkMentions,
    required this.appMentions,
    required this.actionabilityScore,
    required this.privacyLeaks,
    required this.hasKind,
    required this.hasLocation,
    required this.hasProbableCause,
    required this.hasSuggestedFix,
    required this.hasRecentSignals,
    required this.hasRouteContext,
    required this.hasFilteredAppFrames,
    required this.hasDiagnosticPointer,
  });

  factory TextMetrics.from(String text) {
    final hasKind =
        text.contains('Kind:') ||
        text.contains('"kind"') ||
        RegExp(
          r'^(error|warning|fatal)\[[a-z0-9_]+\]:',
          multiLine: true,
        ).hasMatch(text);
    final hasLocation =
        text.contains('Location:') ||
        text.contains('lib/') ||
        text.contains('package:demo/') ||
        text.contains('file:///');
    final hasProbableCause =
        text.contains('# Probable Cause') || text.contains('probableCause');
    final hasSuggestedFix =
        text.contains('# Suggested Fix') ||
        text.contains('suggestedFix') ||
        text.contains(' help: ');
    final hasRecentSignals =
        text.contains('# Recent Signals') || text.contains('recentSignals');
    final hasRouteContext = text.contains('route=') || text.contains('"route"');
    final hasFilteredAppFrames =
        text.contains('# App Frames') || text.contains('"appFrames"');
    final hasDiagnosticPointer =
        text.contains('# Diagnostic') ||
        RegExp(r'^\s*-->\s+', multiLine: true).hasMatch(text);

    final actionabilityScore = [
      hasKind,
      hasLocation,
      hasProbableCause,
      hasSuggestedFix,
      hasRecentSignals,
      hasRouteContext,
      hasFilteredAppFrames,
      hasDiagnosticPointer,
    ].where((value) => value).length;

    return TextMetrics(
      characters: text.length,
      roughTokens: _roughTokenCount(text),
      stackFrameLines: RegExp(
        r'^\s*#\d+\s+',
        multiLine: true,
      ).allMatches(text).length,
      frameworkMentions: _lineCount(
        text,
        (line) =>
            line.contains('package:flutter/') ||
            line.contains('package:provider/') ||
            line.contains('dart:async') ||
            line.contains('dart:ui') ||
            line.contains('package:flutter_test/'),
      ),
      appMentions: _lineCount(
        text,
        (line) =>
            line.contains('package:demo/') ||
            line.contains('file:///') ||
            line.contains('lib/'),
      ),
      actionabilityScore: actionabilityScore,
      privacyLeaks: _privacyLeakCount(text),
      hasKind: hasKind,
      hasLocation: hasLocation,
      hasProbableCause: hasProbableCause,
      hasSuggestedFix: hasSuggestedFix,
      hasRecentSignals: hasRecentSignals,
      hasRouteContext: hasRouteContext,
      hasFilteredAppFrames: hasFilteredAppFrames,
      hasDiagnosticPointer: hasDiagnosticPointer,
    );
  }

  double get appFrameFocus {
    final relevantMentions = appMentions + frameworkMentions;
    if (relevantMentions == 0) {
      return 0;
    }
    return appMentions / relevantMentions;
  }

  Map<String, Object?> toJson() {
    return {
      'characters': characters,
      'roughTokens': roughTokens,
      'stackFrameLines': stackFrameLines,
      'frameworkMentions': frameworkMentions,
      'appMentions': appMentions,
      'appFrameFocus': appFrameFocus,
      'actionabilityScore': actionabilityScore,
      'privacyLeaks': privacyLeaks,
      'fields': {
        'kind': hasKind,
        'location': hasLocation,
        'probableCause': hasProbableCause,
        'suggestedFix': hasSuggestedFix,
        'recentSignals': hasRecentSignals,
        'routeContext': hasRouteContext,
        'filteredAppFrames': hasFilteredAppFrames,
        'diagnosticPointer': hasDiagnosticPointer,
      },
    };
  }

  final int characters;
  final int roughTokens;
  final int stackFrameLines;
  final int frameworkMentions;
  final int appMentions;
  final int actionabilityScore;
  final int privacyLeaks;
  final bool hasKind;
  final bool hasLocation;
  final bool hasProbableCause;
  final bool hasSuggestedFix;
  final bool hasRecentSignals;
  final bool hasRouteContext;
  final bool hasFilteredAppFrames;
  final bool hasDiagnosticPointer;
}

class BenchmarkSummary {
  const BenchmarkSummary({
    required this.caseCount,
    required this.averageRawTokens,
    required this.averageReportTokens,
    required this.averageTokenDeltaPercent,
    required this.averageRawActionability,
    required this.averageReportActionability,
    required this.averageRawAppFrameFocus,
    required this.averageReportAppFrameFocus,
    required this.totalRawFrameworkMentions,
    required this.totalReportFrameworkMentions,
    required this.totalRawPrivacyLeaks,
    required this.totalReportPrivacyLeaks,
  });

  factory BenchmarkSummary.from(List<BenchmarkResult> results) {
    final caseCount = results.length;
    final rawTokens = _average(results.map((result) => result.raw.roughTokens));
    final reportTokens = _average(
      results.map((result) => result.report.roughTokens),
    );

    return BenchmarkSummary(
      caseCount: caseCount,
      averageRawTokens: rawTokens,
      averageReportTokens: reportTokens,
      averageTokenDeltaPercent: rawTokens == 0
          ? 0
          : ((reportTokens - rawTokens) / rawTokens) * 100,
      averageRawActionability: _average(
        results.map((result) => result.raw.actionabilityScore),
      ),
      averageReportActionability: _average(
        results.map((result) => result.report.actionabilityScore),
      ),
      averageRawAppFrameFocus: _average(
        results.map((result) => result.raw.appFrameFocus),
      ),
      averageReportAppFrameFocus: _average(
        results.map((result) => result.report.appFrameFocus),
      ),
      totalRawFrameworkMentions: results.fold(
        0,
        (total, result) => total + result.raw.frameworkMentions,
      ),
      totalReportFrameworkMentions: results.fold(
        0,
        (total, result) => total + result.report.frameworkMentions,
      ),
      totalRawPrivacyLeaks: results.fold(
        0,
        (total, result) => total + result.raw.privacyLeaks,
      ),
      totalReportPrivacyLeaks: results.fold(
        0,
        (total, result) => total + result.report.privacyLeaks,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'caseCount': caseCount,
      'averageRawTokens': averageRawTokens,
      'averageReportTokens': averageReportTokens,
      'averageTokenDeltaPercent': averageTokenDeltaPercent,
      'averageRawActionability': averageRawActionability,
      'averageReportActionability': averageReportActionability,
      'averageRawAppFrameFocus': averageRawAppFrameFocus,
      'averageReportAppFrameFocus': averageReportAppFrameFocus,
      'totalRawFrameworkMentions': totalRawFrameworkMentions,
      'totalReportFrameworkMentions': totalReportFrameworkMentions,
      'totalRawPrivacyLeaks': totalRawPrivacyLeaks,
      'totalReportPrivacyLeaks': totalReportPrivacyLeaks,
    };
  }

  final int caseCount;
  final double averageRawTokens;
  final double averageReportTokens;
  final double averageTokenDeltaPercent;
  final double averageRawActionability;
  final double averageReportActionability;
  final double averageRawAppFrameFocus;
  final double averageReportAppFrameFocus;
  final int totalRawFrameworkMentions;
  final int totalReportFrameworkMentions;
  final int totalRawPrivacyLeaks;
  final int totalReportPrivacyLeaks;
}

String _renderMarkdown(
  BenchmarkSummary summary,
  List<BenchmarkResult> results,
) {
  final buffer = StringBuffer()
    ..writeln('# Raw Runtime Error vs ai_logger Report Benchmark')
    ..writeln()
    ..writeln('Generated by `benchmark/raw_vs_ai_report.dart`.')
    ..writeln()
    ..writeln('## Scope')
    ..writeln()
    ..writeln(
      'This deterministic benchmark compares curated raw runtime-error '
      'fixtures with equivalent `ai_logger` Markdown reports.',
    )
    ..writeln()
    ..writeln(
      'It measures prompt-quality signals before an LLM call: rough token '
      'count, framework stack noise, app-frame focus, structured signal '
      'coverage, and obvious privacy leaks. Structured-signal coverage is a '
      'field-presence check, not a semantic correctness score. It does not '
      'claim model fix accuracy; use the saved raw/report pairs for a separate '
      'LLM evaluation.',
    )
    ..writeln()
    ..writeln(
      'For real tokenizer counts, run '
      '`uv run --with tiktoken python benchmark/openai_token_counts.py`.',
    )
    ..writeln()
    ..writeln('## Summary')
    ..writeln()
    ..writeln('| Metric | Raw runtime paste | ai_logger report | Delta |')
    ..writeln('|---|---:|---:|---:|')
    ..writeln(
      '| Average rough tokens | ${summary.averageRawTokens.toStringAsFixed(1)} '
      '| ${summary.averageReportTokens.toStringAsFixed(1)} '
      '| ${_formatPercent(summary.averageTokenDeltaPercent)} |',
    )
    ..writeln(
      '| Average structured signal fields | '
      '${summary.averageRawActionability.toStringAsFixed(1)}/8 '
      '| ${summary.averageReportActionability.toStringAsFixed(1)}/8 '
      '| ${_signedNumber(summary.averageReportActionability - summary.averageRawActionability)} |',
    )
    ..writeln(
      '| Average app-frame focus | '
      '${_formatRatio(summary.averageRawAppFrameFocus)} '
      '| ${_formatRatio(summary.averageReportAppFrameFocus)} '
      '| ${_signedPercent(summary.averageReportAppFrameFocus - summary.averageRawAppFrameFocus)} |',
    )
    ..writeln(
      '| Framework-line mentions | ${summary.totalRawFrameworkMentions} '
      '| ${summary.totalReportFrameworkMentions} '
      '| ${summary.totalReportFrameworkMentions - summary.totalRawFrameworkMentions} |',
    )
    ..writeln(
      '| Privacy leak matches | ${summary.totalRawPrivacyLeaks} '
      '| ${summary.totalReportPrivacyLeaks} '
      '| ${summary.totalReportPrivacyLeaks - summary.totalRawPrivacyLeaks} |',
    )
    ..writeln()
    ..writeln('## Case Results')
    ..writeln()
    ..writeln(
      '| Case | Raw tokens | ai_logger tokens | Token delta | Raw score | ai_logger score | Raw framework lines | ai_logger framework lines |',
    )
    ..writeln('|---|---:|---:|---:|---:|---:|---:|---:|');

  for (final result in results) {
    final tokenDelta = result.raw.roughTokens == 0
        ? 0.0
        : ((result.report.roughTokens - result.raw.roughTokens) /
                  result.raw.roughTokens) *
              100;
    buffer.writeln(
      '| ${result.name} '
      '| ${result.raw.roughTokens} '
      '| ${result.report.roughTokens} '
      '| ${_formatPercent(tokenDelta)} '
      '| ${result.raw.actionabilityScore}/8 '
      '| ${result.report.actionabilityScore}/8 '
      '| ${result.raw.frameworkMentions} '
      '| ${result.report.frameworkMentions} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Field Definitions')
    ..writeln()
    ..writeln(
      'Structured signal fields are: stable kind, primary location, probable cause, '
      'suggested fix, recent signals, route context, filtered app frames, and '
      'diagnostic pointer/source help.',
    )
    ..writeln()
    ..writeln(
      'This is a structural coverage metric. It does not prove that a cause or '
      'fix is semantically correct, nor does it give raw console prose credit '
      'for equivalent natural-language hints.',
    )
    ..writeln()
    ..writeln(
      'Rough tokens use a simple lexical tokenizer. Treat the number as a '
      'stable local proxy, not an exact model tokenizer count.',
    )
    ..writeln()
    ..writeln('## Next Step For LLM Accuracy')
    ..writeln()
    ..writeln(
      'For model-level benchmarking, feed each `rawText` and `aiLoggerReport` '
      'from `raw_vs_ai_report.json` into the same LLM prompt, apply the '
      'suggested patch to a fixture app, and score first-pass test success, '
      'correct file/line, and conversation turns to fix.',
    );

  return buffer.toString();
}

int _roughTokenCount(String text) {
  return RegExp(r'[A-Za-z0-9_]+|[^\sA-Za-z0-9_]').allMatches(text).length;
}

int _lineCount(String text, bool Function(String line) predicate) {
  return text.split('\n').where(predicate).length;
}

int _privacyLeakCount(String text) {
  final patterns = [
    RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}'),
    RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
    RegExp(
      r'(api[_-]?key|token|password|secret)\s*[:=]\s*[^\s,&}]+',
      caseSensitive: false,
    ),
  ];
  return patterns.fold(
    0,
    (total, pattern) => total + pattern.allMatches(text).length,
  );
}

double _average(Iterable<num> values) {
  final list = values.toList();
  if (list.isEmpty) {
    return 0;
  }
  return list.reduce((left, right) => left + right) / list.length;
}

String _formatPercent(double value) {
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
}

String _signedPercent(double value) {
  return '${value >= 0 ? '+' : ''}${(value * 100).toStringAsFixed(1)}pp';
}

String _signedNumber(double value) {
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}';
}

String _formatRatio(double value) {
  return '${(value * 100).toStringAsFixed(1)}%';
}

const _renderFlexRaw = r'''
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞════════════════════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 42 pixels on the right.

The relevant error-causing widget was:
  Row
  Row:file:///Users/dev/demo/lib/features/profile/profile_header.dart:31:12

When the exception was thrown, this was the stack:
#0      RenderFlex.performLayout (package:flutter/src/rendering/flex.dart:1250:9)
#1      RenderObject.layout (package:flutter/src/rendering/object.dart:2762:7)
#2      ProxyBoxMixin.performLayout (package:flutter/src/rendering/proxy_box.dart:115:18)
#3      RenderObject.layout (package:flutter/src/rendering/object.dart:2762:7)
#4      ProfileHeader.build (package:demo/features/profile/profile_header.dart:31:12)
#5      ProfilePage.build (package:demo/features/profile/profile_page.dart:18:9)
#6      StatelessElement.build (package:flutter/src/widgets/framework.dart:5791:49)
#7      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5723:15)
#8      Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#9      BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3046:19)
''';

const _providerRaw = r'''
ProviderNotFoundException: Error: Could not find the correct Provider<SettingsStore> above this SettingsPage Widget

This happens because you used a BuildContext that does not include the provider
of your choice. There are a few common scenarios:

- You added a new provider in your main.dart and performed a hot-reload.
- The provider you are trying to read is in a different route.
- You used a BuildContext that is an ancestor of the provider.

The relevant error-causing widget was:
  SettingsPage SettingsPage:file:///Users/dev/demo/lib/features/settings/settings_page.dart:22:18

#0      Provider._inheritedElementOf (package:provider/src/provider.dart:343:7)
#1      Provider.of (package:provider/src/provider.dart:293:30)
#2      WatchContext.watch (package:provider/src/provider.dart:693:21)
#3      SettingsPage.build (package:demo/features/settings/settings_page.dart:22:18)
#4      StatelessElement.build (package:flutter/src/widgets/framework.dart:5791:49)
#5      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5723:15)
#6      Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
''';

const _setStateRaw = r'''
FlutterError: setState() called after dispose(): SearchPageState#43a9f(lifecycle state: defunct, not mounted)
This error happens if you call setState() on a State object for a widget that
no longer appears in the widget tree.

The preferred solution is to cancel the timer or stop listening to the callback.

#0      State.setState.<anonymous closure> (package:flutter/src/widgets/framework.dart:1163:9)
#1      State.setState (package:flutter/src/widgets/framework.dart:1198:6)
#2      SearchPageState._loadResults (package:demo/features/search/search_page.dart:57:9)
#3      _rootRunUnary (dart:async/zone.dart:1538:47)
#4      _CustomZone.runUnary (dart:async/zone.dart:1429:19)
#5      Future._propagateToListeners.handleValueCallback (dart:async/future_impl.dart:948:45)
#6      Future._propagateToListeners (dart:async/future_impl.dart:977:13)
#7      Future._completeWithValue (dart:async/future_impl.dart:720:5)
''';

const _viewportRaw = r'''
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞════════════════════════════════════
The following assertion was thrown during layout:
Vertical viewport was given unbounded height.

Viewports expand in the scrolling direction to fill their container. In this
case, a vertical viewport was given an unlimited amount of vertical space in
which to expand.

The relevant error-causing widget was:
  ListView ListView:file:///Users/dev/demo/lib/features/feed/feed_page.dart:44:7

#0      RenderViewport.computeDryLayout (package:flutter/src/rendering/viewport.dart:1543:15)
#1      RenderBox.performResize (package:flutter/src/rendering/box.dart:2870:12)
#2      RenderObject.layout (package:flutter/src/rendering/object.dart:2741:9)
#3      RenderProxyBoxMixin.performLayout (package:flutter/src/rendering/proxy_box.dart:115:18)
#4      RenderObject.layout (package:flutter/src/rendering/object.dart:2762:7)
#5      FeedPage.build (package:demo/features/feed/feed_page.dart:44:7)
#6      StatelessElement.build (package:flutter/src/widgets/framework.dart:5791:49)
#7      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5723:15)
''';
