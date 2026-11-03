# Pines de mapa compartidos

## Qué hace y recorrido

Los mapas internos usan un pin con el logo oficial de Entre Huellas.
En móvil, ZoneMapPicker utiliza BrandMapPin en Ubicaciones de interés, filtros,
reportes, avistamientos y su revisión. Explorar y Recorrido reutilizan ese
renderer para sus resultados. En web, LocationMap incorpora el equivalente SVG
en Reportar, avistamientos QR y ficha de recuperación/coincidencias.
[ADR-165](../decisiones/165-pines-con-logo-compartidos-mobile-web.md).

## Reglas y excepciones

- Selector: negro/logo blanco, 48×56, centro conservado; coordenadas sin alterar.
- Explorar móvil: blanco/logo negro y seleccionado negro/logo blanco, 48×48.
- Recorrido: origen rojo, avisos azules, número/contador y 48×56 conservados.
- Ficha pública móvil y previews de pérdida: punto azul con borde blanco/halo,
  sin sustituirlo por un pin de marca.
- ImmersivePhotoSheet conserva el pin oculto. El enlace QR a Google Maps y los
  mapas ilustrados de Inicio/landing no son marcadores internos editables.

## Persistencia, permisos y errores

Solo presentación; no guarda datos ni añade permisos o consultas. ViewModels,
casos de uso y repositorios existentes conservan selección, privacidad y radios.
Error de teselas conserva toast/reintento y alternativa de coordenadas donde
existe. Los pines no son indicadores de trabajo ni reinician entradas.

## Dependencias y activación

Reutiliza flutter_svg, BrandMapPin y LocationMap. La marca oficial sigue en
apps/mobile/assets/branding/only-black.svg. Regenerar el recurso web desde
apps/platform con `node scripts/generate-map-pin.mjs`; la comprobación web
compara los cinco paths oficiales y dimensiones/anclaje. No requiere SQL nuevo.
Distribuir el cambio requiere recompilar móvil y publicar el build web.

## Validación y pendiente

49 pruebas móviles y12 comprobaciones web aprobadas, análisis/typecheck/build
web y revisión Chromium con fixtures. Selector por toque y teclado, selección
individual de Explorar, grupos de Recorrido y excepción azul conservados.
Normal/pequeño/texto200% y reducido revisados localmente. Capturas en
apps/mobile/build/ui-preview/map-pins y resultados en [ESTADO](../ESTADO.md).
Pendiente revisión física con nueva compilación Android/iOS y proveedor real.
[Inventario por consumidor](../revisiones/pines-mapas-2026-10-29.md).
