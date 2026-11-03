# ADR-157: vista previa de pérdida con la ficha móvil actual

Fecha:29/10/2026, America/Lima.

## Motivo

El usuario señala que crear un caso de pérdida todavía muestra la interfaz
anterior en la vista previa. CasePreviewContent seguía usando ImmersivePhotoSheet,
mientras la consulta publicada ya usa CasePublicCards. La alternativa
«No está en mis mascotas» del mismo recorrido tenía la misma diferencia.

## Decisión

- La revisión de pérdida propia y posible pérdida comunitaria reutiliza los
  renderers actuales CasePublicContent/FoundPublicContent y CasePublicCards.
  Foto/nombre/estado, datos perlados, mapa y fecha comparten la implementación
  de la ficha publicada, sin copiar su layout.
- CaseScreenShell delega esta etapa en CasePublicScreenShell, con título
  «Vista previa», navegación glass persistente y scroll de la ficha actual.
  Una sola entrada ContentReveal/StaggerReveal, sin cortina ni timeline anidado;
  publicar/reintentar conserva la misma entrada. Formulario y confirmación
  conservan sus etapas y acciones existentes.
- La vista previa conserva únicamente fotos seleccionadas o bytes del borrador,
  coordenadas públicas aproximadas y aviso preventivo antes de las acciones.
  No añade contacto ficticio, compartir, QR ni acciones de un caso ya publicado.
  Publicar caso/Editar reporte, bloqueo, shimmer y reintentos siguen en sus
  ViewModels, sin cambios de dominio, datos, SQL ni permisos.
- Esta instrucción sustituye la conservación del diseño inmersivo en las vistas
  previas de pérdida descrita en ADR-113. ImmersivePhotoSheet y sus pruebas se
  conservan íntegros para otros consumidores y reutilización futura; los avisos
  y hallazgos mantienen su vista previa existente. Sin cambios web.

## Validación

Pruebas de los editores perdido/comunitario cubren vista previa, mapa público de
solo lectura, privacidad, publicación, fallo, respuesta ambigua y reintento en
390×844 y320×350/texto200%. La ruta real alterna ambos orígenes, revisa120
fotogramas por entrada normal/reducida y vuelve a editar conservando fotos y
borradores. Arquitectura, consistencia, tarjetas y patrón inmersivo se verifican
con las suites existentes. Resultados y límites finales en ESTADO.

Capturas locales con fuentes reales; fotos/teselas de pruebas no acreditan
descarga remota ni revisión en dispositivo. Nueva compilación Android/iOS y
aceptación física pendientes; sin despliegue ni cierre de historias por arrastre.
