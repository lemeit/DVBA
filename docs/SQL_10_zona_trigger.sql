-- ═══════════════════════════════════════════════════════════════════════════════
-- SQL 10 · Trigger que fuerza zona = current_user_zona() para técnicos
-- v8.44 · Fase 3.5 · defensa server-side de la zona asignada a nuevos registros
--
-- PROBLEMA
--   La policy INSERT de SQL_9 exige que zona = current_user_zona() OR zona IS NULL
--   para técnicos. Pero un técnico que mande zona='VI' explícito PUEDE llegar a
--   pasar (posibles race conditions con current_user_rol(), o el frontend
--   hardcodeaba zona:'VI'). Además el frontend queda con lógica dispersa
--   ("qué zona mando").
--
-- SOLUCIÓN
--   Trigger BEFORE INSERT/UPDATE que sobrescribe NEW.zona con current_user_zona()
--   cuando el user es técnico. Admin y gerencia respetan lo enviado (para
--   permitirles cargar registros en cualquier zona si hace falta administrar).
--
--   Efecto neto:
--   - Técnico IV manda zona='VI' → el trigger lo pisa a 'IV'
--   - Técnico IV manda zona=NULL → el trigger lo pisa a 'IV'
--   - Admin manda zona='VI' → respeta 'VI' (control manual)
--   - Admin manda zona=NULL → queda NULL (comportamiento actual)
--
--   Frontend puede simplificarse: dejar zona sin mandar (que la BD la asigne).
--
-- REQUISITOS PREVIOS
--   ✓ SQL_7 (usuarios_perfil + funciones current_user_zona / current_user_rol)
--   ✓ SQL_8 (columna zona en relevamientos y partes_diarios)
--   ✓ SQL_9 (RLS zonal activo)
--
-- ═══════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1) Función auxiliar del trigger
-- ═══════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION forzar_zona_por_rol()
RETURNS TRIGGER AS $$
DECLARE
  rol_actual TEXT;
  zona_actual TEXT;
BEGIN
  rol_actual  := current_user_rol();
  zona_actual := current_user_zona();

  -- Sólo forzar para técnicos con zona asignada. Admin y gerencia respetan el
  -- valor enviado. Usuarios sin perfil (rol NULL) también quedan sin tocar
  -- (para no romper flujos legacy).
  IF rol_actual = 'tecnico' AND zona_actual IS NOT NULL THEN
    NEW.zona := zona_actual;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 2) Triggers en las 2 tablas principales
-- ═══════════════════════════════════════════════════════════════════════════════
DROP TRIGGER IF EXISTS trg_relev_forzar_zona ON relevamientos;
CREATE TRIGGER trg_relev_forzar_zona
  BEFORE INSERT OR UPDATE OF zona ON relevamientos
  FOR EACH ROW
  EXECUTE FUNCTION forzar_zona_por_rol();

DROP TRIGGER IF EXISTS trg_partes_forzar_zona ON partes_diarios;
CREATE TRIGGER trg_partes_forzar_zona
  BEFORE INSERT OR UPDATE OF zona ON partes_diarios
  FOR EACH ROW
  EXECUTE FUNCTION forzar_zona_por_rol();

-- ═══════════════════════════════════════════════════════════════════════════════
-- 3) Corregir el registro #377 que quedó mal etiquetado (era del técnico IV)
--    Se hace como admin (bypasea el trigger porque admin manda zona explícito).
-- ═══════════════════════════════════════════════════════════════════════════════
-- Descomentar si el registro sigue mal etiquetado:
-- UPDATE relevamientos SET zona = 'IV' WHERE id = 377;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════════
-- 4) VERIFICACIÓN
-- ═══════════════════════════════════════════════════════════════════════════════

-- 4.1 · Ver que los triggers se crearon
SELECT event_object_table AS tabla, trigger_name, action_timing, event_manipulation
FROM information_schema.triggers
WHERE trigger_name LIKE 'trg_%_forzar_zona'
ORDER BY tabla;

-- 4.2 · Ver la función
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'forzar_zona_por_rol';

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROLLBACK · si algo sale mal
-- ═══════════════════════════════════════════════════════════════════════════════
/*
BEGIN;
DROP TRIGGER IF EXISTS trg_relev_forzar_zona  ON relevamientos;
DROP TRIGGER IF EXISTS trg_partes_forzar_zona ON partes_diarios;
DROP FUNCTION IF EXISTS forzar_zona_por_rol();
COMMIT;
*/
