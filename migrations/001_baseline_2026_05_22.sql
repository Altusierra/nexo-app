-- ============================================================================
-- 001_baseline_2026_05_22.sql
-- Fecha: 2026-05-22
-- Descripcion: Baseline del esquema. No corre SQL; documenta el punto de
--              partida del cual arrancan las migraciones versionadas.
-- ============================================================================

-- ESTADO INICIAL:
-- - Esquema de produccion de Nexo en Supabase
-- - 28 tablas en schema public
-- - Backup completo con pg_dump:
--   ~/Desktop/nexo_backup_2026_05_22.sql (6.8 MB)
--   Tambien en Google Drive > Nexo Backups
--
-- BACKUP AUTOMATICO:
-- - Script: ~/scripts/nexo_backup.sh
-- - Programado via launchd: cada lunes 9am
-- - Destino: Google Drive > Nexo Backups (rota a los ultimos 8)
--
-- PARA RESTAURAR DESDE BACKUP:
-- 1. Crear proyecto Supabase nuevo (si toca)
-- 2. Obtener connection string
-- 3. Correr: psql "CONNECTION_STRING" < nexo_backup_2026_05_22.sql

-- UP
-- (no-op, este archivo solo documenta)

-- DOWN
-- (no-op)
