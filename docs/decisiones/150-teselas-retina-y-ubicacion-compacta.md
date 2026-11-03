# ADR-150: teselas retina nativas y cápsula Ubicación compacta

Fecha:26/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Decisión y alcance

La cápsula Ubicación incorpora icono de mapa16, texto14/600, separación6 y
padding14/8. Conserva GlassSurface polished/ribete de ADR-148, posición dentro
del mapa, fecha exterior y ampliación accesible. Sin acción ficticia.

El adaptador compartido ZoneMapPicker solicita retina nativo en pantallas de
alta densidad si la URL contiene {r}. MapConfig agrega {r} antes de .png solo
para el host CARTO configurado, conservando path, query y URLs ya explícitas
{r}/@2x; otros proveedores quedan intactos. No emular retina con cuatro teselas,
no cambiar proveedor/estilo/encuadre/radio ni introducir credenciales nuevas.

LoadingShimmer por tesela solo durante solicitud iniciada, sin imagen ni error
y no cancelada. Decodificación/fallo/cancelación detienen el efecto. Mantener
fallo en toast y Reintentar mapa real; no ocultar permisos o datos anteriores.
Movimiento reducido conserva brillo estático. Sin servicios, paquetes o caché
adicional, ni cambio web. Se aplica desde el adaptador a los mapas móviles.

## Diagnóstico y evidencia

La configuración previa usaba PNG256 sin retina incluso con DPR alto. Prueba
HTTP puntual al proveedor local:200 para PNG256 y200 para PNG512@2x. Demuestra
soporte actual, no disponibilidad continua ni causa concreta del vacío mostrado.
Marcadores se dibujan aparte de las teselas: su presencia no acredita que estas
hayan llegado. Las capturas del harness usan teselas transparentes simuladas,
por lo que su fondo vacío tampoco acredita un fallo de red real.

Fuentes primarias consultadas: código instalado flutter_map8.3.2 y
[documentación oficial de teselas](https://docs.fleaflet.dev/layers/tile-layer).

## Validación

44 pruebas: ficha pública, compartir, carga, mapa de zonas, mapa de Explorar,
retina, arquitectura y consistencia. Además3 con MAP_TILE_URL de CARTO sin
credenciales:requests normales con DPR1 y@2x con DPR3, espera/decodificación y
contratos de URL. MockClient en tests; sin red a cuentas reales. Análisis de6
archivos sin incidencias; capturas normales/320px texto200% regeneradas.
Pendiente Android físico y diagnóstico de conectividad de la carga intermitente.
APK no recompilado ni instalado.
