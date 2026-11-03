import 'package:flutter/material.dart';

/// Forward navigation enters from the right; returning reverses the same path.
/// The secondary animation moves the previous page to the left in sync.
class HorizontalPageTransition extends StatelessWidget {
  const HorizontalPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    super.key,
  });

  static const duration = Duration(milliseconds: 320);
  static const reverseDuration = Duration(milliseconds: 260);
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curve = CurveTween(curve: Curves.easeInOutCubic);
    return ClipRect(
      child: SlideTransition(
        position: animation
            .drive(curve)
            .drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
        child: SlideTransition(
          position: secondaryAnimation
              .drive(curve)
              .drive(Tween(begin: Offset.zero, end: const Offset(-1, 0))),
          child: child,
        ),
      ),
    );
  }
}
