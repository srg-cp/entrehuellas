# ADR-169: retención acotada y revalidación de listas móviles

Fecha: 30/10/2026. Estado: aceptada para este incremento.

## Contexto

El usuario solicita mejorar fluidez y consumo de consultas antes del lanzamiento.
Explorar consultaba al volver de cualquier ficha. Explorar y Mis mascotas podían
perder los resultados al desmontar la sección. La solicitud autoriza mejorar la
gestión de datos, sin convertir esta entrega en certificación de escalabilidad.

## Decisión

- Retener en memoria el estado exitoso de Explorar y las listas de mascotas
  activas/archivadas mediante RetainedQuery en presentación compartida.
- Conservar autoDispose: liberar tras tres minutos sin observadores, al invalidar
  dependencias/identidad o al destruir ProviderScope. No guardar nuevos datos en disco.
- Vigencia inicial de 30 segundos en Explorar y un minuto en mascotas. Son valores
  ajustables con mediciones, no promesas de sincronización en tiempo real.
- Caducar no consulta: revalidar al volver a observar la sección o recuperar el foco
  de la aplicación. Lista/mapa de Explorar también comprueban vigencia al volver de
  una ficha. Sin polling periódico ni consulta mientras la lista queda sin observar.
- La comprobación automática conserva contenido, sin skeleton ni shimmer de refresh.
  Refresh explícito conserva el feedback existente. Cambiar filtros conserva su contrato.
- Deduplicar comprobaciones automáticas en curso y rechazar respuestas antiguas por
  generación. Una actualización explícita de Explorar puede sustituir la automática.
- Fallo de red automático conserva contenido y ofrece el toast/reintento existente.
  Denegación de acceso no conserva contenido como alternativa autorizada.
- Mantener invalidaciones tras operaciones reales. Los callbacks de cambios de ficha
  en router también actualizan Explorar; ya no dependen del regreso incondicional.

No se eliminan las fronteras de casos de uso/repositorios ni se cachean autorizaciones.
La retención es de presentación, dentro de su ProviderScope; backend sigue autorizando
cada operación. Es una precisión de ADR-011/027 para revalidación automática: el shimmer
de contenido queda para trabajo explícito y los errores conservan toast superior.

## Alcance y consecuencias

Primer incremento móvil, sin nuevas HU/RF: Explorar y listas de mascotas. No migra
Nuxt, fichas, alertas, Mis reportes ni caché offline existente. No conserva widgets ni
agrega un IndexedStack. No promete conservar scroll entre secciones desmontadas.
La revalidación de Explorar vuelve a la primera página; los filtros se conservan.

Una lista puede permanecer sin cambios remotos mientras se observa sin volver a entrar
ni recuperar foco. Nuevas publicaciones de otros recorridos pueden esperar la vigencia
o el refresh manual cuando no hay callback específico. No es un sistema realtime.
No sustituir validación de operaciones por la antigüedad de un resultado en memoria.

## Evidencia y siguiente paso

Pruebas de conteo local de consultas, retención/caducidad, errores/reintento,
identidad y carreras en retained_navigation_test.dart. Regresiones de mascotas,
Explorar/mapa, arquitectura y consistencia; resultados en ESTADO.

Antes del lanzamiento: medir recorridos en Android físico con red real y Supabase,
latencia p50/p95 y número/tamaño de peticiones; ampliar la política por recurso a
las pantallas restantes y web, revisar consultas SQL/índices y probar concurrencia.
No inferir coste, carga soportada ni aceptación visual física a partir de fakes.
