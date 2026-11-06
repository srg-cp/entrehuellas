<div align="center">

  <img src="apps/mobile/assets/branding/app_icon.png" alt="Icono de Entre Huellas" width="136" />
  <h1>Entre Huellas</h1>
  <p><strong>Cada huella puede ayudar a volver a casa.</strong></p>
  <p>Proyecto grupal de recuperación colaborativa de mascotas · MVP con prioridad Android</p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.35.3-02569B?logo=flutter&amp;logoColor=white" alt="Flutter 3.35.3" />
    <img src="https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart&amp;logoColor=white" alt="Dart 3.9.2" />
    <img src="https://img.shields.io/badge/Android-primero-3DDC84?logo=android&amp;logoColor=white" alt="Android primero" />
    <img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&amp;logoColor=white" alt="Backend Supabase" />
    <img src="https://img.shields.io/badge/Estado-MVP_en_desarrollo-F4A261" alt="MVP en desarrollo" />
  </p>
  <p>
    <a href="#primeros-pasos">Primeros pasos</a> ·
    <a href="#coincidencias-de-casos">Modelo y resultados de coincidencias</a> ·
    <a href="#configuracion-local">Configuración</a> ·
    <a href="INSTALACION_ANDROID.md">Instalar/publicar APK</a> ·
    <a href="#trabajo-en-equipo">Colaborar</a> ·
    <a href="#documentacion">Documentación</a>
  </p>
</div>

---

## 🐾 Sobre el proyecto

Entre Huellas conecta a quienes buscan una mascota con personas que pueden aportar información para recuperarla. El MVP contempla búsquedas de mascotas perdidas, avisos vinculados, fichas públicas mediante QR y seguimiento de la recuperación.

