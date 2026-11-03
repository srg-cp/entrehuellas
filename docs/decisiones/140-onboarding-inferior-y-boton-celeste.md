# ADR-140: onboarding inferior y botón celeste de la landing

Fecha: 25 de octubre de 2026. Estado: aceptada por instrucción explícita.

## Precisión posterior vigente: botón móvil original y avance solo por acción

El usuario conserva la tipografía del móvil y pide recuperar el tamaño anterior
del botón: mínimo68px, padding28 horizontal/18 vertical, texto22/peso600/altura1.15,
radio26 e icono26. Mantener el degradado/luz, la etiqueta y flecha juntas centradas,
la composición inferior y la ausencia de puntos. Esta precisión sustituye para
Flutter las medidas48/radio18/texto16/padding8/12 descritas abajo.

El onboarding móvil desactiva el gesto horizontal; solo Continuar avanza y
Comenzar guarda en la tercera etapa. PageView conserva su desplazamiento
programático y entrada existente; el scroll vertical accesible sigue activo.
Web conserva íntegramente su geometría Sader48/radio18 y padding8/12.
Con texto ampliado móvil permite apilar la flecha debajo de la etiqueta,
manteniendo el ancho disponible para la palabra y sin reducir la escala del texto.

## Contexto

El usuario pide tomar la composición y geometría del botón Continuar del
onboarding de sader-panel en web y móvil, con el color y la luz de Iniciar sesión
de la landing de Entre Huellas. Solicita retirar los tres puntos del móvil.

## Decisión

- En móvil, ilustración, título, descripción y acción forman una columna apoyada
  abajo, con texto alineado al inicio, margen lateral24 y margen inferior60
  dentro del área segura. Si no cabe, el grupo permite scroll vertical.
- Web conserva la composición Sader existente: margen lateral24, inferior mínimo60,
  columna máxima448 y centrado vertical desde640px. Marca superior persistente.
- Botón de ancho completo, altura mínima48, radio18, texto16/peso500 y separación8
  entre etiqueta y flecha, centradas como un conjunto. El texto ampliado puede
  aumentar la altura del control. Ilustraciones y títulos Poppins32/400 conservados.
- Precisión explícita del usuario: padding interno idéntico a Sader,8px vertical
  y12px horizontal (py-2 y has-[>svg]:px-3). Web ya lo usaba; móvil corrige12→8
  vertical, conservando altura mínima48 y margen lateral exterior24.
- Usar el degradado vertical #75bfff → #459ff6 al48% → #2887ef, blanco,
  luz superior y sombra azul de la landing; no el azul plano de Sader.
- Web comparte variables --brand-action-* entre landing y onboarding, sin
  modificar la geometría ni los estados de la landing. Flutter reutiliza
  BrandActionButton y BottomContentLayout en core/presentation/widgets.
- Retirar puntos visibles; conservar «Paso N de3» accesible. Tres etapas originales,
  sin Omitir, y guardado real por cuenta, bloqueo, toast y reintento conservados.
  Shimmer cubre todo el control únicamente durante guardado, según ADR-139.

## Alcance y consecuencias

Sustituye el botón negro y la composición centrada del onboarding móvil, y el
color negro del botón web de ADR-074. No migra acceso, recuperación u otros
recorridos. No copia el tema oscuro, roles, textos ni controles de Sader.
Conserva los motores de transición existentes; esta intervención de composición
y acabado no acredita auditoría ni paridad global de animaciones.

## Validación

Comprobar las tres etapas, entrada por botón/gesto móvil, finalización y reintento,
semántica, texto ampliado, scroll, movimiento reducido y acabado compartido con
landing. Evidencia local y límites en ESTADO y en la ficha de onboarding.
