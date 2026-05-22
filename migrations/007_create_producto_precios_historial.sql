-- ============================================================================
-- 007_create_producto_precios_historial.sql
-- Fecha: 2026-05-22
-- Descripcion: Tabla de historial de precios y costos por oferta. Cuando se
--              cambia un precio en producto_ofertas, en vez de UPDATE directo
--              se debe cerrar el registro vigente (vigente_hasta=now()) y
--              crear uno nuevo.
--
--              Util para ordenes que aun NO pasaron por Dropi (no tienen
--              precio_dropi lleno) -> buscar el precio vigente en la fecha
--              de la orden.
-- ============================================================================

-- UP

CREATE TABLE IF NOT EXISTS producto_precios_historial (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id uuid NOT NULL REFERENCES productos(id),
  oferta_id uuid REFERENCES producto_ofertas(id),
  cantidad int NOT NULL,
  precio bigint NOT NULL,
  costo bigint NOT NULL,
  vigente_desde timestamptz NOT NULL DEFAULT now(),
  vigente_hasta timestamptz,
  motivo text,
  usuario_id uuid REFERENCES usuarios(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_precios_hist_producto_cantidad
  ON producto_precios_historial(producto_id, cantidad, vigente_desde);

CREATE INDEX IF NOT EXISTS idx_precios_hist_vigente
  ON producto_precios_historial(producto_id, cantidad)
  WHERE vigente_hasta IS NULL;

DROP TRIGGER IF EXISTS set_updated_at_producto_precios_historial ON producto_precios_historial;
CREATE TRIGGER set_updated_at_producto_precios_historial
  BEFORE UPDATE ON producto_precios_historial
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Backfill: snapshot inicial con precios actuales de cada oferta activa
INSERT INTO producto_precios_historial
  (producto_id, oferta_id, cantidad, precio, costo, vigente_desde, vigente_hasta)
SELECT
  producto_id,
  id as oferta_id,
  cantidad,
  precio,
  costo,
  COALESCE(created_at, now()) as vigente_desde,
  NULL as vigente_hasta
FROM producto_ofertas
WHERE activo = true
  AND NOT EXISTS (
    SELECT 1 FROM producto_precios_historial pph
    WHERE pph.oferta_id = producto_ofertas.id
  );

-- Verificacion
-- SELECT p.nombre, pph.cantidad, pph.precio, pph.costo, pph.vigente_desde, pph.vigente_hasta
-- FROM producto_precios_historial pph
-- JOIN productos p ON p.id = pph.producto_id
-- ORDER BY p.nombre, pph.cantidad;

-- DOWN
-- DROP TABLE producto_precios_historial;
