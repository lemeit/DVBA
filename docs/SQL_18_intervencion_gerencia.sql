-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_18 · Auditoría de intervención de Gerencia en asignaciones_tarea
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-18
--
-- Contexto: la Gerencia puede intervenir en tareas de cualquier zona (cancelar,
-- posponer, reasignar, editar notas). Cada intervención debe quedar auditada
-- con el UID del usuario y el timestamp, para que quede claro que un jefe de
-- zona no tomó esa decisión — fue Gerencia interviniendo.
--
-- Complementa las policies del SQL_17 · no las reemplaza.
-- ═════════════════════════════════════════════════════════════════════════════

-- 1. Columnas nuevas
ALTER TABLE asignaciones_tarea ADD COLUMN IF NOT EXISTS intervenido_por    UUID REFERENCES auth.users(id);
ALTER TABLE asignaciones_tarea ADD COLUMN IF NOT EXISTS intervenido_en     TIMESTAMPTZ;
ALTER TABLE asignaciones_tarea ADD COLUMN IF NOT EXISTS motivo_intervencion TEXT;

COMMENT ON COLUMN asignaciones_tarea.intervenido_por IS
  'UID del usuario que intervino la tarea desde fuera de la zona (típicamente Gerencia). NULL si no hubo intervención cross-zona.';
COMMENT ON COLUMN asignaciones_tarea.intervenido_en IS
  'Timestamp de la última intervención cross-zona.';
COMMENT ON COLUMN asignaciones_tarea.motivo_intervencion IS
  'Motivo declarado de la intervención (obligatorio para gerencia al editar tareas de otra zona).';


-- 2. Índice para queries "asignaciones intervenidas por Gerencia" en reportes
CREATE INDEX IF NOT EXISTS idx_asig_intervenido_por ON asignaciones_tarea (intervenido_por)
  WHERE intervenido_por IS NOT NULL;


-- 3. Actualizar policy UPDATE para permitir a gerencia editar TODAS las zonas
--    (antes solo admin podía cross-zona). La app rellena intervenido_por/_en
--    cuando el usuario que edita NO es de la zona de la tarea.
DROP POLICY IF EXISTS asig_update ON asignaciones_tarea;
CREATE POLICY asig_update ON asignaciones_tarea FOR UPDATE USING (
  current_user_rol() = 'admin'
  -- Gerencia puede editar cualquier tarea de cualquier zona (queda registrada
  -- la intervención en la columna intervenido_por vía la app).
  OR current_user_rol() = 'gerencia'
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


-- 4. Vista con badge de "intervenida" para la UI del kanban
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
  a.capataz_id, a.asignado_por,
  ro.foto_url      AS foto_origen,
  ro.observaciones AS obs_origen,
  ro.estado        AS estado_origen,
  ro.fecha         AS fecha_origen,
  rc.foto_url      AS foto_cierre,
  rc.fecha         AS fecha_cierre_registro,
  CASE
    WHEN a.estado_asignacion IN ('completada','cancelada') THEN NULL
    ELSE GREATEST(0, (CURRENT_DATE - a.fecha_prevista))
  END AS dias_atraso,
  -- v18 · Auditoría de intervención de Gerencia
  a.intervenido_por,
  a.intervenido_en,
  a.motivo_intervencion,
  (a.intervenido_por IS NOT NULL) AS fue_intervenida
FROM asignaciones_tarea a
LEFT JOIN relevamientos ro ON ro.id = a.relevamiento_origen_id
LEFT JOIN relevamientos rc ON rc.id = a.registro_cierre_id;


-- 5. Verificación
-- SELECT COUNT(*) FROM asignaciones_tarea WHERE intervenido_por IS NOT NULL;
-- SELECT policyname FROM pg_policies WHERE tablename = 'asignaciones_tarea';
