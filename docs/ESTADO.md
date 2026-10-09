# Estado del proyecto

Última actualización: 7 de octubre de 2026, America/Lima.

## Hechos comprobados

- Carpeta actual: `C:\Users\Administrator\Documents\projects\entreHuellas`.
- Comprobación inicial del chat 00: `main`, commit de partida `8c5fdee` (`init`), árbol limpio. El proyecto ya tenía commits y una app Flutter multiplataforma con una pantalla `Hello World!`; el estado previo del 4 de octubre quedó desactualizado.
- La app se conserva en `flutter_application_entrehuellas`, según la decisión de ubicación del 6 de octubre de 2026. No se creó `apps/mobile` ni se regeneraron las plataformas.
- Flutter 3.35.3 stable / Dart 3.9.2. No se actualizó el SDK.
- `flutter doctor`: Android SDK 36.1.0-rc1, Command-line Tools ausentes y licencias de estado desconocido. `flutter devices`: Windows, Chrome y Edge; ningún Android conectado.
- Identificador Android conservado: `com.example.flutter_application_entrehuellas`, provisional. El proyecto mantiene firma debug para release; distribución pendiente.
- No se consultó ni modificó el remoto en esta tarea. No se realizaron commit, push, issues, PR ni despliegues.

## Completado

- Chat **00 - Proyecto y estructura**: preparación local de arquitectura. No corresponde al cierre de HU-01 / RF-01,34.
- Clean Architecture por funcionalidad con `presentation`, `domain` y `data`. Entidad/contrato de sesión independientes del SDK, repositorios y fuentes de datos inyectados, casos de uso y estado de presentación.
- Riverpod 3.3.2, go_router 17.2.3 y supabase_flutter 2.18.0, resueltos con el SDK instalado y registrados en `pubspec.lock`. Se conservaron los registros de plugins generados para macOS/Windows.
- Inicio, tema Material 3, pantalla de acceso y navegación `/` -> `/access` con regreso. Rutas desconocidas permiten volver al inicio sin mostrar la URL.
- Bootstrap valida configuración pública e inicializa Supabase con PKCE antes de montar Riverpod. Estados explícitos: falta configuración, configuración inválida, fallo de arranque y SDK preparado. Este último no acredita conectividad ni credenciales remotas válidas.
- `AuthViewModel` observa cambios de identidad mediante `WatchAuthSession` y el contrato del repositorio; las pantallas no llaman al SDK. Identidad de sesión sin tokens en `domain/entities`.
- Configuración vía `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`, usando `--dart-define-from-file`. Ejemplo vacío en `config/supabase.local.example.json`; `config/supabase.local.json` comprobado como ignorado por Git. Solo se aceptan URL HTTPS y claves `sb_publishable_...`.
- Android registra INTERNET y `entrehuellas://login-callback/`. iOS registra el esquema. Manejador de deep links de Flutter desactivado en ambos para que Supabase/app_links gestione Auth sin duplicar el callback en go_router.
- CI local preparado en `.github/workflows/flutter.yml`, Flutter 3.35.3, formato/análisis/tests y lockfile. No ejecutado en GitHub.
- Actualizados AGENTS, README, arquitectura y guía para conservar la ubicación existente. Añadida `docs/CONFIGURACION.md` con preparación de Supabase y pruebas móviles pendientes. Las plantillas previas se conservaron.

## Refuerzo de la base, 7 de octubre de 2026

- Se estableció una estructura de arquitectura común para el MVP y los incrementos posteriores: operaciones de dominio mediante casos de uso, entidades y contratos independientes de UI/backend. La decisión quedó registrada en AGENTS, arquitectura y guía.
- Se conservó `main`, todo el trabajo local del chat anterior y `.vscode/settings.json` existente. No hubo commit/push ni cambios de infraestructura.
- `AuthSession` se organizó en `domain/entities`, `AuthRepository` en `domain/repositories` y se añadió `domain/use_cases/WatchAuthSession`. El caso de uso elimina identidades consecutivas repetidas, mantiene transiciones y propaga errores. Se actualizaron los imports y la inyección de Riverpod.
- Se añadió prueba de dependencias arquitectónicas para imports/exports de dominio y acceso directo desde presentación a data/SDKs. Se probaron deduplicación de identidad, cambio de usuario, cierre/reentrada y propagación de errores.
- Se detectó que `config/supabase.local.json` ya existe, sin leer ni modificar sus valores. Se añadieron perfiles de VS Code para desarrollo local y sin Supabase, abriendo la raíz o la carpeta Flutter; sin credenciales en launch.json. JSON y rutas de entrada comprobados. F5 interactivo no ejecutado.
- Validación del refuerzo: `dart format lib test` completado (20 archivos), `flutter analyze --no-pub` sin incidencias, `flutter test --no-pub`: **15 pruebas aprobadas** y `git diff --check` correcto. No se repitió build web; la compilación anterior consta debajo. Android y Supabase remoto siguen pendientes.

## Revisión de presentation y data, 7 de octubre de 2026

- Se mantuvieron la rama `main`, todos los cambios previos, configuración local y plataformas existentes. No se leyeron valores de configuración ni se realizaron acciones GitHub.
- Presentation se organizó en `screens`, `view_models`, `state` y `widgets`. `AccessScreen` observa solo `AuthViewModel`, que entrega `AuthViewState` con arranque y AsyncValue de sesión. Los mensajes de UI se trasladaron de core a presentación. Home sigue sin ViewModel porque no tiene operaciones ni datos de negocio.
- Data se organizó en `data_sources`, `models` y `repositories`. `SupabaseAuthDataSource` encapsula el SDK y expone DTO sin tokens; `AuthRepositoryImpl` transforma DTO a entidades y errores síncronos/de stream a `AuthFailure`. El repositorio puede seguir observando después de un error.
- Declaraciones DI de auth en `features/auth/providers/auth_providers.dart`, sin dependencias de data/presentation. `main` y bootstrap inyectan implementaciones. Se retiró `app/providers.dart`; presentación ya no depende de app. Arranque no configurado evita resolver/observar auth.
- ViewModel/stream de sesión usan autoDispose. Se desactivó el reintento automático del provider de stream; la recuperación mediante un evento posterior conserva la suscripción. El caso de uso transmite cancelación/pausa/reanudación y mantiene historial independiente por suscripción.
- Las pruebas detectaron un fallo en la deduplicación previa con `distinct`: después de un error se descartaba una identidad igual a la última válida. Corregido y comprobado tanto para sesión activa como para sesión nula. El error se muestra sin presentar una identidad obsoleta como estado válido.
- Reglas arquitectónicas ampliadas a presentation/data/providers, incluyendo directivas condicionales y `part`. La revisión de directivas complementa el análisis, no sustituye una auditoría completa de símbolos/transitividad.
- Validación: formato correcto (30 archivos), `flutter analyze --no-pub` sin incidencias y `flutter test --no-pub`: **26 pruebas aprobadas**. Incluyen mapeo/error/continuación/cancelación del repositorio, estados y ciclo de vida del ViewModel, recuperación tras errores, suscripciones independientes, adaptador con estado local del SDK y layout 320×350 con escala de texto 2.
- `flutter build web --no-pub`: correcto tras la reorganización; dry run Wasm correcto y mismo aviso no bloqueante de CupertinoIcons ausente. `git diff --check`: correcto.
- Las pruebas del adaptador usan sesión ficticia almacenada solo en el SDK local; no acreditan autenticación remota. No se modificaron dependencias ni se implementó HU-01. Android y Supabase remoto continúan pendientes.

## Validación de la base del 6 de octubre de 2026

Desde `flutter_application_entrehuellas`:

- `flutter pub get --enforce-lockfile`: correcto.
- `dart format --output=none --set-exit-if-changed lib test`: correcto, 17 archivos sin cambios después del formato inicial.
- `flutter analyze`: sin incidencias.
- `flutter test`: **12 pruebas aprobadas**. Cubren arranque sin backend, rechazo de configuración parcial/HTTP/credenciales en URL/query/claves secretas/JWT, navegación y regreso, propagación de sesión y errores desde un repositorio sustituido, estados inválido/fallido y ruta desconocida.
- `flutter build web --no-pub`: correcto; también pasó el dry run Wasm. Aviso no bloqueante sobre fuente CupertinoIcons ausente. Este build de la app Flutter no implementa la web pública QR de S4.
- Manifiesto Android e Info.plist iOS parseados como XML correctamente. Esto no acredita la resolución del enlace en un dispositivo.
- `git diff --check`: sin errores de whitespace. Git avisa de conversión futura LF/CRLF por configuración local.

