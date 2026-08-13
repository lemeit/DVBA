-- ═══════════════════════════════════════════════════════════════
-- SQL_14 · Alias colaborativo de Caminos Secundarios · v8.70c
--
-- Tabla para que técnicos/vecinos puedan sumar nombres "vulgares"
-- o comunes a los caminos identificados oficialmente por NOMEMCLATURA.
--
-- Ejemplo:
--   nomenclatura: "093-08"
--   denominacion_oficial: "Saladillo - RP 51 (Tramo 1)"
--   alias_locales: ["Camino a Los Molles", "Camino de los Molinos"]
--   denominacion_local: "Camino a Los Molles (por el molino viejo)"
--
-- Contra el geojson (fuente autoritativa): denominación oficial
-- viene del CSV SALADILLO_RED. Este catálogo NO edita el geojson,
-- solo agrega una capa de metadata que el usuario final puede
-- consultar y filtrar en el portal.
-- ═══════════════════════════════════════════════════════════════

-- v8.71 · Alias POR TRAMO · un mismo NOMEMCLATURA (ej. 093-13) puede tener
--         múltiples tramos con nombres populares distintos. UNIQUE compuesto.
CREATE TABLE IF NOT EXISTS public.caminos_alias (
    id              BIGSERIAL PRIMARY KEY,
    nomenclatura    TEXT      NOT NULL,          -- ej. "093-08"
    tramo_num       TEXT      NOT NULL DEFAULT 'ALL',  -- ej. "1", "2" o "ALL" (camino completo)
    zona            TEXT      NOT NULL DEFAULT 'VI',
    partido         TEXT,                        -- ej. "Saladillo" (redundante, para consulta rápida)
    denominacion_oficial TEXT,                   -- copia de la denom oficial al momento de crear el alias
    alias_locales   TEXT[]    DEFAULT ARRAY[]::TEXT[],  -- ["Camino a X", "Camino del Y"]
    denominacion_local  TEXT,                    -- alternativa completa del nombre común
    observaciones   TEXT,                        -- contexto libre ("por el molino viejo", "carga fuerte en época de cosecha")
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by      UUID REFERENCES auth.users(id),
    updated_by      UUID REFERENCES auth.users(id),
    CONSTRAINT caminos_alias_nom_tramo_uk UNIQUE (nomenclatura, tramo_num)
);

CREATE INDEX IF NOT EXISTS idx_caminos_alias_nomencl ON public.caminos_alias (nomenclatura);
CREATE INDEX IF NOT EXISTS idx_caminos_alias_nomencl_tramo ON public.caminos_alias (nomenclatura, tramo_num);
CREATE INDEX IF NOT EXISTS idx_caminos_alias_zona    ON public.caminos_alias (zona);
CREATE INDEX IF NOT EXISTS idx_caminos_alias_partido ON public.caminos_alias (partido);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION public.set_caminos_alias_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_caminos_alias_upd ON public.caminos_alias;
CREATE TRIGGER trg_caminos_alias_upd
BEFORE UPDATE ON public.caminos_alias
FOR EACH ROW
EXECUTE FUNCTION public.set_caminos_alias_updated_at();

-- ═══════════════════════════════════════════════════════════════
-- RLS · Row Level Security
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.caminos_alias ENABLE ROW LEVEL SECURITY;

-- SELECT · público sin login (los alias son data institucional consultable)
DROP POLICY IF EXISTS caminos_alias_select_anon ON public.caminos_alias;
CREATE POLICY caminos_alias_select_anon
    ON public.caminos_alias FOR SELECT
    TO anon
    USING (true);

DROP POLICY IF EXISTS caminos_alias_select_auth ON public.caminos_alias;
CREATE POLICY caminos_alias_select_auth
    ON public.caminos_alias FOR SELECT
    TO authenticated
    USING (true);

-- INSERT / UPDATE · técnicos de la zona correspondiente + gerencia + admin
DROP POLICY IF EXISTS caminos_alias_insert_tech ON public.caminos_alias;
CREATE POLICY caminos_alias_insert_tech
    ON public.caminos_alias FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.usuarios_perfil up
            WHERE up.user_id = auth.uid()
              AND up.rol IN ('tecnico', 'gerencia', 'admin')
              AND (up.rol IN ('gerencia', 'admin') OR up.zona = caminos_alias.zona)
        )
    );

DROP POLICY IF EXISTS caminos_alias_update_tech ON public.caminos_alias;
CREATE POLICY caminos_alias_update_tech
    ON public.caminos_alias FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios_perfil up
            WHERE up.user_id = auth.uid()
              AND up.rol IN ('tecnico', 'gerencia', 'admin')
              AND (up.rol IN ('gerencia', 'admin') OR up.zona = caminos_alias.zona)
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.usuarios_perfil up
            WHERE up.user_id = auth.uid()
              AND up.rol IN ('tecnico', 'gerencia', 'admin')
              AND (up.rol IN ('gerencia', 'admin') OR up.zona = caminos_alias.zona)
        )
    );

-- DELETE · solo admin
DROP POLICY IF EXISTS caminos_alias_delete_admin ON public.caminos_alias;
CREATE POLICY caminos_alias_delete_admin
    ON public.caminos_alias FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.usuarios_perfil up
            WHERE up.user_id = auth.uid()
              AND up.rol = 'admin'
        )
    );

-- ═══════════════════════════════════════════════════════════════
-- Verificación
-- ═══════════════════════════════════════════════════════════════
-- SELECT count(*) FROM public.caminos_alias;
-- SELECT * FROM public.caminos_alias WHERE zona = 'VI' ORDER BY updated_at DESC LIMIT 10;
