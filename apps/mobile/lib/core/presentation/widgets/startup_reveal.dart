import 'app_scaffold.dart';
import 'package:flutter/material.dart';

import 'brand_wordmark.dart';

/// Runs once per app mount, before mounting the router's destination animations.
class StartupReveal extends StatefulWidget {
  const StartupReveal({required this.child, super.key});
  final Widget child;

  @override
  State<StartupReveal> createState() => _StartupRevealState();
}

class _StartupRevealState extends State<StartupReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..addStatusListener(_complete);
  }

  void _complete(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _finished = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _finished = true;
    } else if (!_finished && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return widget.child;
    return AppScaffold(
      body: Semantics(
        label: 'Entre Huellas. Iniciando aplicación',
        child: ExcludeSemantics(
          child: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final progress = const Interval(
                    .18,
                    .85,
                  ).transform(_controller.value);
                  return BrandWordmark.startup(revealProgress: progress);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
