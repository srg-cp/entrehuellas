# ADR-153: acciones compactas y recorrido de búsqueda móvil

Fecha:26/10/2026. Aceptada por instrucción explícita del usuario en este chat.

Precisión posterior: [ADR-154](154-recorrido-con-panel-del-mapa-de-explorar.md)
sustituye la composición de la pantalla cartográfica por el mapa/panel real de
Explorar, con «Ubicaciones» y adornos temporales. Conserva la tarjeta perla,
opciones, datos/permisos y refresco aquí acordados.

## Decisión y alcance

Implementar la composición aprobada en opciones/avisos de la ficha móvil de
búsquedas propias y comunitarias. Galería, contacto, datos, mapa principal y
navegación conservados. Sin migración web ni alcance administrativo móvil.

Tres acciones circulares con etiquetas debajo: Reportar avistamiento reutiliza
NavigationAccentSurface/celeste brilloso; La vi o la encontré y Ya fue recuperada
usan el tono pálido aprobado. Dos utilidades rectangulares contiguas, igual altura,
icono/texto dentro: Ver seguimiento y Crear cartel. Excepción local explícita de
geometría/material para estas opciones; no cambia la norma global de ADR-148 ni
Volver/Compartir/Mapa. Cierre/cartel conservan permisos. Seguimiento indica
«Historial y revisiones»; no se inventa un contador de nuevos/no leídos.

El bloque de avisos usa una tarjeta informativa GlassSurface.card perlada con
ilustración mapa/lupa, resumen real, origen y último aviso. Toda la tarjeta abre
un solo destino. Corrección final: se eliminan el encabezado externo «Avisos de
esta búsqueda», el pie «Ver mapa y cronología», su separador y el chevrón inferior.
Círculo negro56 con flecha diagonal blanca26 en la esquina superior derecha;
flecha reducida desde el boceto30. Tocar círculo o tarjeta abre el mismo destino.
Origen rojo, avisos celestes y logo/huellas oficiales en la ilustración ampliada.
Arte raster separado de texto, fechas, glass y controles nativos.

Corrección posterior26/10: el usuario solicita igualar tipografía/tamaños/estilo
de Recorrido con la tarjeta perla de datos superior. Ambas consumen
CaseCardTypography: familia del tema, etiquetas14/400/1.4 y valores17/600/1.3,
con los colores existentes de la referencia superior. Título/fechas de Recorrido
usan el estilo de valores y sus textos secundarios el de etiquetas. Se retiran
los estilos locales18/700, fechas15 y etiquetas12; superficies y acciones intactas.

La corrección final comparte radio28, padding18, gap16 y separación etiqueta/
valor3 con CasePublicGlassCard mediante constantes comunes. Reserva de espacio
para el círculo y texto ampliado sin superposiciones. Resumen sin prefijo
«Origen»: avistamiento(s) y «Sin avistamientos»; si incluye custodia usa aviso(s),
sin reclasificarla. Datos/permisos y contrato de apertura/retorno conservados.

Vista de recorrido, corrección posterior26/10: retirar «Actualizar recorrido» y
el subtítulo superior «Origen · ...». Usar PullToRefresh compartido de las
secciones para el gesto descendente, con lectura real y bloqueo mientras está
activo. CaseScreenShell transmite scrollPhysics opcional y esta vista solicita
AlwaysScrollableScrollPhysics, incluso con pocos avisos. Mantener ContentRefresh
sobre contenido conservado, toast/reintento, permisos y movimiento reducido.

## Datos y arquitectura

case_journey agrega contratos de dominio de lost_cases/found_cases/case_timeline
mediante providers declarativos; sin imports de presentación/datos entre features.
No requiere tablas, RPC, grants, servicios ni despliegue de backend nuevos.

Lee origen/avisos públicos vinculados. Evidencia privada solo si el servidor
autoriza el historial existente, comprobando destino y reduciendo sus puntos a
la cuadrícula aproximada compartida antes de entregarlos a presentación. Un
fallo/denegación no equivale a vacío ni expone evidencia a otro lector. Cambio
de cuenta oculta estado anterior y selección solo se resuelve contra datos actuales.

Orden por hora del suceso ascendente, clave estable para empates y deduplicación
entre páginas. Evidencia rechazada conserva su historial autorizado, pero no
forma parte del recorrido; las demás muestran estado de revisión sin afirmar certeza.
La línea une avisos por fecha: no navegación vial ni posición actual. Sin avisos
se muestra el origen. Puntos coincidentes comparten pin/contador y acceso a todos
sus avisos, sin desplazamientos geográficos inventados.

ZoneMapPicker comparte capas de líneas/círculos y encuadre de varios puntos,
con estilo, retina, créditos y reintento existentes. La silueta de pin se comparte
con Explorar sin cambiar su aspecto. Apertura desde origen/retorno existentes
320/260ms y modo reducido; no afirma auditoría/paridad global con web.

## Validación

Orden/páginas, privacidad, identidad, cuadrícula, agrupación, acciones, material,
origen/retorno y texto200%. Evidencias finales en ESTADO. Fixtures/teselas simuladas
no sustituyen demo Android con cuentas, fotos y cartografía reales.
