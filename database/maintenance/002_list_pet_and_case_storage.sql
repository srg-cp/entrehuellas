-- SOLO LECTURA. Ejecutar como postgres/propietario antes o después de 001.
-- Inventario de fotos de mascotas/casos, incluidas subidas pendientes/huérfanas.
-- Para liberar los archivos físicos, vaciar ESTOS CINCO buckets mediante
-- Supabase Storage (Dashboard/API), conservando los buckets y sus políticas.
-- No borrar filas de storage.objects por SQL: no elimina los archivos físicos.
-- profile-avatars y cualquier otro bucket quedan fuera de este inventario.

select bucket_id, count(*) as object_count
from storage.objects
where bucket_id in (
    'pet-photos',
    'pet-photo-renditions',
    'pet-photo-thumbnails',
    'found-photo-renditions',
    'found-photo-thumbnails'
)
group by bucket_id
order by bucket_id;

select bucket_id, name
from storage.objects
where bucket_id in (
    'pet-photos',
    'pet-photo-renditions',
    'pet-photo-thumbnails',
    'found-photo-renditions',
    'found-photo-thumbnails'
)
order by bucket_id, name;
