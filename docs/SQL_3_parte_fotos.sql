-- SQL 3 — Tabla parte_fotos (modelo unificado sin duplicados)
-- v7.63 · Bloque 3 Sesión 2B
--
-- Vincula fotos (que existen como relevamientos con GPS + sello) a los partes diarios.
-- Cada foto vive UNA SOLA VEZ en la tabla `relevamientos` (que ya usa la app móvil).
-- Los partes reutilizan esas fotos apuntando por relevamiento_id.
-- Esto permite que:
--   • Un mismo relevamiento pueda asociarse a múltiples partes.
--   • Una foto subida desde la app de partes (etapa 2) cree un relevamiento
--     que también aparezca en el mapa del portal, sin duplicar.

CREATE TABLE IF NOT EXISTS parte_fotos (
  parte_id         bigint NOT NULL REFERENCES partes_diarios(id) ON DELETE CASCADE,
  relevamiento_id  bigint NOT NULL,  -- FK lógica a relevamientos.id (sin ON DELETE porque no queremos borrar el vínculo si el relevamiento se re-numera)
  momento          text   NOT NULL CHECK (momento IN ('previa', 'posterior')),
  orden            smallint NOT NULL DEFAULT 1,
  created_at       timestamptz DEFAULT NOW(),
  PRIMARY KEY (parte_id, relevamiento_id, momento)
);

CREATE INDEX IF NOT EXISTS idx_parte_fotos_parte ON parte_fotos(parte_id);
CREATE INDEX IF NOT EXISTS idx_parte_fotos_rel   ON parte_fotos(relevamiento_id);

-- RLS: cualquier autenticado lee/escribe (mismo patrón que otras tablas del módulo)
ALTER TABLE parte_fotos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS parte_fotos_read_auth ON parte_fotos;
CREATE POLICY parte_fotos_read_auth ON parte_fotos
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS parte_fotos_write_auth ON parte_fotos;
CREATE POLICY parte_fotos_write_auth ON parte_fotos
  FOR ALL USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Verificar
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'parte_fotos'
ORDER BY ordinal_position;
