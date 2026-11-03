# Recarga de contenido por gesto móvil

30/10, [ADR-170](../decisiones/170-tiron-de-recarga-con-gesto-exclusivo.md):
el gesto debe comenzar arriba y hacia abajo, desde cualquier altura del contenido.
El tirón controla exclusivamente el círculo hasta soltar/cancelar; retroceder lo
recoge y desarma bajo el umbral, sin scroll simultáneo ni recarga al cancelar.
Un nuevo gesto desplaza normalmente. Llegar al top desde más abajo o invertir
un scroll iniciado hacia arriba no muestra el círculo. Aspecto y operaciones
conservados; sustituye reconocimiento/ajuste posterior de ADR-162.

PullToRefresh es presentación compartida de los consumidores existentes:
Inicio/Explorar/Mis mascotas, guardados, ubicaciones, avisos y recorridos que
declaran recarga. PullToRefreshTarget inscribe la operación de la sección activa.
Las pantallas/ViewModels conservan lectura de datos, feedback y reintentos;
el componente no añade persistencia ni permisos propios.

Jalar desde arriba muestra el icono glass y lo gira según el avance del dedo.
Soltar por debajo del umbral lo retira sin consultar; superar el umbral ejecuta
una operación con giro durante su Future. El consumidor conserva contenido y
shimmer. El fallo mantiene feedback/reintento del ViewModel; se admite otra
petición tras resolver la anterior. Acción accesible Actualizar contenido
conservada; sin scrolls anidados/horizontales ni formularios desactivados.

29/10, [ADR-162](../decisiones/162-recarga-por-gesto-y-retorno-al-top.md): limitar
la posición pintada ya no congela el giro. Cancelar con rebote retira desde la
primera actualización balística; confirmar/cancelar acomoda el scroll primario
al top de la pantalla actual. Sin navegación ni reinicio del stagger y sin
forzar el top durante scroll ordinario. Movimiento reducido directo/sin giro.

Validación:47 pruebas locales aprobadas del componente/consumidores y reglas;
clamping/bouncing, normal/reducido, gesto parcial/completo/largo y duplicados.
Análisis lib/test sin incidencias; sin nueva activación de backend ni cierre de
historias. Pendiente recompilar y revisar Android/iOS físicamente, incluidos
texto ampliado y pantallas pequeñas. Logs y límites en ESTADO.

Validación30/10:42 pruebas aprobadas de gesto/consumidores/arquitectura y
consistencia, incluidas nueve regresiones nuevas. Normal/reducido, clamping/
bouncing,320×600 y texto200%, cancelación/desmontaje y duplicados comprobados.
Análisis completo inicial y focalizado final limpios; detalles en ESTADO.
Pendiente recompilar y revisar el gesto físicamente en Android/iOS; sin nuevas
capturas visuales ni activación de backend.
