import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Bidirectional Sader onboarding timeline: 550ms per group, 90ms stagger.
/// Enter top-first from +56px; exit bottom-first towards +56px.
class StaggerStageTransition extends StatefulWidget {
  const StaggerStageTransition({required this.child, super.key});

  static const elementMs = 550;
  static const gapMs = 90;
  static const count = 4;
  static const totalMs = elementMs + (count - 1) * gapMs;
  final Widget child;

  @override
  State<StaggerStageTransition> createState() => StaggerStageTransitionState();
}

class StaggerStageTransitionState extends State<StaggerStageTransition>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: StaggerStageTransition.totalMs),
  );
  bool _started = false;
  bool _exiting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_started) {
      _controller.forward();
    }
    _started = true;
  }

  Future<bool> hide() => _run(exiting: true);
  Future<bool> reveal() => _run(exiting: false);

  Future<bool> _run({required bool exiting}) async {
    if (!mounted) return false;
    setState(() => _exiting = exiting);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return true;
    }
    try {
      await _controller.forward(from: 0).orCancel;
      return mounted;
    } on TickerCanceled {
      // A live change to reduced motion settles the current phase immediately.
      return mounted && MediaQuery.disableAnimationsOf(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _StageTimeline(
    animation: _controller,
    exiting: _exiting,
    child: widget.child,
  );
}

class _StageTimeline extends InheritedWidget {
  const _StageTimeline({
    required this.animation,
    required this.exiting,
    required super.child,
  });
  final Animation<double> animation;
  final bool exiting;

  @override
  bool updateShouldNotify(_StageTimeline oldWidget) =>
      exiting != oldWidget.exiting || animation != oldWidget.animation;
}

class StaggerStageItem extends StatelessWidget {
  const StaggerStageItem({required this.order, required this.child, super.key})
    : assert(order >= 0 && order < StaggerStageTransition.count);

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final timeline = context
        .dependOnInheritedWidgetOfExactType<_StageTimeline>()!;
    final index = timeline.exiting
        ? StaggerStageTransition.count - 1 - order
        : order;
    final curve = Interval(
      index * StaggerStageTransition.gapMs / StaggerStageTransition.totalMs,
      (index * StaggerStageTransition.gapMs +
              StaggerStageTransition.elementMs) /
          StaggerStageTransition.totalMs,
      curve: const Cubic(.22, 1, .36, 1),
    );
    return AnimatedBuilder(
      animation: timeline.animation,
      child: child,
      builder: (context, child) {
        final phase = curve.transform(timeline.animation.value);
        final visible = timeline.exiting ? 1 - phase : phase;
        return IgnorePointer(
          ignoring: visible == 0,
          child: ExcludeSemantics(
            excluding: visible == 0,
            child: Opacity(
              opacity: visible,
              child: Transform.translate(
                offset: Offset(0, 56 * (1 - visible)),
                child: ImageFiltered(
                  enabled: visible > 0 && visible < 1,
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: 18 * (1 - visible),
                    sigmaY: 18 * (1 - visible),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
