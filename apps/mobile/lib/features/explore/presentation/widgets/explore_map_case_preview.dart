import '../../../../core/presentation/widgets/map_case_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/explore_case_preview.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';
import '../view_models/explore_case_preview_view_model.dart';

class ExploreMapCasePreview extends ConsumerWidget {
  const ExploreMapCasePreview({
    required this.item,
    this.scrollable = true,
    this.onOpen,
    this.onSummaryHeight,
    super.key,
  });
  final ExploreCase item;
  final bool scrollable;
  final ValueChanged<BuildContext>? onOpen;
  final ValueChanged<double>? onSummaryHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = exploreCasePreviewViewModelProvider(item);
    final state = ref.watch(provider);
    return ConfirmationToastHost(
      confirmed: state.hasError,
      isError: true,
      noticeId: state.error,
      message: 'No pudimos completar la vista previa del caso.',
      actionLabel: 'Reintentar',
      onAction: () => ref.invalidate(provider),
      child: ExploreMapPreviewContent(
        item: item,
        scrollable: scrollable,
        onOpen: onOpen,
        onSummaryHeight: onSummaryHeight,
        detail: state.asData?.value,
        loading: state.isLoading,
        failed: state.hasError,
      ),
    );
  }
}

/// Public case summary sharing the photo renderer used by case cards.
class ExploreMapPreviewContent extends StatelessWidget {
  const ExploreMapPreviewContent({
    required this.item,
    this.detail,
    this.loading = false,
    this.failed = false,
    this.scrollable = true,
    this.onOpen,
    this.onSummaryHeight,
    super.key,
  });
  final ExploreCase item;
  final ExploreCasePreview? detail;
  final bool loading, failed, scrollable;
  final ValueChanged<BuildContext>? onOpen;
  final ValueChanged<double>? onSummaryHeight;

  @override
  Widget build(BuildContext context) {
    final photo = detail?.photoUri ?? item.coverUri;
    final date = caseDateOnlyLabel(detail?.occurredAt ?? item.occurredAt);
    final event = item.kind == ExploreKind.lost
        ? 'Desaparición'
        : item.kind == ExploreKind.sighting
        ? 'Avistamiento'
        : 'Encuentro';
    final species = switch (item.species) {
      'dog' => 'Perro',
      'cat' => 'Gato',
      'other' => 'Otra especie',
      _ => 'Tipo no registrado',
    };
    final size = switch (detail?.size) {
      'small' => 'Pequeño',
      'medium' => 'Mediano',
      'large' => 'Grande',
      _ => failed ? 'Tamaño no disponible' : 'Tamaño no registrado',
    };
    return MapCasePanel(
      name: item.name,
      traits: item.traits,
      photoUri: photo,
      scrollable: scrollable,
      onOpen: onOpen,
      onSummaryHeight: onSummaryHeight,
      details: Column(
        key: const ValueKey('map-preview-facts'),
        children: [
          MapPanelFact(
            icon: Icons.straighten_rounded,
            label: 'Tamaño',
            value: loading
                ? const LoadingShimmer(
                    isLoading: true,
                    isAction: false,
                    loadingLabel: 'Consultando detalles del caso',
                    child: SizedBox(
                      width: 80,
                      height: 16,
                      child: ColoredBox(color: Color(0xFFE5E5EA)),
                    ),
                  )
                : Text(size),
          ),
          const SizedBox(height: 16),
          MapPanelFact(
            icon: Icons.pets_outlined,
            label: 'Especie',
            value: Text(species),
          ),
          const SizedBox(height: 16),
          MapPanelFact(
            icon: Icons.calendar_today_outlined,
            label: event,
            value: Text(date),
          ),
        ],
      ),
    );
  }
}
