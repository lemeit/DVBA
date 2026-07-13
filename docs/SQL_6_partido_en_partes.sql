-- SQL 6 · Agregar columna partido a partes_diarios (v7.70)
--
-- Motivación: el Google Form oficial no captura el partido, pero es
-- información valiosa para estadísticas y reportes. La detección se hace
-- del lado cliente al guardar:
--   • Caminos: código NNN-NN es único por partido (RED_VIAL da el partido).
--   • RPs: se interpola el punto medio del tramo prog_ini↔prog_fin sobre
--     el bundle CHAIN_RPxx y se hace point-in-polygon vs
--     datos/partidos_zona_vi.geojson.
--
-- Nullable: partes existentes no tienen partido y no queremos romperlos.
-- Un backfill se puede hacer con una función SQL o un script después.

BEGIN;

ALTER TABLE partes_diarios
  ADD COLUMN IF NOT EXISTS partido TEXT;

CREATE INDEX IF NOT EXISTS idx_partes_partido
  ON partes_diarios(partido);

-- Actualizar view de export para incluir el partido
DROP VIEW IF EXISTS v_partes_diarios_export CASCADE;

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
  p.partido                                       AS "Partido",
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

-- Verificar
SELECT column_name FROM information_schema.columns
WHERE table_name = 'partes_diarios' AND column_name = 'partido';

SELECT COUNT(*) AS total_partes,
       SUM(CASE WHEN partido IS NULL THEN 1 ELSE 0 END) AS sin_partido
FROM partes_diarios;
