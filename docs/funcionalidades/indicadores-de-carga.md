# Indicadores de carga compartidos

Contrato transversal de presentación para las funcionalidades existentes;
ADR-006/027 y [ADR-139](../decisiones/139-shimmer-en-superficie-completa-del-boton.md).

## Comportamiento y recorrido

Al ejecutar una acción, mantener el texto y las dimensiones del botón mientras
un brillo recorre toda su superficie. Flutter usa LoadingShimmer alrededor del
botón completo; web usa ActionButton/working sobre el control. Radio, iconos y
padding pertenecen a la misma superficie. No envolver únicamente la etiqueta.

Sin trabajo real no hay brillo. Movimiento reducido lo presenta estático y
conserva la semántica de progreso. Se bloquean dobles envíos y se liberan las
animaciones al terminar o desmontar. Skeleton inicial y ContentRefresh sobre
contenido confirmado conservan sus contratos independientes.

## Datos, permisos, errores y reintentos

El componente no persiste datos ni decide permisos. Cada ViewModel mantiene
su operación, autorización, errores por toast superior y reintentos reales.
No sustituir estas responsabilidades por una animación ni activar carga por
simple deshabilitación o cooldown.

## Integración y validación

Flutter rechaza en debug/test LoadingShimmer dentro de ButtonStyleButton o
IconButton. Revisión de usos móviles y web el25/10: un uso incorrecto en
coincidencias, corregido; los demás botones revisados ya cubrían el control.
Pruebas de geometría, píxeles fuera del texto, accesibilidad, movimiento reducido,
doble envío y lifecycle; resultados en [ESTADO](../ESTADO.md). Renders locales
no sustituyen aceptación visual del usuario ni prueba de sesión alojada.
