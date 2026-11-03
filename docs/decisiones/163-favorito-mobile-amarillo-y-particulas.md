# ADR-163: favorito móvil amarillo con partículas discretas

Fecha: 29/10/2026. Estado: aceptada por instrucción explícita del usuario.

En la ficha pública móvil, el marcador confirmado como favorito se muestra
amarillo (#F4BE24). Al guardar se anima únicamente el icono, con rebote de hasta
18% y seis partículas amarillas de 2–4px alrededor de sus lados inferiores,
durante 620ms. No cambia el tamaño de layout, superficie ni área táctil del control.
PanelActionButton y GlassNavigationButton aceptan un icono compuesto opcional;
sus consumidores existentes conservan el aspecto anterior.

FavoriteBookmarkIcon pertenece a presentación de saved_cases. Celebra solo
el cambio no guardado→guardado con un nuevo noticeId confirmado por el ViewModel.
La lectura inicial, errores, reconstrucciones y retirada no celebran. La clave
por caso/cuenta evita trasladar una animación a otra identidad. El controlador
se libera al desmontar; movimiento reducido conserva amarillo sin animación ni
partículas, incluso al cambiar la preferencia durante el efecto. Shimmer,
toast, bloqueo de envíos, casos de uso, persistencia y permisos se conservan.

La petición limita este efecto a móvil: excepción explícita local a la paridad
de ADR-124; no migra web ni amplía HU-07/RF-13.

Validación: cuatro pruebas de widget, tamaños390×844 y320×600/texto200%, con
movimiento normal/reducido; lectura inicial, confirmación, reconstrucción,
retirada y desmontaje. Capturas en apps/mobile/build/ui-preview/favorite.
Arquitectura/consistencia/compartir:26 pruebas aprobadas; análisis lib/test sin
incidencias. Revisión táctil en Android/iOS con nueva compilación pendiente.
