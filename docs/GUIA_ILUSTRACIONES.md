# Guía de ilustraciones de Entre Huellas con imagegen

Recorrido de búsqueda26/10, ADR-153: [fuente/prompt archivados](../output/imagegen/case-journey-2026-10-26/README.md).
Mapa/lupa transparente con dos pines oficiales, origen rojo/recorrido celeste y
trazo de huellas de marca, por corrección explícita. Asset separado de card,
fechas y controles nativos. El mapa funcional usa el SVG oficial existente.

Adopción web26/10: los cuatro WebP finales se reutilizan sin cambios en
[public/images/home](../apps/platform/public/images/home/README.md), con igualdad
SHA256 respecto a móvil. La composición responsive se resuelve en CSS y mantiene
texto/controles nativos; no se generaron variantes de mayor tamaño.
[ADR-147](decisiones/147-inicio-web-con-banners-ilustrados.md).

Fecha: 26 de octubre de 2026. Referencia: [ADR-143](decisiones/143-inicio-mobile-banners-ilustrados-y-scroll.md).

Este documento reúne la dirección visual, los archivos de referencia, los prompts
y el proceso usados para las ilustraciones del Inicio móvil. Sirve para preparar
variantes de la misma familia en móvil o web. La composición aprobada está en
[Inicio](funcionalidades/inicio.md); las fuentes de marca y reglas generales siguen
en [Identidad visual](funcionalidades/identidad-visual.md) y [Diseño UI](DISENO_UI.md).

La corrección explícita del usuario fue: mascotas menos realistas y más cercanas
a los personajes de Platform; conservar los escenarios y lo que hay detrás.
Esa corrección prevalece sobre las primeras generaciones del Home.

## 1. Uso rápido

1. Elegir los personajes de referencia y el destino: banner con escenario,
   ilustración transparente, fotos decorativas o fondo ilustrativo.
2. Adjuntar las imágenes reales indicadas en la tabla de referencias; explicar
   qué aporta cada una. El nombre del archivo en el prompt no adjunta la imagen.
3. Usar el bloque común de estilo y añadir escena, encuadre, zonas libres,
   transparencia e invariantes. Para editar, indicar exactamente qué cambia.
4. Generar cada asset por separado con imagegen integrado; revisar los personajes
   junto a los de Platform y conservar los elementos aprobados del escenario.
5. Exportar, comprobar transparencia y revisar dentro del componente real,
   con texto ampliado y distintos anchos. Guardar prompt y referencias.

Para reutilizar una imagen sin cambios, usar el asset existente. Generar una
variante solo si la escena, postura o composición lo necesita.

## 2. Referencias y qué aporta cada una

Las rutas siguientes están dentro del proyecto. Las dos bases de edición y la
referencia de composición se han archivado para que la guía no dependa de Temp
ni de la carpeta personal de imágenes generadas.

