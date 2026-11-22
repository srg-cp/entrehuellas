# ADR-172: correcciones críticas de la auditoría móvil

Fecha: 21/11/2026, America/Lima. Estado: aceptada por instrucción explícita.

## Contexto y autorización

Una auditoría completa de `apps/mobile` detectó cuatro problemas críticos. El
usuario pidió corregirlos («Críticos 1–4»), incluido el identificador Android,
sabiendo que es una decisión de producto. Sustituye la indicación anterior de
conservar `com.example.flutter_application_entrehuellas` (CONFIGURACION, guía
MVP, distribución Android e INSTALACION_ANDROID).

## Decisión

1. **Pruebas reproducibles sin flags.** El fondo ambiental repite su animación
   de forma indefinida, así que un `flutter test` sin argumentos fallaba en 156
   pruebas por `pumpAndSettle`. `AppPageBackground.animate` pasa a ser opcional
   y usa `AppPageBackground.ambientMotion` como valor por defecto.
   `test/flutter_test_config.dart` lo desactiva para toda la suite; las pruebas
   del fondo siguen pasando `animate: true`. La CI ya no usa el define; las
   capturas de `tool/` lo conservan. En la app no cambia nada.
2. **Identificador Android `app.entrehuellas`**, igual que el commit 9114c0a de
   la rama `Bruno` (mismo cambio, sin conflicto). `namespace` y el paquete
   Kotlin de MainActivity se mantienen. Consecuencias: las instalaciones con el
   identificador provisional no se actualizan (hay que desinstalar e instalar);
   Firebase/FCM debe registrar la app nueva y descargar su
   google-services.json. iOS/macOS conservan su bundle provisional (fuera de
   alcance).
3. **Sesión Supabase en almacenamiento seguro** (Android/iOS):
   `SecureSessionStorage` (Keystore con EncryptedSharedPreferences / Keychain
   `first_unlock_this_device`) sustituye a SharedPreferences en texto plano,
   y `SecurePkceStorage` hace lo mismo con los verificadores PKCE. Al arrancar
   se migra la sesión antigua (misma clave del SDK) y se borra la copia en
   claro solo después de guardarla cifrada, así que actualizar no cierra la
   sesión. Si falla el keystore, el arranque continúa y se cierra la sesión.
   Web y escritorio conservan el almacenamiento por defecto. La prueba de
   arquitectura limita `flutter_secure_storage` a data_sources y bootstrap.
4. **Manejo global de errores.** `installErrorHandlers()` en `main` envía los
   errores de framework (`FlutterError.onError`) y asíncronos
   (`PlatformDispatcher.onError`) a un único destino. Por defecto, registro
   local con tipo y stack, sin mensajes fuera de debug porque pueden contener
   datos personales o tokens. En release, un widget que falla no muestra el
   bloque gris. Conectar un servicio remoto de fallos (Sentry/Crashlytics)
   requiere una decisión aparte: cuenta, consentimiento y política de privacidad.

## Validación

Formato y `flutter analyze` sin incidencias; suite completa con `flutter test`
sin define (ver ESTADO). Pruebas nuevas: `secure_session_storage_test.dart`
(migración, fallos del keystore, PKCE) y `error_reporting_test.dart`. Pendiente:
comprobar en un dispositivo físico la migración de una sesión real tras
actualizar, y el registro FCM con el nuevo identificador.
