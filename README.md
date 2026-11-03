<div align="center">

<<<<<<< HEAD
Aplicación móvil de recuperación colaborativa de mascotas. Diseñada con enfoque **Android primero**, arquitectura limpia y backend en Supabase. El sistema permite reportar mascotas perdidas o encontradas, generar fichas y carteles con código QR, recibir reportes ciudadanos de avistamientos desde una web pública ligera sin necesidad de instalar la app, y coordinar el reencuentro de forma segura y comunitaria.

---

## Índice

- [Visión del Proyecto](#visión-del-proyecto)
- [Base Técnica y Arquitectura](#base-técnica-y-arquitectura)
- [Estructura del Repositorio](#estructura-del-repositorio)
- [Funcionalidades Implementadas](#funcionalidades-implementadas)
- [Base de Datos y Supabase](#base-de-datos-y-supabase)
- [Puesta en Marcha y Desarrollo](#puesta-en-marcha-y-desarrollo)
- [Comprobaciones y Pruebas](#comprobaciones-y-pruebas)
- [Documentación del Proyecto](#documentación-del-proyecto)
- [Decisiones de Arquitectura (ADR)](#decisiones-de-arquitectura-adr)

---

## Visión del Proyecto

Entre Huellas aborda la problemática de mascotas extraviadas articulando la colaboración comunitaria en tiempo real:

1. **Publicación ágil:** Registro del caso (perdido o encontrado) con fotografías, datos descriptivos, fecha/hora y zona geográfica.
2. **Ficha y QR colaborativo:** Generación de carteles físicos y digitales con un código QR único.
3. **Avistamientos sin barreras:** Cualquier ciudadano que escanee el QR accede a una ficha web ligera para reportar coordenadas y evidencia fotográfica sin instalar la app.
4. **Bandeja de recuperación:** El responsable recibe alertas, evalúa avistamientos en mapa y cronología, y coordina el cierre del caso.
5. **Privacidad y moderación:** Separación estricta entre datos públicos del QR y datos privados del usuario, respaldada por políticas de seguridad a nivel de base de datos (RLS).

---

## Base Técnica y Arquitectura

El proyecto adopta **Clean Architecture por funcionalidad** combinada con el patrón **MVVM** y **Riverpod** para la inyección de dependencias y el estado reactivo:

- **Plataforma principal:** Flutter (Android primero; preparado para web y multiplataforma).
- **Presentation (`presentation/`):** Pantallas (`screens`), modelos de vista (`view_models`), estados inmutables (`state`) y componentes visuales reutilizables (`widgets`). Consume exclusivamente casos de uso y no invoca directamente repositorios ni SDKs.
- **Domain (`domain/`):** Núcleo del negocio independiente de Flutter, Riverpod y Supabase. Contiene entidades (`entities`), contratos de repositorios (`repositories`), fallos de dominio (`failures`) y casos de uso concretos (`use_cases`).
- **Data (`data/`):** Implementaciones de repositorios (`repositories`), fuentes de datos (`data_sources`) que encapsulan el SDK de Supabase o servicios externos, y DTOs/modelos (`models`). Mapea respuestas del backend a entidades y fallos de infraestructura a fallos tipados de dominio.
- **Inyección y composición (`providers/`):** Providers de Riverpod desacoplados que exponen contratos y casos de uso.
- **Navegación reactiva:** `go_router` configurado de forma centralizada y sincronizado con `EntryViewModel` para enrutar según el estado de la sesión y del onboarding.
- **Feedback contextual sin SnackBar ([ADR-005](docs/decisiones/005-feedback-sin-snackbar.md)):** Se prohíbe el uso de `SnackBar` o toasts inferiores. Los errores se comunican en el propio contexto del formulario mediante bordes destacados (3.5 px), micro-animación de sacudida (*shake*), iconos temáticos y mensajes descriptivos accesibles.

Los fundamentos y justificación técnica se detallan en [ADR-001](docs/decisiones/001-arquitectura-aplicacion.md) y en las [Reglas de Oro de Arquitectura](docs/REGLAS_ARQUITECTURA.md).

---

## Estructura del Repositorio

```text
entrehuellas/
├── flutter_application_entrehuellas/ # Aplicación móvil en Flutter
│   ├── lib/
│   │   ├── app/                      # Bootstrap, configuración de la app y enrutador go_router
│   │   ├── core/                     # Tema Material 3, configuración y widgets compartidos
│   │   └── features/                 # Funcionalidades bajo Clean Architecture
│   │       ├── auth/                 # Acceso, registro y ciclo de sesión (HU-01)
│   │       ├── home/                 # Pantalla principal tras autenticación
│   │       └── onboarding/           # Onboarding interactivo guiado por cuenta
│   ├── test/                         # Suite completa de pruebas unitarias y de widgets
│   ├── assets/                       # Ilustraciones y recursos visuales oficiales
│   └── config/                       # Plantillas de configuración local de Supabase
├── database/                         # Fuentes SQL de PostgreSQL estructuradas por objeto
│   ├── tables/                       # Tablas y restricciones (profiles, etc.)
│   ├── functions/                    # Funciones PL/pgSQL y RPCs seguras
│   ├── triggers/                     # Triggers vinculados a eventos de Auth
│   ├── policies/                     # Políticas de seguridad RLS por propietario
│   ├── grants/                       # Asignación estricta de privilegios por rol y columna
│   ├── migration_plans/              # Planes de migración por incremento funcional
│   ├── scripts/                      # Generadores PowerShell (Build-Migration, Build-RunAll)
│   ├── tests/                        # Pruebas locales de permisos con PostgreSQL en memoria (PGlite)
│   └── run_all.sql                   # Entrada SQL maestra, autocontenida e idempotente
├── supabase/
│   └── migrations/                   # Migraciones versionadas e inmutables para despliegue
├── docs/                             # Documentación exhaustiva, guías y especificaciones
│   ├── decisiones/                   # Architectural Decision Records (ADR-001 al ADR-005)
│   ├── ARQUITECTURA.md               # Detalle de capas, responsabilidades y flujo de datos
│   ├── REGLAS_ARQUITECTURA.md        # Norma y restricciones arquitectónicas del proyecto
│   ├── CONFIGURACION.md              # Guía de configuración de Supabase, deep links y entorno
│   ├── DISENO_UI.md                  # Sistema de diseño, tokens, tipografía y micro-animaciones
│   ├── ESTADO.md                     # Registro cronológico del estado del proyecto y comprobaciones
│   └── GUIA_MVP.md                   # Plan maestro, sprints (S1-S6) e historias de usuario (HU-01 a HU-16)
├── logo/                             # Recursos de identidad de marca e icono adaptativo Android
└── mockups/                          # Material gráfico y referencias visuales de partida
```

---

## Funcionalidades Implementadas

### 1. Acceso y Autenticación (Sprint 1 / HU-01 / RF-01, RF-34)
- **Inicio de sesión:** Formulario limpio con correo/contraseña y botón de acceso con Google OAuth.
- **Google OAuth móvil:** Autenticación con flujo PKCE y retorno configurado mediante el deep link `entrehuellas://login-callback/`.
- **Manejo de errores seguro y contextual:** Detección de credenciales inválidas, correo no confirmado y problemas de conexión mediante el sistema sin SnackBar ([ADR-005](docs/decisiones/005-feedback-sin-snackbar.md)).
- **Sesión reactiva:** Observación de la sesión en tiempo real a través del caso de uso `WatchAuthSession`.

### 2. Crear Cuenta y Confirmación de Correo (`/register`)
- **Transición fluida:** Expansión visual tipo *morphing* desde el botón de origen (`OriginPageTransition`) y contracción al cerrar con la acción superior.
- **Formulario completo:** Nombre completo, correo electrónico, contraseña segura (mínimo 8 caracteres) y confirmación de contraseña.
- **Entrada escalonada (*Stagger Reveal*):** Animación en cascada con desenfoque progresivo (*blur*) inspirada en estándares de interfaz modernos.
- **Pantalla de confirmación:** Vista informativa ("Revisa tu correo") para cuentas pendientes de confirmación, con temporizador de reenvío de 60 segundos.
- **Sincronización en base de datos:** Creación automática del perfil asociado en `public.profiles` mediante trigger de Supabase Auth con los metadatos de usuario (`full_name`).

### 3. Onboarding Guiado por Cuenta ([ADR-004](docs/decisiones/004-onboarding-por-cuenta.md))
- **Recorrido de 3 etapas:** "Cada huella importa", "Volvamos a casa" y "Una nueva historia", con ilustraciones personalizadas en alta resolución.
- **Sin opción de omitir:** El usuario completa el recorrido pulsando "Comenzar" en la última etapa, garantizando la familiarización con la plataforma.
- **Efecto de cascada por línea:** Revelado de títulos y descripciones línea por línea con desenfoque suave al posicionarse en cada pantalla.
- **Persistencia en base de datos:** Registro de finalización en `public.profiles.onboarding_completed_at` mediante la función RPC `complete_onboarding(auth.uid())`. El estado persiste por cuenta en servidor y sobrevive a reinstalaciones o cambios de dispositivo.

### 4. Navegación y Destino Dinámico
- El router centralizado dirige al usuario según su estado real:
  - Sin sesión activa $\rightarrow$ Pantalla de inicio de sesión (`/access`).
  - Con sesión y onboarding pendiente $\rightarrow$ Pantalla de onboarding (`/onboarding`).
  - Con sesión y onboarding finalizado $\rightarrow$ Pantalla principal (`/home`).

---

## Base de Datos y Supabase

La base de datos sigue las directrices de [ADR-002](docs/decisiones/002-organizacion-database.md) y [ADR-003](docs/decisiones/003-ejecucion-sql-idempotente.md):

- **Nomenclatura uniforme:** Identificadores en inglés y minúsculas con `snake_case`.
- **Estructura por objetos y orden global:** Scripts numerados secuencialmente (`001_...sql` a `009_...sql`) que resuelven dependencias de forma determinista.
- **Ejecución idempotente (`database/run_all.sql`):** Script maestro seguro para ejecutar repetidamente en el SQL Editor de Supabase sin duplicar datos ni alterar registros existentes.
- **Migraciones versionadas (`supabase/migrations/`):**
  - `20261007000100_auth_profiles.sql`: Creación de la tabla `profiles`, triggers de sincronización con `auth.users`, políticas RLS por propietario y privilegios por columna.
  - `20261007000200_onboarding_completion.sql`: Columna `onboarding_completed_at` y función RPC protegida `complete_onboarding`.
- **Verificación de permisos:** Suite de pruebas en `database/tests/` ejecutadas sobre PostgreSQL en memoria (PGlite) para validar aislamiento entre usuarios, protección de columnas y restricciones.

---

## Puesta en Marcha y Desarrollo

### Requisitos Previos
- **Flutter SDK:** 3.35+ (Dart 3.9+).
- **Android Studio / Herramientas:** Android SDK Platform-Tools, Command-line Tools y un emulador o dispositivo físico configurado.
- **Node.js (opcional):** Para ejecutar la suite de pruebas SQL en local.

### 1. Clonar y preparar dependencias

```powershell
git clone https://github.com/srg-cp/entrehuellas.git
Set-Location entrehuellas/flutter_application_entrehuellas
flutter pub get --enforce-lockfile
```

### 2. Configurar el acceso a Supabase

1. Copiar el archivo de plantilla:
   ```powershell
   Copy-Item config/supabase.local.example.json config/supabase.local.json
   ```
2. Completar `config/supabase.local.json` con la URL HTTPS de tu proyecto y la clave **publicable** (`sb_publishable_...`). *Este archivo está ignorado por Git para proteger credenciales locales.*
3. En el panel de Supabase (**Authentication → URL Configuration → Redirect URLs**), registrar la URL de retorno móvil:
   ```text
   entrehuellas://login-callback/
   ```

### 3. Aplicar el esquema en la base de datos

En el SQL Editor de tu proyecto Supabase, pegar y ejecutar el contenido completo de [database/run_all.sql](database/run_all.sql).

### 4. Ejecución en desarrollo

- **Desde VS Code (Recomendado):**
  - Abrir la carpeta del proyecto en VS Code.
  - Ir a **Ejecutar y depurar** (`Ctrl+Shift+D` / `F5`).
  - Seleccionar el perfil **Entre Huellas - desarrollo local** (carga automáticamente el archivo de configuración local).
  - O seleccionar **Entre Huellas - sin Supabase** para explorar la app sin backend conectado.
- **Desde la terminal:**
  ```powershell
  # Con configuración de Supabase:
  flutter run --dart-define-from-file=config/supabase.local.json

  # Sin configuración de backend:
  flutter run
  ```

---

## Comprobaciones y Pruebas

El proyecto cuenta con verificación estricta de dependencias, sintaxis, arquitectura y pruebas automatizadas:

### Comprobaciones de Flutter (en `flutter_application_entrehuellas`)

```powershell
# Verificar formato de código
dart format --output=none --set-exit-if-changed lib test

# Análisis estático y linter
flutter analyze --no-pub

# Ejecutar la suite de pruebas automatizadas (65+ pruebas)
flutter test --no-pub
```

La suite cubre:
- Cumplimiento de fronteras arquitectónicas (prohibición de dependencias directas de presentación a datos o SDK).
- Verificación de la regla sin SnackBar en todo el código base.
- Validación de formularios, tiempos de espera, ciclos de vida y reintentos.
- Transiciones visuales (`OriginPageTransition`, `StaggerReveal`).
- Adaptabilidad en pantallas pequeñas (320×350) y accesibilidad con escala de texto al doble.

### Comprobaciones de Base de Datos (en `database/tests`)

```powershell
npm ci --ignore-scripts
npm test
```

Valida idempotencia del `run_all.sql`, aislamiento RLS entre diferentes usuarios y permisos de funciones RPC sobre PostgreSQL en memoria.

---

## Documentación del Proyecto

El repositorio cuenta con documentación exhaustiva en la carpeta [`docs/`](docs/):

- [Guía de trabajo, chats, sprints y GitHub](docs/GUIA_MVP.md): Hoja de ruta para el desarrollo del MVP y desglose de sprints.
- [Reglas de oro de arquitectura](docs/REGLAS_ARQUITECTURA.md): Norma técnica obligatoria sobre capas, SOLID y límites de dependencias.
- [Arquitectura del sistema](docs/ARQUITECTURA.md): Especificación detallada de componentes, inyección y flujo de información.
- [Diseño y componentes de interfaz](docs/DISENO_UI.md): Guía de estilos, tokens de diseño, tipografía, paleta de colores y componentes.
- [Configuración y validación](docs/CONFIGURACION.md): Instrucciones técnicas de puesta en marcha, depuración OAuth y pruebas móviles.
- [Estado del proyecto y bitácora](docs/ESTADO.md): Registro cronológico de hitos alcanzados, resultados de pruebas y tareas pendientes.
- [Instrucciones para agentes de IA](AGENTS.md): Reglas operativas y directrices para asistentes de desarrollo.
- [Documentación del módulo Flutter](flutter_application_entrehuellas/README.md): Instrucciones específicas del cliente móvil.
- [Documentación de base de datos](database/README.md): Convenciones SQL, generación de migraciones y pruebas de permisos.
- [Icono y recursos Android](logo/README.md): Especificaciones de generación del icono adaptativo para Android.

---

## Decisiones de Arquitectura (ADR)

Todas las decisiones estructurales del proyecto se documentan formalmente en [`docs/decisiones/`](docs/decisiones/):

- [**ADR-001: Arquitectura de la aplicación**](docs/decisiones/001-arquitectura-aplicacion.md): Adopción de Clean Architecture por funcionalidad, MVVM, Riverpod y Supabase para el MVP.
- [**ADR-002: Organización de database y migraciones**](docs/decisiones/002-organizacion-database.md): Estructuración del SQL por tipo de objeto y generación automatizada de migraciones.
- [**ADR-003: Ejecución SQL repetible y estándar de nombres**](docs/decisiones/003-ejecucion-sql-idempotente.md): Creación de `run_all.sql` idempotente y convención `snake_case`.
- [**ADR-004: Onboarding por cuenta tras autenticación**](docs/decisiones/004-onboarding-por-cuenta.md): Flujo de 3 etapas sin opción de omitir, con persistencia en el perfil del usuario mediante RPC.
- [**ADR-005: Feedback contextual sin SnackBar**](docs/decisiones/005-feedback-sin-snackbar.md): Supresión total de SnackBars y toasts en favor de micro-animaciones y feedback contextual accesible.
=======
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
con hallazgos independientes y revisión humana. La implementación está en
`feature/case-matching`; el patch040 fue aplicado según confirmación del usuario.
La evaluación con fotos autorizadas, la prueba entre dos cuentas y la aceptación
siguen pendientes. Consulta el [recorrido y la configuración](docs/funcionalidades/coincidencias-de-casos.md).

La app cuenta con implementaciones de acceso y onboarding por cuenta, perfil, mascotas y fotos, zonas de interés, preferencias de alertas, búsquedas y avisos vinculados, y consulta de Mis reportes. **Implementado no significa historia cerrada ni despliegue confirmado**: la evidencia y los pendientes se registran en [las fichas funcionales](docs/funcionalidades/README.md) y [el estado del proyecto](docs/ESTADO.md).

Explorar, la web pública QR y la entrega real de alertas tienen trabajo pendiente. Guardar preferencias de alertas no implica que ya se envíen notificaciones. Consulta el alcance en [la guía del MVP](docs/GUIA_MVP.md).

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
>>>>>>> 4dab80e3fac03b7e18bf342123c45bd9a3aa0135
