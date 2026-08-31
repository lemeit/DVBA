-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_33 · Métricas de sistema para el panel Admin (tab "Sistema")
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-31
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   El panel admin se reestructura con 4 tabs (Usuarios / Solicitudes /
--   Auditoría / Sistema). La tab "Sistema" muestra información técnica de la
--   base de datos y el almacenamiento (Grupo A):
--
--   1. Tamaño total de la BD, tamaño de tablas principales, cantidad de filas.
--   2. Tamaño del bucket de fotos (relevamientos).
--   3. Salud básica: cuántas tablas con RLS, cuántas policies, etc.
--
--   Estas queries requieren permisos amplios sobre pg_stat_* y pg_class,
--   así que las envolvemos en una función SECURITY DEFINER que valida el rol
--   admin antes de devolver los datos.
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

CREATE OR REPLACE FUNCTION public.admin_metricas_sistema()
RETURNS JSONB
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
  v_result JSONB;
BEGIN
  IF current_user_rol() <> 'admin' THEN
    RAISE EXCEPTION 'Solo admin puede consultar métricas del sistema';
  END IF;

  v_result := jsonb_build_object(
    'timestamp', NOW(),

    -- Tamaño de la BD (data + indexes)
    'db_size_bytes', (SELECT pg_database_size(current_database())),
    'db_size_pretty', (SELECT pg_size_pretty(pg_database_size(current_database()))),

    -- Tamaños de tablas del schema public (top 10 por tamaño)
    'tablas', (
      SELECT jsonb_agg(t) FROM (
        SELECT c.relname AS tabla,
               pg_size_pretty(pg_total_relation_size(c.oid)) AS tamano,
               pg_total_relation_size(c.oid) AS tamano_bytes,
               c.reltuples::BIGINT AS filas_estimadas
          FROM pg_class c
          JOIN pg_namespace n ON n.oid = c.relnamespace
         WHERE c.relkind = 'r'
           AND n.nspname = 'public'
         ORDER BY pg_total_relation_size(c.oid) DESC
         LIMIT 12
      ) t
    ),

    -- Conteo de filas exacto en tablas clave
    'filas_relevamientos', (SELECT COUNT(*) FROM public.relevamientos),
    'filas_relevamientos_activos', (SELECT COUNT(*) FROM public.relevamientos WHERE borrado_en IS NULL),
    'filas_relevamientos_archivados', (SELECT COUNT(*) FROM public.relevamientos WHERE borrado_en IS NOT NULL),
    'filas_partes_diarios', (SELECT COUNT(*) FROM public.partes_diarios),
    'filas_usuarios_perfil', (SELECT COUNT(*) FROM public.usuarios_perfil),
    'filas_usuarios_activos', (SELECT COUNT(*) FROM public.usuarios_perfil WHERE activo),

    -- Almacenamiento del bucket relevamientos
    'storage_relevamientos', (
      SELECT jsonb_build_object(
        'total_archivos', COUNT(*),
        'tamano_bytes', COALESCE(SUM((metadata->>'size')::BIGINT), 0),
        'tamano_pretty', pg_size_pretty(COALESCE(SUM((metadata->>'size')::BIGINT), 0)),
        'ultima_subida', MAX(created_at)
      )
      FROM storage.objects
      WHERE bucket_id = 'relevamientos'
    ),

    -- Salud RLS: cuántas tablas tienen RLS activa y cuántas policies
    'salud_rls', (
      SELECT jsonb_build_object(
        'tablas_con_rls', COUNT(DISTINCT c.relname),
        'total_policies', (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public')
      )
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relkind = 'r'
        AND n.nspname = 'public'
        AND c.relrowsecurity = TRUE
    ),

    -- Info de auth: usuarios registrados en auth.users
    'auth', (
      SELECT jsonb_build_object(
        'total_usuarios_auth', (SELECT COUNT(*) FROM auth.users),
        'confirmados', (SELECT COUNT(*) FROM auth.users WHERE email_confirmed_at IS NOT NULL),
        'ultima_actividad', (SELECT MAX(last_sign_in_at) FROM auth.users)
      )
    )
  );

  RETURN v_result;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.admin_metricas_sistema() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_metricas_sistema() TO authenticated;


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN (correr como admin desde el SQL Editor o desde la app)
-- ─────────────────────────────────────────────────────────────────────────────
-- SELECT admin_metricas_sistema();
--
-- Devuelve un JSONB con toda la info agrupada. La UI del admin lo va a leer
-- una vez y renderizar en cards visuales agrupadas (BD / Storage / Salud / Auth).
