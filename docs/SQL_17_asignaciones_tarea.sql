-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_17 · Módulo Jefe de Zona · Asignaciones de tareas de mantenimiento
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-18
-- Autor: DVBA Zona VI Saladillo
--
-- OBJETIVO
--   Modelar el ciclo completo del sistema DVBA:
--
--       DIV. TÉCNICA        JEFE DE ZONA / OPERATIVA        CAPATAZ / CUADRILLA
--       (releva)      ────► (asigna tarea)          ────►   (ejecuta y cierra)
--                                                              │
--                                                              ▼
--                                                        REGISTRO DE CIERRE
--                                                        (naturaleza=tarea,
--                                                         estado=finalizado)
--                                                              │
--                                                              ▼
--                                                        REPORTES MENSUALES
--                                                              (gerencia)
--
--   Este SQL define el modelo de datos y las políticas RLS para ese flujo.
--   Depende de SQL_7 (usuarios_perfil) y SQL_9 (RLS zonal base).
--
-- ORGANIGRAMA COMPLETO REFLEJADO EN LOS ROLES
--   ┌────────────────────────────────────────────────────────────────────────┐
--   │  gerencia         (1 rol · centraliza las 12 zonas)                    │
--   │       │                                                                │
--   │       ▼                                                                │
--   │  jefe_zona        (12 jefes · 1 por zona vial DVBA)                    │
--   │       │                                                                │
--   │       ├── jefe_administrativa  (RRHH + contable · sin ingerencia op.)  │
--   │       ├── jefe_automotores     (parque vehicular)                      │
--   │       ├── jefe_tecnica         (genera relevamientos)                  │
--   │       └── jefe_operativa       (ejecuta con capataces + cuadrillas)    │
--   │              │                                                         │
--   │              └── capataz       (1-N por zona · maneja cuadrilla)       │
--   │                                                                        │
--   │  admin            (transversal · gestión de usuarios y catálogos)      │
--   │  tecnico          (rol existente · operador de campo genérico)         │
--   │  publico          (sin login · solo mapa)                              │
--   └────────────────────────────────────────────────────────────────────────┘
-- ═════════════════════════════════════════════════════════════════════════════


-- ═════════════════════════════════════════════════════════════════════════════
-- 1. AMPLIAR CHECK DE rol EN usuarios_perfil
-- ═════════════════════════════════════════════════════════════════════════════
-- Los nuevos roles se agregan al CHECK existente sin tocar los actuales.
-- SQL_7 definió: 'publico', 'tecnico', 'gerencia', 'admin'.
-- SQL_17 agrega: 'jefe_zona', 'jefe_tecnica', 'jefe_operativa',
--                'jefe_administrativa', 'jefe_automotores', 'capataz'.

ALTER TABLE usuarios_perfil DROP CONSTRAINT IF EXISTS usuarios_perfil_rol_check;
ALTER TABLE usuarios_perfil ADD CONSTRAINT usuarios_perfil_rol_check
  CHECK (rol IN (
    'publico',
    'tecnico',
    'capataz',
    'jefe_administrativa',
    'jefe_automotores',
    'jefe_tecnica',
    'jefe_operativa',
    'jefe_zona',
    'gerencia',
    'admin'
  ));

COMMENT ON COLUMN usuarios_perfil.rol IS
  'Rol operativo del usuario. Ver organigrama en SQL_17.';

-- La regla de "técnico requiere zona" se extiende: TODOS los roles operativos
-- (excepto gerencia y admin, que son transversales) DEBEN tener zona asignada.
ALTER TABLE usuarios_perfil DROP CONSTRAINT IF EXISTS chk_zona_tecnico_obligatoria;
ALTER TABLE usuarios_perfil ADD CONSTRAINT chk_zona_operativo_obligatoria
  CHECK (
    (rol IN ('publico', 'gerencia', 'admin')) OR (zona IS NOT NULL)
  );


-- ═════════════════════════════════════════════════════════════════════════════
-- 2. HELPERS NUEVOS · IDENTIFICAR TIPOS DE ROL
-- ═════════════════════════════════════════════════════════════════════════════
-- current_user_es_jefe() → true si el rol es jefe de zona o de alguna división.
-- current_user_puede_asignar() → true si el rol tiene autoridad para asignar
--                                tareas (jefe_zona, jefe_operativa, gerencia, admin).
-- current_user_es_capataz() → true si es capataz (destino de asignaciones).

