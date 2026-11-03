import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'case_public_cards.dart';
import 'loading_shimmer.dart';

/// Matches the public cards without requesting photos, metadata or map tiles.
class CasePublicCardsSkeleton extends StatelessWidget {
  const CasePublicCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => LoadingShimmer(
    isLoading: true,
    isAction: false,
    radius: 28,
    loadingLabel: 'Consultando ficha del caso',
    child: ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: MediaQuery.textScalerOf(context).scale(16) > 22
                ? .7
                : 1.05,
            child: const _Shape(),
          ),
          const SizedBox(height: 12),
          const _Shape(height: 68),
          const SizedBox(height: 12),
          const CasePublicGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Shape(height: 50),
                SizedBox(height: 16),
                _Shape(height: 50),
                SizedBox(height: 16),
                _Shape(height: 45),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(
              builder: (context, constraints) => _Shape(
                key: const ValueKey('case-skeleton-map'),
                height: math.max(
                  constraints.maxWidth / 1.35,
                  MediaQuery.textScalerOf(context).scale(140),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _Shape(height: 20),
        ],
      ),
    ),
  );
}

class _Shape extends StatelessWidget {
  const _Shape({this.height, super.key});
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFDCE1E7),
      borderRadius: BorderRadius.circular(24),
    ),
  );
}
