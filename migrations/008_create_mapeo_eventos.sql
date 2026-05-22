-- ============================================================================
-- 008_create_mapeo_eventos.sql
-- Fecha: 2026-05-22
-- Descripcion: Tabla mapeo_eventos. Event sourcing de ordenes. Cada cambio
--              de estado se guarda como evento inmutable. mapeos.estado_final
--              sigue siendo "el ultimo estado" (no se rompe nada existente).
--
--              Permite responder:
--              - Cuando paso esta orden de "en transito" a "en bodega"?
--              - Cuantos dias tarda en entregarse?
--              - Cuantas veces estuvo en novedad?
-- ============================================================================

-- UP

CREATE TABLE IF NOT EXISTS mapeo_eventos (
  id bigserial PRIMARY KEY,
  mapeo_id uuid NOT NULL REFERENCES mapeos(id) ON DELETE CASCADE,
  evento varchar NOT NULL,  -- 'creado', 'confirmado', 'enviado', 'en_bodega', 'entregado', 'devuelto', 'novedad', 'novedad_ok', 'cancelado', 'reclame_oficina', ...
  detalle jsonb,            -- info extra: motivo, causal, etc.
  fuente varchar,           -- 'asignador', 'dropi', 'auxiliar_manual', 'novedades_upload', 'reclame_upload', ...
  usuario_id uuid REFERENCES usuarios(id),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mapeo_eventos_mapeo ON mapeo_eventos(mapeo_id, created_at);
CREATE INDEX IF NOT EXISTS idx_mapeo_eventos_evento ON mapeo_eventos(evento);
CREATE INDEX IF NOT EXISTS idx_mapeo_eventos_fuente ON mapeo_eventos(fuente);

-- Backfill 1: evento 'creado' por cada mapeo (sin duplicar)
INSERT INTO mapeo_eventos (mapeo_id, evento, fuente, created_at)
SELECT m.id, 'creado', 'backfill_inicial', COALESCE(m.created_at, NOW())
FROM mapeos m
WHERE NOT EXISTS (
  SELECT 1 FROM mapeo_eventos e
  WHERE e.mapeo_id = m.id AND e.evento = 'creado'
);

-- Backfill 2: evento del estado_final si esta informado
INSERT INTO mapeo_eventos (mapeo_id, evento, fuente, detalle, created_at)
SELECT
  m.id,
  LOWER(REPLACE(TRIM(m.estado_final), ' ', '_')),
  'backfill_inicial',
  jsonb_build_object('estado_final_raw', m.estado_final),
  COALESCE(m.fecha_dropi::timestamptz, m.updated_at, m.created_at, NOW())
FROM mapeos m
WHERE m.estado_final IS NOT NULL
  AND TRIM(m.estado_final) != ''
  AND NOT EXISTS (
    SELECT 1 FROM mapeo_eventos e
    WHERE e.mapeo_id = m.id
      AND e.fuente = 'backfill_inicial'
      AND e.evento = LOWER(REPLACE(TRIM(m.estado_final), ' ', '_'))
  );

-- Verificacion
-- SELECT evento, COUNT(*) FROM mapeo_eventos GROUP BY evento ORDER BY COUNT(*) DESC;

-- DOWN
-- DROP TABLE mapeo_eventos;
