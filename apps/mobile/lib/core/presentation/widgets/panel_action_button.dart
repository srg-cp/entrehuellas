import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared secondary action in an opaque panel, with accessible icon-only mode.
class PanelActionButton extends StatelessWidget {
  const PanelActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconOnly = true,
    this.iconWidget,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool iconOnly;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) => iconOnly
      ? IconButton(
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFEEEEF0),
            disabledBackgroundColor: const Color(0xFFEEEEF0),
            foregroundColor: AppColors.ink,
            fixedSize: const Size.square(56),
            shape: const CircleBorder(),
          ),
          onPressed: onPressed,
          icon: iconWidget ?? Icon(icon, size: 26),
        )
      : TextButton.icon(
          onPressed: onPressed,
          icon: iconWidget ?? Icon(icon),
          label: Text(label),
        );
}
