# ADR-164: guardar una ubicación de interés sin escribir nombre

Fecha: 29/10/2026. Estado: aceptada por instrucción explícita del usuario.
Trazabilidad: HU-02.1 / RF-02,16 / issue #26, sin nueva historia ni ampliación del MVP.

## Decisión

Perfil → Ubicaciones de interés permite guardar seleccionando el punto del mapa,
con el radio inicial existente de 1 km. El nombre es opcional; se conserva el
campo para quienes quieran personalizarlo, con límite de 60 puntos de código.
La alternativa manual de coordenadas permanece disponible.

SaveInterestZone normaliza el nombre y, si queda vacío, asigna una etiqueta
determinista `Ubicación (latitud, longitud)` con cinco decimales. No usa búsqueda
inversa, GPS ni llamadas adicionales. La etiqueta se persiste como nombre y se
puede editar. Los nombres anteriores se conservan. Seleccionar un punto explícito
sigue siendo obligatorio; el encuadre inicial del mapa no cuenta como selección.

El contrato SQL010 exige un nombre persistido de 1–60 caracteres y se conserva:
la operación de dominio entrega la etiqueta antes de llamar al repositorio.
No se modifica SQL aplicado ni hace falta activar una migración. Permanecen
UUID/versiones, permisos por cuenta, deduplicación de servidor, borrador ante
fallo y continuación directa a la lista tras éxito confirmado.

## Pines

La otra petición del usuario es identificar las diferencias actuales, sin
rediseñar los marcadores. La [revisión del código](../revisiones/pines-mapas-2026-10-29.md)
registra selectores Material, resultados con marca, Recorrido y punto azul de
ficha pública. Esta decisión no unifica esos diseños.

## Validación

Pruebas de dominio para nombre vacío/espacios, etiqueta determinista en reintento,
nombre personalizado, punto obligatorio y límites existentes. ViewModel comprueba
fallo/reintento sin nombre y edición posterior. Pantalla normal y 320×350 con texto
200% comprueban guardado, scroll y descarte; la etiqueta opcional admite dos líneas.
Mapa comprueba toque/selección y alternativa ante fallo de teselas.
Resultados ejecutados y límites en [ESTADO](../ESTADO.md).
