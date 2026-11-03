# Limpieza manual de mascotas y casos

Petición del 30/10/2026: vaciar las mascotas y casos de todas las cuentas,
incluidos abiertos, resueltos, retirados, archivados, borradores y eliminados
lógicamente, con sus datos asociados. Esta operación no es una migración y
no se incluye en `run_all.sql` ni en planes de despliegue.

1. Detener temporalmente escrituras de la app/web, procesadores de fotos y
   entrega de notificaciones. Los borradores offline pueden volver a enviarse
   cuando el cliente se conecte; el SQL no borra el almacenamiento del dispositivo.
2. En el SQL Editor de la base elegida, con el rol `postgres`/propietario,
   ejecutar **completo** [001_clear_pets_and_cases.sql](001_clear_pets_and_cases.sql).
   El archivo contiene `BEGIN`/`COMMIT`: confirma la eliminación al terminar.
   Cualquier error revierte la transacción; si la herramienta mantiene la sesión
   en estado abortado, ejecutar `ROLLBACK` antes de reintentar.
3. Si también se quieren eliminar las fotos físicas, ejecutar el inventario
   [002_list_pet_and_case_storage.sql](002_list_pet_and_case_storage.sql) y vaciar
   los cinco buckets indicados mediante Storage en Dashboard/API. Conservar los
   buckets y sus políticas. No borrar `storage.objects` por SQL.
4. Reabrir/actualizar los clientes para volver a consultar el servidor.

El script elimina favoritos/guardados, seguimientos de casos y sus comandos,
contactos por caso, QR, cronología/cierres, notificaciones y entregas, denuncias,
decisiones/apelaciones/accesos de moderación e índices/revisiones de coincidencias.
También admite los avistamientos privados antiguos si aún existen antes de042.
Las tablas opcionales no instaladas se omiten con un aviso.

Conserva `auth.users`, perfiles y avatares, onboarding, administradores/revisores,
bloqueos entre usuarios, zonas de interés y sus seguimientos/comandos,
preferencias de alertas y dispositivos push. No cambia esquema, funciones,
triggers, políticas ni permisos. Usa una lista explícita y `RESTRICT`:
una nueva FK externa causa error y reversión, sin ampliar el borrado.

Mascotas y casos usan UUID. `RESTART IDENTITY` reinicia las secuencias propias
de las tablas vaciadas (actualmente eventos, notificaciones y accesos auditados);
su siguiente identificador será1. No reinicia secuencias de cuentas u otras tablas.

Las fotos físicas, cachés del dispositivo, carteles ya descargados y notificaciones
ya entregadas quedan fuera del SQL. Los enlaces QR eliminados dejan de resolver
en el servidor. Tras borrar fotos por Storage, el inventario debe devolver cero
filas; no se ha ejecutado ninguna limpieza remota al preparar estos archivos.
