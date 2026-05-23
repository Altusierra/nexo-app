-- ============================================================================
-- Migration: 011_create_meta_escaladas_y_snapshots
-- Fecha: 2026-05-23
-- Descripción:
--   1. meta_escaladas: registra cambios de presupuesto (subidas y bajadas)
--      detectados automáticamente en el sync de Meta. Aplica a campañas (CBO)
--      y a ad sets (ABO).
--   2. meta_snapshots_horarios: snapshot horario del estado de cada
--      campaña/adset activa, para tener datos "antes del cambio" precisos.
-- ============================================================================

-- ── UP ──────────────────────────────────────────────────────────────────────

-- TABLA 1: meta_escaladas
CREATE TABLE meta_escaladas (
  id bigserial PRIMARY KEY,
  meta_id text NOT NULL,
  nivel text NOT NULL,
  account_id text,
  nombre text,

  budget_anterior numeric,
  budget_nuevo numeric,
  cambio_pct numeric,
  tipo text NOT NULL,
  fecha date NOT NULL,
  hora_cambio timestamptz NOT NULL,
  detectado_por text DEFAULT 'sync_auto',

  ventas_reportadas_al_cambio integer DEFAULT 0,
  gasto_al_cambio numeric DEFAULT 0,
  conv_meta_al_cambio integer DEFAULT 0,

  ventas_reportadas_cierre integer DEFAULT 0,
  gasto_cierre numeric DEFAULT 0,
  conv_meta_cierre integer DEFAULT 0,
  dia_cerrado boolean DEFAULT false,

  ventas_confirmadas_final integer DEFAULT 0,
  confirmacion_lista boolean DEFAULT false,

  veredicto text,
  veredicto_pct numeric,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_escaladas_meta ON meta_escaladas(meta_id, fecha);
CREATE INDEX idx_escaladas_fecha ON meta_escaladas(fecha DESC);
CREATE INDEX idx_escaladas_cuenta ON meta_escaladas(account_id, fecha DESC);
CREATE INDEX idx_escaladas_dia_cerrado ON meta_escaladas(dia_cerrado) WHERE dia_cerrado=false;

CREATE TRIGGER set_updated_at_meta_escaladas
  BEFORE UPDATE ON meta_escaladas
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE meta_escaladas ENABLE ROW LEVEL SECURITY;

CREATE POLICY escaladas_select ON meta_escaladas FOR SELECT USING (true);
CREATE POLICY escaladas_insert ON meta_escaladas FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY escaladas_update ON meta_escaladas FOR UPDATE USING (auth.uid() IS NOT NULL);
CREATE POLICY escaladas_delete_admin ON meta_escaladas FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE id=auth.uid() AND rol='admin')
);

-- TABLA 2: meta_snapshots_horarios
CREATE TABLE meta_snapshots_horarios (
  id bigserial PRIMARY KEY,
  meta_id text NOT NULL,
  nivel text NOT NULL,
  account_id text,

  fecha date NOT NULL,
  hora timestamptz NOT NULL,

  budget_actual numeric,
  gasto_acumulado_dia numeric DEFAULT 0,
  conv_meta_acumulado_dia integer DEFAULT 0,
  ventas_reportadas_dia integer DEFAULT 0,
  ventas_confirmadas_dia integer DEFAULT 0,

  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_snap_meta_hora ON meta_snapshots_horarios(meta_id, hora DESC);
CREATE INDEX idx_snap_fecha ON meta_snapshots_horarios(fecha);

ALTER TABLE meta_snapshots_horarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY snap_select ON meta_snapshots_horarios FOR SELECT USING (true);
CREATE POLICY snap_insert ON meta_snapshots_horarios FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY snap_delete_admin ON meta_snapshots_horarios FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE id=auth.uid() AND rol='admin')
);

-- ── DOWN (cómo revertir) ────────────────────────────────────────────────────
-- DROP TABLE IF EXISTS meta_snapshots_horarios;
-- DROP TABLE IF EXISTS meta_escaladas;

-- ── VERIFICACIÓN ────────────────────────────────────────────────────────────
-- SELECT COUNT(*) FROM meta_escaladas;
-- SELECT COUNT(*) FROM meta_snapshots_horarios;
-- SELECT * FROM meta_escaladas ORDER BY created_at DESC LIMIT 10;
