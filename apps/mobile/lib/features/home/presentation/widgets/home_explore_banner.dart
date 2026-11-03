import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_banner_surface.dart';

class HomeExploreBanner extends StatelessWidget {
  const HomeExploreBanner({required this.onExplore, super.key});

  static const artwork = 'assets/illustrations/home/explore-map.webp';
  final VoidCallback onExplore;

  Widget _artwork() => Stack(
    fit: StackFit.expand,
    children: [
      HomeBannerScenery(
        child: Image.asset(
          artwork,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
      ),
      Positioned(
        right: 24,
        top: 32,
        child: ExcludeSemantics(
          child: SvgPicture.asset(
            'assets/branding/only-black.svg',
            width: 68,
            height: 68,
            colorFilter: const ColorFilter.mode(
              Color(0xFF459FF6),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => HomeBannerSurface(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final expanded = MediaQuery.textScalerOf(context).scale(16) > 22;
        final content = Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: expanded ? null : constraints.maxWidth * .62,
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Explora\n'),
                      TextSpan(
                        text: 'cerca de ti',
                        style: TextStyle(color: Color(0xFF459FF6)),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: Color(0xFF454746),
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cada mirada puede ayudar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6E6E73),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              HomeBannerAction(label: 'Explorar', onTap: (_) => onExplore()),
            ],
          ),
        );
        if (expanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 140, child: _artwork()),
              content,
            ],
          );
        }
        return Stack(
          children: [
            Positioned.fill(child: _artwork()),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xD9D9DEE2), Color(0x00F5FAFF)],
                      stops: [0, .95],
                    ),
                  ),
                ),
              ),
            ),
            content,
          ],
        );
      },
    ),
  );
}
