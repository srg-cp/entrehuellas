# Pruebas personales de iOS desde Windows

28/10/2026. Infraestructura de prueba autorizada para iPhone 11/iOS 18.5.
Rama `feature/ios-sideload`: integra `feature/case-matching` (afb7cb2) y
`origin/main` (6db8810), por instrucción posterior de actualizar el APK y crear
un tag nuevo. No cierra historias del MVP.

## Recorrido y reglas

GitHub Actions ejecuta Flutter 3.35.3 sobre macOS 15, analiza el código y prueba
arquitectura/configuración. Compila Release AOT para dispositivo, sin firma Apple,
y empaqueta `Payload/Runner.app` en `entre-huellas-ios-unsigned.ipa`.
El IPA aún no es instalable directamente: Sideloadly en Windows lo firma con la
cuenta Apple gratuita del usuario y lo instala por USB. No requiere jailbreak.

Desde la integración solicitada29/10, `Flutter` se ejecuta por push a `main`
o manualmente desde main. Tras validate, compila Android y llama al workflow
reutilizable iOS (`workflow_call`), pasando solo MOBILE_CONFIG_JSON. Release
espera ambos jobs, verifica SHA-256 y commit y publica APK+IPA originales en
`android-build-N`. Sin publicación parcial si uno falla; número de build10000+N
compartido. Las PR validan sin firma ni publicación. No hay compilación por
push a la antigua rama iOS. Reintentos operativos: ejecutar todos los jobs para
que los nombres de artefacto coincidan con run_attempt.

Artefactos privados con retención14 días como respaldo; adjuntos de Release
sin ese vencimiento de Actions. Solo el job final tiene contents:write; iOS
solo lectura. No activa facturación adicional. macOS consume cuota del repositorio
privado y agotarla puede bloquear el build.
No se almacenan credenciales Apple
ni certificados personales en GitHub o en este repositorio.

## Configuración, persistencia y permisos

Reutiliza `MOBILE_CONFIG_JSON` de Android mediante validación compartida:
solo clave publicable y configuración cliente permitida. No contiene service_role
ni secretos de servidor. CocoaPods integra plugins existentes; ubicación solo
mientras se usa la app, cámara/galería con descripciones existentes y callback
`entrehuellas://login-callback/` conservado. Identificador de paquete conservado.
No cambia dominio, repositorios, UI, backend, RLS ni consentimientos del producto.

Firma gratuita: vigencia7 días, hasta3 apps instaladas por este método. Renovar
con la misma cuenta e identificador sobre la instalación existente, sin borrarla,
para conservar los datos locales. Cada compañero firma con su propia cuenta.
Caducidad impide abrir hasta renovar, no supone vencimiento de la cuenta del
producto. Reinstalación y cambio de identificador pueden afectar datos locales,
sesión o llavero; comprobar persistencia en dispositivo antes de darla por válida.

## Errores y reintentos

Fallo de configuración: corregir secret existente sin imprimir valores.
Fallo de compilación: revisar el run; no entregar un artefacto incompleto.
El verificador exige plataforma iPhoneOS, binarios Flutter/App, ausencia del
kernel debug y descripciones de permisos. Un IPA válido no acredita ejecución.
La renovación automática requiere PC encendido y dispositivo detectable por USB
o Wi-Fi. Si vence, volver a firmar el mismo IPA; no es necesario recompilar.

## Publicación conjunta verificada29/10

Run40830305712 aprobado en main(d3d501b). Release
[android-build-66](https://github.com/srg-cp/entrehuellas/releases/tag/android-build-66)
con APK firmado e IPA de dispositivo sin firma personal; hashes de ambos
verificados tras descargar y estructura del IPA comprobada.642 pruebas Flutter,
8 Python, formato/análisis y publicación aprobados. La instalación física de
esta build y la renovación semanal siguen pendientes.

## Activación y validación

29/10: run40820124492 aprobado, IPA2e31261 descargado y estructura/SHA-256
verificados. Usuario confirma instalación/uso «10 de10» en iPhone11/iOS18.5
tras autorizar su desarrollador. Guía ampliada para compañeros con cuenta propia.
Pendientes de comprobación por recorrido y no acreditados por esa aceptación:
instalación/apertura sin depurador, cuenta y retorno de autenticación, cámara,
galería, ubicación manual/GPS, mapa, compartir/PDF, SQLite al reiniciar/offline,
renovación sin desinstalar y fluidez. Push y capacidades Apple restringidas a
membresía no se consideran validadas por instalar con cuenta gratuita.
Guía paso a paso: [INSTALACION_IOS.md](../../INSTALACION_IOS.md).

Fuentes: [Sideloadly](https://sideloadly.io/faq),
[Flutter iOS](https://docs.flutter.dev/deployment/ios),
[GitHub runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).
