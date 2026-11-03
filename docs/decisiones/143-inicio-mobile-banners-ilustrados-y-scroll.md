# ADR-143: Inicio móvil con banners ilustrados y scroll

Fecha:26 de octubre de2026. Estado: aceptada por instrucción explícita.

## Problema y decisión

El usuario rechaza un Inicio comprimido con accesos del mismo peso, aprueba la
revisión3 el25/10 y autoriza implementarla generando primero assets individuales.
El26/10 pide mascotas como los personajes de Platform conservando los escenarios.

- Mantener Poppins400/32/#454746 y el remate600 con degradado #459FF6→#75C9EF,
  fondo ambiental, marca, avatar, campana y navegación existentes.
- Cabecera fuera del scroll/stagger. Contenido vertical, márgenes24 y separación24,
  sin altura impuesta por viewport; espacio final para navegación/inset del gesto.
- Reportar integra pareja de mascotas, mensaje y botón; Mis reportes queda como
  enlace secundario dentro del banner, con objetivo mínimo48.
- Hallazgo presenta perro/puerta, mensaje centrado y botón inferior ancho;
  conserva formulario independiente y independent=true, sin retirar los avisos
  vinculados ni reclasificar históricos.
- Buscar con una foto es el acceso a coincidencias existente, con dos fotografías
  ilustrativas, sin resultados inventados ni afirmaciones de precisión.
- Explorar usa un fondo ilustrativo y el SVG oficial existente: no es mapa de
  datos ni solicita teselas/ubicación. Los mapas reales conservan sus adaptadores.
- Generar cuatro ilustraciones con imagegen integrado, sin texto/controles/marcos
  de UI; preservar los escenarios y estilizar mascotas según hero-dog, hero-cat y
  dog-report de Platform. WebP con prompts/referencias junto a los assets.
- HomeBannerSurface se comparte dentro de la funcionalidad, evitando glass sobre
  glass; HomeBannerAction usa primaryActionButtonStyle con mínimo52/radio24,
  etiqueta18/flecha24 y crecimiento accesible. Fotos/banners decorativos excluidos
  de semántica; controles y texto reales, sin recortes de mockups.
- Con texto ampliado se separan arte/contenido de Reportar y Explorar y se apila
  el acceso por foto; no limitar la escala del usuario ni recortar etiquetas.

## Arquitectura y movimiento

Solo presentación/assets de apps/mobile. HomeContent compone widgets estáticos;
HomeViewModel, bootstrap, dominio/data, permisos y operaciones se mantienen.
Sin imports de presentación/data de otras funcionalidades, paquetes nuevos ni
ViewModels/casos de uso vacíos.

Cinco grupos con StaggerReveal existente:850ms por grupo/90ms de separación,
sin repetir al desplazar. Cabecera/barra fuera del efecto. Expansión/retorno
existentes320/260ms, mismas curvas/fases, origen del control real. Nuevos botones
usan su flecha24; acceso por foto usa superficie azul pálida, radio26/flecha26.
El control Reportar inferior y otros consumidores del helper conservan parámetros
anteriores. Respetar reducido y limpieza. Navegar no añade trabajo artificial
ni shimmer; refresh del perfil, bloqueo/toast/reintento existentes se conservan.
La regla de shimmer sobre control completo sigue vigente para trabajo real.

## Alcance y validación

Solo Inicio Flutter, sin migración implícita de Inicio web. Reorganiza accesos
de HU-05/06/07 y HU-25/26 sin nuevas operaciones, SQL, historias o servicios.
No cierra historias ni sustituye activación/evaluación de coincidencias.

Validar rutas, origen/retorno normal/reducido, cabecera/barra estables, scroll,
fuentes/assets, transparencia, objetivos táctiles,320px/texto200%, refresh y
arquitectura. Capturas en apps/mobile/build/ui-preview/home-redesign; resultados
en ESTADO. Build y aceptación del mockup no sustituyen revisión Android física.

