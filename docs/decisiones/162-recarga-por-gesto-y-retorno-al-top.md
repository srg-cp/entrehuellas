# ADR-162: recarga por gesto y retorno al borde superior

Estado: aceptada por instrucción explícita del usuario, 29/10/2026.

El usuario observa un indicador quieto durante un tirón lento/incompleto y pide
quedar arriba en la pantalla actual al soltar. Se corrige PullToRefresh
compartido conservando reconocimiento y umbral nativos de ADR-049.

El máximo112px limita solo el desplazamiento pintado; el controlador del giro
sigue respondiendo al dedo. No hay giro indeterminado antes de una operación real.
Un tirón insuficiente se retira sin consulta; con rebote empieza a retirarse al
comenzar la fase balística, sin esperar inmóvil a ScrollEnd. Cancelar/confirmar
un tirón acomoda el scroll primario observado a minScrollExtent en220ms con
easeOutCubic, cortando la velocidad de liberación; movimiento reducido directo.
No navega a Inicio ni fuerza el top durante desplazamientos ordinarios.

Se observa la posición del Scrollable emisor sin sustituir los controladores de
las funcionalidades. Ajuste al siguiente frame con comprobación de montaje e
identidad, sin esperas de carga. Glass polished52/radio26/icono28, duplicados,
callbacks/ViewModels, shimmer, errores/reintentos, accesibilidad y entrada única
conservados. Sin cambios de dominio/data, SQL, permisos, web o alcance MVP.

Validación:47 pruebas locales del componente, Inicio, mascotas, ContentRefresh,
Recorrido, arquitectura y consistencia aprobadas. Física clamping/bouncing,
movimiento normal/reducido, gesto parcial/completo/largo, top y duplicados.
Análisis lib/test sin incidencias. Recompilación y revisión táctil Android/iOS
pendientes; simulaciones locales no acreditan validación física.
