import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/map_case_panel.dart';
import '../../../../core/presentation/widgets/map_case_sheet.dart';
import '../../../../core/presentation/widgets/map_sheet_header.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../domain/entities/case_journey.dart';
import '../view_models/case_journey_view_model.dart';
import '../widgets/journey_map.dart';

class CaseJourneyScreen extends ConsumerStatefulWidget {
  const CaseJourneyScreen({
    required this.target,
    this.createTileProvider,
    super.key,
  });
  final JourneyTarget target;
  final TileProvider Function()? createTileProvider;
  @override
  ConsumerState<CaseJourneyScreen> createState() => _CaseJourneyScreenState();
}

class _CaseJourneyScreenState extends ConsumerState<CaseJourneyScreen> {
  final _sheetExtent = ValueNotifier<double>(.5);
  final _sheet = GlobalKey<MapCaseSheetState>();
  final _map = MapController();
  Set<String> _selectedKeys = {};
  Size? _viewport;

  @override
  void dispose() {
    _sheetExtent.dispose();
    _map.dispose();
    super.dispose();
  }

  void _select(List<JourneyPoint> points) {
    setState(() => _selectedKeys = points.map((point) => point.key).toSet());
    _sheet.currentState?.showSummary();
    final size = _viewport;
    if (size == null || points.isEmpty) return;
    final media = MediaQuery.of(context);
    final selectedExtent = math.max(
      .5,
      ((32 +
                  (_sheet.currentState?.summaryHeight ?? 172) +
                  media.padding.bottom +
                  12) /
              size.height)
          .clamp(.18, .85),
    );
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: [
          for (final point in points) LatLng(point.latitude, point.longitude),
        ],
        padding: EdgeInsets.fromLTRB(
          24,
          media.padding.top + 24,
          24,
          math.min(
            size.height - media.padding.top - 24,
            size.height * selectedExtent + 72,
          ),
        ),
        maxZoom: math.max(_map.camera.zoom, 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = caseJourneyViewModelProvider(widget.target),
        state = ref.watch(provider),
        model = ref.read(provider.notifier);
    ref.listen(provider, (previous, next) {
      if (next.isLoading || next.hasError) {
        _sheetExtent.value = .5;
        _selectedKeys = {};
        _viewport = null;
      }
    });
    final view = state.isLoading || state.hasError ? null : state.asData?.value;
    final value = view?.journey;
    return AppScaffold(
      body: ConfirmationToastHost(
        confirmed: state.hasError || view?.refreshFailed == true,
        isError: true,
        message: state.hasError
            ? 'No pudimos consultar el recorrido. Reintenta.'
            : 'No pudimos actualizar. Se conserva la última consulta.',
        noticeId: (state.error, view?.owner, view?.notice),
        child: PullToRefresh(
          onRefresh: view == null ? null : model.refresh,
          enabled: view?.refreshing != true,
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _sheetExtent.value = notification.extent;
              return false;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (value == null)
                  state.hasError
                      ? Center(
                          child: TextButton(
                            onPressed: model.retry,
                            child: const Text('Reintentar recorrido'),
                          ),
                        )
                      : const LoadingShimmer(
                          isLoading: true,
                          isAction: false,
                          loadingLabel: 'Consultando recorrido',
                          child: ColoredBox(color: Color(0xFFE5E5EA)),
                        )
                else
                  ContentRefresh(
                    refreshing: view!.refreshing,
                    label: 'Actualizando recorrido',
                    child: MapCaseSheet(
                      key: _sheet,
                      hasSelection: true,
                      scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      mapBuilder: (constraints, summaryHeight) {
                        _viewport = constraints.biggest;
                        final media = MediaQuery.of(context);
                        return JourneyMap(
                          value: value,
                          controller: _map,
                          height: constraints.maxHeight,
                          borderRadius: 0,
                          showAttribution: false,
                          cameraPadding: EdgeInsets.fromLTRB(
                            24,
                            media.padding.top + 76,
                            24,
                            constraints.maxHeight * .5 + 16,
                          ),
                          createTileProvider: widget.createTileProvider,
                          onSelect: _select,
                        );
                      },
                      panelBuilder: (onSummaryHeight) => MapCasePanel(
                        name: value.summary.name,
                        traits: value.summary.traits,
                        photoUri: value.summary.photoUri,
                        scrollable: false,
                        decorativeActions: true,
                        sectionTitle: 'Ubicaciones',
                        onSummaryHeight: onSummaryHeight,
                        details: Column(
                          key: const ValueKey('journey-locations'),
                          children: [
                            for (
                              var index = 0;
                              index <= value.points.length;
                              index++
                            )
                              _LocationRow(
                                isLast: index == value.points.length,
                                point: index == 0
                                    ? value.origin
                                    : value.points[index - 1],
                                number: index,
                                selected: _selectedKeys.contains(
                                  (index == 0
                                          ? value.origin
                                          : value.points[index - 1])
                                      .key,
                                ),
                                onTap: () => _select([
                                  index == 0
                                      ? value.origin
                                      : value.points[index - 1],
                                ]),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                MapSheetHeader(
                  title: 'Recorrido',
                  backTooltip: 'Volver a la ficha',
                  extent: _sheetExtent,
                  onBack: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.point,
    required this.number,
    required this.isLast,
    required this.selected,
    required this.onTap,
  });
  final JourneyPoint point;
  final int number;
  final bool selected, isLast;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final style = MapPanelFact.labelStyle;
    final anchor = math.max(
      7.0,
      MediaQuery.textScalerOf(context).scale(style.fontSize!) *
          style.height! /
          2,
    );
    final color = number == 0
        ? JourneyMap.originColor
        : JourneyMap.sightingColor;
    return CustomPaint(
      foregroundPainter: _LocationConnector(
        anchor: anchor,
        first: number == 0,
        last: isLast,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
        child: Material(
          color: selected ? const Color(0xFFE8F3FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: MapPanelFact(
              leading: SizedBox(
                width: 22,
                child: Padding(
                  padding: EdgeInsets.only(top: anchor - 7),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              label: number == 0
                  ? 'Origen'
                  : point.inCustody
                  ? 'Está con quien la encontró'
                  : 'Avistamiento $number',
              value: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(caseDateTimeLabel(point.time))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationConnector extends CustomPainter {
  const _LocationConnector({
    required this.anchor,
    required this.first,
    required this.last,
  });
  final double anchor;
  final bool first, last;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E5EA)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (var y = 0.0; y < size.height; y += 5) {
      final end = math.min(y + 2, size.height);
      if ((!first && end <= anchor - 7) || (!last && y >= anchor + 7)) {
        canvas.drawLine(Offset(11, y), Offset(11, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LocationConnector oldDelegate) =>
      anchor != oldDelegate.anchor ||
      first != oldDelegate.first ||
      last != oldDelegate.last;
}
