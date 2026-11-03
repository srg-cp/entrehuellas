# Recorrido de la búsqueda móvil

29/10: BrandMapPin comparte renderer con selectores y Explorar; origen rojo,
avisos azules, numeración/agrupación y48×56 conservados. Sin cambio de datos,
acciones ni movimiento. [Pines de mapa](pines-de-mapa.md), ADR-165.

29/10, [ADR-160](../decisiones/160-origen-completo-y-fases-al-55.md): expansión
desde la tarjeta completa: ilustración en su tamaño real, título, contador,
fechas y flecha, con un solo desvanecimiento hasta55%; destino desde55%.
Sin sustituir la tarjeta por una imagen centrada de120px. Layout compartido
entre origen/copia, scroll parcial y texto ampliado conservados; consulta,
permisos/mapa existentes. Validación y revisión física pendiente en ESTADO.

HU-05/06/10/11, RF-05/06/11/12/14; incremento sobre contratos existentes.
[ADR-153](../decisiones/153-acciones-y-recorrido-de-busqueda-mobile.md) y
[ADR-154](../decisiones/154-recorrido-con-panel-del-mapa-de-explorar.md).

## Qué hace y recorrido

Ficha propia/comunitaria → tarjeta perla «Recorrido de la búsqueda» → mapa y
ubicaciones. Corrección final: sin encabezado «Avisos de esta búsqueda» ni pie
«Ver mapa y cronología»/separador/chevrón. Círculo negro56/flecha diagonal blanca26
arriba a la derecha; un destino para toda la tarjeta. Padding18/radio28/gap16 y
separación etiqueta/valor3 compartidos con datos mediante CasePublicGlassCard.
Pin rojo para origen y celestes numerados para avisos.
El resumen muestra cantidad real visible al lector, inicio y último suceso.
Contador sin «Origen»: avistamiento(s) y «Sin avistamientos»; con custodia usa
aviso(s) sin alterar su clasificación.
Por corrección del usuario26/10, comparte CaseCardTypography con la tarjeta perla
superior: misma familia, etiquetas14/400 y título/valores17/600, interlineado y
colores de texto. Sin estilos locales de tipografía ni cambios de material.
Sin avisos conserva el origen y declara ausencia confirmada. Ilustración decorativa
no representa resultados; todos los textos/controles son nativos.

La pantalla abierta reutiliza los componentes reales del mapa de Explorar:
mapa completo, retorno/cápsula «Recorrido», panel blanco deslizable con foto,
nombre/rasgos públicos del origen, flecha celeste, Ver ficha y «Ubicaciones».
Medidas, tipografía compacta, colores y movimiento compartidos mediante
MapCaseSheet/MapCasePanel/MapSheetHeader en core. La tarjeta perla anterior
conserva su diseño; la superficie blanca solo corresponde a esta pantalla.

Por instrucción explícita, Ver ficha/flecha de este panel son adornos temporales:
visibles con colores completos, sin callbacks, foco ni semántica de acción.
Explorar mantiene esos controles funcionales. Las filas/pines sí centran su zona;
cada fila muestra fecha y, si está autorizada, revisión de la evidencia privada.
Puntos coincidentes comparten marcador/contador sin inventar coordenadas. Línea
por hora del suceso ascendente, no ruta vial ni trayecto real confirmado.
Ver seguimiento de la ficha conserva acceso al historial/revisión existente.

Refinamiento26/10: Ubicaciones usa puntos con halo suave en lugar de iconos de
pin: rojo para Origen y celeste para los avisos. Una línea vertical punteada gris
une los puntos, sin tramo sobrante al final ni línea cuando solo existe el origen.
Altura adaptada a las filas/texto ampliado; conserva fechas, orden y selección.
Los pines del mapa y las filas de detalles de Explorar mantienen su aspecto.

## Persistencia y permisos

Sin persistencia nueva. Contratos públicos de casos y list_recovery_observations;
evidencia de case_timeline solo para lector autorizado en servidor. Se valida
relación con el caso. Coordenadas exactas privadas se aproximan antes de renderizar.
Rechazados permanecen en historial; los otros conservan revisión. Aviso con custodia
mantiene clasificación sin cerrar la búsqueda.

Ver seguimiento abre historial/revisión existente, distinto del mapa de la tarjeta;
Cartel y cierre mantienen sus permisos. No habilita GPS ni publica evidencia
privada. Ficha offline conserva restricciones y oculta acciones remotas.

## Errores y reintentos

La vista cartográfica se actualiza arrastrando hacia abajo desde el inicio del
scroll con el panel en su mínimo, mediante PullToRefresh compartido con las
secciones. No tiene botón
«Actualizar recorrido» ni subtítulo superior «Origen · ...». Scroll siempre
desplazable, incluso con poco contenido; el indicador entra desde arriba y se
retira al terminar. Una consulta activa bloquea nuevos envíos de refresco.

Skeleton inicial, toast superior y reintento; fallos no se convierten en vacío.
Cambio de cuenta oculta estado/selecciones anteriores y restaura cabecera/retorno.
Al actualizar se consulta autorización vigente. Mapa conserva estilo/créditos/retina
y reintento compartidos; no afirma precisión ni ubicación actual.

## Dependencias y validación pendiente

Refinamiento de puntos26/10:32 pruebas existentes de Recorrido/Explorar/
arquitectura/consistencia aprobadas y análisis limpio. Capturas normal/texto200%
de la cronología inspeccionadas;16 capturas de Explorar idénticas. Sin nuevo
APK/instalación; revisión Android real pendiente.

Diseño vigente ADR-154,26/10:62 pruebas de recorrido/Explorar/flujo real/mapas/
retina/cronología/fichas/refresco/arquitectura/consistencia aprobadas, análisis
limpio.16 capturas de Explorar idénticas antes/después de la extracción a core.
Recorrido normal y320px/texto200% inspeccionado; controles decorativos conservan
colores y carecen de acción/semántica. Foco de ubicación, refresco, retirada por
denegación, retorno y reintento comprobados con fixtures. Bundle Flutter debug
compilado; APK/instalación y demo Android real pendientes. Resultados del diseño
anterior debajo conservados como historial.

Refresco por gesto26/10:42 pruebas de recorrido/flujo/refresco compartido y
regresión aprobadas, análisis sin incidencias. Gesto real normal/texto200%,
lectura, contenido retenido, bloqueo simultáneo y dato nuevo comprobados.

Refinamiento final26/10:32 pruebas de recorrido/ficha/flujo real/arquitectura/
consistencia y análisis aprobados; capturas normales y texto200% inspeccionadas.
No genera APK nuevo ni cambia permisos/activación.

Contratos existentes de casos/avisos/timeline, sin SQL nuevo. Arte imagegen:
[procedencia y prompt](../../output/imagegen/case-journey-2026-10-26/README.md).
Resultados/capturas en [ESTADO](../ESTADO.md). Demo Android con cuentas/fotos/
teselas reales distinta de pruebas locales; sin cierre de historias ni despliegue.

Validación final26/10:102 comprobaciones aprobadas y análisis sin incidencias,
bundle Flutter compilado. Capturas normal/texto200% y apertura/retorno inspeccionadas.
APK pendiente por fallo local Java/Gradle al establecer conexión loopback, antes
de compilar; este bloqueo no se atribuye a una operación del producto.
