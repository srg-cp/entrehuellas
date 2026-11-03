# ADR-167: ayuda pública unificada con cuenta

Fecha: 29/10/2026. Decisión explícita del usuario: la ayuda nueva se publica
dentro del caso para que la comunidad pueda verla; el creador recibe una alerta.
También confirma que publicar desde el QR requiere cuenta.

## Recorrido

La ficha móvil conserva una sola tarjeta gris «La vi o la encontré», del diseño
ADR-166. Abre el aviso vinculado existente: «La vi» o «La encontré y está conmigo».
Retira el acceso duplicado a envío privado. Publicar no cierra el caso; solo el
responsable puede confirmar recuperación. Sigue usando dominio, borradores,
cola, UUID estables, fotos procesadas y permisos del aviso público existente.

QR conserva consulta anónima. «La vi o la encontré» entra en /ayudar/:slug,
registrada como account en la política global. El destino interno validado
se conserva durante acceso/registro/onboarding; nunca contiene sesión ni datos
privados. El formulario fija la búsqueda y separa su borrador por cuenta/QR,
sin sobreescribir el borrador general. El endpoint anónimo antiguo devuelve410.

## Datos, privacidad y alertas

No convertir ni publicar avistamientos históricos privados, ni sus fotos,
comentarios o coordenadas. El módulo privado y sus contratos móviles permanecen
para compatibilidad de borradores/envíos ya existentes y revisión histórica;
no son la acción nueva de la ficha. No se realiza migración de contenido.

Avisos nuevos usan found_cases de tipo sighting/with_reporter. La ubicación
pública es aproximada; referencia/punto exactos permanecen privados. El texto
del formulario explica publicación de aviso/fotos y alertas según preferencias.
El trigger existente notifica al responsable y seguidores habilitados; no se
activa FCM, todavía pospuesto por ADR-068.

Plan041 añade destino QR autenticado y proyección QR de hasta100 avisos públicos
recientes (tipo, descripción y fecha, con enlace a ficha autenticada). Excluye
eliminados/ocultos y respeta revocación del QR; no consulta public_sightings para
esa lista. Los originales/fotos del caso conservan su proxy y validación.

## Activación y validación

Aplicar migración20261029004100 después de las anteriores, junto con servidor/web
actualizados. No ejecutar run_all sobre producción para actualizar. Sin despliegue
ni aplicación remota autorizados en esta tarea. Pruebas y limitaciones en ESTADO.
