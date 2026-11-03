# ADR-155: login móvil con una sola entrada sin cortina

Fecha:29/10/2026, America/Lima. Corrección solicitada por el usuario.

La captura de iPhone muestra un rectángulo de fondo dentro del formulario antes
de su entrada. AccessScreen aún usaba AuthStageTransition(startCovered: true):
dibujaba AppPageBackground con las dimensiones del formulario durante320ms y
solo después iniciaba StaggerReveal. ADR-094 retiró esa fase exclusivamente
de Inicio/Explorar, por lo que el login conservaba el defecto.

AccessScreen usa directamente su StaggerReveal existente de11 posiciones,
sin cortina ni fondo adicional. Conserva orden, duración, curva, marca fija,
layout, movimiento reducido y comportamiento de autenticación. StartupReveal
continúa antes de montar el destino. Esta corrección sustituye cover→stagger
de ADR-006 solo para la entrada del login móvil; no migra otras etapas ni web.

La regresión monta StartupReveal y AccessScreen reales, recorre120 fotogramas,
comprueba fondo único, ausencia de CoverReveal, marca estable, progreso continuo
y conservación de la instancia al editar. Incluye movimiento reducido.
La revisión en iPhone instalado queda pendiente; las pruebas locales no
acreditan una compilación iOS nueva.
