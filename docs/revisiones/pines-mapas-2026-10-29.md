# Pines de los mapas: revisión del 29/10/2026

Estado del código local en main tras [ADR-165](../decisiones/165-pines-con-logo-compartidos-mobile-web.md):
los pines internos comparten silueta y logo oficial; se conserva el punto azul
de ficha pública. No acredita la versión instalada. El mapa base permite ocultar
el pin central y suministrar capas; sus consumidores deben respetar esta regla.

| Dónde aparece | Diseño actual | Coincidencia |
| --- | --- | --- |
| Móvil: Perfil → Ubicaciones de interés; formularios de pérdida propia/comunitaria y hallazgo; filtro Ubicación de Explorar; registrar avistamiento y revisar su evidencia privada | BrandMapPin negro #111111 con logo blanco, 48×56, centrado sobre la coordenada. | Todos usan el mismo componente. El radio cambia según operación. |
| Web: Reportar, avistamiento desde QR y ficha del caso de recuperación/coincidencias | SVG equivalente del pin negro/logo blanco, 48×56 y anclaje central24/28. | Coincide con silueta, logo y tamaño del selector móvil. Todos usan LocationMap. |
| Móvil: mapa de resultados de Explorar | BrandMapPin 48×48 con logo oficial de30; blanco/logo negro, seleccionado negro/logo blanco. | Mismo renderer que selectores y Recorrido; estados/proporciones de Explorar conservados. |
| Móvil: Recorrido de la búsqueda | Silueta con logo oficial blanco de 27, contenedor 48×56; origen rojo #E45454, avisos azules #459FF6, numeración y contador si comparten coordenada. | Comparte silueta y marca con Explorar; cambian proporciones, tamaño del logo, colores e insignias. |
| Móvil: ficha pública actual y vistas previas de pérdida propia/comunitaria que reutilizan CasePublicCards | Punto azul #2887EF con borde blanco y halo azul, conjunto 72×72; no tiene silueta de pin ni logo. | Excepción explícita conservada en todos los consumidores de CasePublicCards. |
| Móvil: Ficha fotográfica inmersiva conservada, ImmersivePhotoSheet | Pin central oculto, círculo de zona aproximada de 1 km. | No dibuja un pin que comparar. |

Explorar web ofrece lista, sin mapa de resultados equivalente al móvil. El lector
público QR enlaza «Ver área aproximada» a Google Maps; sus marcadores pertenecen
a ese servicio externo. Los mapas ilustrados de Inicio/landing no son mapas
interactivos de datos y sus dibujos no pertenecen al sistema de pines.

## Estados conservados y regla actual

ADR-165 sustituye el pin Material anterior de
[ADR-129](../decisiones/129-paridad-visual-de-mapas-mobile-web.md). Explorar
conserva sus estados con marca de [ADR-062](../decisiones/062-pines-de-marca-y-vista-previa-publica.md)
y Recorrido sus colores/numeración de
[ADR-153](../decisiones/153-acciones-y-recorrido-de-busqueda-mobile.md).
Las variaciones ahora expresan selección y tipo de punto sobre una marca común;
el punto azul se conserva por excepción explícita del usuario.

## Fuentes revisadas

- [Pin estándar móvil y adaptador](../../apps/mobile/lib/core/presentation/widgets/zone_map_picker.dart).
- [Ubicaciones de interés](../../apps/mobile/lib/features/interest_zones/presentation/widgets/zone_editor.dart), [campos de reportes](../../apps/mobile/lib/core/presentation/widgets/case_location_fields.dart), [filtro de Explorar](../../apps/mobile/lib/features/explore/presentation/widgets/explore_filter_editor.dart), [avistamientos](../../apps/mobile/lib/features/sightings/presentation/screens/sighting_screen.dart) y [revisión privada](../../apps/mobile/lib/features/case_timeline/presentation/screens/sighting_review_screen.dart).
- [Pin de Explorar](../../apps/mobile/lib/features/explore/presentation/widgets/explore_map_pin.dart) y [capa de resultados](../../apps/mobile/lib/features/explore/presentation/widgets/explore_map_pins.dart).
- [Pin de marca](../../apps/mobile/lib/core/presentation/widgets/brand_map_pin.dart) y [mapa de Recorrido](../../apps/mobile/lib/features/case_journey/presentation/widgets/journey_map.dart).
- [Punto azul de ficha pública](../../apps/mobile/lib/core/presentation/widgets/case_public_cards.dart) y [ficha inmersiva](../../apps/mobile/lib/core/presentation/widgets/immersive_photo_sheet.dart).
- [Adaptador web](../../apps/platform/app/components/LocationMap.vue), [SVG web](../../apps/platform/public/map-location-pin.svg), [Reportar](../../apps/platform/app/features/recovery/presentation/screens/RecoveryScreen.vue), [avistamientos QR](../../apps/platform/app/features/sightings/presentation/widgets/SightingMap.vue), [ficha de recuperación](../../apps/platform/app/features/recovery/presentation/screens/PublicationScreen.vue) y [lector QR](../../apps/platform/app/features/case_reader/presentation/screens/CaseReader.vue).
