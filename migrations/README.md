# Nexo — Migrations

Historial completo de cambios al esquema de base de datos.

## Convención

- Archivos numerados secuenciales: `NNN_descripcion_corta.sql`
- Cada archivo tiene un bloque **UP** (cambios a aplicar) y un bloque **DOWN** (cómo revertir).
- Las migraciones se corren en orden, una sola vez cada una.
- Las migraciones ya aplicadas a la BD de producción están documentadas retroactivamente.

## Cómo aplicar una migración nueva

1. Hacer backup antes (`~/scripts/nexo_backup.sh`)
2. Copiar el contenido del bloque UP del archivo `.sql`
3. Pegar en Supabase → SQL Editor
4. Ejecutar
5. Verificar con las queries de verificación del archivo

## Cómo revertir una migración

1. Identificar el archivo
2. Copiar el contenido del bloque DOWN
3. Pegar en Supabase → SQL Editor
4. Ejecutar

⚠️ Algunas migraciones (como las que insertan datos de backfill) no se pueden revertir limpiamente. Si necesitas restaurar, usa el último backup de pg_dump.

## Historial de migraciones

| # | Fecha | Descripción |
|---|---|---|
| 001 | 2026-05-22 | Baseline (referencia al backup pg_dump) |
| 002 | 2026-05 (previo) | Agregar `producto_id` a `mapeos` |
| 003 | 2026-05-22 | Soft delete en `productos` (`archivado`) |
| 004 | 2026-05-22 | Timestamps consistentes (`created_at`/`updated_at`) en todas las tablas |
| 005 | 2026-05-22 | Verificación: `producto_id` en `reportes_diarios` (ya existía) |
| 006 | 2026-05-22 | Snapshots de precio en `mapeos` |
| 007 | 2026-05-22 | Tabla `producto_precios_historial` |
| 008 | 2026-05-22 | Tabla `mapeo_eventos` (event sourcing) |
