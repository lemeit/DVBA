-- SQL 0 — Ajustes de schema para bulk insert de partes históricos
-- v7.62 · Bloque 3 Sesión 1
-- Ejecutar UNA SOLA VEZ antes del bulk insert de partes.

ALTER TABLE partes_diarios 
  ADD COLUMN IF NOT EXISTS combustible_l numeric,
  ADD COLUMN IF NOT EXISTS mezcla_asfaltica_tn numeric;

-- Verificar
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'partes_diarios' 
  AND column_name IN ('combustible_l', 'mezcla_asfaltica_tn');
