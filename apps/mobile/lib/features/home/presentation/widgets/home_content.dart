import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/theme/app_typography.dart';
import '../state/home_view_state.dart';
import 'home_banner_surface.dart';
import 'home_explore_banner.dart';
import 'home_found_banner.dart';
import 'home_navigation.dart';
import 'home_photo_search_card.dart';
import 'home_report_banner.dart';

export 'home_navigation.dart' show openHomeAction, openLostReport;

class HomeContent extends StatelessWidget {
  const HomeContent({
    required this.onSelect,
    required this.onReport,
    super.key,
  });

  static const revealCount = 5;
  final ValueChanged<HomeSection> onSelect;
  final ValueChanged<BuildContext> onReport;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: 0,
        child: Semantics(
          label: 'Su regreso empieza contigo',
          excludeSemantics: true,
          child: DefaultTextStyle.merge(
            style: AppTypography.primaryTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Su regreso'),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF459FF6), Color(0xFF75C9EF)],
                  ).createShader(bounds),
                  child: const Text(
                    'empieza contigo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 22),
      StaggerRevealItem(
        order: 1,
        child: HomeReportBanner(
          key: const ValueKey('home-report-banner'),
          onReport: onReport,
          onMyReports: () => context.push('/home/my-reports'),
        ),
      ),
      const SizedBox(height: 24),
      StaggerRevealItem(
        order: 2,
        child: HomeFoundBanner(
          key: const ValueKey('home-found-banner'),
          onFound: (source) => openHomeAction(
            source,
            '/home/found-cases/new?independent=true',
            HomeBannerAction.identity(source, 'Encontré una mascota'),
            radius: 24,
          ),
        ),
      ),
      const SizedBox(height: 24),
      StaggerRevealItem(
        order: 3,
        child: HomePhotoSearchCard(
          key: const ValueKey('home-photo-search'),
          onTap: (source) => openHomeAction(
            source,
            '/home/coincidencias',
            const HomePhotoSearchContent(),
            color: HomeBannerSurface.originColor,
            radius: HomeBannerSurface.radius,
          ),
        ),
      ),
      const SizedBox(height: 24),
      StaggerRevealItem(
        order: 4,
        child: HomeExploreBanner(
          key: const ValueKey('home-explore-banner'),
          onExplore: () => onSelect(HomeSection.explore),
        ),
      ),
    ],
  );
}

/// Existing fallback when a section has not been composed by the app router.
class HomeNotice extends StatelessWidget {
  const HomeNotice({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title, description;

  @override
  Widget build(BuildContext context) => GlassSurface.card(
    radius: 26,
    backdropBlendMode: BlendMode.src,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6E6E73), size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF6E6E73),
            ),
          ),
        ],
      ),
    ),
  );
}
