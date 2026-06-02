import 'diagnostic.dart';
import 'level.dart';
import 'redaction.dart';
import 'report.dart';

class Options {
  const Options({
    this.captureLevel = .info,
    this.reportLevel = .warning,
    this.recentSignalLimit = 20,
    this.recentSignalLevels,
    this.capturePrint = true,
    this.printReports = true,
    this.reportFormat = .diagnostic,
    this.reportWriter,
    this.reportSourceLoader,
    this.redactionRules,
  });

  /// Lowest event level to store.
  ///
  /// Events below this level are ignored completely, so they cannot be shown in
  /// later reports or returned from recent event queries.
  final Level captureLevel;

  /// Lowest captured event level that should trigger an AI-readable report.
  ///
  /// For example, `captureLevel: .debug` and `reportLevel: .warning`
  /// stores debug/info/warning/error/fatal events, but only warning/error/fatal
  /// events automatically print reports.
  final Level reportLevel;

  /// Maximum number of previous events to include as report context.
  final int recentSignalLimit;

  /// Exact previous event levels to include as report context.
  ///
  /// Leave this unset to include the default useful signals: debug, info,
  /// warning, error, and fatal. Set it to values such as
  /// `[.trace, .debug, .error]` when reports should include only
  /// those levels.
  final List<Level>? recentSignalLevels;

  /// Whether guarded `print()` calls should be captured as info events.
  final bool capturePrint;

  /// Whether reportable events should automatically print an AI-readable report.
  final bool printReports;

  /// Format used for automatically printed reports.
  final ReportFormat reportFormat;

  /// Custom writer for automatically printed reports.
  final void Function(String report)? reportWriter;

  /// Source loader used to render source frames in reports.
  final SourceLoader? reportSourceLoader;

  /// Custom redaction rules for messages, errors, stack traces, and context.
  final List<RedactionRule>? redactionRules;

  Redactor createRedactor() {
    return Redactor(redactionRules ?? Redactor.defaultRules);
  }
}
