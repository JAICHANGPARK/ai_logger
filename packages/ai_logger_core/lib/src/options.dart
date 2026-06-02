import 'level.dart';
import 'redaction.dart';

class Options {
  const Options({
    this.captureLevel = Level.info,
    this.reportLevel = Level.warning,
    this.recentSignalLimit = 20,
    this.capturePrint = true,
    this.redactionRules,
  });

  final Level captureLevel;
  final Level reportLevel;
  final int recentSignalLimit;
  final bool capturePrint;
  final List<RedactionRule>? redactionRules;

  Redactor createRedactor() {
    return Redactor(redactionRules ?? Redactor.defaultRules);
  }
}
