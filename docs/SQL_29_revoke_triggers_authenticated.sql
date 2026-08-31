-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_29 · Revocar EXECUTE de authenticated en funciones que son solo triggers
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-31
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   Post-SQL_28, quedan 15 warnings de "authenticated_security_definer_function".
--   De esas 15, hay 3 que son SOLO triggers o helpers internos — nadie las llama
--   por RPC desde el frontend, y no las usa ninguna policy RLS. Se pueden
--   revocar de authenticated sin romper nada:
--
--     · forzar_zona_por_rol()       → trigger BEFORE INSERT/UPDATE
--     · set_caminos_alias_updated_at() → trigger BEFORE UPDATE
--     · zona_por_partido(TEXT)      → usada por el trigger anterior (no por app)
--
--   El resto (7 helpers current_user_* + 5 RPCs reales) mantienen EXECUTE
--   porque las policies RLS o el frontend las necesitan.
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

REVOKE EXECUTE ON FUNCTION public.forzar_zona_por_rol()          FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.set_caminos_alias_updated_at() FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.zona_por_partido(TEXT)         FROM authenticated;

-- Los triggers siguen funcionando porque corren bajo el owner del código
-- (SECURITY DEFINER), no bajo el rol del user. El EXECUTE del user no aplica
-- al trigger, solo aplica a llamadas directas via RPC.

COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
-- Debe quedar 0 filas (ninguna con EXECUTE para authenticated):
SELECT p.proname
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.proname IN ('forzar_zona_por_rol','set_caminos_alias_updated_at','zona_por_partido')
   AND has_function_privilege('authenticated', p.oid, 'EXECUTE');

-- Test funcional post-revoke:
-- 1) Como jefe_zona.vi cargar un relevamiento nuevo → el trigger forzar_zona_por_rol
--    debe ejecutar y setear zona=VI automáticamente.
-- 2) Editar un camino_alias → set_caminos_alias_updated_at debe pisar updated_at.
