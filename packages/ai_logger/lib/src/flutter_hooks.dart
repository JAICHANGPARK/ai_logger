import 'dart:ui' as ui;

import 'package:ai_logger_core/ai_logger_core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as widgets;

import 'flutter_error_classifier.dart';

typedef PlatformErrorHandler =
    bool Function(Object error, StackTrace stackTrace);

bool _installed = false;
FlutterExceptionHandler? _previousFlutterError;
PlatformErrorHandler? _previousPlatformError;
DebugPrintCallback? _previousDebugPrint;

void installFlutterHooks({
  core.Options? options,
  Iterable<core.LogSink>? sinks,
}) {
  if (options != null || sinks != null) {
    core.configure(options: options, sinks: sinks);
  }
  if (_installed) {
    return;
  }

  _previousFlutterError = FlutterError.onError;
  FlutterError.onError = (details) {
    logClassifiedFlutterError(
      details.exception,
      stackTrace: details.stack,
      source: 'flutter',
    );
    final previous = _previousFlutterError;
    if (previous != null) {
      previous(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  _previousPlatformError = ui.PlatformDispatcher.instance.onError;
  ui.PlatformDispatcher.instance.onError = (error, stackTrace) {
    core.logger.log(
      core.Level.fatal,
      error,
      error: error,
      stackTrace: stackTrace,
      source: 'platform_dispatcher',
      kind: 'platform_dispatcher_error',
      probableCause:
          'An uncaught asynchronous error reached PlatformDispatcher.',
      suggestedFix:
          'Inspect the primary app frame and add local error handling.',
    );
    final previous = _previousPlatformError;
    return previous?.call(error, stackTrace) ?? true;
  };

  _previousDebugPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message != null) {
      core.logger.log(core.Level.debug, message, source: 'debugPrint');
    }
    _previousDebugPrint?.call(message, wrapWidth: wrapWidth);
  };

  _installed = true;
}

void runApp(
  widgets.Widget app, {
  core.Options? options,
  Iterable<core.LogSink>? sinks,
}) {
  runGuarded(
    () {
      widgets.runApp(app);
    },
    options: options,
    sinks: sinks,
  );
}

R runGuarded<R>(
  R Function() body, {
  core.Options? options,
  Iterable<core.LogSink>? sinks,
}) {
  return core.guard<R>(
    () {
      installFlutterHooks(options: options, sinks: sinks);
      return body();
    },
    options: options,
    sinks: sinks,
    target: core.logger,
  );
}

@visibleForTesting
void resetFlutterHooksForTesting() {
  if (!_installed) {
    return;
  }
  FlutterError.onError = _previousFlutterError;
  ui.PlatformDispatcher.instance.onError = _previousPlatformError;
  debugPrint = _previousDebugPrint ?? debugPrintThrottled;
  _previousFlutterError = null;
  _previousPlatformError = null;
  _previousDebugPrint = null;
  _installed = false;
}
