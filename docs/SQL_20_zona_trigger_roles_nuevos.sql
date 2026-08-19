-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_20 · Ampliar trigger forzar_zona_por_rol para todos los roles operativos
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   SQL_10 creó el trigger forzar_zona_por_rol() que setea NEW.zona =
--   current_user_zona() al insertar. Pero SOLO lo hace para rol='tecnico'.
--
--   Al agregar los roles de SQL_17 (capataz, jefe_zona, jefe_tecnica,
--   jefe_operativa, etc.), estos roles NO disparan el trigger. Resultado:
--   NEW.zona queda NULL, y la policy INSERT (con WITH CHECK
--   "zona = current_user_zona()") rechaza el INSERT con error 42501
--   "new row violates row-level security policy".
--
--   Este SQL amplía el trigger a todos los roles operativos zonales.
--   Admin y gerencia siguen respetando el valor enviado (para poder
--   cargar registros en cualquier zona si hace falta).
--
-- REQUISITOS PREVIOS
--   ✓ SQL_10 (trigger base)
--   ✓ SQL_17 (roles nuevos)
--   ✓ SQL_19 (policies ampliadas — para que INSERT acepte los nuevos roles)
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- Reemplazamos la función para incluir todos los roles operativos zonales.
CREATE OR REPLACE FUNCTION forzar_zona_por_rol()
RETURNS TRIGGER AS $$
DECLARE
  rol_actual TEXT;
  zona_actual TEXT;
BEGIN
  rol_actual  := current_user_rol();
  zona_actual := current_user_zona();

  -- v8.82 · Ampliado: todos los roles operativos zonales fuerzan su zona.
  -- Admin y gerencia respetan el valor enviado (para poder cargar en
  -- cualquier zona si necesitan administrar).
  -- Usuarios sin perfil (rol NULL) también quedan sin tocar (compat legacy).
  IF rol_actual IN (
       'tecnico', 'capataz',
       'jefe_zona', 'jefe_tecnica', 'jefe_operativa',
       'jefe_administrativa', 'jefe_automotores'
     ) AND zona_actual IS NOT NULL THEN
    NEW.zona := zona_actual;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

COMMIT;

-- ═════════════════════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ═════════════════════════════════════════════════════════════════════════════
-- Después de correr esto, un jefe_tecnica VI que haga INSERT en relevamientos
-- SIN mandar zona debería ver zona='VI' auto-completada por el trigger.
--
-- Test:
--   SET LOCAL request.jwt.claims TO '{"sub":"<UID_jefetecnica_vi>"}';
--   INSERT INTO relevamientos (ruta, tipo, naturaleza) VALUES ('30', 'test', 'relevamiento');
--   SELECT id, zona FROM relevamientos ORDER BY id DESC LIMIT 1;  -- debe ser 'VI'
-- ═════════════════════════════════════════════════════════════════════════════
