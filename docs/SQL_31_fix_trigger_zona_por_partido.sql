-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_31 · Fix trigger forzar_zona_por_rol · restaurar lógica SQL_23 (zona por partido)
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-31
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   Diagnóstico reveló que el trigger `forzar_zona_por_rol` quedó en la
--   versión SQL_20 (que solo hace NEW.zona := current_user_zona() para
--   roles operativos zonales) en lugar de la versión SQL_23 (que deriva
--   zona del partido usando zona_por_partido).
--
--   Efecto observado en producción:
--   - Admin carga foto en partido "Saladillo" → zona queda NULL (admin no
--     está en el IF de operativos zonales).
--   - Admin envía zona="PBA" desde el picker → trigger no lo pisa, zona
--     queda "PBA" (que no es una zona vial válida).
--   - Registros invisibles desde vistas por zona específica.
--
-- SOLUCIÓN
--   1. Recrear forzar_zona_por_rol con la lógica correcta:
--      · Prioridad 1: derivar de partido via zona_por_partido().
--      · Prioridad 2: fallback a current_user_zona() para operativos zonales.
--      · Prioridad 3: rechazar zona='PBA' explícitamente (no es zona real).
--      · Prioridad 4: admin/gerencia sin partido → NEW.zona respeta lo enviado.
--   2. Retro-fill de los registros históricos con zona=NULL o zona='PBA'
--      que tengan partido reconocible.
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Recrear el trigger con la lógica SQL_23 (zona por partido geográfico)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.forzar_zona_por_rol()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
DECLARE
  rol_actual  TEXT;
  zona_actual TEXT;
  zona_geo    TEXT;
BEGIN
  rol_actual  := current_user_rol();
  zona_actual := current_user_zona();

  -- Normalizar: "PBA" no es una zona vial válida (es la vista panorámica del picker).
  -- Si viene "PBA", tratarlo como NULL para que la lógica siguiente lo resuelva.
  IF NEW.zona = 'PBA' THEN
    NEW.zona := NULL;
  END IF;

  -- Prioridad 1: derivar zona del partido si es reconocible.
  IF NEW.partido IS NOT NULL AND TRIM(NEW.partido) <> '' THEN
    zona_geo := zona_por_partido(NEW.partido);
    IF zona_geo IS NOT NULL THEN
      NEW.zona := zona_geo;
      RETURN NEW;
    END IF;
  END IF;

  -- Prioridad 2: si el user es operativo zonal, usar su zona.
  IF rol_actual IN (
       'tecnico', 'capataz',
       'jefe_zona', 'jefe_tecnica', 'jefe_operativa',
       'jefe_administrativa', 'jefe_automotores'
     ) AND zona_actual IS NOT NULL THEN
    NEW.zona := zona_actual;
    RETURN NEW;
  END IF;

  -- Prioridad 3: admin/gerencia sin partido reconocible → respetar lo enviado
  -- (puede ser NULL si el frontend no lo pobló). Ya no puede ser 'PBA' por
  -- el guard al inicio.
  RETURN NEW;
END;
$$;

-- Los triggers existentes siguen apuntando a esta función (mismo nombre),
-- no hace falta drop/create trigger.

REVOKE EXECUTE ON FUNCTION public.forzar_zona_por_rol() FROM PUBLIC, anon, authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Retro-fill · corregir registros existentes
-- ─────────────────────────────────────────────────────────────────────────────
-- Registros con partido reconocible pero zona incorrecta (NULL o 'PBA')
-- se corrigen a la zona geográfica correcta.

UPDATE public.relevamientos
   SET zona = zona_por_partido(partido)
 WHERE partido IS NOT NULL
   AND (zona IS NULL OR zona = 'PBA')
   AND zona_por_partido(partido) IS NOT NULL;

UPDATE public.partes_diarios
   SET zona = zona_por_partido(partido)
 WHERE partido IS NOT NULL
   AND (zona IS NULL OR zona = 'PBA')
   AND zona_por_partido(partido) IS NOT NULL;

-- Registros con zona='PBA' sin partido reconocible → dejar NULL (más honesto
-- que un valor falso). Admin puede corregir a mano después si sabe la zona.
UPDATE public.relevamientos SET zona = NULL WHERE zona = 'PBA';
UPDATE public.partes_diarios SET zona = NULL WHERE zona = 'PBA';


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────

-- 1) Ver los últimos registros de hoy con zona corregida:
SELECT id, fecha, ruta, partido, zona, autor_rol, foto_url IS NOT NULL AS con_foto
  FROM relevamientos
 WHERE fecha::date >= (CURRENT_DATE - INTERVAL '1 day')
 ORDER BY id DESC
 LIMIT 15;

-- 2) Distribución final por zona (no debería quedar ninguna 'PBA'):
SELECT zona, COUNT(*) FROM relevamientos GROUP BY zona ORDER BY 2 DESC;

-- 3) Test del trigger post-fix (correr como user autenticado, no como postgres):
-- BEGIN;
-- INSERT INTO relevamientos (fecha, ruta, partido, progresiva, tipo, naturaleza)
-- VALUES (NOW(), 'RP 51', 'Veinticinco de Mayo', '0+000', 'test-trigger', 'relevamiento')
-- RETURNING id, zona;  -- debe ser 'VI'
-- ROLLBACK;
