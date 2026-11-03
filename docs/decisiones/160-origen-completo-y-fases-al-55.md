# ADR-160: composición de origen completa y fases al 55%

Estado: aceptada por instrucción explícita del usuario. Fecha:29/10/2026.

## Problema

Inicio entregaba solo una flecha al motor de expansión, aunque el control
visible también tenía texto o ilustración. Recorrido entregaba únicamente
una imagen de120px en lugar de su tarjeta; las utilidades sustituían su
contenido por un icono de otro tamaño. El motor centraba esas representaciones
incompletas, provocando desapariciones y saltos en el primer fotograma.
El acceso de nueve puntos y el botón + delegado también podían entregar una
identidad distinta de la real. La fase fuente terminaba al45% y el destino
empezaba al65%, dejando un intervalo sin ninguno de los dos contenidos.

## Decisión

Se conserva la expansión de superficie con desvanecimiento de origen/destino;
no se requiere transformar cada elemento en otro del destino.

- En el motor móvil compartido, la fuente se desvanece del0 al55% y el
  destino aparece del55 al100%. Apertura y retorno conservan320/260ms,
  curvas, escala, radio y movimiento reducido. Al55% exacto ambos tienen
  opacidad0, pero ya no existe un intervalo temporal entre las dos fases.
- OriginDialogTransition usa los mismos límites del55%, conservando su
  curva de fuente y el cierre sin copia de origen existente. Los diálogos
  web equivalentes comparten los límites mediante origin_motion_contract.
- La identidad reproduce todo el contenido que pertenece al rectángulo
  capturado, con el mismo layout, tipografía, iconos, imagen y escala de texto.
  Se desvanece como un conjunto de tamaño fijo dentro de la superficie,
  sin retirar hermanos y recentrar solo el icono. Las etiquetas externas
  a controles circulares siguen fuera del origen.
- Reutilizar contenido entre el control real y su copia de presentación:
  botones/buscador de Inicio, nueve puntos, utilidades y tarjeta Recorrido.
  CollectionAddButton ofrece su composición a callbacks de navegación;
  OriginPageSource.capture conserva temas y MediaQuery del control real.
- Un origen parcialmente visible por scroll conserva sus límites completos;
  el viewport recorta la pintura, sin reducir primero el rectángulo ni mover
  el centro de su contenido. Un origen totalmente fuera conserva el fallback.
- Web captura únicamente el control completo con estilos resueltos, sin
  reconstruir icono y etiqueta en una columna distinta. Copia temporal inerte,
  sin IDs, eventos ni navegación; eliminación al acabar/cancelar y liberación
  de referencias con el coordinador existente. No se copian páginas/formularios
  ni se persisten nodos o datos.
- Al abrir una ruta web desde scroll, el cuerpo del destino se coloca en
  coordenadas documentales; así no hereda el desplazamiento de Inicio ni salta
  al finalizar el morph. Cierre y editores locales conservan su posición actual.
- El motor fullscreen Sader conserva sus700ms/CustomEase y fade/blur del
  destino en500ms, excepción vigente ADR-127/128; su fase fuente pasa al55%.
  No sustituir esa entrada por otro stagger o una cortina.

La precisión del55% sustituye los límites45/65 de ADR-124 y el45% de ADR-128.
Las demás diferencias expresamente acordadas de ambos motores se conservan.
Solo presentación: sin nuevas HU/RF, operaciones, SQL, permisos, dependencias
ni ampliación de MVP. Sin publicación/despliegue o acciones GitHub implícitas.

## Validación

Pruebas de fases, geometría inicial completa, scroll parcial, composición,
apertura/retorno, texto200% y movimiento reducido. Revisar fotogramas de los
tres recorridos reportados, controles compartidos y equivalentes web; comprobar
que no queden copias interactivas o residuos al terminar/cancelar.
Resultados, capturas y revisión física pendiente en [ESTADO](../ESTADO.md).
