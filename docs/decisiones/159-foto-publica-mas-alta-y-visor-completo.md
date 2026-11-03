# ADR-159: foto pública más alta y visor completo

Fecha:29/10/2026. Petición explícita: aumentar solo el alto y abrir la imagen
completa al tocarla porque el encuadre de la ficha recorta la fotografía.

La tarjeta móvil conserva ancho, radios, nombre, estado y paginación. Su relación
ancho/alto cambia de1.35 a1.05 (y de0.8 a0.7 con texto ampliado); el skeleton
comparte la geometría. Mapa y otras tarjetas conservan sus dimensiones.

Tocar la galería abre CasePhotoViewer desde la foto activa: BoxFit.contain,
zoom1–4, desplazamiento entre fotos y cierre glass con X/Atrás. Reutiliza los
mismos ImageProvider autorizados de CasePhotoView, sin pedir originales privados
ni abrir permisos nuevos. Al cerrar conserva scroll/foto de la ficha. Sin fotos
no se ofrece una acción vacía. El visor emplea una sola entrada StaggerReveal,
respeta movimiento reducido y no repite la entrada al cambiar de fotografía.

Se aplica también a las vistas previas que ya comparten CasePublicCards.
ImmersivePhotoSheet y web conservados. Pruebas, análisis y límites en ESTADO;
sin nuevas historias, cambios SQL ni publicación automática.
