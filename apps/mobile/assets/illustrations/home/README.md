# Ilustraciones de Inicio —26/10/2026

Guía reutilizable para variantes móviles/web:
[GUIA_ILUSTRACIONES.md](../../../../../docs/GUIA_ILUSTRACIONES.md).
Incluye roles/orden de referencias y las bases de edición archivadas; los
prompts literales de esta entrega permanecen a continuación.

Generadas individualmente con **imagegen integrado** a partir de la referencia
visual aprobada en `output/imagegen/home-scroll-propuesta-v3-2026-10-25`.
Se consultaron las mascotas reales de Platform (`hero-dog.png`, `hero-cat.png`
y `dog-report.png`) para la corrección solicitada: personajes 3D de cabezas/ojos
grandes, hocicos cortos y formas redondeadas. Los escenarios se conservan.

Los originales generados se convierten a WebP con sharp ya instalado en Platform,
calidad90, alfa100 y reducción al ancho de uso; sin retoques de estilo con código.
Se comprueban dimensiones, canal alfa y esquinas transparentes.

- `report-reunion.webp`: fondo del banner de Reportar; opaco,1024×1024.
- `found-home.webp`: perro y puerta; alfa real,1024×683.
- `photo-search.webp`: dos fotografías **ilustrativas**; alfa real,720×540.
- `explore-map.webp`: fondo decorativo,1024×683, sin datos geográficos reales,
  teselas, pines ni solicitudes de red. Flutter superpone el símbolo oficial
  existente. Los mapas interactivos siguen usando el adaptador compartido.

No contienen etiquetas, controles ni flechas; se componen con widgets accesibles.
Las fotografías ilustrativas no representan resultados, cuentas o casos reales.
Las imágenes anteriores de comunidad se conservan para sus otros consumidores.

# Prompts finales

## Reportar: perro y gato

```text
Use case: style-transfer / precise character edit for production Flutter asset.
Image1 is EDIT TARGET, a square pale-blue room with German shepherd puppy and Siamese kitten. Images2 and3 are the ACTUAL approved Entre Huellas Platform character assets and must define the exact animal style.
Change ONLY the TWO ANIMALS in Image1 to match those Platform mascots. Preserve the room, blanket, plant, window, depth of field, illumination, shadows, camera composition and all background pixels as closely as possible. Keep left40% clear for native Flutter text, subjects on right as now, exact canvas size/framing. User explicitly approves scenery; do not redesign it.
ANIMAL STYLE: recognizable same German shepherd fromImage2 and Siamese fromImage3, animated family-film mascots rather than realistic pets. Larger rounded heads relative to compact bodies, very large glossy expressive eyes with broad warm irises and clear sclera, tiny short rounded muzzles, small smooth nose, soft toy-like oversized paws, cheeky happy gentle expressions. Simplified plush rounded fur clumps with soft short velvet detail; avoid individual coarse hair strands, long realistic whiskers, skin pores or realistic canine anatomy. Same warm coat colors/breed identity asImage1, but stronger cartoon proportions ofImages2/3. Preserve poses and approximate sizes so original composition works. Both keep BLACK bandanas with the small WHITE official paw-location emblem; do not copy green/navy bandana colors from style references.
Must be meaningfully more stylized, rounded and cute thanImage1. Not flat2D, not plastic/rubbery: premium dimensional illustrated characters matching actual Platform art.
No text, interface, buttons, arrows, border or other additions. Background and scenery unchanged.
```

## Hallazgo: perro y puerta

```text
Use case: style-transfer / precise character edit for production Flutter asset.
Image1 is EDIT TARGET: transparent puppy next to open blue door. Image2 is the actual approved Entre Huellas Platform brown-and-white mascot pair, STYLE REFERENCE for proportions and friendly character design. Image3 approved mobile layout defines intended small dog character (not a UI to reproduce).
Change ONLY THE DOG ofImage1. Keep the blue doorway, open angle, knob, light through the doorway, shadows/halo, subject position, framing and transparent background unchanged. The user explicitly loves the scenery and wants ONLY animals less realistic.
Rebuild dog as a strongly stylized 3D ANIMATED MASCOT matching Image2: large rounded head approx45% of entire standing height, shorter compact little body and shorter legs, oversized rounded plush paws, very large glossy amber/brown eyes with broad white sclera, expressive curved eyebrows, soft inflated cheeks, very short tiny rounded muzzle with small smooth black nose. Friendly cheerful happy open-mouth expression. Keep cream-and-caramel floppy-eared breed/coat and black neckwear with white official paw-location mark fromImage1. Simplify coat into soft velvety rounded tufts instead of the realistic dense long wavy strands inImage1. MUST NOT resemble a photo of a real cockapoo; no realistic adult proportions, long muzzle, pores or intricate flyaway hairs. Also not plastic figurine and not flat vector: match the same premium soft dimensional animated mascot family asImage2. Dog keeps four paws standing on same ground and tail curling behind, at same approximate location relative to door.
No changes to door or surroundings, no added objects, text, button, UI, framing or logos outside neckwear. Preserve real transparent alpha all around.
```

## Buscar con una foto

```text
Use case: illustration-story.
Production asset for Flutter photo-search shortcut, not a UI screenshot. Recreate ONLY the pair of overlapping small white-bordered pet picture prints shown in the Buscar con una foto card of Image1. Image2 defines the friendly Entre Huellas character style.
Two slightly tilted square photo-paper prints overlap like a small stack, left print in front rotated slightly counterclockwise, right print behind slightly clockwise. Each contains a different pose/view of a warm caramel and cream puppy, friendly large glossy eyes, round oversized head, short soft muzzle, plush rounded paws, gentle animated mascot expression matching Platform character style inImage2. Dimensional premium 3D cartoon illustration, not realistic dog photography. Soft green/blue blurred garden backgrounds INSIDE each picture; WHITE paper borders, clean edges, gentle short shadow.
Entire two-print stack isolated on REAL TRANSPARENT BACKGROUND, centered generous5% margin, no rectangle around the stack. Landscape about4:3 composition.
Pictures are decorative examples of searching for similar pets, no matching conclusion. No text, numbers, arrow, scan marks, badges, button, UI, heading, ribbons or graphic extras. Keep just the two illustrated prints, for a Flutter card with real text on their right.
```

## Explorar: fondo ilustrativo

```text
Use case: illustration-story.
Production Flutter decorative background asset, NOT a UI mockup or a real live map. Recreate ONLY the understated illustrative street-map BACKGROUND in the Explora cerca de ti banner of the reference.
High resolution landscape3:2 flat top-down cartographic illustration: very pale warm-grey city blocks, clean narrow white streets, small softly desaturated green park shapes, a gentle pale blue river curve running through right/lower half. Light airy pale-blue and white palette of approved banner, quiet low contrast, friendly. Street detail mostly at RIGHT two-thirds, LEFT third quieter fading toward near-white for Flutter-drawn text.
IMPORTANT remove the blue pin and all markers: the OFFICIAL existing brand symbol will be overlaid natively in Flutter. NO text, place labels, coordinates, typography, border, button, headline, shadow/card frame, navigation, logo, pet, legend or UI. Full bleed raster illustration, no rounded corners. No actual city/location data or identifiable map source. Preserve the soft graphic feeling and color balance of the reference.
```