CREATE OR REPLACE FUNCTION current_user_es_jefe() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() IN (
      'jefe_zona', 'jefe_administrativa', 'jefe_automotores',
      'jefe_tecnica', 'jefe_operativa'
    );
$$;

CREATE OR REPLACE FUNCTION current_user_puede_asignar() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() IN ('jefe_zona', 'jefe_operativa', 'gerencia', 'admin');
$$;

CREATE OR REPLACE FUNCTION current_user_es_capataz() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() = 'capataz';
$$;

-- Grants para authenticated (bypass de gerencia/admin ya cubierto en SQL_7)
GRANT EXECUTE ON FUNCTION current_user_es_jefe()          TO authenticated;
GRANT EXECUTE ON FUNCTION current_user_puede_asignar()    TO authenticated;
GRANT EXECUTE ON FUNCTION current_user_es_capataz()       TO authenticated;


-- ═════════════════════════════════════════════════════════════════════════════
-- 3. TABLA asignaciones_tarea
-- ═════════════════════════════════════════════════════════════════════════════
-- Una asignación representa una tarea de mantenimiento QUE VA A EJECUTARSE.
-- Se diferencia del registro (tabla relevamientos):
--   · El registro captura QUÉ SE OBSERVÓ o QUÉ SE HIZO (con foto + GPS + sello).
--   · La asignación captura QUÉ SE VA A HACER, QUIÉN LO HARÁ y CUÁNDO.
-- El cierre del ciclo une ambas cosas: cuando el capataz completa la tarea,
-- crea un registro (con foto de la ejecución) y el sistema vincula
-- asignacion.registro_cierre_id → relevamiento.id.

CREATE TABLE IF NOT EXISTS asignaciones_tarea (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Origen (opcional): si esta tarea nace de un relevamiento específico,
  -- se guarda el link para trazabilidad completa.
  relevamiento_origen_id BIGINT REFERENCES relevamientos(id) ON DELETE SET NULL,

  -- Descripción de la tarea a ejecutar
  categoria TEXT NOT NULL,           -- calzada | drenaje | estructura | senial_vertical | ...
  tipo TEXT NOT NULL,                -- "Bacheo profundo" | "Colocación de cebras" | ...
  ruta TEXT NOT NULL,                -- "RP 30" | "093-13" | ...
  progresiva TEXT,                   -- "45+500" (opcional para tareas de tramo largo)
  progresiva_fin TEXT,               -- para tareas lineales (desmalezado km 45 al 47)
  partido TEXT,
  tipo_via TEXT DEFAULT 'rp' CHECK (tipo_via IN ('rp', 'camino')),
  superficie TEXT CHECK (superficie IS NULL OR superficie IN
    ('asfalto','hormigon','tierra','estabilizado','dolomita','suelo_cal')),
  modalidad TEXT CHECK (modalidad IS NULL OR modalidad IN ('manual','mecanico','mixto')),
  lat NUMERIC(9,6),
  lng NUMERIC(9,6),

  -- Zona vial · imprescindible para RLS zonal
  zona TEXT NOT NULL,

  -- Asignación
  asignado_por UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  capataz_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  cuadrilla_nombre TEXT,             -- texto libre: "Cuadrilla A", "Grupo del sur", etc.
  fecha_prevista DATE NOT NULL,
  prioridad TEXT DEFAULT 'media' CHECK (prioridad IN ('baja','media','alta','urgente')),
  notas_asignacion TEXT,             -- instrucciones específicas del jefe

  -- Estado del ciclo
  estado_asignacion TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado_asignacion IN
    ('pendiente',   -- creada, aún no ejecutada
     'en_curso',    -- capataz tocó "Iniciar" en el móvil
     'completada',  -- hay registro de cierre vinculado
     'pospuesta',   -- capataz o jefe la pospuso, se re-programará
     'cancelada'    -- se dio de baja
    )),
  fecha_iniciada TIMESTAMPTZ,        -- se llena al pasar a 'en_curso'
  fecha_completada TIMESTAMPTZ,      -- se llena al pasar a 'completada'
  registro_cierre_id BIGINT REFERENCES relevamientos(id) ON DELETE SET NULL,
  motivo_no_ejecucion TEXT,          -- si pasa a 'pospuesta' o 'cancelada'

  -- Metadata
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE asignaciones_tarea IS
  'Tareas de mantenimiento asignadas por Jefes de Zona/Operativa a Capataces. '
  'Cierra el ciclo relevamiento → asignación → ejecución → registro de cierre.';


