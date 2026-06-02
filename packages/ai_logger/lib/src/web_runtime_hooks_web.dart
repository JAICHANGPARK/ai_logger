import 'dart:js_interop';

import 'package:ai_logger_core/ai_logger_core.dart' as core;
import 'package:web/web.dart' as web;

import 'web_runtime_error_classifier.dart';

bool _installed = false;
web.EventListener? _errorListener;
web.EventListener? _unhandledRejectionListener;

void installWebRuntimeHooks({core.AiLogger? target}) {
  if (_installed) {
    return;
  }

  final activeLogger = target ?? core.logger;
  _captureWebContext(activeLogger.context);

  final errorListener = ((web.Event event) {
    _captureWebContext(activeLogger.context);
    if (_tryLogErrorEvent(event, activeLogger)) {
      return;
    }
    logClassifiedWebRuntimeError(
      event,
      message: 'Browser error event: ${event.type}',
      source: 'web:onerror',
      level: .fatal,
      target: activeLogger,
    );
  }).toJS;
  _errorListener = errorListener;

  final unhandledRejectionListener = ((web.Event event) {
    _captureWebContext(activeLogger.context);
    final reason = _safePromiseReason(event) ?? event;
    logClassifiedWebRuntimeError(
      reason,
      message: 'Unhandled promise rejection: $reason',
      source: 'web:unhandledrejection',
      isUnhandledRejection: true,
      level: .error,
      target: activeLogger,
    );
  }).toJS;
  _unhandledRejectionListener = unhandledRejectionListener;

  web.window.addEventListener('error', errorListener);
  web.window.addEventListener('unhandledrejection', unhandledRejectionListener);
  _installed = true;
}

void resetWebRuntimeHooksForTesting() {
  if (!_installed) {
    return;
  }
  final errorListener = _errorListener;
  if (errorListener != null) {
    web.window.removeEventListener('error', errorListener);
  }
  final unhandledRejectionListener = _unhandledRejectionListener;
  if (unhandledRejectionListener != null) {
    web.window.removeEventListener(
      'unhandledrejection',
      unhandledRejectionListener,
    );
  }
  _errorListener = null;
  _unhandledRejectionListener = null;
  _installed = false;
}

bool _tryLogErrorEvent(web.Event event, core.AiLogger activeLogger) {
  try {
    final errorEvent = event as web.ErrorEvent;
    logClassifiedWebRuntimeError(
      _safeJsValue(errorEvent.error),
      message: errorEvent.message,
      file: errorEvent.filename,
      line: errorEvent.lineno,
      column: errorEvent.colno,
      source: 'web:onerror',
      level: .fatal,
      target: activeLogger,
    );
    return true;
  } on Object {
    return false;
  }
}

Object? _safePromiseReason(web.Event event) {
  try {
    return _safeJsValue((event as web.PromiseRejectionEvent).reason);
  } on Object {
    return null;
  }
}

Object? _safeJsValue(JSAny? value) {
  return value?.toString();
}

void _captureWebContext(core.LoggerContext context) {
  context
    ..set('web.url', _redactedUrl(web.window.location.href))
    ..set('web.userAgent', web.window.navigator.userAgent)
    ..set('web.viewport', '${web.window.innerWidth}x${web.window.innerHeight}');
}

String _redactedUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.queryParameters.isEmpty) {
    return value;
  }
  final redactedParameters = {
    for (final entry in uri.queryParameters.entries)
      entry.key: _isSensitiveKey(entry.key) ? '[REDACTED]' : entry.value,
  };
  return uri.replace(queryParameters: redactedParameters).toString();
}

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return lower.contains('token') ||
      lower.contains('secret') ||
      lower.contains('password') ||
      lower.contains('key');
}
