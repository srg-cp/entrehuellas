# ADR-146: contacto móvil sólido según referencia

Fecha:26 de octubre de2026. Estado: aceptada por instrucción explícita.

## Decisión

El usuario proporciona una referencia y solicita reproducir el bloque de contacto
sin glass. La ficha pública móvil muestra una cápsula lavanda opaca #F5F4FF,
avatar48, teléfono gris sobre nombre oscuro y dos acciones circulares blancas48
con iconos azules rellenos22 (mensaje y teléfono con ondas). Padding18 y separación8
entre acciones; sin blur, reflejos, ribete ni sombra de glass.

Esta instrucción sustituye ADR-113/145 únicamente para el contacto móvil.
Conservar texto ampliado, disposición apilada en ancho pequeño, semántica,
bloqueo durante operaciones, revalidación de visibilidad y acciones SMS/marcador.
El editor del autor comparte la superficie sólida con radio28 para su contenido;
la tarjeta de lectura usa radio56. Foto e identidad proceden del contacto autorizado,
sin copiar nombre, teléfono ni avatar ficticios de la referencia al producto.

## Validación

Pruebas de contacto, ficha pública, arquitectura y consistencia; análisis del
widget y revisión de capturas390px y320px/texto200%. Usar
--dart-define=AMBIENT_BACKGROUND_MOTION=false en el harness: el fondo ambiental
repetitivo impide pumpAndSettle aun cuando el contenido terminó de cargar.
Resultados y pendientes en ESTADO. Sin build ni instalación Android.
