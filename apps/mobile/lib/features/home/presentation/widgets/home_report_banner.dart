import 'package:flutter/material.dart';

import 'home_banner_surface.dart';

class HomeReportBanner extends StatelessWidget {
  const HomeReportBanner({
    required this.onReport,
    required this.onMyReports,
    super.key,
  });

  static const artwork = 'assets/illustrations/home/report-reunion.webp';
  final ValueChanged<BuildContext> onReport;
  final VoidCallback onMyReports;

  Widget _myReports(BuildContext context) => TextButton(
    onPressed: onMyReports,
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF454746),
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      textStyle: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontSize: 15),
    ),
    child: const Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.assignment_outlined, size: 20),
        Text('Mis reportes'),
        Icon(Icons.arrow_forward_rounded, size: 20),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => HomeBannerSurface(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final expanded = MediaQuery.textScalerOf(context).scale(16) > 22;
        const message = Text(
          'Ayudemos a que vuelva a casa.',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.25,
            color: Color(0xFF454746),
          ),
        );
        final action = HomeBannerAction(
          label: 'Reportar pérdida',
          onTap: onReport,
        );
        if (expanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.2,
                child: HomeBannerScenery(
                  child: Image.asset(
                    artwork,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _myReports(context),
                    ),
                    const SizedBox(height: 16),
                    message,
                    const SizedBox(height: 20),
                    action,
                  ],
                ),
              ),
            ],
          );
        }
        return Stack(
          children: [
            Positioned.fill(
              child: HomeBannerScenery(
                child: Image.asset(
                  artwork,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: .45),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: const [0, .6],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _myReports(context),
                  SizedBox(height: constraints.maxWidth * .10),
                  SizedBox(width: constraints.maxWidth * .36, child: message),
                  SizedBox(height: constraints.maxWidth * .17),
                  action,
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
