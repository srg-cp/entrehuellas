# Inicio y navegación

29/10: recarga compartida corregida en Inicio y sus secciones: giro ligado al
dedo sin congelarse; cancelar/confirmar acomoda el scroll al top de la sección
actual. [Contrato y validación](recarga-de-contenido.md), ADR-162.

29/10, [ADR-160](../decisiones/160-origen-completo-y-fases-al-55.md): Reportar
pérdida/Encontré una mascota conservan texto y flecha al comenzar expansión;
Buscar con una foto conserva ilustración/texto/flecha. Navegación conserva los
nueve puntos reales; + delegado conserva su identidad. Fuente hasta55% y destino
móvil desde55%, composición y texto ampliado sin saltos. Web conserva todo el
control y la entrada Sader del destino. Datos/rutas/borradores intactos;
validación local y revisión física pendiente en ESTADO.

## Cabecera y desvanecido comunes —26/10/2026

Por instrucción explícita, el efecto se integra en FadingHeaderScroll compartido
en core/presentation, no en el contenido de Inicio. Inicio, Explorar y Mis
mascotas lo reciben de su cabecera/scroll común. Conserva forma, posición,
padding inicial, fondo, navegación y origen/retorno; reinicia máscara al cambiar
sección. Refresh/paginación conservan eventos de scroll. Sin cambios de datos,
permisos, errores o reintentos. [ADR-152](../decisiones/152-cabecera-con-desvanecido-compartido-mobile.md)
sustituye las notas de alcance exclusivo a Inicio siguientes. Validación local
y revisión Android pendiente en ESTADO; sin cierre de historias ni cambios web.

## Desvanecido bajo cabecera móvil —26/10/2026

Refinamiento vigente: forma de neblina sin copiar su textura. Cuatro
prolongaciones suaves desiguales, con zonas más despejadas entre ellas;
profundidad24–48px al desplazar, solape32px y alcance máximo conservados.
Sustituye el perfil de banda ondulada siguiente. No añade assets o animación;
solo cambia la máscara del contenido real.16 comprobaciones aprobadas,
incluidas entradas claras/prolongaciones y contenido inferior opaco;
capturas normales/ampliadas regeneradas e inspeccionadas. Pendiente Android
físico y recompilación APK.

Instrucción vigente: sobre la posición restaurada32px/16px, añadir solamente
variación horizontal suave de4px/1.5px en la profundidad del desvanecido. Conserva
curva y cabecera; máscara alfa generada/cacheada por la interfaz, sin assets ni
animación nueva.16 comprobaciones aprobadas, incluida regresión de opacidad;
capturas regeneradas e inspeccionadas, análisis sin incidencias.
La restauración uniforme siguiente queda como antecedente.

Por petición posterior y capturas del chat, restaurada la máscara uniforme
anterior al desplazamiento4px y la irregularidad. Sin texturas ni malla alfa.

Corrección posterior por captura del usuario: el efecto nace dentro del margen
inferior de la cabecera. Viewport solapado32px, máscara48px y solo16px de salida
inferior; padding compensado conserva título/composición inicial. Cabecera
medida a su altura natural y pintada por encima, sin desplazar controles.

Por referencia explícita del usuario, Inicio disuelve el contenido al deslizar
bajo la cabecera mediante HomeScrollFade. Máscara alfa sobre los widgets reales,
sin imagen de niebla; deja ver el fondo ambiental existente. Transición hasta48px
lógicos, limitada al40% del viewport de scroll en ventanas bajas; título intacto
al estar arriba y retirada continua al volver/pull-to-refresh. No añade animación
autónoma; movimiento reducido conservado. Cabecera/barra fuera de la máscara.
Explorar/Mis mascotas/web y materiales ADR-148 conservados. Sin operaciones,
persistencia/permisos/activación nuevos ni cambios de feedback/reintento.
[ADR-151](../decisiones/151-desvanecido-bajo-cabecera-inicio-mobile.md).
39 comprobaciones aprobadas con fondo fijado para las pruebas y capturas reales
normales/320px/texto200%. Pendiente Android físico y aceptación visual del render;
APK sin recompilar/instalar. No cierra historias.

