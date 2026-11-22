import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/app/error_reporting.dart';

void main() {
  test('Framework and async errors reach the sink; handlers restore', () {
    final seen = <String>[];
    final originalFlutter = FlutterError.onError;
    final originalPlatform = PlatformDispatcher.instance.onError;
    final restore = installErrorHandlers(
      sink: (error, stack, {required origin}) =>
          seen.add('$origin:${error.runtimeType}'),
    );
    try {
      // Silence the debug console dump for this synthetic error.
      FlutterError.onError!(
        FlutterErrorDetails(exception: StateError('build'), silent: true),
      );
      final handled = PlatformDispatcher.instance.onError!(
        const FormatException('async'),
        StackTrace.current,
      );

      expect(handled, isTrue);
      expect(seen, ['flutter:StateError', 'platform:FormatException']);
    } finally {
      restore();
    }
    expect(FlutterError.onError, same(originalFlutter));
    expect(PlatformDispatcher.instance.onError, same(originalPlatform));
  });

  testWidgets('Release builds hide a failing widget instead of a grey box', (
    tester,
  ) async {
    final restore = installErrorHandlers(
      sink: (_, _, {required origin}) {},
      releaseErrorWidget: true,
    );
    try {
      final widget = ErrorWidget.builder(
        FlutterErrorDetails(exception: StateError('build')),
      );
      expect(widget, isA<SizedBox>());
    } finally {
      restore();
    }
  });
}
