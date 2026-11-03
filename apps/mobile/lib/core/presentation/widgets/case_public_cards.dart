import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'expandable_description.dart';
import 'glass_surface.dart';
import 'stagger_reveal.dart';
import 'zone_map_picker.dart';
import 'case_photo_viewer.dart';
import '../../theme/case_card_typography.dart';

const casePublicationPrivacyNotice =
    'Ubicación pública aproximada de unos 1 km. El punto exacto y la referencia permanecen privados. Al publicar, estos datos y fotos serán públicos; revisa que no contengan domicilio, documentos ni datos personales.';

class CasePublicFact {
  const CasePublicFact(this.label, this.value);
  final String label, value;
}

/// Public projection only: features supply metadata and authorized real actions.
/// The previous full-screen design remains in ImmersivePhotoSheet.
class CasePublicCards extends StatelessWidget {
  const CasePublicCards({
    required this.name,
    required this.eventLabel,
    required this.photos,
    required this.facts,
    required this.description,
    required this.occurredAt,
    required this.latitude,
    required this.longitude,
    this.actions,
    this.contact,
    this.privacy,
    this.createMapTileProvider,
    this.offline = false,
    super.key,
  });

  final String name, eventLabel, description, occurredAt;
  final List<Widget> photos;
  final List<CasePublicFact> facts;
  final double latitude, longitude;
  final Widget? actions;
  final Widget? contact;
  final String? privacy;
  final bool offline;
  final TileProvider Function()? createMapTileProvider;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StaggerRevealItem(
        order: 0,
        child: _CasePhotoCard(
          name: name,
          eventLabel: eventLabel,
          photos: photos,
        ),
      ),
      const SizedBox(height: 12),
      if (contact != null)
        StaggerRevealItem(order: 1, preserveBackdrop: true, child: contact!),
      StaggerRevealItem(
        order: 2,
        preserveBackdrop: true,
        child: CasePublicGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final single =
                      MediaQuery.textScalerOf(context).scale(16) > 22;
                  return Wrap(
                    spacing: CasePublicGlassCard.spacing,
                    runSpacing: CasePublicGlassCard.spacing,
                    children: [
                      for (final fact in facts)
                        SizedBox(
                          width: single
                              ? constraints.maxWidth
                              : (constraints.maxWidth -
                                        CasePublicGlassCard.spacing) /
                                    2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fact.label, style: CaseCardTypography.label),
                              const SizedBox(
                                height: CasePublicGlassCard.factSpacing,
                              ),
                              Text(fact.value, style: CaseCardTypography.value),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (description.trim().isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0x1F454746)),
                ),
                const Text('Rasgos', style: CaseCardTypography.label),
                const SizedBox(height: 4),
                ExpandableDescription(text: description),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      StaggerRevealItem(
        order: 3,
        preserveBackdrop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xB3FFFFFF),
                borderRadius: BorderRadius.circular(34),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      if (offline)
                        SizedBox(
                          height: math.max(
                            constraints.maxWidth / 1.35,
                            MediaQuery.textScalerOf(context).scale(140),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.map_outlined,
                              size: 48,
                              semanticLabel: 'Mapa disponible al conectar',
                            ),
                          ),
                        )
                      else
                        ZoneMapPicker(
                          latitude: latitude,
                          longitude: longitude,
                          radiusMeters: 1000,
                          onSelect: null,
                          readOnly: true,
                          compactAttribution: true,
                          fitRadius: true,
                          showRadius: false,
                          showCenterMarker: false,
                          markers: [
                            Marker(
                              point: LatLng(latitude, longitude),
                              width: 72,
                              height: 72,
                              child: Semantics(
                                label: 'Ubicación pública aproximada',
                                child: Container(
                                  padding: const EdgeInsets.all(23),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0x30459FF6),
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF2887EF),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          height: math.max(
                            constraints.maxWidth / 1.35,
                            MediaQuery.textScalerOf(context).scale(140),
                          ),
                          borderRadius: 28,
                          createTileProvider: createMapTileProvider,
                        ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 32,
                        child: IgnorePointer(
                          child: Center(
                            child: GlassSurface(
                              radius: 28,
                              finish: GlassSurfaceFinish.polished,
                              showRim: true,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      size: 16,
                                      color: Color(0xFF171918),
                                    ),
                                    SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Ubicación',
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.2,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF171918),
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
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(occurredAt, style: CaseCardTypography.label),
            ),
          ],
        ),
      ),
      if (privacy != null || actions != null) ...[
        const SizedBox(height: 16),
        StaggerRevealItem(
          order: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (privacy != null) ...[
                Text(privacy!, style: CaseCardTypography.label),
                const SizedBox(height: 16),
              ],
              if (actions != null) actions!,
            ],
          ),
        ),
      ],
    ],
  );
}

