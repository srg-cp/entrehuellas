# ADR-151: desvanecido del contenido bajo la cabecera de Inicio móvil

Fecha:26/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Decisión

Alcance posterior sustituido por [ADR-152](152-cabecera-con-desvanecido-compartido-mobile.md):
FadingHeaderScroll compartido en core reemplaza los componentes locales y aplica
el mismo efecto en Inicio, Explorar y Mis mascotas. Forma/posición conservadas.

Refinamiento vigente autorizado después de la referencia de neblina: tomar
solo la forma, sin textura. Sustituir la banda rellena ondulada por cuatro
prolongaciones difusas de alturas/anchos desiguales y entradas más despejadas
entre ellas. Perfil de profundidad continuo con lóbulos gaussianos; entre24px
y48px con scroll completo, sin bajar el conjunto ni ampliar el máximo aprobado.
Solape32px, curva alfa, fondo/controles/navegación conservados. La forma es fija,
sin ruido, imagen de humo ni animación autónoma. Sustituye las dos ondas previas.
16 comprobaciones aprobadas, incluida regresión gráfica que exige varias
prolongaciones y entradas claras a la misma altura, además de contenido inferior
opaco. Capturas normales/320px/texto200% regeneradas e inspeccionadas.

Instrucción vigente posterior a la restauración: conservar exactamente el
solape32px y la curva48px aprobados, variando solo la profundidad horizontal.
Dos ondas amplias desiguales de4px/1.5px producen irregularidad sutil, sin
desplazar la transición completa. Máscara alfa generada en memoria por columnas,
cacheada por tamaño/scroll y aplicada con ShaderMask; imagen/shader liberados
al reemplazar/desmontar. Sin assets decorativos ni animación autónoma.
16 comprobaciones locales aprobadas, incluida regresión gráfica de variación
horizontal/contenido opaco. Análisis sin incidencias, capturas regeneradas.
Las notas siguientes documentan la restauración previa, no la forma final.

Por instrucción posterior, restaurada la versión señalada por el usuario en
capturas del chat: máscara uniforme original, solape32px y salida16px. Quedan
retirados el desplazamiento4px hacia abajo y la irregularidad posteriores.

Precisión posterior del usuario: la transición comienza dentro del margen
inferior de la cabecera, no debajo de su límite. HomeScrollLayout solapa32px
del viewport de scroll bajo la cabecera y reserva esos32px en el padding del
cuerpo para conservar su posición inicial. Cabecera medida con su altura real
y pintada al final; geometría y texto ampliado conservados. El desvanecido48px
empieza32px antes de la unión y termina solo16px después, en altura normal.

Aplicar la última referencia aprobada: transición amplia, continua y suave
entre cabecera y contenido desplazado, integrada con el fondo real. Sin
imagen de humo, textura decorativa ni nubes de contornos exagerados.

HomeScrollFade en presentación de Home aplica una máscara alfa suave
dstIn al cuerpo existente. Deja ver AppPageBackground, incluida su iluminación
y movimiento originales. No añade una superficie celeste independiente ni
desenfoca toda la pantalla. La referencia se traduce en desvanecido de opacidad,
sin introducir un filtro de desenfoque adicional.

El alcance crece con el desplazamiento real hasta48px lógicos; se limita al40%
del viewport de scroll en ventanas bajas. Arriba no atenúa el título. Al volver
al inicio o hacer pull-to-refresh se retira de forma continua. Sin temporizador
ni animación nueva; funciona también con movimiento reducido.

Cabecera, controles y navegación quedan fuera de la máscara, con dimensiones,
materiales, semántica y origen/retorno conservados conforme a ADR-148.
Solo Inicio móvil: Explorar, Mis mascotas y web conservados. Sin cambios de
dominio, datos, rutas, permisos, persistencia, dependencias o assets de producto.

## Validación

39 comprobaciones locales aprobadas: Home, destinos/retorno normal y reducido,
refresh/reintento, estabilidad glass, arquitectura, consistencia y harness visual.
Se fija AMBIENT_BACKGROUND_MOTION=false para pumpAndSettle; la ejecución sin
esa opción agotó la espera por el movimiento ambiental continuo existente.
Capturas con fuentes y assets reales en390×844 y320px/texto200%, incluyendo
ventana320×350. Pendiente aceptación del render y Android físico; APK sin
recompilar ni instalar. Sin cierre de historias ni despliegue.
Análisis de lib/test/tool sin incidencias; análisis global señala dos avisos
avoid_print en un archivo preexistente de build, fuera de las fuentes mantenidas.
