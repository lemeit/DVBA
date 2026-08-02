-- ═══════════════════════════════════════════════════════════════════════════════
-- SQL 12 · Endurecimiento RLS · Bloqueo total a anon en tablas de datos internos
-- v8.56 · Portal público solo con geometrías base (RPs/caminos/partidos)
--
-- CONTEXTO
--   Hasta v8.44 la policy relev_read_zonal permitía a rol anon leer relevamientos
--   aprobados (para el mapa público del portal). Sin embargo:
--     - La app es info institucional (aunque geometrías son públicas, la ejecución
--       de tareas concretas por parte del organismo no debería estar expuesta).
--     - Cualquiera con la anon-key (que va en el HTML público) podría hacer
--       fetch a Supabase y bajarse toda la info aprobada de las 12 zonas.
--
-- DECISIÓN (v8.56)
--   El portal público (index.html sin sesión) solo muestra mapa base:
--   RPs + caminos secundarios + partidos + localidades (todos como geojson
--   estático servido desde /datos, no desde Supabase). Cualquier registro,
--   parte, foto, perfil o info operativa requiere login.
--
-- CAMBIOS
--   1) Reemplazar policy relev_read_zonal · sacar la cláusula anon
--   2) Endurecer usuarios_perfil · anon no lee nada (por defecto ya lo estaba,
--      pero explicitamos con policy negativa)
--   3) parte_maquinarias y parte_fotos ya heredan RLS de partes_diarios,
--      no requieren cambios.
--
-- REQUISITOS PREVIOS
--   ✓ SQL_9 aplicado (policies zonales).
--   ✓ SQL_10 aplicado (trigger de zona).
--   ✓ SQL_11 aplicado (funciones admin).
--
-- ROLLBACK
--   Ver bloque al final del archivo.
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) RELEVAMIENTOS · sacar acceso anon
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS relev_read_zonal   ON relevamientos;
DROP POLICY IF EXISTS relev_read_publico ON relevamientos;

CREATE POLICY relev_read_zonal ON relevamientos
  FOR SELECT USING (
       (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
    -- Fallback authenticated sin perfil (legacy pre-SQL_7): ve solo zona VI
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
    -- v8.56 · anon NO tiene acceso · portal público solo con geometrías base
  );

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) USUARIOS_PERFIL · asegurar bloqueo anon (defensivo)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE usuarios_perfil ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS usuarios_perfil_own_read     ON usuarios_perfil;
DROP POLICY IF EXISTS usuarios_perfil_own_upsert   ON usuarios_perfil;
DROP POLICY IF EXISTS usuarios_perfil_admin_all    ON usuarios_perfil;
DROP POLICY IF EXISTS usuarios_perfil_publico_read ON usuarios_perfil;

-- Cada usuario ve solo su propio perfil (por user_id = auth.uid())
CREATE POLICY usuarios_perfil_own_read ON usuarios_perfil
  FOR SELECT USING (
    auth.uid() = user_id
    OR current_user_rol() = 'admin'
    OR current_user_rol() = 'gerencia'
  );

-- Insert/update solo del propio perfil, salvo admin
CREATE POLICY usuarios_perfil_own_upsert ON usuarios_perfil
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    OR current_user_rol() = 'admin'
  );

CREATE POLICY usuarios_perfil_admin_all ON usuarios_perfil
  FOR UPDATE USING (current_user_rol() = 'admin')
  WITH CHECK (current_user_rol() = 'admin');

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Bloque de defensa: eliminar cualquier policy legacy que exponga anon
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE p RECORD;
BEGIN
  FOR p IN
    SELECT tablename, policyname
    FROM pg_policies
    WHERE tablename IN ('relevamientos','partes_diarios','parte_maquinarias',
                        'parte_fotos','usuarios_perfil','catalogo_tareas')
      AND (
        (tablename = 'relevamientos'    AND policyname NOT LIKE 'relev\_%'    ESCAPE '\')
        OR (tablename = 'partes_diarios' AND policyname NOT LIKE 'partes\_%'   ESCAPE '\')
        OR (tablename = 'parte_maquinarias' AND policyname != 'parte_maq_zonal')
        OR (tablename = 'parte_fotos'      AND policyname != 'parte_fotos_zonal')
        OR (tablename = 'usuarios_perfil'  AND policyname NOT LIKE 'usuarios\_%' ESCAPE '\')
      )
  LOOP
    EXECUTE format('DROP POLICY %I ON %I', p.policyname, p.tablename);
    RAISE NOTICE 'v8.56 · Policy legacy eliminada: %.%', p.tablename, p.policyname;
  END LOOP;
END $$;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════════
-- VERIFICACIÓN · correr después del COMMIT
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1 · Listar policies activas
SELECT tablename, policyname, cmd, qual::text AS using_clause
FROM pg_policies
WHERE tablename IN ('relevamientos','partes_diarios','usuarios_perfil',
                    'parte_maquinarias','parte_fotos')
ORDER BY tablename, policyname;

-- 2 · Simular anon (correr desde SQL Editor con "Run as anon"):
--       SET ROLE anon;
--       SELECT COUNT(*) FROM relevamientos;       -- debe devolver 0
--       SELECT COUNT(*) FROM partes_diarios;      -- debe devolver 0
--       SELECT COUNT(*) FROM usuarios_perfil;     -- debe devolver 0
--       RESET ROLE;

-- 3 · Simular técnico logueado (mismo test que en v8.44 · debería seguir andando)
--       SELECT current_user_zona(), current_user_rol();
--       SELECT COUNT(*) FROM relevamientos;       -- filtrado por zona
--       SELECT COUNT(*) FROM partes_diarios;      -- filtrado por zona

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROLLBACK · si algo se rompe, restaurar la policy con acceso anon a aprobados
-- ═══════════════════════════════════════════════════════════════════════════════
/*
BEGIN;

DROP POLICY IF EXISTS relev_read_zonal ON relevamientos;

CREATE POLICY relev_read_zonal ON relevamientos
  FOR SELECT USING (
       (auth.role() = 'anon' AND estado_workflow = 'aprobado')
    OR (current_user_rol() = 'admin')
    OR (current_user_rol() = 'gerencia')
    OR (current_user_rol() = 'tecnico' AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL
        AND (zona = 'VI' OR zona IS NULL))
  );

COMMIT;
*/
