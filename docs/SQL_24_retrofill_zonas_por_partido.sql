-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_24 · Retro-fill de registros existentes usando zona_por_partido()
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Autor: DVBA Zona VI Saladillo
--
-- OBJETIVO
--   Los registros ya cargados en `relevamientos` y `partes_diarios` tienen
--   la zona que se les asignó según el rol del que cargó (o quedaron NULL
--   por bug pre-multi-zona). Ahora que existe zona_por_partido() y el
--   trigger SQL_23, queremos re-asignar las zonas históricas al criterio
--   geográfico correcto.
--
-- ESTRATEGIA
--   Solo tocamos filas donde:
--     · partido NO es null ni vacío
--     · zona_por_partido(partido) devuelve un valor
--     · la zona actual difiere del valor calculado
--
--   Antes de aplicar los UPDATE, se muestra un PREVIEW por zona.
--
-- REQUISITOS PREVIOS
--   ✓ SQL_22 (tabla partidos_zona + función zona_por_partido)
-- ═════════════════════════════════════════════════════════════════════════════


-- ─────────────────────────────────────────────────────────────────────────────
-- 1. PREVIEW · registros que cambiarían de zona
-- ─────────────────────────────────────────────────────────────────────────────
-- Ejecutá primero este SELECT para ver el impacto:

SELECT 'relevamientos' AS tabla,
       zona AS zona_actual,
       zona_por_partido(partido) AS zona_geografica,
       COUNT(*) AS registros
FROM relevamientos
WHERE partido IS NOT NULL AND TRIM(partido) <> ''
  AND zona_por_partido(partido) IS NOT NULL
  AND (zona IS NULL OR zona <> zona_por_partido(partido))
GROUP BY zona, zona_por_partido(partido)
UNION ALL
SELECT 'partes_diarios',
       zona,
       zona_por_partido(partido),
       COUNT(*)
FROM partes_diarios
WHERE partido IS NOT NULL AND TRIM(partido) <> ''
  AND zona_por_partido(partido) IS NOT NULL
  AND (zona IS NULL OR zona <> zona_por_partido(partido))
GROUP BY zona, zona_por_partido(partido)
ORDER BY tabla, zona_actual NULLS FIRST, zona_geografica;

-- Preview de partidos sin match (para revisar aparte si hay muchos)
SELECT 'sin_match' AS tabla, partido, COUNT(*) AS cnt
FROM relevamientos
WHERE partido IS NOT NULL AND TRIM(partido) <> ''
  AND zona_por_partido(partido) IS NULL
GROUP BY partido
ORDER BY cnt DESC;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2. UPDATE · aplicar el retro-fill (correr después de revisar el preview)
-- ─────────────────────────────────────────────────────────────────────────────
-- Descomentar el BEGIN/COMMIT cuando estés listo para aplicarlo:

BEGIN;

UPDATE relevamientos
   SET zona = zona_por_partido(partido)
 WHERE partido IS NOT NULL AND TRIM(partido) <> ''
   AND zona_por_partido(partido) IS NOT NULL
   AND (zona IS NULL OR zona <> zona_por_partido(partido));

UPDATE partes_diarios
   SET zona = zona_por_partido(partido)
 WHERE partido IS NOT NULL AND TRIM(partido) <> ''
   AND zona_por_partido(partido) IS NOT NULL
   AND (zona IS NULL OR zona <> zona_por_partido(partido));

COMMIT;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. VERIFICACIÓN post-update
-- ─────────────────────────────────────────────────────────────────────────────

-- Breakdown final por zona
SELECT 'relevamientos' AS tabla, zona, COUNT(*) AS cnt
FROM relevamientos GROUP BY zona
UNION ALL
SELECT 'partes_diarios', zona, COUNT(*)
FROM partes_diarios GROUP BY zona
ORDER BY tabla, zona NULLS FIRST;

-- ¿Quedan registros huérfanos (zona NULL y sin partido reconocible)?
SELECT id, fecha, partido, ruta, tipo
FROM relevamientos
WHERE zona IS NULL
ORDER BY fecha DESC NULLS LAST
LIMIT 20;

-- ═════════════════════════════════════════════════════════════════════════════
-- NOTA
--   Los registros con partido = NULL o partido no reconocido (ejemplo:
--   'Prueba', 'Test', typos) NO se tocan. Se los revisa manualmente después.
-- ═════════════════════════════════════════════════════════════════════════════
