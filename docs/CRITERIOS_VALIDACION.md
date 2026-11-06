# Criterios de validación

Esta guía reúne las comprobaciones mínimas para revisar cambios en Entre
Huellas. Debe aplicarse junto con las reglas de arquitectura, UI/UX y las
decisiones vigentes del recorrido modificado.

## Alcance y trazabilidad

- Identificar la historia de usuario, requisito funcional e issue relacionados.
- Confirmar que el cambio no amplía el MVP ni incorpora recorridos vacíos.
- Distinguir implementación local, activación remota y aceptación funcional.
- Registrar dependencias, riesgos conocidos y validaciones pendientes.

## Arquitectura

- Mantener las reglas del producto en dominio y el acceso externo en data.
- Evitar dependencias de Flutter, Vue, Nuxt, Riverpod o Supabase en dominio.
- Hacer que pantallas y componentes consuman estado y acciones mediante sus
  ViewModels, sin consultar repositorios o SDK directamente.
- Componer implementaciones en bootstrap y conservar contratos sustituibles.
- Evitar ciclos e imports de presentation o data entre funcionalidades.

## Interfaz y accesibilidad

- Reutilizar componentes compartidos y respetar la referencia visual vigente.
- Verificar tamaño normal, pantalla pequeña y texto ampliado.
- Comprobar foco, etiquetas semánticas, orden de lectura y áreas táctiles.
- Respetar movimiento reducido y evitar reiniciar animaciones por edición,
  actualización o cambios internos de estado.
- Usar skeleton para carga inicial, shimmer para acciones reales y el toast
  superior compartido para validación, errores y resultados.

## Estado y errores

- Diferenciar carga, vacío confirmado, error recuperable y contenido disponible.
- Conservar datos durante una actualización explícita de la misma cuenta.
- Limpiar estado privado al cambiar de identidad o cerrar sesión.
- Bloquear envíos duplicados y conservar reintentos idempotentes.
- No presentar una operación como completada antes de su confirmación real.

## Datos, privacidad y permisos

- Validar autorización en servidor para cada operación protegida.
- Comprobar RLS, grants, restricciones y funciones con usuarios distintos.
- Evitar exponer coordenadas exactas, documentos, tokens o datos privados en
  proyecciones públicas, logs, URLs o respuestas serializadas.
- Versionar cambios de esquema y comprobar repetición de las migraciones.
- Verificar que los fallos externos se conviertan en errores de dominio seguros.

## Pruebas por plataforma

### Móvil

- Ejecutar formato, análisis estático y pruebas relacionadas con el cambio.
- Probar el recorrido en Android con navegación, retorno y restauración de estado.
- Revisar comportamiento con teclado, insets y área segura inferior.

### Web

- Ejecutar comprobaciones de tipos, pruebas y build de producción pertinentes.
- Verificar renderizado de servidor, hidratación y navegación cliente.
- Confirmar que la política global de acceso cubre las rutas intervenidas.
- Revisar diseño responsive y funcionamiento sin movimiento cuando corresponda.

### Base de datos y servicios

- Probar permisos entre usuarios, invariantes, concurrencia y reintentos.
- Verificar idempotencia y conservación del historial requerido.
- Separar claramente evidencia local de activación y verificación remotas.

## Evidencia de cierre

Antes de considerar terminado un incremento, registrar:

- archivos y recorridos modificados;
- comandos ejecutados y resultados obtenidos;
- escenarios manuales comprobados;
- limitaciones o validaciones pendientes;
- siguiente paso verificable.

Una compilación correcta no demuestra por sí sola permisos, comportamiento
remoto, calidad visual ni aceptación de una historia de usuario.