-- ═════════════════════════════════════════════════════════════════════════════
-- 4. ÍNDICES PARA QUERIES FRECUENTES
-- ═════════════════════════════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_asig_zona            ON asignaciones_tarea (zona);
CREATE INDEX IF NOT EXISTS idx_asig_capataz         ON asignaciones_tarea (capataz_id)
                                                    WHERE capataz_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_asig_estado          ON asignaciones_tarea (estado_asignacion);
CREATE INDEX IF NOT EXISTS idx_asig_fecha_prevista  ON asignaciones_tarea (fecha_prevista);
CREATE INDEX IF NOT EXISTS idx_asig_prioridad_fecha ON asignaciones_tarea (prioridad, fecha_prevista);
CREATE INDEX IF NOT EXISTS idx_asig_relev_origen    ON asignaciones_tarea (relevamiento_origen_id)
                                                    WHERE relevamiento_origen_id IS NOT NULL;


-- ═════════════════════════════════════════════════════════════════════════════
-- 5. TRIGGER updated_at
-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_7 ya creó _touch_updated_at(). Aplicarlo también a esta tabla.
DROP TRIGGER IF EXISTS trg_asig_updated_at ON asignaciones_tarea;
CREATE TRIGGER trg_asig_updated_at
  BEFORE UPDATE ON asignaciones_tarea
  FOR EACH ROW EXECUTE FUNCTION _touch_updated_at();


-- ═════════════════════════════════════════════════════════════════════════════
-- 6. RLS · POLÍTICAS ZONALES
-- ═════════════════════════════════════════════════════════════════════════════
-- Matriz de accesos:
--
--   ROL                  │ SELECT              │ INSERT/UPDATE/DELETE
--   ─────────────────────┼─────────────────────┼──────────────────────────────
--   publico              │ (nada)              │ (nada)
--   tecnico              │ su zona             │ (nada) · solo relev/observa
--   capataz              │ solo suyas          │ UPDATE de las suyas para
--                        │ (donde es dest.)    │ marcar en_curso/completada/
--                        │                     │ pospuesta con motivo
--   jefe_administrativa  │ su zona (lectura)   │ (nada) · sin ingerencia op.
--   jefe_automotores     │ su zona (lectura)   │ (nada) · sin ingerencia op.
--   jefe_tecnica         │ su zona             │ INSERT (crea desde relevam.)
--   jefe_operativa       │ su zona             │ CRUD completo su zona
--   jefe_zona            │ su zona             │ CRUD completo su zona
--   gerencia             │ TODAS las zonas     │ (nada) · solo lectura global
--   admin                │ TODAS               │ CRUD global sin restricción

ALTER TABLE asignaciones_tarea ENABLE ROW LEVEL SECURITY;

-- Defensa: eliminar policies anteriores si se re-ejecuta el script.
DO $$
DECLARE p RECORD;
BEGIN
  FOR p IN
    SELECT policyname FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'asignaciones_tarea'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON asignaciones_tarea', p.policyname);
  END LOOP;
END $$;

-- ── SELECT ────────────────────────────────────────────────────────────────
CREATE POLICY asig_select ON asignaciones_tarea FOR SELECT USING (
  current_user_rol() = 'admin'
  OR current_user_rol() = 'gerencia'
  OR (
    -- Roles zonales (todos menos publico) ven las de SU zona
    current_user_rol() IN (
      'tecnico','capataz','jefe_administrativa','jefe_automotores',
      'jefe_tecnica','jefe_operativa','jefe_zona'
    )
    AND zona = current_user_zona()
    -- Capataz además ve SOLO las asignadas a él (además del filtro zonal)
    AND (current_user_rol() <> 'capataz' OR capataz_id = auth.uid())
  )
);

-- ── INSERT ────────────────────────────────────────────────────────────────
-- Solo jefes con autoridad de asignación (jefe_zona, jefe_operativa, jefe_tecnica)
-- pueden crear asignaciones nuevas · siempre en su propia zona.
-- Admin puede insertar en cualquier zona.
CREATE POLICY asig_insert ON asignaciones_tarea FOR INSERT WITH CHECK (
  current_user_rol() = 'admin'
  OR (
    current_user_rol() IN ('jefe_zona', 'jefe_operativa', 'jefe_tecnica')
    AND zona = current_user_zona()
    AND asignado_por = auth.uid()
  )
);

