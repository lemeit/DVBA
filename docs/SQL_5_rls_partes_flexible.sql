-- SQL 5 · Relajar RLS de partes_diarios + parte_maquinarias + parte_fotos
-- v7.68 · Fix bug: "new row violates row-level security policy for table partes_diarios"
--
-- CAUSA: la policy INSERT original (SQL_partes_diarios.sql línea 279-281) exige
--   WITH CHECK (auth.uid() = responsable_id)
-- pero la app no envía responsable_id → fail 42501.
-- Además los 632 partes históricos migrados por bulk no tienen responsable_id,
-- así que la policy UPDATE con esa misma condición los vuelve ineditables.
--
-- DECISIÓN: uso interno DVBA (~5 usuarios de misma zona). Todos los authenticated
-- pueden CRUD. La columna responsable_id igual se llena desde la app (auditoría),
-- pero no la usamos como gate de seguridad.

BEGIN;

-- ═══════════════════════════════════════════════════════════════════
-- partes_diarios
-- ═══════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS partes_read_auth   ON partes_diarios;
DROP POLICY IF EXISTS partes_insert_auth ON partes_diarios;
DROP POLICY IF EXISTS partes_update_own  ON partes_diarios;
DROP POLICY IF EXISTS partes_delete_auth ON partes_diarios;

CREATE POLICY partes_read_auth ON partes_diarios
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY partes_insert_auth ON partes_diarios
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY partes_update_auth ON partes_diarios
  FOR UPDATE USING (auth.role() = 'authenticated')
             WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY partes_delete_auth ON partes_diarios
  FOR DELETE USING (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════════════
-- parte_maquinarias
-- ═══════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS parte_maq_read_auth   ON parte_maquinarias;
DROP POLICY IF EXISTS parte_maq_insert_auth ON parte_maquinarias;
DROP POLICY IF EXISTS parte_maq_del_own     ON parte_maquinarias;
DROP POLICY IF EXISTS parte_maq_upd_auth    ON parte_maquinarias;

CREATE POLICY parte_maq_read_auth ON parte_maquinarias
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY parte_maq_insert_auth ON parte_maquinarias
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY parte_maq_upd_auth ON parte_maquinarias
  FOR UPDATE USING (auth.role() = 'authenticated')
             WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY parte_maq_del_auth ON parte_maquinarias
  FOR DELETE USING (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════════════
-- parte_fotos (creada en SQL 3, ya tenía policies auth — dejo por si acaso)
-- ═══════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS parte_fotos_read_auth  ON parte_fotos;
DROP POLICY IF EXISTS parte_fotos_write_auth ON parte_fotos;

CREATE POLICY parte_fotos_read_auth ON parte_fotos
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY parte_fotos_write_auth ON parte_fotos
  FOR ALL USING (auth.role() = 'authenticated')
          WITH CHECK (auth.role() = 'authenticated');

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- Verificar policies activas
-- ═══════════════════════════════════════════════════════════════════

SELECT tablename, policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename IN ('partes_diarios','parte_maquinarias','parte_fotos')
ORDER BY tablename, cmd;