/// Shared pearl material, matching Home and the other glass surfaces.
class CasePublicGlassCard extends StatelessWidget {
  const CasePublicGlassCard({required this.child, super.key});
  static const radius = 28.0;
  static const contentPadding = EdgeInsets.all(18);
  static const spacing = 16.0;
  static const factSpacing = 3.0;
  final Widget child;

  @override
  Widget build(BuildContext context) => GlassSurface.card(
    radius: radius,
    backdropBlendMode: BlendMode.src,
    child: Padding(padding: contentPadding, child: child),
  );
}

class _CasePhotoCard extends StatefulWidget {
  const _CasePhotoCard({
    required this.name,
    required this.eventLabel,
    required this.photos,
  });
  final String name, eventLabel;
  final List<Widget> photos;

  @override
  State<_CasePhotoCard> createState() => _CasePhotoCardState();
}

class _CasePhotoCardState extends State<_CasePhotoCard> {
  int _photo = 0;

  @override
  void didUpdateWidget(_CasePhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name ||
        oldWidget.photos.length != widget.photos.length) {
      _photo = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 22;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: largeText ? .7 : 1.05,
            child: ColoredBox(
              color: const Color(0xFFDCE1E7),
              child: widget.photos.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.pets_outlined,
                        size: 56,
                        color: Color(0xFF626975),
                        semanticLabel: 'Sin foto pública',
                      ),
                    )
                  : Semantics(
                      button: true,
                      label: 'Abrir foto completa de ${widget.name}',
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          PageRouteBuilder<void>(
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CasePhotoViewer(
                                      photos: widget.photos,
                                      initialPhoto: _photo,
                                    ),
                          ),
                        ),
                        child: PageView(
                          key: ValueKey((widget.name, widget.photos.length)),
                          onPageChanged: (index) =>
                              setState(() => _photo = index),
                          children: widget.photos,
                        ),
                      ),
                    ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xB3000000),
                    ],
                    stops: [0, .45, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: IgnorePointer(
              child: _CasePhotoCaption(
                name: widget.name,
                eventLabel: widget.eventLabel,
                photo: _photo,
                photoCount: widget.photos.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CasePhotoCaption extends StatelessWidget {
  const _CasePhotoCaption({
    required this.name,
    required this.eventLabel,
    required this.photo,
    required this.photoCount,
  });
  final String name, eventLabel;
  final int photo, photoCount;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const badgeStyle = TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
      final measure = TextPainter(
        text: TextSpan(text: eventLabel, style: badgeStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final stack =
          MediaQuery.textScalerOf(context).scale(16) > 22 ||
          measure.width + 24 > constraints.maxWidth * .5;
      measure.dispose();
      final title = Text(
        name,
        key: const ValueKey('public-case-photo-name'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 48,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Color(0x33000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      );
      final badge = Container(
        key: const ValueKey('public-case-photo-status'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xD9C35C68),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(eventLabel, style: badgeStyle),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stack) ...[
            title,
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: badge),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: title),
                const SizedBox(width: 12),
                badge,
              ],
            ),
          const SizedBox(height: 8),
          Center(
            child: photoCount <= 1
                ? const SizedBox(height: 6)
                : Semantics(
                    label: 'Foto ${photo + 1} de $photoCount',
                    child: Row(
                      key: const ValueKey('public-case-photo-pagination'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < photoCount; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == photo
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    },
  );
}
