import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/presentation/widgets/horizontal_page_transition.dart';
import '../../core/presentation/widgets/stagger_reveal.dart';

Page<void> horizontalPage({
  required BuildContext context,
  required LocalKey key,
  required Widget child,
}) {
  final reduced = MediaQuery.disableAnimationsOf(context);
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: reduced
        ? Duration.zero
        : HorizontalPageTransition.duration,
    reverseTransitionDuration: reduced
        ? Duration.zero
        : HorizontalPageTransition.reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        HorizontalPageTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
    child: PageEntranceScope(routeOwnsEntrance: true, child: child),
  );
}
