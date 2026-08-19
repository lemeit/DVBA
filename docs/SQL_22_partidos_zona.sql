-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_22 · Tabla partidos_zona · mapeo partido → zona DVBA
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-19
-- Autor: DVBA Zona VI Saladillo
--
-- CONTEXTO
--   Hoy el mapping partido→zona vive solo en el frontend
--   (datos/referencias/partidos_pba.json, cargado en index.html línea ~4405).
--   Para que la BD pueda derivar la zona correcta según el partido de un
--   registro (independiente de quién lo cargue), necesitamos ese mapping
--   como tabla consultable.
--
-- ESTRUCTURA
--   partido_numero  · int PK · numero oficial ARBA (1..137)
--   nombre          · text UNIQUE · nombre canónico (con tildes)
--   zona            · text NOT NULL · código romano de zona DVBA (I..XII)
--   aliases         · text[] · variantes ortográficas comunes (25 de Mayo,
--                    9 de Julio, etc.) para hacer lookup case-insensitive.
--
-- FUENTE
--   ARBA + D.A.D.P. 194/2013 + rutas_partidos.csv (Luciano 2026-08-03).
--   135 partidos + 2 aliases numéricos (25/9 de Mayo/Julio).
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

CREATE TABLE IF NOT EXISTS partidos_zona (
  partido_numero INT PRIMARY KEY,
  nombre TEXT UNIQUE NOT NULL,
  zona TEXT NOT NULL CHECK (zona IN ('I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII')),
  aliases TEXT[] DEFAULT ARRAY[]::TEXT[]
);

COMMENT ON TABLE partidos_zona IS 'Mapping oficial partido → zona vial DVBA. Fuente: ARBA + Luciano 2026-08-03.';

-- Idempotente: TRUNCATE + INSERT (permite re-correr para actualizar)
TRUNCATE TABLE partidos_zona;

