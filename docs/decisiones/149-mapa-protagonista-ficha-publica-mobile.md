# ADR-149: mapa protagonista en ficha pública móvil

Corrección26/10: la cápsula «Ubicación» usa GlassSurface polished con ribete original, según la regla obligatoria ADR-148; el acabado perlado/frosted queda reservado a tarjetas de contenido. Se conserva posición, radio, texto, mapa y datos.

Fecha:26/10/2026. Estado: aceptada por instrucción explícita del usuario.
Trazabilidad: presentación de HU-05/06/07, RF-05/06/13; no cierra historias.

## Decisión

Eliminar por completo del bloque de ubicación de la ficha pública móvil el texto
«Ubicación pública aproximada de unos 1 km. El punto exacto y la referencia
permanecen privados». El mapa ocupa la tarjeta, sin cabecera exterior de ubicación:
marco claro6, radio exterior34 e interior28, proporción1.35 y altura mínima
adaptada al texto ampliado. Cápsula GlassSurface dentro, centrada abajo, con
«Ubicación», sin acción ficticia. Fecha real debajo del mapa.

La referencia orienta composición y cápsula, no solicita edificios3D, rutas,
coches ni otra cartografía. Mantener ZoneMapPicker/MapStyle, teselas configuradas,
marcador, encuadre del radio público1000m, créditos y reintento; sin acceder a
coordenadas privadas. Retirar también las cadenas/argumentos obsoletos de
CasePublicCards y adaptar el skeleton. La ficha inmersiva de vistas previas
conserva sus propios textos y contrato. Web y formularios conservados.

## Validación y límites

34 pruebas de ficha pública, compartir, carga, arquitectura y consistencia
aprobadas; análisis de seis archivos sin incidencias. Capturas390×844 y320×350
con texto200%, movimiento normal/reducido; teselas simuladas del harness.
Fondo ambiental repetitivo detenido solo en pruebas mediante
AMBIENT_BACKGROUND_MOTION=false. La cápsula permanece dentro del mapa y el
mapa conserva ancho de pantalla menos44px. Sin build/instalación Android ni
validación de red del proveedor. Pendiente revisión física y aceptación visual.
