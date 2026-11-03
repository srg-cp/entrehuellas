# ADR-152: cabecera y desvanecido compartidos entre secciones móviles

Fecha:26/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Decisión

El desvanecido aprobado pertenece a la composición de cabecera/scroll, no al
contenido de Inicio. La cabecera con marca, Alertas y avatar se comparte entre
Inicio, Explorar y Mis mascotas en HomeScreen. Retirar la condición que activaba
el efecto únicamente en HomeSection.home.

FadingHeaderScroll, en core/presentation/widgets, concentra medición de cabecera,
viewport solapado, padding compensado, scroll y máscara alfa irregular. Recibe
cabecera, contenido, padding propio de sección y clave de identidad del scroll.
No conoce funcionalidades, Riverpod ni datos. Retirar HomeScrollLayout y
HomeScrollFade locales; la implementación del efecto permanece única.

Conservar forma de cuatro prolongaciones difusas/entradas claras, solape32px,
profundidad24–48px limitada al40% de ventanas bajas, curva, fondo vivo y reducido.
Cabecera pintada por encima, marca/Alertas/avatar nítidos y posiciones iniciales
conservadas. Cambiar sección reinicia scroll/máscara conjuntamente. Notificaciones
de scroll siguen propagándose a refresh, paginación y observadores existentes.
Materiales, dimensiones y movimiento de controles/barra siguen ADR-148.

Barra inferior, Reportar y acción Mapa permanecen fuera de la máscara. Fichas y
editores con sus propias cabeceras Volver/Cerrar conservan sus componentes;
no son consumidores de esta cabecera de marca. Sin migración web ni cambios de
dominio, permisos, repositorios, SQL, assets o activación de funcionalidades.
Sustituye únicamente la restricción a Inicio de ADR-151.

## Validación

64 comprobaciones locales aprobadas. Análisis de lib/test/tool sin incidencias;
formato y diff comprobados. Se fija AMBIENT_BACKGROUND_MOTION=false para las
pruebas con pumpAndSettle, sin desactivar los recorridos normales de navegación.

Pruebas de secciones, origen/retorno normal/reducido, refresh, Explorar/mapa,
mascotas, arquitectura y consistencia. Regresiones gráficas verifican entradas
claras/prolongaciones, contenido opaco y máscara activa en las tres secciones,
reinicio al cambiar y cabecera/barra estables, con y sin movimiento reducido.

Harness con widgets reales de Explorar y Mis mascotas y repositorios simulados
solo en pruebas: capturas iniciales/desplazadas en390×844,320×600 y320×350 con
texto200%. Registros de prueba sin fotos usan el placeholder real. No acredita
datos alojados. Resultados de ejecución en ESTADO. Pendiente Android físico y
aceptación visual; APK sin recompilar/instalar, sin despliegue ni cierre de HU.
