# ADR-147: Inicio web con los banners ilustrados existentes

Fecha:26 de octubre de2026. Estado: aceptada por instrucción explícita.

## Decisión y alcance

Tras consultar si los assets móviles sirven en web, el usuario pide colocarlos
en el Inicio web. Esta autorización extiende expresamente ADR-143 a /inicio de
Platform; no migra otras pantallas ni el material móvil global de ADR-145.

Reutilizar los cuatro WebP finales, sin generación adicional ni escalado de
archivos. Las copias públicas son idénticas a los originales móviles:336488bytes.
Conservar personajes, escenarios y transparencia; texto, controles y símbolo
oficial del mapa siguen siendo elementos nativos. El mapa es ilustrativo y las
fotos no representan casos ni resultados reales.

Escritorio: Reportar ocupa la columna izquierda, hallazgo y búsqueda por foto
la derecha; Explorar ocupa el ancho inferior. Hasta850px se apilan en ese orden
con scroll natural. Con texto ampliado se ajustan líneas y separan imágenes de
contenido cuando falta espacio. Conservar título Poppins32/400, remate azul600,
marca, fondo, cabecera, navegación, gestión por permisos y material web existente.

## Recorrido y arquitectura

HomeContent compone GlassSurface, NavigationLink y CSS de la funcionalidad.
AccountScreen, StaggerReveal y el coordinador global de origen siguen siendo
los existentes. Reportar, hallazgo y foto usan origen real y retorno compartido;
no se cambian duración, curva o fases de GSAP ni la política global de acceso.

El enlace secundario web es Mis mascotas, que ya tiene destino operativo.
No anunciar Mis reportes como una lista web implementada. Reportar pérdida abre
/reportar; hallazgo abre /reportar?tipo=hallazgo y propone independent_found al
formulario existente. Un borrador guardado prevalece sobre esa sugerencia;
la selección inicial sin edición no marca el formulario como modificado.
Buscar con una foto conserva /coincidencias; Explorar conserva /explorar.

Sin nuevas rutas, guards, dependencias, operaciones, dominio/data, SQL ni cambios
en Flutter o landing. No se alteran permisos ni activación/evaluación del motor
de coincidencias y no se cierran historias.

## Validación

Build y typecheck,94 pruebas y revisión Chrome con backend fixture. Home cubre
1920/1440/900/390/320px, texto200% móvil/escritorio, imágenes decodificadas,
objetivos táctiles, teclado, sesión/gestión, destinos y borrador conservado.
Los botones de pérdida/hallazgo se comprueban con movimiento normal y retorno
desde origen en1440/390; coincidencias con fotogramas1440/390/320, reducido,
revisión, detalle y reintento. La prueba de alertas conserva cabecera/cuenta.
Capturas en apps/mobile/build/ui-preview/web-home y case-matching/web.

Pendientes aceptación visual del usuario, backend alojado y dispositivos/navegadores
adicionales. Evidencia local con fixtures; sin despliegue.
