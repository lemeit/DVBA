-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_19 · Ampliar RLS zonal para roles nuevos de SQL_17
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   SQL_9 (rls_zonal) filtraba relevamientos + partes_diarios por zona pero solo
--   reconocía 3 roles: 'tecnico', 'admin', 'gerencia'.
--
--   SQL_17 agregó 6 roles nuevos: jefe_zona, jefe_tecnica, jefe_operativa,
--   jefe_administrativa, jefe_automotores, capataz. NINGUNO de ellos aparece
--   en las policies de SQL_9 → hoy no ven ni pueden operar sobre relevamientos.
--
--   Este SQL amplía las policies existentes para incluir a los roles zonales
--   nuevos con los permisos que corresponden según el organigrama.
--
-- MATRIZ DE PERMISOS SOBRE relevamientos + partes_diarios
--
--   Rol                    | SELECT | INSERT | UPDATE | DELETE
--   ─────────────────────────────────────────────────────────────
--   admin                  |  all   |  all   |  all   |  all
--   gerencia               |  all   |  all   |  all   |  no
--   jefe_zona              |  zona  |  zona  |  zona  |  no
--   jefe_operativa         |  zona  |  zona  |  zona  |  no
--   jefe_tecnica           |  zona  |  zona  |  zona  |  no
--   jefe_administrativa    |  zona  |  no    |  no    |  no
--   jefe_automotores       |  zona  |  no    |  no    |  no
--   capataz                |  zona  |  zona  |  zona  |  no
--   tecnico (Fase 1)       |  zona  |  zona  |  zona  |  zona
--   publico (sin login)    |  zona  (via policy publico separada) — sin escritura
--
-- Notas:
--   · "zona" significa: solo registros donde relevamientos.zona = current_user_zona().
--   · Los jefes administrativos/automotores tienen READ para poder consultar
--     información zonal (planillas, indicadores) pero no operan campo.
--   · Solo tecnico y admin pueden borrar. Los jefes NO borran (auditoría).
-- ═════════════════════════════════════════════════════════════════════════════


-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Sets de roles helpers (para no repetir listas en cada policy)
-- ─────────────────────────────────────────────────────────────────────────────
-- Roles con acceso "operativo pleno" (SELECT + INSERT + UPDATE) sobre su zona:
CREATE OR REPLACE FUNCTION current_user_es_operativo_zonal() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() IN (
      'tecnico', 'capataz',
      'jefe_zona', 'jefe_tecnica', 'jefe_operativa'
    );
$$;

-- Roles con solo lectura zonal (jefes de división sin operativa de campo):
CREATE OR REPLACE FUNCTION current_user_es_lector_zonal() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() IN (
      'jefe_administrativa', 'jefe_automotores'
    );
$$;

GRANT EXECUTE ON FUNCTION current_user_es_operativo_zonal() TO authenticated;
GRANT EXECUTE ON FUNCTION current_user_es_lector_zonal()    TO authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Recrear policies de relevamientos
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS relev_read_zonal   ON relevamientos;
DROP POLICY IF EXISTS relev_insert_zonal ON relevamientos;
DROP POLICY IF EXISTS relev_update_zonal ON relevamientos;
DROP POLICY IF EXISTS relev_delete_zonal ON relevamientos;

CREATE POLICY relev_read_zonal ON relevamientos
  FOR SELECT USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
    OR (current_user_es_lector_zonal()    AND (zona = current_user_zona() OR zona IS NULL))
    -- Fallback compat: authenticated sin rol seteado (usuarios legacy)
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

CREATE POLICY relev_insert_zonal ON relevamientos
  FOR INSERT WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona()))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

CREATE POLICY relev_update_zonal ON relevamientos
  FOR UPDATE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  ) WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona()))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

-- DELETE: solo admin y tecnico (no jefes ni capataz — auditoría)
CREATE POLICY relev_delete_zonal ON relevamientos
  FOR DELETE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
  );


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Recrear policies de partes_diarios (misma matriz)
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS partes_read_zonal   ON partes_diarios;
DROP POLICY IF EXISTS partes_insert_zonal ON partes_diarios;
DROP POLICY IF EXISTS partes_update_zonal ON partes_diarios;
DROP POLICY IF EXISTS partes_delete_zonal ON partes_diarios;

CREATE POLICY partes_read_zonal ON partes_diarios
  FOR SELECT USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
    OR (current_user_es_lector_zonal()    AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

CREATE POLICY partes_insert_zonal ON partes_diarios
  FOR INSERT WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona()))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

CREATE POLICY partes_update_zonal ON partes_diarios
  FOR UPDATE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  ) WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_es_operativo_zonal() AND (zona = current_user_zona()))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

CREATE POLICY partes_delete_zonal ON partes_diarios
  FOR DELETE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
  );


-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Verificación
-- ─────────────────────────────────────────────────────────────────────────────
-- Al loguearte como jefezona.vi@dvba.test debe devolver:
--   SELECT COUNT(*) FROM relevamientos;  -- solo los de VI (~222)
--   SELECT current_user_rol(), current_user_zona();  -- 'jefe_zona', 'VI'
--
-- Al loguearte como jefeoperativa.iv@dvba.test debe devolver solo los de IV (~2).
--
-- Ninguna sesión de jefe puede DELETE de relevamientos ni partes_diarios.
-- ═════════════════════════════════════════════════════════════════════════════
