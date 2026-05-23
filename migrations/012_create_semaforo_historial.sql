-- 012_create_semaforo_historial.sql
-- Fecha: 2026-05-23
-- Descripción: Crea tabla semaforo_historial para Entrega 3B (histórico de semáforos).
--              Cada vez que el auxiliar actualiza ventas (asignador, cruce dropi,
--              seguimiento, reporte del día, reservados) se recalcula el semáforo
--              de las campañas/adsets/ads afectados y se guarda un registro aquí.
--
-- Indexada por: meta_id, fecha, account_id, hora_calculo.
-- RLS: SELECT abierto, INSERT requiere sesión, DELETE solo admin.

-- ─────────────────────────────────────────────────────────────────────
-- UP
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE semaforo_historial (
  id bigserial PRIMARY KEY,
  meta_id text NOT NULL,
  nivel text NOT NULL,                  -- 'campaign' | 'adset' | 'ad'
  account_id text,
  fecha date NOT NULL,
  hora_calculo timestamptz NOT NULL DEFAULT now(),

  semaforo text NOT NULL,               -- 'sin_ventas'|'stop'|'precaucion'|'escalar'|'fuego'
  semaforo_label text,                  -- '⏳ Sin ventas' | '🔴 STOP' | etc

  cpa_real numeric DEFAULT 0,
  ventas integer DEFAULT 0,
  canceladas integer DEFAULT 0,
  pendientes integer DEFAULT 0,
  gasto numeric DEFAULT 0,
  conv_meta integer DEFAULT 0,

  margenBE_referencia numeric,
  producto_referencia text,

  triggered_by text,                    -- 'asignador'|'cruce_dropi'|'seguimiento'|
                                        --  'reporte_dia'|'reservados'|'manual'|
                                        --  'render_portafolio'

  cambio_vs_anterior boolean DEFAULT false,
  semaforo_anterior text,

  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_sem_meta_fecha  ON semaforo_historial(meta_id, fecha DESC);
CREATE INDEX idx_sem_fecha       ON semaforo_historial(fecha DESC);
CREATE INDEX idx_sem_cuenta      ON semaforo_historial(account_id, fecha DESC);
CREATE INDEX idx_sem_hora        ON semaforo_historial(hora_calculo DESC);

ALTER TABLE semaforo_historial ENABLE ROW LEVEL SECURITY;

CREATE POLICY sem_select ON semaforo_historial
  FOR SELECT USING (true);

CREATE POLICY sem_insert ON semaforo_historial
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY sem_delete_admin ON semaforo_historial
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM usuarios WHERE id = auth.uid() AND rol = 'admin')
  );

-- ─────────────────────────────────────────────────────────────────────
-- DOWN (si necesitas revertir)
-- ─────────────────────────────────────────────────────────────────────

-- DROP POLICY IF EXISTS sem_delete_admin ON semaforo_historial;
-- DROP POLICY IF EXISTS sem_insert       ON semaforo_historial;
-- DROP POLICY IF EXISTS sem_select       ON semaforo_historial;
-- DROP INDEX IF EXISTS idx_sem_hora;
-- DROP INDEX IF EXISTS idx_sem_cuenta;
-- DROP INDEX IF EXISTS idx_sem_fecha;
-- DROP INDEX IF EXISTS idx_sem_meta_fecha;
-- DROP TABLE IF EXISTS semaforo_historial;

-- ─────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN POST-MIGRATION
-- ─────────────────────────────────────────────────────────────────────

-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'semaforo_historial'
-- ORDER BY ordinal_position;

-- SELECT indexname FROM pg_indexes WHERE tablename = 'semaforo_historial';

-- SELECT policyname FROM pg_policies WHERE tablename = 'semaforo_historial';
