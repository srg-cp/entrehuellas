# ADR-156: entrada móvil única sin cortinas de fondo

Fecha:29/10/2026, America/Lima. Corrección extendida por instrucción explícita
del usuario tras ADR-155: buscar y corregir el mismo defecto en otros recorridos.

## Causa y alcance

AuthStageTransition seguía combinando un fondo AppPageBackground recortado a
las dimensiones locales durante320ms y un stagger posterior. El encuadre de
ese fondo difería del fondo de pantalla y producía un rectángulo visible.
Las transiciones de etapa retenían además el formulario anterior hasta terminar
la cortina. ADR-094 y155 habían retirado solo algunos consumidores.

La búsqueda de todas las referencias móviles localizó seis consumidores:

| Componente | Recorridos afectados |
| --- | --- |
| RegisterScreen | Formulario y confirmación por código |
| PasswordRecoveryScreen | Solicitud, código, nueva contraseña y resultado |
| AlertPreferencesScreen | Preferencias de alertas con datos disponibles |
| InterestZonesScreen | Lista y editor de ubicaciones de interés |
| CasePublicScreenShell | Consulta de fichas públicas |
| EntityScreenShell | Mascotas, reportes y sus vistas previas, listados propios, avisos, carteles, seguimiento/cronología, cierre, coincidencias, denuncias, apelaciones, bandeja, guardados, bloqueos, borradores y envíos |

## Decisión

AuthStageTransition conserva su nombre y firma de builder para los consumidores,
pero ya no dibuja cortina, fondo ni copia de la etapa anterior, y no añade una
espera antes del stagger. Se retira startCovered de la API y de sus llamadas.
Solo una etapa discreta cambia la clave del subárbol; edición/reconstrucción
mantienen su identidad. La resolución de carga pertenece a la entrada existente:
no cambia la clave al pasar de loading a datos/error/vacío. ContentReveal sigue
conservando su historial de skeleton y evita una segunda entrada de los datos.

Registro y recuperación tienen un stagger propio por etapa, también al volver
al formulario inicial. Los títulos/marca/navegación fuera de ese contenido
conservan su posición y comportamiento. No se modifican parámetros del stagger,
glass, geometría, permisos, ViewModels ni consultas. Movimiento reducido muestra
el contenido de inmediato. CoverReveal queda sin instanciaciones en producción;
su tipo histórico se conserva para las comprobaciones de ausencia existentes.

Esto sustituye la regla cover→stagger móvil de ADR-006 para todos los consumidores
restantes de este motor. Las expansiones desde origen, navegación, arranque y
onboarding con StaggerStageTransition mantienen sus contratos. La búsqueda web
no localizó esta cortina en StaggerReveal/useStaggerReveal; el clip-path aprobado
de landing es un efecto distinto y se conserva. No constituye auditoría global
de todas las animaciones ni demuestra paridad visual entre plataformas.

## Validación

Por instrucción posterior del usuario, la prevención queda como regla obligatoria
en AGENTS.md y REGLAS_UI_UX.md para integraciones actuales y futuras. No recrear
la cortina con otro nombre ni aplicar dos timelines al mismo contenido.
architecture_test detecta usos de CoverReveal (incluidos constructores nombrados
y tear-offs), startCovered y fondos/temporizadores en AuthStageTransition.
El detector incluye ejemplos positivos y negativos; la suite Flutter existente
de CI lo ejecuta sin añadir otro workflow. Complementa las regresiones reales:
no garantiza detectar una implementación nueva con nombres arbitrarios.

Pruebas reales de registro/códigos/recuperación, carga/caché de entidades,
preferencias y ubicaciones. Regresión de entidades y fichas públicas con120
fotogramas por entrada: fondo único, ausencia de cortina, progreso continuo,
etapa anterior desmontada, misma instancia al reconstruir; normal y reducido
con320×600/texto200%. Suite y análisis finales registrados en ESTADO.
Revisión física con APK/IPA nuevo pendiente; sin publicación en este incremento.