INSERT INTO partidos_zona (partido_numero, nombre, zona) VALUES
  (   1, 'Adolfo Alsina', 'VIII'),
  (   2, 'Alberti', 'V'),
  (   3, 'Almirante Brown', 'III'),
  (   4, 'Avellaneda', 'III'),
  (   5, 'Ayacucho', 'X'),
  (   6, 'Azul', 'IX'),
  (   7, 'Bahía Blanca', 'XI'),
  (   8, 'Balcarce', 'X'),
  (   9, 'Baradero', 'I'),
  (  10, 'Arrecifes', 'I'),
  (  11, 'Bolívar', 'VIII'),
  (  12, 'Bragado', 'V'),
  (  13, 'Brandsen', 'III'),
  (  14, 'Campana', 'II'),
  (  15, 'Cañuelas', 'III'),
  (  16, 'Carlos Casares', 'VIII'),
  (  17, 'Carlos Tejedor', 'IV'),
  (  18, 'Carmen de Areco', 'I'),
  (  19, 'Daireaux', 'VIII'),
  (  20, 'Castelli', 'VII'),
  (  21, 'Colón', 'I'),
  (  22, 'Coronel Dorrego', 'XI'),
  (  23, 'Coronel Pringles', 'XI'),
  (  24, 'Coronel Suárez', 'XI'),
  (  25, 'Lanús', 'III'),
  (  26, 'Chacabuco', 'V'),
  (  27, 'Chascomús', 'III'),
  (  28, 'Chivilcoy', 'V'),
  (  29, 'Dolores', 'VII'),
  (  30, 'Esteban Echeverría', 'III'),
  (  31, 'Exaltación de la Cruz', 'II'),
  (  32, 'Florencio Varela', 'III'),
  (  33, 'General Alvarado', 'X'),
  (  34, 'General Alvear', 'VI'),
  (  35, 'General Arenales', 'IV'),
  (  36, 'General Belgrano', 'III'),
  (  37, 'General Guido', 'VII'),
  (  38, 'Zárate', 'III'),
  (  39, 'General Juan Madariaga', 'VII'),
  (  40, 'General La Madrid', 'IX'),
  (  41, 'General Las Heras', 'VI'),
  (  42, 'General Lavalle', 'VII'),
  (  43, 'General Paz', 'III'),
  (  44, 'General Pinto', 'IV'),
  (  45, 'General Pueyrredón', 'X'),
  (  46, 'General Rodríguez', 'II'),
  (  47, 'General San Martín', 'II'),
  (  49, 'General Viamonte', 'IV'),
  (  50, 'General Villegas', 'IV'),
  (  51, 'Adolfo Gonzales Chaves', 'XII'),
  (  52, 'Guaminí', 'VIII'),
  (  53, 'Benito Juárez', 'XII'),
  (  54, 'Junín', 'IV'),
  (  55, 'La Plata', 'III'),
  (  56, 'Laprida', 'IX'),
  (  57, 'Tigre', 'III'),
  (  58, 'Las Flores', 'VI'),
  (  59, 'Leandro N. Alem', 'IV'),
  (  60, 'Lincoln', 'IV'),
  (  61, 'Lobería', 'XII'),
  (  62, 'Lobos', 'VI'),
  (  63, 'Lomas de Zamora', 'III'),
  (  64, 'Luján', 'II'),
  (  65, 'Magdalena', 'III'),
  (  66, 'Maipú', 'VII'),
  (  67, 'Salto', 'I'),
  (  68, 'Marcos Paz', 'II'),
  (  69, 'Mar Chiquita', 'X'),
  (  70, 'La Matanza', 'II'),
  (  71, 'Mercedes', 'II'),
  (  72, 'Merlo', 'II'),
  (  73, 'Monte', 'III'),
  (  74, 'Moreno', 'II'),
  (  75, 'Navarro', 'VI'),
  (  76, 'Necochea', 'XII'),
  (  77, 'Nueve de Julio', 'V'),
  (  78, 'Olavarría', 'IX'),
  (  79, 'Patagones', 'XI'),
  (  80, 'Pehuajó', 'VIII'),
  (  81, 'Pellegrini', 'VIII'),
  (  82, 'Pergamino', 'I'),
  (  83, 'Pila', 'VII'),
  (  84, 'Pilar', 'II'),
  (  85, 'Puan', 'XI'),
  (  86, 'Quilmes', 'III'),
  (  87, 'Ramallo', 'I'),
  (  88, 'Rauch', 'IX'),
  (  89, 'Rivadavia', 'VIII'),
  (  90, 'Rojas', 'I'),
  (  91, 'Roque Pérez', 'VI'),
  (  92, 'Saavedra', 'XI'),
  (  93, 'Saladillo', 'VI'),
  (  94, 'San Andrés de Giles', 'III'),
  (  95, 'San Antonio de Areco', 'III'),
  (  96, 'San Fernando', 'III'),
  (  97, 'San Isidro', 'III'),
  (  98, 'San Nicolás', 'I'),
  (  99, 'San Pedro', 'I'),
  ( 100, 'San Vicente', 'III'),
  ( 101, 'Morón', 'II'),
  ( 102, 'Suipacha', 'V'),
  ( 103, 'Tandil', 'X'),
  ( 104, 'Tapalqué', 'IX'),
  ( 105, 'Tordillo', 'VII'),
  ( 106, 'Tornquist', 'XI'),
  ( 107, 'Trenque Lauquen', 'VIII'),
  ( 108, 'Tres Arroyos', 'XII'),
  ( 109, 'Veinticinco de Mayo', 'VI'),
  ( 110, 'Vicente López', 'III'),
  ( 111, 'Villarino', 'XI'),
  ( 113, 'Coronel de Marina Leonardo Rosales', 'XI'),
  ( 114, 'Berisso', 'III'),
  ( 115, 'Ensenada', 'III'),
  ( 116, 'San Cayetano', 'XII'),
  ( 117, 'Tres de Febrero', 'III'),
  ( 118, 'Escobar', 'II'),
  ( 119, 'Hipólito Yrigoyen', 'VIII'),
  ( 120, 'Berazategui', 'III'),
  ( 121, 'Capitán Sarmiento', 'I'),
  ( 122, 'Salliqueló', 'VIII'),
  ( 123, 'La Costa', 'VII'),
  ( 124, 'Pinamar', 'VII'),
  ( 125, 'Villa Gesell', 'VII'),
  ( 126, 'Monte Hermoso', 'XI'),
  ( 127, 'Tres Lomas', 'VIII'),
  ( 128, 'Florentino Ameghino', 'IV'),
  ( 129, 'Presidente Perón', 'III'),
  ( 130, 'Ezeiza', 'III'),
  ( 131, 'San Miguel', 'III'),
  ( 132, 'José C. Paz', 'II'),
  ( 133, 'Malvinas Argentinas', 'II'),
  ( 134, 'Punta Indio', 'III'),
  ( 135, 'Hurlingham', 'II'),
  ( 136, 'Ituzaingó', 'II'),
  ( 137, 'Lezama', 'III');

-- Aliases numéricos (25/9 de Mayo/Julio) — el frontend los usa por partidos_geo
UPDATE partidos_zona SET aliases = ARRAY['25 de Mayo','25 De Mayo','25 de mayo']
  WHERE nombre = 'Veinticinco de Mayo';
UPDATE partidos_zona SET aliases = ARRAY['9 de Julio','9 De Julio','9 de julio']
  WHERE nombre = 'Nueve de Julio';

-- Índice para lookup case-insensitive por nombre
CREATE INDEX IF NOT EXISTS idx_partidos_zona_nombre_lower ON partidos_zona (LOWER(nombre));
CREATE INDEX IF NOT EXISTS idx_partidos_zona_aliases ON partidos_zona USING GIN (aliases);

-- ─────────────────────────────────────────────────────────────────────────────
-- Función helper: dado un nombre de partido (o alias), devolver la zona DVBA
-- Tolera diferencias de case y compara contra nombre + aliases.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION zona_por_partido(p_nombre TEXT) RETURNS TEXT
  LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT zona FROM partidos_zona
     WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))
        OR EXISTS (
             SELECT 1 FROM unnest(aliases) AS a
             WHERE LOWER(a) = LOWER(TRIM(p_nombre))
           )
     LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION zona_por_partido(TEXT) TO authenticated;
GRANT SELECT ON partidos_zona TO authenticated;

COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
-- SELECT COUNT(*) FROM partidos_zona;                          -- 135
-- SELECT zona_por_partido('Saladillo');                        -- VI
-- SELECT zona_por_partido('25 de Mayo');                       -- VI (por alias)
-- SELECT zona_por_partido('  la plata  ');                     -- III (trim + lower)
-- SELECT nombre, zona FROM partidos_zona ORDER BY zona, nombre;
