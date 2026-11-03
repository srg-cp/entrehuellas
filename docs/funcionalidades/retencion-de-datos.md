# Retención de datos y actualización al volver

30/10/2026, [ADR-169](../decisiones/169-retencion-acotada-y-revalidacion-mobile.md).

## Qué hace y recorrido

Explorar y listas de mascotas móviles reutilizan resultados exitosos en visitas
breves. Volver de una ficha de Explorar comprueba antigüedad, sin consultar siempre.
Datos recientes se muestran directamente; los antiguos se actualizan conservando
contenido. Recuperar foco también comprueba las listas observadas.

## Reglas, persistencia y permisos

Memoria por ProviderScope/identidad, tres minutos de retención sin observadores.
Vigencia30s Explorar/60s mascotas, sin polling. AutoDispose y liberación de timers,
observadores de lifecycle y suscripciones mantenidos. Dominio/data y permisos del
servidor intactos. Sin nuevo almacenamiento persistente ni caché de autorización.

Cambiar cuenta reconstruye las dependencias; resultados tardíos se rechazan por
generación. Sin cambios de las fichas privadas/offline existentes. Las listas pueden
quedar desactualizadas mientras no haya reentrada/foco/refresh o cambio explícito.

## Errores y reintento

Carga inicial conserva skeleton/error existentes. Una comprobación automática
fallida conserva datos y muestra toast; el usuario puede reintentar. Pérdida de
acceso elimina la alternativa retenida. Actualizar manualmente fuerza consulta y
conserva shimmer. Confirmaciones de cambios conservan sus invalidaciones.

## Dependencias, activación y validación

Usa Riverpod y lifecycle Flutter existentes, sin paquete, migración o servicio nuevo.
Requiere actualizar el binario móvil; no se generó ni publicó una versión.
Pruebas locales de diez viajes entre secciones: una lectura por cada lista vigente;
no extrapolar a todas las peticiones HTTP/SQL de la aplicación. Detalles en ESTADO.

Pendientes: medición real, pruebas de carga, revisión física y extensión por recurso
a web y otras pantallas. No hay sincronización continua ni garantía de lanzamiento
por completar este incremento. No se cierran historias por esta optimización.
