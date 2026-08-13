-- ═══════════════════════════════════════════════════════════════
-- SQL_14b · Migración caminos_alias · alias POR TRAMO · v8.71
--
-- Contexto: la versión original de SQL_14 usaba UNIQUE(nomenclatura)
-- pero un mismo código NOMEMCLATURA (ej. 093-13) puede tener varios
-- tramos geográficamente distintos, cada uno con nombres populares
-- diferentes. Este SQL:
--   1. Agrega columna tramo_num (si no existe)
--   2. Elimina el UNIQUE viejo sobre nomenclatura
--   3. Crea nuevo UNIQUE sobre (nomenclatura, tramo_num)
--
-- Corré este SQL SOLO SI ya corriste SQL_14 antes.
-- Si empezás desde 0, corré directamente el SQL_14 actualizado
-- que ya incluye estos cambios.
-- ═══════════════════════════════════════════════════════════════

-- 1) Agregar columna tramo_num (idempotente)
ALTER TABLE public.caminos_alias
    ADD COLUMN IF NOT EXISTS tramo_num TEXT;

-- 2) Backfill: para filas existentes sin tramo, marcar como 'ALL'
--    (significa que el alias aplica al camino completo, no a un tramo)
UPDATE public.caminos_alias
    SET tramo_num = 'ALL'
    WHERE tramo_num IS NULL;

-- 3) Hacer tramo_num NOT NULL con default 'ALL'
ALTER TABLE public.caminos_alias
    ALTER COLUMN tramo_num SET DEFAULT 'ALL';
ALTER TABLE public.caminos_alias
    ALTER COLUMN tramo_num SET NOT NULL;

-- 4) Eliminar el UNIQUE viejo sobre nomenclatura
DO $$
DECLARE constraint_name TEXT;
BEGIN
    SELECT conname INTO constraint_name
    FROM pg_constraint
    WHERE conrelid = 'public.caminos_alias'::regclass
      AND contype = 'u'
      AND array_length(conkey, 1) = 1;
    IF constraint_name IS NOT NULL THEN
        EXECUTE format('ALTER TABLE public.caminos_alias DROP CONSTRAINT %I', constraint_name);
    END IF;
END $$;

-- 5) Crear el nuevo UNIQUE compuesto
ALTER TABLE public.caminos_alias
    DROP CONSTRAINT IF EXISTS caminos_alias_nom_tramo_uk;
ALTER TABLE public.caminos_alias
    ADD CONSTRAINT caminos_alias_nom_tramo_uk UNIQUE (nomenclatura, tramo_num);

-- 6) Índice adicional para búsquedas por tramo
CREATE INDEX IF NOT EXISTS idx_caminos_alias_nomencl_tramo
    ON public.caminos_alias (nomenclatura, tramo_num);

-- ═══════════════════════════════════════════════════════════════
-- Verificación
-- ═══════════════════════════════════════════════════════════════
-- SELECT nomenclatura, tramo_num, alias_locales FROM public.caminos_alias
--   ORDER BY nomenclatura, tramo_num;
-- Debería aceptar múltiples filas con el mismo nomenclatura pero distinto tramo_num
