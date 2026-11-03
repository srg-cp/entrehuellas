import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';

/// Shared material for the illustrated Home actions; artwork is decorative.
class HomeBannerSurface extends StatelessWidget {
  const HomeBannerSurface({required this.child, super.key});

  static const radius = 26.0;
  static const originColor = GlassSurface.originColor;
  final Widget child;

  @override
  Widget build(BuildContext context) => GlassSurface.card(
    radius: radius,
    // The whole banner enters inside StaggerReveal's opacity layer.
    backdropBlendMode: BlendMode.src,
    child: Material(type: MaterialType.transparency, child: child),
  );
}

/// Integrates full-bleed opaque scenery into the pearl material. The light
/// falls on artwork only, leaving native text, controls and alpha assets crisp.
class HomeBannerScenery extends StatelessWidget {
  const HomeBannerScenery({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.modulate,
    shaderCallback: (bounds) => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFCED4D8),
        Color(0xFFF2F5F7),
        Colors.white,
        Color(0xFFCCD2D8),
      ],
      stops: [0, .35, .65, 1],
    ).createShader(bounds),
    child: child,
  );
}

/// Captures the actual button's context for the existing origin transition.
class HomeBannerAction extends StatelessWidget {
  const HomeBannerAction({required this.label, required this.onTap, super.key});

  final String label;
  final ValueChanged<BuildContext> onTap;

  static Widget identity(BuildContext context, String label) =>
      DefaultTextStyle(
        style: primaryActionButtonStyle(
          context,
        ).textStyle!.resolve({})!.copyWith(color: Colors.white),
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Center(child: _content(label)),
          ),
        ),
      );

  static Widget _content(String label) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 12,
    runSpacing: 6,
    children: [
      Text(label, textAlign: TextAlign.center),
      const Icon(Icons.arrow_forward_rounded, size: 24),
    ],
  );

  @override
  Widget build(BuildContext context) => Builder(
    builder: (source) => FilledButton(
      onPressed: () => onTap(source),
      style: primaryActionButtonStyle(context).copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      child: _content(label),
    ),
  );
}
