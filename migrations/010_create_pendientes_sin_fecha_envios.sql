-- ============================================================================
-- Migration: 008_create_pendientes_sin_fecha_envios
-- Fecha: 2026-05-22
-- Descripción:
--   Nueva tabla para registrar los mensajes enviados a clientes con pedidos
--   en estado pendiente que aún NO tienen fecha de envío programada.
--
--   Esta tabla NO reemplaza confirmacion_envios (esa requiere programacion_id,
--   los pedidos PSF no tienen programación todavía).
--
--   Cuota: 2 mensajes por día por pedido.
--   Niveles: 1-4 (auto-progresivos según envíos previos).
--   Protocolo de 4 mensajes (PSF_MSGS) definido en index.html.
-- ============================================================================

-- ── UP ──────────────────────────────────────────────────────────────────────
CREATE TABLE pendientes_sin_fecha_envios (
  id bigserial PRIMARY KEY,
  mapeo_id uuid REFERENCES mapeos(id) ON DELETE CASCADE,
  telefono text,
  nivel_mensaje smallint NOT NULL,
  usuario_id uuid REFERENCES usuarios(id),
  usuario_nombre text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_psf_envios_mapeo ON pendientes_sin_fecha_envios(mapeo_id);
CREATE INDEX idx_psf_envios_telefono ON pendientes_sin_fecha_envios(telefono);
CREATE INDEX idx_psf_envios_created ON pendientes_sin_fecha_envios(created_at);

-- RLS
ALTER TABLE pendientes_sin_fecha_envios ENABLE ROW LEVEL SECURITY;

CREATE POLICY psf_envios_select ON pendientes_sin_fecha_envios
  FOR SELECT USING (true);

CREATE POLICY psf_envios_insert ON pendientes_sin_fecha_envios
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY psf_envios_delete_admin ON pendientes_sin_fecha_envios
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM usuarios WHERE id=auth.uid() AND rol='admin')
  );

-- ── DOWN (cómo revertir) ────────────────────────────────────────────────────
-- DROP POLICY IF EXISTS psf_envios_delete_admin ON pendientes_sin_fecha_envios;
-- DROP POLICY IF EXISTS psf_envios_insert ON pendientes_sin_fecha_envios;
-- DROP POLICY IF EXISTS psf_envios_select ON pendientes_sin_fecha_envios;
-- DROP INDEX IF EXISTS idx_psf_envios_created;
-- DROP INDEX IF EXISTS idx_psf_envios_telefono;
-- DROP INDEX IF EXISTS idx_psf_envios_mapeo;
-- DROP TABLE IF EXISTS pendientes_sin_fecha_envios;

-- ── VERIFICACIÓN ────────────────────────────────────────────────────────────
-- SELECT COUNT(*) FROM pendientes_sin_fecha_envios;
-- SELECT mapeo_id, COUNT(*) AS envios, MAX(created_at) AS ultimo
-- FROM pendientes_sin_fecha_envios
-- GROUP BY mapeo_id
-- ORDER BY ultimo DESC LIMIT 20;