26/10, precisión ADR-148: actualizar recupera su glass original; el material
perlado se solicita solo en las tarjetas mediante GlassSurface.card.

26/10, [ADR-148](../decisiones/148-restaurar-glass-controles-y-navegacion-mobile.md):
barra de navegación recupera acabado polished y ribete originales por corrección
del usuario. Las tarjetas mantienen glass perlado sin borde; acciones/scroll intactos.

## Inicio web ilustrado —26/10/2026

Por instrucción explícita, /inicio reutiliza los cuatro WebP finales móviles;
Reportar a la izquierda, hallazgo/foto a la derecha y Explorar al ancho inferior.
Hasta850px se apilan y permiten scroll. Texto200% ajusta líneas y separa arte;
texto/controles nativos, marca, título, fondo, glass web y navegación conservados.
[ADR-147](../decisiones/147-inicio-web-con-banners-ilustrados.md) sustituye solo
la composición web histórica siguiente. Sin cambios Flutter/landing.

Mis mascotas, pérdida, coincidencias y Explorar conservan destinos reales.
Hallazgo abre /reportar?tipo=hallazgo con independent_found como sugerencia
inicial; restaurar borrador tiene prioridad, sin sobrescribirlo ni marcar como
editado un formulario recién abierto. Sin nueva persistencia, permisos o SQL.
Mis reportes no se presenta como lista web implementada. No cambia activación
del motor ni se prometen resultados reales a partir de las fotos decorativas.

HomeContent comparte GlassSurface/NavigationLink y conserva origen/retorno.
Validación local: build/typecheck,94 pruebas; Chrome1920/1440/900/390/320 y200%,
teclado, objetivos48, imágenes decodificadas, roles, destinos y borrador; origen
normal/retorno de los botones en1440/390 y foto en1440/390/320, reducido y
alertas/cuenta. Capturas en apps/mobile/build/ui-preview/web-home. Pendiente
aceptación visual, backend alojado y dispositivos adicionales; sin despliegue.

26/10, [ADR-145](../decisiones/145-glass-perlado-compartido-mobile.md): por
precisión expresa del usuario, material/luces sin borde pasan de HomeBannerSurface
a GlassSurface para todos sus consumidores móviles, incluida ficha pública y
navegación. Home conserva composición/arte, sin duplicar iluminación de superficie.

## Material glass perlado —26/10/2026

Corrección posterior: retirado el contorno blanco de las cuatro tarjetas por
observación del usuario. La luz queda dentro del material; otros consumidores
de GlassSurface conservan su ribete. Sin cambios de composición ni navegación.

Por solicitud explícita, las cuatro tarjetas sustituyen la base celeste opaca
por glass gris perla con luz blanca/celeste difusa y ribete único. HomeBannerSurface
reutiliza GlassSurface frosted; HomeBannerScenery integra la iluminación de las
escenas opacas sin cambiar assets, mascotas, escenarios ni texto/controles.
Buscar con una foto conserva la expansión existente con color de origen perlado.
Composición, rutas, persistencia, permisos y activación no cambian; solo móvil.
[ADR-144](../decisiones/144-inicio-mobile-glass-perlado.md). Resultados y revisión
física pendiente en [ESTADO](../ESTADO.md).

Validación local del ajuste:23 pruebas aprobadas de navegación/retorno normal y
reducido, estabilidad, arquitectura y capturas; análisis sin incidencias.
Inspección de material en inicio/scroll/final y320px/texto200%. No se recompila
APK en este incremento; aceptación visual y dispositivo Android pendientes.

## Inicio móvil implementado localmente —26/10/2026

El usuario autoriza implementar la revisión3 y generar primero los assets;
precisa mascotas menos realistas según Platform y escenarios conservados.
[ADR-143](../decisiones/143-inicio-mobile-banners-ilustrados-y-scroll.md) sustituye
la composición móvil de las notas históricas siguientes.

Recorrido: título existente → Reportar con Mis reportes integrado → hallazgo
con perro/puerta y botón inferior → Buscar con una foto → Explorar. Cuatro
ilustraciones generadas por separado; controles, texto y símbolo oficial
vectorial son nativos. Cabecera/navegación fijas, cuerpo con scroll continuo,
márgenes24 y espacio inferior para barra/gesto. Imágenes excluidas de semántica.

