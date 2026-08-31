-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_32 · Notificaciones de restauración de registros archivados
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-31
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   El ciclo completo de borrado del sistema es:
--     Jefe zona archiva con motivo → Admin revisa en panel auditoría →
--     Admin decide: Restaurar (SQL_27 UPDATE simple hoy) o Eliminar definitivo.
--
--   Si el Admin restaura, el jefe de zona NO se entera. El registro reaparece
--   pero sin contexto de que hubo intervención. Este SQL agrega notificaciones:
--
--   1. Columnas de restauración (histórico + estado de "leído" por el jefe).
--   2. RPC restaurar_registro (con motivo opcional del admin).
--   3. RPC marcar_restauraciones_vistas (jefe marca como vistas).
--   4. Vista v_restauraciones_pendientes (para el banner + badge en la cola).
--
-- REQUISITOS PREVIOS
--   ✓ SQL_27 (soft-delete jefe_zona)
--   ✓ SQL_30 (autor_id)
--   ✓ SQL_31 (trigger zona por partido)
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Columnas de restauración en relevamientos y partes_diarios
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.relevamientos
  ADD COLUMN IF NOT EXISTS restaurado_en TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS restaurado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS motivo_restauracion TEXT,
  ADD COLUMN IF NOT EXISTS restauracion_vista BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.partes_diarios
  ADD COLUMN IF NOT EXISTS restaurado_en TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS restaurado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS motivo_restauracion TEXT,
  ADD COLUMN IF NOT EXISTS restauracion_vista BOOLEAN NOT NULL DEFAULT FALSE;

-- NOTA: motivo_borrado se conserva aunque el registro se restaure (historial).
-- Solo se resetea borrado_en, borrado_por para que la RLS lo vuelva visible.


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) RPC restaurar_registro (con motivo opcional)
-- ─────────────────────────────────────────────────────────────────────────────
-- Solo admin. Reactiva el registro (borrado_en = NULL) y deja constancia:
--   - motivo_borrado histórico conservado.
--   - restaurado_en / restaurado_por / motivo_restauracion nuevos.
--   - restauracion_vista = FALSE (el jefe todavía no lo vio).

CREATE OR REPLACE FUNCTION public.restaurar_registro(
  p_tabla  TEXT,
  p_id     BIGINT,
  p_motivo TEXT DEFAULT NULL
) RETURNS BIGINT
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF current_user_rol() <> 'admin' THEN
    RAISE EXCEPTION 'Solo admin puede restaurar registros';
  END IF;

  IF p_tabla NOT IN ('relevamientos', 'partes_diarios') THEN
    RAISE EXCEPTION 'Tabla % no soportada', p_tabla;
  END IF;

  IF p_tabla = 'relevamientos' THEN
    UPDATE public.relevamientos
       SET borrado_en          = NULL,
           borrado_por         = NULL,
           restaurado_en       = NOW(),
           restaurado_por      = auth.uid(),
           motivo_restauracion = NULLIF(TRIM(COALESCE(p_motivo,'')), ''),
           restauracion_vista  = FALSE
     WHERE id = p_id
       AND borrado_en IS NOT NULL;
  ELSE
    UPDATE public.partes_diarios
       SET borrado_en          = NULL,
           borrado_por         = NULL,
           restaurado_en       = NOW(),
           restaurado_por      = auth.uid(),
           motivo_restauracion = NULLIF(TRIM(COALESCE(p_motivo,'')), ''),
           restauracion_vista  = FALSE
     WHERE id = p_id
       AND borrado_en IS NOT NULL;
  END IF;

  RETURN p_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.restaurar_registro(TEXT, BIGINT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.restaurar_registro(TEXT, BIGINT, TEXT) TO authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) RPC marcar_restauraciones_vistas (jefe marca aviso como leído)
-- ─────────────────────────────────────────────────────────────────────────────
-- El jefe la llama al cerrar el banner o modal de notificación. Marca todos los
-- registros restaurados de su zona como "ya vistos" para que no se muestren
-- de nuevo. Solo aplica a registros de la zona del jefe (RLS zonal implícita).

CREATE OR REPLACE FUNCTION public.marcar_restauraciones_vistas()
RETURNS INTEGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_zona TEXT;
  v_count INTEGER := 0;
  v_c INTEGER;
