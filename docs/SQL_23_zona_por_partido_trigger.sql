-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_23 · Trigger: zona se deriva del partido (no del rol del que carga)
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Autor: DVBA Zona VI Saladillo
--
-- PROBLEMA CONCEPTUAL
--   Hasta SQL_20 el trigger forzar_zona_por_rol() PISABA la zona con la del
--   usuario que carga. Eso significa: si un capataz VI viaja a Junín y carga
--   un bache, el trigger le pone zona='VI' y el jefe IV NUNCA lo ve, aunque
--   geográficamente pertenece a IV.
--
--   La zona debe ser la del PARTIDO GEOGRÁFICO donde ocurrió el registro,
--   no la del que lo cargó. Así cualquier agente DVBA puede recorrer la PBA
--   y sus registros llegan automáticamente al jefe de la zona correspondiente.
--
-- NUEVA LÓGICA
--   1. Si NEW.partido matchea con partidos_zona → NEW.zona := zona del partido.
--   2. Si NEW.partido no matchea (mal escrito, vacío, o partido desconocido)
--      Y el usuario es operativo zonal (tiene zona propia) → NEW.zona :=
--      current_user_zona() (fallback conservador · no bloquea INSERT).
--   3. Si NEW.partido no matchea y no hay current_user_zona (admin/gerencia)
--      → NEW.zona queda como venga (NULL o lo que el usuario mandó).
--
--   Los usuarios pueden seguir mandando zona explícita si son admin/gerencia
--   (para carga administrativa manual de registros huérfanos).
--
-- REQUISITOS PREVIOS
--   ✓ SQL_20 (trigger anterior)
--   ✓ SQL_22 (tabla partidos_zona + función zona_por_partido)
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

CREATE OR REPLACE FUNCTION forzar_zona_por_rol()
RETURNS TRIGGER AS $$
DECLARE
  rol_actual TEXT;
  zona_actual TEXT;
  zona_geo TEXT;
BEGIN
  rol_actual  := current_user_rol();
  zona_actual := current_user_zona();

  -- 1) Prioridad máxima: derivar de partido si es reconocido
  IF NEW.partido IS NOT NULL AND TRIM(NEW.partido) <> '' THEN
    zona_geo := zona_por_partido(NEW.partido);
    IF zona_geo IS NOT NULL THEN
      NEW.zona := zona_geo;
      RETURN NEW;
    END IF;
  END IF;

  -- 2) Fallback: si el user tiene zona operativa, usar esa (no dejar NULL)
  IF rol_actual IN (
       'tecnico', 'capataz',
       'jefe_zona', 'jefe_tecnica', 'jefe_operativa',
       'jefe_administrativa', 'jefe_automotores'
     ) AND zona_actual IS NOT NULL THEN
    NEW.zona := zona_actual;
    RETURN NEW;
  END IF;

  -- 3) Admin/gerencia sin partido reconocible → respetar lo que envían
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Los triggers ya están creados en SQL_10, solo cambia la función que ejecutan.
-- Verificar que estén activos:
--   SELECT event_object_table, trigger_name FROM information_schema.triggers
--   WHERE trigger_name LIKE 'trg_%_forzar_zona';

COMMIT;

-- ═════════════════════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ═════════════════════════════════════════════════════════════════════════════
-- Después de correr esto:
--
--   Capataz VI cargando bache en partido 'Junín':
--     INSERT INTO relevamientos (partido, ruta, tipo, naturaleza) VALUES
--       ('Junín', '65', 'Bacheo', 'relevamiento');
--     → NEW.zona = 'IV' (auto, porque Junín pertenece a IV)
--     → Aparece en la cola del jefe IV, NO en la del jefe VI.
--
--   Jefe VI cargando en '25 de Mayo' (alias de Veinticinco):
--     → NEW.zona = 'VI' (por alias)
--
--   Admin cargando sin partido:
--     → NEW.zona respeta lo que el admin manda (o NULL si no manda nada).
--
-- CONSIDERACIÓN
--   Como el registro AHORA cae en la zona geográfica, el que lo cargó no
--   necesariamente puede verlo después (la RLS filtra por su propia zona).
--   Si necesitamos que el autor pueda ver sus propios registros aunque estén
--   fuera de su zona, hay que agregar columna autor_id + policy extra.
-- ═════════════════════════════════════════════════════════════════════════════