Las pruebas de sesión usan un repositorio sustituido; no equivalen a acceso contra Supabase. No se ejecutó la app en teléfono/emulador ni en navegador interactivo.

## Norma de arquitectura, 7 de octubre de 2026

- Creado `docs/REGLAS_ARQUITECTURA.md` como norma del sistema: Clean Architecture por funcionalidad, MVVM, Repository, Adapter, casos de uso, inyección, estado inmutable y SOLID.
- Define responsabilidades de presentation/domain/data/providers/composición, dependencias permitidas/prohibidas, calidad por responsabilidades sin límites arbitrarios de líneas, manejo de errores/streams, seguridad y criterios de revisión. Los cambios de reglas se registran como decisiones versionadas.
- Lectura incorporada a AGENTS y enlaces añadidos desde README, arquitectura y guía. Se conservó la app y todo el trabajo local previo en `main`; esta tarea modifica solo documentación.
- Validación documental: coherencia con la implementación actual, enlaces locales y `git diff --check`. No se repitieron pruebas/builds Flutter; la última evidencia de código sigue siendo 26 pruebas aprobadas y build web correcto, descrita arriba. Los controles automáticos existentes son parciales y se complementan con revisión.
- Siguiente paso: aplicar esta norma al implementar HU-01 y mantener las comprobaciones arquitectónicas. Android y Supabase remoto continúan pendientes.

## Documentación de la decisión arquitectónica, 7 de octubre de 2026

- Añadido `docs/decisiones/001-arquitectura-aplicacion.md` (ADR-001) con contexto, decisión, motivos, alternativas y consecuencias. Relaciona las capas con los recorridos de recuperación, datos públicos/privados, pruebas y la incorporación prevista de almacenamiento local.
- README general, arquitectura, reglas, guía y AGENTS describen Clean Architecture por funcionalidad con MVVM, casos de uso, repositorios, adaptadores e inyección. La configuración describe el recorrido de sesión actual. Se conservaron los registros históricos y sus resultados de validación.
- Sustituido el README genérico de Flutter por instrucciones de desarrollo, configuración, comprobaciones y referencias de arquitectura. Las plantillas de historia/PR incluyen la norma y el registro de cambios arquitectónicos.
- La documentación distingue la base de sesión implementada de los flujos previstos de mascotas, recuperación y almacenamiento local. El registro de decisión incluye los costos de los contratos/mapeos y los límites de una futura sustitución del backend.
- Validación: enlaces locales y coherencia de referencias revisados, `git diff --check` sin errores. Cambios solo documentales; no se repitieron pruebas Flutter. Se conservó el trabajo local en `main` sin acciones GitHub ni configuración remota.

## Organización de la base de datos, 7 de octubre de 2026

- Estado de partida de esta tarea: rama `main`, commit `8503fa3` (`feat: Initialize Supabase and set up authentication structure`), árbol limpio antes de editar. Se conservaron los archivos existentes.
- Confirmado `config/supabase.local.json`: JSON y formato de URL HTTPS/clave publicable compatibles con AppConfig, sin mostrar ni modificar valores. Archivo ignorado por Git. Esto no verifica credenciales remotas ni autenticación.
- Creado `database` con 11 directorios versionables: extensions, types, tables, indexes, functions, triggers, views, policies, grants, seeds y tests. Su README define numeración global `001_...sql`, dependencias, separación de datos de prueba y conservación del SQL aplicado. No se crearon objetos de base de datos ni scripts SQL ficticios.
- ADR-002 registra la organización por objeto y la generación prevista de migraciones de Supabase a partir de las fuentes. Actualizados AGENTS, README, arquitectura, reglas, guía y configuración. El procedimiento de generación se debe implementar y comprobar en S1 antes del primer despliegue.
- Validación: directorios y enlaces locales comprobados, `git diff --check` correcto y protección Git de la configuración local confirmada. No hay SQL nuevo que ejecutar; no se realizaron pruebas de permisos ni se repitieron pruebas Flutter. Supabase CLI y psql no se encontraron en PATH.
- No se ejecutó SQL local/remoto ni se modificó el proyecto Supabase. No hubo commit, push o despliegue en esta tarea.
- Siguiente paso: S1 / HU-01, definir el primer esquema y sus políticas en database, preparar generación/migración y probar permisos con dos usuarios antes de aplicarlo al entorno de desarrollo autorizado.

## Icono Android, 7 de octubre de 2026

- Inicio de tarea: rama `main`, commit `6abc4a5`; solo `logo` tenía archivos sin seguimiento. Se conservaron todos los originales exportados desde Figma.
- Fuente clásica: PNG `Logo EntreHuellas 512 vector inner v2@2x.png`, 1024×1024. Fuente adaptativa: SVG `Logo EntreHuellas 512 vector inner v2-16.svg`, viewport 512×512. PNG inspeccionado visualmente y dimensiones de las cuatro exportaciones comprobadas.
- Añadido flutter_launcher_icons 0.14.4 como dependencia de desarrollo, configuración Android y script `tool/generate_android_icons.ps1`. Generados los PNG clásicos para mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi, vectores de símbolo/fondo/monocromo y recursos adaptativos API 26+/33+. El manifiesto conserva `@mipmap/ic_launcher` y su deep link existente.
- La variante adaptativa conserva formas y colores del vector y centra el símbolo con escala 0.72. VectorDrawable no traslada los filtros de textura/sombra interna del SVG. Los iconos de otras plataformas no se modificaron.
- Generación ejecutada correctamente. PNG xxxhdpi inspeccionado visualmente; cinco densidades comprobadas como 48/72/96/144/192 px y cinco XML parseados. Sintaxis del script PowerShell comprobada.
- AAPT2 36.0.0 compiló todos los recursos Android y los enlazó contra android-36 correctamente con un manifiesto de validación mínimo. Esto verifica recursos/referencias; el artefacto de validación no es un APK ejecutable de la app.
- Formato: 30 archivos Dart sin cambios. `flutter analyze --no-pub`: sin incidencias. No se repitieron las pruebas de lógica Flutter; las comprobaciones pertinentes al cambio fueron generación, recursos nativos y análisis.
- `flutter build apk --debug --no-pub` falló antes de compilar por `java.io.IOException: Unable to establish loopback connection`. Un intento con opciones temporales IPv4/sin daemon produjo el mismo fallo; no se cambiaron opciones persistentes de Gradle. Build de la app e instalación/icono en launcher no verificados.
- `flutter doctor` mantiene Command-line Tools ausentes y licencias desconocidas. `flutter devices` no detectó Android conectado. No hubo commit, push ni despliegue.
- Instrucciones de regeneración/instalación en `logo/README.md` y enlace desde configuración. Siguiente paso: resolver entorno Android/Gradle, iniciar emulador y verificar el icono con sus recortes tras reinstalar la app.

## Primera ejecución Android observada, 7 de octubre de 2026

- Se reportó compilación desde VS Code y se aportaron capturas del emulador con las pantallas Inicio y Acceso y cuenta. La navegación a acceso es visible; la interfaz coincide con la base implementada. No se aportó un log de build, ni se repitió la compilación desde esta sesión.
- `flutter devices` detectó `emulator-5554`, Android 16/API 36, android-x64. Las comprobaciones anteriores sin dispositivo son históricas.
- La pantalla muestra `Falta configurar el servicio de acceso`: esa ejecución recibió los dos dart-define vacíos. El archivo local conserva las propiedades de URL y clave publicable con valores; los perfiles de launch.json incluyen el argumento esperado. Revisar perfil seleccionado y detener/reiniciar con `Entre Huellas - desarrollo local`, en lugar de continuar una ejecución sin configuración.
- Estado esperado al cargar la configuración: `Servicio de acceso preparado` y `Sin sesión activa`. Esto confirma inicialización del SDK, no autenticación remota. Registro/login/perfil siguen pendientes de HU-01.
- El icono en el launcher y el retorno real del deep link no se observan en estas capturas. El error de loopback documentado corresponde al intento previo de esta sesión; no bloqueó la ejecución reportada desde VS Code.
- Siguiente paso: relanzar con el JSON, comprobar el estado de acceso y el icono del launcher; después implementar y validar S1. No se cambiaron archivos de la app ni se leyeron valores de credenciales para mostrarlos.

