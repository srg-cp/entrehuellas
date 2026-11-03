import 'package:flutter/material.dart';

import 'loading_shimmer.dart';

/// Original mobile action geometry with the sky light of the landing CTA.
class BrandActionButton extends StatelessWidget {
  const BrandActionButton({
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.loadingLabel = 'Guardando',
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final String loadingLabel;

  @override
  Widget build(BuildContext context) => LoadingShimmer(
    isLoading: isBusy,
    loadingLabel: loadingLabel,
    radius: 26,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF75BFFF), Color(0xFF459FF6), Color(0xFF2887EF)],
          stops: [0, .48, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x402887EF),
            offset: Offset(0, 7),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Color(0x1A2887EF),
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x80FFFFFF), Color(0x00FFFFFF)],
            stops: [0, .06],
          ),
        ),
        child: FilledButton(
          onPressed: isBusy ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            minimumSize: const Size(double.infinity, 68),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.15,
              shadows: const [
                Shadow(
                  color: Color(0x4D155BA9),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(label, textAlign: TextAlign.center),
              const Icon(Icons.arrow_forward_rounded, size: 26),
            ],
          ),
        ),
      ),
    ),
  );
}
