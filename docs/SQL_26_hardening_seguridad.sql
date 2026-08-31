-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_26 · Hardening de seguridad · fix de hallazgos del linter Supabase
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-XX
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   El linter de Supabase reportó vulnerabilidades en:
--   1. Vista v_partes_diarios_export sin security_invoker.
--   2. Vista v_solicitudes_admin que lee auth.users (privilege escalation).
--   3. Tabla `registros` legacy con policy "acceso publico" USING(true).
--   4. Tabla `partidos_zona` con RLS enabled pero sin policies (deny-all).
--
-- Este SQL resuelve los 4 puntos.
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) v_partes_diarios_export · security_invoker
-- ─────────────────────────────────────────────────────────────────────────────
ALTER VIEW public.v_partes_diarios_export SET (security_invoker = true);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) v_solicitudes_admin → función SECURITY DEFINER
-- ─────────────────────────────────────────────────────────────────────────────
-- La vista lee auth.users, que authenticated no puede leer directamente.
-- Reemplazamos por una función que:
--   · Es SECURITY DEFINER (corre con permisos del owner del código, no del caller).
--   · Filtra explícitamente por rol admin (una sola vez, antes de traer datos).
--   · Devuelve las MISMAS 15 columnas que la vista original (contrato preservado).

CREATE OR REPLACE FUNCTION public.get_solicitudes_admin()
RETURNS TABLE (
  id              BIGINT,
  tipo            TEXT,
  target_tabla    TEXT,
  target_id       BIGINT,
  target_zona     TEXT,
  zona_destino    TEXT,
  mensaje         TEXT,
  estado          TEXT,
  creado_en       TIMESTAMPTZ,
  actualizado_en  TIMESTAMPTZ,
  autor_id        UUID,
  autor_rol       TEXT,
  autor_zona      TEXT,
  autor_email     TEXT,
  autor_nombre    TEXT
)
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT c.id,
         c.tipo,
         c.target_tabla,
         c.target_id,
         c.target_zona,
         c.zona_destino,
         c.mensaje,
         c.estado,
         c.creado_en,
         c.actualizado_en,
         c.autor_id,
         c.autor_rol,
         c.autor_zona,
         au.email AS autor_email,
         up.nombre AS autor_nombre
    FROM public.comentarios_zona c
    LEFT JOIN public.usuarios_perfil up ON up.user_id = c.autor_id
    LEFT JOIN auth.users au             ON au.id      = c.autor_id
   WHERE c.tipo IN ('mover_zona', 'eliminar')
     AND c.estado = 'abierto'
     AND EXISTS (
       SELECT 1 FROM public.usuarios_perfil me
        WHERE me.user_id = auth.uid()
          AND me.activo
          AND me.rol = 'admin'
     )
   ORDER BY c.creado_en;
$$;

REVOKE ALL ON FUNCTION public.get_solicitudes_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_solicitudes_admin() TO authenticated;

-- Drop de la vista (después de actualizar el frontend a rpc)
DROP VIEW IF EXISTS public.v_solicitudes_admin;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Tabla `registros` legacy · DROP (asumiendo COUNT=0 o solo tests)
-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORTANTE: verificar antes de correr esta línea con:
--   SELECT COUNT(*) FROM public.registros;
-- Si count > 0 y hay datos reales, migrar a `relevamientos` antes de dropear.

DROP TABLE IF EXISTS public.registros;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) `partidos_zona` · policy de lectura pública
-- ─────────────────────────────────────────────────────────────────────────────
-- La tabla tiene RLS enabled pero sin policies → deny-all.
-- El mapeo partido→zona es información institucional pública, no sensible.
-- Damos SELECT a todos los roles autenticados y anónimos (para el mapa público).

ALTER TABLE public.partidos_zona ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lectura_publica_partidos_zona" ON public.partidos_zona;
CREATE POLICY "lectura_publica_partidos_zona" ON public.partidos_zona
  FOR SELECT USING (true);

-- Escritura: solo admin puede modificar el mapeo oficial.
DROP POLICY IF EXISTS "escritura_admin_partidos_zona" ON public.partidos_zona;
CREATE POLICY "escritura_admin_partidos_zona" ON public.partidos_zona
  FOR ALL USING (current_user_rol() = 'admin')
           WITH CHECK (current_user_rol() = 'admin');


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN post-aplicación
-- ─────────────────────────────────────────────────────────────────────────────

-- Vistas con security_invoker
SELECT c.relname, c.reloptions
  FROM pg_class c
 WHERE c.relkind = 'v'
   AND c.relnamespace = 'public'::regnamespace
   AND c.relname IN ('v_partes_diarios_export','v_agenda_capataz','v_backlog_jefe_zona','v_kpi_asignaciones');

-- Función get_solicitudes_admin creada y RPC accesible
SELECT proname, prosecdef FROM pg_proc WHERE proname = 'get_solicitudes_admin';

-- registros ya no existe
SELECT to_regclass('public.registros');  -- debe ser NULL

-- partidos_zona con 2 policies
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'partidos_zona';
