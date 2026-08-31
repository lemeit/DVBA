-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_30 · Columna autor_id + trazabilidad multi-usuario
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-31
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   Hasta hoy los registros (relevamientos, partes_diarios) NO tenían columna
--   `autor_id` — solo se sabía la zona geográfica del registro, no quién lo
--   cargó. Esto limita:
--   1. La trazabilidad del caso "agente de casa central que recorre la PBA":
--      no puedo saber que un registro en zona III lo cargó gerencia o admin
--      desde su celular en gira.
--   2. La regla de la matriz "tecnico UPDATE solo sus propios registros":
--      sin autor_id no puedo aplicar `AND autor_id = auth.uid()` en la policy.
--   3. La auditoría completa: en el panel admin veo quién archivó (borrado_por)
--      pero no quién había cargado originalmente.
--
--   Este SQL agrega la columna, el trigger auto-populate, actualiza la policy
--   UPDATE de tecnico, extiende la vista de auditoría, y hace backfill donde
--   se pueda (los históricos sin evidencia quedan NULL).
--
-- REQUISITOS PREVIOS
--   ✓ SQL_27 (matriz consolidada + soft-delete)
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Columnas nuevas
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.relevamientos
  ADD COLUMN IF NOT EXISTS autor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS autor_rol TEXT,
  ADD COLUMN IF NOT EXISTS autor_zona TEXT;

ALTER TABLE public.partes_diarios
  ADD COLUMN IF NOT EXISTS autor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS autor_rol TEXT,
  ADD COLUMN IF NOT EXISTS autor_zona TEXT;

-- Índice para queries frecuentes de "mis registros"
CREATE INDEX IF NOT EXISTS idx_relev_autor  ON public.relevamientos  (autor_id) WHERE autor_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_partes_autor ON public.partes_diarios (autor_id) WHERE autor_id IS NOT NULL;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Trigger BEFORE INSERT · auto-poblar autor_id/rol/zona con el user actual
-- ─────────────────────────────────────────────────────────────────────────────
-- Si el frontend no lo envía, el trigger lo completa desde auth.uid() y
-- usuarios_perfil. Si el user es admin o gerencia y quiere atribuir el registro
-- a otro user (excepcional), envía el autor_id explícito y el trigger respeta.

CREATE OR REPLACE FUNCTION public.set_autor_registro()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
  v_rol  TEXT;
  v_zona TEXT;
BEGIN
  -- Solo poblar si autor_id no vino explícito
  IF NEW.autor_id IS NULL THEN
    NEW.autor_id := auth.uid();
  END IF;

  -- Snapshot del rol/zona del autor en el momento del INSERT
  -- (para que si el user cambia de zona/rol después, el registro histórico
  -- conserve quién era esa persona cuando cargó)
  IF NEW.autor_id IS NOT NULL AND (NEW.autor_rol IS NULL OR NEW.autor_zona IS NULL) THEN
    SELECT rol, zona INTO v_rol, v_zona
      FROM public.usuarios_perfil
     WHERE user_id = NEW.autor_id
     LIMIT 1;
    IF NEW.autor_rol  IS NULL THEN NEW.autor_rol  := v_rol; END IF;
    IF NEW.autor_zona IS NULL THEN NEW.autor_zona := v_zona; END IF;
  END IF;

  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.set_autor_registro() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_relev_set_autor  ON public.relevamientos;
CREATE TRIGGER trg_relev_set_autor
  BEFORE INSERT ON public.relevamientos
  FOR EACH ROW EXECUTE FUNCTION public.set_autor_registro();

DROP TRIGGER IF EXISTS trg_partes_set_autor ON public.partes_diarios;
CREATE TRIGGER trg_partes_set_autor
  BEFORE INSERT ON public.partes_diarios
  FOR EACH ROW EXECUTE FUNCTION public.set_autor_registro();


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Backfill de registros históricos (donde se pueda inferir el autor)
-- ─────────────────────────────────────────────────────────────────────────────
-- Los registros anteriores a SQL_30 no tienen autor. Sin logs de auditoría
-- no podemos recuperar quién los cargó. Estrategias posibles:
--
--   a) Los relevamientos huérfanos de VI (zona=VI) pre-fecha X probablemente
--      son de tecnica.dvba.z6@gmail.com que era el único usuario activo hasta
--      agosto 2026. Backfill conservador: asignar a ese user los relevamientos
--      de VI creados antes del alta de otros usuarios.
--
--   b) Los partes_diarios cargados desde el portal por gerencia/admin no
--      tenían responsable_id (SQL_7 lo agregó) pero los muy viejos no.
--
-- OPCIONAL — descomentar SOLO si querés hacer el backfill conservador:
--
-- UPDATE public.relevamientos
--    SET autor_id = '9725c77f-77c8-4dee-a61a-9670e32db7b9',  -- tecnica.dvba.z6
--        autor_rol = 'jefe_tecnica',
--        autor_zona = 'VI'
--  WHERE autor_id IS NULL
--    AND zona = 'VI'
--    AND fecha < '2026-08-19'::timestamptz;
--
-- El resto de registros históricos quedan con autor_id NULL, marcados
-- claramente como "sin autor registrado" en la UI.


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Policy UPDATE tecnico · restringir a registros propios
-- ─────────────────────────────────────────────────────────────────────────────
-- Ahora que tenemos autor_id, aplicamos la regla real de la matriz:
-- "tecnico UPDATE solo sobre sus propios registros".

