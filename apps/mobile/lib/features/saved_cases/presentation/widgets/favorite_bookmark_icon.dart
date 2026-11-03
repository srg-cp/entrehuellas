import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A confirmed save celebrates locally; loading an existing favorite does not.
class FavoriteBookmarkIcon extends StatefulWidget {
  const FavoriteBookmarkIcon({
    required this.saved,
    required this.celebrationId,
    this.size = 26,
    super.key,
  });

  static const yellow = Color(0xFFF4BE24);
  final bool saved;
  final int celebrationId;
  final double size;

  @override
  State<FavoriteBookmarkIcon> createState() => _FavoriteBookmarkIconState();
}

class _FavoriteBookmarkIconState extends State<FavoriteBookmarkIcon>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );

  @override
  void didUpdateWidget(FavoriteBookmarkIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.saved) {
      _controller.reset();
    } else if (!oldWidget.saved &&
        widget.celebrationId > oldWidget.celebrationId &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final t = _controller.value;
      final bounce = t < .55 ? math.sin(t / .55 * math.pi) * .18 : 0.0;
      return CustomPaint(
        foregroundPainter: _FavoriteConfettiPainter(t),
        child: Transform.scale(scale: 1 + bounce, child: child),
      );
    },
    child: Icon(
      widget.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      size: widget.size,
      color: widget.saved ? FavoriteBookmarkIcon.yellow : null,
    ),
  );
}

class _FavoriteConfettiPainter extends CustomPainter {
  const _FavoriteConfettiPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final travel = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - Curves.easeIn.transform(progress)).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = FavoriteBookmarkIcon.yellow.withValues(alpha: opacity);
    final center = Offset(size.width / 2, size.height / 2 + 4);
    // Six tiny pieces fan around the lower sides of the bookmark.
    for (var i = 0; i < 6; i++) {
      final angle = (.08 + i * .168) * math.pi;
      final radius = 9 + (i.isEven ? 17 : 21) * travel;
      final position =
          center +
          Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius + 5 * progress * progress,
          );
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + progress * (i.isEven ? 2 : -2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 2.3,
            height: i.isEven ? 4 : 3,
          ),
          const Radius.circular(.8),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FavoriteConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
