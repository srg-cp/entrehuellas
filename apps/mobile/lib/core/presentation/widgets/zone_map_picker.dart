import 'confirmation_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/map_config.dart';
import 'map_attribution.dart';
import 'map_style.dart';
import 'loading_shimmer.dart';
import 'brand_map_pin.dart';

/// Visual map adapter only. The ViewModel owns the selected product coordinates.
class ZoneMapPicker extends StatefulWidget {
  static const viewportHeight = 280.0;
  const ZoneMapPicker({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.onSelect,
    this.createTileProvider,
    this.readOnly = false,
    this.fitRadius = false,
    this.showCenterMarker = true,
    this.showRadius = true,
    this.showAttribution = true,
    this.compactAttribution = false,
    this.attributionTopInset = 0,
    this.readOnlyNavigation = false,
    this.markers = const [],
    this.polylines = const [],
    this.circles = const [],
    this.fitPoints = const [],
    this.markerLayer,
    this.height = viewportHeight,
    this.borderRadius = 22,
    this.cameraPadding = const EdgeInsets.all(24),
    this.controller,
    this.onMapTap,
    super.key,
  });
  final double? latitude;
  final double? longitude;
  final int radiusMeters;
  final bool readOnly, showCenterMarker, fitRadius, showRadius;
  final double attributionTopInset;
  final bool showAttribution;
  final bool compactAttribution;

  /// Result maps can be explored without changing the selected search center.
  final bool readOnlyNavigation;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final List<CircleMarker> circles;
  final List<LatLng> fitPoints;

  /// Optional visual layer for result maps with camera-dependent placement.
  final Widget? markerLayer;
  final double height;
  final double borderRadius;
  final EdgeInsets cameraPadding;
  final MapController? controller;
  final VoidCallback? onMapTap;
  final void Function(double latitude, double longitude)? onSelect;
  final TileProvider Function()? createTileProvider;
  @override
  State<ZoneMapPicker> createState() => _ZoneMapPickerState();
}

class _ZoneMapPickerState extends State<ZoneMapPicker> {
  late final _controller = widget.controller ?? MapController();
  late TileProvider _tiles;
  TileProvider _createTiles() =>
      widget.createTileProvider?.call() ?? NetworkTileProvider();
  @override
  void initState() {
    super.initState();
    _tiles = _createTiles();
  }

