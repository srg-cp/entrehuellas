# ADR-168: retirada completa de avistamientos privados

Fecha: 30/10/2026. El usuario aclara que no existen avistamientos privados
antiguos y pide eliminar el sistema completo, incluido un patch de base de datos.
Sustituye la conservación de compatibilidad privada de ADR-167.

## Decisión

Solo se publican avisos vinculados en found_cases (sighting/with_reporter), con
cuenta, información pública aproximada y notificaciones según preferencias.
Se eliminan módulos, formularios, rutas, providers y adaptadores privados en
Flutter/Nuxt, además de la revisión/clasificación privada. No se elimina el
tipo sighting de los avisos públicos.

Recorrido agrega exclusivamente avisos públicos. Ver seguimiento conserva
el historial de publicación/recuperación, sin revisiones privadas. La cola
solo procesa pérdidas y avisos públicos; SQLite3 elimina slots privados en la
actualización local, sin convertirlos a publicaciones ni afectar otros borradores.

## Base de datos

Plan042/fuente136 elimina public_sightings, sighting_reviews, RPC de envío,
lectura de evidencia/revisión y trigger privado de bloqueos. Antes actualiza
dependencias de historial, moderación, bloqueos, apelaciones y notificaciones.
Estadísticas cuenta avistamientos públicos publicados. Usa DROP sin CASCADE y
comprueba que ninguna función pública conserve consultas a las tablas retiradas.
La transacción aborta si queda alguna dependencia inesperada.

Las migraciones anteriores son historial inmutable. run_all termina aplicando
042; no deja el sistema privado instalado. Sus pruebas históricas declaran
expresamente el esquema anterior a042; las regresiones de retirada prueban
instalación actual, actualización, repetición y operaciones públicas vigentes.

## Activación

Generar con Build-PrivateSightingsRetirementPatch.ps1. Aplicar solo
042_patch_remove_private_sightings.sql después de041 y actualizar servidor/web y
móvil juntos. No ejecutar run_all para actualizar un servidor existente.
No se ha aplicado SQL remoto ni desplegado desde esta tarea. Resultados en ESTADO.
