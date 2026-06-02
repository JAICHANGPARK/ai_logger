import 'diagnostic.dart';
import 'level.dart';
import 'redaction.dart';
import 'report.dart';

class Options {
  const Options({
    this.captureLevel = Level.info,
    this.reportLevel = Level.warning,
    this.recentSignalLimit = 20,
    this.capturePrint = true,
    this.printReports = true,
    this.reportFormat = ReportFormat.diagnostic,
    this.reportWriter,
    this.reportSourceLoader,
    this.redactionRules,
  });

  final Level captureLevel;
  final Level reportLevel;
  final int recentSignalLimit;
  final bool capturePrint;
  final bool printReports;
  final ReportFormat reportFormat;
  final void Function(String report)? reportWriter;
  final SourceLoader? reportSourceLoader;
  final List<RedactionRule>? redactionRules;

  Redactor createRedactor() {
    return Redactor(redactionRules ?? Redactor.defaultRules);
  }
}
