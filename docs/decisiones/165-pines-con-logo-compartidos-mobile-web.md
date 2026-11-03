# ADR-165: todos los pines usan el logo de Entre Huellas

Fecha: 29/10/2026. Estado: aceptada por instrucción explícita del usuario.
Alcance: presentación de mapas existentes, HU-02/05/06/07/10 y Recorrido;
sin nuevas HU/RF, operaciones, SQL ni ampliación del MVP.

## Decisión

Los pines de mapas internos móviles y web usan la silueta con el logo oficial,
sin el marcador Material estándar con hueco circular. Se conserva expresamente
el punto azul con borde blanco y halo de la ficha pública móvil y sus vistas
previas que usan CasePublicCards. No se añaden pines donde estaban ocultos,
como ImmersivePhotoSheet, ni se modifica Google Maps externo.

ZoneMapPicker móvil usa BrandMapPin negro #111111 con logo blanco, 48×56 y
anclaje centrado en la coordenada. LocationMap web reproduce silueta, marca,
tamaño y centro mediante el SVG local generado; conserva selección manual y
teclado. Este contrato sustituye únicamente la obligación de usar location_on36
de ADR-129. Radio, círculo, teselas, zoom, encuadre y precisión permanecen.

Explorar reutiliza el mismo BrandMapPin y conserva 48×48, logo30, blanco/negro
según selección y sombras previas. Recorrido conserva 48×56, logo27, origen rojo,
avisos azules, numeración, agrupación y retorno. La igualdad solicitada consiste
en usar silueta y marca comunes; se conservan esos estados y proporciones.

## Implementación y mantenimiento

BrandMapPin es presentación de core; ExploreMapPin delega en él, sin dibujar
otra silueta/logo. JourneyMap y el selector comparten las dimensiones publicadas.
El SVG web se regenera con `node scripts/generate-map-pin.mjs` desde
apps/platform y usa los cinco paths oficiales de only-black.svg, recoloreados
en blanco sin cambiar geometría. No hay nuevas dependencias, servicios,
llamadas externas, imports entre funcionalidades ni cambios de permisos.

## Validación

49 pruebas móviles aprobadas de selección/reintento, ubicaciones, Explorar,
Recorrido, ficha pública, arquitectura y consistencia. El selector comprueba
pin de marca, tamaño/anclaje y toque; las regresiones conservan acciones,
coincidencias y la excepción azul. 12 comprobaciones web aprobadas, incluida
paridad de dimensiones/anclaje y los paths completos de la marca.

Análisis lib/test y typecheck web sin incidencias; build Nuxt de producción
aprobado. Chromium con autenticación/teselas fixture comprueba toque/teclado,
SVG servido, escritorio1440/móvil390/320 con texto200% y movimiento reducido,
sin overflow, errores CSP ni hidratación. Capturas del widget móvil real y
del mapa web en apps/mobile/build/ui-preview/map-pins.

No acredita teselas/proveedor real, sesión Supabase remota ni versión instalada.
Recompilación y revisión física Android/iOS pendientes. Sin publicación/despliegue.
