import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/brand_action_button.dart';

class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    required this.page,
    required this.isBusy,
    required this.onNext,
    this.disabled = false,
    super.key,
  });
  final int page;
  final bool isBusy;
  final VoidCallback onNext;
  final bool disabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Retain progress for assistive technology without visible dots.
      Semantics(
        label: 'Paso ${page + 1} de 3',
        liveRegion: true,
        child: const SizedBox.shrink(),
      ),
      BrandActionButton(
        label: page == 2 ? 'Comenzar' : 'Continuar',
        onPressed: disabled ? null : onNext,
        isBusy: isBusy,
        loadingLabel: 'Guardando finalización del onboarding',
      ),
    ],
  );
}
