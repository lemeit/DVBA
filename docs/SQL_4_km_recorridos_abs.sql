-- SQL 4 · Cambiar km_recorridos a valor absoluto
-- v7.65 · Partes Diarios
--
-- Progresivas pueden ir descendentes (prog_fin < prog_ini). Nueva fórmula
-- ABS(prog_fin - prog_ini) para que km_recorridos siempre sea >= 0.
--
-- Complicación: la view v_partes_diarios_export depende de km_recorridos.
-- Solución: DROP CASCADE + ADD COLUMN + recrear la view.
-- Todo dentro de BEGIN/COMMIT para atomicidad.

BEGIN;

-- 1. Borrar la columna generada y la view que depende
ALTER TABLE partes_diarios DROP COLUMN IF EXISTS km_recorridos CASCADE;

-- 2. Agregar la columna con la nueva fórmula
ALTER TABLE partes_diarios
  ADD COLUMN km_recorridos numeric
  GENERATED ALWAYS AS (ABS(prog_fin - prog_ini)) STORED;

-- 3. Recrear la view v_partes_diarios_export tal cual estaba antes
CREATE OR REPLACE VIEW v_partes_diarios_export AS
WITH maq AS (
  SELECT
    pm.parte_id,
    pm.orden,
    v.tipo_maquinaria AS maquinaria,
    v.identificador   AS id_codigo,
    v.numero          AS n_id
  FROM parte_maquinarias pm
  JOIN vehiculos v ON v.id = pm.vehiculo_id
),
pivot AS (
  SELECT
    parte_id,
    MAX(CASE WHEN orden = 1 THEN maquinaria END) AS "Maquinaria 1",
    MAX(CASE WHEN orden = 1 THEN id_codigo  END) AS "ID1",
    MAX(CASE WHEN orden = 1 THEN n_id       END) AS "NºID1",
    MAX(CASE WHEN orden = 2 THEN maquinaria END) AS "Maquinaria 2",
    MAX(CASE WHEN orden = 2 THEN id_codigo  END) AS "ID2",
    MAX(CASE WHEN orden = 2 THEN n_id       END) AS "NºID2",
    MAX(CASE WHEN orden = 3 THEN maquinaria END) AS "Maquinaria 3",
    MAX(CASE WHEN orden = 3 THEN id_codigo  END) AS "ID3",
    MAX(CASE WHEN orden = 3 THEN n_id       END) AS "NºID3",
    MAX(CASE WHEN orden = 4 THEN maquinaria END) AS "Maquinaria 4",
    MAX(CASE WHEN orden = 4 THEN id_codigo  END) AS "ID4",
    MAX(CASE WHEN orden = 4 THEN n_id       END) AS "NºID4",
    MAX(CASE WHEN orden = 5 THEN maquinaria END) AS "Maquinaria 5",
    MAX(CASE WHEN orden = 5 THEN id_codigo  END) AS "ID5",
    MAX(CASE WHEN orden = 5 THEN n_id       END) AS "NºID5"
  FROM maq
  GROUP BY parte_id
)
SELECT
  CASE WHEN p.enviado_admin THEN 'si' ELSE '' END AS "Enviado",
  TO_CHAR(p.fecha, 'DD/MM/YYYY')                  AS "Fecha",
  ct.nombre                                       AS "Tarea",
  CASE WHEN p.tipo_via = 'rp' THEN 'RP' || p.ruta ELSE p.ruta END AS "Ruta",
  p.prog_ini                                      AS "Prog. Inicial",
  p.prog_fin                                      AS "Prog. Final",
  pv."Maquinaria 1", pv."ID1", pv."NºID1",
  pv."Maquinaria 2", pv."ID2", pv."NºID2",
  pv."Maquinaria 3", pv."ID3", pv."NºID3",
  pv."Maquinaria 4", pv."ID4", pv."NºID4",
  pv."Maquinaria 5", pv."ID5", pv."NºID5",
  p.observaciones                                 AS "Observaciones",
  p.foto_previa_url                               AS "Imágenes previas",
  p.foto_posterior_url                            AS "Imágenes posteriores",
  p.km_recorridos                                 AS "km"
FROM partes_diarios p
JOIN catalogo_tareas ct ON ct.id = p.tarea_id
LEFT JOIN pivot pv ON pv.parte_id = p.id
ORDER BY p.fecha DESC, p.id DESC;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- Verificaciones post-migración
-- ═══════════════════════════════════════════════════════════════════

-- 1) km_recorridos ahora siempre >= 0
SELECT
  COUNT(*)                                     AS total_partes,
  SUM(CASE WHEN km_recorridos IS NULL THEN 1 ELSE 0 END) AS con_km_null,
  SUM(CASE WHEN km_recorridos >= 0    THEN 1 ELSE 0 END) AS con_km_positivo_o_cero,
  SUM(CASE WHEN km_recorridos < 0     THEN 1 ELSE 0 END) AS con_km_negativo,
  ROUND(SUM(km_recorridos)::numeric, 2)        AS km_total
FROM partes_diarios;

-- 2) La view sigue funcionando
SELECT COUNT(*) AS filas_export FROM v_partes_diarios_export;

-- 3) Ejemplo: partes cuya prog_ini > prog_fin (descendentes) — ahora deben tener km >= 0
SELECT id, fecha, ruta, prog_ini, prog_fin, km_recorridos
FROM partes_diarios
WHERE prog_ini > prog_fin
ORDER BY fecha DESC
LIMIT 10;
