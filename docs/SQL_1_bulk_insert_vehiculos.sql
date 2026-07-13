-- SQL 1 — Bulk insert de vehículos (Zona VI Saladillo)
-- v7.62 · Bloque 3 Sesión 1
-- 49 filas válidas del CSV vehiculos.csv (7/7/2026).
-- Ejecutar DESPUÉS del SQL 1 (constraints UNIQUE + maquinarias faltantes).

INSERT INTO vehiculos (identificador, numero, tipo_maquinaria, marca, modelo, descripcion, observaciones, activo) VALUES
  ('O.I.', '21806', 'TRACTOR', 'Massey Ferguson', '4292K', 'Año 2017 · Comb. G.O. · Dominio DIZ09 · Z6 - SALADILLO', NULL, true),
  ('O.I.', '21715', 'TRACTOR', 'Massey Ferguson', '4292K', 'Año 2016 · Comb. G.O. · Dominio DDY87 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '9649', 'TRACTOR', 'Massey Ferguson', 'MF1615-S', 'Año 1996 · Comb. G.O. · Z6 - SALADILLO', 'FUERA DE SERVICIO', false),
  ('O.I.', '9667', 'TRACTOR', 'Massey Ferguson', 'MF1615-S', 'Año 1996 · Comb. G.O. · Z6 - SALADILLO', NULL, true),
  ('O.I.', '9734', 'TRACTOR', 'Massey Ferguson', NULL, 'Comb. G.O. · Z6 - LOBOS', NULL, true),
  ('O.I.', '21503', 'TRACTOR', 'Pauny', NULL, 'Comb. G.O.', NULL, true),
  ('O.I.', '9626', 'TRACTOR', NULL, NULL, 'Comb. G.O. · Z6 - SALADILLO', 'FUERA DE SERVICIO', false),
  ('O.I.', '9631', 'TRACTOR', 'Massey Ferguson', 'MF1615-S', 'Año 1996 · Comb. G.O. · Z6 - SALADILLO', NULL, true),
  ('O.I.', '2084', 'RETROEXCAVADORA', 'Volvo', NULL, 'Comb. G.O. · Z6 - SALADILLO', NULL, true),
  ('O.I.', '21202', 'MINI CARGADORA', 'Bobcat', 'SS650', 'Año 2012 · Comb. G.O. · Dominio CIZ77 · Z6 - SALADILLO', NULL, true),
  ('O.I.', '21803', 'DESMALEZADORA', NULL, NULL, 'Comb. N/A', NULL, true),
  ('O.I.', '21502', 'DESMALEZADORA', 'Yomel', '1550 BRL', 'Año 2015 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '24', 'TANQUE COMBUSTIBLE', NULL, NULL, 'Z6 - SALADILLO', NULL, true),
  ('O.I.', '8653', 'MOTONIVELADORA', 'Klia', NULL, 'Comb. G.O. · Z6 - SALADILLO', NULL, true),
  ('O.I.', '22108', 'MOTONIVELADORA', 'Lovol', NULL, 'Comb. G.O. · Dominio EBZ60 · Z6 - SALADILLO', NULL, true),
  ('O.I.', '2066', 'MOTONIVELADORA', 'Fiat Allis', NULL, 'Comb. G.O.', NULL, true),
  ('O.I.', '2067', 'RETROEXCAVADORA', 'Fiat Allis', NULL, 'Comb. G.O.', NULL, true),
  ('O.I.', '22127', 'RETROPALA', 'Case', NULL, 'Año 2019 · Comb. G.O. · Dominio EBZ63 · Z6 - SALADILLO', NULL, true),
  ('O.I.', '22121', 'REMOLQUE', 'Comar', NULL, 'Año 2019 · Dominio AD798IE · Z6 - SALADILLO', NULL, true),
  ('O.I.', '21211', 'REMOLQUE', 'Comar', NULL, 'Año 2012 · Dominio LNX118 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '18736', 'CAMIÓN', 'Mercedes Benz', '1114', 'Año 1986 · Comb. G.O. · Dominio WPJ559 · Z6 - LOBOS', NULL, true),
  ('R.O.', '18748', 'CAMIÓN', 'Mercedes Benz', '1114', 'Año 1986 · Comb. G.O. · Dominio WPJ556 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '18775', 'CAMIÓN', 'Mercedes Benz', '1114', 'Año 1986 · Comb. G.O. · Dominio WPJ544 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '18785', 'CAMIÓN', 'Mercedes Benz', '1114', 'Año 1986 · Comb. G.O. · Dominio WPJ541 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '18805', 'CAMIÓN', 'Mercedes Benz', '1114', 'Año 1986 · Comb. G.O. · Dominio WPJ550 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '40990', 'CAMIÓN', 'Ford', '1722 Cargo', 'Año 2012 · Comb. G.O. · Dominio LOU570 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '41020', 'CAMIÓN', 'Ford', '1722 Cargo', 'Año 2012 · Comb. G.O. · Dominio LXA291 · Z6 - SALADILLO', NULL, true),
  ('O.I.', '1721', 'FURGONETA', 'Peugeot', 'Partner', 'Año 2017 · Comb. G.O. · Dominio AB156OR · Z6 - SALADILLO', NULL, true),
  ('R.O.', '41890', 'FURGONETA', 'Citroen', 'Berlingo', 'Año 2011 · Dominio JWD825 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '52501', 'FURGONETA', 'Peugeot', 'Partner', 'Año 2015 · Comb. G.O. · Dominio OPG584 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '58191', 'FURGONETA', 'Peugeot', 'Partner', 'Comb. G.O. · Z6 - SALADILLO', NULL, true),
  ('O.I.', '1211', 'CAMIONETA', 'Citroen', 'Berlingo', 'Año 2012 · Dominio LBL152 · Z6 - LOBOS', NULL, true),
  ('R.O.', '19084', 'CAMIONETA', 'Ford', 'F-100', 'Año 1986 · Comb. G.O. · Dominio URV086 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '26395', 'CAMIONETA', 'Nissan', 'Pathfinder', 'Año 2001 · Dominio BTY831 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '29792', 'CAMIONETA', 'Nissan', 'Pathfinder', 'Año 2001 · Dominio DTL166 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '31556', 'CAMIONETA', 'Ford', 'Ranger', 'Año 2005 · Comb. G.O. · Dominio FAQ165 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '36895', 'CAMIONETA', 'Ford', 'Ranger', 'Año 2006 · Comb. G.O. · Dominio FJS659 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '37073', 'CAMIONETA', 'Ford', 'Ranger', 'Año 2005 · Dominio EZE309 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '41893', 'CAMIONETA', 'Ford', 'Ranger', 'Año 2009 · Comb. G.O. · Dominio ICZ224 · Z6 - LOBOS', NULL, true),
  ('O.I.', '2918', 'CAMIONETA', 'Ford', 'Ranger', 'Comb. G.O. · Dominio IAG449 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '44808', 'CAMIONETA', 'Chevrolet', 'S10', 'Año 2011 · Dominio JUQ814 · Z6 - SALADILLO', NULL, true),
  ('O.I.', '1307', 'CAMIONETA', 'Chevrolet', 'S10', 'Comb. G.O. · Dominio MUC016 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '51385', 'CAMIONETA', 'Toyota', 'Hilux', 'Año 2016 · Comb. G.O. · Dominio AA801RE · Z6 - SALADILLO', NULL, true),
  ('R.O.', '51423', 'CAMIONETA', 'Toyota', 'Hilux', 'Año 2017 · Comb. G.O. · Dominio AB333WE · Z6 - SALADILLO', NULL, true),
  ('R.O.', '51426', 'CAMIONETA', 'Peugeot', 'Partner', 'Año 2016 · Dominio POL990 · Z6 - SALADILLO', NULL, true),
  ('R.O.', '41125', 'CAMIONETA', 'Ford', 'Ranger', NULL, NULL, true),
  ('R.O.', '41800', 'FURGONETA', 'Citroen', 'Berlingo', NULL, NULL, true),
  ('R.O.', '43742', 'CAMIONETA', 'Ford', 'Ranger', NULL, NULL, true),
  ('R.O.', '52504', 'FURGONETA', 'Peugeot', 'Partner', NULL, NULL, true);

-- Total insertado: 49 filas (skip: 28 por datos incompletos/tipos desconocidos)

-- Verificar
SELECT identificador, tipo_maquinaria, COUNT(*) FROM vehiculos GROUP BY identificador, tipo_maquinaria ORDER BY 1,2;