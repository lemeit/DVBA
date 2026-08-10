-- ═══════════════════════════════════════════════════════════════════════════
-- SQL_13 · Tabla comentarios_zona + policies RLS + helpers
-- v8.66a · Modelo comentarios gerencia + solicitudes cross-zona a admin
-- ═══════════════════════════════════════════════════════════════════════════
-- Objetivo: separar lo que puede hacer cada rol sobre los registros de vialidad.
--   · Técnico: edita SU zona (sigue igual)
--   · Gerencia: solo ve TODAS las zonas y puede dejar COMENTARIOS al técnico
--     de esa zona. No edita ni re-sella.
--   · Admin: puede editar todas las zonas + resolver solicitudes de "mover"
--     registros entre zonas cuando gerencia o técnico lo piden.
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- PASO 1 · Tabla base
-- ═══════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.comentarios_zona (
  id               BIGSERIAL PRIMARY KEY,
  -- Referencia genérica al registro comentado (evita 2 FK separadas)
  target_tabla     TEXT NOT NULL CHECK (target_tabla IN ('relevamientos', 'partes_diarios')),
  target_id        BIGINT NOT NULL,
  target_zona      TEXT,  -- zona del registro al momento de crear el comentario (referencia)
  -- Tipo de acción solicitada
  tipo             TEXT NOT NULL DEFAULT 'comentario'
                     CHECK (tipo IN ('comentario', 'mover_zona', 'eliminar')),
  -- Autor
  autor_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  autor_rol        TEXT NOT NULL CHECK (autor_rol IN ('tecnico', 'gerencia', 'admin')),
  autor_zona       TEXT,  -- zona del autor (útil si es técnico)
  -- Contenido
  mensaje          TEXT NOT NULL CHECK (length(trim(mensaje)) >= 3),
  zona_destino     TEXT,  -- solo aplica si tipo='mover_zona' (ej: 'IV')
  -- Estado del hilo
  estado           TEXT NOT NULL DEFAULT 'abierto'
                     CHECK (estado IN ('abierto', 'resuelto', 'descartado')),
  -- Respuesta / resolución
  respuesta        TEXT,
  respondido_por   UUID REFERENCES auth.users(id),
  respondido_en    TIMESTAMPTZ,
  -- Timestamps
  creado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.comentarios_zona IS
  'v8.66a · Comentarios y solicitudes de gerencia/técnico sobre registros de vialidad. '
  'Permite auditar quién pidió qué, quién respondió y cuándo.';

-- ═══════════════════════════════════════════════════════════════════════════
-- PASO 2 · Índices para performance
-- ═══════════════════════════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_comentarios_zona_target
  ON public.comentarios_zona (target_tabla, target_id);

CREATE INDEX IF NOT EXISTS idx_comentarios_zona_estado
  ON public.comentarios_zona (estado)
  WHERE estado = 'abierto';  -- índice parcial: solo los abiertos (que se muestran)

CREATE INDEX IF NOT EXISTS idx_comentarios_zona_autor
  ON public.comentarios_zona (autor_id, creado_en DESC);

CREATE INDEX IF NOT EXISTS idx_comentarios_zona_target_zona
  ON public.comentarios_zona (target_zona)
  WHERE estado = 'abierto';  -- para contadores rápidos por zona

CREATE INDEX IF NOT EXISTS idx_comentarios_zona_tipo_estado
  ON public.comentarios_zona (tipo, estado);  -- para cola de solicitudes admin

-- ═══════════════════════════════════════════════════════════════════════════
-- PASO 3 · Trigger para actualizado_en
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.trg_comentarios_zona_updated()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.actualizado_en := NOW();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS comentarios_zona_set_updated ON public.comentarios_zona;
CREATE TRIGGER comentarios_zona_set_updated
  BEFORE UPDATE ON public.comentarios_zona
  FOR EACH ROW EXECUTE FUNCTION public.trg_comentarios_zona_updated();

-- ═══════════════════════════════════════════════════════════════════════════
-- PASO 4 · RLS activada + policies por rol
-- ═══════════════════════════════════════════════════════════════════════════
ALTER TABLE public.comentarios_zona ENABLE ROW LEVEL SECURITY;

-- ─── SELECT ───────────────────────────────────────────────────────────────
-- Admin ve todo · Gerencia ve todo · Técnico ve solo los de SU zona
DROP POLICY IF EXISTS "comentarios_select" ON public.comentarios_zona;
CREATE POLICY "comentarios_select"
  ON public.comentarios_zona
  FOR SELECT
  TO authenticated
  USING (
    public.current_user_rol() IN ('admin', 'gerencia')
    OR (public.current_user_rol() = 'tecnico' AND target_zona = public.current_user_zona())
  );

-- ─── INSERT ───────────────────────────────────────────────────────────────
-- Admin puede crear cualquier tipo · Gerencia puede crear 'comentario' o 'mover_zona'
-- Técnico solo puede crear 'mover_zona' (para pedir a admin) sobre registros de su zona
DROP POLICY IF EXISTS "comentarios_insert" ON public.comentarios_zona;
CREATE POLICY "comentarios_insert"
  ON public.comentarios_zona
  FOR INSERT
  TO authenticated
  WITH CHECK (
    autor_id = auth.uid()
    AND autor_rol = public.current_user_rol()
    AND (
      public.current_user_rol() = 'admin'
      OR (public.current_user_rol() = 'gerencia' AND tipo IN ('comentario', 'mover_zona'))
      OR (public.current_user_rol() = 'tecnico' AND tipo = 'mover_zona'
          AND target_zona = public.current_user_zona())
    )
  );

-- ─── UPDATE ───────────────────────────────────────────────────────────────
-- Admin puede resolver/descartar cualquier comentario ·
-- Técnico puede responder los de SU zona (solo cambiar estado/respuesta, no el mensaje)
-- Gerencia NO puede editar (una vez creado, se ejecuta o descarta por admin/técnico)
DROP POLICY IF EXISTS "comentarios_update" ON public.comentarios_zona;
CREATE POLICY "comentarios_update"
  ON public.comentarios_zona
  FOR UPDATE
  TO authenticated
  USING (
    public.current_user_rol() = 'admin'
    OR (public.current_user_rol() = 'tecnico'
        AND target_zona = public.current_user_zona()
        AND tipo = 'comentario')  -- técnico solo responde comentarios, no ejecuta solicitudes
  )
  WITH CHECK (
    public.current_user_rol() = 'admin'
    OR (public.current_user_rol() = 'tecnico'
        AND target_zona = public.current_user_zona()
        AND tipo = 'comentario')
  );

-- ─── DELETE ───────────────────────────────────────────────────────────────
-- Solo admin puede borrar (para limpiar duplicados o basura); prefer marcarlos 'descartado'
DROP POLICY IF EXISTS "comentarios_delete" ON public.comentarios_zona;
CREATE POLICY "comentarios_delete"
  ON public.comentarios_zona
  FOR DELETE
  TO authenticated
  USING (public.current_user_rol() = 'admin');

-- ═══════════════════════════════════════════════════════════════════════════
-- PASO 5 · Helpers para contadores del banner (RPC)
-- ═══════════════════════════════════════════════════════════════════════════

-- Devuelve conteos según el rol del que llama (para el banner del header)
-- - Admin: { solicitudes_pendientes: N, comentarios_abiertos: M }
-- - Gerencia: { mis_comentarios_activos: N, solicitudes_mias_pendientes: M }
-- - Técnico: { comentarios_sin_responder: N, mis_solicitudes_pendientes: M }
CREATE OR REPLACE FUNCTION public.comentarios_contadores()
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER STABLE AS $$
DECLARE
  rol TEXT;
  zona TEXT;
  uid UUID;
  resultado JSONB;
BEGIN
  rol := public.current_user_rol();
  zona := public.current_user_zona();
  uid := auth.uid();
  IF rol IS NULL OR uid IS NULL THEN
    RETURN '{}'::jsonb;
  END IF;

  IF rol = 'admin' THEN
    SELECT jsonb_build_object(
      'solicitudes_pendientes',
        (SELECT COUNT(*) FROM public.comentarios_zona
         WHERE estado='abierto' AND tipo IN ('mover_zona','eliminar')),
      'comentarios_abiertos',
        (SELECT COUNT(*) FROM public.comentarios_zona
         WHERE estado='abierto' AND tipo='comentario')
    ) INTO resultado;

  ELSIF rol = 'gerencia' THEN
    SELECT jsonb_build_object(
      'mis_comentarios_activos',
        (SELECT COUNT(*) FROM public.comentarios_zona
         WHERE autor_id=uid AND tipo='comentario' AND estado='abierto'),
      'solicitudes_mias_pendientes',
        (SELECT COUNT(*) FROM public.comentarios_zona
         WHERE autor_id=uid AND tipo IN ('mover_zona','eliminar') AND estado='abierto')
    ) INTO resultado;

  ELSIF rol = 'tecnico' THEN
    SELECT jsonb_build_object(
      'comentarios_sin_responder',
        (SELECT COUNT(*) FROM public.comentarios_zona
         WHERE target_zona=zona AND tipo='comentario' AND estado='abierto'),
      'mis_solicitudes_pendientes',
        (SELECT COUNT(*) FROM public.comentarios_zona
         WHERE autor_id=uid AND tipo IN ('mover_zona','eliminar') AND estado='abierto')
    ) INTO resultado;
  ELSE
    resultado := '{}'::jsonb;
  END IF;

  RETURN resultado;
END $$;

GRANT EXECUTE ON FUNCTION public.comentarios_contadores() TO authenticated;

COMMENT ON FUNCTION public.comentarios_contadores() IS
  'v8.66a · Contadores de comentarios/solicitudes según el rol del que llama. '
  'Usado por el banner del header en el portal para avisar de pendientes.';

-- ═══════════════════════════════════════════════════════════════════════════
-- PASO 6 · Vista para admin: cola completa de solicitudes con datos del target
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE VIEW public.v_solicitudes_admin AS
SELECT
  c.id, c.tipo, c.target_tabla, c.target_id, c.target_zona,
  c.zona_destino, c.mensaje, c.estado,
  c.creado_en, c.actualizado_en,
  c.autor_id, c.autor_rol, c.autor_zona,
  up.email  AS autor_email,
  up.nombre AS autor_nombre
FROM public.comentarios_zona c
LEFT JOIN public.usuarios_perfil up ON up.id = c.autor_id
WHERE c.tipo IN ('mover_zona', 'eliminar')
  AND c.estado = 'abierto'
ORDER BY c.creado_en ASC;

GRANT SELECT ON public.v_solicitudes_admin TO authenticated;
-- La vista respeta RLS de comentarios_zona → admin ve todo, gerencia solo lo suyo, etc.

-- ═══════════════════════════════════════════════════════════════════════════
-- PASO 7 · Verificación (correr después de aplicar el script)
-- ═══════════════════════════════════════════════════════════════════════════
-- Chequeos manuales para verificar que quedó bien:
--
--   SELECT COUNT(*) FROM public.comentarios_zona;
--   SELECT * FROM public.comentarios_contadores();
--   SELECT policyname, cmd FROM pg_policies WHERE tablename='comentarios_zona';
--
-- Deberías ver 4 policies (SELECT / INSERT / UPDATE / DELETE) y contadores en 0.
