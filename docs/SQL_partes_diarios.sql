-- ═══════════════════════════════════════════════════════════════════════
-- DVBA Zona VI · Sistema de Partes Diarios
-- Fase 1: schema + catálogos iniciales (2026-07-06)
--
-- Reemplaza el flujo actual de Google Form + Google Sheets espejo.
-- Integra con el sistema existente reusando los selectores de Ruta
-- (RPs + Caminos Secundarios) y el cálculo de progresivas con anchors.
--
-- APLICAR EN ORDEN:
--   1. Crear catálogos (catalogo_tareas, catalogo_maquinarias)
--   2. Crear tabla vehículos + poblar con CSV (Vehículos y Equipos)
--   3. Crear tabla partes_diarios + parte_maquinarias
--   4. RLS policies
--   5. Bulk insert histórico desde CSV (Tareas DVBA Z6)
-- ═══════════════════════════════════════════════════════════════════════


-- ─────────────────────────────────────────────────────────────────────
-- 1. CATÁLOGOS (data maestra, editable desde admin UI en el futuro)
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS catalogo_tareas (
  id BIGSERIAL PRIMARY KEY,
  nombre TEXT UNIQUE NOT NULL,
  categoria TEXT,                    -- para agrupar (Mantenimiento / Señalización / etc)
  descripcion TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO catalogo_tareas (nombre, categoria) VALUES
  ('CORTE DE PASTO',                                   'Conservación'),
  ('MANTENIMIENTO DE PAVIMENTOS',                      'Mantenimiento'),
  ('CALZADO DE BANQUINAS',                             'Mantenimiento'),
  ('SEÑALIZACIÓN Y DEMARCACIÓN (Horizontal y Vertical)', 'Señalización'),
  ('MANTENIMIENTO DE ALUMBRADO',                       'Alumbrado'),
  ('CAMINOS RURALES',                                  'Red Secundaria'),
  ('REEMPLAZO DE BARANDAS FLEX BEAM',                  'Seguridad Vial'),
  ('REPARACIÓN DE ALCANTARILLAS',                      'Obras de Arte')
ON CONFLICT (nombre) DO NOTHING;


CREATE TABLE IF NOT EXISTS catalogo_maquinarias (
  tipo TEXT PRIMARY KEY,
  categoria TEXT,                    -- Camión / Equipo pesado / Liviano / etc
  activo BOOLEAN DEFAULT true
);

INSERT INTO catalogo_maquinarias (tipo, categoria) VALUES
  ('MOTONIVELADORA',        'Equipo pesado'),
  ('TRACTOR',               'Equipo agrícola'),
  ('DESMALEZADORA',         'Equipo agrícola'),
  ('RETROEXCAVADORA',       'Equipo pesado'),
  ('PALA CARGADORA FRONTAL','Equipo pesado'),
  ('MINI CARGADORA',        'Equipo pesado'),
  ('TOPADORA',              'Equipo pesado'),
  ('CAMIÓN',                'Transporte'),
  ('CAMIONETA',             'Transporte liviano'),
  ('APLANADORA',            'Equipo pesado')
ON CONFLICT (tipo) DO NOTHING;


-- Catálogo de identificadores (O.I., R.O., etc)
CREATE TABLE IF NOT EXISTS catalogo_identificadores (
  codigo TEXT PRIMARY KEY,
  descripcion TEXT,
  activo BOOLEAN DEFAULT true
);

INSERT INTO catalogo_identificadores (codigo, descripcion) VALUES
  ('O.I.', 'Orden Interna'),
  ('R.O.', 'Registro Oficial')
  -- agregar los demás cuando el user confirme
ON CONFLICT (codigo) DO NOTHING;


-- ─────────────────────────────────────────────────────────────────────
-- 2. VEHÍCULOS (data del sheet "Vehículos y Equipos")
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS vehiculos (
  id BIGSERIAL PRIMARY KEY,
  identificador TEXT NOT NULL REFERENCES catalogo_identificadores(codigo),
  numero TEXT NOT NULL,
  tipo_maquinaria TEXT NOT NULL REFERENCES catalogo_maquinarias(tipo),
  marca TEXT,
  modelo TEXT,
  descripcion TEXT,
  observaciones TEXT,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (identificador, numero)
);

-- Index sugerido para búsquedas rápidas al elegir maquinaria en el form
CREATE INDEX IF NOT EXISTS idx_vehiculos_tipo ON vehiculos(tipo_maquinaria) WHERE activo = true;

-- Bulk insert: PLACEHOLDER — reemplazar cuando el user pase el CSV
-- Ejemplo del formato esperado a partir de las filas vistas en el sheet:
--   INSERT INTO vehiculos (identificador, numero, tipo_maquinaria) VALUES
--     ('O.I.', '21202', 'MINI CARGADORA'),
--     ('R.O.', '4099',  'CAMIÓN'),
--     ('R.O.', '41020', 'RETROEXCAVADORA'),
--     ('O.I.', '26395', 'CAMIONETA'),
--     ('O.I.', '21806', 'TRACTOR'),
--     ('R.O.', '2084',  'CAMIÓN'),
--     ('O.I.', '2180',  'DESMALEZADORA'),
--     ('R.O.', '2210',  'MOTONIVELADORA')
--   ON CONFLICT (identificador, numero) DO NOTHING;


-- ─────────────────────────────────────────────────────────────────────
-- 3. PARTES DIARIOS + MAQUINARIAS ASOCIADAS
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS partes_diarios (
  id BIGSERIAL PRIMARY KEY,
  fecha DATE NOT NULL,
  tarea_id BIGINT NOT NULL REFERENCES catalogo_tareas(id),

  -- Vía relevada (misma convención que relevamientos)
  tipo_via TEXT NOT NULL CHECK (tipo_via IN ('rp', 'camino')),
  ruta TEXT NOT NULL,                    -- '51' | '093-08' | etc

  -- Progresivas (en km, con 3 decimales para precisión de m)
  prog_ini NUMERIC(8,3),
  prog_fin NUMERIC(8,3),
  km_recorridos NUMERIC(8,3)
    GENERATED ALWAYS AS (COALESCE(prog_fin,0) - COALESCE(prog_ini,0)) STORED,

  -- Datos del parte
  observaciones TEXT,

  -- Fotos (URLs de Supabase Storage bucket 'partes_diarios' o similar)
  foto_previa_url TEXT,
  foto_posterior_url TEXT,

  -- Metadata operativa
  responsable_id UUID REFERENCES auth.users(id),
  enviado_admin BOOLEAN DEFAULT false,   -- se envió al Google Form/Sheet oficial
  enviado_admin_at TIMESTAMPTZ,          -- cuándo se envió (si aplica)

  -- Auditoría
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_partes_fecha ON partes_diarios(fecha DESC);
CREATE INDEX IF NOT EXISTS idx_partes_tarea ON partes_diarios(tarea_id);
CREATE INDEX IF NOT EXISTS idx_partes_ruta  ON partes_diarios(tipo_via, ruta);


CREATE TABLE IF NOT EXISTS parte_maquinarias (
  parte_id BIGINT NOT NULL REFERENCES partes_diarios(id) ON DELETE CASCADE,
  orden SMALLINT NOT NULL CHECK (orden BETWEEN 1 AND 5),  -- Maquinaria 1..5
  vehiculo_id BIGINT NOT NULL REFERENCES vehiculos(id),
  PRIMARY KEY (parte_id, orden)
);


-- ─────────────────────────────────────────────────────────────────────
-- 4. VISTA CONVENIENTE para exportar en formato Google Sheet
-- ─────────────────────────────────────────────────────────────────────
--
-- Reproduce las columnas del sheet original:
-- Enviado | Fecha | Tarea | Ruta | Prog. Inicial | Prog. Final |
-- Maquinaria 1..5 | ID1..5 | N°ID1..5 | Observaciones |
-- Imágenes previas | Imágenes posteriores | km
--
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


-- ─────────────────────────────────────────────────────────────────────
-- 5. TRIGGER updated_at
-- ─────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION _touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_partes_diarios_touch ON partes_diarios;
CREATE TRIGGER trg_partes_diarios_touch
  BEFORE UPDATE ON partes_diarios
  FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();


-- ─────────────────────────────────────────────────────────────────────
-- 6. RLS POLICIES
-- ─────────────────────────────────────────────────────────────────────
-- Regla de negocio provisoria (ajustar cuando definamos roles):
--   Autenticados pueden leer todo (para dashboard y filtros compartidos)
--   Autenticados pueden crear partes y editar los propios
--   El bucket 'partes_fotos' se maneja aparte con policies de Storage
--
ALTER TABLE catalogo_tareas         ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_maquinarias    ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_identificadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehiculos               ENABLE ROW LEVEL SECURITY;
ALTER TABLE partes_diarios          ENABLE ROW LEVEL SECURITY;
ALTER TABLE parte_maquinarias       ENABLE ROW LEVEL SECURITY;

-- NOTA: Postgres NO soporta CREATE POLICY IF NOT EXISTS.
-- Usar DROP + CREATE (idempotente al re-ejecutar el script).

-- Lectura pública para catálogos (uso en dropdowns del form)
DROP POLICY IF EXISTS catalogos_read_auth   ON catalogo_tareas;
CREATE POLICY catalogos_read_auth ON catalogo_tareas
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS catalogos_read_auth_m ON catalogo_maquinarias;
CREATE POLICY catalogos_read_auth_m ON catalogo_maquinarias
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS catalogos_read_auth_i ON catalogo_identificadores;
CREATE POLICY catalogos_read_auth_i ON catalogo_identificadores
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS vehiculos_read_auth ON vehiculos;
CREATE POLICY vehiculos_read_auth ON vehiculos
  FOR SELECT USING (auth.role() = 'authenticated' AND activo = true);

-- Partes: los usuarios autenticados pueden crear y editar los suyos
DROP POLICY IF EXISTS partes_read_auth   ON partes_diarios;
CREATE POLICY partes_read_auth ON partes_diarios
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS partes_insert_auth ON partes_diarios;
CREATE POLICY partes_insert_auth ON partes_diarios
  FOR INSERT WITH CHECK (auth.uid() = responsable_id);

DROP POLICY IF EXISTS partes_update_own  ON partes_diarios;
CREATE POLICY partes_update_own ON partes_diarios
  FOR UPDATE USING (auth.uid() = responsable_id);

DROP POLICY IF EXISTS parte_maq_read_auth ON parte_maquinarias;
CREATE POLICY parte_maq_read_auth ON parte_maquinarias
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS parte_maq_insert_auth ON parte_maquinarias;
CREATE POLICY parte_maq_insert_auth ON parte_maquinarias
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM partes_diarios p
            WHERE p.id = parte_maquinarias.parte_id AND p.responsable_id = auth.uid())
  );

DROP POLICY IF EXISTS parte_maq_del_own ON parte_maquinarias;
CREATE POLICY parte_maq_del_own ON parte_maquinarias
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM partes_diarios p
            WHERE p.id = parte_maquinarias.parte_id AND p.responsable_id = auth.uid())
  );


-- ─────────────────────────────────────────────────────────────────────
-- 7. BULK INSERT HISTÓRICO — placeholder para el CSV del user
-- ─────────────────────────────────────────────────────────────────────
--
-- Cuando pases el CSV de la pestaña "Tareas DVBA Z6" del sheet:
--
--   \COPY partes_diarios_staging(fecha, tarea, ruta, prog_ini, prog_fin,
--                                 m1_tipo, m1_id, m1_nro,
--                                 m2_tipo, m2_id, m2_nro, ...)
--     FROM 'tareas.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
--
-- Después script de migración desde staging → partes_diarios + parte_maquinarias
-- resolviendo los FKs (buscar tarea_id por nombre, vehiculo_id por identificador+numero).


-- ═══════════════════════════════════════════════════════════════════════
-- FIN Fase 1
-- Cuando esto esté aplicado en Supabase, arrancamos Fase 2 (UI escritorio).
-- ═══════════════════════════════════════════════════════════════════════