-- ── UPDATE ────────────────────────────────────────────────────────────────
-- Jefes de zona/operativa pueden editar toda asignación de su zona
-- (reprogramar, cambiar capataz, cancelar, agregar notas).
-- Capataz puede UPDATE solo de sus propias asignaciones y solo campos
-- limitados (estado_asignacion, fecha_iniciada, fecha_completada,
-- registro_cierre_id, motivo_no_ejecucion). El filtro fino de columnas
-- se hace en la app; a nivel RLS chequeamos que sea suya y que esté en
-- la zona correcta.
CREATE POLICY asig_update ON asignaciones_tarea FOR UPDATE USING (
  current_user_rol() = 'admin'
  OR (
    current_user_rol() IN ('jefe_zona', 'jefe_operativa')
    AND zona = current_user_zona()
  )
  OR (
    current_user_rol() = 'capataz'
    AND capataz_id = auth.uid()
    AND zona = current_user_zona()
  )
);

-- ── DELETE ────────────────────────────────────────────────────────────────
-- Solo jefe_zona/jefe_operativa/admin pueden borrar (raro, mejor cancelar).
CREATE POLICY asig_delete ON asignaciones_tarea FOR DELETE USING (
  current_user_rol() = 'admin'
  OR (
    current_user_rol() IN ('jefe_zona', 'jefe_operativa')
    AND zona = current_user_zona()
  )
);


-- ═════════════════════════════════════════════════════════════════════════════
-- 7. VISTAS ÚTILES
-- ═════════════════════════════════════════════════════════════════════════════

-- v_backlog_jefe_zona · relevamientos que ameritan tarea y aún no fueron
-- convertidos en asignación. Filtra por zona a través de RLS de relevamientos.
CREATE OR REPLACE VIEW v_backlog_jefe_zona AS
SELECT
  r.id                     AS relevamiento_id,
  r.fecha                  AS fecha_relevamiento,
  r.ruta, r.progresiva, r.partido, r.zona,
  r.tipo, r.estado,
  r.observaciones, r.foto_url,
  r.lat, r.lng,
  r.tipo_via,
  -- Prioridad sugerida por severidad
  CASE
    WHEN r.estado IN ('critico','falta','inspeccion_urg','activo') THEN 'urgente'
    WHEN r.estado IN ('malo','ilegible','no_funciona')             THEN 'alta'
    WHEN r.estado IN ('regular','danada','borrada','parcial')      THEN 'media'
    ELSE 'baja'
  END AS prioridad_sugerida,
  -- ¿Alguna asignación abierta ya vinculada?
  (SELECT COUNT(*) FROM asignaciones_tarea a
     WHERE a.relevamiento_origen_id = r.id
       AND a.estado_asignacion IN ('pendiente','en_curso','pospuesta'))
    AS asignaciones_abiertas
FROM relevamientos r
WHERE r.naturaleza = 'relevamiento'
  AND r.estado IN (
    'critico','malo','regular','danada','ilegible','falta','inspeccion_urg',
    'borrada','inexistente','parcial','no_funciona','activo','monitoreo'
  )
  AND r.estado_workflow = 'aprobado';

COMMENT ON VIEW v_backlog_jefe_zona IS
  'Backlog de relevamientos que ameritan generar tarea. Filtrado por RLS zonal '
  'a nivel relevamientos. La app filtra asignaciones_abiertas=0 por default.';

-- v_agenda_capataz · lista de mis tareas asignadas (para app móvil del capataz)
CREATE OR REPLACE VIEW v_agenda_capataz AS
SELECT
  a.id, a.categoria, a.tipo,
  a.ruta, a.progresiva, a.progresiva_fin, a.partido,
  a.tipo_via, a.superficie, a.modalidad,
  a.lat, a.lng, a.zona,
  a.fecha_prevista, a.prioridad,
  a.estado_asignacion,
  a.notas_asignacion, a.cuadrilla_nombre,
  a.fecha_iniciada, a.fecha_completada,
  -- Info del relevamiento origen (para que el capataz vea qué observó el técnico)
  ro.foto_url    AS foto_origen,
  ro.observaciones AS obs_origen,
  ro.estado      AS estado_origen,
  ro.fecha       AS fecha_origen,
  -- Info del registro de cierre (si ya se completó)
  rc.foto_url    AS foto_cierre,
  rc.fecha       AS fecha_cierre_registro,
  -- Días de atraso respecto a fecha prevista
  CASE
    WHEN a.estado_asignacion IN ('completada','cancelada') THEN NULL
    ELSE GREATEST(0, (CURRENT_DATE - a.fecha_prevista))
  END AS dias_atraso