Destinos existentes: Mis reportes abre su lista; Reportar abre pérdida; Encontré
una mascota abre hallazgo independiente conservando independent=true; Buscar con
una foto abre coincidencias; Explorar selecciona su sección real. Conserva avisos
vinculados, históricos, permisos, persistencia y requisitos de activación/evaluación.
Las fotos son ilustrativas, no resultados; el mapa del banner no tiene datos,
teselas ni ubicación. Sin nuevas operaciones, dominio/data/SQL o cambios web.

HomeBannerSurface/Action se comparten entre banners y reutilizan el estilo de
botón de core. Texto200% crece y separa arte/contenido; objetivos mínimos48.
Stagger y expansión/retorno conservan motores/parámetros, con origen, color,
radio y flecha reales. Refresh/bloqueo/toast/reintento conservados; navegar no
introduce carga artificial. [Assets y prompts](../../apps/mobile/assets/illustrations/home/README.md):
cuatro WebP,336488bytes; alfa/esquinas0 en puerta/fotos, dimensiones comprobadas.

Validación final:51 pruebas aprobadas de Home/refresh/banners/coincidencias,
arquitectura, origen/stagger y harness.11 regresiones nuevas verifican destinos,
origen/retorno normal y reducido, scroll, cabecera/barra y tamaños390×844,
320×600 y320×350/texto200%. Análisis lib/test/harness sin incidencias; formato/diff
limpios. Capturas reales con fuentes/assets en apps/mobile/build/ui-preview/home-redesign,
incluida entrada200ms; inspección normal y ampliada. APK debug con configuración
local compilado mediante workaround temporal de Java documentado en CONFIGURACION,
sin cambios permanentes de Gradle. Sin instalación ni nueva operación Supabase.
Pendiente revisión Android físico y aceptación del render implementado; no se
cierran historias ni se afirma auditoría global de animaciones.

## Referencia visual móvil aprobada —25/10/2026

El usuario aprueba expresamente la revisión3 como referencia del Home móvil:
composición inicial y continuación al deslizar. La implementación Flutter y
su validación siguen pendientes; esta aceptación visual no cierra historias.

Exploración solicitada por el usuario con imagegen integrado y criterios de
apple-design: banners con imagen y botón para pérdida/hallazgo y banner de
Explorar. El usuario rechaza el banner y los accesos de revisión2. Revisión3:
Mis reportes pasa al banner de Reportar y Buscar con una foto tiene un acceso
visual propio con fotos ilustrativas, sin afirmar resultados reales. Hallazgo
presenta un perro de cuerpo entero junto a una puerta azul, mensaje y botón
inferior. Sustituye solo como propuesta los cuadrados y la barra anteriores;
paleta y tipografía aprobadas siguen siendo referencia de conservación.
Dos imágenes muestran el comienzo y la continuación al deslizar;
el hallazgo compartido permite reconocer el mismo recorrido. Se conserva como
referencia la identidad, tipografía y paleta aprobadas; no se intenta mostrar
todo el contenido en una sola pantalla.

[Imágenes y prompts de revisión3](../../output/imagegen/home-scroll-propuesta-v3-2026-10-25/propuesta-y-prompts.md).
La propuesta anterior se conserva como exploración previa.
Referencia visual aprobada, sin sustitución todavía del diseño implementado
ni nuevas operaciones, persistencia, permisos o requisitos de activación. Los
botones representados corresponden a destinos existentes. Inspección visual
realizada; implementar y comprobar composición, scroll, fuentes exactas,
texto ampliado, semántica, áreas táctiles y transiciones queda pendiente.

21/10, corrección posterior del usuario: la cabecera incorpora campana real
de [alertas web](notificaciones-web.md), avatar privado con iniciales como
alternativa y panel de consulta de cuenta. Se retira el desplegable inferior
Tu cuenta del incremento anterior. GlassSurface compartido extiende el acabado
polished móvil a Inicio, controles, cuenta y bandeja; GlassDialog gestiona cierre,
Escape, foco y scroll. Marca estable y cierre real por icono accesible.
Las páginas componen alertas por slot sin imports entre presentaciones.
Perfil editable/push/preferencias web siguen fuera de este incremento.

