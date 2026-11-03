# Ficha pública móvil por tarjetas glass

30/10: [ADR-168](../decisiones/168-retirada-completa-avistamientos-privados.md) retira por completo el sistema privado, por aclaración del usuario de que no existen registros antiguos. Sin compatibilidad de envío/revisión privada. Avisos públicos, notificaciones e historial de publicación/recuperación conservados; SQLite3 limpia slots retirados. Plan042 elimina tablas/RPC y actualiza dependencias; activación remota pendiente. Las notas anteriores son históricas.

29/10: [ADR-167](../decisiones/167-ayuda-publica-unificada-con-cuenta.md) sustituye la doble entrada de ficha por «La vi o la encontré»: aviso público vinculado y alerta al creador según preferencias. QR requiere cuenta para publicar y conserva consulta pública. Históricos privados intactos; plan041/servidor pendientes de activación. Las notas anteriores sobre doble acceso son históricas.


29/10, [ADR-166](../decisiones/166-acciones-de-avistamiento-en-tarjetas-grises.md):
«Reportar avistamiento» y «La vi o la encontré» usan dos tarjetas sólidas gris
claro, radio22, icono21 arriba a la izquierda y etiqueta14/600 debajo;
padding14 horizontal/20 vertical. Referencia elegida archivada en
[mockups](../../mockups/acciones-ficha-tarjetas-grises.png). Sin subtítulos
inventados; dos columnas de igual altura, apiladas en ancho pequeño/texto
ampliado. CaseUtilityButton y CaseActionLayout compartidos; origen completo,
rutas, retorno y permisos conservados. Recuperación sigue circular debajo.
Excepción local a ADR-148/153 solo para estas dos acciones móviles; web y otros
controles conservados. Validación y revisión física pendiente en ESTADO.

29/10, [ADR-163](../decisiones/163-favorito-mobile-amarillo-y-particulas.md):
marcador favorito amarillo tras confirmación; pequeño rebote y seis partículas
amarillas discretas alrededor de la parte inferior al guardar. Se conserva el
control compartido y su área táctil; sin animación en reducido ni al consultar
favoritos existentes. [Reglas y validación](casos-guardados.md).

29/10, [ADR-160](../decisiones/160-origen-completo-y-fases-al-55.md): utilidades
y tarjeta Recorrido entregan el contenido completo al morph, incluidos
textos, ilustración, contador y fechas, en sus posiciones reales. Etiquetas
externas a círculos siguen fuera de su origen. Fases móviles55/55; scroll
parcial y texto ampliado conservados. Sin cambios de lectura/permisos/acciones.
Validación local y revisión física pendiente en ESTADO.

29/10, [ADR-159](../decisiones/159-foto-publica-mas-alta-y-visor-completo.md): foto pública móvil más alta sin cambiar ancho;
tocar abre visor completo sin recorte, con zoom y galería desde la foto activa.
Cerrar conserva foto/scroll. Skeleton adaptado, proveedores/permisos existentes
y entrada única/reducido; validación y pendientes en ESTADO.

29/10, [ADR-157](../decisiones/157-vista-previa-perdida-con-ficha-actual.md):
las vistas previas de pérdida propia/comunitaria ahora comparten estos renderers
y CasePublicScreenShell, con título Vista previa, aviso preventivo y acciones
reales de publicar/editar. Sustituye la reserva inmersiva solo en esos previews;
la consulta pública y los otros consumidores del patrón inmersivo se conservan.

29/10: el motor móvil compartido elimina la cortina/fondo local previo al
stagger; una entrada por etapa y sin repetición al resolver skeleton o editar.
[Alcance y validación ADR-156](../decisiones/156-entrada-mobile-unica-sin-cortinas.md).
Revisión física con nueva compilación pendiente; datos/permisos conservados.

26/10, [ADR-154](../decisiones/154-recorrido-con-panel-del-mapa-de-explorar.md):
el destino de la tarjeta Recorrido adopta el mapa/panel real de Explorar, con
cabecera «Recorrido» y «Ubicaciones». Flecha celeste/Ver ficha permanecen como
adornos temporales sin acción solo en ese destino; tarjeta perla y demás opciones
de esta ficha conservadas. [Recorrido/validación](recorrido-de-busqueda.md).

