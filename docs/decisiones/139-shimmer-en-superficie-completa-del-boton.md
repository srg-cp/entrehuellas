# ADR-139: shimmer sobre la superficie completa del botón

Fecha:25/10/2026, America/Lima. Aceptada por instrucción explícita del usuario.
Refina ADR-006 y ADR-027; contrato compartido de presentación, sin ampliar MVP.

## Motivo

Buscar coincidencias colocaba LoadingShimmer dentro de FilledButton, alrededor
del texto. El brillo quedaba reducido a la etiqueta. El usuario exige que el
shimmer de cualquier botón cubra siempre toda su superficie, también al revisar
otros recorridos móviles y web.

## Decisión

- En Flutter, LoadingShimmer envuelve el control completo: superficie, padding,
  texto e iconos. Nunca se coloca dentro de child/label/icon del botón. Se
  conserva su radio, tamaño, etiqueta y bloqueo de dobles envíos. Reutilizar el
  componente existente, sin indicadores propios por funcionalidad.
- El componente detecta en debug/test ancestros ButtonStyleButton e IconButton
  y rechaza la integración incorrecta, incluso con wrappers intermedios.
- Web conserva ActionButton y su clase working en el elemento button. El
  pseudo-elemento compartido cubre el control con inset:0; no animar solo spans,
  textos o iconos. Los controles de archivo y enlaces existentes conservan el
  efecto sobre su superficie completa.
- La animación dura1400ms y solo existe durante trabajo real. Movimiento
  reducido mantiene brillo estático, semántica de progreso y etiqueta estable.
  Estar deshabilitado o en cooldown no activa shimmer.
- Los skeletons y ContentRefresh conservan su contrato de carga de contenido;
  esta precisión trata de cómo se integra el shimmer en botones.

## Alcance y comprobación

Revisión de usos de LoadingShimmer en apps/mobile/lib y del contrato working
en apps/platform/app. Se corrige el único uso encontrado que envolvía solo el
texto de un botón: Buscar/Continuar comparación. El resto ya envolvía el
control completo; no se cambian dominio, llamadas, permisos ni motor visual.

Regresión visual de coincidencias con petición pendiente, tamaño del brillo
igual al botón, píxeles fuera de la etiqueta, doble toque y vuelta a reposo;
390px y320px/texto200%, movimiento normal/reducido. Tests del componente
rechazan shimmer dentro de FilledButton/IconButton. Evidencia/resultados y
límites de prueba en [ESTADO](../ESTADO.md).
