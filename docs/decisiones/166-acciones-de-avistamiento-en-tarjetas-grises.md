# ADR-166: acciones de avistamiento en tarjetas grises

Fecha:29/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Decisión

En la ficha pública móvil, «Reportar avistamiento» y «La vi o la encontré»
adoptan el diseño de las dos tarjetas del [mockup elegido](../../mockups/acciones-ficha-tarjetas-grises.png):
superficie sólida gris claro, sin glass/ribete/sombra añadidos, radio22,
icono pequeño21 arriba a la izquierda y etiqueta14/600 debajo, alineada a la
izquierda. Padding horizontal14/vertical20; separación12 entre las dos tarjetas.
No se copian los textos ni los contadores ilustrativos de la referencia.

Se reutiliza CaseUtilityButton, con subtítulo opcional y padding configurable;
sus consumidores anteriores conservan subtítulos y padding14. Las dos acciones
mantienen sus etiquetas reales sin añadir subtítulos. CaseActionLayout con
utilities distribuye dos columnas de igual altura y apila en ancho pequeño con
texto ampliado, sin fijar altura ni reducir fuente. La acción de recuperación,
cuando corresponde, conserva su círculo y permisos debajo de la pareja.

Esta instrucción sustituye los círculos y el acento azul de ADR-153 únicamente
para estas dos acciones. Es una excepción local explícita a ADR-148: no cambia
el material de otros controles, navegación, utilidades ni tarjetas informativas.
Alcance móvil, sin migración implícita de web ni nuevas HU/RF/operaciones.

## Navegación y arquitectura

Se conservan rutas/identificador/tipo de búsqueda, permisos de visibilidad y
refresco al retornar. La tarjeta completa, incluido icono/texto/padding, es el
origen de la expansión existente320/260ms y55/55; radio/color coinciden con el
control real. Conservar reducido y una sola entrada, sin shimmer por navegación.

Solo presentación compartida y composición de found_cases, reutilizada en
búsquedas propias y comunitarias. Sin cambios en dominio, ViewModels, datos,
SQL o autorización. La imagen archivada es referencia; no se rasteriza la UI.

## Validación

Comprobar apertura/retorno y composición completa del origen, rutas reales de
los dos formularios, cierre/recuperación y permisos existentes; render normal,
ancho320/texto200%, semántica y reducido. Resultados y limitaciones en ESTADO.
