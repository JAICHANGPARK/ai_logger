import 'package:ai_logger/ai_logger.dart' as ailog;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final memorySink = ailog.MemorySink();
final routeObserver = ailog.AiLoggerRouteObserver();

void main() {
  ailog.runApp(
    const AiLoggerExampleApp(),
    options: const ailog.Options(captureLevel: .trace),
    sinks: [memorySink],
  );
}

class AiLoggerExampleApp extends StatelessWidget {
  const AiLoggerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ai_logger example',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LogConsolePage(),
    );
  }
}

class LogConsolePage extends StatefulWidget {
  const LogConsolePage({super.key});

  @override
  State<LogConsolePage> createState() => _LogConsolePageState();
}

class _LogConsolePageState extends State<LogConsolePage> {
  String? _aiReport;
  ailog.ReportFormat _reportFormat = .markdown;

  void _refresh() {
    setState(() {});
  }

  void _logInfo() {
    ailog.context.setRoute('/example');
    ailog.breadcrumb('tap_manual_log');
    ailog.i('manual info log from example');
    _refresh();
  }

  void _logWarning() {
    ailog.breadcrumb('tap_manual_warning');
    ailog.logger.log(
      .warning,
      'manual warning log from example',
      kind: 'manual_warning',
      probableCause: 'The example intentionally emitted a warning event.',
      suggestedFix:
          'Inspect the recent signals and decide if action is needed.',
    );
    _refresh();
  }

  void _logPrint() {
    print('print() log from example button');
    _refresh();
  }

  void _logDebugPrint() {
    debugPrint('debugPrint() log from example button');
    _refresh();
  }

  void _reportFlutterError() {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: FlutterError('RenderFlex overflowed by 42 pixels.'),
        stack: StackTrace.fromString(
          '#0      LogConsolePage.build '
          '(package:ai_logger_example/main.dart:88:12)',
        ),
      ),
    );
    _refresh();
  }

  void _logWebRuntimeError() {
    ailog.logClassifiedWebRuntimeError(
      'Failed to fetch',
      file: 'main.dart.js',
      line: 123,
      column: 45,
      source: 'web:onerror',
    );
    _refresh();
  }

  void _throwAsyncError() {
    Future<void>.delayed(Duration.zero, () {
      throw StateError('async failure captured by ai_logger');
    });
    Future<void>.delayed(const Duration(milliseconds: 50), _refresh);
  }

  void _clear() {
    memorySink.clear();
    _aiReport = null;
    _refresh();
  }

  Future<void> _copyAiReport() async {
    final report = ailog.formatLastReport(_reportFormat);
    final text =
        report ?? 'No warning, error, or fatal event has been captured yet.';
    setState(() {
      _aiReport = text;
    });
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } on PlatformException {
      ailog.w('Clipboard.setData failed in ai_logger example');
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AI report copied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = memorySink.events.reversed.toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ai_logger runtime capture'),
        actions: [
          IconButton(
            tooltip: 'Clear captured events',
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: _logInfo, child: const Text('ailog.i')),
                FilledButton.tonal(
                  onPressed: _logWarning,
                  child: const Text('warning'),
                ),
                FilledButton.tonal(
                  onPressed: _logPrint,
                  child: const Text('print'),
                ),
                FilledButton.tonal(
                  onPressed: _logDebugPrint,
                  child: const Text('debugPrint'),
                ),
                FilledButton.tonal(
                  onPressed: _reportFlutterError,
                  child: const Text('FlutterError'),
                ),
                FilledButton.tonal(
                  onPressed: _logWebRuntimeError,
                  child: const Text('web error'),
                ),
                OutlinedButton(
                  onPressed: _throwAsyncError,
                  child: const Text('async error'),
                ),
                SegmentedButton<ailog.ReportFormat>(
                  segments: const [
                    ButtonSegment(
                      value: .markdown,
                      icon: Icon(Icons.article_outlined),
                      label: Text('Markdown'),
                    ),
                    ButtonSegment(
                      value: .diagnostic,
                      icon: Icon(Icons.terminal_outlined),
                      label: Text('Diagnostic'),
                    ),
                    ButtonSegment(
                      value: .compactJson,
                      icon: Icon(Icons.data_object_outlined),
                      label: Text('JSON'),
                    ),
                  ],
                  selected: {_reportFormat},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _reportFormat = selection.single;
                    });
                  },
                ),
                OutlinedButton.icon(
                  onPressed: _copyAiReport,
                  icon: const Icon(Icons.content_copy),
                  label: const Text('copy AI report'),
                ),
              ],
            ),
          ),
          if (_aiReport != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _aiReport!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const Divider(height: 1),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('No captured events yet.'))
                : ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        dense: true,
                        title: Text('[${event.level.code}] ${event.message}'),
                        subtitle: Text(
                          [
                            event.source,
                            if (event.kind != null) event.kind,
                            if (event.location != null) event.location,
                          ].join(' • '),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
