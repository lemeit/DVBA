-- ═══════════════════════════════════════════════════════════════════════════════
-- SQL 11 · Funciones y policies para el Panel Admin de Usuarios
-- v8.45 · Fase 4 · Panel de administración
--
-- OBJETIVO
--   El panel admin_usuarios.html necesita:
--   1. Listar todos los users (auth.users + usuarios_perfil). No se puede hacer
--      desde el frontend directo porque auth.users solo es accesible con
--      service_role. Solución: función SECURITY DEFINER que devuelve el JOIN.
--   2. Que admin pueda UPDATE cualquier usuarios_perfil (no solo el propio).
--   3. Que admin pueda INSERT/UPSERT nuevos perfiles para users que se
--      autoregistraron (invitación diferida).
--
-- REQUISITOS PREVIOS
--   ✓ SQL_7, SQL_8, SQL_9, SQL_10 aplicados.
--
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1) FUNCIÓN · Listar users con perfiles (accesible solo por admins)
-- ═══════════════════════════════════════════════════════════════════════════════
DROP FUNCTION IF EXISTS admin_listar_usuarios();
CREATE OR REPLACE FUNCTION admin_listar_usuarios()
RETURNS TABLE (
  user_id       UUID,
  email         TEXT,
  nombre        TEXT,
  rol           TEXT,
  zona          TEXT,
  activo        BOOLEAN,
  created_at    TIMESTAMPTZ,
  last_sign_in  TIMESTAMPTZ,
  email_confirmed BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  -- Guard: solo admins pueden invocar
  IF current_user_rol() != 'admin' THEN
    RAISE EXCEPTION 'Acceso denegado: se requiere rol admin (rol actual: %)', COALESCE(current_user_rol(), 'sin perfil');
  END IF;

  RETURN QUERY
  SELECT
    au.id                                       AS user_id,
    au.email::TEXT                              AS email,
    up.nombre                                   AS nombre,
    up.rol                                      AS rol,
    up.zona                                     AS zona,
    COALESCE(up.activo, false)                  AS activo,
    au.created_at                               AS created_at,
    au.last_sign_in_at                          AS last_sign_in,
    (au.email_confirmed_at IS NOT NULL)         AS email_confirmed
  FROM auth.users au
  LEFT JOIN usuarios_perfil up ON up.user_id = au.id
  ORDER BY
    CASE up.rol WHEN 'admin' THEN 1 WHEN 'gerencia' THEN 2 WHEN 'tecnico' THEN 3 ELSE 4 END,
    up.zona NULLS LAST,
    au.email;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_listar_usuarios() TO authenticated;
COMMENT ON FUNCTION admin_listar_usuarios() IS 'v8.45 · Lista users + perfil. Solo admin (guard interno).';

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2) POLICY · Admin puede UPSERT/UPDATE cualquier usuarios_perfil
-- ═══════════════════════════════════════════════════════════════════════════════
ALTER TABLE usuarios_perfil ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS usuarios_perfil_own_read       ON usuarios_perfil;
DROP POLICY IF EXISTS usuarios_perfil_own_upsert     ON usuarios_perfil;
DROP POLICY IF EXISTS usuarios_perfil_admin_all      ON usuarios_perfil;

-- User autenticado puede leer su propio perfil
CREATE POLICY usuarios_perfil_own_read ON usuarios_perfil
  FOR SELECT
  USING (auth.uid() = user_id);

-- User autenticado puede insertar/actualizar su propio perfil
-- (bootstrap · pero no puede cambiarse el rol a admin unilateralmente)
CREATE POLICY usuarios_perfil_own_upsert ON usuarios_perfil
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id
    AND (rol IS NULL OR rol = 'tecnico' OR rol = current_user_rol())  -- no puede escalar solo
  );

-- Admin puede TODO sobre cualquier perfil (leer, crear, editar, borrar)
CREATE POLICY usuarios_perfil_admin_all ON usuarios_perfil
  FOR ALL
  USING (current_user_rol() = 'admin')
  WITH CHECK (current_user_rol() = 'admin');

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3) FUNCIÓN · Contar users por rol/zona (para métricas del panel)
-- ═══════════════════════════════════════════════════════════════════════════════
DROP FUNCTION IF EXISTS admin_metricas_usuarios();
CREATE OR REPLACE FUNCTION admin_metricas_usuarios()
RETURNS TABLE (rol TEXT, zona TEXT, activos BIGINT, total BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
BEGIN
  IF current_user_rol() != 'admin' THEN
    RAISE EXCEPTION 'Acceso denegado: se requiere rol admin';
  END IF;
  RETURN QUERY
  SELECT
    COALESCE(up.rol, '<sin_perfil>')::TEXT   AS rol,
    COALESCE(up.zona, '<sin_zona>')::TEXT    AS zona,
    COUNT(*) FILTER (WHERE COALESCE(up.activo, false))  AS activos,
    COUNT(*)                                            AS total
  FROM auth.users au
  LEFT JOIN usuarios_perfil up ON up.user_id = au.id
  GROUP BY up.rol, up.zona
  ORDER BY
    CASE up.rol WHEN 'admin' THEN 1 WHEN 'gerencia' THEN 2 WHEN 'tecnico' THEN 3 ELSE 4 END,
    up.zona NULLS LAST;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_metricas_usuarios() TO authenticated;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4) VERIFICACIÓN
-- ═══════════════════════════════════════════════════════════════════════════════

-- 4.1 · Ver que las funciones se crearon
SELECT proname, pronargs, prosecdef
FROM pg_proc
WHERE proname IN ('admin_listar_usuarios', 'admin_metricas_usuarios');

-- 4.2 · Probar la función (correr como admin)
SELECT * FROM admin_listar_usuarios();

-- 4.3 · Ver policies actualizadas en usuarios_perfil
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'usuarios_perfil'
ORDER BY policyname;
