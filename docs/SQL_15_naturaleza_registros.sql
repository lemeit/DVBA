-- ═════════════════════════════════════════════════════════════════════════
-- SQL_15 · Modelo Tipos v2 — columna "naturaleza" en relevamientos
-- ═════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-14
-- Motivo: separar formalmente dos tipos de registro sobre el mismo
--         elemento vial:
--
--   'relevamiento' — se observa el estado del elemento (bache, mojón
--                    faltante, cuneta obstruida, puente con fisura...).
--                    Estados: bueno / regular / malo / critico / etc.
--
--   'tarea'        — se registra una acción de mantenimiento ejecutada
--                    o programada sobre el elemento (bacheo, colocación
--                    de cebras, reposición de señal, desmalezado...).
--                    Estados: programado / en_ejecucion / finalizado /
--                             suspendido / cancelado.
--
-- Compatibilidad:
--   - DEFAULT 'relevamiento' → los registros históricos, que no traían
--     la columna, quedan como relevamiento (que es lo que eran de facto).
--   - No hay migración destructiva. Los registros con categoria =
--     'mantenimiento' del modelo viejo mantienen su naturaleza como
--     'relevamiento' salvo que el usuario los reclasifique manualmente.
--   - El frontend nuevo (Modelo Tipos v2) escribe naturaleza explícita
--     en todos los INSERT nuevos.
-- ═════════════════════════════════════════════════════════════════════════

-- 1. Agregar la columna con default seguro
ALTER TABLE relevamientos
  ADD COLUMN IF NOT EXISTS naturaleza TEXT NOT NULL DEFAULT 'relevamiento';

-- 2. Constraint de valores válidos
ALTER TABLE relevamientos
  DROP CONSTRAINT IF EXISTS relevamientos_naturaleza_check;

ALTER TABLE relevamientos
  ADD CONSTRAINT relevamientos_naturaleza_check
  CHECK (naturaleza IN ('relevamiento', 'tarea'));

-- 3. Índice para filtros por naturaleza en reportes
CREATE INDEX IF NOT EXISTS idx_relevamientos_naturaleza
  ON relevamientos (naturaleza);

-- 4. Comentario en la columna
COMMENT ON COLUMN relevamientos.naturaleza IS
  'Naturaleza del registro: relevamiento (observación de estado) o tarea (mantenimiento ejecutado/programado). Modelo Tipos v2.';

-- ═════════════════════════════════════════════════════════════════════════
-- Verificación post-migración (informativa, no ejecutiva)
-- ═════════════════════════════════════════════════════════════════════════
-- SELECT naturaleza, COUNT(*) FROM relevamientos GROUP BY naturaleza;
-- Debería mostrar TODO como 'relevamiento' inicialmente (DEFAULT aplicado
-- retroactivamente a los registros existentes).
