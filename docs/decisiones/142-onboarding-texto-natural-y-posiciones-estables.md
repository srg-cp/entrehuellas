# ADR-142: texto natural y posiciones estables en onboarding

Fecha:25 de octubre de2026. Estado: aceptada por instrucción explícita.

## Problema

La segunda descripción tenía tres líneas forzadas, frente a dos en las otras
etapas. La columna inferior o centrada cambiaba de altura al cambiar la etapa,
desplazando el título y, según viewport/scroll, la acción. Las imágenes ya
compartían el mismo contenedor; la diferencia procedía de la composición textual.
El usuario además pide el ajuste natural de texto de Sader, sin saltos prematuros.

## Decisión

- Retirar los saltos explícitos de títulos y descripciones web/móvil. Conservar
  literalmente palabras, puntuación y tipografía vigente: el ancho disponible
  decide dónde ajustar las líneas, sin reducir texto ni tamaño de fuente.
- Reservar en título y descripción la mayor altura de las tres alternativas para
  el ancho/escala actuales. Alinear cada texto arriba de su espacio, conservando
  huecos, acción inferior, dimensiones de ilustración y movimiento ADR-141.
- Flutter mide alternativas con TextPainter, estilos heredados, locale,
  dirección y TextScaler efectivos; aplica minHeight, sin alturas fijas ni recorte.
- Web usa CSS grid con textos de medida visibility:hidden/aria-hidden y el texto
  activo en la misma celda. Hereda la misma tipografía/ancho y recalcula con
  CSS al cambiar viewport, fuente o escala; no duplica páginas ni usa medición JS.
- Mantener solo el texto activo en el árbol accesible y sin traducciones
  inventadas. El scroll vertical permite leer todo en pantallas pequeñas.
  Marca, botones, shimmer, guardado y transiciones se conservan.

## Validación

Comparar coordenadas de título, descripción y botón entre las tres etapas,
normal y ampliado, en ambas plataformas; revisar también ajuste natural,
foco, progreso accesible, errores/reintento y fases de movimiento.
Ver ESTADO para resultados locales; no implica aceptación visual ni pruebas remotas.
