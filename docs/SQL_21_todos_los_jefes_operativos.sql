-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_21 · Ampliar current_user_es_operativo_zonal() a TODOS los jefes
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   SQL_19 dejó a jefe_administrativa y jefe_automotores como LECTORES zonales
--   (helper current_user_es_lector_zonal). El uso real muestra que todo jefe
--   —independiente de su división— debe poder cargar registros dentro de su
--   zona: puede acompañar operativos, sacar fotos de averías, cargar partes.
--
-- CAMBIO
--   Se amplía current_user_es_operativo_zonal() para incluir jefe_administrativa
--   y jefe_automotores. current_user_es_lector_zonal() queda como identidad
--   histórica (por si en el futuro queremos restringir a alguien).
--
-- REQUISITOS PREVIOS
--   ✓ SQL_19 (helpers actuales)
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

CREATE OR REPLACE FUNCTION current_user_es_operativo_zonal() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT current_user_rol() IN (
      'tecnico', 'capataz',
      'jefe_zona', 'jefe_tecnica', 'jefe_operativa',
      'jefe_administrativa', 'jefe_automotores'
    );
$$;

-- Lector queda vacío pero mantengo la función por compat con SQL_19
CREATE OR REPLACE FUNCTION current_user_es_lector_zonal() RETURNS BOOLEAN
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT FALSE;
$$;

COMMIT;
