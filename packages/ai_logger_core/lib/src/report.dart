import 'dart:convert';

import 'diagnostic.dart';
import 'event.dart';
import 'level.dart';

enum ReportFormat {
  markdown,
  compactJson,
  diagnostic;

  static ReportFormat parse(String? value) {
    return switch (value) {
      'json' || 'compact-json' || 'compactJson' => ReportFormat.compactJson,
      'diagnostic' => ReportFormat.diagnostic,
      _ => ReportFormat.markdown,
    };
  }
}

class AiReport {
  const AiReport({required this.event, this.recentSignals = const []});

  final LogEvent event;
  final List<LogEvent> recentSignals;

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln(
        '# ${event.source == 'flutter' ? 'Flutter Error' : 'Runtime Event'}',
      )
      ..writeln(event.message)
      ..writeln();

    if (event.kind case final String kind) {
      buffer.writeln('Kind: $kind');
    }
    if (event.likelyWidget case final String widget) {
      buffer.writeln('Likely widget: $widget');
    }
    if (event.location case final String location) {
      buffer.writeln('Location: $location');
    }

    if (event.probableCause case final String cause) {
      buffer
        ..writeln()
        ..writeln('# Probable Cause')
        ..writeln(cause);
    }

    if (event.suggestedFix case final String fix) {
      buffer
        ..writeln()
        ..writeln('# Suggested Fix')
        ..writeln(fix);
    }

    final frames = event.appFrames;
    if (frames.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('# App Frames');
      for (var index = 0; index < frames.length; index += 1) {
        buffer.writeln('${index + 1}. ${frames[index]}');
      }
    }

    if (recentSignals.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('# Recent Signals');
      for (final signal in recentSignals) {
        final route = signal.context['route'];
        final routeText = route == null ? '' : ' route=$route';
        buffer.writeln('- ${signal.level.label}$routeText ${signal.message}');
      }
    }

    return buffer.toString().trimRight();
  }

  Map<String, Object?> toCompactJson() {
    return {
      'event': event.toJson(),
      if (recentSignals.isNotEmpty)
        'recentSignals': recentSignals.map((event) => event.toJson()).toList(),
    };
  }

  String toCompactJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toCompactJson());
  }

  String toDiagnostic({SourceLoader? sourceLoader}) {
    return DiagnosticRenderer().render(event, sourceLoader: sourceLoader);
  }

  String format(ReportFormat format, {SourceLoader? sourceLoader}) {
    return switch (format) {
      ReportFormat.markdown => toMarkdown(),
      ReportFormat.compactJson => toCompactJsonString(),
      ReportFormat.diagnostic => toDiagnostic(sourceLoader: sourceLoader),
    };
  }
}

class ReportGenerator {
  const ReportGenerator({this.recentSignalLimit = 20});

  final int recentSignalLimit;

  AiReport build(LogEvent event, Iterable<LogEvent> allEvents) {
    final recent = <LogEvent>[];
    for (final candidate in allEvents) {
      if (identical(candidate, event)) {
        break;
      }
      if (_isUsefulSignal(candidate)) {
        recent.add(candidate);
      }
    }
    final signals = recent.length <= recentSignalLimit
        ? recent
        : recent.sublist(recent.length - recentSignalLimit);
    return AiReport(event: event, recentSignals: signals);
  }

  bool _isUsefulSignal(LogEvent event) {
    if (event.level.index >= Level.warning.index) {
      return true;
    }
    return event.level == Level.debug || event.level == Level.info;
  }
}
