-- LIMPIEZA GLOBAL E IRREVERSIBLE AL CONFIRMAR COMMIT.
-- Ejecutar este archivo completo en el SQL Editor como postgres/propietario.
-- Borra mascotas y TODOS los estados de casos de TODAS las cuentas.
-- Conserva usuarios, perfiles, roles, bloqueos, zonas, preferencias y dispositivos.
-- Detener escrituras de clientes/procesadores durante la limpieza.
-- No ejecutar como migración ni incorporar a run_all.sql.
-- Las fotos físicas NO se borran aquí: ver 002_list_pet_and_case_storage.sql.

begin;
set local lock_timeout = '5s';
set local statement_timeout = '60s';

do $clear$
declare
    -- Lista explícita: incluye referencias lógicas que no tienen foreign key.
    v_targets constant text[] := array[
        'pets', 'pet_photos', 'pet_deletions', 'pet_photo_deletions',
        'lost_cases', 'case_events',
        'found_cases', 'found_case_photos', 'found_case_events',
        'saved_cases', 'case_public_links', 'case_contacts', 'case_closures',
        'public_sightings', 'sighting_reviews', -- Compatibilidad anterior a patch042.
        'notifications', 'notification_deliveries',
        'content_reports', 'content_visibility', 'content_report_resolutions',
        'content_moderation_decisions', 'content_moderation_access',
        'moderation_appeals', 'moderation_appeal_answers', 'moderation_appeal_access',
        'case_match_embeddings', 'case_match_reviews'
    ];
    v_tables text[] := array[]::text[];
    v_name text;
    v_count bigint;
begin
    if to_regclass('public.pets') is null
       or to_regclass('public.lost_cases') is null
       or to_regclass('public.found_cases') is null then
        raise exception 'Faltan pets/lost_cases/found_cases: revisar la base y sus incrementos.';
    end if;

    foreach v_name in array v_targets loop
        if to_regclass(format('public.%I', v_name)) is not null then
            v_tables := array_append(v_tables, format('public.%I', v_name));
        else
            raise notice 'Tabla no instalada; se omite: public.%', v_name;
        end if;
    end loop;

    -- Bloqueo antes de contar/borrar; no se deshabilitan triggers ni RLS.
    execute 'lock table ' || array_to_string(v_tables, ', ') || ' in access exclusive mode';
    foreach v_name in array v_tables loop
        execute 'select count(*) from ' || v_name into v_count;
        raise notice '%: % filas a eliminar', v_name, v_count;
    end loop;

    -- Estas tablas mezclan seguimientos de casos con seguimientos de zonas.
    -- Conservar las zonas y sus recibos de comandos.
    if to_regclass('public.alert_subscription_commands') is not null then
        delete from public.alert_subscription_commands where target_kind in ('lost', 'found');
        get diagnostics v_count = row_count;
        raise notice 'alert_subscription_commands: % comandos de casos eliminados', v_count;
    end if;
    if to_regclass('public.alert_subscriptions') is not null then
        delete from public.alert_subscriptions where target_kind in ('lost', 'found');
        get diagnostics v_count = row_count;
        raise notice 'alert_subscriptions: % seguimientos de casos eliminados', v_count;
    end if;

    -- RESTRICT impide arrastrar tablas nuevas/ajenas por una FK inesperada.
    -- RESTART IDENTITY reinicia a 1 las secuencias propias actuales; los UUID
    -- de mascotas/casos no son incrementales y no tienen contador que reiniciar.
    -- TRUNCATE no dispara los guards DELETE de conservación de historial.
    execute 'truncate table ' || array_to_string(v_tables, ', ') || ' restart identity restrict';

    foreach v_name in array v_tables loop
        execute 'select count(*) from ' || v_name into v_count;
        if v_count <> 0 then
            raise exception 'La tabla % no quedó vacía; se revierte la limpieza.', v_name;
        end if;
    end loop;
    raise notice 'Limpieza completada: % tablas vacías. Cuentas y configuración conservadas.', cardinality(v_tables);
end
$clear$;

commit;
