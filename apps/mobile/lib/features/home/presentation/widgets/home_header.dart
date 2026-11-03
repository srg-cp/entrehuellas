import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';

/// Persistent Home chrome, outside scrolling content and its entrance timeline.
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.profileAvatar, this.onAlerts, super.key});

  final Widget profileAvatar;
  final ValueChanged<OriginPageSource?>? onAlerts;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
    child: Row(
      children: [
        const Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: BrandWordmark(iconSize: 46, textSize: 22),
          ),
        ),
        Builder(
          builder: (source) => IconButton(
            tooltip: 'Alertas',
            onPressed: onAlerts == null
                ? null
                : () {
                    final box = source.findRenderObject();
                    final navigator = Navigator.of(
                      context,
                    ).context.findRenderObject();
                    final bounds = box is RenderBox && box.hasSize
                        ? box.localToGlobal(Offset.zero, ancestor: navigator) &
                              box.size
                        : null;
                    onAlerts!(
                      bounds == null
                          ? null
                          : OriginPageSource(
                              bounds: bounds,
                              color: Colors.white,
                              radius: 24,
                              child: const Center(
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF6E6E73),
                                ),
                              ),
                            ),
                    );
                  },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF6E6E73),
            ),
          ),
        ),
        const SizedBox(width: 4),
        profileAvatar,
      ],
    ),
  );
}
