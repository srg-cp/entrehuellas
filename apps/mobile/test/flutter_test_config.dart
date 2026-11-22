import 'dart:async';

import 'package:flutter_application_entrehuellas/core/presentation/widgets/app_page_background.dart';

/// Applies to every test under test/. The ambient background repeats forever,
/// so pumpAndSettle could never settle; tests that verify the motion pass
/// `animate: true` explicitly.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppPageBackground.ambientMotion = false;
  await testMain();
}