## Inicio web con la composición móvil —21/10/2026

Por petición explícita, /inicio de platform adapta el HomeContent móvil vigente:
título «Su regreso empieza contigo» Poppins400/32 con remate600 y degradado
#459FF6→#75C9EF, tres accesos negros, ilustración original de perro/gato3:2
y descripción dentro de tarjeta glass/radio26, sección Cerca de ti con aviso
glass y enlace real a Explorar. Dos columnas en escritorio, secuencia móvil
en pantallas pequeñas y accesos apilados al necesitar más espacio.

El widget HomeContent de acceso es presentación estática, compuesto por
AccountScreen bajo su sesión/onboarding y StaggerReveal existentes. No importa
otras funcionalidades ni añade ViewModel/caso de uso sin operaciones nuevas.
Reportar conserva expansión/retorno desde origen; Explorar y Mis mascotas
usan sus rutas existentes. Mis reportes, perfil editable y alertas móviles
no se anuncian como implementados en web. La descripción de Explorar refleja
la selección de zona web, sin prometer geolocalización automática móvil.

Tu cuenta conserva nombre/correo/ciudad reales en details/summary accesible por
teclado; no hay persistencia adicional del desplegable. Moderación y su retry
se conservan por permiso, sin esperar gestión para mostrar el contenido.
No reaparecen frases decorativas superiores ni pie legal autenticado.

Validación local: build en .nuxt-home-review sin detener el dev server,
typecheck y64 pruebas aprobados. check-home-browser.mjs confirma Chrome1440,
390,320 y texto200%, imagen/fuente locales, abrir/cerrar cuenta por teclado,
los tres accesos y retorno, redirect anónimo y gestión por rol con fixtures.
Capturas desktop/mobile/text200 revisadas en apps/mobile/build/ui-preview/web-home.
check-stagger-browser.mjs confirma entrada real y permisos pendientes sin
skeletons, resize/movimiento reducido y QR sin JS. check-access-browser.mjs
confirma login/onboarding/roles/logout/reintentos con el nuevo título.
Sin despliegue; pendiente revisión del usuario, backend real, Safari/Firefox
y dispositivos físicos.

Alineación20/10/2026: CollectionHeader ancla el título al borde superior de
la fila, conservando mínimo56 y espacio de acciones. Explorar y Mis mascotas
comparten la posición inicial de «Su regreso»; se elimina el desplazamiento8
por centrado vertical. Regresión de navegación con fuentes reales en390×844
y320×350/texto2 aprobada. Sin cambio de tipografía, datos o permisos.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

20/10/2026: corregido el arrastre del indicador al pasar por Explorar. El
Positioned de navegación tiene identidad estable en el Stack: insertar o
retirar el acceso flotante Mapa no desmonta LiquidNavigation ni reinicia su
tween. Conserva deslizamiento320ms, selección inmediata con movimiento
reducido y destinos existentes. Sin nueva persistencia, permisos, dependencias
o activación. Dos regresiones reproducen Inicio→Explorar→Mis mascotas y vuelta,
con Mapa visible, identidad y posiciones inicial/intermedia/final. Fallaban
antes del ajuste y pasan después; suite Home/refresh/arquitectura/consistencia
27/27 aprobada y análisis completo sin incidencias. Revisión visual Android pendiente.

20/10/2026, acabado vigente de accesos: Reportar/Mis reportes/Mis mascotas con
fondo negro #111111, iconos y texto blancos, peso600 original y sin refuerzo
de iconos. Tamaños compactos y destinos conservados; apertura de Reportar
parte del negro real. Sustituye el azul/gris de las notas anteriores. Sin
nuevos datos, permisos o activación. Formato/análisis limpios;11 comprobaciones
de arquitectura/captura aprobadas, normal y pequeño/texto2 sin overflow.
Captura normal revisada; pendiente revisión visual Android.

