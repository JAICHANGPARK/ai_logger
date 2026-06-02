import 'dart:collection';

class Breadcrumb {
  const Breadcrumb({
    required this.name,
    required this.timestamp,
    this.data = const {},
  });

  final String name;
  final DateTime timestamp;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      't': timestamp.toIso8601String(),
      if (data.isNotEmpty) 'data': data,
    };
  }

  static Breadcrumb fromJson(Map<String, Object?> json) {
    return Breadcrumb(
      name: json['name']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(json['t']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      data: _objectMap(json['data']),
    );
  }
}

class LoggerContext {
  LoggerContext({this.maxBreadcrumbs = 50});

  final int maxBreadcrumbs;
  final Map<String, Object?> _values = {};
  final Queue<Breadcrumb> _breadcrumbs = Queue();

  String? get route => _values['route']?.toString();

  Map<String, Object?> get values => Map.unmodifiable(_values);

  List<Breadcrumb> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  void setRoute(String route) {
    set('route', route);
    addBreadcrumb('route', data: {'route': route});
  }

  void set(String key, Object? value) {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  void addBreadcrumb(String name, {Map<String, Object?> data = const {}}) {
    _breadcrumbs.add(
      Breadcrumb(name: name, timestamp: DateTime.now(), data: data),
    );
    while (_breadcrumbs.length > maxBreadcrumbs) {
      _breadcrumbs.removeFirst();
    }
  }

  void clear() {
    _values.clear();
    _breadcrumbs.clear();
  }
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }
  return const {};
}
