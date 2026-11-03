import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Replace the completed editor only after its confirmed state has rendered.
void completeOperation(BuildContext context, String destination) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  final source = router.routeInformationProvider.value.uri;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // The editor shell may change at confirmation and dispose its child.
    // A subsequent user navigation still cancels this pending continuation.
    if (router.routeInformationProvider.value.uri != source) return;
    router.pushReplacement(destination);
  });
}
