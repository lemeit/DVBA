-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_28 · Hardening de warnings del linter Supabase
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-31
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   Post-SQL_26/27, el linter reporta solo warnings (0 errores). Este SQL:
--   1. Fija search_path = public en todas las funciones DEFINER.
--   2. Revoca EXECUTE de `anon` en todas las funciones DEFINER (no público).
--   3. Endurece el bucket `relevamientos` quitando la policy que permite listing.
--
-- NOTA IMPORTANTE sobre `authenticated_security_definer_function_executable`:
--   Los helpers `current_user_rol/zona/es_*` son usados dentro de las policies
--   RLS, y por lo tanto CADA authenticated necesita EXECUTE para que las
--   policies puedan evaluar. No podemos revocar sin romper el sistema entero.
--   Ese warning en helpers es esperado y aceptable — son funciones sin efectos
--   secundarios que solo devuelven metadata del user actual. Se puede marcar
--   como "ignored" en el Advisor.
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Fijar search_path = public en todas las funciones DEFINER existentes
-- ─────────────────────────────────────────────────────────────────────────────
ALTER FUNCTION public.current_user_rol()                       SET search_path = public;
ALTER FUNCTION public.current_user_zona()                      SET search_path = public;
ALTER FUNCTION public.current_user_es_jefe()                   SET search_path = public;
ALTER FUNCTION public.current_user_es_capataz()                SET search_path = public;
ALTER FUNCTION public.current_user_puede_asignar()             SET search_path = public;
ALTER FUNCTION public.current_user_es_operativo_zonal()        SET search_path = public;
ALTER FUNCTION public.current_user_es_lector_zonal()           SET search_path = public;
ALTER FUNCTION public.forzar_zona_por_rol()                    SET search_path = public;
ALTER FUNCTION public.zona_por_partido(TEXT)                   SET search_path = public;
ALTER FUNCTION public._touch_updated_at()                      SET search_path = public;
ALTER FUNCTION public.trg_comentarios_zona_updated()           SET search_path = public;
ALTER FUNCTION public.set_caminos_alias_updated_at()           SET search_path = public;
ALTER FUNCTION public.comentarios_contadores()                 SET search_path = public;
ALTER FUNCTION public.admin_listar_usuarios()                  SET search_path = public;
ALTER FUNCTION public.admin_metricas_usuarios()                SET search_path = public;
-- SQL_26/27 ya vienen con SET search_path, pero por si acaso:
ALTER FUNCTION public.get_solicitudes_admin()                  SET search_path = public;
ALTER FUNCTION public.soft_delete_relevamiento(BIGINT, TEXT)   SET search_path = public;
ALTER FUNCTION public.soft_delete_parte_diario(BIGINT, TEXT)   SET search_path = public;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Revocar EXECUTE en `anon` para todas las funciones DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
-- Ninguna de estas funciones debería poder llamarse sin sesión.
-- (Las que devuelven metadata del user actual devolverían NULL igual, pero
-- exponerlas por RPC es innecesario y ruidoso.)
REVOKE EXECUTE ON FUNCTION public.current_user_rol()                     FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.current_user_zona()                    FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.current_user_es_jefe()                 FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.current_user_es_capataz()              FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.current_user_puede_asignar()           FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.current_user_es_operativo_zonal()      FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.current_user_es_lector_zonal()         FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.forzar_zona_por_rol()                  FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.zona_por_partido(TEXT)                 FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public._touch_updated_at()                    FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.trg_comentarios_zona_updated()         FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.set_caminos_alias_updated_at()         FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.comentarios_contadores()               FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.admin_listar_usuarios()                FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.admin_metricas_usuarios()              FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.get_solicitudes_admin()                FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.soft_delete_relevamiento(BIGINT, TEXT) FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.soft_delete_parte_diario(BIGINT, TEXT) FROM anon, PUBLIC;

-- Nota: mantenemos EXECUTE a `authenticated` porque las policies RLS
-- necesitan poder evaluar los helpers current_user_*. Los helpers no
-- devuelven info sensible por sí solos (son metadata del user actual).


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Bucket `relevamientos` · quitar policy que permite listing público
-- ─────────────────────────────────────────────────────────────────────────────
-- El bucket es público (necesario para que las URLs de foto funcionen sin
-- signed URLs), pero no debería permitir LISTAR el contenido del bucket.
-- Las URLs directas siguen accesibles porque el bucket sigue siendo `public`.
--
-- Dejamos "fotos_lectura" (probablemente la que autoriza el acceso individual)
-- y quitamos "storage_select_publico" (la genérica que permite listar).

DROP POLICY IF EXISTS "storage_select_publico" ON storage.objects;

-- Verificación: debe quedar solo "fotos_lectura" u otra específica
-- SELECT policyname, cmd, qual FROM pg_policies
--  WHERE tablename = 'objects' AND schemaname = 'storage'
--    AND policyname ILIKE '%foto%' OR policyname ILIKE '%relev%';


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Todas las funciones DEFINER con search_path fijo:
SELECT n.nspname AS schema, p.proname AS function,
       CASE WHEN p.proconfig IS NULL THEN '(sin search_path)' ELSE array_to_string(p.proconfig, ', ') END AS config
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.prosecdef = true
 ORDER BY p.proname;

-- 2. Funciones con EXECUTE de anon (deberían ser 0):
SELECT p.proname, r.rolname
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  CROSS JOIN LATERAL (
    SELECT rolname FROM pg_roles WHERE rolname = 'anon'
  ) r
 WHERE n.nspname = 'public'
   AND p.prosecdef = true
   AND has_function_privilege(r.rolname, p.oid, 'EXECUTE');


-- ═════════════════════════════════════════════════════════════════════════════
-- ACCIÓN MANUAL FUERA DE SQL · Habilitar protección de passwords filtrados
-- ═════════════════════════════════════════════════════════════════════════════
-- El warning `auth_leaked_password_protection` no se resuelve con SQL.
-- Se activa desde el Dashboard de Supabase:
--
--   1. Ir a: Authentication → Policies (o Providers, depende de versión)
--   2. Sección "Password strength"
--   3. Activar: "Prevent use of leaked passwords" (chequea contra HaveIBeenPwned)
--   4. Guardar
--
-- Ojo: si algún user actual tiene una password comprometida, no podrá cambiarla
-- por otra también comprometida hasta que use una segura.
-- ═════════════════════════════════════════════════════════════════════════════
