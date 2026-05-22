-- ============================================================================
-- 005_verify_producto_id_in_reportes_diarios.sql
-- Fecha: 2026-05-22
-- Descripcion: Verificacion (no-op). La columna producto_id ya existia en
--              reportes_diarios con FK hacia productos(id) y todos los
--              registros existentes la tenian llena (9/9). No requirio cambios.
-- ============================================================================

-- UP

-- Si por algun motivo la columna no existiera, este SQL la crearia y rellenaria.
-- (Idempotente: no hace nada si ya esta.)

ALTER TABLE reportes_diarios
  ADD COLUMN IF NOT EXISTS producto_id UUID REFERENCES productos(id);

-- Backfill por nombre canonico
UPDATE reportes_diarios r
SET producto_id = p.id
FROM productos p
WHERE LOWER(TRIM(r.producto_nombre)) = LOWER(TRIM(p.nombre))
  AND r.producto_id IS NULL;

-- Backfill por aliases
UPDATE reportes_diarios r
SET producto_id = p.id
FROM productos p, LATERAL unnest(p.aliases) AS alias
WHERE LOWER(TRIM(r.producto_nombre)) = LOWER(TRIM(alias))
  AND r.producto_id IS NULL;

-- Verificacion
-- SELECT COUNT(*) total, COUNT(producto_id) con_producto_id,
--   COUNT(*)-COUNT(producto_id) sin_producto_id FROM reportes_diarios;

-- DOWN
-- ALTER TABLE reportes_diarios DROP COLUMN producto_id;
