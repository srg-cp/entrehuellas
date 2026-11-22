# ADR-173: correcciones no críticas de la auditoría móvil

Fecha: 21/11/2026, America/Lima. Estado: aceptada por instrucción explícita
(«continúa con todas las correcciones faltantes»). Complementa ADR-172.

## Decisión: aplicado

- **Router.** Toda ruta `/home/...` comparte la política de acceso de `/home`
  (una condición en lugar de una lista manual). Un único validador
  `_invalidCaseRoute` (origen `lost|found` + UUID, sin distinguir mayúsculas)
  protege denunciar, cierre, recorrido, cronología y carteles; carteles antes no
  validaba el id. `_draftEditorRoute` sustituye la conversión de slot a ruta
  que estaba duplicada. El `extra` de solo lectura de la ficha de mascota es
  `PetDetailEntry.inspect` y no el texto `'inspect'`.
- **Evento de dominio «caso cambió».** `CaseChanges`/`NotifyCaseChanged`
  (`core/domain`) y `caseChangesProvider` (`core/providers`), con el mismo
  patrón que `PetChanges`. El router ya no invalida providers de otras
  funcionalidades: cierre, recuperación y actividad notifican, y cada pantalla
  se refresca sola. `lifecycle: true` (cierre) recarga fichas y listas; la
  actividad recarga recorrido, Explorar y, si es de un caso perdido, Mis casos
  y mascotas. Se conserva la recarga propia de cada ficha.
- **Tipos compartidos.** `CaseKind` (`lost|found`, valor de red = `name`),
  `CommunityCaseTarget` (alias único de los destinos de cierre, recorrido y
  cronología), `CaseStatus` (constantes) y `isActive` en las entidades. El
  estado sigue siendo texto en las entidades para que un estado nuevo del
  servidor no rompa la lectura. `ReportSlot` (sealed) interpreta el formato
  persistido de los slots de borrador sin cambiarlo. `caseDetailRoute`
  construye la ruta de detalle.
- **Datos.** `enumByNameOrNull`: especie, tamaño o sexo desconocidos pasan a
  null (los campos ya son opcionales) y una tarjeta pública con tipo o estado
  desconocido se omite en lugar de hacer fallar la página. Las fotos de casos
  perdidos y encontrados se firman con una sola llamada `createSignedUrlsResult`
  por lectura en lugar de una por foto (antes eran en serie en la ficha
  perdida). Se elimina `photoUri`, que quedó sin uso.
- **Robustez.** Publicar no se permite mientras la cola está enviando ese mismo
  comando. El estado `inactive` (diálogos, cortina) ya no detiene la cola. La
  app no programa un callback por cada build. Los 21 providers de sesión usan
  el mismo `retry: null`.
- **Plataforma.** `flutter_localizations` con locale `es`: selectores de fecha y
  hora y textos Material en español. Las teselas por defecto son CARTO
  Positron (ADR-104) en lugar de los servidores comunitarios de OSM, que además
  se mostraban sin atribución.
- **Calidad.** 178 colores literales pasan a usar los tokens existentes de
  `AppColors` (mismo valor, sin cambio visual). Lints: `strict-casts`,
  `strict-raw-types`, `avoid_dynamic_calls`, `unawaited_futures`,
  `cancel_subscriptions` y `close_sinks`, con sus avisos corregidos.
  Centinelas de formulario incompleto con nombre (`MissingReportValue`).
  Se eliminan siete widgets sin uso (ActionDock, ReportContentButton,
  CommunityHero, UpcomingFeatures, PillLabel, SurfaceCard, PrimaryAction) y
  los registros de fallos `flutter_0*.log` (ignorados por Git).

## Decisión: no aplicado, con motivo

- **Textos en ViewModels.** Son traducciones de tipo de fallo a mensaje dentro
  de presentación, que es la función del ViewModel en MVVM. Moverlos a enums
  solo aporta si se internacionaliza la app, algo que no está en el MVP.
- **Editores perdido/encontrado duplicados.** La coordinación de borrador, cola
  y recibo tiene concurrencia delicada y estados distintos. Extraerla requiere
  un incremento propio con pruebas dedicadas; queda como trabajo pendiente.
- **Unificar los 21 providers de sesión en uno.** Las pruebas sobrescriben cada
  uno por separado; unirlos rompería esas sobrescrituras. Solo se iguala el
  reintento.
- **LostReportScreen en `app/`.** Combina dos funcionalidades y la regla prohíbe
  presentación entre funcionalidades; `app` es la capa de composición. Se
  mantiene allí como excepción explícita.
- **Debounce del guardado de borradores.** La escritura va a un isolate de
  SQLite; un retardo arriesga perder el último cambio si se cierra la app.
- **Espera progresiva de la cola.** Ya existe por entrada (`nextAttemptAt`
  persistido); el temporizador de 15 s solo lee la base local.
- **Fondo ambiental a 60 fps.** Diseño aprobado; ya respeta movimiento reducido
  y TickerMode.
- **`directives_ordering`.** 649 avisos de orden de imports: tocaría casi todos
  los archivos y causaría conflictos con otras ramas. Puede aplicarse con
  `dart fix` en un cambio aislado.
- **Errores por texto de mensaje SQL** (`case_already_active`…). Es el contrato
  del backend; cambiarlo exige migración SQL.
- **CasePublicSkeleton, AuthViewModel, EnablePushButton.** Sin uso en `lib`,
  pero aparecen en la documentación o pertenecen al push pospuesto. Se
  conservan hasta revisar esos documentos.
- **Credenciales locales y versión fija de dependencias.** Requieren acción o
  decisión del usuario.
