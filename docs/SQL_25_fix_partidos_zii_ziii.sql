-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_25 · Fix asignación de partidos zonas II y III
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Motivo: CABECERAS.md original tenía 9 partidos en ZIII que en realidad
--   pertenecen a ZII. Fuente autoritativa: revisión Luciano 2026-08-19.
--
-- Partidos que se mueven de III → II:
--   38  Zárate
--   57  Tigre
--   94  San Andrés de Giles
--   95  San Antonio de Areco
--   96  San Fernando
--   97  San Isidro
--   110 Vicente López
--   117 Tres de Febrero
--   131 San Miguel
--
-- Efecto: ZII pasa de 17 → 26 partidos. ZIII pasa de 31 → 23 partidos.
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

UPDATE partidos_zona
   SET zona = 'II'
 WHERE partido_numero IN (38, 57, 94, 95, 96, 97, 110, 117, 131);

-- Retro-fill de registros históricos que quedaron mal etiquetados
UPDATE relevamientos
   SET zona = 'II'
 WHERE partido IN (
   'Zárate','Tigre','San Andrés de Giles','San Antonio de Areco',
   'San Fernando','San Isidro','Vicente López','Tres de Febrero','San Miguel'
 ) AND zona = 'III';

UPDATE partes_diarios
   SET zona = 'II'
 WHERE partido IN (
   'Zárate','Tigre','San Andrés de Giles','San Antonio de Areco',
   'San Fernando','San Isidro','Vicente López','Tres de Febrero','San Miguel'
 ) AND zona = 'III';

COMMIT;

-- Verificación
SELECT zona, COUNT(*) FROM partidos_zona GROUP BY zona ORDER BY zona;
-- Esperado: I=11, II=26, III=23, IV=9, V=6, VI=8, VII=11, VIII=12, IX=6, X=6, XI=11, XII=6
