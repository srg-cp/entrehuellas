# ADR-174: coordinador compartido de borrador local, cola y recibo (móvil)

Fecha: 21/11/2026, America/Lima. Estado: aceptada. Retoma el trabajo que
[ADR-173](173-correcciones-no-criticas-auditoria-mobile.md) dejó pendiente
(«editores perdido/encontrado duplicados») como incremento propio con pruebas
dedicadas.

## Contexto

`CaseEditorViewModel` (perdidos) y `FoundEditorViewModel` (encontrados y
avistamientos) repetían casi línea a línea la coordinación con el borrador
local y la cola de envíos: `discardLocalDraft`, `saveForLater`, `_saveLocal`,
`_observeDraft`, `_observeQueue`, `_applyQueue`, `restoreReportDetails`,
`chooseDate`, `chooseTime` y el patrón `_generation` + `ref.keepAlive()` +
`_current()`. Es la parte con concurrencia más delicada de la app: resultados
tardíos de otra cuenta o de un editor reconstruido, guardados lentos, recibos
que llegan por la cola en segundo plano y descartes a medio camino. Duplicada,
una corrección en un editor podía faltar en el otro.

La regla de fronteras impide la solución obvia: ninguna funcionalidad importa
la presentación de otra, y `core` no importa funcionalidades. Un componente en
`offline_drafts/presentation` no sería importable por los editores, y uno en
`core` no puede nombrar `SubmissionStatus`, `QueuedReport` ni
`LocalReportDraft`.

## Decisión

`ReportDraftCoordinator<S, St, Q>` (`core/presentation/state`), mixin sobre
`AsyncNotifier<S>`, contiene una sola vez:

- **Generación.** `nextDraftGeneration()` al inicio de `build`,
  `draftGeneration` capturada antes de cada espera e `isCurrentDraft(gen,
  owner)` (montado, misma generación, sin carga, misma cuenta) antes de aplicar
  cualquier resultado.
- **keepAlive.** Guardado local y descarte retienen el provider autoDispose
  hasta terminar.
- **Checkpoint.** `listenSelf` guarda cada contenido distinto (clave del
  feature); un estado confirmado elimina su borrador y un fallo de ese borrado
  se ignora, porque reenviar el mismo comando es seguro.
- **Cola y recibo.** La entrada de la cola del comando editado actualiza o
  limpia el estado de envío; un recibo confirma el editor. Un editor ocupado o
  ya publicado ignora la cola, que se vuelve a aplicar al quedar libre.
- **Acciones públicas.** `saveForLater`, `discardLocalDraft`,
  `restoreReportDetails`, `chooseDate` y `chooseTime`.

Cada feature aporta lo que `core` no puede conocer, mediante métodos
`@protected` del mixin: puertos de persistencia (sus providers de
`offline_drafts`), lectura de la entrada de cola, clave de checkpoint,
transiciones de estado (`copyWith`), su guarda de edición y la traducción de
`ReportDraftIssue { localStorage, conflict }` a su propio tipo de fallo. Los
estados implementan `ReportDraftState<St>` con los campos que ya tenían más
tres getters derivados (`hasLockedDraft`, `isConfirmed`, `hasPublication`).

Diferencias de cada editor que se conservan como ganchos:

- perdido no descarta un comando congelado (`canDiscardLocalDraft`);
- encontrado, si el envío llegó a intentarse, primero confirma en servidor que
  no hay publicación activa (`releaseBeforeDiscard` → `_performDiscard`).

`publish`, `preview`, la selección de mascota o fotos y el descarte remoto de
encontrado siguen en cada ViewModel: sus reglas, tiempos de espera y fallos son
distintos. Usan las mismas primitivas (`draftGeneration`, `isCurrentDraft`,
`saveLocalCheckpoint`). El bloqueo de doble envío (`publish` no actúa mientras
la cola envía ese mismo comando, `SubmissionStatus.sending`) se mantiene en
ambos.

Sin cambios de persistencia, esquema, formato de slot (`ReportSlot`), textos
ni UI.

## Equivalencia

Única diferencia observable: tras liberar el comando en encontrado, el descarte
vuelve a marcar el editor como ocupado solo si no lo estaba. Antes emitía
también un estado idéntico cuando ya estaba ocupado. Los proveedores de
borrado y cancelación se leen justo antes de usarse, no al inicio del descarte.
Mientras tanto el provider sigue retenido y la generación se comprueba antes de
cada uso.

## Validación

`test/report_draft_coordinator_test.dart` (12 pruebas) prueba el mixin con un
editor de prueba independiente de perdido/encontrado: checkpoint único y
borrado al confirmar, estado de cola solo del comando propio, editor ocupado,
guardado lento de una generación anterior, keepAlive, `saveForLater`, orden y
fallos del descarte, doble descarte, descarte de una generación anterior y
guardas de fecha/hora/detalles. `offline_drafts_test.dart` suma dos pruebas
con los ViewModels reales: ninguno publica ni modifica su estado mientras la
cola envía ese mismo comando. Pruebas de mutación locales (quitar la
generación, el keepAlive del guardado, la limpieza confirmada o cada bloqueo
`sending`) hacen fallar al menos una prueba.

## Consecuencias

- Una corrección de concurrencia de borradores se hace una vez y la cubren
  pruebas propias.
- Un editor nuevo con borrador local implementa los ganchos en lugar de copiar
  la coordinación.
- Los ganchos hacen explícita la frontera: `core` no conoce tipos de
  funcionalidades y cada editor declara cómo persiste y traduce sus fallos.