20/10/2026: Inicio también permite actualizar al jalar desde el borde superior
y soltar al alcanzar el umbral, con PullToRefresh/indicador glass compartidos.
Recarga el perfil real de cabecera; contenido editorial e ilustración fijos.
Router inyecta el callback del ViewModel de perfil; HomeViewModel coordina
duplicados, errores seguros y descarte al cambiar sección. Toast superior con
Reintentar; avatar conservado durante refresh de la misma cuenta. Explorar y
Mis mascotas mantienen sus callbacks propios. Sin nuevas tablas/permisos o
activación.14 pruebas de recarga/arquitectura y8 de perfil aprobadas, análisis
limpio. Pendiente gesto/consulta autenticada Android. Actualiza el alcance de
[ADR-048](../decisiones/048-actualizar-listas-al-jalar.md), sin cierre de HU.

20/10/2026, accesos vigentes: Reportar/Mis reportes/Mis mascotas usan texto700
y azul #2887EF en texto/iconos, con refuerzo horizontal de iconos0.25px por lado.
Conservan fondo gris, tamaños, destinos y ampliación. Sin nuevos datos, permisos
o activación. Formato/análisis limpios y11 comprobaciones de arquitectura/captura
aprobadas; renders normal/pequeño sin overflow, normal revisado. Android pendiente.

20/10/2026, título vigente tras nueva referencia: Poppins32 (antes26), primera
frase gris400 y segunda600 con degradado horizontal azul #459FF6→celeste #75C9EF.
Sin glass. ShaderMask solo en «empieza contigo»; ampliación, ajuste natural,
etiqueta accesible completa y stagger conservados. Sin nueva persistencia,
permisos o activación. Formato/análisis limpios;11 comprobaciones aprobadas,
renders390×844/texto1 y320×350/texto2 revisados sin overflow. Android pendiente.

20/10/2026, composición vigente: título «Su regreso empieza contigo» sin
glass, Poppins26 (antes23), mismos pesos/colores y ampliación del sistema.
La descripción «Una comunidad…» se muestra debajo del perro/gato en la misma
HomeReunionCard glass, conservando imagen3:2. Cerca de ti mantiene glass.
Sin nuevas reglas, permisos, persistencia o activación. Formato/análisis
limpios y11 comprobaciones de arquitectura/captura aprobadas; renders normal
y pequeño/texto2 revisados sin overflow. Pendiente revisión Android con imagen.

20/10/2026: «Explora cerca de ti» reutiliza GlassSurface/radio26 mediante
HomeNotice, igual que las otras tarjetas glass de Inicio. Conserva textos,
padding y acceso real a Explorar; entrada preserveBackdrop. El fallback que
usa HomeNotice comparte el acabado. Sin nueva persistencia, permisos,
dependencias o activación. Formato/análisis limpios y11 comprobaciones de
arquitectura/captura aprobadas; tamaños normal y pequeño/texto2 sin overflow.
Captura normal revisada; pendiente validación visual Android.

20/10/2026, ajuste posterior: se retiran la huella superior de la tarjeta
principal y «Conoce Mis mascotas». Los accesos Reportar/Mis reportes/Mis mascotas
conservan fondo gris #F5F5F7 y usan iconos/texto #459FF6 como el énfasis del título
(corrección explícita del usuario: el azul no corresponde al fondo);
padding vertical16, iconos25, separación10 y texto12.5. Mantienen destinos,
ampliación y columna adaptable; apertura de Reportar desde su color real.
Sin nuevas reglas de dominio, persistencia, permisos o activación.
Formato/análisis limpios y11 comprobaciones de arquitectura/captura aprobadas;
renders390×844/texto1 y320×350/texto2 revisados sin overflow. Captura aislada
del contenido; pendiente revisión visual Android.

20/10/2026: título principal con el estilo de la referencia del usuario:
Poppins local23/altura1.25; «Su regreso» gris/peso400 y «empieza contigo»
azul/peso600, con salto entre ambos. Aproximación tipográfica a la captura,
no identificación de su fuente. Ajuste natural con texto ampliado y frase
accesible completa. No requiere activación, persistencia o permisos nuevos.
[ADR-105](../decisiones/105-titulo-inicio-mobile-referencia-tipografica.md).
Validación: análisis limpio; captura específica390×844/texto1 y320×350/texto2
aprobada y revisada. Suite Home/arquitectura:15 pasan,2 timeout al esperar
el fin del fondo continuo; captura general también bloqueada por esa espera.
Pendiente revisión visual Android; evidencia completa en ESTADO.

