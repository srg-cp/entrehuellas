# ADR-141: transición de onboarding móvil igual a web/Sader

Fecha:25 de octubre de2026. Estado: aceptada por instrucción explícita.

## Contexto

El usuario solicita retirar también el movimiento lateral programático del
onboarding móvil: bloquear el gesto de PageView no eliminaba ese efecto.
Pide reproducir el stagger reveal del onboarding web de Entre Huellas/Sader.

## Decisión

- Retirar PageView, PageController, animateToPage y su coordinación de llegada.
  Solo se monta una etapa, con scroll vertical; Continuar inicia el cambio.
- Usar el contrato real de OnboardingFlow.vue: cuatro grupos (ilustración,
  título completo, descripción y acción),550ms por grupo, separación90ms,
  desplazamiento local vertical+56px y blur18→0, opacity0→1, curva
  cubic-bezier(.22,1,.36,1). Cada fase completa dura820ms.
- Entrada de arriba hacia abajo; salida hacia+56px en orden inverso: acción,
  descripción, título e ilustración. No deslizar toda la página ni superponer
  etapas. La etapa anterior se desmonta solo cuando termina su salida.
- Presión del botón400ms (200+200, escala1→.93→1) antes de la salida, como web.
  Bloqueo de toques repetidos durante presión, salida y entrada; no usar shimmer
  para estas esperas de animación. Marca persistente fuera de la secuencia.
- Comenzar conserva contenido/shimmer durante guardado real. ViewModel registra
  completed solo tras confirmar repositorio; acknowledgeCompletion invalida la
  entrada después de terminar salida. Un fallo conserva contenido y reintento.
  No cambiar RPC, dominio, repositorios ni permisos.
- Movimiento reducido omite presión/blur/desplazamiento/esperas. Un cambio de
  preferencia durante la fase la completa inmediatamente; dispose cancela los
  tickers y no deja cambios de etapa diferidos.
- Se conserva el diseño móvil de ADR-140: botón68/radio26/texto22/600 y padding
  28/18, fuente del sistema, celeste/luz, composición inferior y sin puntos.
  Web no cambia.

## Implementación y evidencia

StaggerStageTransition/StaggerStageItem son widgets compartidos de presentación;
la pantalla coordina las fases mediante su estado y el ViewModel mantiene el
resultado del guardado. El StaggerReveal anterior conserva sus consumidores y
sus parámetros; no se migra globalmente ningún otro recorrido.

Ver ESTADO para pruebas, capturas intermedias de presión/salida/entrada y límites.
La equivalencia se revisa en este onboarding; no acredita paridad global.
