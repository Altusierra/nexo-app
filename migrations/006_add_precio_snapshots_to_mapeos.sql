-- ============================================================================
-- 006_add_precio_snapshots_to_mapeos.sql
-- Fecha: 2026-05-22
-- Descripcion: Agrega columnas snapshot a mapeos. Captura precio/costo al
--              momento de cada orden para que los reportes historicos no se
--              distorsionen cuando se cambien precios en productos.
--
--              - precio_dropi: precio real desde el XLSX de Dropi (cliente)
--              - costo_snapshot: costo del producto al crear la orden
--              - flete_snapshot: flete outbound al momento
--              - flete_dev_snapshot: flete devolucion al momento
--
--              Para ordenes existentes quedan NULL -> fallback al precio
--              actual del producto en calculos.
-- ============================================================================

-- UP
ALTER TABLE mapeos ADD COLUMN IF NOT EXISTS precio_dropi numeric;
ALTER TABLE mapeos ADD COLUMN IF NOT EXISTS costo_snapshot numeric;
ALTER TABLE mapeos ADD COLUMN IF NOT EXISTS flete_snapshot numeric;
ALTER TABLE mapeos ADD COLUMN IF NOT EXISTS flete_dev_snapshot numeric;

-- Verificacion
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_schema='public' AND table_name='mapeos'
--   AND column_name IN ('precio_dropi','costo_snapshot','flete_snapshot','flete_dev_snapshot')
-- ORDER BY column_name;

-- DOWN
-- ALTER TABLE mapeos DROP COLUMN flete_dev_snapshot;
-- ALTER TABLE mapeos DROP COLUMN flete_snapshot;
-- ALTER TABLE mapeos DROP COLUMN costo_snapshot;
-- ALTER TABLE mapeos DROP COLUMN precio_dropi;