## Arranque desde main.dart, 7 de octubre de 2026

- Configurado `templateFor` del perfil local en ambos launch.json: `flutter_application_entrehuellas/lib` al abrir el repositorio y `lib` al abrir la app. Run/Debug predeterminado de Dart/Flutter utiliza los argumentos del JSON sin seleccionar manualmente el perfil. El perfil sin Supabase permanece disponible para ejecución explícita.
- Se conservaron los settings existentes y los valores de configuración. La plantilla no se aplica a las pruebas ni añade argumentos globales a otros proyectos.
- Validación: JSON, rutas de plantilla/entrada/configuración y diff comprobados. El comportamiento de templateFor se contrastó con la documentación de Dart Code. El relanzamiento desde el botón del editor aún requiere comprobarse en la sesión de VS Code; no se volvió a compilar ni se ejecutaron pruebas de lógica por este cambio de configuración.
- Siguiente paso: detener con el botón cuadrado y relanzar desde Run/Debug de main.dart; comprobar `Servicio de acceso preparado` en acceso. La ejecución Android observada anteriormente sigue siendo válida para la base sin configuración.

## Arranque con configuración confirmado, 7 de octubre de 2026

- Se confirmó que, al relanzar desde el botón de main.dart, Acceso y cuenta muestra `Servicio de acceso preparado` y `Sin sesión activa`. El perfil local carga el JSON y el SDK se inicializa en la ejecución Android reportada.
- Esta confirmación corresponde al arranque y estado inicial; todavía no acredita login, permisos remotos, restauración de sesión o retorno del deep link. No se ejecutaron pruebas ni builds adicionales desde esta sesión.
- Siguiente incremento: S1 / HU-01, RF-01,34, con registro/acceso, perfil, cierre de sesión y permisos. Conservar este procedimiento de arranque y la organización de fuentes SQL en database.

## Trazabilidad con GitHub, 7 de octubre de 2026