  bool _mapReady = false;
  void _fitSelection() {
    if (_mapReady && widget.fitPoints.isNotEmpty) {
      _controller.fitCamera(
        CameraFit.coordinates(
          coordinates: widget.fitPoints,
          padding: widget.cameraPadding,
          maxZoom: 13,
        ),
      );
      return;
    }
    if (!_mapReady ||
        !widget.fitRadius ||
        widget.latitude == null ||
        widget.longitude == null) {
      return;
    }
    final center = LatLng(widget.latitude!, widget.longitude!);
    final distance = const Distance();
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: [0.0, 90.0, 180.0, 270.0]
            .map(
              (bearing) => distance.offset(
                center,
                widget.radiusMeters.toDouble(),
                bearing,
              ),
            )
            .toList(),
        padding: widget.cameraPadding,
        maxZoom: 16,
      ),
    );
  }

  @override
  void didUpdateWidget(ZoneMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pointChanged =
        widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude;
    if (!listEquals(widget.fitPoints, oldWidget.fitPoints)) {
      _fitSelection();
    }
    if (widget.fitRadius &&
        (pointChanged ||
            widget.radiusMeters != oldWidget.radiusMeters ||
            !oldWidget.fitRadius)) {
      _fitSelection();
    } else if (pointChanged &&
        _mapReady &&
        widget.latitude != null &&
        widget.longitude != null) {
      _controller.move(
        LatLng(widget.latitude!, widget.longitude!),
        _controller.camera.zoom,
      );
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  bool _failed = false;
  int _attempt = 0;
  void _failure(int attempt) {
    if (_failed || attempt != _attempt) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_failed && attempt == _attempt) {
        setState(() => _failed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attempt = _attempt;
    final tiles = TileLayer(
      urlTemplate: MapConfig.displayTileUrl,
      retinaMode:
          MapConfig.displayTileUrl.contains('{r}') &&
          RetinaMode.isHighDensity(context),
      tileProvider: _tiles,
      userAgentPackageName: 'com.example.flutter_application_entrehuellas',
      panBuffer: 0,
      errorTileCallback: (_, _, _) => _failure(attempt),
      tileBuilder: (context, child, tile) => LoadingShimmer(
        isLoading:
            tile.loadStarted != null &&
            tile.imageInfo == null &&
            !tile.loadError &&
            !tile.cancelLoading.isCompleted,
        isAction: false,
        radius: 0,
        loadingLabel: 'Consultando mapa',
        child: child,
      ),
    );
    final point = widget.latitude == null || widget.longitude == null
        ? null
        : LatLng(widget.latitude!, widget.longitude!);
    return ConfirmationToastHost(
      confirmed: _failed,
      message: 'No se pudo mostrar el mapa. Reintenta.',
      noticeId: _attempt,
      isError: true,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: SizedBox(
              height: widget.height,
              child: FlutterMap(
                mapController: _controller,
                key: ValueKey(_attempt),
                options: MapOptions(
                  onMapReady: () {
                    _mapReady = true;
                    _fitSelection();
                  },
                  initialCenter: point ?? const LatLng(-12.0464, -77.0428),
                  initialZoom: 12,
                  interactionOptions: InteractionOptions(
                    flags: widget.readOnly && !widget.readOnlyNavigation
                        ? InteractiveFlag.none
                        : InteractiveFlag.all,
                  ),
                  minZoom: 3,
                  maxZoom: 18,
                  backgroundColor: MapStyle.background,
                  onTap: (_, location) {
                    widget.onMapTap?.call();
                    if (!_failed && !widget.readOnly) {
                      widget.onSelect?.call(
                        location.latitude,
                        location.longitude,
                      );
                    }
                  },
                ),
                children: [
                  ColorFiltered(
                    colorFilter: MapStyle.tileColorFilter,
                    child: tiles,
                  ),
                  if (point != null && widget.showRadius)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: point,
                          radius: widget.radiusMeters.toDouble(),
                          useRadiusInMeter: true,
                          color: const Color(0x22111111),
                          borderColor: const Color(0xFF111111),
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  if (point != null && widget.showCenterMarker)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: BrandMapPin.markerWidth,
                          height: BrandMapPin.markerHeight,
                          alignment: Alignment.center,
                          child: const BrandMapPin(color: Color(0xFF111111)),
                        ),
                      ],
                    ),
                  if (widget.circles.isNotEmpty)
                    CircleLayer(circles: widget.circles),
                  if (widget.polylines.isNotEmpty)
                    PolylineLayer(polylines: widget.polylines),
                  if (widget.markerLayer != null)
                    widget.markerLayer!
                  else if (widget.markers.isNotEmpty)
                    MarkerLayer(markers: widget.markers),
                ],
              ),
            ),
          ),
          if ((MapConfig.usesCarto && widget.showAttribution) || _failed)
            Positioned(
              top: widget.compactAttribution
                  ? null
                  : widget.borderRadius == 0
                  ? MediaQuery.paddingOf(context).top +
                        8 +
                        widget.attributionTopInset
                  : 8,
              bottom: widget.compactAttribution ? 4 : null,
              left: MapConfig.usesCarto && !widget.compactAttribution ? 76 : 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (MapConfig.usesCarto && widget.showAttribution)
                    MapAttribution(compact: widget.compactAttribution),
                  if (_failed)
                    TextButton(
                      onPressed: () => setState(() {
                        _failed = false;
                        _mapReady = false;
                        _attempt++;
                        _tiles = _createTiles();
                      }),
                      child: const Text('Reintentar mapa'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
