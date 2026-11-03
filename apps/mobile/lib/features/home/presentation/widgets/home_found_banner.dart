import 'package:flutter/material.dart';

import 'home_banner_surface.dart';

class HomeFoundBanner extends StatelessWidget {
  const HomeFoundBanner({required this.onFound, super.key});

  static const artwork = 'assets/illustrations/home/found-home.webp';
  final ValueChanged<BuildContext> onFound;

  @override
  Widget build(BuildContext context) => HomeBannerSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1.65,
          child: Image.asset(
            artwork,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '¿Encontraste una '),
                    TextSpan(
                      text: 'mascota?',
                      style: TextStyle(color: Color(0xFF459FF6)),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF454746),
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ayúdala a volver a casa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6E6E73),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              HomeBannerAction(label: 'Encontré una mascota', onTap: onFound),
            ],
          ),
        ),
      ],
    ),
  );
}
