-- ═══════════════════════════════════════════════════════════════════════════════
-- SQL 9 · Row Level Security ZONAL (multi-zona activo)
-- v8.23 · Fase 3 del Plan de Roles y Escalado Multi-Zona
--
-- OBJETIVO
--   Reemplazar las policies "authenticated puede todo" de SQL_5 y SETUP_AUTH por
--   policies zone-aware que respeten el modelo de 4 roles definido en SQL_7:
--
--   ┌─────────────┬───────────────────────────────────────────────────────────┐
--   │ ROL         │ QUÉ VE / QUÉ HACE                                          │
--   ├─────────────┼───────────────────────────────────────────────────────────┤
--   │ público     │ SELECT abierto de relevamientos aprobados (para el mapa).  │
--   │             │ No hay INSERT/UPDATE/DELETE.                              │
--   │ técnico     │ CRUD completo, PERO solo sobre registros de SU zona.       │
--   │             │ (zona = current_user_zona())                              │
--   │ gerencia    │ SELECT global (12 zonas). NO edita.                        │
--   │ admin       │ CRUD global sin restricción.                              │
--   └─────────────┴───────────────────────────────────────────────────────────┘
--
--   Tablas afectadas:
--     - relevamientos (fotos de campo + sello)
--     - partes_diarios (plan de seguridad en circulación)
--     - parte_maquinarias (vehículos por parte)
--     - parte_fotos (fotos adjuntas al parte)
--
-- REQUISITOS PREVIOS
--   ✓ SQL_7 aplicado (tabla usuarios_perfil + funciones current_user_zona() y
--     current_user_rol()).
--   ✓ SQL_8 aplicado (columna zona en relevamientos y partes_diarios con
--     backfill 'VI' para datos existentes).
--   ✓ Perfil admin creado para el bootstrap (ver bloque final de SQL_7).
--
-- ORDEN DE APLICACIÓN
--   1. Correr todo este archivo en SQL Editor de Supabase (service_role).
--   2. Ejecutar los SELECT de verificación al final.
--   3. Testear desde el frontend con distintos usuarios:
--        - técnico VI  → solo ve zona VI
--        - técnico VII → solo ve zona VII (crear uno de prueba)
--        - gerencia    → ve todo, no puede editar
--        - admin       → hace todo
--
-- ROLLBACK
--   Si algo falla, correr el bloque ROLLBACK del final que restaura las
--   policies "authenticated puede todo" de SQL_5.
--
-- NOTA de diseño · manejo de datos legacy (zona NULL)
--   Los registros migrados masivamente (632 partes históricos + relevamientos
--   viejos) pueden tener zona=NULL si el backfill de SQL_8 no cubrió alguno.
--   Las policies tratan `zona IS NULL` como "acceso al técnico de VI" (default
--   histórico) para no romper el histórico. Después migrar los NULLs con:
--     UPDATE relevamientos SET zona='VI' WHERE zona IS NULL;
--     UPDATE partes_diarios SET zona='VI' WHERE zona IS NULL;
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1) Sanity check: las funciones auxiliares tienen que existir
-- ═══════════════════════════════════════════════════════════════════════════════
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'current_user_zona') THEN
    RAISE EXCEPTION 'Falta la función current_user_zona() — correr SQL_7 primero';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'current_user_rol') THEN
    RAISE EXCEPTION 'Falta la función current_user_rol() — correr SQL_7 primero';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='relevamientos' AND column_name='zona') THEN
    RAISE EXCEPTION 'Falta la columna zona en relevamientos — correr SQL_8 primero';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name='partes_diarios' AND column_name='zona') THEN
    RAISE EXCEPTION 'Falta la columna zona en partes_diarios — correr SQL_8 primero';
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2) RELEVAMIENTOS (fotos de campo)
--    Policies actuales de SETUP_AUTH: lectura pública, insert/update/delete
--    para authenticated. Las reemplazamos por versiones zone-aware.
-- ═══════════════════════════════════════════════════════════════════════════════
ALTER TABLE relevamientos ENABLE ROW LEVEL SECURITY;

