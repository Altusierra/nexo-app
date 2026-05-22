-- ============================================================================
-- 003_add_archivado_to_productos.sql
-- Fecha: 2026-05-22
-- Descripcion: Soft delete en productos. Permite "archivar" sin perder
--              historial. Todos los queries de productos deben filtrar
--              archivado=false.
-- ============================================================================

-- UP
ALTER TABLE productos ADD COLUMN IF NOT EXISTS archivado boolean NOT NULL DEFAULT false;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS archivado_at timestamptz;

-- Verificacion
-- SELECT id, nombre, archivado, archivado_at FROM productos;

-- DOWN
-- ALTER TABLE productos DROP COLUMN archivado_at;
-- ALTER TABLE productos DROP COLUMN archivado;
