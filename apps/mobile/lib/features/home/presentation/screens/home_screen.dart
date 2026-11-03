import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/fading_header_scroll.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/scroll_safe_area.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/theme/app_typography.dart';
import '../state/home_view_state.dart';
import '../view_models/home_view_model.dart';
import '../widgets/home_content.dart';
import '../widgets/home_banner_surface.dart';
import '../widgets/home_header.dart';
import '../widgets/liquid_navigation.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    required this.profileAvatar,
    this.petsContent,
    this.exploreContent,
    this.exploreFloatingAction,
    this.onAlerts,
    this.onHomeRefresh,
    super.key,
  });

  final Widget profileAvatar;
  final Widget? petsContent, exploreContent, exploreFloatingAction;
  final ValueChanged<OriginPageSource?>? onAlerts;
  final Future<void> Function()? onHomeRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final model = ref.read(homeViewModelProvider.notifier);
    final animateContent =
        state.section != HomeSection.pets &&
        (state.section != HomeSection.explore || exploreContent == null);
    final scrollBottom =
        state.section == HomeSection.explore && exploreFloatingAction != null
        ? 200 +
              (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(
                0,
                double.infinity,
              )
        : 130.0;
    return ConfirmationToastHost(
      confirmed: state.refreshError,
      isError: true,
      message: 'No pudimos actualizar el inicio.',
      noticeId: state.noticeId,
      actionLabel: 'Reintentar',
      onAction: onHomeRefresh == null
          ? null
          : () => model.refresh(onHomeRefresh!),
      child: AppScaffold(
        body: ScrollSafeArea(
          top: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: PullToRefresh(
                onRefresh:
                    state.section == HomeSection.home && onHomeRefresh != null
                    ? () => model.refresh(onHomeRefresh!)
                    : null,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FadingHeaderScroll(
                        scrollKey: ValueKey(state.section),
                        header: HomeHeader(
                          profileAvatar: profileAvatar,
                          onAlerts: onAlerts,
                        ),
                        padding: EdgeInsets.fromLTRB(
                          state.section == HomeSection.explore ? 12 : 24,
                          6,
                          state.section == HomeSection.explore ? 12 : 24,
                          ScrollSafeArea.bottomPadding(
                            context,
                            scrollBottom.toDouble(),
                          ),
                        ),
                        child: StaggerReveal(
                          enabled: animateContent,
                          key: ValueKey(state.section),
                          count: state.section == HomeSection.home
                              ? HomeContent.revealCount
                              : 2,
                          child: state.section == HomeSection.home
                              ? HomeContent(
                                  onSelect: model.select,
                                  onReport: (source) => openLostReport(
                                    source,
                                    radius: 24,
                                    identity: HomeBannerAction.identity(
                                      source,
                                      'Reportar pérdida',
                                    ),
                                  ),
                                )
                              : state.section == HomeSection.explore &&
                                    exploreContent != null
                              ? exploreContent!
                              : state.section == HomeSection.pets &&
                                    petsContent != null
                              ? petsContent!
                              : _UnavailableSection(section: state.section),
                        ),
                      ),
                    ),
                    if (state.section == HomeSection.explore &&
                        exploreFloatingAction != null)
                      Positioned(
                        right: 16,
                        bottom: ScrollSafeArea.bottomPadding(context, 100),
                        child: exploreFloatingAction!,
                      ),
                    Positioned(
                      key: const ValueKey('home-navigation'),
                      left: 16,
                      right: 16,
                      bottom: ScrollSafeArea.bottomPadding(context, 16),
                      child: LiquidNavigation(
                        selected: state.section,
                        onSelect: model.select,
                        onReport: (source) => openLostReport(source),
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

class _UnavailableSection extends StatelessWidget {
  const _UnavailableSection({required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: 0,
        child: Text(
          section == HomeSection.explore ? 'Explorar' : 'Mis mascotas',
          style: AppTypography.primaryTitle,
        ),
      ),
      const SizedBox(height: 24),
      StaggerRevealItem(
        order: 1,
        child: HomeNotice(
          icon: section == HomeSection.explore
              ? Icons.travel_explore
              : Icons.pets_outlined,
          title: section == HomeSection.explore
              ? 'Ayuda a encontrar su hogar'
              : 'Su información, en un solo lugar',
          description: section == HomeSection.explore
              ? 'Aquí podrás consultar casos en lista o mapa y filtrar por ubicación. La búsqueda de casos aún no está disponible.'
              : 'Aquí podrás registrar tus mascotas, sus fotos y consultar sus casos. El registro de mascotas aún no está disponible.',
        ),
      ),
    ],
  );
}