FROM asignaciones_tarea a
LEFT JOIN relevamientos ro ON ro.id = a.relevamiento_origen_id
LEFT JOIN relevamientos rc ON rc.id = a.registro_cierre_id;

COMMENT ON VIEW v_agenda_capataz IS
  'Agenda del capataz (o del jefe). RLS de asignaciones_tarea filtra al capataz '
  'a sus propias asignaciones; los jefes ven todas las de su zona.';

-- v_kpi_asignaciones · para dashboard de reportes
CREATE OR REPLACE VIEW v_kpi_asignaciones AS
SELECT
  zona,
  DATE_TRUNC('week', fecha_prevista)::DATE AS semana,
  COUNT(*)                                                   AS total,
  COUNT(*) FILTER (WHERE estado_asignacion = 'pendiente')    AS pendientes,
  COUNT(*) FILTER (WHERE estado_asignacion = 'en_curso')     AS en_curso,
  COUNT(*) FILTER (WHERE estado_asignacion = 'completada')   AS completadas,
  COUNT(*) FILTER (WHERE estado_asignacion = 'pospuesta')    AS pospuestas,
  COUNT(*) FILTER (WHERE estado_asignacion = 'cancelada')    AS canceladas,
  COUNT(*) FILTER (WHERE prioridad = 'urgente')              AS urgentes,
  -- Cumplimiento: completadas / (totales - canceladas)
  ROUND(
    100.0 *
    COUNT(*) FILTER (WHERE estado_asignacion = 'completada') /
    NULLIF(COUNT(*) FILTER (WHERE estado_asignacion <> 'cancelada'), 0)
    , 1
  ) AS pct_cumplimiento
FROM asignaciones_tarea
GROUP BY zona, DATE_TRUNC('week', fecha_prevista);

COMMENT ON VIEW v_kpi_asignaciones IS
  'KPIs semanales de cumplimiento de asignaciones por zona. Alimenta el '
  'dashboard de gerencia y el reporte del jefe de zona.';


-- ═════════════════════════════════════════════════════════════════════════════
-- 8. VERIFICACIÓN POST-MIGRACIÓN (informativa, no ejecutiva)
-- ═════════════════════════════════════════════════════════════════════════════
-- SELECT tablename, policyname FROM pg_policies WHERE tablename = 'asignaciones_tarea';
-- SELECT rol, COUNT(*) FROM usuarios_perfil GROUP BY rol ORDER BY rol;
-- SELECT COUNT(*) FROM asignaciones_tarea; -- debería ser 0 al principio
-- SELECT current_user_es_jefe(), current_user_puede_asignar(), current_user_es_capataz();


-- ═════════════════════════════════════════════════════════════════════════════
-- 9. DATOS SEMILLA (comentado · descomentar para dar de alta capataz de prueba)
-- ═════════════════════════════════════════════════════════════════════════════
-- Para probar el módulo en Zona VI, dar de alta al menos:
--   · 1 usuario con rol='jefe_zona' zona='VI'
--   · 1 usuario con rol='jefe_operativa' zona='VI'
--   · 1-2 usuarios con rol='capataz' zona='VI'
--
-- Reemplazar los UUIDs por los reales de auth.users:
--
-- INSERT INTO usuarios_perfil (user_id, nombre, rol, zona) VALUES
INSERT INTO usuarios_perfil (user_id, nombre, rol, zona) VALUES
('966fe4f6-46a1-44b9-b27c-a4b9ad6b3665',  'Jefe Zona',    'jefe_zona',      'VI'),
('8cecf908-dd6d-4c91-b7c1-d9a003abc31a',  'Jefe Operat.', 'jefe_operativa', 'VI'),
('9b027516-2de9-4046-bc6c-cda7efbb1c08',  'Capataz 1',    'capataz',        'VI')
ON CONFLICT (user_id) DO UPDATE
SET rol  = EXCLUDED.rol,
    zona = EXCLUDED.zona;


-- jefezona.vi@dvba.test
-- jefeoperativa.vi@dvba.test
-- jefetecnica.vi@dvba.test
-- capataz1.vi@dvba.test
-- jefeoperativa.iv@dvba.test
-- jefeoperativa.v@dvba.test
-- gerencia@dvba.test