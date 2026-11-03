# ADR-161: marca estable entre animación de arranque y espera de cuenta

Fecha: 29/10/2026. Estado: aceptada por instrucción del usuario.

## Contexto

Las capturas del usuario muestran un cambio de tamaño y posición cuando termina
el arranque y todavía se está preparando la cuenta. StartupReveal dibujaba un
icono96 y lettering36 dentro de un ancho268 con espacio sobrante a la derecha;
EntryScreen usaba icono80/lettering32, separación16 y centrado en SafeArea.
La espera hace visible esa diferencia; el código no permite atribuir su duración
en el dispositivo a señal, CPU o una consulta concreta.

## Decisión

Reutilizar BrandWordmark.startup en las dos etapas, con icono80, lettering32,
separación16 y ancho calculado desde las dimensiones reales de BrandName.
Centrar ambas en la misma área segura y aplicar el mismo ajuste scaleDown,
sin padding exclusivo del arranque. Conservar las proporciones gráficas de la
marca con texto ampliado y su etiqueta accesible.

Conservar1100ms, intervalo18–85%, easeOutBack, aparición del nombre detrás del
icono y sobrepaso exclusivamente horizontal. El icono comienza centrado; el
conjunto completo termina centrado en el rectángulo de la espera y se mantiene
inmóvil mientras esta dure. Movimiento reducido entrega directamente el destino.
No prolongar la animación por red ni agregar temporizadores, cortinas o entradas.

Es una corrección móvil de presentación del acceso existente HU-01/RF-01;
no cambia sesiones, preparación de cuenta, errores, reintentos ni permisos.
Splash nativo, web y restantes tamaños de BrandWordmark conservados.

## Validación

Regresión con EntryScreen real y ViewModel de prueba pendiente: comparar
rectángulos de icono/nombre antes y después del relevo, tras cinco segundos de
espera y al resolver. Referencia independiente: composición estática anterior
icono80/lettering32. Matriz iPhone/Android, pequeño con texto200%, ancho extremo
y horizontal, con movimiento normal/reducido. Conservar prueba de fotogramas
intermedios, sobrepaso horizontal y entrada directa del destino disponible.
Resultados y revisión física pendiente en ESTADO.
