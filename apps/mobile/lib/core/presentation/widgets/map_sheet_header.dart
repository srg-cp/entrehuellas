import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'glass_navigation_button.dart';
import 'glass_surface.dart';

class MapSheetHeader extends StatelessWidget {
  const MapSheetHeader({
    required this.title,
    required this.backTooltip,
    required this.extent,
    required this.onBack,
    super.key,
  });
  final String title, backTooltip;
  final ValueListenable<double> extent;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Positioned(
    top: MediaQuery.paddingOf(context).top + 8,
    left: 16,
    right: 16,
    child: ValueListenableBuilder<double>(
      valueListenable: extent,
      child: Row(
        children: [
          GlassNavigationButton(tooltip: backTooltip, onPressed: onBack),
          Expanded(
            child: Center(
              child: ValueListenableBuilder<double>(
                valueListenable: extent,
                child: GlassSurface(
                  radius: 24,
                  backdropBlendMode: BlendMode.src,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF171918),
                      ),
                    ),
                  ),
                ),
                builder: (context, extent, child) {
                  final media = MediaQuery.of(context);
                  final remaining =
                      media.size.height * (1 - extent) - media.padding.top;
                  final opacity = media.size.height < 500
                      ? 0.0
                      : ((remaining - 80) / 40).clamp(0.0, 1.0);
                  return ExcludeSemantics(
                    excluding: opacity == 0,
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
      builder: (context, extent, child) {
        final reduced = MediaQuery.disableAnimationsOf(context);
        final progress = reduced || extent >= .8999
            ? (extent >= .89 ? 1.0 : 0.0)
            : ((extent - .78) / .12).clamp(0.0, 1.0);
        return ExcludeSemantics(
          excluding: progress >= 1,
          child: IgnorePointer(
            ignoring: progress >= 1,
            child: Opacity(
              opacity: 1 - progress,
              child: Transform.translate(
                offset: Offset(0, reduced ? 0 : -72 * progress),
                child: child,
              ),
            ),
          ),
        );
      },
    ),
  );
}
