# ADR-170: tirón de recarga con gesto exclusivo

Estado: aceptada por instrucción explícita del usuario, 30/10/2026.

El indicador flotante y el contenido respondían simultáneamente al invertir el
arrastre. El usuario solicita que se recoja primero el círculo y que no aparezca
por un cambio de dirección durante scroll ordinario.

PullToRefresh decide elegibilidad una sola vez al comenzar el arrastre vertical
primario: contenido en minScrollExtent y primer desplazamiento hacia abajo. El
dedo puede comenzar en cualquier altura del contenido. Llegar al borde desde
más abajo, arrastrar primero hacia arriba o un rebote balístico no habilita
recarga en ese mismo gesto. Scrolls anidados/horizontales quedan fuera.

Tras el primer tirón válido, el componente conserva la posición superior mediante
ScrollPosition.hold y sigue únicamente el puntero iniciador hasta soltar/cancelar.
El mismo gesto recoge el indicador sin desplazar la página, incluso si se recoge
por completo; otro arrastre permite scroll normal. No usa física ni controladores
por funcionalidad. Libera el hold al terminar o desmontarse. El scroll puede
utilizarse con un nuevo gesto durante la petición; no hay bloqueo de toda la UI.

Sustituye el reconocimiento RefreshIndicator.noSpinner y el ajuste posterior al
top de ADR-049/162: el contenido permanece arriba durante el tirón adquirido.
Conserva umbral de liberación equivalente al nativo (25% del viewport), resistencia
visual .5, máximo pintado112px, giro ligado al dedo, acomodo64px y retirada220ms
con easeOutCubic. Al retroceder bajo el umbral se desarma; cancelar el puntero no
consulta. Movimiento reducido sin giro ni animación de acomodo/retirada.

Conserva glass polished52/radio26/icono28, acción accesible, callbacks/ViewModels,
shimmer, errores/reintentos y protección de duplicados. Solo presentación móvil,
sin cambios de dominio/data, SQL, permisos, web, nuevas HU/RF ni cierre de historias.

Validación y límites: véanse ESTADO y la ficha de recarga de contenido. Las pruebas
locales de gestos no sustituyen revisión táctil Android/iOS.