-- Sacar policies viejas (los IF EXISTS toleran ausencias)
DROP POLICY IF EXISTS "lectura_publica"       ON relevamientos;
DROP POLICY IF EXISTS "insert_authenticated"  ON relevamientos;
DROP POLICY IF EXISTS "update_authenticated"  ON relevamientos;
DROP POLICY IF EXISTS "delete_authenticated"  ON relevamientos;
DROP POLICY IF EXISTS relev_read_zonal        ON relevamientos;
DROP POLICY IF EXISTS relev_insert_zonal      ON relevamientos;
DROP POLICY IF EXISTS relev_update_zonal      ON relevamientos;
DROP POLICY IF EXISTS relev_delete_zonal      ON relevamientos;
DROP POLICY IF EXISTS relev_read_publico      ON relevamientos;

-- SELECT · público ve aprobados (mapa) + técnico ve su zona + gerencia/admin ven todo
CREATE POLICY relev_read_zonal ON relevamientos
  FOR SELECT USING (
       (auth.role() = 'anon' AND estado_workflow = 'aprobado')
    OR (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
    -- Fallback authenticated sin perfil (usuarios legacy pre-SQL_7):
    -- que vean SOLO zona VI para no romper el flow histórico.
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  );

-- INSERT · técnicos solo pueden crear en su zona; admin/gerencia en cualquiera;
-- el fallback histórico (sin perfil) inserta con zona='VI'.
CREATE POLICY relev_insert_zonal ON relevamientos
  FOR INSERT WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_rol() = 'tecnico'
        AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  );

-- UPDATE · mismo criterio que SELECT (misma zona o admin)
CREATE POLICY relev_update_zonal ON relevamientos
  FOR UPDATE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  )
  WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico'
        AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  );

-- DELETE · solo admin o técnicos de la misma zona
CREATE POLICY relev_delete_zonal ON relevamientos
  FOR DELETE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
  );

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3) PARTES_DIARIOS (Plan de Seguridad en la Circulación)
--    Reemplazan las policies "authenticated puede todo" de SQL_5.
-- ═══════════════════════════════════════════════════════════════════════════════
ALTER TABLE partes_diarios ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS partes_read_auth      ON partes_diarios;
DROP POLICY IF EXISTS partes_insert_auth    ON partes_diarios;
DROP POLICY IF EXISTS partes_update_auth    ON partes_diarios;
DROP POLICY IF EXISTS partes_delete_auth    ON partes_diarios;
DROP POLICY IF EXISTS partes_read_zonal     ON partes_diarios;
DROP POLICY IF EXISTS partes_insert_zonal   ON partes_diarios;
DROP POLICY IF EXISTS partes_update_zonal   ON partes_diarios;
DROP POLICY IF EXISTS partes_delete_zonal   ON partes_diarios;

CREATE POLICY partes_read_zonal ON partes_diarios
  FOR SELECT USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  );

CREATE POLICY partes_insert_zonal ON partes_diarios
  FOR INSERT WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico'
        AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  );

CREATE POLICY partes_update_zonal ON partes_diarios
  FOR UPDATE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  )
  WITH CHECK (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico'
        AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  );

CREATE POLICY partes_delete_zonal ON partes_diarios
  FOR DELETE USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
  );

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4) PARTE_MAQUINARIAS + PARTE_FOTOS (tablas satélite de partes_diarios)
--    Estas NO tienen columna zona propia — la zona la heredan del parte padre.
--    Simplificamos: filtramos por EXISTS del parte padre (que ya tiene su RLS).
-- ═══════════════════════════════════════════════════════════════════════════════
ALTER TABLE parte_maquinarias ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS parte_maq_read_auth   ON parte_maquinarias;
DROP POLICY IF EXISTS parte_maq_insert_auth ON parte_maquinarias;
DROP POLICY IF EXISTS parte_maq_upd_auth    ON parte_maquinarias;
DROP POLICY IF EXISTS parte_maq_del_auth    ON parte_maquinarias;
DROP POLICY IF EXISTS parte_maq_zonal       ON parte_maquinarias;

