# Limpieza operativa de mascotas y casos

Solicitud del 30/10/2026. Operación manual para eliminar mascotas y casos de
todas las cuentas, con todos sus estados y referencias asociadas. Sin nueva
pantalla, HU/RF ni modificación del alcance funcional del MVP.

Recorrido: ejecutar completo el SQL transaccional en el SQL Editor como
`postgres`/propietario, siguiendo las [instrucciones de mantenimiento](../../database/maintenance/README.md).
Los avisos informan las filas afectadas. El `COMMIT` incluido confirma el borrado.

Elimina registros de mascotas/fotos, casos propios/comunitarios/hallazgos/avisos,
favoritos, QR, contactos, eventos/cierres, alertas/entregas, denuncias, moderación/
apelaciones y coincidencias. Incluye avistamientos privados si aún existen.
Solo elimina seguimientos/comandos `lost`/`found`; los de zonas se conservan.
No cambia cuentas, perfiles, onboarding, avatares, roles, bloqueos, preferencias,
zonas ni dispositivos push. Los UUID no tienen secuencia; las secuencias propias
de las tablas vaciadas reinician a1.

Permisos y persistencia: SQL administrativo fuera de migraciones y run_all.
No añade RPC ni permisos de cliente. Lista cerrada con TRUNCATE RESTRICT y
transacción única; una dependencia nueva no prevista causa error y reversión.
Tablas opcionales ausentes se omiten; las tres tablas principales son obligatorias.
Timeout de bloqueo5s y de sentencia60s; ante error, revisar causa/ROLLBACK y
reintentar el archivo completo. No requiere cambiar configuración del esquema.

Activación: detener escrituras durante el mantenimiento y actualizar clientes
después. Las fotos físicas se eliminan mediante Storage Dashboard/API usando
el inventario de solo lectura. El SQL no borra cachés, borradores del dispositivo,
carteles descargados ni notificaciones ya entregadas.

Validación:2/2 pruebas locales sobre esquema vigente y anterior a042 comprueban
borrado integral con dos cuentas, conservación exacta de configuración/Storage,
reinicio de identidades, repetición, rechazo de rol de aplicación y reversión
ante FK ajena. Ejecución remota y eliminación física de fotos no realizadas.
