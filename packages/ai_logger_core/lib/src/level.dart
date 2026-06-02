enum Level {
  trace('T', 'trace'),
  debug('D', 'debug'),
  info('I', 'info'),
  warning('W', 'warning'),
  error('E', 'error'),
  fatal('F', 'fatal');

  const Level(this.code, this.label);

  final String code;
  final String label;

  bool allows(Level other) => other.index >= index;

  static Level parse(Object? value) {
    if (value is Level) {
      return value;
    }
    final text = value?.toString().toLowerCase();
    return switch (text) {
      't' || 'trace' => .trace,
      'd' || 'debug' => .debug,
      'i' || 'info' => .info,
      'w' || 'warning' || 'warn' => .warning,
      'e' || 'error' => .error,
      'f' || 'fatal' => .fatal,
      _ => .info,
    };
  }
}