Corrección posterior19/10/2026 del usuario: Reportar (nueve puntos) vuelve
a su IconButton circular negro #111111 original, de64px y puntos blancos,
sin degradado, brillo ni sombra azul. El acabado de landing y sus efectos
se conservan únicamente en la selección activa de la barra.
Validación: formato, análisis completo y7 pruebas de Home aprobados.
Pendiente revisión visual Android.

19/10/2026: opción activa y Reportar comparten un acabado local equivalente
a Iniciar sesión de landing: degradado azul, brillo y sombras suaves,
hover/foco/pulsación con elevación2px y oscurecimiento3% en200ms. Movimiento
reducido aplica solo color inmediato. Conserva glass, destinos, origen real
de Reportar, áreas52/64 y selección deslizante320ms. No requiere activación,
persistencia ni permisos nuevos.16 comprobaciones de Home/arquitectura y
análisis aprobados; renders390/320 con texto2 revisados. Pendiente revisión
Android. [ADR-098](../decisiones/098-navegacion-mobile-acabado-boton-landing.md).

19/10/2026: los títulos de fallback Explorar/Mis mascotas usan peso500, igual
que CollectionHeader en las secciones reales, por petición del usuario.
Sin cambios de navegación. Revisión visual Android pendiente.

18/10/2026: la campana Alertas abre la bandeja persistente HU-12, sustituyendo
el aviso de indisponibilidad. Callback compuesto en router; HomeScreen no
importa presentación de notifications. [Ficha](seguimiento-y-alertas.md).

Corrección18/10/2026: la clave de sección pertenece al scroll del contenido,
no al contenedor de toda la pantalla. LiquidNavigation y su Tween conservan
la instancia al alternar Inicio/Explorar/Mis mascotas, restaurando el
desplazamiento320ms y el cambio de destino durante el movimiento. Movimiento
reducido mantiene selección inmediata. Regresión integrada en Home comprueba
identidad, posición inicial/intermedia y cambios rápidos; análisis limpio y
31 pruebas de Home/Explorar/recarga de mascotas/arquitectura aprobadas.
Revisión de fluidez Android pendiente; sin cambios de dominio o permisos.

Refinamiento del gesto compartido: icono de recarga acompaña el descenso, gira durante refresh y retorna al finalizar/cancelar. Se mantiene inscripción por sección y navegación flotante. [ADR-049](../decisiones/049-indicador-recarga-y-retorno.md). Análisis estático sin incidencias; sin nuevas pruebas por instrucción del usuario, pendiente revisión Android.

Actualización del15 de octubre: el scroll principal integra PullToRefresh con destino registrado por la sección visible, Explorar o Mis mascotas. Cada sección controla su ViewModel, sin colaboración entre presentaciones de funcionalidades. Vacío/lista corta permite jalar; el scroll se reinicia al cambiar sección y la navegación flotante conserva su instancia. Inicio sin consulta remota no tiene refresco ficticio. [ADR-048](../decisiones/048-actualizar-listas-al-jalar.md). Análisis sin incidencias, sin pruebas ejecutadas por instrucción del usuario; revisión Android pendiente.

Ajuste del15 de octubre: texto Zona/Zonas sustituido por Ubicación/Ubicaciones y descripción de Explorar actualizada al inicio por ubicación actual/radio15km con alternativa manual. Sin cambios de rutas. Formato/análisis, sin nuevas pruebas por instrucción del usuario. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

Módulo: `home`; composición y protección de rutas en `app`.

## Qué hace y cómo se usa

Es el destino tras iniciar sesión y completar onboarding. Compone Inicio,
Explorar y Mis mascotas mediante la navegación compartida. La cabecera incluye
el acceso al perfil y el control de alertas. Mis mascotas recibe el contenido
real de la funcionalidad pets desde la composición de la app.

HomeViewModel mantiene la sección seleccionada; la pantalla observa ese estado.
Bootstrap/router conectan funcionalidades sin que home importe sus repositorios
ni combine directamente providers de infraestructura.

## Alcance actual y estados

Mis mascotas permite el recorrido documentado en [Mascotas](mascotas.md).
Explorar recibe desde app el listado filtrado real de [Explorar](explorar.md).
Alertas conserva información de disponibilidad pendiente; no hay bandeja operativa.

