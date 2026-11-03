import 'package:flutter/material.dart';
import 'app_page_background.dart';
import 'stagger_reveal.dart';

/// A curtain with the shared background covers content without scaling it.
class CoverReveal extends StatelessWidget {
  const CoverReveal({required this.animation, super.key});
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) => ClipRect(
      clipper: _CoverClipper(Curves.easeInOutCubic.transform(animation.value)),
      child: const AppPageBackground(child: SizedBox.expand()),
    ),
  );
}

class _CoverClipper extends CustomClipper<Rect> {
  const _CoverClipper(this.progress);
  final double progress;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * (1 - progress), size.width, size.height);
  @override
  bool shouldReclip(_CoverClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Keeps the header outside a single stagger entrance per discrete stage.
/// The historical name remains for callers; no curtain or background is drawn.
/// Loading completion, edits, countdowns and errors preserve the current entry.
class AuthStageTransition extends StatefulWidget {
  const AuthStageTransition({
    required this.stage,
    required this.builder,
    this.enabled = true,
    super.key,
  });
  final Object stage;
  final Widget Function(bool play) builder;
  final bool enabled;
  @override
  State<AuthStageTransition> createState() => _AuthStageTransitionState();
}

class _AuthStageTransitionState extends State<AuthStageTransition> {
  Key _stageKey = UniqueKey();
  bool _changedStage = false;

  @override
  void didUpdateWidget(AuthStageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resolving a resource belongs to its existing skeleton entrance.
    if (widget.enabled &&
        oldWidget.enabled &&
        oldWidget.stage != widget.stage) {
      _stageKey = UniqueKey();
      _changedStage = true;
    }
  }

  @override
  Widget build(BuildContext context) => PageEntranceScope(
    routeOwnsEntrance:
        !_changedStage && PageEntranceScope.routeOwnsEntranceOf(context),
    child: KeyedSubtree(key: _stageKey, child: widget.builder(true)),
  );
}