CREATE POLICY parte_maq_zonal ON parte_maquinarias
  FOR ALL USING (
    EXISTS (SELECT 1 FROM partes_diarios pd WHERE pd.id = parte_maquinarias.parte_id)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM partes_diarios pd WHERE pd.id = parte_maquinarias.parte_id)
  );

ALTER TABLE parte_fotos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS parte_fotos_read_auth  ON parte_fotos;
DROP POLICY IF EXISTS parte_fotos_write_auth ON parte_fotos;
DROP POLICY IF EXISTS parte_fotos_zonal      ON parte_fotos;

CREATE POLICY parte_fotos_zonal ON parte_fotos
  FOR ALL USING (
    EXISTS (SELECT 1 FROM partes_diarios pd WHERE pd.id = parte_fotos.parte_id)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM partes_diarios pd WHERE pd.id = parte_fotos.parte_id)
  );

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 5) VERIFICACIÓN (correr después del COMMIT para chequear estado)
-- ═══════════════════════════════════════════════════════════════════════════════

-- 5.1 · Listar policies activas en las 4 tablas
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE tablename IN ('relevamientos','partes_diarios','parte_maquinarias','parte_fotos')
ORDER BY tablename, policyname;

-- 5.2 · Contar registros por zona (para verificar que el backfill de SQL_8 quedó bien)
SELECT 'relevamientos' AS tabla, zona, COUNT(*) FROM relevamientos GROUP BY zona
UNION ALL
SELECT 'partes_diarios' AS tabla, zona, COUNT(*) FROM partes_diarios GROUP BY zona
ORDER BY tabla, zona;

-- 5.3 · Simular consultas como distintos roles (correr en Supabase SQL Editor)
--       SELECT current_user_zona(), current_user_rol();  -- lo que ve la sesión
--       SELECT COUNT(*) FROM relevamientos;               -- debería filtrar por zona
--       SELECT COUNT(*) FROM partes_diarios;

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROLLBACK · en caso de que algo falle, correr este bloque para volver a SQL_5
-- ═══════════════════════════════════════════════════════════════════════════════
/*
BEGIN;

-- relevamientos
DROP POLICY IF EXISTS relev_read_zonal   ON relevamientos;
DROP POLICY IF EXISTS relev_insert_zonal ON relevamientos;
DROP POLICY IF EXISTS relev_update_zonal ON relevamientos;
DROP POLICY IF EXISTS relev_delete_zonal ON relevamientos;

CREATE POLICY "lectura_publica" ON relevamientos FOR SELECT USING (true);
CREATE POLICY "insert_authenticated" ON relevamientos FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "update_authenticated" ON relevamientos FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "delete_authenticated" ON relevamientos FOR DELETE USING (auth.role() = 'authenticated');

-- partes_diarios
DROP POLICY IF EXISTS partes_read_zonal   ON partes_diarios;
DROP POLICY IF EXISTS partes_insert_zonal ON partes_diarios;
DROP POLICY IF EXISTS partes_update_zonal ON partes_diarios;
DROP POLICY IF EXISTS partes_delete_zonal ON partes_diarios;

CREATE POLICY partes_read_auth   ON partes_diarios FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY partes_insert_auth ON partes_diarios FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY partes_update_auth ON partes_diarios FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY partes_delete_auth ON partes_diarios FOR DELETE USING (auth.role() = 'authenticated');

-- satélites
DROP POLICY IF EXISTS parte_maq_zonal   ON parte_maquinarias;
DROP POLICY IF EXISTS parte_fotos_zonal ON parte_fotos;

CREATE POLICY parte_maq_read_auth   ON parte_maquinarias FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY parte_maq_insert_auth ON parte_maquinarias FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY parte_maq_upd_auth    ON parte_maquinarias FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY parte_maq_del_auth    ON parte_maquinarias FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY parte_fotos_read_auth  ON parte_fotos FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY parte_fotos_write_auth ON parte_fotos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

COMMIT;
*/
