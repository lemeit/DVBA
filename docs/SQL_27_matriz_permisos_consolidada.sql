-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_27 · Matriz de permisos consolidada · rollback de derivas + soft-delete
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   Auditoría de seguridad detectó 3 derivas respecto de la directiva original
--   del proyecto (gerencia descentralizada + jerarquía real DVBA + mínimo
--   privilegio). Este SQL consolida la matriz definitiva:
--
--   1. GERENCIA · rollback INSERT/UPDATE/DELETE. Solo LECTURA + intervenciones
--      via SQL_18 (columnas intervenido_por / motivo_intervencion). Preserva la
--      descentralización zonal: gerencia consulta y sugiere, no ejecuta.
--
--   2. jefe_administrativa y jefe_automotores · rollback CRUD (SQL_21).
--      Vuelven a SOLO LECTURA ZONAL. Coherente con SQL_17: estos jefes no
--      hacen trabajo de campo vial, gestionan RRHH/contable y parque vehicular.
--
--   3. tecnico · rollback DELETE. Un técnico individual no debe poder borrar
--      registros oficiales. Solo admin borra físico; jefe_zona hace soft-delete
--      con justificación.
--
--   4. jefe_zona · autorizado a SOFT-DELETE con motivo obligatorio. Queda
--      registro auditable para admin (columnas borrado_por / borrado_en /
--      motivo_borrado). El registro no se elimina físicamente, queda oculto
--      para roles no-admin y recuperable ante error.
--
-- MATRIZ CONSOLIDADA (fuente única de verdad · 2026-08-19)
--
--   Rol                   | SELECT | INSERT | UPDATE | DELETE(*) | Aprobar | Interv | Asignar
--   ─────────────────────────────────────────────────────────────────────────────────────────
--   admin                 |  all   |   ✓    |   ✓    |    ✓ HARD    |    ✓    |   ✓    |    ✓
--   gerencia              |  all   |   ✗    |   ✗    |    ✗         |    ✗    |   ✓    |    ✗
--   jefe_zona             |  zona  |   ✓    |   ✓    |  ✓ SOFT (**) |    ✓    |   ✗    |    ✓
--   jefe_operativa        |  zona  |   ✓    |   ✓    |    ✗         |    ✓    |   ✗    |    ✓
--   jefe_tecnica          |  zona  |   ✓    |   ✓    |    ✗         |    ✓    |   ✗    |    ✗
--   jefe_administrativa   |  zona  |   ✗    |   ✗    |    ✗         |    ✗    |   ✗    |    ✗
--   jefe_automotores      |  zona  |   ✗    |   ✗    |    ✗         |    ✗    |   ✗    |    ✗
--   capataz               |  zona  |  ✓(#)  |   ✗    |    ✗         |    ✗    |   ✗    |    ✗
--   tecnico               |  zona  |   ✓    | ✓(##)  |    ✗         |    ✗    |   ✗    |    ✗
--   publico (sin login)   |  mapa  |   ✗    |   ✗    |    ✗         |    ✗    |   ✗    |    ✗
--
--   (*)  HARD delete: elimina físicamente la fila. SOFT delete: setea columnas
--        borrado_por / borrado_en / motivo_borrado; el registro queda oculto
--        para roles no-admin (via policy SELECT) pero recuperable por admin.
--   (**) jefe_zona: soft-delete solo en su zona, requiere motivo (min 10 chars).
--   (#)  capataz: solo INSERT de "cierre de tarea con foto" — no crea relevamientos.
--   (##) tecnico: UPDATE solo sobre registros que él mismo cargó (autor_id = auth.uid()).
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Helpers · restaurar la separación operativo vs lector zonal
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.current_user_es_operativo_zonal() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() IN (
      'tecnico', 'capataz',
      'jefe_zona', 'jefe_tecnica', 'jefe_operativa'
    );
$$;

CREATE OR REPLACE FUNCTION public.current_user_es_lector_zonal() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() IN (
      'jefe_administrativa', 'jefe_automotores'
    );
$$;

GRANT EXECUTE ON FUNCTION public.current_user_es_operativo_zonal() TO authenticated;
GRANT EXECUTE ON FUNCTION public.current_user_es_lector_zonal()    TO authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Columnas de soft-delete en relevamientos y partes_diarios
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.relevamientos
  ADD COLUMN IF NOT EXISTS borrado_en TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS borrado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS motivo_borrado TEXT;

ALTER TABLE public.partes_diarios
  ADD COLUMN IF NOT EXISTS borrado_en TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS borrado_por UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS motivo_borrado TEXT;

-- Índices para excluir borrados rápido en queries frecuentes
CREATE INDEX IF NOT EXISTS idx_relev_no_borrados  ON public.relevamientos (id)  WHERE borrado_en IS NULL;
CREATE INDEX IF NOT EXISTS idx_partes_no_borrados ON public.partes_diarios (id) WHERE borrado_en IS NULL;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Función RPC · soft-delete con justificación obligatoria
-- ─────────────────────────────────────────────────────────────────────────────
-- Se llama desde el frontend cuando jefe_zona (o admin) borra con motivo.
-- La función valida:
--   - Motivo con longitud mínima (10 caracteres).
--   - Que el user tenga rol admin o jefe_zona.
--   - Que el registro pertenezca a su zona (si es jefe_zona).
-- Devuelve el id del registro marcado como borrado, o error si algo falla.

CREATE OR REPLACE FUNCTION public.soft_delete_relevamiento(
  p_id BIGINT,
  p_motivo TEXT
) RETURNS BIGINT
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rol TEXT;
  v_zona TEXT;
  v_reg_zona TEXT;
BEGIN
  IF p_motivo IS NULL OR LENGTH(TRIM(p_motivo)) < 10 THEN
    RAISE EXCEPTION 'Motivo obligatorio (mínimo 10 caracteres)';
  END IF;

  v_rol  := current_user_rol();
  v_zona := current_user_zona();

  IF v_rol NOT IN ('admin', 'jefe_zona') THEN
    RAISE EXCEPTION 'Rol % no autorizado para borrar', v_rol;
  END IF;

  SELECT zona INTO v_reg_zona FROM public.relevamientos WHERE id = p_id;
  IF v_reg_zona IS NULL THEN
    RAISE EXCEPTION 'Registro % no existe', p_id;
  END IF;

  IF v_rol = 'jefe_zona' AND v_reg_zona <> v_zona THEN
    RAISE EXCEPTION 'jefe_zona solo puede borrar registros de su zona (% vs %)', v_reg_zona, v_zona;
  END IF;

  UPDATE public.relevamientos
     SET borrado_en     = NOW(),
         borrado_por    = auth.uid(),
         motivo_borrado = p_motivo
   WHERE id = p_id
     AND borrado_en IS NULL;

  RETURN p_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.soft_delete_relevamiento(BIGINT, TEXT) TO authenticated;

-- Misma función para partes_diarios
CREATE OR REPLACE FUNCTION public.soft_delete_parte_diario(
  p_id BIGINT,
  p_motivo TEXT
) RETURNS BIGINT
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rol TEXT;
  v_zona TEXT;
  v_reg_zona TEXT;
BEGIN
  IF p_motivo IS NULL OR LENGTH(TRIM(p_motivo)) < 10 THEN
    RAISE EXCEPTION 'Motivo obligatorio (mínimo 10 caracteres)';
  END IF;

  v_rol  := current_user_rol();
  v_zona := current_user_zona();

  IF v_rol NOT IN ('admin', 'jefe_zona') THEN
    RAISE EXCEPTION 'Rol % no autorizado para borrar', v_rol;
  END IF;

  SELECT zona INTO v_reg_zona FROM public.partes_diarios WHERE id = p_id;
  IF v_reg_zona IS NULL THEN
    RAISE EXCEPTION 'Parte % no existe', p_id;
  END IF;

  IF v_rol = 'jefe_zona' AND v_reg_zona <> v_zona THEN
    RAISE EXCEPTION 'jefe_zona solo puede borrar partes de su zona (% vs %)', v_reg_zona, v_zona;
  END IF;

  UPDATE public.partes_diarios
     SET borrado_en     = NOW(),
         borrado_por    = auth.uid(),
         motivo_borrado = p_motivo
   WHERE id = p_id
     AND borrado_en IS NULL;

  RETURN p_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.soft_delete_parte_diario(BIGINT, TEXT) TO authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) relevamientos · rehacer policies con la matriz consolidada
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS relev_read_zonal   ON public.relevamientos;
DROP POLICY IF EXISTS relev_insert_zonal ON public.relevamientos;
DROP POLICY IF EXISTS relev_update_zonal ON public.relevamientos;
DROP POLICY IF EXISTS relev_delete_zonal ON public.relevamientos;

-- SELECT: excluye borrados para todos excepto admin.
CREATE POLICY relev_read_zonal ON public.relevamientos
  FOR SELECT USING (
    (current_user_rol() = 'admin')  -- admin ve todo incluyendo borrados
    OR (
      borrado_en IS NULL AND (
           current_user_rol() = 'gerencia'
        OR (current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
        OR (current_user_es_lector_zonal()    AND (zona = current_user_zona() OR zona IS NULL))
        OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
      )
    )
  );

-- INSERT: admin, operativo_zonal (en su zona). Gerencia NO. Lectores NO.
CREATE POLICY relev_insert_zonal ON public.relevamientos
  FOR INSERT WITH CHECK (
       current_user_rol() = 'admin'
    OR (current_user_es_operativo_zonal() AND zona = current_user_zona())
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

-- UPDATE: admin, operativo_zonal (su zona). No permite reactivar registros borrados (excepto admin).
CREATE POLICY relev_update_zonal ON public.relevamientos
  FOR UPDATE USING (
       current_user_rol() = 'admin'
    OR (borrado_en IS NULL AND current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  ) WITH CHECK (
       current_user_rol() = 'admin'
    OR (current_user_es_operativo_zonal() AND zona = current_user_zona())
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

-- DELETE HARD: SOLO admin. jefe_zona usa soft_delete_relevamiento() RPC.
CREATE POLICY relev_delete_zonal ON public.relevamientos
  FOR DELETE USING (
    current_user_rol() = 'admin'
  );


-- ─────────────────────────────────────────────────────────────────────────────
-- 5) partes_diarios · misma matriz
-- ─────────────────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS partes_read_zonal   ON public.partes_diarios;
DROP POLICY IF EXISTS partes_insert_zonal ON public.partes_diarios;
DROP POLICY IF EXISTS partes_update_zonal ON public.partes_diarios;
DROP POLICY IF EXISTS partes_delete_zonal ON public.partes_diarios;

CREATE POLICY partes_read_zonal ON public.partes_diarios
  FOR SELECT USING (
    (current_user_rol() = 'admin')
    OR (
      borrado_en IS NULL AND (
           current_user_rol() = 'gerencia'
        OR (current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
        OR (current_user_es_lector_zonal()    AND (zona = current_user_zona() OR zona IS NULL))
        OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
      )
    )
  );

CREATE POLICY partes_insert_zonal ON public.partes_diarios
  FOR INSERT WITH CHECK (
       current_user_rol() = 'admin'
    OR (current_user_es_operativo_zonal() AND zona = current_user_zona())
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

CREATE POLICY partes_update_zonal ON public.partes_diarios
  FOR UPDATE USING (
       current_user_rol() = 'admin'
    OR (borrado_en IS NULL AND current_user_es_operativo_zonal() AND (zona = current_user_zona() OR zona IS NULL))
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  ) WITH CHECK (
       current_user_rol() = 'admin'
    OR (current_user_es_operativo_zonal() AND zona = current_user_zona())
    OR (auth.role() = 'authenticated' AND current_user_rol() IS NULL)
  );

CREATE POLICY partes_delete_zonal ON public.partes_diarios
  FOR DELETE USING (
    current_user_rol() = 'admin'
  );


-- ─────────────────────────────────────────────────────────────────────────────
-- 6) Vista de auditoría · los borrados vistos por admin
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.v_borrados_auditoria AS
  SELECT 'relevamientos' AS tabla, r.id, r.zona, r.tipo, r.ruta, r.progresiva, r.partido,
         r.borrado_en, r.borrado_por, up.nombre AS borrado_por_nombre, r.motivo_borrado
    FROM public.relevamientos r
    LEFT JOIN public.usuarios_perfil up ON up.user_id = r.borrado_por
   WHERE r.borrado_en IS NOT NULL
  UNION ALL
  SELECT 'partes_diarios' AS tabla, p.id, p.zona, NULL::TEXT AS tipo, p.ruta, NULL::TEXT AS progresiva, p.partido,
         p.borrado_en, p.borrado_por, up.nombre AS borrado_por_nombre, p.motivo_borrado
    FROM public.partes_diarios p
    LEFT JOIN public.usuarios_perfil up ON up.user_id = p.borrado_por
   WHERE p.borrado_en IS NOT NULL
   ORDER BY 8 DESC;  -- por borrado_en descendente

ALTER VIEW public.v_borrados_auditoria SET (security_invoker = true);
GRANT SELECT ON public.v_borrados_auditoria TO authenticated;


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
-- Policies actualizadas:
SELECT tablename, policyname, cmd FROM pg_policies
 WHERE tablename IN ('relevamientos','partes_diarios')
 ORDER BY tablename, cmd;

-- Columnas nuevas:
SELECT column_name FROM information_schema.columns
 WHERE table_schema='public' AND table_name='relevamientos'
   AND column_name LIKE 'borrado%' OR column_name = 'motivo_borrado';

-- Test como jefe_zona VI (correr con SET LOCAL request.jwt.claims si podés):
-- SELECT public.soft_delete_relevamiento(1, 'Test motivo con mas de 10 chars');
-- SELECT * FROM public.v_borrados_auditoria LIMIT 5;
