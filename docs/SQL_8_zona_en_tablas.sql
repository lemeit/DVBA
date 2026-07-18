-- SQL 8 · Columna zona en partes_diarios y relevamientos (v7.92)
--
-- Contexto: Fase 1 del PLAN_ROLES_MULTIZONA. Este SQL agrega la columna
-- 'zona' a las dos tablas operativas principales, y hace backfill de
-- todos los registros existentes como Zona VI (que es lo único que hay
-- hoy — el sistema arrancó operando solo Zona VI Saladillo).
--
-- ESTA MIGRACIÓN ES SEGURA para producción:
--   • Solo agrega columnas (nullable durante la migración).
--   • Los índices son idempotentes (IF NOT EXISTS).
--   • Actualiza la view v_partes_diarios_export para exponer zona en el CSV.
--   • NO toca policies vigentes — eso queda para SQL 9 (Fase 3).
--
-- Después de este SQL, el frontend puede empezar a llenar 'zona' al
-- INSERT (Fase 2) sin que rompa nada existente.

BEGIN;

-- ═══════════════════════════════════════════════════════════════════
-- 1) Columna zona en partes_diarios
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE partes_diarios
  ADD COLUMN IF NOT EXISTS zona TEXT;

CREATE INDEX IF NOT EXISTS idx_partes_zona ON partes_diarios(zona);

COMMENT ON COLUMN partes_diarios.zona IS
  'Zona vial DVBA (I..XII). Se llena al INSERT desde usuarios_perfil.zona o desde el partido detectado.';

-- Backfill: todos los partes actuales son Zona VI (única zona operativa a 2026-07-18).
-- WHERE zona IS NULL para permitir re-correr el script sin sobrescribir.
UPDATE partes_diarios
SET zona = 'VI'
WHERE zona IS NULL;

-- ═══════════════════════════════════════════════════════════════════
-- 2) Columna zona en relevamientos
-- ═══════════════════════════════════════════════════════════════════
ALTER TABLE relevamientos
  ADD COLUMN IF NOT EXISTS zona TEXT;

CREATE INDEX IF NOT EXISTS idx_relevamientos_zona ON relevamientos(zona);

COMMENT ON COLUMN relevamientos.zona IS
  'Zona vial DVBA (I..XII). Se llena al INSERT desde usuarios_perfil.zona o desde partido/GPS.';

-- Backfill: idem partes.
UPDATE relevamientos
SET zona = 'VI'
WHERE zona IS NULL;

-- ═══════════════════════════════════════════════════════════════════
-- 3) Actualizar v_partes_diarios_export para exponer la zona
--    (mismo patrón que SQL 6 cuando agregamos partido)
-- ═══════════════════════════════════════════════════════════════════
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
  p.zona                                          AS "Zona",
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

-- ═══════════════════════════════════════════════════════════════════
-- Verificación
-- ═══════════════════════════════════════════════════════════════════
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name IN ('partes_diarios', 'relevamientos')
  AND column_name = 'zona';

SELECT 'partes_diarios' AS tabla,
       COUNT(*) AS total,
       COUNT(zona) AS con_zona,
       COUNT(*) - COUNT(zona) AS sin_zona,
       COUNT(*) FILTER (WHERE zona = 'VI') AS zona_vi
FROM partes_diarios
UNION ALL
SELECT 'relevamientos',
       COUNT(*),
       COUNT(zona),
       COUNT(*) - COUNT(zona),
       COUNT(*) FILTER (WHERE zona = 'VI')
FROM relevamientos;

-- Se espera:
--   • partes_diarios: total=632 aprox, sin_zona=0, zona_vi=632
--   • relevamientos:  total=N,       sin_zona=0, zona_vi=N
