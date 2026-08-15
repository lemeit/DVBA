-- SQL 7 · Tabla usuarios_perfil + funciones helper de rol/zona (v7.92)
--
-- Contexto: hoy toda auth.role() = 'authenticated' tiene acceso total.
-- Este SQL prepara el backend para el modelo de 4 niveles (público /
-- técnico de zona / gerencia / admin) documentado en docs/PLAN_ROLES_MULTIZONA.md.
--
-- Esta migración es SEGURA para correr en producción — solo agrega
-- objetos nuevos (tabla + funciones + trigger). NO toca las policies
-- vigentes: eso queda para SQL 9 (Fase 3 del plan). Después de correrla
-- el sistema sigue funcionando exactamente igual porque nada la usa aún.
--
-- Post-migración: insertar tu perfil manualmente (ver bloque al final).

BEGIN;

-- ═══════════════════════════════════════════════════════════════════
-- 1) Tabla usuarios_perfil
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS usuarios_perfil (
  user_id     UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre      TEXT NOT NULL,
  rol         TEXT NOT NULL CHECK (rol IN ('publico', 'tecnico', 'gerencia', 'admin')),
  zona        TEXT,  -- 'I'..'XII'. NULL para gerencia/admin (ven todas).
  activo      BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Regla de consistencia rol↔zona: los técnicos DEBEN tener zona;
  -- gerencia/admin la tienen opcional (típicamente NULL = todas).
  CONSTRAINT chk_zona_tecnico_obligatoria CHECK (
    (rol = 'tecnico' AND zona IS NOT NULL) OR (rol <> 'tecnico')
  )
);

CREATE INDEX IF NOT EXISTS idx_usuarios_perfil_zona ON usuarios_perfil(zona);
CREATE INDEX IF NOT EXISTS idx_usuarios_perfil_rol  ON usuarios_perfil(rol);

COMMENT ON TABLE  usuarios_perfil IS 'Perfil operativo del usuario. Extiende auth.users con rol y zona.';
COMMENT ON COLUMN usuarios_perfil.rol  IS 'publico|tecnico|gerencia|admin. Ver docs/PLAN_ROLES_MULTIZONA.md';
COMMENT ON COLUMN usuarios_perfil.zona IS 'Código romano de la zona (I..XII). NULL = ve todas (gerencia/admin).';

-- ═══════════════════════════════════════════════════════════════════
-- 2) Trigger para updated_at
-- ═══════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION _touch_updated_at() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_usuarios_perfil_updated ON usuarios_perfil;
CREATE TRIGGER trg_usuarios_perfil_updated
  BEFORE UPDATE ON usuarios_perfil
  FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();

-- ═══════════════════════════════════════════════════════════════════
-- 3) Funciones helper (security definer, stable — cacheable en el plan)
--
-- current_user_zona() → 'I'..'XII' o NULL (gerencia/admin/sin perfil)
-- current_user_rol()  → 'publico'|'tecnico'|'gerencia'|'admin' o NULL
--
-- Se usan en las RLS policies de SQL 9. Ejemplos:
--   USING (zona = current_user_zona() OR current_user_rol() IN ('gerencia','admin'))
-- ═══════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION current_user_zona() RETURNS TEXT
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
  SELECT zona FROM usuarios_perfil WHERE user_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION current_user_rol() RETURNS TEXT
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
  SELECT rol FROM usuarios_perfil WHERE user_id = auth.uid()
$$;

-- ═══════════════════════════════════════════════════════════════════
-- 4) RLS de la tabla usuarios_perfil (mínima y segura)
--
-- - Cualquier authenticated puede LEER su propio perfil (para que el
--   front cargue rol/zona al login).
-- - Solo admin puede INSERT/UPDATE/DELETE cualquier perfil.
-- - Para el bootstrap inicial (cuando aún no hay ningún admin) usar
--   el bloque final de este archivo con service_role.
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE usuarios_perfil ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS usuarios_perfil_self_read ON usuarios_perfil;
CREATE POLICY usuarios_perfil_self_read ON usuarios_perfil
  FOR SELECT USING (user_id = auth.uid() OR current_user_rol() = 'admin');

DROP POLICY IF EXISTS usuarios_perfil_admin_write ON usuarios_perfil;
CREATE POLICY usuarios_perfil_admin_write ON usuarios_perfil
  FOR ALL USING (current_user_rol() = 'admin')
        WITH CHECK (current_user_rol() = 'admin');

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- Verificación
-- ═══════════════════════════════════════════════════════════════════
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'usuarios_perfil'
ORDER BY ordinal_position;

SELECT routine_name FROM information_schema.routines
WHERE routine_name IN ('current_user_zona', 'current_user_rol', '_touch_updated_at');

-- ═══════════════════════════════════════════════════════════════════
-- BOOTSTRAP INICIAL · Insertar el primer admin
-- ═══════════════════════════════════════════════════════════════════
-- IMPORTANTE: correr este bloque UNA SOLA VEZ desde el SQL Editor de
-- Supabase (que usa service_role y bypasea RLS). Reemplazar '<UID>'
-- por tu user_id real, que sacás con:
--
--   SELECT id, email FROM auth.users WHERE email = 'admin.zonavi@vialidad.gba.gov.ar';
--
-- Después de este INSERT, cualquier cambio en usuarios_perfil requiere
-- estar logueado como admin.
--
-- INSERT INTO usuarios_perfil (user_id, nombre, rol, zona)
-- VALUES ('<UID>', 'Luciano Lamaita', 'admin', 'VI');
-- ═══════════════════════════════════════════════════════════════════