Las coincidencias visuales también forman parte del MVP (HU-25/#71 y HU-26/#72),
con hallazgos independientes y revisión humana. Su implementación está integrada
en `main`; el patch040 fue aplicado según confirmación del usuario. La validación
funcional con dos cuentas, servidor alojado, web y emulador está terminada; la
evaluación de calidad es exploratoria y su aceptación de producto sigue separada.
Consulta el [modelo, datos y resultados](#coincidencias-de-casos) y el
[recorrido y la configuración](docs/funcionalidades/coincidencias-de-casos.md).

La app cuenta con implementaciones de acceso y onboarding por cuenta, perfil, mascotas y fotos, zonas de interés, preferencias de alertas, búsquedas y avisos vinculados, y consulta de Mis reportes. **Implementado no significa historia cerrada ni despliegue confirmado**: la evidencia y los pendientes se registran en [las fichas funcionales](docs/funcionalidades/README.md) y [el estado del proyecto](docs/ESTADO.md).

Explorar, la web pública QR y la entrega real de alertas tienen trabajo pendiente. Guardar preferencias de alertas no implica que ya se envíen notificaciones. Consulta el alcance en [la guía del MVP](docs/GUIA_MVP.md).

<a id="coincidencias-de-casos"></a>

## 🔎 Coincidencias de casos: modelo, datos y acierto medido

### Modelo actual y procesamiento de fotografías

Usamos **CLIP ViT-B/32 cuantizado a 8 bits (q8)**, con los pesos preentrenados de
[`Xenova/clip-vit-base-patch32`](https://huggingface.co/Xenova/clip-vit-base-patch32),
revisión fija `d15189d7028b43f1d3e65039190477f6af591c2a` y versión del proyecto
`clip-vit-b32-d15189d-q8-v1`. Se ejecuta en CPU dentro del servidor Nuxt mediante
Transformers.js 3.8.1, con pesos locales verificados por hash; cada foto produce
un vector normalizado de 512 valores. No se entrenó ni ajustó el modelo con fotos
de las cuentas de Entre Huellas, ni se envían esas fotos a inferencia externa.

Las fotos del caso se normalizan, orientan y sanitizan al subirlas, conservando
sus proporciones. **El recorte central a 224 × 224 para CLIP se aplica en memoria
en Nuxt al comparar**, mediante `fit:'cover'`; no sustituye la fotografía guardada
ni la ficha. Se leen las versiones procesadas autorizadas de Storage, no las
miniaturas. Los vectores se indexan por caso/foto/hash/versión y se reutilizan;
una petición procesa hasta seis fotos pendientes y permite continuar después.
El código está en el [encoder](apps/platform/server/features/matching/data/clip_image_encoder.ts)
y el [repositorio de coincidencias](apps/platform/server/features/matching/data/server_matching_repository.ts).

### Qué datos participan en la búsqueda

El responsable selecciona una búsqueda activa propia o comunitaria con fotos.
Se comparan hasta tres fotografías por caso con hallazgos independientes y
encontrados históricos activos de la misma especie, sujetos a visibilidad,
permisos y bloqueos. Los avisos ya vinculados a una búsqueda conservan su función
de colaboración y no se presentan como hallazgos independientes. El piloto admite
hasta 100 casos candidatos elegibles y muestra hasta cinco sugerencias por caso;
superar el límite devuelve un error explícito, sin truncar silenciosamente.

| Dato | Uso actual |
| --- | --- |
| Fotografías procesadas | Similitud coseno entre vectores; se toma la mayor similitud entre pares de fotos de ambos casos |
| Especie | Filtro de compatibilidad entre búsqueda y candidatos |
| Ubicación pública aproximada | Proximidad geográfica suave, sin excluir automáticamente un caso lejano |
| Fecha/hora del suceso | Cercanía temporal suave, sin excluir automáticamente un reporte tardío |
| Estado, fotos vigentes, permisos y bloqueos | Elegibilidad y rechazo de resultados obsoletos o no autorizados |

El [ranking actual](apps/platform/shared/features/matching/domain/matching.ts)
combina **85% de similitud visual, 10% de proximidad geográfica y 5% de cercanía
temporal**. La proximidad decae de forma exponencial con escalas de 50 km y 90 días,
respectivamente. Son pesos de una fórmula exploratoria, **no porcentajes de
certeza ni de acierto**. Nombre, rasgos escritos, raza y sexo no aportan puntuación
al ranking visual actual. El resultado siempre requiere revisión humana;
confirmarlo no asigna propietario ni confirma recuperación automáticamente.

### Evaluación y limitaciones conocidas

El 03/11/2026 se evaluó el modelo con [Sibetan-v1](https://www.lirmm.fr/YT-BB-Dog_Sibetan/)
(LIRMM/SEAdogSEA, CC BY 4.0), usando etiquetas oficiales de individuos: 114 fotos
distintas de 59 perros, con cinco identidades de desarrollo y 54 de prueba
separadas. Hubo 50 consultas positivas frente a 50 casos de galería y cuatro
consultas sin pareja en la galería. **Es un conjunto de evaluación; no se usó
para entrenar el modelo.**

| Métrica | Resultado medido |
| --- | --- |
| Mascota correcta entre las cinco sugerencias (Recall@5) | **28/50 — 56%** |
| Primera sugerencia correcta (top1) | **11/50 — 22%** |
| Consultas sin pareja que recibieron sugerencias | **4/4** |
| Tiempo medio local del encoder en CPU Windows |48 ms/foto; no representa la latencia total del servidor alojado |

Los datos son perros de cámaras trampa de una zona/semana de 2019; 39 pares cruzan
secuencias de vídeo y solo siete cruzan cámaras. No representan gatos ni todos
los escenarios de fotos de celulares/reportes locales. Se igualaron ubicación y
fecha en el experimento para aislar el componente visual. No hay un umbral
calibrado para rechazar todos los candidatos ni una precisión global garantizada;
el porcentaje medido no debe presentarse como probabilidad de identidad.

La validación funcional del 05/11 aprobó el flujo real con dos cuentas, fotos,
Supabase/Storage/Edge y Nuxt/CLIP, revisión/reintento, ficha, cierre/retirada,
navegador y emulador Android. Esa comprobación acredita funcionamiento en los
escenarios ensayados y no aumenta las métricas de identificación anteriores.
Véanse la [evaluación reproducible y sus hashes](docs/revisiones/coincidencias-2026-11-03.md),
los [resultados de calidad en JSON](docs/revisiones/coincidencias-2026-11-03/sibetan-resultados.json)
y la [validación alojada final](docs/revisiones/coincidencias-2026-11-05.md).

<a id="primeros-pasos"></a>

## 🚀 Primeros pasos

Las aplicaciones se organizan en dos directorios:

- [apps/mobile](apps/mobile/README.md): Flutter para Android y futuras plataformas móviles.
- [apps/platform](apps/platform/README.md): Vue/Nuxt/TypeScript para la plataforma web.

Base de datos, funciones y documentación permanecen en database, supabase y docs.
Para desarrollar la web, seguir [la guía Vue](apps/platform/DESARROLLO.md);
los pasos siguientes corresponden a Flutter. Véase [ADR-059](docs/decisiones/059-directorios-apps-platform-mobile.md).

Esta guía está dirigida a los integrantes del equipo que van a ejecutar o desarrollar la app desde el código fuente.

### 1. Preparar el equipo

| Herramienta | Referencia del proyecto |
| --- | --- |
| Git | Clonar el repositorio y trabajar con ramas |
| Flutter | **3.35.3 stable**, versión fijada en el workflow Flutter |
| Dart | **3.9.2**, incluido en esa instalación de Flutter |
| Android Studio / Android SDK | SDK, herramientas y emulador para Android |
| Editor | VS Code con extensiones Dart/Flutter o Android Studio |
| Dispositivo | Emulador iniciado o teléfono Android con depuración USB |

Comprueba tu instalación:

```powershell
flutter --version
flutter doctor
flutter devices
```

Resuelve los requisitos Android que indique `flutter doctor`. Si faltan licencias, revisa sus términos mediante `flutter doctor --android-licenses`.

### 2. Clonar e instalar dependencias

Con acceso al repositorio:

```powershell
git clone https://github.com/srg-cp/entrehuellas.git
Set-Location entrehuellas
Set-Location apps/mobile
flutter pub get --enforce-lockfile
```

La app se conserva en **`apps/mobile`**. No hay que regenerarla ni trasladarla. Si ya tienes una copia, utiliza esa copia y revisa sus cambios antes de actualizarla.

<a id="configuracion-local"></a>

## 🔑 Archivo de configuración

**La plantilla que necesitas ya está incluida:** [supabase.local.example.json](apps/mobile/config/supabase.local.example.json).

Desde la carpeta de la app, cópiala una sola vez:

```powershell
Copy-Item config/supabase.local.example.json config/supabase.local.json
```

Si `config/supabase.local.json` ya existe, conserva tu configuración. El responsable del proyecto **compartirá internamente los valores del entorno de desarrollo** para completar ese archivo.

| Campo | Qué colocar |
| --- | --- |
| `SUPABASE_URL` | URL HTTPS del entorno de desarrollo compartido |
| `SUPABASE_PUBLISHABLE_KEY` | Clave publicable del mismo entorno, con prefijo `sb_publishable_` |
| `EMAIL_OTP_VALIDITY_MINUTES` | Minutos de validez del código, solo si coinciden con la configuración real del servidor |

La plantilla contiene `15` para la validez del código: confírmalo con el responsable. Si el plazo no está confirmado, elimina ese campo; la app puede mostrar la instrucción sin afirmar una duración. Este valor informa en la interfaz y **no modifica la caducidad del servidor**.

> El archivo `*.local.json` está ignorado por Git. No lo adjuntes a issues ni pull requests. Flutter incorpora estos valores al cliente: aquí solo van datos de configuración pública, nunca `service_role`, claves secretas, contraseñas SQL o tokens personales.

No necesitas acceso administrativo a Supabase para ejecutar la app. Usa una cuenta de prueba propia y coordina con el responsable la activación del backend que requiera tu módulo. Copiar el JSON no crea tablas, políticas, funciones ni buckets.

## ▶️ Ejecutar la app

Desde `apps/mobile`, con el emulador o teléfono disponible:

```powershell
flutter run --dart-define-from-file=config/supabase.local.json
```

Si hay varios dispositivos, consulta `flutter devices` y añade `-d <id-del-dispositivo>` al comando. Al modificar la configuración, detén y vuelve a ejecutar la app: hot reload no actualiza los valores de compilación.

En **VS Code**, selecciona **Entre Huellas - desarrollo local** en Ejecutar y depurar, elige el dispositivo y pulsa **F5**. Ese perfil utiliza el mismo archivo local.

El recorrido comienza en acceso; una cuenta que no completó el onboarding debe finalizar sus tres etapas antes de entrar. El retorno móvil utiliza `entrehuellas://login-callback/`; su configuración y las pruebas reales de acceso están en [CONFIGURACION.md](docs/CONFIGURACION.md).

Si falla el acceso o falta una función remota, confirma el entorno y la activación del incremento con el responsable. No ejecutes todo el SQL sobre el servidor compartido para intentar resolverlo.

## 📦 Instalar y publicar Android

La [guía paso a paso de instalación y distribución](INSTALACION_ANDROID.md)
explica cómo generar y respaldar la firma, completar el JSON local, guardar los
cinco secrets en GitHub, activar la compilación desde `main`, descargar el APK
e instalarlo o actualizarlo en un teléfono. Incluye compilación local y solución
de errores, con comandos e indicaciones de dónde ejecutar cada paso.

El workflow está preparado para publicar una **prerelease con APK firmado** por
cada push a `main` que supere las validaciones. El usuario confirmó el24/10 la
configuración de firma, los cinco secrets y `key.properties` local; el
[inventario y estado de preparación](INSTALACION_ANDROID.md#estado-de-la-preparacion)
indica de dónde sale cada dato y los pendientes de respaldo, integración y
validación de Actions. No implica despliegue de Supabase
ni publicación en Google Play. Quien solo instala el APK no necesita Flutter,
el JSON ni las credenciales de firma.

<a id="trabajo-en-equipo"></a>

## 🤝 Trabajo en equipo

### Antes de empezar un módulo

1. Acuerda la **HU/RF**, el issue, los criterios de aceptación y los límites de la entrega. El identificador de historia y el número del issue son distintos.
2. Confirma la rama o commit de partida. `main` es la base integrada; si necesitas trabajo aún no integrado, acuerda expresamente otra base.
3. Lee [AGENTS.md](AGENTS.md), [las reglas de arquitectura](docs/REGLAS_ARQUITECTURA.md), [la arquitectura](docs/ARQUITECTURA.md), [el estado](docs/ESTADO.md), el sprint y la ficha funcional correspondientes.
4. Si modificas pantallas, lee también [las reglas de UI/UX](docs/REGLAS_UI_UX.md) y [la guía de diseño](docs/DISENO_UI.md).
5. Coordina contratos compartidos, cambios en router/bootstrap/core y numeración SQL antes de trabajar sobre ellos.

Con tu copia limpia y usando `main` como base acordada, desde la raíz del repositorio:

```powershell
git status
git switch main
git pull --ff-only origin main
git switch -c feature/nombre-del-modulo
```

### Arquitectura de cada entrega

```text
Pantalla → ViewModel → Caso de uso → Contrato de repositorio
                                      ↑ implementación inyectada
                             Repositorio de data → Fuente de datos → SDK
```

- **Dominio:** entidades, contratos, casos de uso y fallos independientes de Flutter, Riverpod y Supabase.
- **Presentación:** pantallas, widgets, ViewModels y estado. Los widgets consumen ViewModels; las operaciones de producto pasan por casos de uso.
- **Datos:** DTO, repositorios y fuentes de datos que encapsulan el SDK. Bootstrap/main inyectan las implementaciones.
- **Colaboración entre módulos:** mediante dominio y providers declarativos; sin importar presentation/data de otra funcionalidad ni features desde core.
- **Interfaz:** reutilizar los componentes aprobados. Toast superior para validación, errores y resultados; skeleton y `LoadingShimmer` para carga. Sin SnackBar, errores bajo inputs ni indicadores circulares/lineales.
- **Persistencia:** permisos y reglas críticas también en servidor. SQL versionado, migraciones generadas y RLS comprobada según [database/README.md](database/README.md). No modificar migraciones aplicadas ni editar manualmente `run_all.sql`.

Entrega incrementos completos por funcionalidad: comportamiento, persistencia, permisos, estados y pruebas pertinentes. No añadas funcionalidades futuras solo porque figuran en el plan maestro.

### Antes de entregar el pull request

Desde la carpeta de la app:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
```

Si cambias dependencias, resuélvelas primero y entrega el lockfile actualizado. El comando de formato comprueba cambios: si falla, aplica `dart format lib test` y vuelve a comprobar.

- Revisa el diff y comprueba que no contiene configuración local ni secretos.
- Verifica los criterios, fallos, reintentos y permisos afectados. Para UI, revisa tamaño normal, pantalla pequeña y texto ampliado.
- Actualiza [ESTADO.md](docs/ESTADO.md) y la ficha de [funcionalidades](docs/funcionalidades/README.md); registra pruebas ejecutadas y pendientes reales.
- Abre el PR hacia la base acordada con [la plantilla del repositorio](.github/pull_request_template.md), vincula el issue y solicita revisión antes de integrar.
- Acuerda con el responsable cualquier despliegue, migración o cambio del entorno compartido.

El [workflow Flutter](.github/workflows/flutter.yml) define formato, análisis y pruebas; sus ejecuciones se consultan en [GitHub Actions](https://github.com/srg-cp/entrehuellas/actions). Una prueba local aprobada no confirma un despliegue ni una validación real en Android/Supabase.

## 🗂️ Mapa del repositorio

```text
entrehuellas/
├── apps/mobile/   App Flutter existente
│   ├── config/                        Plantillas de configuración
│   ├── lib/app/                       Bootstrap, aplicación y router
│   ├── lib/core/                      Configuración y componentes compartidos
│   ├── lib/features/                  Domain, data, presentation y providers por funcionalidad
│   └── test/                          Pruebas, incluidas fronteras arquitectónicas
├── database/                          Fuentes SQL y generadores de migraciones
├── supabase/                          Migraciones, Edge Functions y configuración de servidor
├── docs/                              Reglas, funcionalidades, backlog y decisiones
├── logo/                              Originales del icono del sistema
└── .github/                           Workflows y plantillas de colaboración
```

<a id="documentacion"></a>

## 📚 Documentación

| Necesitas… | Consulta |
| --- | --- |
| Preparar el entorno y diagnosticar acceso | [Configuración y validación](docs/CONFIGURACION.md) |
| Configurar firma/secrets, publicar, instalar o actualizar el APK | [Instalación y distribución Android](INSTALACION_ANDROID.md) |
| Conocer lo implementado y sus pendientes | [Estado](docs/ESTADO.md) · [Funcionalidades](docs/funcionalidades/README.md) |
| Elegir y delimitar una entrega | [Guía MVP](docs/GUIA_MVP.md) · [Backlog](docs/BACKLOG_MVP.md) |
| Respetar las fronteras de código | [Reglas](docs/REGLAS_ARQUITECTURA.md) · [Arquitectura](docs/ARQUITECTURA.md) |
| Mantener la interfaz consistente | [Reglas UI/UX](docs/REGLAS_UI_UX.md) · [Diseño](docs/DISENO_UI.md) |
| Entender las decisiones técnicas | [ADR-001](docs/decisiones/001-arquitectura-aplicacion.md) · [Decisiones](docs/decisiones/) |
| Modificar datos o permisos | [Base de datos](database/README.md) |
| Actualizar el icono Android | [Fuentes y regeneración](logo/README.md) |
| Trabajar con un asistente de código | [Instrucciones del proyecto](AGENTS.md) |

---

<div align="center">
  <sub>Entre Huellas · Recuperación colaborativa de mascotas</sub>
</div>
