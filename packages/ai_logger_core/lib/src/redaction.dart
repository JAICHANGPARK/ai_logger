class RedactionRule {
  const RedactionRule(this.pattern, this.replacement);

  final Pattern pattern;
  final String replacement;

  String apply(String value) {
    return value.replaceAll(pattern, replacement);
  }
}

class Redactor {
  const Redactor(this.rules);

  static final List<RedactionRule> defaultRules = [
    RedactionRule(
      RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
      'Bearer [REDACTED]',
    ),
    RedactionRule(
      RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}'),
      '[REDACTED_EMAIL]',
    ),
    RedactionRule(
      RegExp(
        r'(api[_-]?key|token|password|secret)\s*[:=]\s*[^\s,&}]+',
        caseSensitive: false,
      ),
      '[REDACTED_SECRET]',
    ),
  ];

  final List<RedactionRule> rules;

  String redactText(String value) {
    var output = value;
    for (final rule in rules) {
      output = rule.apply(output);
    }
    return output;
  }

  Object? redactValue(Object? value) {
    return switch (value) {
      null => null,
      String text => redactText(text),
      num number => number,
      bool boolean => boolean,
      Map map => {
        for (final entry in map.entries)
          entry.key.toString(): redactValue(entry.value),
      },
      Iterable<Object?> values => values.map(redactValue).toList(),
      _ => redactText(value.toString()),
    };
  }
}
