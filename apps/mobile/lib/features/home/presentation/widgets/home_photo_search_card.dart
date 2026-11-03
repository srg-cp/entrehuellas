import 'package:flutter/material.dart';

import 'home_banner_surface.dart';

class HomePhotoSearchCard extends StatelessWidget {
  const HomePhotoSearchCard({required this.onTap, super.key});

  static const artwork = 'assets/illustrations/home/photo-search.webp';
  final ValueChanged<BuildContext> onTap;

  @override
  Widget build(BuildContext context) => HomeBannerSurface(
    child: Builder(
      builder: (source) => InkWell(
        onTap: () => onTap(source),
        child: const HomePhotoSearchContent(),
      ),
    ),
  );
}

class HomePhotoSearchContent extends StatelessWidget {
  const HomePhotoSearchContent({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final expanded =
          constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(16) > 22;
      final picture = Image.asset(
        HomePhotoSearchCard.artwork,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      );
      const label = Text(
        'Buscar con una foto',
        style: TextStyle(
          color: Color(0xFF454746),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      );
      const arrow = Icon(
        Icons.arrow_forward_rounded,
        color: Color(0xFF459FF6),
        size: 26,
      );
      return Padding(
        padding: const EdgeInsets.all(14),
        child: expanded
            ? Column(
                children: [
                  SizedBox(height: 124, child: picture),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(child: label),
                      SizedBox(width: 12),
                      arrow,
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth * .42,
                    height: 94,
                    child: picture,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: label),
                  const SizedBox(width: 8),
                  arrow,
                ],
              ),
      );
    },
  );
}
