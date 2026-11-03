import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/collection_empty_state.dart';
import '../../../../core/presentation/widgets/map_case_sheet.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';
import 'explore_map_pins.dart';
import 'explore_map_case_preview.dart';

class ExploreCaseMap extends StatefulWidget {
  const ExploreCaseMap({
    required this.items,
    required this.query,
    required this.onOpen,
    this.trailing = const [],
    this.emptyMessage,
    this.createTileProvider,
    this.previewBuilder,
    super.key,
  });
  final List<ExploreCase> items;
  final ExploreQuery query;
  final void Function(ExploreCase, BuildContext)? onOpen;
  final List<Widget> trailing;
  final String? emptyMessage;
  final TileProvider Function()? createTileProvider;
  final Widget Function(ExploreCase, ValueChanged<double>)? previewBuilder;
  @override
  State<ExploreCaseMap> createState() => _ExploreCaseMapState();
}

class _ExploreCaseMapState extends State<ExploreCaseMap> {
  final _sheet = GlobalKey<MapCaseSheetState>();
  final _map = MapController();
  String? _selectedCaseKey;
  @override
  void didUpdateWidget(covariant ExploreCaseMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.query, widget.query)) {
      _selectedCaseKey = null;
      final query = widget.query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && identical(widget.query, query)) {
          _sheet.currentState?.showSummary(resetScroll: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items
        .where((item) => item.key == _selectedCaseKey)
        .firstOrNull;
    final media = MediaQuery.of(context);
    return MapCaseSheet(
      key: _sheet,
      hasSelection: item != null,
      showAttribution:
          widget.query.latitude != null && widget.query.longitude != null,
      mapBuilder: (constraints, summaryHeight) {
        void select(ExploreCase selected) {
          final selectedExtent = math.max(
            .5,
            ((32 + summaryHeight + media.padding.bottom + 12) /
                    constraints.maxHeight)
                .clamp(.18, .85),
          );
          setState(() => _selectedCaseKey = selected.key);
          _sheet.currentState?.showSummary();
          _map.fitCamera(
            CameraFit.coordinates(
              coordinates: [LatLng(selected.latitude, selected.longitude)],
              padding: EdgeInsets.fromLTRB(
                24,
                media.padding.top + 24,
                24,
                math.min(
                  constraints.maxHeight - media.padding.top - 24,
                  constraints.maxHeight * selectedExtent + 72,
                ),
              ),
              maxZoom: math.max(_map.camera.zoom, 15),
            ),
          );
        }

        if (widget.query.latitude == null || widget.query.longitude == null) {
          return const ColoredBox(color: Color(0xFFF5F5F7));
        }
        return ZoneMapPicker(
          controller: _map,
          latitude: widget.query.latitude,
          longitude: widget.query.longitude,
          radiusMeters: widget.query.radiusMeters ?? 15000,
          onSelect: null,
          onMapTap: () => setState(() => _selectedCaseKey = null),
          readOnly: true,
          readOnlyNavigation: true,
          fitRadius: true,
          showCenterMarker: false,
          showRadius: false,
          showAttribution: false,
          createTileProvider: widget.createTileProvider,
          height: constraints.maxHeight,
          borderRadius: 0,
          cameraPadding: EdgeInsets.fromLTRB(
            24,
            media.padding.top + 76,
            24,
            constraints.maxHeight * .5 + 16,
          ),
          markerLayer: ExploreMapPins(
            items: widget.items,
            selectedKey: _selectedCaseKey,
            onSelect: select,
          ),
        );
      },
      panelBuilder: (onSummaryHeight) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CollectionEmptyState(
                title: widget.items.isNotEmpty
                    ? 'Selecciona un pin'
                    : widget.emptyMessage != null
                    ? 'Explora los casos cercanos'
                    : 'No encontramos casos',
                description: widget.items.isNotEmpty
                    ? 'Selecciona un pin para ver el resumen del caso.'
                    : widget.emptyMessage ??
                          'Prueba con otra ubicación o ajusta los filtros de búsqueda.',
              ),
            )
          else
            widget.previewBuilder?.call(item, onSummaryHeight) ??
                ExploreMapPreviewContent(
                  item: item,
                  scrollable: false,
                  onSummaryHeight: onSummaryHeight,
                  onOpen: widget.onOpen == null
                      ? null
                      : (source) => widget.onOpen!(item, source),
                ),
          ...widget.trailing,
        ],
      ),
    );
  }
}