| Archivo | Papel en este trabajo |
| --- | --- |
| [hero-dog.png](../apps/platform/public/images/landing/hero-dog.png) | Referencia principal del pastor alemán: identidad, proporciones, ojos, hocico y expresión. Adjuntado en la corrección del banner Reportar. |
| [hero-cat.png](../apps/platform/public/images/landing/hero-cat.png) | Referencia principal del gato crema/marrón de ojos azules. Adjuntado en la misma corrección. |
| [dog-report.png](../apps/platform/public/images/landing/dog-report.png) | Referencia de proporciones y acabado de personajes para el perro de la puerta y las fotos. No copiar su papel, gato acompañante o colores de pañuelo si la escena no los pide. |
| [pets-home.png](../apps/platform/public/images/landing/pets-home.png) | Comparación visual del estilo de Platform durante la revisión: pareja amable, formas redondeadas y escenario de hogar. No fue adjunto de los prompts finales. |
| [reunion.png de móvil](../apps/mobile/assets/illustrations/reunion.png) | Referencia inicial de pareja/emblema al crear la escena de Reportar. Para el acabado final de personajes gobiernan hero-dog/hero-cat y la corrección posterior. |
| [Mockup aprobado: al abrir](../output/imagegen/home-scroll-propuesta-v3-2026-10-25/01-inicio.png) | Distribución de animales y espacio para texto/acciones del banner Reportar. No es una textura para recortar y usar en la app. |
| [Mockup aprobado: al deslizar](../output/imagegen/home-scroll-propuesta-v3-2026-10-25/02-al-deslizar.png) | Escena de regreso a casa, acceso por foto y fondo de Explorar; también composición y relación entre elementos. |
| [Base Reportar antes de estilizar](../output/imagegen/home-referencias-2026-10-26/base-reportar-antes-de-estilizar.png) | Objetivo de edición del prompt final: habitación, manta, luz, encuadre y espacio izquierdo. Sus mascotas se corrigieron; no usar esta base como patrón final de personajes. |
| [Base Hallazgo antes de estilizar](../output/imagegen/home-referencias-2026-10-26/base-hallazgo-antes-de-estilizar.png) | Objetivo de edición del prompt final: puerta, ángulo, luz, sombra y alfa. El perro inicial fue rechazado por realista. |
| [Tarjeta de monedas](../output/imagegen/home-referencias-2026-10-26/referencia-composicion-moneda.png) | Referencia aportada por el usuario para posición/tamaño: imagen arriba, mensaje debajo y botón ancho al pie. No aporta colores, monedas, tipografía ni estilo de mascotas. |
| [only-black.svg](../apps/mobile/assets/branding/only-black.svg) | Símbolo oficial vectorial superpuesto por Flutter en Explorar. No se pidió a imagegen que lo recreara dentro del mapa. |

Antecedente de las ilustraciones web:
[LANDING_ASSETS.md](../apps/platform/LANDING_ASSETS.md). Conserva decisiones y
prompts de aquella entrega; para el Home actual se aplicó la corrección del26/10.
Los pañuelos de distintos colores de la landing no sustituyen automáticamente
los negros de estos banners.

Las skills consultadas fueron imagegen, para generación/edición y validación,
y apple-design, para jerarquía, agrupación y materiales de la interfaz. El estilo
de los animales procede de los archivos de Platform; no de una regla de Apple.

## 3. Dirección de las mascotas

| Conservar | Evitar |
| --- | --- |
| Personajes de animación 3D, suaves, amables y expresivos. | Aspecto de fotografía de un animal real. |
| Cabezas grandes respecto de cuerpos compactos; patas redondeadas. | Anatomía adulta, cuerpos largos o patas demasiado finas. |
| Ojos grandes y brillantes, iris claros, esclerótica visible y mirada cálida. | Mirada realista pequeña, ojos inquietantes o exageración que cambie la identidad. |
| Hocicos cortos, mejillas redondeadas y nariz pequeña/suave. | Hocicos largos y detalle fotográfico de piel/poros. |
| Pelaje de aspecto suave, con mechones redondeados y detalle contenido. | Pelo largo hiperrealista, hebras ásperas y detalle que domine la cara. |
| Volumen e iluminación coherentes con el escenario. | Acabado plástico, goma brillante o conversión a ilustración plana. |
| Especie, pelaje, postura e identidad de la escena pedida. | Copiar la raza o accesorios de una imagen que solo era referencia de estilo. |

En el prompt del perro de la puerta se pidió una cabeza de aproximadamente45%
de la altura de pie para acentuar la estilización. Fue una orientación de esa
edición, no una proporción obligatoria para todos los animales.

Para los assets actuales:

- Reportar: pastor alemán dorado/negro y gato crema/marrón de ojos azules.
- Hallazgo: cachorro crema/caramelo de orejas caídas, junto a puerta azul.
- Pañuelos/elemento de cuello negros con emblema blanco de huella/localización.
  Conservarlos en variantes de estas escenas; no copiar el verde o azul de los
  archivos de estilo por accidente.
