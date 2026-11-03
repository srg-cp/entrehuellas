# ADR-158: continuar directamente tras completar operaciones

Fecha:29/10/2026. Instrucción explícita del usuario: eliminar las pantallas
de éxito que solo obligan a pulsar otro botón para continuar.

## Decisión

En móvil, publicar pérdida, búsqueda comunitaria, hallazgo o aviso abre directamente
su ficha, reemplazando el editor. Un avistamiento vuelve a la ficha de destino;
una denuncia vuelve al contenido anterior. El cambio de contraseña cierra la
capacidad de recuperación antes de continuar al acceso. Si ese cierre falla,
permite reintentarlo sin volver a guardar la contraseña.

En web, publicar un reporte abre su ficha o la búsqueda vinculada, cambiar la
contraseña vuelve al acceso con aviso superior, el avistamiento QR cierra su
formulario y moderación consulta directamente el estado actualizado.

Se retiran las confirmaciones posteriores que exigían Ver ficha pública,
Volver a iniciar sesión, Volver a la ficha/contenido, Ir a Explorar o Consultar
estado actual. El estado confirmado/recibo sigue en los modelos y contratos;
no se confunde éxito con respuesta ambigua. No se alteran permisos, persistencia,
idempotencia, código de verificación, onboarding ni confirmaciones previas.
Vacíos, errores con reintento y recibos con valor de consulta no son pasos
de éxito redundantes y conservan sus contratos.

## Validación y límites

Pruebas de navegación real y modelos, arquitectura, análisis móvil y comprobaciones
web registradas en ESTADO. Los tests preparan la proyección antes de confirmar
la publicación porque ahora se consulta inmediatamente, sin una pulsación extra.
Sin publicación ni despliegue. Revisión física/alojada pendiente.