Corrección final26/10 de ADR-153: tarjeta Recorrido sin encabezado «Avisos de esta
búsqueda» ni pie «Ver mapa y cronología»/separador/chevrón. Círculo negro56 con
flecha diagonal26 en esquina superior derecha, un único destino. Padding18,
radio28, gap16 y separación etiqueta/valor3 compartidos con CasePublicGlassCard.
Contador sin «Origen»: avistamiento(s)/Sin avistamientos, o aviso(s) con custodia.

26/10, [ADR-153](../decisiones/153-acciones-y-recorrido-de-busqueda-mobile.md):
acciones compactas aprobadas, Reportar con NavigationAccentSurface, Seguimiento
y Cartel contiguos. Avisos pasan a tarjeta perla de [recorrido](recorrido-de-busqueda.md),
un acceso a mapa/cronología. Origen rojo/avisos celestes con logo; arte separado.
Mapa principal, contacto, navegación y permisos conservados.

Corrección26/10: Recorrido y tarjeta perla de datos usan CaseCardTypography
compartida: familia del tema, etiquetas14/400/1.4, título/valores17/600/1.3 y
colores de texto de la tarjeta superior. Se elimina la jerarquía local distinta
del recorrido sin cambiar superficies, geometría, acciones ni mapa.

26/10, [ADR-150](../decisiones/150-teselas-retina-y-ubicacion-compacta.md):
cápsula Ubicación compacta con icono16/texto14/padding14–8, glass polished.
ZoneMapPicker comparte retina nativo CARTO en DPR alto y shimmer por teselas
pendientes; conserva estilo, coordenadas públicas, créditos, fallo/reintento.
44 pruebas+3 de retina nativo y análisis correctos; HTTP puntual200 en256/512px.
Sin confirmación de causa del vacío intermitente ni revisión Android física.

Corrección26/10: la cápsula «Ubicación» usa GlassSurface polished con ribete original, según la regla obligatoria ADR-148; el acabado perlado/frosted queda reservado a tarjetas de contenido. Se conserva posición, radio, texto, mapa y datos.

26/10, [ADR-149](../decisiones/149-mapa-protagonista-ficha-publica-mobile.md):
mapa a todo el ancho de la tarjeta con marco6/radios34–28 y cápsula glass
«Ubicación» dentro, centrada abajo. Fecha debajo; se retiran cabecera exterior
y aviso visible de ubicación aproximada. Mantiene coordenadas públicas/radio1000,
créditos, cartografía compartida y reintento. Skeleton equivalente y altura
adaptada al texto200%; vistas previas inmersivas conservadas. Validación:34
pruebas y análisis sin incidencias; capturas con teselas simuladas, Android pendiente.

26/10, [ADR-148](../decisiones/148-restaurar-glass-controles-y-navegacion-mobile.md):
Volver/Compartir recuperan glass polished/ribete originales. Tarjetas conservan
perlado sin borde; contacto sólido ADR-146 y operaciones se mantienen.

26/10, corrección posterior [ADR-146](../decisiones/146-contacto-mobile-solido-segun-referencia.md):
contacto móvil con cápsula lavanda sólida, acciones blancas e iconos azules rellenos,
sin glass en superficie ni botones, según la nueva referencia del usuario.
Sustituye el acabado de ADR-113/145 solo en este bloque. Mantener identidad real,
consentimiento, SMS/marcador, permisos y adaptación a texto ampliado.


26/10, [ADR-145](../decisiones/145-glass-perlado-compartido-mobile.md): ficha,
contacto y controles adoptan el mismo material gris perla del Home, luz difusa
blanca/celeste y ausencia de contorno blanco. Sustituye las reservas históricas
de ribete/acabado anterior. Datos, galería, scroll, geometría, ampliado, acciones
y permisos se conservan. Validación y pendientes en ESTADO.

23/10, por instrucción del usuario, [ADR-133](../decisiones/133-acciones-de-ficha-y-navegacion-glass-compartida.md):
la cabecera conserva únicamente Volver y Compartir. Favoritos, Seguir/Dejar de
seguir y Bloquear/Desbloquear pasan al panel «Compartir ficha», junto a Descargar/Denunciar: círculos grises56, iconos26, sin texto visible,
con tooltip y semántica. Wrap centra los controles y permite varias filas. Las opciones mantienen
sus ViewModels, permisos, confirmaciones, shimmer, toast y reintentos. Seguir
conserva su disponibilidad anterior por tipo de caso y bloqueo no se ofrece
contra la propia cuenta. El contacto permanece en el cuerpo de la ficha.