- Emblemas integrados en el pañuelo siguen su tela y perspectiva. El logo oficial
  de cabecera se consume desde el recurso existente, fuera de imagegen.
- Variar animales o accesorios para otra escena requiere definirlos en el encargo;
  no introducirlos por iniciativa del prompt.

## 4. Escenarios, color y composición

La habitación, manta, ventana/planta desenfocadas y luz de Reportar se aprobaron.
También la puerta azul abierta, su orientación, luz interior y sombra de Hallazgo.
Al corregir el personaje, pedir que esos elementos permanezcan como están.

El entorno puede conservar detalle y profundidad mientras las mascotas se
estilizan. Cambiar solo el sujeto no exige volver caricatura todo el escenario.

| Asset | Encuadre y reserva para la interfaz |
| --- | --- |
| Reportar | Pareja a la derecha y zona izquierda tranquila, aproximadamente40%, para texto y enlace. Parte inferior izquierda apta para un botón nativo. Cabezas/orejas/patas dentro del encuadre. |
| Hallazgo | Perro de cuerpo entero a la izquierda de la puerta; conjunto centrado, con margen para cola, orejas y marco. El mensaje y botón se componen debajo en la interfaz. |
| Buscar con una foto | Dos copias ilustrativas de papel blanco, superpuestas y algo giradas; conjunto aislado. El texto y la flecha se añaden fuera de la imagen. |
| Explorar | Calles grises muy claras, parques suaves y río azul pálido, con mayor detalle a la derecha y zona izquierda despejada. Sin etiquetas, marcadores o datos reales. |

Paleta del entorno: blanco/crema y azul pálido, luz suave, sombras discretas.
Azules de la identidad: #459FF6 y #75C9EF; gris de texto: #454746, aplicado
por la interfaz. Los colores cálidos del pelaje y elementos ambientales suaves
no implican cambiar la paleta de marca.

Las referencias de tarjetas o banners aportan composición; no autorizan copiar
su marca, monedas, paleta comercial, botones o textos.

## 5. Imágenes de producción y transparencia

Generar ilustraciones separadas de la interfaz:

- Sin etiquetas, encabezados, botones, flechas, navegación, marcos de pantalla
  o esquinas redondeadas ya dibujadas.
- Textos, superficies, radios, acciones y símbolos de navegación se implementan
  con Flutter o Vue/CSS/SVG según el destino.
- Marco blanco de las fotos y puerta/pañuelo pertenecen a la ilustración.
  No confundir esos objetos con un marco de UI.
- Fondo transparente real en puerta/perro y conjunto de fotos. El fondo de la
  habitación de Reportar y el mapa ilustrativo son opacos.
- No simular alfa con blanco, negro o un tablero de ajedrez pintado. Revisar el
  canal alfa y su apariencia sobre fondo claro, azul y oscuro.
- Si el asset contiene un marcador oficial separado, usar el vector existente
  en la interfaz en lugar de regenerar el emblema como parte del fondo.

Las fotos del acceso son ilustraciones de ejemplo: no casos, resultados
confirmados ni evidencia de coincidencia. El mapa del banner es decorativo;
los mapas funcionales siguen [ADR-104](decisiones/104-cartografia-global-mobile-web.md)
y sus adaptadores compartidos.

## 6. Herramienta y llamadas realmente utilizadas

Se utilizó **imagegen integrado**, una llamada por asset, sin CLI/API ni clave
aportada por el usuario. Se adjuntaron archivos locales con un papel explícito.
No se fijó un modelo, semilla o parámetro de calidad del generador. No inventar
esos datos al documentar la reproducción.

