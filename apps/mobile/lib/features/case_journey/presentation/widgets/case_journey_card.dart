import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/case_action_button.dart';
import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/theme/case_card_typography.dart';
import '../../../../core/presentation/widgets/case_public_cards.dart';
import '../../domain/entities/case_journey.dart';
import '../view_models/case_journey_view_model.dart';

String journeyDate(DateTime value) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]} · ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

class CaseJourneyCard extends ConsumerWidget {
  const CaseJourneyCard({required this.target, super.key});
  final JourneyTarget target;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = caseJourneyViewModelProvider(target),
        state = ref.watch(provider);
    if (state.isLoading) return const SkeletonFormFields(fieldCount: 2);
    if (state.hasError) {
      return ConfirmationToastHost(
        confirmed: true,
        message: 'No pudimos consultar el recorrido. Reintenta.',
        noticeId: state.error,
        isError: true,
        child: TextButton(
          onPressed: ref.read(provider.notifier).retry,
          child: const Text('Reintentar recorrido'),
        ),
      );
    }
    final value = state.requireValue;
    return ConfirmationToastHost(
      confirmed: value.refreshFailed,
      isError: true,
      noticeId: (value.owner, value.notice),
      message:
          'No pudimos actualizar el recorrido. Se conserva la última consulta.',
      actionLabel: 'Reintentar',
      onAction: ref.read(provider.notifier).refresh,
      child: ContentRefresh(
        refreshing: value.refreshing,
        label: 'Actualizando recorrido',
        child: JourneySummaryCard(
          value: value.journey,
          onReturn: ref.read(provider.notifier).refresh,
        ),
      ),
    );
  }
}

class JourneySummaryCard extends StatelessWidget {
  JourneySummaryCard({required this.value, this.onReturn, super.key});
  final CaseJourney value;
  final VoidCallback? onReturn;
  final _surface = GlobalKey();
  static const art = 'assets/illustrations/case-journey.webp';
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Abrir recorrido de la búsqueda. ${value.countLabel}',
    child: GlassSurface.card(
      key: _surface,
      radius: CasePublicGlassCard.radius,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(CasePublicGlassCard.radius),
          onTap: () async {
            await pushCaseControl(
              context,
              '/home/journey/${value.target.community ? 'found' : 'lost'}/${value.target.id}',
              _surface,
              color: GlassSurface.originColor,
              radius: CasePublicGlassCard.radius,
              identity: JourneySummaryContent(value: value),
            );
            if (context.mounted) onReturn?.call();
          },
          child: JourneySummaryContent(value: value),
        ),
      ),
    ),
  );
}

class _DateFact extends StatelessWidget {
  const _DateFact(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: CaseCardTypography.label),
      const SizedBox(height: CasePublicGlassCard.factSpacing),
      Text(value, style: CaseCardTypography.value),
    ],
  );
}

class JourneySummaryContent extends StatelessWidget {
  const JourneySummaryContent({required this.value, super.key});
  final CaseJourney value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: CasePublicGlassCard.contentPadding,
    child: LayoutBuilder(
      builder: (context, c) {
        final large = MediaQuery.textScalerOf(context).scale(16) > 22;
        final image = Image.asset(
          JourneySummaryCard.art,
          width: large ? 154 : c.maxWidth * .36,
          excludeFromSemantics: true,
          filterQuality: FilterQuality.high,
        );
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: large ? 0 : 72),
              child: const Text(
                'Recorrido de la búsqueda',
                style: CaseCardTypography.value,
              ),
            ),
            const SizedBox(height: CasePublicGlassCard.factSpacing),
            Text(value.countLabel, style: CaseCardTypography.label),
          ],
        );
        final dates = [
          _DateFact('Inicio de la búsqueda', journeyDate(value.origin.time)),
          _DateFact(
            'Último aviso',
            value.latest == null
                ? 'Sin avisos todavía'
                : journeyDate(value.latest!),
          ),
        ];
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (large) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 72),
                    child: Align(alignment: Alignment.centerLeft, child: image),
                  ),
                  const SizedBox(height: CasePublicGlassCard.spacing),
                  title,
                ] else
                  Row(
                    children: [
                      image,
                      const SizedBox(width: CasePublicGlassCard.spacing),
                      Expanded(child: title),
                    ],
                  ),
                const SizedBox(height: CasePublicGlassCard.spacing),
                if (large) ...[
                  dates[0],
                  const SizedBox(height: CasePublicGlassCard.spacing),
                  dates[1],
                ] else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: dates[0]),
                        const VerticalDivider(
                          width: CasePublicGlassCard.spacing,
                        ),
                        Expanded(child: dates[1]),
                      ],
                    ),
                  ),
              ],
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: ExcludeSemantics(
                child: SizedBox.square(
                  dimension: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF171918),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.north_east_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
