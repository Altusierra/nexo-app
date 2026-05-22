-- ============================================================================
-- 002_add_producto_id_to_mapeos.sql
-- Fecha: 2026-05 (previo a esta sesion - documentada retroactivamente)
-- Descripcion: Agrega producto_id (UUID) a mapeos como ancla inmutable
--              hacia productos. Permite renombrar productos sin perder
--              referencias en ordenes historicas.
-- ============================================================================

-- UP
ALTER TABLE mapeos ADD COLUMN IF NOT EXISTS producto_id UUID REFERENCES productos(id);

-- Backfill: matchear por nombre canonico
UPDATE mapeos m
SET producto_id = p.id
FROM productos p
WHERE LOWER(TRIM(m.producto)) = LOWER(TRIM(p.nombre))
  AND m.producto_id IS NULL;

-- Backfill: matchear por aliases
UPDATE mapeos m
SET producto_id = p.id
FROM productos p, LATERAL unnest(p.aliases) AS alias
WHERE LOWER(TRIM(m.producto)) = LOWER(TRIM(alias))
  AND m.producto_id IS NULL;

-- Verificacion
-- SELECT producto, COUNT(*) FROM mapeos WHERE producto_id IS NULL GROUP BY producto;

-- DOWN
-- ALTER TABLE mapeos DROP COLUMN producto_id;