| Prompt final | Referencias adjuntadas, en este orden | transparent_background |
| --- | --- | --- |
| Corrección Reportar | Base Reportar antes de estilizar → hero-dog.png → hero-cat.png | false |
| Corrección Hallazgo | Base Hallazgo antes de estilizar → dog-report.png → mockup aprobado al deslizar | true |
| Buscar con una foto | Mockup aprobado al deslizar → dog-report.png | true |
| Explorar | Mockup aprobado al deslizar | false |

Los prompts completos, conservados literalmente, están en el README de producción:

- [Reportar: perro y gato](../apps/mobile/assets/illustrations/home/README.md#reportar-perro-y-gato).
- [Hallazgo: perro y puerta](../apps/mobile/assets/illustrations/home/README.md#hallazgo-perro-y-puerta).
- [Buscar con una foto](../apps/mobile/assets/illustrations/home/README.md#buscar-con-una-foto).
- [Explorar: fondo ilustrativo](../apps/mobile/assets/illustrations/home/README.md#explorar-fondo-ilustrativo).

La [propuesta aprobada y sus prompts de UI](../output/imagegen/home-scroll-propuesta-v3-2026-10-25/propuesta-y-prompts.md)
documenta la fase previa. Un prompt de mockup genera una referencia de pantalla;
un prompt de producción genera solo el recurso que se integra en esa pantalla.

## 7. Bloques reutilizables de prompt

Los siguientes son plantillas para **nuevas** generaciones, no transcripciones de
las llamadas anteriores. Sustituir las partes entre corchetes y adjuntar realmente
las imágenes que el texto identifica.

### Nueva ilustración de la misma familia

~~~text
Use case: illustration-story.
Asset: one independent production illustration for Entre Huellas, not a UI mockup.

References:
Image 1: approved Entre Huellas character identity and style.
Image 2: approved scene/composition reference, if present.

Subject and action: [animal identity, coat colors, pose and requested action].
Style: premium soft dimensional animated mascots matching Image 1.
Large rounded heads, compact bodies, oversized soft paws, very large warm
glossy eyes with clear sclera, short rounded muzzles and soft rounded fur tufts.
Friendly and approachable for people of all ages. Not realistic pet photography,
not plastic figures and not flat vector art.

Scene: [approved environment, lighting and elements to preserve].
Composition: [aspect ratio, framing, safe margins and clear area for native text].
Background: [genuine transparent alpha OR complete approved opaque scenery].
Keep: [coat, wardrobe, official bandana emblem, scene and identity invariants].

No text, headings, buttons, arrows, navigation, UI cards, watermark or extra props.
Generate only the artwork. Preserve complete ears, paws, tails and requested objects.
~~~

### Corrección solo de mascotas, conservando el escenario

~~~text
Use case: style-transfer / precise character edit.
Image 1: edit target. Images 2 and 3: approved Entre Huellas character references.

Change ONLY [the animal / the two animals] to match the character proportions
and soft animated mascot style of the references.
Preserve the scenery, lighting, background, props, camera angle, framing and
clear areas for native UI as closely as possible.
Keep the original animal identity, coat colors, pose and [wardrobe/emblem].

Use larger rounded heads and glossy expressive eyes, short rounded muzzles,
compact bodies, plush paws and softer simplified fur.
Remove realistic adult anatomy and excessive photographic hair detail.
Do not transfer the reference's unrelated coat, props or bandana color.

No added objects, text or UI. Preserve existing transparency when present.
~~~

Al reutilizar: describir medidas y composición necesarias para esa escena,
sin convertir todos los valores del Home en reglas universales. Nombrar
“3D bonito” o “estilo Apple” por sí solo no define esta familia de personajes.

## 8. Adaptación a web y móvil

Reutilizar los personajes y el acabado, adaptando la geometría al componente:

- Si la misma imagen funciona, consumir el asset existente. Mantener relación
  de aspecto y punto focal; no estirar las mascotas.
- Para un banner de escritorio más ancho, pedir más escenario/espacio negativo,
  conservando personajes y luz. Revisar por separado la versión estrecha.
- Para fondos variables, preferir una ilustración con alfa y componer la
  superficie con código. Para una escena ya aprobada, conservarla como objetivo
  de edición si necesita extenderse.
- Dimensionar según el ancho visible y densidad prevista, con un límite de
  exportación razonable. No ampliar un PNG pequeño y presentarlo como detalle nuevo.
- Reservar el área de texto desde el prompt. Comprobar después el recorte con
  textos reales y ampliados: el texto no debe tapar ojos/hocicos ni la acción.
- Leer [REGLAS_UI_UX_WEB](REGLAS_UI_UX_WEB.md) antes de integrar en Platform.
  Esta guía permite preparar imágenes coherentes; no implica migrar el Home
  móvil a web ni sustituir sus componentes o contratos de movimiento.

## 9. Exportación y tamaños de la entrega de referencia

Se conservaron como recursos de producción los WebP siguientes:

| Archivo final | Dimensiones reales | Alfa | Tamaño |
| --- | --- | --- | --- |
| [report-reunion.webp](../apps/mobile/assets/illustrations/home/report-reunion.webp) | 1024×1024 | No | 106014 bytes |
| [found-home.webp](../apps/mobile/assets/illustrations/home/found-home.webp) | 1024×683 | Sí | 131478 bytes |
| [photo-search.webp](../apps/mobile/assets/illustrations/home/photo-search.webp) | 720×540 | Sí | 71808 bytes |
| [explore-map.webp](../apps/mobile/assets/illustrations/home/explore-map.webp) | 1024×683 | No | 27188 bytes |

Total:336488 bytes. Las dimensiones del prompt eran orientativas; las medidas de
esta tabla son las de los archivos exportados y comprobados.

Conversión realizada con sharp ya instalado en Platform: ancho máximo1024
(pareja, puerta y mapa) o720 (fotos), withoutEnlargement:true, WebP quality:90,
alphaQuality:100, effort:6. Fue conversión/reducción técnica, sin modificar el
estilo de los personajes con código. No añadir una dependencia a móvil por ello.

Guardar variantes con nombres nuevos. Registrar fecha, finalidad, prompt final,
orden/papel de referencias, transparencia solicitada, dimensiones reales,
conversión y lugar de integración. Conservar los assets anteriores cuando
tengan consumidores o sean referencias aprobadas.

La generación es iterativa: mismos prompts y referencias ayudan a mantener
coherencia, pero no garantizan una copia idéntica píxel a píxel.

## 10. Revisión antes de integrar

- Comparar directamente con hero-dog/hero-cat/dog-report de Platform, no solo
  con otra generación nueva. Revisar cara, ojos, hocico, patas y proporciones.
- Confirmar que escenario, encuadre y objetos aprobados siguen conservados.
- Verificar orejas/patas/cola completas y ausencia de texto o controles dibujados.
- Comprobar alfa efectivo, no únicamente la existencia del canal; en puerta/fotos
  se verificaron las cuatro esquinas con alfa0 y se inspeccionaron los bordes.
- Revisar que el emblema integrado en tela sea reconocible. Para el logo exacto
  de cabecera o símbolos nativos se mantiene el archivo oficial.
- Revisar en el componente real: pantalla normal/pequeña, recortes responsive,
  texto200%, legibilidad de acciones y espacio de scroll. Imágenes decorativas
  fuera de la lectura accesible; etiquetas/operaciones accesibles en código.
- No confundir una ilustración bonita o un mockup aprobado con interacción,
  accesibilidad, precisión de coincidencias o permisos validados.
- Anotar resultados y revisión pendiente en ESTADO y en la ficha pertinente.

Para el Home del26/10 se validaron fuentes/assets, scroll y navegación en harness;
el detalle de pruebas/build y la revisión Android física pendiente se conservan
en [Inicio](funcionalidades/inicio.md). Esta guía no genera nuevas imágenes,
no altera los assets finales ni sustituye esa revisión.

