# ADR-148: restaurar glass de controles y navegación móvil

Precisión posterior del usuario: el perlado es para CARDS. Actualizar y Mapa
de Explorar también recuperan su material original. GlassSurface vuelve a
polished/ribete por defecto; GlassSurface.card solicita frosted sin ribete
explícitamente en Home, ficha pública, skeleton y ficha inmersiva. Así los
controles y cápsulas existentes no heredan por accidente el material de tarjetas.

Fecha:26 de octubre de2026. Estado: aceptada por instrucción explícita.

## Regla permanente solicitada por el usuario

Criterio precisado: superficies amplias que contienen y agrupan información,
como cards, usan perlado. Piezas pequeñas, botones y cápsulas usan glass normal.
El tamaño orienta, pero la función prevalece: la barra de navegación sigue con
glass normal aunque sea ancha. No hay umbral de píxeles ni cambio de material
por redimensionado o texto ampliado.

El glass gris perla es para tarjetas de contenido; controles y navegación
conservan el glass polished original. Incluye expresamente Volver, Cerrar,
Compartir, Actualizar, Mapa de Explorar y LiquidNavigation. Refinar cards no
autoriza cambiar esos controles. Cualquier excepción exige instrucción explícita
y decisión documentada; excepciones sólidas existentes se conservan.

Ambos materiales comparten blur22. El original es más transparente, con
degradado blanco neutro, ribete direccional doble y sombras más marcadas.
El de tarjetas suma capas gris perla y luz radial celeste, resulta más cubriente,
no dibuja ribete blanco y utiliza sombra suave. El efecto perlado proviene de
esas capas de color/luz, no de aumentar el blur.

El usuario excluye del material perlado de ADR-145 los botones superiores
Volver/Cerrar/Compartir y la barra de navegación. Solicita recuperar su diseño
anterior, conservando el nuevo material en las tarjetas.

GlassNavigationButton vuelve a polished por defecto y activa su ribete original
para ese acabado. LiquidNavigation solicita polished y showRim=true explícitos.
Se reutilizan los degradados, blur, sombras y doble ribete originales de core;
sin reconstruir el material ni cambiar dimensiones, iconos o interacción.

GlassSurface mantiene frosted/sin ribete por defecto para las tarjetas perladas.
La excepción sólida de contacto de ADR-146 se conserva. Sin cambios web, datos,
permisos, assets, rutas, animaciones ni alcance funcional.

Validar navegación/retorno, controles de ficha pública y capturas normales,
pequeñas/texto200% y reducido; análisis/formato. Resultados en ESTADO.