- Consultados los issues de `srg-cp/entrehuellas`: se encontraron las historias HU-01 a HU-16. No se encontró un issue específico de preparación/chat 00 en los resultados.
- S1 / HU-01, RF-01,34 corresponde actualmente a [issue #1: Entrar y gestionar mi cuenta](https://github.com/srg-cp/entrehuellas/issues/1). El número de historia y el número de issue se conservan como identificadores distintos aunque en este repositorio coincidan.
- La base de arquitectura, configuración y observación de sesión prepara HU-01; no cumple todavía sus criterios de registro/correo/Google, perfil, cierre, persistencia de sesión y baja. No corresponde declarar la historia terminada por el arranque del SDK.
- El issue #1 conserva tareas de ASP.NET Core que no coinciden con ADR-001 y la arquitectura Flutter + Supabase. Su descripción técnica requiere actualización antes de ejecutar S1; no se modificó ni cerró ningún issue en esta consulta.
- Validación de esta tarea: lectura del repositorio/issues y contraste con la guía. Sin cambios de código, pruebas o build nuevos.

## Rediseño de Inicio y Acceso, 7 de octubre de 2026

- Dirección visual basada en las referencias aportadas: tarjetas de radio 32, botones tipo píldora, títulos grandes, superficies menta/durazno y fondo claro. Tema y colores en core; componentes compartidos para tarjetas, marca, etiquetas y acción fija. La UI está construida con Flutter; bootstrap solo prepara el arranque.
- Inicio muestra marca, ilustración, acceso real a cuenta y próximos recorridos identificados. Acceso conserva su ViewModel/estados de arranque y sesión, incorpora tarjetas visuales y una acción de regreso. No se implementó login ni se añadieron publicaciones/acciones simuladas; dominio/data permanecen sin cambios.
- Ilustración derivada mediante image_gen del material existente en mockups, guardada en `assets/illustrations/community_pets.png`; origen/prompt en su README. Transparencia y composición inspeccionadas. Copia del logo original en `assets/branding/app_icon.png`; assets registrados en pubspec sin nuevas dependencias.
- `flutter pub get --enforce-lockfile`, formato y análisis correctos. `flutter test --no-pub`: **27 pruebas aprobadas**, incluyendo navegación y estado más Inicio/Acceso en 320×350 y texto ampliado a escala 2.
- Render QA ejecutado con `flutter test --no-pub tool/capture_ui_preview.dart`: 1 comprobación aprobada y capturas 390×844 en `build/ui-preview`. Fuentes reales del SDK cargadas para inspección; se revisaron ambas pantallas y se ajustó la ilustración de Acceso para mantener el estado inicial visible. El repositorio de esas capturas está sustituido: no prueba autenticación remota.
- `flutter build web --no-pub`: correcto, incluido dry run Wasm. Persiste el aviso no bloqueante de fuente CupertinoIcons de comprobaciones anteriores. Enlaces y `git diff --check` correctos. No se compiló ni instaló este rediseño Android desde esta sesión.
- Actualizados guía y arquitectura, añadido `docs/DISENO_UI.md` y regla de UI en AGENTS. Se conservaron los cambios locales anteriores y los valores de configuración; sin acciones GitHub ni modificaciones remotas.
- Pendiente comprobar este rediseño en el emulador, deteniendo/reiniciando desde main.dart para incorporar assets. El siguiente incremento funcional sigue siendo HU-01; su issue requiere adaptar las tareas técnicas registradas previamente.

## Login y preparación de perfiles, 7 de octubre de 2026

- Se conservó `main` y el trabajo previo. El acceso se reemplazó por el mockup: fondo blanco, marca negra, sans serif del sistema, campos redondeados, contraseña ocultable y botones sociales. Se retiraron widgets de estado visual que habían quedado sin uso.
- Correo/contraseña y Google conectados mediante `SignIn`, `AccessRepository`, fuente Supabase y `LoginViewModel`; `SignOut` cierra la sesión local. Se mantiene observación de sesión por eventos: iniciar OAuth no se presenta como sesión confirmada. Controles bloqueados durante solicitudes, prevención de duplicados, mensajes seguros y recuperación tras error/disposición del ViewModel.
- Consulta de solo lectura a `/auth/v1/settings` con configuración pública local: Google y correo habilitados; Apple deshabilitado. No se imprimieron ni modificaron claves. Apple aparece deshabilitado; registro y recuperación muestran aviso de pendiente, sin simular operaciones completas.
- Preparadas fuentes SQL 001–007: `public.profiles`, funciones de alta/timestamp, triggers, RLS por propietario, grants por columna y perfiles para cuentas existentes. Contraseñas permanecen en Supabase Auth. `database/scripts/Build-Migration.ps1` y plan versionado generan `supabase/migrations/20261007000100_auth_profiles.sql`, con transacción, fuentes y hashes; regeneración idéntica comprobada.
- Preparada prueba SQL con dos usuarios y rollback: creación por trigger, lectura/actualización propia, aislamiento cruzado, timestamps protegidos, rechazo de DELETE/acceso anónimo y revocación de ejecución de función privilegiada. **No ejecutada en PostgreSQL**: psql/CLI no disponibles y Docker sin motor accesible. Analizador pglast verificó sintaxis de 9 archivos SQL, ambas funciones PL/pgSQL y los bloques de pruebas; esto no acredita permisos ni integración con el catálogo de Supabase.
- Formato correcto (50 archivos), análisis sin incidencias y **34 pruebas Flutter aprobadas**. Incluyen límites arquitectónicos, validación de credenciales, reintento/duplicados, disposición durante solicitudes y adaptador contra HTTP sustituido con sesión devuelta y rechazo Auth. `http` se declaró como dependencia de desarrollo para este cliente de prueba, conservando su versión ya resuelta 1.6.0. Todas las credenciales de pruebas son ficticias.
- Render QA: 1 comprobación aprobada; captura de login inspeccionada en 390×844. Corregidos desbordamientos del separador y marca al ampliar texto; pruebas en 320×350/escala 2 aprobadas. `flutter build web --no-pub` correcto y dry run Wasm correcto; persiste aviso no bloqueante de CupertinoIcons ausente.
- Actualizados diseño, arquitectura, configuración, guía, ADR-002, READMEs y organización SQL. Símbolo Google guardado como asset local con procedencia oficial documentada.
- **Pendiente:** aplicar migración y probar RLS en desarrollo, ingresar con una cuenta real por correo y Google, comprobar callback/retorno con app abierta/cerrada, persistencia y cierre en Android. No se compiló ni instaló este incremento Android desde esta sesión. No hubo despliegue remoto ni acciones GitHub; HU-01 (issue #1) sigue abierta.

## Run all y convención SQL, 7 de octubre de 2026

- Preparado `database/run_all.sql`, autocontenido para SQL Editor, generado por `scripts/Build-RunAll.ps1` desde las fuentes 001–007. La migración anterior y sus fuentes permanecen intactas; los hashes se comprueban antes de generar. El generador rechaza cambios de plan sin revisar cómo repetirlos.
- Transacción y bloqueo asesor; creación de objetos ausentes, RLS/grants y backfill sin duplicados. No sustituye funciones/políticas/triggers preexistentes ni modifica datos de perfiles existentes. Valida estructura básica/constraints de la tabla existente y rechaza incompatibilidad. No es una auditoría completa ni reparación automática de deriva.
- Convención registrada: identificadores SQL en inglés y `snake_case`; propiedades Dart `camelCase`, clases `PascalCase`. ADR-003, reglas, AGENTS, arquitectura, configuración, guía y README actualizados.
- **3 pruebas locales aprobadas** en PostgreSQL en memoria (PGlite 0.5.8): tres ejecuciones conservan perfiles editados/fechas/OID; entrada después de la migración anterior; tabla incompatible aborta sin alterar datos. También se ejecutaron las aserciones SQL de permisos entre usuarios, roles y columnas en esa base local con fixture de Auth. No incluye GoTrue ni valida el proyecto Supabase remoto.
- Análisis sintáctico SQL/PLpgSQL correcto y generación reproducible comprobada. Sin cambios Flutter, despliegues ni acciones GitHub. Sigue pendiente aplicar y comprobar `run_all.sql` y permisos en Supabase de desarrollo, además del login real Android.

## Ajustes visuales del login, 7 de octubre de 2026

- Reemplazada la huella genérica del login por `BrandMark`, reutilizando el logo original verde y su asset existente en `assets/branding/app_icon.png`. SHA256 idéntico a `logo/Logo EntreHuellas 512 vector inner v2@2x.png`; originales conservados sin copias adicionales.
- Campos con radio 22, botones con radio 24 y alturas mínimas 56–58. Textos de campos/sociales/subtítulo 16, ingreso 17, recuperación 14, pie 15 y título 28. Se conserva sans serif del tema, texto ampliable y scroll; marca ajustable al ancho.
- Solo cambió presentación. Los ViewModels, casos de uso, repositorios y comportamiento de acceso permanecen intactos. Actualizados diseño y procedencia de assets.
- Formato correcto (42 archivos de lib), análisis sin incidencias y 34 pruebas aprobadas, incluyendo 320×350 con texto a escala 2. Captura Flutter 390×844 generada y revisada; no se compiló/instaló este ajuste en Android. Sin cambios de Supabase ni acciones GitHub.

## Diagnóstico de Google OAuth, 7 de octubre de 2026

- Captura Android: Google rechaza el ingreso con `400 redirect_uri_mismatch`. La captura del cliente web autoriza el callback público con una sola ruta `/auth/v1/callback`.
- Consulta de diagnóstico sin seguir redirecciones ni iniciar sesión: Auth responde HTTP 302 y envía `https://entrehuellas-supabase.kormind.com/auth/v1/auth/v1/callback` a Google. Confirmada duplicación de ruta en el callback generado por el servidor. No se imprimieron claves, códigos, estado OAuth ni tokens.
- Documentada corrección de la variable efectiva `GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI` y revisión de su composición con `API_EXTERNAL_URL`, seguida de recreación del servicio Auth. Flutter/SQL no requieren cambios para este error. No se accedió al servidor ni se modificó Google Cloud.
- Pendiente identificar la plataforma de despliegue, corregir su configuración, volver a consultar el callback y repetir el ingreso real. Sin nuevas pruebas Flutter ni build: solo diagnóstico de red y documentación.

## Login primero y onboarding por cuenta, 7 de octubre de 2026

- Corrección explícita del usuario: retirada la bienvenida pública y la pantalla intermedia “Tu cuenta”. Login es la entrada sin sesión; sesión confirmada conduce automáticamente al onboarding pendiente o a la app. La pantalla posterior es una base autenticada para funcionalidades futuras, sin publicaciones simuladas.
- Implementada funcionalidad onboarding con dominio (contrato, fallos, CheckOnboarding/CompleteOnboarding), data (DTO, fuente SDK/repositorio) y presentación (ViewModels/estado/pantallas). Inyección en bootstrap/main. Router único refrescado por estado de entrada: no recrearlo por cada sesión ni permitir rutas protegidas antes de autenticar/completar.
- Tres etapas exactas de texto: Cada huella importa, Volvamos a casa y Una nueva historia; imágenes originales del mockup mostrado por regiones en Flutter, sin generación nueva. Original conservado y copia en assets/onboarding. Marca compartida en core como BrandWordmark, controles reales, indicadores, scroll y áreas seguras.
- Omitir/Comenzar guardan finalización por cuenta en Supabase mediante RPC. Lectura fallida ofrece reintento sin saltar el flujo; guardado fallido conserva onboarding. Una sesión restaurada/completada abre la app; otra cuenta conserva su propio criterio. Una respuesta tardía del usuario anterior no modifica la ruta actual.
- Nuevas fuentes 008–009 y migración 20261007000200_onboarding_completion.sql: columna protegida onboarding_completed_at y RPC complete_onboarding con auth.uid(), fecha de servidor y operación repetible. Ampliado run_all explícitamente; migración inicial conservada intacta. Nueva prueba SQL 002 de propiedad, repetición y prohibición de reset.
- Validación: análisis Flutter sin incidencias, formato correcto y **36 pruebas Flutter aprobadas**. Render QA aprobado e inspección de las tres etapas en 390×844; pruebas de login/onboarding en 320×350/escala 2. **4 pruebas PostgreSQL locales (PGlite) aprobadas**, incluida RPC/aislamiento/repetición; 14 archivos SQL analizados sintácticamente. Build web correcto con dry run Wasm; persiste aviso no bloqueante de CupertinoIcons. No se compiló ni instaló este incremento Android.
- Usuario informó haber corregido OAuth en Dokploy y aportó captura de sesión activa. No se realizó ingreso con sus credenciales desde esta sesión ni se accedió al despliegue. Este nuevo SQL aún debe aplicarse en Supabase para probar onboarding remoto; sin despliegues ni acciones GitHub.
- Registrado ADR-004 y actualizado diseño, arquitectura, reglas de entrada en AGENTS, READMEs, guía y configuración. Siguiente paso: aplicar run_all actualizado, completar/omitir con una cuenta, reiniciar/cerrar sesión/reingresar y comprobar que no se repite; repetir con otra cuenta.

## Ilustraciones independientes del onboarding, 7 de octubre de 2026

- Por solicitud del usuario, reemplazados los recortes de baja resolución del tablero por tres PNG independientes derivados del mockup con la herramienta integrada image_gen: dog_waving.png, dog_with_map.png y dog_and_cat.png.
- Assets en flutter_application_entrehuellas/assets/onboarding, 1254×1254 RGBA con transparencia real. Copiados desde las salidas originales sin redimensionar/recomprimir; orejas, patas y colas inspeccionadas. Son reconstrucciones generadas a partir de la referencia, no una ampliación determinista del tablero.
- OnboardingIllustration simplificado a Image.asset con BoxFit.contain y filtrado medio. Eliminada del bundle la copia del tablero usada anteriormente; el original de mockups se conserva. Prompts exactos versionados en assets/onboarding/generation_prompts.json y procedencia/método en su README.
- Configuración de assets y captura QA actualizadas. Resolución con lockfile, formato, análisis sin incidencias y **36 pruebas Flutter aprobadas**; render QA adicional aprobado y las tres pantallas inspeccionadas sobre fondo blanco, incluyendo composición/bordes. No se realizó nuevo build/instalación Android ni cambios SQL, de sesión, despliegue o GitHub.
- Actualizados diseño, ADR-004 y documentación de assets. Para ver la sustitución en el emulador, detener la app y ejecutar nuevamente desde main.dart. El onboarding ya completado por una cuenta continúa sin repetirse, según su persistencia existente.

## Centrado y legibilidad del onboarding, 7 de octubre de 2026

- Comprobado que OnboardingIllustration y pubspec utilizan los tres PNG independientes de image_gen. La captura del usuario parece mostrar el recorte anterior (borde rectangular y gato recortado); no se comprobó qué build está instalado en el emulador.
- Extraído OnboardingPage como componente de presentación: centra el conjunto ilustración/título/descripción en el espacio disponible y permite scroll al aumentar texto o reducir altura. La ilustración sigue completa con BoxFit.contain y alto proporcional al viewport.
- Títulos 32, descripciones 19, acciones 18, indicadores 10 y botón mínimo 56. Marca del onboarding configurable a icono 56/texto 24; corregida la distribución del encabezado para evitar que Flexible+Spacer la reduzcan pese a aumentar tamaños.
- Formato y análisis correctos, 36 pruebas Flutter aprobadas incluyendo pantalla pequeña/texto ampliado, más render QA de las tres páginas. Capturas revisadas. No se instaló ni recompiló un APK desde esta sesión; sin cambios de flujo, SQL, persistencia o despliegue.
- Para cargar los assets actuales en Android, detener completamente la ejecución y volver a iniciar con el perfil local de VS Code. El onboarding completado no se restablece por esta revisión visual.

## Actualización comprobada en el emulador, 7 de octubre de 2026

- Identificada ejecución de VS Code cuyo target es el main.dart del proyecto correcto; dispositivo emulator-5554, Android API 36. Las capturas anteriores del usuario mostraban el diseño/corte anterior, pese a que las fuentes locales ya estaban actualizadas.
- Aumentados título 36, descripción 22, botón 22/alto mínimo 68/ancho mínimo 180, indicadores 16 y Omitir 20. No se modificó el tamaño ni contenido de los PNG. Conservado centrado del conjunto y separadas acciones adaptables en OnboardingActions.
- La prueba con 320×350 y texto al doble detectó desbordamiento del botón grande en una fila estrecha. Corregido mediante apilado de indicadores/acción en ancho reducido o texto ampliado y altura de línea explícita; 36 pruebas finales aprobadas, formato y análisis correctos, render QA aprobado.
- Conexión mediante flutter attach a la app ya en ejecución, con configuración pública local, sin DDS adicional. Hot restart/hot reload completados y primera captura real del emulador inspeccionada: imagen nueva transparente completa, conjunto más abajo/centrado, texto y acción/indicadores grandes. Tras aplicar el ajuste responsive final, el estado visible había cambiado a login con sesión cerrada; esa última captura se conserva como build/ui-preview/login_android.png y no se presenta como prueba visual del onboarding. No se reconstruyó APK ni se desinstaló la app; no se reinició el onboarding persistido ni se pulsó Comenzar/Omitir.
- Al desconectar el cliente adicional flutter attach, la herramienta Flutter 3.35.3 terminó con Bad state: Stream has already been listened to; registrado en flutter_01.log (ignorado). Se comprobó después que el proceso Android y la ejecución original de VS Code seguían activos. No fue un error de análisis/tests de la app.
- Actualizado diseño y evidencia. No hubo SQL, cambios de cuenta, despliegues ni acciones GitHub. Las capturas finales del harness muestran las tres etapas; la comprobación real del emulador se distingue de ese render sustituido. No se forzó acceso al onboarding tras el cambio de sesión.

## Login a escala del onboarding, 7 de octubre de 2026

- Por instrucción del usuario, retirado el botón Apple y todos los avisos informativos de sesión/arranque que ocupaban espacio entre subtítulo y correo. Sesión cerrada e inicio de OAuth ya no se presentan como bloques informativos. Los errores de una operación permanecen después del formulario, con semántica accesible, para permitir corregir/reintentar.
- Login sin appBar fijo: marca y formulario dentro de un bloque centrado en el alto disponible, con scroll al abrir teclado/ampliar texto. Logo 80/texto de marca 32, título 36/subtítulo 22, campos 20 e iconos 24, ingreso 22/alto mínimo 68, Google 20/alto mínimo 64, recuperación/pie 18. No se cambió el flujo de sesión ni onboarding.
- Formato y análisis correctos, **37 pruebas Flutter aprobadas**. Nueva regresión verifica ausencia de Apple/mensaje de salida y presencia de errores debajo del ingreso. Se mantienen pruebas de pantalla pequeña/texto al doble. Render QA adicional aprobado y login 390×844 inspeccionado; no se compiló/instaló ni actualizó la ejecución Android en esta revisión.
- Actualizados diseño, arquitectura, configuración y guía. Sin cambios de backend/SQL ni acciones GitHub. Reiniciar la app desde VS Code para revisar el nuevo login en el emulador.

## Ajuste intermedio del formulario de login, 7 de octubre de 2026

- Conservada la escala de la cabecera aprobada por el usuario. Reducidos campos a 18, ingreso a 20/alto mínimo 60, Google a 18/alto mínimo 58 y recuperación/pie a 16. Mantenidos centrado, scroll, radios y ausencia de Apple/avisos informativos.
- Subtítulo sustituido por “Ingresa a tu cuenta”: la frase anterior procedía del mockup, pero suponía una visita previa. El nuevo texto sirve también para el primer ingreso.
- Formato y análisis correctos, 37 pruebas aprobadas y render QA inspeccionado. Sin cambios de autenticación, onboarding ni backend; actualización en emulador pendiente de reejecución desde VS Code.

## Errores del login en los campos, 7 de octubre de 2026

- Reemplazado el párrafo de error por outline rojo suave y shake horizontal amortiguado en el campo afectado (4 px, 360 ms). Correo inválido, contraseña vacía y correo no confirmado tienen pistas cortas; rechazo genérico marca ambos y muestra una única notificación transitoria corta. Los errores generales del servicio no marcan credenciales como incorrectas.
- LoginViewModel publica LoginFieldIssue e identificador de intento; el formulario consume estado/callbacks y ShakeField se limita a animación visual. Edición limpia la marca; reintento vuelve a sacudir; animaciones desactivadas mantienen feedback estático y semántica accesible. No hay SDK ni reglas de autenticación dentro del widget.
- Separado emailNotConfirmed del rechazo genérico en fuente, fallos de dominio y repositorio, mediante código tipado del SDK sin propagar mensajes externos.
- Formato y análisis correctos; **42 pruebas Flutter aprobadas**: mapping SDK/repositorio de confirmación, precisión de campos, reintentos, limpieza, movimiento y preferencia de animación reducida. Render QA aprobado y access_error.png inspeccionado con repositorio sustituido. No se intentó ingresar con credenciales reales ni se actualizó el emulador en esta revisión.
- Actualizados diseño y arquitectura. Sin cambios SQL, políticas, configuración remota o GitHub. Recargar/reiniciar la ejecución para revisar el nuevo feedback en Android.

## Regla sin SnackBar y outline de error, 7 de octubre de 2026

- Eliminado el SnackBar del login por instrucción del usuario. El rechazo de credenciales permanece en borde/iconos/shake de los campos, sin barra inferior. Los fallos generales mantienen únicamente un mensaje breve en el contexto del formulario.
- Borde danger aumentado a 2.5 px en estados normal de error, enfocado y con pista de validación. Fondo del input conservado en su gris normal; iconos continúan danger. Captura access_error.png inspeccionada sin notificación inferior ni fondo rosado.
- Registrado ADR-005 y actualizados AGENTS, reglas obligatorias, diseño y arquitectura: no usar SnackBar en funcionalidades/componentes ni mediante wrappers; no sustituirlo por una barra/toast equivalente.
- Nueva comprobación automática del código de lib que rechaza referencias al componente y APIs de presentación. Pruebas de campos verifican grosor y fondo conservado. Formato/análisis correctos y **43 pruebas Flutter aprobadas**, más render QA aprobado.
- Sin cambios SQL/remotos ni acciones GitHub; el ajuste requiere recargar/reiniciar la ejecución del emulador. No se compiló ni instaló un APK en esta revisión.

## Ajustes finos de inputs y botones del login, 7 de octubre de 2026

- Ingresar reducido de 20 a 18, Google de 18 a 16 y pie de cuenta de 16 a 14. Padding vertical de ambos inputs aumentado de 18 a 22 (+4 arriba y abajo), conservando el horizontal en 16.
- La validación detectó una discrepancia previa: la prueba existente exigía borde danger 3.5 y el widget usaba 2.5. Conservada la prueba y alineado el componente/documentación a 3.5, sin cambiar el fondo del input ni la regla sin SnackBar.
- Formato/análisis correctos, 43 pruebas finales aprobadas y render QA inspeccionado. Sin cambios de autenticación, onboarding, SQL o remoto; revisión en el emulador pendiente de recarga de la app.

## Cabecera y alineación de Google en login, 7 de octubre de 2026

- Retirado el subtítulo “Ingresa a tu cuenta”; el título “Iniciar sesión” explica la acción sin repetirla. Pie de cuenta aumentado de 14 a 15.
- Icono y texto de Google centrados como conjunto, separados por 8 px. Conservados tamaños de inputs, botones y cabecera.
- Formato y análisis correctos, 43 pruebas Flutter aprobadas y render QA del login inspeccionado. Actualizado DISENO_UI. Sin cambios de autenticación ni backend; la ejecución Android requiere recarga para mostrar estos ajustes.

## Separación de marca y texto danger, 7 de octubre de 2026

- Separación logo/título aumentada de 28 a 40 y título de 36 a 38; el bloque mantiene su centrado y scroll adaptable.
- El texto ingresado en cada input con error adopta el mismo rojo del borde/icono. Al editar y limpiar el error recupera su color normal; no se modifica el fondo ni los placeholders.
- Formato/análisis correctos y 43 pruebas Flutter aprobadas, incluida comprobación de color por campo y recuperación tras edición. Render QA aprobado e inspeccionado; actualizado DISENO_UI. Sin cambios de backend ni actualización del emulador desde esta revisión.

## Entrada escalonada al onboarding, 7 de octubre de 2026

- Añadido componente compartido StaggerReveal/StaggerRevealItem: opacidad y desplazamiento suave de 14 px, secuencia de cinco grupos en 760 ms. Aplicado a cabecera, ilustración, título, descripción y acciones al entrar; no se repite con cambios de estado o etapa.
- Ruta onboarding con fundido de 240 ms. La preferencia de reducir animaciones elimina entrada, fundido y desplazamiento programático de páginas. Sin cambios de acceso Google/correo ni persistencia.
- Formato/análisis correctos, 45 pruebas Flutter aprobadas: nuevos casos verifican desfase, fin, ausencia de repetición, reducción de movimiento y desmontaje; se mantienen navegación y layout pequeño. Render QA aprobado y primera etapa inspeccionada. Actualizado DISENO_UI; suavidad perceptiva del retorno OAuth en Android pendiente de revisión en dispositivo, no se actualizó el emulador ni se hizo login remoto.

## Consulta de cuenta sin spinner central, 7 de octubre de 2026

- Identificado el loader en EntryScreen, durante la consulta de sesión/finalización del onboarding previa al stagger reveal. Sustituido por marca estática con semántica “Preparando tu cuenta”; ruta intermedia sin deslizamiento. Conservados comprobación real, errores, reintento y salida.
- Formato/análisis correctos y 46 pruebas aprobadas. Nueva regresión mantiene una consulta pendiente y verifica marca sin spinner, ausencia de acceso anticipado y entrada al onboarding al resolverla. Render QA aprobado y entry_check.png inspeccionado. Actualizado DISENO_UI; sin login remoto ni actualización del emulador en esta revisión.

## Entrada más pausada, 7 de octubre de 2026

- Stagger reveal ampliado de 760 a 1400 ms, desfase de 70 a 140 ms y duración de cada elemento de 480 a 840 ms. Conservados curva, desplazamiento, accesibilidad y ejecución única.
- Formato/análisis correctos y 46 pruebas aprobadas. Actualizado DISENO_UI. Revisión perceptiva en Android pendiente de reiniciar la app; sin cambios de layout ni backend.

## Reveal de texto por etapa, 7 de octubre de 2026

- Limitado el stagger al título y descripción de cada una de las tres etapas. Mascotas, cabecera, indicadores y acciones quedan fuera. Cada timeline se inicia al activar su página, por botón o swipe, y se conserva para no repetirlo al regresar; duración total 1400 ms.
- La regresión de swipe detectó que el listener iniciaba animateToPage durante el gesto. Corregido para animar solo cambios programáticos aún pendientes.
- Formato/análisis correctos y 47 pruebas aprobadas, incluida activación por botón/deslizamiento, ausencia de wrappers en imágenes/botones y no repetición al volver. Render QA aprobado y segunda etapa inspeccionada. Actualizado DISENO_UI; revisión en emulador pendiente de Hot Restart, sin cambios remotos ni de persistencia.

## Barrido desenfocado de referencia Sader, 7 de octubre de 2026

- Consultado en solo lectura el hook use-stagger-reveal.tsx del proyecto local platform-sader-kormind. Identificada la diferencia: blur progresivo, entrada desde arriba y cubic-bezier(0.22, 1, 0.36, 1), además de opacidad.
- Adaptado en Dart: ImageFiltered con blur inicial 18, desplazamiento -28, misma curva y desfase 90 ms entre título/descripción. Duración individual 1310 ms para mantener los 1400 ms totales solicitados. El filtro se desactiva al finalizar; se conserva una reproducción por etapa y reducción de movimiento. No se modificó el proyecto Sader.
- La captura intermedia detectó que el fundido global superponía la marca anterior sobre la mascota. Retirado ese fundido de ruta: el reveal queda solo en los textos y las mascotas/controles se muestran directamente. Repetidas comprobaciones tras corregirlo.
- Formato/análisis correctos y 47 pruebas aprobadas, con filtro activo durante entrada y desactivado al terminar/con movimiento reducido. Render QA aprobado; captura intermedia onboarding_reveal.png inspeccionada. Actualizado DISENO_UI. No se ejecutó retorno Google real ni se actualizó el emulador; fluidez en Android pendiente de Hot Restart y revisión.

## Parámetros exactos del login de Sader, 7 de octubre de 2026

- Revisados en solo lectura app/page.tsx, app/(auth)/page.tsx y el alias /login de Sader. La raíz usa useStaggerReveal({ count: 5 }) sin overrides: 850 ms por elemento, gap 90, blur 18, offset -28 y curva (0.22, 1, 0.36, 1).
- Alineado el componente Dart a esos valores exactos, retirando la duración individual 1310 ms de la adaptación anterior. Con dos bloques, el onboarding termina el reveal en 940 ms. Se conservan alcance solo textual, activación por página y no repetición.
- Formato/análisis correctos, 47 pruebas aprobadas y render QA aprobado/inspeccionado. La prueba de animación verifica título completo a 850 ms y descripción a 940 ms. Actualizado DISENO_UI. Sin modificar Sader ni ejecutar OAuth/emulador; revisión visual en dispositivo pendiente de Hot Restart.

## Cascada por línea y activación al llegar, 7 de octubre de 2026

- Por elección del usuario, título y descripción se revelan línea por línea mediante StaggerRevealText, conservando etiqueta accesible completa por bloque. El timeline admite el número real de líneas: cuatro o cinco, a 850 ms por línea y gap 90 ms; resto de parámetros iguales al login de Sader. Mascotas y controles siguen fuera del stagger.
- Corregido el inicio anticipado: el reveal espera el ScrollEnd de la página, sin consumirse durante el avance por botón/swipe. Se conserva el estado para no repetirlo al regresar.
- Formato/análisis correctos y 48 pruebas aprobadas. Regresiones verifican líneas consecutivas, semántica, texto oculto durante el desplazamiento y no repetición. Render QA aprobado y segunda etapa final inspeccionada. Actualizado DISENO_UI; percepción de blur/rendimiento en Android aún pendiente de Hot Restart y prueba en dispositivo.

## Inicio del reveal con menos espera, 7 de octubre de 2026

- Anticipado el inicio al último 15 % del desplazamiento de llegada, en lugar de esperar ScrollEnd. Conservados blur, curva, duración, secuencia por línea y reproducción única.
- Formato/análisis correctos y 48 pruebas aprobadas. La regresión verifica texto aún oculto a mitad del avance y animación iniciada antes de terminar el desplazamiento. Actualizado DISENO_UI; percepción en Android pendiente de recarga/reinicio, sin cambios de backend.

## Crear cuenta por correo, 7 de octubre de 2026 — HU-01 / RF-01,34

- Sustituida la acción pendiente del login por /register con nombre, correo, contraseña y confirmación, visibilidad independiente, formulario adaptable y el mismo feedback por campo del login. Sin casilla legal por elección explícita del usuario. Extraída decoración compartida para evitar divergencias; conservado diseño del login.
- Implementados RegistrationRepository, RegisterAccount, ResendRegistrationConfirmation, DTO/fallos de data, adaptador Supabase signup/resend, ViewModel autoDispose y composición en bootstrap/main. Metadata full_name reutiliza el trigger 002; no hay nuevas tablas de credenciales ni cambios de esquema/migración.
- Registro sin sesión muestra Revisa tu correo y reenvío tras 60 segundos, con temporizador liberado al salir. Registro con sesión sigue el observador de Auth/EntryViewModel al onboarding. Router permite registro únicamente en el flujo sin sesión; confirmación usa enlace/callback existente, no OTP simulado.
- Formato/análisis correctos y **60 pruebas aprobadas**. Nuevas pruebas: validación antes de red, contraseña sin trim, duplicados/desmontaje, errores por campo/recuperación, ausencia de casilla legal, espera/reenvío, entrada tras sesión y viewport 320×350 con escala 2. SDK real con HTTP/storage PKCE sustituidos verifica signup/resend, metadata, callback, respuestas con/sin sesión y fallos tipados. Estas pruebas no contactan Supabase real ni envían correo.
- Render QA aprobado; register.png y register_confirmation.png inspeccionados con fuentes reales. Detectada y corregida tipografía de botones que perdía la familia al sobreescribir el estilo. Actualizados arquitectura, diseño, configuración, guía, README de app y database. No se instalaron builds, crearon cuentas remotas, desplegaron SQL ni realizaron acciones GitHub.
- Pendiente de prueba en Android: SMTP/registro habilitado, política de contraseña en servidor, entrega y retorno del enlace con app abierta/cerrada y creación real del perfil. Procedimiento en CONFIGURACION. Recuperación y editor de perfil permanecen pendientes.

## Entrada escalonada de Crear cuenta, 8 de octubre de 2026

- Reutilizado StaggerReveal en toda la pantalla de registro: regreso, marca, título/subtítulo, cuatro campos independientes, pista de contraseña, acción y pie. Once componentes con parámetros de Sader (850 ms/elemento, gap 90, blur 18, offset -28 y curva original); duración total 1750 ms. Retirada transición adicional de ruta para mostrar la cascada desde el inicio.
- Un único timeline se conserva durante edición, teclado, validación y cambios del ViewModel. No se repite al mostrar errores; movimiento reducido muestra todo inmediatamente. Registro/confirmación y persistencia no cambian.
- Formato/análisis correctos y **62 pruebas aprobadas**. Dos regresiones nuevas verifican todos los órdenes, desfase entre campos, ausencia de reinicio con edición/errores, movimiento reducido y desmontaje. Se mantienen pruebas de viewport pequeño/texto ampliado y registro/reenvío.
- Render QA aprobado; register_reveal.png intermedia y register.png final inspeccionadas. Actualizados DISENO_UI y ARQUITECTURA. Sin backend/SQL, cuentas remotas, instalación Android ni acciones GitHub; probar percepción y rendimiento en dispositivo tras Hot Restart.

## Cabecera alineada entre login y registro, 8 de octubre de 2026

- Identificada la diferencia: registro reservaba un AppBar, reducía marca/título y centraba un bloque con otra altura. Extraído AuthPageLayout compartido: marca 80/32, título 38, separación 40 y un único anclaje independiente del contenido. Flecha superpuesta sin desplazar el cuerpo; teclado y pantallas pequeñas conservan scroll.
- Crear cuenta entra con elevación suave desde abajo (8 % del alto, 320 ms; salida 240 ms), sin alterar la posición final de cabecera. Se mantiene el stagger por componente y se desactivan ambas animaciones con movimiento reducido.
- Formato/análisis correctos y 62 pruebas aprobadas. Ampliada regresión de registro para comparar rectángulo de marca y altura del título entre pantallas, además de comprobar entrada vertical. Se mantienen validación, reenvío, flujo de sesión y viewport pequeño/texto ampliado.
- Render QA aprobado; access.png y register.png finales inspeccionados y alineados. Actualizados diseño y arquitectura. No se actualizó el emulador ni se tocó backend/SQL; revisión perceptiva pendiente de Hot Restart.

## Expansión desde Crear cuenta y cierre al origen, 8 de octubre de 2026

- Sustituida elevación vertical por OriginPageTransition compartida: CreateAccountButton mide su rectángulo real respecto al Navigator; superficie blanca redondeada se expande hasta pantalla completa en 560 ms y contrae al origen en 480 ms. Curva simétrica, escala uniforme de pintura con layout estable, recorte redondeado y entrada progresiva del contenido. Sin origen se usa fundido; movimiento reducido presenta la pantalla directamente.
- Corregido el salto de regreso: flecha, Iniciar sesión y retorno desde confirmación hacen pop para completar la animación inversa y conservar el login. go queda solo para navegación sin ruta anterior. Se conserva stagger y geometría final de cabecera. Interacción con formulario bloqueada durante la transición.
- Formato/análisis correctos y 65 pruebas aprobadas. Nuevas pruebas verifican geometría de origen/pantalla, reversa, layout sin deformación y movimiento reducido; integración comprueba ambos cierres, ruta todavía montada durante contracción y mismo origen. Tras ajustar escala uniforme por la revisión visual, se repitieron nueve pruebas pertinentes y render QA, aprobados.
- Capturas register_origin_open.png y register_origin_close.png inspeccionadas; corrección de escala evita cortar horizontalmente marca/textos en estados intermedios. Actualizados DISENO_UI y ARQUITECTURA. Sin cambios de backend ni instalación Android; revisar percepción/rendimiento tras Hot Restart en el emulador.

## Registro sin pie redundante y cierre con X, 8 de octubre de 2026

- Retirados subtítulo y pie ¿Ya tienes una cuenta?/Iniciar sesión del formulario de registro. La X superior sustituye la flecha y conserva pop/contracción hacia el origen. Confirmación de correo mantiene su acción de retorno.
- Ambos títulos aumentados de 38 a 42; separación de marca/título reducida de 40 a 28 dentro de AuthPageLayout compartido. Cabeceras continúan alineadas. Stagger ajustado a nueve componentes y 1570 ms totales, sin huecos de elementos eliminados.
- Formato/análisis correctos y 65 pruebas aprobadas. Regresión actualizada verifica X y retorno de sistema, ausencia de subtítulo/pie, orden completo y cierre inverso; se mantienen geometría, accesibilidad y pantallas pequeñas. Render QA aprobado; login y registro finales inspeccionados.
- Actualizados diseño y arquitectura. Sin backend ni actualización Android; revisar tras Hot Restart.

## Ajuste de títulos, cierre y Google, 8 de octubre de 2026

- X desplazada de 8 a 16 px desde el borde izquierdo del contenedor. Separación marca/título reducida de 28 a 20 y ambos títulos aumentados de 42 a 44, dentro del layout compartido.
- Google reducido de icono 28 a 22 y texto 16 a 15, conservando separación 8 y área táctil del botón. Sin cambios de flujo ni animación.
- Formato/análisis correctos y 65 pruebas aprobadas; render QA aprobado e inspeccionados login/registro finales. Actualizado DISENO_UI. Sin backend ni actualización del emulador; revisar tras recarga/Hot Restart.

## Entrada más rápida y cabeceras a la izquierda, 8 de octubre de 2026

- Expansión de registro reducida de 560 a 320 ms y contracción de 480 a 260 ms, conservando el botón de origen y pop inverso. Logo y títulos de ambos formularios alineados al margen izquierdo del layout compartido.
- Placeholder/texto ingresado reducidos de 18 a 17. Altura de línea conservada en 27 para no reducir el alto de los inputs; paddings, radios, iconos y acciones sin cambios.
- Formato/análisis correctos y 65 pruebas aprobadas. Render QA aprobado; login/registro inspeccionados, campos con mismas dimensiones y cabeceras alineadas. Actualizado DISENO_UI y tiempos de capturas intermedias. Sin backend ni actualización Android; probar tras Hot Restart.

## Títulos reforzados y menos espacio, 8 de octubre de 2026

- Ambos títulos aumentados de 44 a 48, conservando alineación izquierda. Espacio marca/título reducido de 20 a 14 y título/formulario de 32 a 20.
- Texto ingresado y placeholders reducidos de 17 a 16 con altura de línea 27 para conservar el tamaño exterior de campos. Quitado chevron de Ingresar; etiqueta y carga centradas.
- Formato/análisis correctos y 65 pruebas aprobadas. Render QA aprobado; ambos formularios finales inspeccionados. Actualizado DISENO_UI. Sin backend ni cambios de flujo; revisión Android pendiente de recarga/Hot Restart.

## Inputs y acciones con dimensiones iguales, 8 de octubre de 2026

- Registro adopta el padding vertical 22 del login, con la misma decoración, tipografía, fondo y radio. Ingresar adopta las dimensiones de Crear cuenta: padding vertical 18/horizontal 24, radio 24, alto mínimo 60 y texto 18, mediante authPrimaryButtonStyle compartido.
- Formato/análisis correctos y 65 pruebas aprobadas, más render QA. Ampliada la regresión de registro para comparar el tamaño renderizado de sus cuatro campos con el input de login y el botón de registro con Ingresar; siete pruebas de registro repetidas tras añadirla, aprobadas.
- Login/registro finales inspeccionados; actualizado DISENO_UI. Sin cambios de flujo/backend ni actualización Android; revisar tras recarga/Hot Restart.

## Google con icono y botón más pequeños, 8 de octubre de 2026

- Icono reducido de 22 a 20 y alto mínimo del botón de 58 a 56. Padding vertical de 14 a 13 por lado para reducir 2 px en total; texto y alineación conservados.
- Formato/análisis correctos y 65 pruebas aprobadas. Render QA aprobado e inspeccionado login; actualizado DISENO_UI. Sin backend ni actualización del emulador.

## Onboarding sin Omitir y acción de ancho completo, 8 de octubre de 2026

- Retirado Omitir por instrucción del usuario. Finalización únicamente desde Comenzar en la tercera etapa; guardado delegado a método privado del ViewModel. Se conservan RPC, fechas anteriores y reintento tras fallo, sin cambios SQL.
- Conservados tres puntos centrados como guía de progreso, encima de Continuar/Comenzar de ancho completo con flecha derecha. Texto/indicadores mantienen tamaños; PNG y reveal textual no cambian. El pie conserva área segura y permite texto ampliado.
- Formato/análisis correctos y 65 pruebas aprobadas. Regresiones actualizadas para ausencia de Omitir, flecha, finalización/reintento desde última etapa y recorrido completo en viewport pequeño. Render QA aprobado e inspeccionada primera etapa. Actualizados AGENTS, diseño, configuración, guía, README de database y actualización fechada de ADR-004.
- Sin despliegue ni actualización del emulador; revisar la propuesta de puntos sobre botón tras Hot Restart.

## Mascotas más grandes y controles menos redondeados, 8 de octubre de 2026

- Ampliado espacio de ilustraciones: margen horizontal de 24 a 12 y proporción de alto de .62 a .68, límite superior 460. PNG completos con contain, sin modificar assets ni tamaño/márgenes de texto.
- Indicadores reducidos de 16 a 12 (margen 5); radio explícito 26 en Continuar/Comenzar para reducir forma de píldora. Conservados ancho completo, alto, flecha y flujo.
- Formato/análisis correctos y 65 pruebas aprobadas, incluido viewport pequeño/texto ampliado. Render QA aprobado e inspeccionadas primera/tercera etapa. Actualizado DISENO_UI; sin backend ni actualización del emulador, revisar tras recarga.

## Actualización integral del README principal, 9 de octubre de 2026

- Se realizó un análisis exhaustivo del proyecto: arquitectura limpia por funcionalidad (`features/auth`, `features/onboarding`, `features/home`), estado de la suite de pruebas (65 pruebas unitarias/widgets), estructura del esquema SQL modular (001–009) en `database`, migraciones en `supabase/migrations`, y decisiones arquitectónicas (ADR-001 al ADR-005).
- Se actualizó el `README.md` raíz para reflejar fielmente la realidad del proyecto:
  - Visión general del MVP de recuperación colaborativa y flujos de publicación, QR y avistamiento ciudadano sin app.
  - Base técnica y principios arquitectónicos: Clean Architecture, MVVM, Riverpod, desacoplamiento del dominio y regla de oro de feedback sin SnackBar (ADR-005).
  - Estructura detallada de carpetas del repositorio.
  - Detalle de funcionalidades implementadas: Login con correo y Google OAuth PKCE, Crear cuenta (`/register`) con `OriginPageTransition`, validación contextual y pantalla de confirmación por correo con temporizador, Onboarding sin "Omitir" (ADR-004) con ilustraciones dedicadas, cascada desenfocada y persistencia mediante RPC `complete_onboarding`.
  - Organización de base de datos (`database/`), estándar de nombres (`snake_case`), `run_all.sql` idempotente y suite de pruebas PGlite.
  - Guía completa de puesta en marcha: clonación, configuración local de Supabase (`supabase.local.json`), perfiles de VS Code F5 y comandos de terminal.
  - Resumen de comandos de verificación (`dart format`, `flutter analyze`, `flutter test`, `npm test`).
  - Índice exhaustivo de documentación interna y decisiones arquitectónicas (ADR-001 a ADR-005).
- Validación: enlaces relativos verificados, `git diff --check` sin incidencias. Sin cambios en lógica ni código de la app Flutter; árbol de trabajo conservado.

## Pendiente

- Ejecución inicial Android observada en capturas y emulador detectado. Revisar herramientas/licencias si afectan nuevas compilaciones; build APK desde esta sesión, icono instalado y retorno de Auth aún no verificados. iOS no compilado en Windows.
- Registrar/verificar el retorno exacto en Authentication > URL Configuration > Redirect URLs. La configuración pública de Auth fue consultada en solo lectura: Google y correo activos, Apple inactivo. No se modificó el Dashboard ni se verificaron las credenciales OAuth.
- Probar retorno con app abierta/cerrada y luego correo/OAuth real en S1. No se verificó autenticación ni restauración remota de sesión.
- Completar HU-01 / RF-01,34: validar registro/confirmación real, recuperación, editor de perfil y gestión de cuenta. Registro, correo/Google/salida están implementados localmente; aplicar las migraciones de perfiles/onboarding ya generadas y ejecutar pruebas de permisos entre usuarios. El esquema no se ha desplegado desde esta sesión.
- Revisar identificadores definitivos, firma y requisitos de distribución antes de publicar una app.
- Publicar cambios y ejecutar CI remoto solo cuando la tarea autorice acciones GitHub.

## Siguiente chat

Completar validación Android del chat **00** siguiendo `docs/CONFIGURACION.md`, y continuar con **01 - Acceso y cuenta**, HU-01 / RF-01,34. La base local está preparada; el criterio de salida Android del chat 00 sigue pendiente.

Al iniciar, comprobar Git y herramientas de nuevo y conservar los cambios locales de esta entrega. Usar el prompt de S1 de `docs/GUIA_MVP.md` sin recrear la app.
