# Onboarding por cuenta

## Texto natural y posiciones estables —25/10/2026

[ADR-142](../decisiones/142-onboarding-texto-natural-y-posiciones-estables.md):
títulos/descripciones sin saltos forzados, con ajuste natural como Sader. Los
contenedores reservan la máxima altura de las tres alternativas para el ancho
y texto ampliado actuales; título, descripción y acción mantienen posiciones.
Flutter usa TextPainter/TextScaler y minHeight; web CSS grid con muestras
invisibles/aria-hidden. Solo el texto vigente es accesible. Sin cambiar palabras,
tipografía, PNG, controles, marca, stagger ni persistencia. Scroll conservado.

La segunda etapa variaba por la descripción de tres líneas explícitas; el
contenedor de imagen ya tenía iguales dimensiones en las tres. Esta precisión
sustituye los saltos manuales heredados de la composición inicial.

## Transición vigente —25/10/2026

[ADR-141](../decisiones/141-onboarding-mobile-stagger-como-web.md) sustituye también
el desplazamiento programático del móvil por stagger igual a OnboardingFlow web:
presión400ms y cuatro grupos550ms/90ms, entrada superior primero y salida inversa,
opacity/blur18/traslación vertical local56. La marca permanece estable y solo se
monta una etapa. No hay PageView ni gesto horizontal, tampoco deslizamiento de página.

Se bloquean toques durante las fases sin activar shimmer. El guardado final real
mantiene contenido y shimmer; tras confirmación completed, sale y el ViewModel
acknowledgeCompletion autoriza reevaluar entrada. Error conserva la tercera etapa.
Reducido omite animaciones/esperas y una preferencia cambiada durante la salida
la completa inmediatamente; desmontar cancela tickers. Persistencia/permisos
conservados. El botón grande de ADR-140 y el scroll vertical se mantienen.

Evidencia local: regresión de fases/orden, toques repetidos, x estable, marca,
guardado pendiente/fallo/reintento, reducido durante fase y cancelación por dispose.
Capturas intermedias en onboarding-sader/motion-*.png. Revisión del usuario y
prueba física Android pendientes; no se afirma auditoría global de movimiento.

## Ajuste móvil vigente —25/10/2026

Por precisión posterior del usuario, móvil recupera el botón anterior: altura
mínima68, padding horizontal28/vertical18, texto22/peso600/altura1.15, radio26 y
flecha26. Conserva fuente del sistema, degradado/luz y etiqueta/flecha juntas
centradas. Solo Continuar cambia de etapa y Comenzar guarda: el gesto horizontal
se desactiva mediante NeverScrollableScrollPhysics, manteniendo PageView
programático, tres etapas, animación existente y scroll vertical accesible.
Web no cambia y mantiene48/radio18/texto16/padding8/12. Esta instrucción sustituye
las medidas móviles de la primera versión de ADR-140 descrita a continuación.

Regresión: intentar avanzar/retroceder con gestos en las tres etapas no cambia
la página; botones y guardado/error/reintento siguen disponibles. Capturas locales
normal y texto200%/reducido se regeneran en onboarding-sader. Revisión física
Android y confirmación visual del usuario pendientes.

## Composición y botón —25/10/2026

[ADR-140](../decisiones/140-onboarding-inferior-y-boton-celeste.md): web y móvil
usan geometría Sader con botón celeste y luz de Iniciar sesión de la landing.
Móvil reúne ilustración/texto/acción en un bloque inferior desplazable, alineado
al inicio, con24 laterales y60 inferiores dentro del área segura. Sin puntos
visibles; conserva progreso accesible, tres etapas y textos/PNG originales.
Web conserva columna448, margen inferior60 y centrado desde640px.

Reutilización: BottomContentLayout recibe el grupo de contenido/acciones;
BrandActionButton recibe etiqueta, callback y estado real isBusy. Ambos viven
en core/presentation/widgets de Flutter; no trasladan lógica de dominio al layout.
La piel web comparte --brand-action-* desde assets/brand-action.css entre landing
y onboarding; sus dimensiones y transiciones siguen en onboarding.css.
Botón mínimo48/radio18/texto16/peso500, etiqueta y flecha centradas juntas.
Padding interno8 vertical/12 horizontal en ambas plataformas, igual a Sader;
margen exterior lateral24. Precisión del usuario posterior a la primera revisión:
Flutter corrige su padding vertical de12 a8; web ya coincidía.
Texto ampliado ajusta líneas y crece; shimmer envuelve el control completo.
No aplica automáticamente esta composición a otras pantallas.

Persistencia/RPC/permisos y activación sin cambios. Evidencia local: pruebas
de cuenta/recorrido/shimmer/arquitectura, Chrome con backend fixture y capturas
de tres etapas móvil390×844 y320×600/texto200%/reducido. Confirmación visual del
usuario, revisión Android física y nueva finalización remota pendientes.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Auditoría de seguimiento18/10:** HU-01.5/#21 en Done: tres etapas sin Omitir, RPC/persistencia por cuenta y reintento implementados e integrados; pruebas existentes aprobadas. No se ejecuta una nueva finalización de cuenta por este cambio de seguimiento.

Módulo: `onboarding`. Decisión: [ADR-004](../decisiones/004-onboarding-por-cuenta.md).

## Qué hace y cómo se usa

Después de iniciar sesión, una cuenta que no completó el onboarding recorre
tres etapas introductorias. No se ofrece Omitir. Comenzar en la tercera etapa
guarda la finalización antes de permitir entrar a la app.

Al volver a iniciar sesión, una cuenta completada entra directamente a la app.
Una cuenta distinta tiene su propio estado: completar el recorrido en un
dispositivo no completa el onboarding de todas las cuentas de ese dispositivo.
Se respetan finalizaciones existentes reconocidas por el servidor.

## Reglas, datos y errores

EntryViewModel consulta CheckOnboarding junto con la sesión; OnboardingViewModel
coordina etapas y CompleteOnboarding. La finalización se persiste en el perfil
de la cuenta mediante una RPC protegida, no con un indicador global local.
Sin sesión se vuelve a login. Si falla consulta o guardado, se permite reintentar
y no se autoriza saltar el recorrido. El router no se recrea en cada evento.

La UI mantiene progreso accesible sin puntos visibles y transiciones por etapa, respetando
movimiento reducido. No repite animaciones por edición ni por cada frame de un gesto.

## Dependencias y validación

Depende de Auth, perfil y RPC de finalización. Verificar cuenta nueva, cuenta
completada, reinicio, cambio de cuenta y fallo de red al pulsar Comenzar.
El registro de pruebas ejecutadas y pendientes está en [ESTADO](../ESTADO.md).

## Corrección de consistencia — 11 de octubre de 2026

Entrada observa el contrato de sesión y CheckOnboarding sin importar ViewModels de auth. El cierre usa SignOut mediante EntryExitViewModel. Fallos de consulta, guardado y salida usan toast; reintentos conservados.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.
