import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Receives every error nobody else handled. The default only logs locally;
/// a crash-reporting service can be plugged in here without touching features.
typedef UnhandledErrorSink =
    void Function(Object error, StackTrace? stack, {required String origin});

/// Logs the error type and stack only. Messages are omitted outside debug
/// because SDK and widget errors can embed user data, URLs or tokens.
void logUnhandledError(
  Object error,
  StackTrace? stack, {
  required String origin,
}) {
  developer.log(
    'Unhandled ${error.runtimeType} ($origin)',
    name: 'entre_huellas.error',
    level: 1000,
    error: kDebugMode ? error : null,
    stackTrace: stack,
  );
}

/// Routes framework, platform and async errors to [sink]. In release, a widget
/// that fails to build renders nothing instead of the default grey block.
/// Returns a callback that restores the previous handlers (used by tests).
VoidCallback installErrorHandlers({
  UnhandledErrorSink sink = logUnhandledError,
  bool releaseErrorWidget = kReleaseMode,
}) {
  final previousFlutter = FlutterError.onError;
  final previousPlatform = PlatformDispatcher.instance.onError;
  final previousWidget = ErrorWidget.builder;

  FlutterError.onError = (details) {
    if (!kReleaseMode) FlutterError.presentError(details);
    sink(details.exception, details.stack, origin: 'flutter');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    sink(error, stack, origin: 'platform');
    return true;
  };
  if (releaseErrorWidget) {
    ErrorWidget.builder = (_) => const SizedBox.shrink();
  }

  return () {
    FlutterError.onError = previousFlutter;
    PlatformDispatcher.instance.onError = previousPlatform;
    ErrorWidget.builder = previousWidget;
  };
}
