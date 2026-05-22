-- ============================================================================
-- 004_add_timestamps_consistentes.sql
-- Fecha: 2026-05-22
-- Descripcion: Agrega created_at y updated_at a todas las tablas del schema
--              public que no los tengan. Crea funcion + trigger que actualiza
--              updated_at automaticamente en cada UPDATE.
-- ============================================================================

-- UP

-- 1. Funcion del trigger (idempotente)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Loop por todas las tablas del schema public
DO $$
DECLARE
  t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now()', t.tablename);
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now()', t.tablename);
    EXECUTE format('DROP TRIGGER IF EXISTS set_updated_at_%I ON public.%I', t.tablename, t.tablename);
    EXECUTE format('CREATE TRIGGER set_updated_at_%I BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION set_updated_at()', t.tablename, t.tablename);
  END LOOP;
END $$;

-- Verificacion
-- SELECT t.tablename,
--   EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=t.tablename AND column_name='created_at') as has_created,
--   EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=t.tablename AND column_name='updated_at') as has_updated
-- FROM pg_tables t WHERE schemaname='public' ORDER BY tablename;

-- DOWN
-- No es recomendado revertir esta migracion porque puede afectar tablas que
-- ya tenian created_at/updated_at antes. Si necesitas revertir tabla por tabla:
-- ALTER TABLE <tabla> DROP COLUMN updated_at;
-- ALTER TABLE <tabla> DROP COLUMN created_at;
-- DROP TRIGGER set_updated_at_<tabla> ON <tabla>;
-- DROP FUNCTION set_updated_at();