La cabecera permanece fuera del reveal del contenido. Navegación y cargas
reutilizan las reglas visuales compartidas; al cambiar identidad se protege el
contenido privado y el router devuelve a login cuando corresponde.

## Validación

Comprobar acceso autorizado, cambio de sección, entrada a mascotas/perfil,
cierre de sesión y dimensiones pequeñas con texto ampliado. No atribuir
persistencia de casos o entrega de alertas al shell. Evidencia: [ESTADO](../ESTADO.md).

## Reportar y consultar casos

Reportar permite Mascota perdida (HU-05) y Mascota encontrada (HU-06), con accesos a Mis casos y Mis encontrados. Los botones abren los formularios; solo su publicación confirmada crea un caso. La composición/router protege sesión y onboarding sin importar presentación/data entre funcionalidades. Recorridos completos en [Casos perdidos](casos-perdidos.md) y [Casos encontrados](casos-encontrados.md), con activación/demo real pendientes según ESTADO. Mis encontrados distingue drafts y limpieza pendiente de publicaciones; no muestra identificadores técnicos ni datos ficticios.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.


## Nuevo significado de búsqueda y aviso — 11 de octubre de2026

Por instrucción del usuario, Mascota perdida admite Mi mascota u Otra mascota posiblemente perdida. Mascota encontrada avisa en una búsqueda abierta con La vi o La encontré y está conmigo, sin cerrarla. Desde ficha se vincula automáticamente el aviso; solo el autor confirma Ya fue recuperada. Se conservan UI de Mascotas, coordenadas privadas/zonas públicas y órdenes estables. Aviso admite foto opcional; búsqueda comunitaria exige fotos. Registros anteriores siguen como Reporte anterior, sin reclasificación automática. [ADR-034](../decisiones/034-busquedas-y-avisos-vinculados.md) y [ficha](busquedas-y-avisos.md).

Cambio de alcance autorizado: HU-05/RF-05 y HU-06/RF-06; se adelantan partes app de HU-10/RF-11 y confirmación de HU-13/RF-07. No se cierran historias ni se entrega web/QR, moderación completa, push o exploración/paginación de HU-07. Fuentes062–065/plan018, migración generada y probada localmente; activación remota/Android y concurrencia multiconexión pendientes.


## Panel Reportar y Mis reportes — 12 de octubre de 2026

Sustituye los accesos intercalados anteriores: Reportar contiene únicamente Mascota perdida/Mascota encontrada con explicación breve. Cerrar retirado por instrucción del usuario; modal se cierra con gesto, barrera o Atrás. Inicio ofrece Reportar, Mis reportes y Mis mascotas. [Mis reportes](mis-reportes.md) reúne ambos orígenes con tarjetas/filtro/swipe compartidos; no divide la consulta en enlaces dentro de crear. [ADR-036](../decisiones/036-reportar-y-mis-reportes.md). Sin nuevos SQL o funciones de exploración/alertas.


## Reportar directo — 12 de octubre de 2026

Por decisión explícita del usuario, se retira Mascota encontrada del acceso Reportar y el panel intermedio. Reportar abre Mascota perdida con Mi mascota/Otra mascota. Avisos solo desde ficha abierta con caso vinculado; Mis reportes conserva consulta/gestión. Explorar es destino previsto de consulta pública pero su implementación continúa pendiente. [ADR-037](../decisiones/037-avisos-desde-ficha.md).


## Explorar operativo localmente — 15 de octubre de 2026

Sustituye la disponibilidad pendiente de las notas anteriores: Explorar consulta tarjetas públicas con filtros y paginación y abre las fichas existentes. App inyecta ExploreSection; Home no importa otras presentaciones. La cabecera y navegación se conservan, con entrada cover→stagger; consultas no repiten la animación. Actualizar y retorno desde ficha conservan datos durante refresh. Requiere backend019; evidencia local y pendientes en [ficha](explorar.md)/ESTADO. El16 de octubre HU-07.2 agrega Lista/Mapa sobre la misma consulta, con puntos públicos aproximados y apertura de tarjetas/fichas; sin entrega de alertas. Demo Android/hosted pendiente.
