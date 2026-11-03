# ADR-145: glass perlado compartido en móvil

Precisión posterior: [ADR-148](148-restaurar-glass-controles-y-navegacion-mobile.md)
excluye botones superiores y barra de navegación, que recuperan polished/ribete
originales. La excepción sólida de contacto está registrada en ADR-146.

Fecha:26 de octubre de2026. Estado: aceptada por instrucción explícita.

## Decisión

El usuario precisa que el acabado del Home debe afectar a todos los lugares
que utilizan ese estilo glass, incluida la ficha pública. Sustituye el alcance
local de ADR-144 y las reservas históricas de acabado previo/ribete blanco en
las superficies móviles que consumen GlassSurface.

GlassSurface concentra el material gris perla, iluminación blanca difusa y
reflejo radial celeste previamente locales a HomeBannerSurface. El acabado
predeterminado pasa a frosted y el trazo de borde se desactiva por defecto.
GlassNavigationButton adopta el mismo acabado. Se conserva la API polished
para compatibilidad, pero ningún consumidor de producción la solicita.

HomeBannerSurface retira las capas de material locales para evitar duplicación;
conserva su radio, Material para interacción y BlendMode.src bajo el stagger.
El color representativo del origen pasa a GlassSurface.originColor. El arte
opaco del Home mantiene su iluminación específica sin alterar los assets.

El cambio alcanza tarjetas de ficha pública, contacto y controles, navegación
inferior, volver/cerrar/compartir, Explorar, ficha inmersiva conservada,
skeleton y retorno de refresh que ya usaban GlassSurface. Conserva geometría,
semántica, estados, permisos, datos, acciones, blur y contratos de movimiento.
Paneles blancos de Compartir y otros materiales independientes conservan su
contrato; no son consumidores del estilo glass modificado. Web no intervenida.

## Validación

Ejecutar pruebas existentes de ficha pública, contacto, ficha inmersiva, Home,
refresh, arquitectura y capturas; inspeccionar normales y texto200% con movimiento
normal/reducido. Análisis de componentes compartidos y consumidores. Resultados
en ESTADO; Android físico/rendimiento y aceptación visual pendientes.