DROP POLICY IF EXISTS relev_update_zonal ON public.relevamientos;

CREATE POLICY relev_update_zonal ON public.relevamientos
  FOR UPDATE USING (
       current_user_rol() = 'admin'
    OR (borrado_en IS NULL AND (
          -- Los jefes zonales pueden editar cualquiera de su zona
          (current_user_rol() IN ('jefe_zona','jefe_tecnica','jefe_operativa','capataz')
           AND zona = current_user_zona())
          -- Los tecnicos solo sus propios registros (o los sin autor histórico de su zona)
          OR (current_user_rol() = 'tecnico'
              AND zona = current_user_zona()
              AND (autor_id = auth.uid() OR autor_id IS NULL))
       ))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  ) WITH CHECK (
       current_user_rol() = 'admin'
    OR (current_user_es_operativo_zonal() AND zona = current_user_zona())
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );


-- ─────────────────────────────────────────────────────────────────────────────
-- 5) Vista de auditoría ampliada (borrados + autor original)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.v_borrados_auditoria AS
  SELECT 'relevamientos' AS tabla, r.id, r.zona, r.tipo, r.ruta, r.progresiva, r.partido,
         r.borrado_en, r.borrado_por,
         upB.nombre AS borrado_por_nombre,
         r.motivo_borrado,
         r.autor_id AS autor_original_id,
         upA.nombre AS autor_original_nombre,
         r.autor_rol,
         r.autor_zona,
         r.fecha AS fecha_carga
    FROM public.relevamientos r
    LEFT JOIN public.usuarios_perfil upB ON upB.user_id = r.borrado_por
    LEFT JOIN public.usuarios_perfil upA ON upA.user_id = r.autor_id
   WHERE r.borrado_en IS NOT NULL
  UNION ALL
  SELECT 'partes_diarios' AS tabla, p.id, p.zona,
         NULL::TEXT AS tipo, p.ruta,
         NULL::TEXT AS progresiva, p.partido,
         p.borrado_en, p.borrado_por,
         upB.nombre AS borrado_por_nombre,
         p.motivo_borrado,
         p.autor_id AS autor_original_id,
         upA.nombre AS autor_original_nombre,
         p.autor_rol,
         p.autor_zona,
         p.fecha AS fecha_carga
    FROM public.partes_diarios p
    LEFT JOIN public.usuarios_perfil upB ON upB.user_id = p.borrado_por
    LEFT JOIN public.usuarios_perfil upA ON upA.user_id = p.autor_id
   WHERE p.borrado_en IS NOT NULL
   ORDER BY 8 DESC;

ALTER VIEW public.v_borrados_auditoria SET (security_invoker = true);
GRANT SELECT ON public.v_borrados_auditoria TO authenticated;


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────

-- Columnas creadas:
SELECT column_name, data_type FROM information_schema.columns
 WHERE table_schema='public' AND table_name IN ('relevamientos','partes_diarios')
   AND column_name IN ('autor_id','autor_rol','autor_zona')
 ORDER BY table_name, column_name;

-- Triggers activos:
SELECT event_object_table AS tabla, trigger_name FROM information_schema.triggers
 WHERE trigger_name LIKE 'trg_%_set_autor';

-- Cuántos registros tienen autor y cuántos son huérfanos históricos:
SELECT 'relevamientos' AS tabla,
       COUNT(*) FILTER (WHERE autor_id IS NOT NULL) AS con_autor,
       COUNT(*) FILTER (WHERE autor_id IS NULL) AS sin_autor
  FROM public.relevamientos
UNION ALL
SELECT 'partes_diarios',
       COUNT(*) FILTER (WHERE autor_id IS NOT NULL),
       COUNT(*) FILTER (WHERE autor_id IS NULL)
  FROM public.partes_diarios;

-- Test: al cargar un relevamiento nuevo, autor_id debe quedar auto-poblado.
