# ADR-144: material glass perlado en Inicio móvil

Precisión posterior: [ADR-145](145-glass-perlado-compartido-mobile.md) extiende
expresamente este material a todos los consumidores móviles de GlassSurface,
centraliza las capas en core y desactiva su trazo blanco por defecto.

Fecha:26 de octubre de2026. Estado: aceptada por instrucción explícita.

## Decisión

El usuario solicita aplicar a las tarjetas del Inicio móvil el acabado de las
dos referencias de paquetería: vidrio esmerilado gris perla, luz blanca difusa,
reflejos celestes y borde discreto. La paleta celeste previa por sí sola no
reproducía ese material. Se conserva la composición aprobada en ADR-143.

HomeBannerSurface reutiliza GlassSurface en acabado frosted, radio26, blur
acotado y ribete único. Una iluminación compartida combina degradado perlado
semitransparente y luz radial celeste. Material transparente e Ink mantienen
la respuesta táctil de Buscar con una foto. No se añade otra tarjeta glass
dentro de la superficie ni un doble borde metálico.

Las escenas opacas de Reportar/Explorar reciben modulación de iluminación en
HomeBannerScenery para integrar sus blancos con el material. Se aplica solo al
arte, sin filtros sobre textos/controles ni modificación de los archivos WebP;
mascotas, encuadres, escenarios y assets con alfa se conservan. El acabado es
estático y no introduce animaciones. El título y fondo ambiental no cambian.

Buscar con una foto comunica el nuevo gris perla representativo al coordinador
de expansión existente; geometría, flecha, fases y duraciones se conservan.
Backdrop usa BlendMode.src bajo la opacidad del stagger, como el glass compartido.

## Alcance y validación

Corrección posterior del26/10: el usuario indica que el ribete blanco destaca
demasiado frente a la referencia. Inicio desactiva el trazo de borde mediante
showRim=false; el material conserva luces internas, radio, blur y sombra suave.
GlassSurface mantiene showRim=true por defecto para sus demás consumidores.

Solo presentación de Inicio Flutter. Sin web, nuevas dependencias, datos,
permisos, operaciones, SQL o cierre de historias. Navegación, scroll, cabecera,
tipografía, texto ampliado y movimiento reducido conservan sus contratos.

Validar análisis, arquitectura, navegación/retorno normal y reducido, estabilidad
del material durante/después de entrada y capturas normales/320px/texto200%.
Evidencia final en ESTADO y ficha de Inicio; revisión Android física pendiente.
