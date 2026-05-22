-- 009_fix_permisos_tablas_sin_grants.sql
-- Fecha: 2026-05-22
-- Descripción: Fix de permisos en 7 tablas que fueron creadas vía SQL Editor
-- sin GRANTs a authenticated, causando 403 al INSERT/UPDATE desde la app.
-- Aplica el mismo patrón de producto_ofertas (SELECT abierto, INSERT/UPDATE/DELETE admin).
-- Bug latente descubierto al testear Fase 2.2: los historial inserts fallaban silenciosamente.

-- UP

-- ============================================================
-- 1. producto_precios_historial (Fase 2.2)
-- ============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON producto_precios_historial TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON producto_precios_historial TO service_role;
ALTER TABLE producto_precios_historial ENABLE ROW LEVEL SECURITY;

CREATE POLICY producto_precios_historial_select ON producto_precios_historial FOR SELECT USING (true);
CREATE POLICY producto_precios_historial_insert_admin ON producto_precios_historial FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY producto_precios_historial_update_admin ON producto_precios_historial FOR UPDATE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY producto_precios_historial_delete_admin ON producto_precios_historial FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));

-- ============================================================
-- 2. mapeo_eventos (Fase 3)
-- ============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON mapeo_eventos TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON mapeo_eventos TO service_role;
ALTER TABLE mapeo_eventos ENABLE ROW LEVEL SECURITY;

CREATE POLICY mapeo_eventos_select ON mapeo_eventos FOR SELECT USING (true);
-- INSERT abierto para cualquier autenticado (eventos los crea cualquier rol operacional)
CREATE POLICY mapeo_eventos_insert_auth ON mapeo_eventos FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY mapeo_eventos_update_admin ON mapeo_eventos FOR UPDATE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY mapeo_eventos_delete_admin ON mapeo_eventos FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));

-- ============================================================
-- 3. meta_sync_log
-- ============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON meta_sync_log TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON meta_sync_log TO service_role;

CREATE POLICY meta_sync_log_select ON meta_sync_log FOR SELECT USING (true);
CREATE POLICY meta_sync_log_insert_auth ON meta_sync_log FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================================
-- 4. gasto_ads
-- ============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON gasto_ads TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON gasto_ads TO service_role;

CREATE POLICY gasto_ads_select ON gasto_ads FOR SELECT USING (true);
CREATE POLICY gasto_ads_insert_admin ON gasto_ads FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY gasto_ads_update_admin ON gasto_ads FOR UPDATE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY gasto_ads_delete_admin ON gasto_ads FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));

-- ============================================================
-- 5. maestros (cabecera)
-- ============================================================
GRANT INSERT, UPDATE, DELETE ON maestros TO authenticated;
GRANT INSERT, UPDATE, DELETE ON maestros TO service_role;

CREATE POLICY maestros_insert_admin ON maestros FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY maestros_update_admin ON maestros FOR UPDATE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY maestros_delete_admin ON maestros FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));

-- ============================================================
-- 6. maestro_ciudades
-- ============================================================
GRANT INSERT, UPDATE, DELETE ON maestro_ciudades TO authenticated;
GRANT INSERT, UPDATE, DELETE ON maestro_ciudades TO service_role;

CREATE POLICY maestro_ciudades_insert_admin ON maestro_ciudades FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY maestro_ciudades_update_admin ON maestro_ciudades FOR UPDATE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY maestro_ciudades_delete_admin ON maestro_ciudades FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));

-- ============================================================
-- 7. maestro_keywords
-- ============================================================
GRANT INSERT, UPDATE, DELETE ON maestro_keywords TO authenticated;
GRANT INSERT, UPDATE, DELETE ON maestro_keywords TO service_role;

CREATE POLICY maestro_keywords_insert_admin ON maestro_keywords FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY maestro_keywords_update_admin ON maestro_keywords FOR UPDATE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));
CREATE POLICY maestro_keywords_delete_admin ON maestro_keywords FOR DELETE USING (
  EXISTS (SELECT 1 FROM usuarios WHERE usuarios.id = auth.uid() AND usuarios.rol = 'admin'::text));

-- DOWN (rollback - descomentar si necesitas revertir)
-- DROP POLICY IF EXISTS producto_precios_historial_select ON producto_precios_historial;
-- DROP POLICY IF EXISTS producto_precios_historial_insert_admin ON producto_precios_historial;
-- ...etc para cada policy creada arriba
-- ALTER TABLE producto_precios_historial DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE mapeo_eventos DISABLE ROW LEVEL SECURITY;
-- REVOKE ALL ON producto_precios_historial FROM authenticated;
-- ...etc
