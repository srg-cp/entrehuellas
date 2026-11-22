import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared surface of segmented selectors and floating filter controls.
class SelectionPillSurface extends StatelessWidget {
  const SelectionPillSurface({
    required this.child,
    this.padding = const EdgeInsets.all(6),
    super.key,
  });
  static const background = AppColors.divider;
  static const selected = AppColors.ink;
  static const optionRadius = 26.0;
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Padding(padding: padding, child: child),
  );
}
