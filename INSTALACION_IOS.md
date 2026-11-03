# 🐾 Entre Huellas en tu iPhone

> **Guía para el equipo · Windows + cuenta Apple gratuita**  
> Actualizada el **29 de octubre de 2026**. Instalación y uso confirmados por Sergio en **iPhone 11 con iOS 18.5**. La renovación semanal y los demás modelos deben comprobarse por separado.

Instala la aplicación real de Entre Huellas en tu iPhone, con su icono y acceso desde la pantalla de inicio. Después de instalarla puedes abrirla sin conectar el teléfono al PC. Las funciones que consultan el servidor siguen necesitando Internet, igual que en Android.

**No necesitas comprar una Mac ni pagar la membresía Apple Developer.** Sí necesitas una cuenta Apple gratuita, un PC Windows para instalar y renovar, y el archivo iOS que proporciona el equipo.

---

## 📖 Contenido

1. [Qué hicimos y qué instalará cada compañero](#1-qué-hicimos-y-qué-instalará-cada-compañero)
2. [Lo que necesitas](#2-lo-que-necesitas)
3. [Obtener el archivo de Entre Huellas](#3-obtener-el-archivo-de-entre-huellas)
4. [Preparar Windows](#4-preparar-windows)
5. [Conectar el iPhone](#5-conectar-el-iphone)
6. [Instalar con Sideloadly](#6-instalar-con-sideloadly)
7. [Autorizar el desarrollador en el iPhone](#7-autorizar-el-desarrollador-en-el-iphone)
8. [Activar el Modo de desarrollador](#8-activar-el-modo-de-desarrollador)
9. [Abrir y probar la aplicación](#9-abrir-y-probar-la-aplicación)
10. [Renovar cada siete días](#10-renovar-cada-siete-días)
11. [Instalar una actualización](#11-instalar-una-actualización)
12. [Problemas frecuentes](#12-problemas-frecuentes)
13. [Información técnica y fuentes](#13-información-técnica-y-fuentes)

---

## 1. Qué hicimos y qué instalará cada compañero

La aplicación está desarrollada en Flutter. El equipo compiló una versión iOS **Release** en una Mac de **GitHub Actions**, alojada en la nube. Por eso nadie tuvo que disponer de una Mac propia. Después descargamos un archivo `.ipa` sin firma personal y usamos **Sideloadly en Windows** para firmarlo con una cuenta Apple gratuita e instalarlo en el iPhone.

```text
Código Flutter de Entre Huellas
             ↓
Compilación iOS en GitHub Actions (macOS)
             ↓
entre-huellas-ios-unsigned.ipa
             ↓
Sideloadly en Windows + cuenta Apple de cada persona
             ↓
Entre Huellas instalada en su iPhone
```

| Elemento | Para qué sirve | ¿Lo necesita cada compañero? |
| --- | --- | --- |
| GitHub Actions | Compila la app iOS en la nube | No; el equipo entrega el IPA ya generado |
| Archivo `.ipa` | Contiene la aplicación para iPhone | Sí; todos pueden partir del mismo IPA del equipo |
| Sideloadly | Firma e instala el IPA desde Windows | Sí, en el PC que se utilizará para instalar y renovar |
| iTunes y componentes Apple | Permiten que Windows reconozca el teléfono | Sí, según los requisitos de Sideloadly |
| Cuenta Apple | Autoriza la instalación personal gratuita | Sí; cada persona utiliza la suya |
| Cuenta Entre Huellas | Permite entrar al producto | Sí; es independiente de la cuenta Apple |

**El APK de Android no sirve para iPhone.** Tampoco se convierte a IPA: compilamos la versión iOS desde el código fuente.

## 2. Lo que necesitas

- [ ] Un iPhone compatible con la compilación entregada.
- [ ] Un PC con Windows 10 u 11, preferiblemente de 64 bits.
- [ ] Cable de datos para tu teléfono: Lightning en el iPhone 11; USB-C en modelos que lo utilicen.
- [ ] Internet en el PC y el iPhone durante la instalación y verificación.
- [ ] Tu cuenta Apple, su contraseña y acceso al segundo factor si está activado.
- [ ] Sideloadly instalado y los componentes Apple indicados en su web.
- [ ] El archivo `entre-huellas-ios-unsigned.ipa` proporcionado por el equipo.

> **Cada compañero usa su propia cuenta Apple.** No compartan contraseñas, códigos de verificación ni la cuenta de Sergio. Las credenciales se introducen personalmente en la herramienta, nunca en el chat del equipo.

## 3. Obtener el archivo de Entre Huellas

Pide al responsable del proyecto el **IPA original sin firma personal** de la versión que van a probar. Puedes recibirlo por el canal de archivos que acuerden; no necesitas acceso a GitHub si el equipo te lo entrega directamente.

### Descargar las nuevas versiones desde Releases

Cada push a `main` ejecuta el workflow **Flutter**. Primero valida el proyecto;
después compila Android e iOS. Si ambos terminan correctamente, publica una
**prerelease conjunta** con etiqueta `android-build-N`. Se conserva ese nombre
por continuidad con Android, pero ahora la Release contiene las dos plataformas.

Si tienes acceso al repositorio privado:

1. Abre [Releases de Entre Huellas](https://github.com/srg-cp/entrehuellas/releases).
2. Elige la versión que indique el responsable y abre sus **Assets**.
3. Descarga **`entre-huellas-ios-unsigned.ipa`** y **`SHA256SUMS.txt`**.
4. Carga directamente ese IPA en Sideloadly. El APK es para Android; los archivos
   automáticos **Source code** tampoco se utilizan para instalar en el iPhone.

Una persona puede descargar el IPA y compartirlo con todo el grupo: cada compañero
firma el mismo original con su propia cuenta. No hace falta generar uno por persona.
La descarga de Releases sigue requiriendo acceso al repositorio privado.

Si un build falla, la nueva Release conjunta no se publica; no confundir una
versión anterior disponible con el resultado del último push. La compilación
puede iniciarse también manualmente desde **Actions → Flutter → Run workflow**,
seleccionando **main**. Las ramas de desarrollo validan mediante PR; no publican.

### Primera instalación realizada en este chat

Antes de unificar la publicación, descargamos el IPA de
[Artifacts del run40820124492](https://github.com/srg-cp/entrehuellas/actions/runs/40820124492),
artefacto `ios-sideload-3-1`, y extrajimos su ZIP. Ese es el IPA probado en el
iPhone11. Fue una descarga desde Actions, sin Release iOS en aquella ejecución.

Estos archivos acompañan la compilación:

| Archivo | Contenido |
| --- | --- |
| `entre-huellas-ios-unsigned.ipa` | La app que cargarás en Sideloadly |
| `SHA256SUMS.txt` | Huella para comprobar que el IPA no cambió al descargarlo o compartirlo |
| `BUILD.txt` | Commit y herramientas usados para compilar |
| `ios-Podfile.lock` (o `Podfile.lock` en el artefacto inicial) | Registro de dependencias nativas; no tienes que abrirlo para instalar |

Los artefactos temporales de Actions se conservan **14 días desde su generación**; los adjuntos de Releases no utilizan esa caducidad automática de Actions. Guarda el IPA en el PC: podrás usarlo para renovar sin volver a descargarlo ni compilarlo.

**Opcional: comprobar la descarga en PowerShell**, desde la carpeta del archivo:

```powershell
Get-FileHash .\entre-huellas-ios-unsigned.ipa -Algorithm SHA256
```

El valor `Hash` debe coincidir con el de `SHA256SUMS.txt`; las mayúsculas no importan. Si no coincide, vuelve a obtener el archivo del equipo.

## 4. Preparar Windows

1. Visita **[sideloadly.io](https://sideloadly.io/)**, la web oficial.
2. Revisa sus requisitos para Windows. La web indica usar las versiones web de **iTunes e iCloud**, con enlaces a Apple, en lugar de las versiones de Microsoft Store.
3. Si ya tienes componentes instalados, comprueba qué versión tienes antes de reemplazarlos; sigue las indicaciones actuales del sitio.
4. Descarga Sideloadly para Windows de 64 bits si corresponde a tu PC.
5. Ejecuta el instalador y completa el asistente.
6. Abre **Sideloadly**.

En la prueba realizada, Windows ya tenía iTunes, el servicio Apple Mobile Device y Bonjour. Se instaló **Sideloadly 0.71.2**. No significa que debas buscar esa versión exacta: usa la versión vigente del sitio oficial.

## 5. Conectar el iPhone

1. Conecta el teléfono al PC con el cable de datos.
2. Desbloquea el iPhone.
3. Si aparece **«¿Confiar en este ordenador?»**, pulsa **Confiar** e introduce el código del teléfono.
4. Abre Sideloadly y comprueba el campo **iDevice**.
5. Selecciona tu iPhone si hay varios dispositivos.

**Resultado esperado:** aparece el nombre del teléfono y la conexión `USB`. Si no aparece, revisa la tabla de problemas al final.

## 6. Instalar con Sideloadly

1. Arrastra **`entre-huellas-ios-unsigned.ipa`** desde el Explorador de archivos al recuadro del icono IPA de Sideloadly.
2. Comprueba que aparece el icono de Entre Huellas y el nombre del archivo.
3. En **Apple ID**, escribe el correo de tu cuenta Apple, la que utilizas en App Store/iCloud. No escribas aquí tu cuenta de Entre Huellas.
4. Conserva las opciones predeterminadas. No hace falta modificar **Advanced Options** para este recorrido.
5. Pulsa **Start**.
6. Introduce tu contraseña Apple en el diálogo de la herramienta y completa el segundo factor si lo solicita.
7. Mantén el teléfono conectado y espera a que finalice. El proceso firma el paquete y lo instala.

> **Si Start está deshabilitado:** comprueba los tres datos: iPhone seleccionado, IPA cargado y correo Apple escrito. En nuestra prueba faltaba completar el campo Apple ID.

Carga el **IPA extraído**, no el ZIP descargado de GitHub ni el APK de Android. No cambies manualmente el identificador de la app entre instalaciones y renovaciones.

## 7. Autorizar el desarrollador en el iPhone

Es posible que al abrirla aparezca **«Desarrollador no confiable»**, junto con tu correo y una referencia a `iPhone Developer`. Fue el aviso que apareció durante nuestra instalación.

En el iPhone:

1. Abre **Configuración → General**.
2. Entra en **VPN y administración de dispositivos**.
3. Busca **App de desarrollador** y toca el correo que utilizaste en Sideloadly.
4. Pulsa **Confiar en [tu correo]** y confirma el aviso que muestre iOS.
5. Vuelve a abrir **Entre Huellas**.

Según el idioma del teléfono, las opciones pueden llamarse **Ajustes**, **VPN y gestión de dispositivos** o **Administración de dispositivos**. Mantén Internet disponible para verificar la firma.

**El correo mostrado debe corresponder a la cuenta con la que acabas de firmar.** La autorización se hace en tu teléfono; no requiere una membresía de pago.

## 8. Activar el Modo de desarrollador

Si iOS lo solicita, o todavía no está activado:

1. Ve a **Configuración → Privacidad y seguridad**.
2. Busca **Modo de desarrollador** y actívalo.
3. Acepta el reinicio.
4. Al encender el iPhone, desbloquéalo y confirma la activación; introduce el código si lo pide.
5. Abre nuevamente Entre Huellas.

No es un jailbreak. Si la opción no aparece inicialmente, completa primero el emparejamiento y el intento de instalación, y revisa otra vez. En un teléfono administrado por una organización puede existir una restricción que deba resolver su administrador.

## 9. Abrir y probar la aplicación

El icono de Entre Huellas aparecerá como el de cualquier otra app. Puedes desconectar el cable y abrirla desde el teléfono.

Accede con **tu cuenta de Entre Huellas**. Si necesitas registrarte, utiliza el recorrido de creación de cuenta de la aplicación. La cuenta Apple se utilizó para firmar, no para crear automáticamente una cuenta en Entre Huellas.

### Recorrido sugerido para el equipo

- [ ] Abrir la app sin el cable conectado.
- [ ] Iniciar sesión y completar la bienvenida si corresponde.
- [ ] Navegar por Inicio, Explorar, mascotas y perfil.
- [ ] Comprobar scroll, teclado, retorno y fluidez.
- [ ] Probar cámara y galería cuando el recorrido lo requiera.
- [ ] Probar ubicación y mapas, incluida la alternativa manual.
- [ ] Revisar compartir y PDF en los recorridos disponibles.
- [ ] Cerrar y volver a abrir la app.
- [ ] Comprobar por separado borradores y comportamiento sin conexión.
- [ ] Confirmar después una renovación sin perder trabajo local.

**Utilizamos el backend configurado para la app Android.** Los cambios que confirmes pueden guardarse en esa cuenta y ser visibles según las reglas del producto. Coordina con el equipo antes de publicar reportes de prueba.

La instalación no habilita por sí sola las notificaciones push. El «10 de 10» confirmado en el iPhone 11 es evidencia de uso del usuario, no una auditoría de todas las funciones, dispositivos ni renovaciones.

## 10. Renovar cada siete días

### Qué significa la caducidad

La firma de una cuenta gratuita permite abrir la app durante **7 días**. No es un límite de horas de uso ni de aperturas. Si caduca, la app deja de abrir hasta volver a firmarla.

No hay un máximo de renovaciones indicado en la documentación consultada. Puedes seguir renovándola bajo las condiciones vigentes de Apple y Sideloadly; no es una garantía de disponibilidad permanente del método.

### Renovación manual

1. Conserva el IPA original en el PC.
2. Abre Sideloadly y conecta tu iPhone.
3. Carga el mismo IPA y utiliza **la misma cuenta Apple**.
4. Mantén el mismo identificador y opciones de la instalación anterior.
5. Pulsa **Start** y espera a que termine.
6. Comprueba que la app abre y conserva tus datos.

> **Renovar no requiere recompilar ni desinstalar.** Instala sobre la app existente. Desinstalar puede eliminar borradores, fotos pendientes y otros datos locales; cambiar de cuenta o identificador también puede afectar la continuidad de la instalación.

La conservación tras una renovación todavía debe verificarse en nuestro proyecto. Mantén respaldado el trabajo local importante antes de probarla.

### Renovación automática opcional

Sideloadly ofrece **Automatic App Refreshing**. Para que funcione, su proceso debe estar activo en el PC y el teléfono debe ser detectable por USB o por Wi-Fi configurado.

Para usar Wi-Fi, la documentación indica conectar primero por USB y activar en iTunes la opción de sincronizar el dispositivo por Wi-Fi. Ambos equipos deben estar en la misma red. Comprueba primero una renovación manual y luego la automática.

**Con el PC apagado no debes contar con que se renueve.** Como hábito, revisa la firma y renueva antes de cumplir la semana.

### Límites de la cuenta gratuita

- Hasta **3 apps instaladas por este método** en el dispositivo, según Sideloadly; las apps de App Store no cuentan para este límite.
- La vigencia de cada firma es de **7 días**.
- Apple puede imponer cuotas adicionales de dispositivos e identificadores. Si aparece un error de cuota, conserva su mensaje exacto y consulta al equipo antes de crear identificadores nuevos.

## 11. Instalar una actualización

Cuando el equipo publique otro IPA:

1. Descarga la nueva versión y verifica que corresponde a Entre Huellas.
2. Consérvala junto con su `BUILD.txt` para identificar qué estás probando.
3. Cárgala en Sideloadly.
4. Firma con la misma cuenta Apple y el mismo identificador.
5. Instala sobre la versión existente y comprueba tus datos.

**Renovar** amplía la vigencia de la misma versión. **Actualizar** instala código nuevo. Esta instalación personal no recibe actualizaciones automáticamente desde App Store.

## 12. Problemas frecuentes

| Lo que ves | Qué comprobar o hacer |
| --- | --- |
| No aparece el iPhone | Desbloquearlo, aceptar Confiar, probar otro cable/puerto y comprobar que iTunes lo detecta. Revisar los componentes Apple para Windows. |
| Start está gris | Seleccionar el iPhone, cargar el IPA y escribir el correo en Apple ID. |
| Pide Apple ID | Usar tu cuenta Apple gratuita. No hace falta comprar Apple Developer. |
| Pide contraseña o código | Introducirlos personalmente en el diálogo de la herramienta. No enviarlos al equipo. |
| Desarrollador no confiable | Configuración → General → VPN y administración de dispositivos → tu correo → Confiar. |
| Pide Modo de desarrollador | Configuración → Privacidad y seguridad → Modo de desarrollador; reiniciar y confirmar. |
| No aparece Modo de desarrollador | Completar emparejamiento e intento de instalación y revisar de nuevo; comprobar restricciones si el teléfono es administrado. |
| Dejó de abrir después de una semana | Renovar con el mismo IPA, cuenta e identificador, sin borrar la app. |
| Ya hay tres apps de este tipo | Revisar las otras instalaciones personales y sus datos antes de retirar alguna; consultar al equipo si hay dudas. |
| Error de autenticación o cuota | Revisar el texto exacto, la cuenta y el segundo factor. No cambiar identificadores al azar. |
| El enlace de GitHub ya no descarga | Puede haber caducado el artefacto o faltar acceso al repositorio privado; pedir al equipo el IPA guardado o una compilación nueva. |
| La app abre pero falla una función | Registrar el recorrido y el error: un fallo de producto se investiga por separado de la firma. |

Para pedir ayuda, indica **modelo de iPhone, versión de iOS, etapa, versión/commit del IPA y mensaje exacto**. En capturas, oculta correo, identificadores del dispositivo, contraseñas y códigos. No desinstales como primera solución si tienes trabajo pendiente.

## 13. Información técnica y fuentes

### Compilación probada en esta sesión

| Dato | Valor |
| --- | --- |
| Workflow | `iOS personal testing` |
| Ejecución aprobada | [40820124492](https://github.com/srg-cp/entrehuellas/actions/runs/40820124492) |
| Artefacto | `ios-sideload-3-1` |
| Commit fuente | `2e31261826f56d5edf47879c64c08a3f85abca8c` |
| Flutter | `3.35.3` |
| Xcode | `16.4` · build `16F6` |
| Tipo de compilación | Release para iPhone físico, sin firma personal en CI |
| Firma e instalación local | Sideloadly en Windows, con cuenta Apple gratuita |
| Prueba física comunicada | iPhone 11 · iOS 18.5 · instalación y uso aceptados por Sergio |

El equipo agregó CocoaPods para integrar los plugins nativos, reutilizó la configuración pública del backend y empaquetó la aplicación como `Payload/Runner.app` dentro del IPA. Se verificaron estructura para dispositivo, binarios y SHA-256. Las credenciales Apple se introdujeron localmente: no se guardaron en el repositorio ni en GitHub Actions.

Estas tareas ya están resueltas para el IPA entregado. **Los compañeros no necesitan instalar Flutter, Xcode, CocoaPods ni compilar el proyecto.**

### Documentación oficial consultada

- [Sideloadly: descarga y requisitos de Windows](https://sideloadly.io/).
- [Sideloadly: firma, vigencia, renovación, límites y problemas frecuentes](https://sideloadly.io/faq).
- [AltStore: autorización de cuenta y Modo de desarrollador en iOS](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows). Se consulta como referencia de los pasos de iOS; esta guía utiliza Sideloadly.
- [Flutter: compilación y distribución iOS](https://docs.flutter.dev/deployment/ios).
- [GitHub: equipos alojados para Actions](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).

---

**Para compartir esta guía:** envía este `.md` junto con el IPA original y `SHA256SUMS.txt`. Cada persona hace la instalación con su propia cuenta Apple y conserva los archivos para renovarla.
