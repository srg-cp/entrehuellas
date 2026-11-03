# ADR-154: Recorrido reutiliza el mapa y panel de Explorar

Fecha:26/10/2026. Aceptada por instrucción explícita del usuario en este chat.

## Decisión y alcance

La pantalla abierta desde la tarjeta «Recorrido de la búsqueda» adopta literalmente
la composición móvil de Ver mapa de Explorar: mapa a pantalla completa, retorno y
cápsula glass superiores, panel blanco deslizable con tirador, foto/resumen, flecha
celeste, Ver ficha, separador y filas inferiores. La cápsula dice «Recorrido» y la
sección inferior «Ubicaciones». Conserva medidas, colores y movimiento de Explorar;
el panel blanco es la referencia explícita de este recorrido, sin extenderlo a las
tarjetas perla de la ficha. La cápsula mantiene la tipografía compacta16/500 del
mapa de Explorar, como excepción local al título principal32. Texto ampliado y
scroll se conservan; la cápsula elide en una línea si falta ancho.

Por instrucción explícita, Ver ficha y la flecha diagonal de esta pantalla quedan
temporalmente como adornos: aspecto y posición originales, sin callback, respuesta
al toque, foco ni semántica de acción. La desactivación no atenúa sus colores.
Los controles equivalentes de Explorar conservan su funcionalidad existente.
Esta excepción no autoriza acciones vacías en otras pantallas.

El mapa conserva pin rojo de origen, celestes numerados para avisos, marca oficial,
zonas aproximadas y conexión por orden de suceso. Ubicaciones muestra el origen y
todos los avisos autorizados en ese orden; tocar fila/pin centra su zona y devuelve
el panel al resumen. Los puntos coincidentes comparten pin sin inventar coordenadas.
No representa una ruta vial ni ubicación actual. La revisión de evidencia conserva
su acceso existente mediante Ver seguimiento de la ficha, fuera de este panel.

Refinamiento posterior26/10 solicitado con referencia de cronología: en las filas
de Ubicaciones, sustituir los iconos de pin por puntos pequeños con halo suave;
origen rojo y avisos celestes, unidos por una línea vertical punteada gris tenue.
El eje termina en el último punto y no se dibuja con origen único. Se adapta a
la altura real de filas/texto ampliado, sin representar pasos pendientes ni cambiar
revisión, orden, datos o selección. Los pines del mapa conservan su diseño.
MapPanelFact admite leading decorativo opcional; Explorar conserva sus iconos.

Se conserva PullToRefresh real al arrastrar hacia abajo desde el inicio del scroll
con el panel en su mínimo. Contenido retenido con shimmer, bloqueo simultáneo,
toast/reintentos y movimiento reducido existentes. No hay botón Actualizar ni
subtítulo «Origen · ...». Loading/error y cambio de identidad restauran el estado
visual y el acceso de retorno; los datos antiguos no se mantienen al perder permiso.

Sustituye la composición anterior de la pantalla cartográfica de ADR-153.
La tarjeta perla de entrada, ilustración, contador, datos, contacto y demás opciones
de la ficha conservan su diseño aprobado. Sin migración web, SQL ni despliegue.

## Implementación compartida

MapCaseSheet, MapCasePanel/MapPanelFact y MapSheetHeader se extraen de Explorar a
core/presentation/widgets. Centralizan geometría, medida del resumen, panel blanco,
resortes/gestos, encabezado y controles; no conocen providers, entidades ni permisos
de funcionalidades. Ambas pantallas los componen sin imports entre presentaciones.
ZoneMapPicker sigue siendo el adaptador cartográfico único y conserva estilo,
créditos, teselas y reintentos. Los controladores se liberan con su propietario.

ReadCaseJourney incluye nombre/rasgos/foto de la misma proyección pública del origen
ya consultada. Sin consultas nuevas a perfiles/mascotas privados, servicios o SDK en
presentación. La evidencia privada sigue dependiendo de los contratos autorizados
existentes, destino comprobado y aproximación antes de entregarla a la vista.

## Validación

Comparación de capturas de Explorar antes/después de la extracción, pruebas de sus
gestos/selección/retorno, Recorrido normal/texto200%, acciones decorativas, ubicación
seleccionada, refresco real, dominio/identidad/privacidad y comprobaciones de
arquitectura/consistencia. Resultados finales y límites en ESTADO. Fixtures locales
no sustituyen una sesión con cuentas/fotos/teselas reales ni la revisión Android.
