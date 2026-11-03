import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/widgets/brand_map_pin.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../domain/entities/case_journey.dart';

class JourneyMap extends StatelessWidget {
  const JourneyMap({
    required this.value,
    required this.onSelect,
    this.createTileProvider,
    this.controller,
    this.height = 300,
    this.borderRadius = 26,
    this.showAttribution = true,
    this.cameraPadding = const EdgeInsets.all(58),
    super.key,
  });
  final CaseJourney value;
  final ValueChanged<List<JourneyPoint>> onSelect;
  final TileProvider Function()? createTileProvider;
  final MapController? controller;
  final double height, borderRadius;
  final bool showAttribution;
  final EdgeInsets cameraPadding;
  static const originColor = Color(0xFFE45454);
  static const sightingColor = Color(0xFF459FF6);
  @override
  Widget build(BuildContext context) {
    final all = [value.origin, ...value.points];
    LatLng location(JourneyPoint p) => LatLng(p.latitude, p.longitude);
    final groups = <LatLng, List<JourneyPoint>>{};
    for (final point in all) {
      (groups[location(point)] ??= []).add(point);
    }
    return ZoneMapPicker(
      controller: controller,
      latitude: value.origin.latitude,
      longitude: value.origin.longitude,
      radiusMeters: 1000,
      onSelect: null,
      readOnly: true,
      readOnlyNavigation: true,
      showCenterMarker: false,
      showRadius: false,
      compactAttribution: true,
      height: height,
      borderRadius: borderRadius,
      showAttribution: showAttribution,
      cameraPadding: cameraPadding,
      fitPoints: all.map(location).toList(),
      createTileProvider: createTileProvider,
      circles: [
        for (final entry in groups.entries)
          CircleMarker(
            point: entry.key,
            useRadiusInMeter: true,
            radius: 1000,
            color:
                (entry.value.contains(value.origin)
                        ? originColor
                        : sightingColor)
                    .withValues(alpha: .10),
            borderStrokeWidth: 0,
          ),
      ],
      polylines: value.points.isEmpty
          ? []
          : [
              Polyline(
                points: all.map(location).toList(),
                color: sightingColor,
                strokeWidth: 2,
                pattern: StrokePattern.dashed(segments: const [7, 6]),
              ),
            ],
      markers: [
        for (final entry in groups.entries)
          Marker(
            point: entry.key,
            width: BrandMapPin.markerWidth,
            height: BrandMapPin.markerHeight,
            alignment: Alignment.topCenter,
            child: Tooltip(
              message: entry.value
                  .map(
                    (p) => p == value.origin
                        ? 'Origen'
                        : 'Aviso ${value.points.indexOf(p) + 1}',
                  )
                  .join(', '),
              child: BrandMapPin(
                count: entry.value.length,
                color: entry.value.contains(value.origin)
                    ? originColor
                    : sightingColor,
                number: entry.value.contains(value.origin)
                    ? null
                    : value.points.indexOf(entry.value.last) + 1,
                label: entry.value.length > 1
                    ? '${entry.value.length} puntos en esta zona'
                    : entry.value.first == value.origin
                    ? 'Origen de la búsqueda'
                    : 'Aviso ${value.points.indexOf(entry.value.first) + 1}',
                onTap: () => onSelect(entry.value),
              ),
            ),
          ),
      ],
    );
  }
}
