# ADR-171: perfil agrupado y navegación horizontal móvil

Fecha: 30/10/2026, America/Lima. Estado: aceptada por instrucción explícita.

## Contexto y autorización

El usuario aprueba las propuestas imagegen del resumen de Perfil con chevrón
y del editor separado. Solicita entrada lateral y retorno inverso, coherencia
con la UI existente y reutilización de código. HU-01.7 / RF-01 / issue #23;
refinamiento de presentación, sin nueva historia ni ampliación de permisos.

## Decisión

- Perfil muestra avatar/nombre/ciudad reales en una sola fila accesible que abre
  `/home/profile/edit`. Sin botón Editar separado ni formulario en el resumen.
- Mi actividad agrupa Borradores, Envíos y Mis apelaciones; Alertas y zonas agrupa
  Preferencias de alertas y Ubicaciones de interés; Privacidad contiene Cuentas
  bloqueadas. Tarjetas GlassSurface.card, filas completas y separadores suaves.
  Cerrar sesión conserva su acción real y acabado danger suave.
- Editor: avatar112 con cámara polished, nombre, correo seleccionable de solo
  lectura/candado, ciudad con buscador compartido y celular privado opcional con
  país/prefijo. Se reutilizan ProfileEditor/ProfilePhotoEditor y sus ViewModels,
  casos de uso y repositorios. Sin datos de ejemplo en producción.
- Guardar conserva etiqueta, shimmer de superficie completa, bloqueo de duplicados,
  validación/toast/reintentos y confirmación remota. Solo se habilita con cambios.
  Volver/Atrás conserva cambios si se cancela el descarte; no sale mientras guarda
  o procesa foto. Recuperaciones y fotos fallidas pendientes también se protegen.
- Editor y seis destinos del menú usan horizontalPage/HorizontalPageTransition:
  destino desde derecha y anterior hacia izquierda al avanzar; inversión al volver.
  Apertura320ms, retorno260ms, easeInOutCubic, desplazamiento de un viewport.
  Movimiento reducido directo. El avatar de Inicio conserva su expansión/cierre
  desde origen; su página participa como anterior en el deslizamiento interno.
- La entrada horizontal es la única entrada inicial de sus destinos. PageEntranceScope
  evita superponer stagger/blur sin eliminar contenido ni añadir coberturas.
  AuthStageTransition restaura el stagger solo ante un nuevo cambio discreto de
  etapa (p. ej., editar una ubicación). Skeleton→resultado y edición no reinician
  la entrada. El retorno no vuelve a animar el resumen ni reinicia su scroll.
- ProfileScreenShell comparte composición, scroll, insets y navegación glass.
  El título se coloca junto al control cuando cabe; con texto ampliado pasa a
  fila propia, sin reducir fuente. Filas, campos y acciones crecen y hacen scroll.

## Alcance y alternativas

La autorización corresponde a las pantallas móviles mostradas y su navegación.
Excepción local explícita al morph de destinos internos y al stagger inicial,
registrada frente a ADR-124/156; sin migración web ni cambio global de navegación.
Se descarta mantener el formulario y los enlaces sueltos en una misma página;
también duplicar formularios/materiales/transiciones por destino. Las pantallas
de cada funcionalidad conservan su contenido y acciones existentes.

## Consecuencias y validación

Solo presentación/composición del router; la nueva ruta conserva acceso de cuenta.
Sin SQL, nueva persistencia, dependencias ni importaciones entre presentaciones
de funcionalidades. Se preservan cambios locales ajenos del gesto de recarga.

Pruebas de navegación real, apertura/cierre intermedios, guardado y descarte,
acceso sin sesión, datos pendientes/error/reintento/cambio de identidad, texto200%
y reducido, además de arquitectura/consistencia y regresiones de destinos.
Resultados, renders y comprobaciones pendientes: [ESTADO](../ESTADO.md).
Referencia funcional: [Perfil](../funcionalidades/perfil.md).