BEGIN
  v_zona := current_user_zona();
  IF v_zona IS NULL AND current_user_rol() NOT IN ('admin','gerencia') THEN
    RETURN 0;
  END IF;

  -- Admin y gerencia marcan todo. Roles zonales solo su zona.
  IF current_user_rol() IN ('admin','gerencia') THEN
    UPDATE public.relevamientos SET restauracion_vista = TRUE
     WHERE restaurado_en IS NOT NULL AND NOT restauracion_vista;
    GET DIAGNOSTICS v_c = ROW_COUNT; v_count := v_count + v_c;

    UPDATE public.partes_diarios SET restauracion_vista = TRUE
     WHERE restaurado_en IS NOT NULL AND NOT restauracion_vista;
    GET DIAGNOSTICS v_c = ROW_COUNT; v_count := v_count + v_c;
  ELSE
    UPDATE public.relevamientos SET restauracion_vista = TRUE
     WHERE zona = v_zona AND restaurado_en IS NOT NULL AND NOT restauracion_vista;
    GET DIAGNOSTICS v_c = ROW_COUNT; v_count := v_count + v_c;

    UPDATE public.partes_diarios SET restauracion_vista = TRUE
     WHERE zona = v_zona AND restaurado_en IS NOT NULL AND NOT restauracion_vista;
    GET DIAGNOSTICS v_c = ROW_COUNT; v_count := v_count + v_c;
  END IF;

  RETURN v_count;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.marcar_restauraciones_vistas() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.marcar_restauraciones_vistas() TO authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Vista v_restauraciones_pendientes (para el banner y la cola)
-- ─────────────────────────────────────────────────────────────────────────────
-- Registros que fueron archivados por un jefe, luego restaurados por admin,
-- y aún no fueron marcados como vistos. La RLS se hereda de relevamientos
-- (jefe zonal solo ve los de su zona; admin ve todo).

CREATE OR REPLACE VIEW public.v_restauraciones_pendientes AS
  SELECT 'relevamientos' AS tabla, r.id, r.zona, r.tipo, r.ruta, r.progresiva, r.partido,
         r.restaurado_en, r.restaurado_por,
         upR.nombre AS restaurado_por_nombre,
         r.motivo_restauracion,
         r.borrado_por AS jefe_que_archivo_id,
         upB.nombre AS jefe_que_archivo_nombre,
         r.motivo_borrado AS motivo_archivado_original,
         r.fecha AS fecha_carga
    FROM public.relevamientos r
    LEFT JOIN public.usuarios_perfil upR ON upR.user_id = r.restaurado_por
    LEFT JOIN public.usuarios_perfil upB ON upB.user_id = r.borrado_por
   WHERE r.restaurado_en IS NOT NULL
     AND NOT r.restauracion_vista
     AND r.borrado_en IS NULL   -- solo los activos (no re-archivados)
  UNION ALL
  SELECT 'partes_diarios' AS tabla, p.id, p.zona,
         NULL::TEXT AS tipo, p.ruta,
         NULL::TEXT AS progresiva, p.partido,
         p.restaurado_en, p.restaurado_por,
         upR.nombre AS restaurado_por_nombre,
         p.motivo_restauracion,
         p.borrado_por AS jefe_que_archivo_id,
         upB.nombre AS jefe_que_archivo_nombre,
         p.motivo_borrado AS motivo_archivado_original,
         p.fecha AS fecha_carga
    FROM public.partes_diarios p
    LEFT JOIN public.usuarios_perfil upR ON upR.user_id = p.restaurado_por
    LEFT JOIN public.usuarios_perfil upB ON upB.user_id = p.borrado_por
   WHERE p.restaurado_en IS NOT NULL
     AND NOT p.restauracion_vista
     AND p.borrado_en IS NULL
   ORDER BY 8 DESC;

ALTER VIEW public.v_restauraciones_pendientes SET (security_invoker = true);
GRANT SELECT ON public.v_restauraciones_pendientes TO authenticated;


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
-- Después de un ciclo completo (archivar → restaurar), esta query debe
-- mostrar 1 fila para el jefe de la zona correspondiente:
--   SELECT * FROM v_restauraciones_pendientes;

-- Cuando el jefe cierra el banner, esta llamada debe devolver la cantidad
-- de registros marcados como vistos:
--   SELECT marcar_restauraciones_vistas();

-- Después de marcar como vistas, v_restauraciones_pendientes debe estar vacía
-- para ese jefe.
