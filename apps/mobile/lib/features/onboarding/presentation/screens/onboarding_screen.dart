import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/stagger_stage_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../view_models/onboarding_view_model.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _motion = GlobalKey<StaggerStageTransitionState>();
  bool _transitioning = false;
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final _pressScale = _press.drive(
    TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: .93,
        ).chain(CurveTween(curve: const Cubic(.22, 1, .36, 1))),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: .93,
          end: 1.0,
        ).chain(CurveTween(curve: const Cubic(.22, 1, .36, 1))),
        weight: 1,
      ),
    ]),
  );
  static const _titles = [
    'Cada huella importa',
    'Volvamos a casa',
    'Una nueva historia',
  ];
  static const _descriptions = [
    'Encuentra, ayuda y cuida a las mascotas cerca de ti.',
    'Con tu ayuda, más mascotas pueden reencontrarse con su familia.',
    'Pequeñas acciones generan grandes finales.',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _press.value = 1;
  }

  Future<void> _advance() async {
    if (_transitioning || ref.read(onboardingViewModelProvider).isBusy) return;
    setState(() => _transitioning = true);
    try {
      if (!MediaQuery.disableAnimationsOf(context)) {
        try {
          await _press.forward(from: 0).orCancel;
        } on TickerCanceled {
          if (!mounted || !MediaQuery.disableAnimationsOf(context)) return;
        }
      }
      if (!mounted) return;
      final vm = ref.read(onboardingViewModelProvider.notifier);
      if (ref.read(onboardingViewModelProvider).page == 2) {
        // Keep the full action and its shimmer visible throughout the real save.
        await vm.next();
        if (!mounted || !ref.read(onboardingViewModelProvider).completed) {
          return;
        }
        if (!await _motion.currentState!.hide() || !mounted) return;
        vm.acknowledgeCompletion();
        return;
      }
      if (!await _motion.currentState!.hide() || !mounted) return;
      await vm.next();
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await _motion.currentState!.reveal();
    } finally {
      if (mounted) setState(() => _transitioning = false);
    }
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    return ConfirmationToastHost(
      confirmed: state.hasError,
      message: 'No se pudo guardar. Inténtalo de nuevo.',
      isError: true,
      noticeId: state,
      child: PopScope(
        canPop: false,
        child: AppScaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 496),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BrandWordmark(iconSize: 56, textSize: 24),
                      ),
                    ),
                    Expanded(
                      child: StaggerStageTransition(
                        key: _motion,
                        child: OnboardingPage(
                          key: ValueKey(state.page),
                          page: state.page,
                          title: _titles[state.page],
                          description: _descriptions[state.page],
                          titleSamples: _titles,
                          descriptionSamples: _descriptions,
                          isBusy: state.isBusy,
                          disabled: _transitioning,
                          pressScale: _pressScale,
                          onNext: _advance,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