GlassNavigationBar concentra el inset superior seguro +4 y márgenes simétricos24,
fuera del scroll; lo consumen CasePublicScreenShell y EntityScreenShell. Se retira
el hueco de Guardar en cabecera. Esto sustituye las notas anteriores de tres
controles; no implica migración de todas las pantallas ni cambios en QR/web.
Composición por slots desde router, sin imports de presentación entre features.
No cambia SQL, persistencia, privacidad ni los dos recorridos de avistamiento.

Validación de este incremento y límites en [ESTADO](../ESTADO.md). Pendiente
revisión en dispositivo Android y aprobación visual del usuario.

Compartir20/10, ADR-115: acceso junto a Guardar, con [panel blanco sin X](compartir-ficha.md). Denunciar se traslada al icono del panel; las demás operaciones del cuerpo permanecen. Descargar usa el PDF público existente; enlaces públicos de búsquedas activas por RPC nueva032. Título en fila propia bajo380px o con texto ampliado para reservar los tres controles.

Refinamiento20/10 por corrección visual del usuario: etiqueta del caso a la derecha del nombre y centrada verticalmente en la misma fila; puntos de galería centrados debajo. Con texto ampliado o etiqueta larga se apilan y la foto crece. Tarjetas y controles de contacto usan GlassSurfaceFinish.frosted (ribete blanco único, sombra suave y tono perla/celeste traslúcido), sin doble borde oscuro ni relleno gris adicional. Volver/guardar e ImmersivePhotoSheet conservan su acabado. Renders comparados con el mockup; ver validación en ESTADO.

Incremento20/10 de HU-05/06/07, RF-05/06/13. Implementado localmente según
[ADR-113](../decisiones/113-ficha-publica-tarjetas-glass.md); no cierra historias.

## Qué hace y recorrido

Ver ficha desde Explorar, mapa, Guardados o casos propios abre el mismo detalle
existente. Perdidos y encontrados comparten CasePublicCards/CasePublicScreenShell.
Foto en galería, nombre y etiqueta, contacto autorizado, datos etiquetados y
rasgos expandibles, fecha de observación/desaparición, mapa aproximado y acciones.
Volver/guardar conservan sus controles glass, permisos y operación reales.
El título sale con el scroll; los controles permanecen flotantes y accesibles.

## Datos y acciones

Perdidos: nombre, especie, sexo/tamaño/edad si constan y rasgos disponibles.
Encontrados/avisos: especie o detalle real, sexo/tamaño/cuidado si constan, sin
inventar nombre ni edad. Etiqueta distingue posible pérdida, avistamiento,
encontrada y cierre. Sin fotos usa alternativa semántica; no muestra fotos falsas.
Mapa usa coordenadas públicas/radio1000m y señala privacidad; ninguna ciudad o
referencia exacta inventada. Conserva crédito configurado y reintento compartidos.

Seguimiento se ofrece solo con el permiso existente de cronología. CTA azul
Reportar avistamiento en búsquedas activas; después se conservan seguir/dejar de
seguir, cartel del autor, avisos/custodia, cierre y denuncia según permisos.
El contacto y sus acciones se describen en [su ficha](contacto-reportante.md).

## Persistencia, errores y dependencias

Este layout no cambia repositorios ni RPC de casos. Consume las proyecciones
actuales mediante ViewModels; contacto se compone por slot desde router.
Skeleton por tarjetas en carga inicial; refresco de la misma identidad conserva
contenido con shimmer. Error/validación/resultado van al toast; reintento real.
Cambiar identidad elimina contenido anterior según los ViewModels existentes.
Reutiliza GlassSurface, ZoneMapPicker/MapStyle, descripción, LoadingShimmer,
cover/stagger, NavigationAccentSurface, AppScaffold y controles de navegación.

## Diseño conservado y validación

[ImmersivePhotoSheet](ficha-fotografica-inmersiva.md) se conserva íntegro y sigue
en vistas previas de publicar; no es el diseño de Ver ficha actual.
Mockup aprobado en mockups/ficha-publica-glass-contacto.png, solo referencia.
Layouts390×844 y320×350/texto2, galería, descripción, mapa público y acciones
probados con movimiento normal/reducido y renders locales. Datos/fotos de los
tests son fixtures, nunca se incorporan a la UI del producto. Las teselas de
las capturas de pruebas son simuladas; no prueban red/proveedor real.
Resultados en ESTADO. Pendientes revisión física Android y activación del contacto
en Supabase mediante031; sin APK ni despliegue web/backend.
