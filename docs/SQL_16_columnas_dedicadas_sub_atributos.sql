-- ═════════════════════════════════════════════════════════════════════════
-- SQL_16 · Migración sub-atributos serializados → columnas dedicadas
-- ═════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-18
-- Motivo: hasta v8.77 los sub-atributos "superficie" (asfalto/hormigón/tierra/
--         estabilizado/dolomita/suelo_cal) y "modalidad" (manual/mecánico/mixto)
--         se guardaban al final del campo `observaciones` con el formato:
--
--             <texto libre del user>
--
--             [superficie:asfalto · modalidad:mecanico]
--
--         Funciona pero impide cruzar en reportes agregados. Esta migración
--         crea columnas dedicadas, hace backfill desde el texto y limpia el
--         sufijo del campo observaciones para dejar historial consistente.
--
-- Retrocompatible con el frontend v8.77 y anterior: no rompe nada porque el
-- código viejo sigue guardando el sufijo en observaciones (lo va a pisar el
-- nuevo frontend que escribe en columnas + observaciones limpio).
-- ═════════════════════════════════════════════════════════════════════════

-- 1. Agregar columnas nuevas (nullables, sin default — solo aplica a los que corresponda)
ALTER TABLE relevamientos ADD COLUMN IF NOT EXISTS superficie TEXT;
ALTER TABLE relevamientos ADD COLUMN IF NOT EXISTS modalidad  TEXT;

-- 2. Constraint de valores válidos (según DVBA_ESTADOS)
ALTER TABLE relevamientos DROP CONSTRAINT IF EXISTS relevamientos_superficie_check;
ALTER TABLE relevamientos ADD CONSTRAINT relevamientos_superficie_check
  CHECK (superficie IS NULL OR superficie IN
    ('asfalto','hormigon','tierra','estabilizado','dolomita','suelo_cal'));

ALTER TABLE relevamientos DROP CONSTRAINT IF EXISTS relevamientos_modalidad_check;
ALTER TABLE relevamientos ADD CONSTRAINT relevamientos_modalidad_check
  CHECK (modalidad IS NULL OR modalidad IN ('manual','mecanico','mixto'));

-- 3. Índices para filtros agregados en reportes
CREATE INDEX IF NOT EXISTS idx_relevamientos_superficie ON relevamientos (superficie) WHERE superficie IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_relevamientos_modalidad  ON relevamientos (modalidad)  WHERE modalidad IS NOT NULL;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. BACKFILL · extraer valores del texto de observaciones y limpiar sufijo
-- ═════════════════════════════════════════════════════════════════════════
--
-- Formato esperado del sufijo (case-sensitive, ambos son opcionales):
--   [superficie:X]
--   [modalidad:Y]
--   [superficie:X · modalidad:Y]
--
-- El separador es " · " (con espacios). El sufijo siempre está al final del
-- campo observaciones. La regex captura el bloque entero para poder limpiarlo.
-- ═════════════════════════════════════════════════════════════════════════

-- 4a. Extraer superficie
-- Nota: usamos `substring(text FROM pattern)` (scalar) en vez de
-- `regexp_matches` (set-returning function, no permitida en UPDATE en PG14+).
UPDATE relevamientos
SET superficie = LOWER(substring(observaciones FROM 'superficie:(\w+)'))
WHERE observaciones ~* 'superficie:(\w+)'
  AND superficie IS NULL;

-- 4b. Extraer modalidad
UPDATE relevamientos
SET modalidad = LOWER(substring(observaciones FROM 'modalidad:(\w+)'))
WHERE observaciones ~* 'modalidad:(\w+)'
  AND modalidad IS NULL;

-- 4c. Limpiar el sufijo `[...]` al final del campo observaciones.
-- Regex: opcionalmente uno o dos saltos de línea, luego `[`, luego cualquier
-- contenido hasta `]` que sea el fin del string. Case-insensitive.
UPDATE relevamientos
SET observaciones = TRIM(BOTH E'\n\t ' FROM
      regexp_replace(observaciones, E'\\s*\\[[^\\]]*\\]\\s*$', '', 'g'))
WHERE observaciones ~ E'\\[[^\\]]*\\]\\s*$'
  AND observaciones ~* '(superficie|modalidad):';

-- 4d. Si observaciones queda vacío después de limpiar, dejarlo NULL
UPDATE relevamientos
SET observaciones = NULL
WHERE observaciones = '' OR observaciones ~ '^\s*$';

-- 5. Comentarios en las columnas nuevas
COMMENT ON COLUMN relevamientos.superficie IS
  'Tipo de superficie física (asfalto/hormigon/tierra/estabilizado/dolomita/suelo_cal). Aplica a calzada y a tareas sobre calzada/entorno. Migración SQL_16.';
COMMENT ON COLUMN relevamientos.modalidad IS
  'Modalidad de ejecución (manual/mecanico/mixto). Aplica solo cuando naturaleza=tarea. Migración SQL_16.';

-- ═════════════════════════════════════════════════════════════════════════
-- Verificación post-migración (informativa)
-- ═════════════════════════════════════════════════════════════════════════
-- SELECT superficie, COUNT(*) FROM relevamientos GROUP BY superficie ORDER BY 2 DESC;
-- SELECT modalidad,  COUNT(*) FROM relevamientos GROUP BY modalidad  ORDER BY 2 DESC;
-- SELECT COUNT(*) FROM relevamientos WHERE observaciones ~* '\[(superficie|modalidad):';
--   → Debería devolver 0 (ya no queda sufijo en el texto).
