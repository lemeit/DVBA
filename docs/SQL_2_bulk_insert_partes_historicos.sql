-- SQL 2 v2 — Bulk insert de partes históricos + parte_maquinarias
-- v7.62 · Bloque 3 Sesión 1 · REGENERADO sin km_recorridos (columna generated)
-- Postgres calcula km_recorridos = prog_fin - prog_ini automáticamente.
-- 632 filas del CSV partes_historicos.csv (7/7/2026).
-- Ejecutar DESPUÉS del SQL 0 (ALTER TABLE) y SQL 1 (vehículos cargados).

BEGIN;
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-06'::date, 2, 'rp', 'RP51', 318.8, 319.0,
    'La fecha registrada en las fotográficas del programa GPS Map Camera no es coincidente con la fecha real de la captura (tareas del 6/3/25)', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-07'::date, 2, 'rp', 'RP51', 318.8, 319.0,
    'Segunda jornada para completar la tarea informada con fecha 6/3/25. La fecha registrada en las fotográficas del programa GPS Map Camera no es coincidente con la fecha real de la captura (tareas del 6 y 7/03/25). Las fotografías previas a la realización de la tarea fueron tomadas desde el programa propio del celular.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-10'::date, 2, 'rp', 'RP91', 32.0, 32.0,
    'Caída de árboles por inclemencias climáticas. Corte y limpieza de árboles y ramas caídas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-11'::date, 4, 'rp', 'RP30', 263.5, 263.8,
    'Colocación de señalización en EP15 (Las Flores) y en curva (límite de Zona VI/Arroyo El Gualicho, Las Flores)', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-12'::date, 4, 'rp', 'RP30', 263.5, 263.8,
    'Colocación de señalización en zona de la EP15 (Escuela en paraje "El Gualicho", Las Flores). No se registraron imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-12'::date, 1, 'camino', '093-08', 1.1, 4.2,
    'No se registran imágenes fotográficas', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-13'::date, 8, 'rp', 'RP51', 225.0, 225.05,
    'Traslado de caños (carretón OI 22121) desde Moreno a 25 de Mayo para reparación de alcantarilla.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-17'::date, 1, 'rp', 'RP91', 20.0, 52.0,
    'Tramo de Las Flores hacia Saladillo. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-18'::date, 8, 'rp', 'RP51', 225.0, 225.05,
    'Las imágenes fueron enviadas oportunamente en otro soporte. Las tareas implicaron la apertura de la traza, colocación de caños de chapa nuevos, rellenado con material de suelos de la obra y colocación de mezcla asfáltica. Para la actividad se recurrió al uso de Pala Mecánica proveniente de Chivilcoy.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895'
  UNION ALL
  SELECT (SELECT id FROM p), 5::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-18'::date, 1, 'rp', 'RP91', 0.0, 20.0,
    'Continuación del tramo de Las Flores hacia Saladillo. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-19'::date, 8, 'rp', 'RP51', 225.0, 225.05,
    'Conituación de las tareas iniciadas el 18/03/2025 para la reparación y mantenimiento de alcantarilla en zona de Laguna de Todos Los Santos.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-19'::date, 4, 'rp', 'RP51', 225.0, 226.0,
    'Colocación de "chevrones". No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-19'::date, 1, 'rp', 'RP91', 20.0, 52.0,
    'Tramo de Saladillo hacia Las Flores. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-20'::date, 8, 'rp', 'RP51', 225.0, 225.05,
    'Traslado de Retroexcavadora (carretón OI 22121) desde 25 de Mayo a Saladillo luego de obra de reparación de alcantarilla Lag. de Todos Los Santos.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-21'::date, 1, 'rp', 'RP91', 0.0, 20.0,
    'Conituación de corte de pasto en banquina RP91 Saladillo - Las Flores. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-25'::date, 2, 'rp', 'RP51', 224.0, 227.0,
    'Bacheo de traza en sector del pavimento en cercanías de alcantarilla reparada en Lag. de Todos Los Santos.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-25'::date, 4, 'rp', 'RP51', 309.0, 310.0,
    'Colocación de "chevrones" en RP51 ca. "Estac. Micheo".', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-26'::date, 2, 'rp', 'RP30', 263.2, 287.7,
    'Bacheo en varios puntos del pavimento en el tramo de Las Flores al límite de Zona.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-03-27'::date, 2, 'camino', '093-02', 0.0, 5.0,
    'Bacheo en acceso pavimentado a Cazón (Saladillo) desde RN205 hasta zona urbana de la localidad. No se registran imágenes.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-01'::date, 2, 'rp', 'RP51', 214.0, 225.0,
    'Bacheo de tramo desde inicio de zona hacia sector de Lag. de Todos Los Santos. Se incluyen equipos de señalización y carretón (O.I.: 22121) para traslado de equipos.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-03'::date, 2, 'rp', 'RP51', 250.0, 277.0,
    'Bacheo en tramos de RP51 desde 25 de Mayo hacia Saladillo. Se incluyen equipos de señalización (O.I.: 22121) y carretón para traslado de equipos.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-07'::date, 1, 'rp', 'RP91', 8.5, 9.8,
    '?? no se cargó. Corte de paso en zona de Rotonda "La Campana"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-08'::date, 2, 'rp', 'RP30', 263.0, 290.0,
    'Continuación de obras de bacheo en varios puntos del pavimento en el tramo de Las Flores al límite de Zona VI (ca. de "El Gualicho")', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-08'::date, 2, 'rp', 'RP51', 279.0, 279.5,
    'Obras de bacheo en vías del FFCC en RP51 y acceso a "La Barrancosa" (Saladillo).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-08'::date, 4, 'rp', 'RP30', 250.0, 282.0,
    'Colocación de señalización de curvas en tramo desde Las Flores a límite de zona ("El Gualicho").', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-09'::date, 2, 'rp', 'RP51', 225.0, 226.0,
    'Bacheo en sector de alcantarilla reparada en Lag de Todos Los Santos. Se movilizan otros equipos como señalizadores lumínicos.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-09'::date, 6, 'camino', '093-08', 0.0, 2.0,
    'Mantenimiento de caminos rurales. Ejecución de tareas incluyendo entrenamiento del personal. Se realizan series de pasadas a lo largo de la traza indicada.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-09'::date, 1, 'rp', 'RP91', 9.0, 29.0,
    'Tramo RP91 de La Campana (Saladillo) al Trigo (Las Flores).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-11'::date, 2, 'camino', '093-03', 0.0, 8.0,
    'Bacheo en sectores del tramo del acceso a Del Carril, desde RN205 a zona urbana. Se incluyen otros equipamientos como señalizadores lumínicos, carretón (OI: 22121).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-11'::date, 1, 'rp', 'RP91', 20.0, 40.0,
    'Continuación de corte de pasto en banquinas, RP91 de Saladillo a Las Flores.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-11'::date, 4, 'rp', 'RP51', 256.0, 256.0,
    'Colocación de "chevrones" en sector de Puente Ayo. Saladillo (en límite de Pdos. Saladillo-25 de Mayo)', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-14'::date, 2, 'rp', 'RP51', 327.0, 335.0,
    'Tareas de bacheo en varios sectores de la traza y en banquinas a lo largo de los kilómetros indicados. Se incluyen equipos de señalización lumínica y carretón (O.I.: 22121) para traslado de equipos pesados.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-14'::date, 6, 'camino', '093-08', 2.0, 4.0,
    'Se llevan a cabo series de pasadas a lo largo de la traza indicada.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-14'::date, 1, 'rp', 'RP51', 256.0, 277.0,
    'Corte de pasto en banquinas. Tramo desde Saladillo a 25 de Mayo.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-21'::date, 6, 'camino', '093-08', 4.0, 6.0,
    'Mantenimiento de caminos rurales. Serie de pasadas a lo pargo de la traza indicada.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-22'::date, 6, 'camino', '093-08', 6.0, 8.0,
    'Continuación de tareas de mantenimiento de caminos rurales. Serie de pasadas a lo pargo de la traza indicada.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-22'::date, 2, 'rp', 'RP51', 340.0, 350.0,
    'Bacheo en varios sectores a lo largo de la traza indicada. Se incluyen señalizadores lumínicos y carretón para traslado de equipos pesados (O.I.: 22121).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-23'::date, 2, 'rp', 'RP51', 335.0, 341.0,
    'Bacheo en varios sectores a lo largo de la traza indicada. Se incluyen señalizadores lumínicos y carretón para traslado de equipos pesados (O.I.: 22121).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-23'::date, 6, 'camino', '093-08', 8.0, 10.0,
    'Mantenimiento de caminos rurales. Se llevan a cabo series de pasadas a lo largo de la traza indicada.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-24'::date, 2, 'rp', 'RP51', 320.0, 328.0,
    'Trabajos de bacheo en sectores de ambas calzadas del tramo indicado.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-24'::date, 6, 'camino', '093-08', 10.0, 12.0,
    'Mantenimiento de caminos rurales. Se llevan a cabo series de pasadas a lo largo de la traza indicada.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-24'::date, 4, 'rp', 'RP51', 305.0, 305.05,
    'Colocación de señalizaciones en curvas del tramo.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-25'::date, 2, 'rp', 'RP51', 325.0, 335.0,
    'Trabajos de bacheo en sectores de ambas calzadas del tramo indicado. Utilización de carretón para acarreos (O.I.: 22121) y señalización lumínica.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-28'::date, 2, 'rp', 'RP51', 330.0, 340.0,
    'Continuación de trabajos de bacheo en sectores de ambas calzadas del tramo indicado. Utilización de carretón para acarreos (O.I.: 22121) y señalización lumínica.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-28'::date, 4, 'rp', 'RP51', 245.0, 250.0,
    'no se cargaron vehículos!!! Colocación de cartelería de cruces de caminos.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-29'::date, 2, 'rp', 'RP51', 225.0, 225.5,
    'Fresado y reparación de bacheos en sector de alcantarilla "Lag. de Todos Los Santos"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-04-29'::date, 2, 'camino', '093-02', 0.0, 5.0,
    'Mantenimiento y reparación de baches en colaboración con el Municipio de Saladillo a lo largo de la traza del acceso a la localidad de Cazón.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-03'::date, 1, 'rp', 'RP91', 0.0, 25.0,
    'No se registraron fotografías al momento de realizadas las tareas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-09'::date, 1, 'rp', 'RP51', 256.0, 277.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9649'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-09'::date, 2, 'rp', 'RP51', 346.0, 350.0,
    'Reparación de baches en sectores del tramo indicado.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-09'::date, 6, 'camino', '093-08', 12.0, 14.0,
    'Mantenimiento de caminos rurales.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-12'::date, 2, 'rp', 'RP51', 330.0, 345.0,
    'Se incluyen equipos de acarreo (O.I.; 22121) y señalización lumínica.', 'se cargaron', 'se cargaron', NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-12'::date, 1, 'rp', 'RP51', 250.0, 270.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9649'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-12'::date, 6, 'camino', '093-08', 14.0, 16.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-13'::date, 2, 'rp', 'RP40', 28.0, 31.0,
    'Se incluyen otros equipos para el acarreo (O.I.: 22121) y señalización lumínica.', 'se cargaron', 'se cargaron', NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-13'::date, 6, 'camino', '093-08', 16.0, 18.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-14'::date, 2, 'rp', 'RP40', 28.0, 31.0,
    'Continuación de las tareas de fresado y bacheo iniciadas el día previo (13/05/2025).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-14'::date, 4, 'rp', 'RP30', 263.0, 282.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-15'::date, 4, 'rp', 'RP51', 279.0, 280.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-15'::date, 4, 'rp', 'RP30', 263.0, 280.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-15'::date, 1, 'camino', '093-08', 2.0, 4.0,
    'Desmalezado y retiro de raíces de banquinas en camino de acceso.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-15'::date, 1, 'camino', '093-08', 0.5, 4.0,
    'se cargaron mal los vehículos', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21406'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-15'::date, 2, 'rp', 'RP51', 225.0, 225.1,
    'Fresado de pavimento en sector de "Lag. de Todos Los Santos"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21202';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-19'::date, 2, 'rp', 'RP46', 0.0, 23.0,
    'Vahículo mal cargado. Bacheo en diversos sectores del tramo indicado.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-19'::date, 1, 'camino', '093-08', 1.0, 4.0,
    'se cargó mal el OI de Desmalezadora', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21406'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-20'::date, 2, 'rp', 'RP51', 225.0, 226.1,
    'Carretón OI 22121. Señalización lumínica.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-20'::date, 6, 'camino', '093-08', 18.0, 20.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-20'::date, 4, 'rp', 'RP30', 263.0, 270.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-21'::date, 2, 'rp', 'RP51', 225.0, 240.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-21'::date, 6, 'camino', '093-08', 20.0, 22.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-21'::date, 1, 'camino', '093-13', 12.7, 17.0,
    'se cargó mal el OI de Desmalezadora. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-22'::date, 2, 'rp', 'RP51', 279.0, 279.5,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-22'::date, 1, 'camino', '093-13', 10.0, 12.0,
    'se cargó mal el OI de Desmalezadora. Acceso Cicaré (Camino secundario 093-13: no está registrado en la base de datos del formulario)', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-22'::date, 4, 'rp', 'RP30', 263.0, 282.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-22'::date, 6, 'camino', '093-08', 22.0, 24.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='8653'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-23'::date, 2, 'rp', 'RP51', 278.0, 279.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-23'::date, 2, 'camino', '093-08', 1.5, 4.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-23'::date, 2, 'camino', '093-13', 0.0, 8.0,
    'Acc. Néstor Kirchner (prolongación Av. Moreno): Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-28'::date, 2, 'camino', '093-13', 8.0, 10.0,
    'Acc. Néstor Kirchner (prolongación Av. Moreno): Camino secundario 093-13 (no está registrado en la base de datos del formulario). Reparación de baches.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-28'::date, 2, 'rp', 'RP91', 0.0, 9.0,
    'Reparación de baches.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-28'::date, 1, 'camino', '093-13', 1.0, 5.0,
    'Acc. Néstor Kirchner (prolongación Av. Moreno): Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-29'::date, 2, 'rp', 'RP51', 214.0, 239.0,
    'Reparación de baches.', 'si', 'si', NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-29'::date, 1, 'camino', '093-13', 5.0, 11.0,
    'Acc. Néstor Kirchner (prolongación Av. Moreno): Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'si', 'si', NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-29'::date, 4, 'camino', '093-13', 8.0, 10.0,
    'Acc. Néstor Kirchner (prolongación Av. Moreno): Camino secundario 093-13 (no está registrado en la base de datos del formulario). Señalización de curvas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-30'::date, 2, 'camino', '093-03', 0.0, 7.0,
    NULL, 'si', 'si', NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-05-30'::date, 1, 'camino', '093-13', 5.0, 11.0,
    'Acc. Néstor Kirchner (prolongación Av. Moreno): Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-02'::date, 1, 'rp', 'RP51', 282.7, 283.0,
    'desmalezado manual en rotonda "La Gallareta"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-03'::date, 2, 'rp', 'RP51', 265.0, 284.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-03'::date, 4, 'rp', 'RP30', 263.0, 263.8,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-04'::date, 2, 'rp', 'RP51', 250.0, 265.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-04'::date, 4, 'rp', 'RP30', 255.0, 263.8,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-04'::date, 1, 'camino', '093-05', 0.0, 2.0,
    'Prueba de tractor y cortadora: no funcionó', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21715';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-05'::date, 1, 'rp', 'RP51', 280.0, 283.0,
    'desmalezado en rotonda "La Gallareta"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-06'::date, 1, 'rp', 'RP51', 283.0, 286.0,
    'desmalezado en rotonda "La Gallareta"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-06'::date, 1, 'rp', 'RP91', 7.0, 9.0,
    'desmalezado manual en rotonda "La Campana"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-06'::date, 6, 'camino', '093-08', 0.0, 2.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-09'::date, 1, 'camino', '093-13', 8.0, 8.5,
    'Desmalezado manual en Puente Canal 16. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-09'::date, 6, 'camino', '093-08', 2.0, 4.0,
    'mantenimiento de caminos rurales (camino a "La Barrancosa")', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-09'::date, 1, 'rp', 'RP91', 9.0, 11.0,
    'desmalezado mecánico en sector de rotonda "La Campana"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-10'::date, 1, 'camino', '093-13', 5.0, 8.0,
    'desmalezado mecánico desde Rotonda "La Campana" hasta interesección de Cno. 093-05. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-10'::date, 6, 'camino', '093-08', 4.0, 6.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-11'::date, 6, 'camino', '093-08', 6.0, 8.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-11'::date, 1, 'camino', '093-13', NULL, NULL,
    'Disqueado de banquinas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-11'::date, 2, 'rp', 'RP30', 423.0, 436.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-12'::date, 6, 'camino', '093-08', 8.0, 10.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-12'::date, 2, 'rp', 'RP30', 418.0, 423.0,
    'Bacheos en varios sectores a lo largo de la traza indicada. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-12'::date, 4, 'camino', '093-13', 8.0, 9.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-13'::date, 3, 'camino', '093-13', 4.0, 7.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-18'::date, 6, 'camino', '093-08', 10.0, 12.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-18'::date, 2, 'rp', 'RP30', 403.0, 418.0,
    'Bacheos en varios sectores a lo largo de la traza indicada. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-19'::date, 6, 'camino', '093-08', 12.0, 14.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-19'::date, 8, 'rp', 'RP30', NULL, NULL,
    'Traslado de maquinaria para mantenimiento (con carretón O.I.: 22121) de alcantarillas desde RP30 (El Gualicho, Las Flores) hasta RP51 (Lag. de Todos Los Santos, 25 de Mayo)', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-23'::date, 6, 'camino', '093-08', 23.0, 25.3,
    NULL, 'Camanino 093-08 (Acc. La Barrancosa) 23-06-25', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-23'::date, 6, 'camino', '093-08', 0.0, 3.0,
    NULL, 'Camanino 093-08 (Acc. La Barrancosa) 23-06-25', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-24'::date, 6, 'camino', '093-08', 16.0, 18.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-24'::date, 2, 'rp', 'RP40', 27.0, 30.0,
    'No se registran imágenes fotográficas', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-25'::date, 6, 'camino', '093-08', 18.0, 20.0,
    'No se registran imágenes fotográficas', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-26'::date, 6, 'camino', '093-08', 20.0, 22.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-06-26'::date, 2, 'rp', 'RP47', 5.0, 20.0,
    'No se registran imágenes fotográficas', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-01'::date, 2, 'rp', 'RP30', 412.0, 417.0,
    NULL, '01-07-25 RP30', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-02'::date, 6, 'camino', '093-08', 11.0, 13.0,
    NULL, '02-07-25 Cno. 093-08', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-02'::date, 2, 'rp', 'RP30', 408.0, 415.0,
    NULL, '02-07-25 RP30', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-03'::date, 2, 'rp', 'RP30', 408.0, 413.0,
    'Continuación de tareas de bacheo del día 02/07/25', '03-07-25 RP30', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-03'::date, 6, 'camino', '093-08', 13.0, 15.0,
    NULL, '03-07-25 Cno. 093-08', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='36895';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-04'::date, 4, 'rp', 'RP91', 30.0, 40.0,
    'Recolección de cartelería para reparación/recambio', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-11'::date, 1, 'rp', 'RP51', 287.0, 287.2,
    'Remoción de troncos en banquina', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-14'::date, 1, 'rp', 'RP51', 277.0, 280.0,
    'Corte de pasto en banquinas y en predio de Zona VI (CEVIS)', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9649'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21502';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-17'::date, 2, 'rp', 'RP30', 415.0, 417.0,
    NULL, 'RP30 17-07-25', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-18'::date, 2, 'rp', 'RP30', 414.0, 418.0,
    'Continuación de tareas de bacheo del día 17/07/25', '18-07-25 RP30', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-18'::date, 6, 'camino', '109-07', 0.0, 4.0,
    NULL, '18-07-25 Pedernales', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-21'::date, 4, 'rp', 'RP41', 188.0, 192.0,
    'Colocación de señalización de curvas en acceso a Laguna de Navarro', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-21'::date, 2, 'rp', 'RP51', 240.0, 244.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-22'::date, 2, 'rp', 'RP91', 9.0, 12.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-23'::date, 2, 'rp', 'RP30', 418.0, 420.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-23'::date, 6, 'camino', '093-08', 15.0, 17.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-24'::date, 2, 'rp', 'RP30', 419.0, 422.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-24'::date, 6, 'camino', '093-08', 17.0, 19.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-28'::date, 2, 'rp', 'RP30', 422.0, 425.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-28'::date, 6, 'camino', '093-08', 19.0, 21.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-29'::date, 2, 'rp', 'RP30', 425.0, 427.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-29'::date, 2, 'rp', 'RP51', 239.0, 242.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-29'::date, 6, 'camino', '093-08', 21.0, 23.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-30'::date, 2, 'rp', 'RP51', 237.0, 239.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-07-30'::date, 6, 'camino', '093-08', 23.0, 25.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-04'::date, 2, 'rp', 'RP51', 318.0, 319.0,
    NULL, '04-08-2025', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-04'::date, 1, 'rp', 'RP51', 282.0, 283.0,
    'Corte de pasto en Rot. "La Gallareta"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-04'::date, 1, 'rp', 'RP91', 8.5, 9.5,
    'Corte de pasto en Rot. "La Campana"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-05'::date, 6, 'camino', '093-08', 4.0, 6.0,
    NULL, '05-08-25 093-08', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-05'::date, 2, 'rp', 'RP51', 333.0, 340.0,
    NULL, '05-08-25 RP51', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-05'::date, 1, 'rp', 'RP91', 0.0, 9.0,
    NULL, '05-08-25 RP91', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-06'::date, 6, 'camino', '093-08', 6.0, 8.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-06'::date, 2, 'rp', 'RP51', 278.0, 279.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-06'::date, 2, 'rp', 'RP51', 317.0, 320.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-06'::date, 1, 'rp', 'RP51', 277.5, 279.0,
    'Disqueado de banquinas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-07'::date, 2, 'camino', '093-03', 2.0, 4.0,
    'Bacheo en "Acc. a Del Carril"', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-07'::date, 6, 'camino', '093-08', 8.0, 10.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-07'::date, 3, 'rp', 'RP51', 279.0, 279.6,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-07'::date, 4, 'rp', 'RP51', 256.0, 257.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-07'::date, 1, 'rp', 'RP91', 0.0, 6.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-08'::date, 2, 'rp', 'RP51', 277.0, 280.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-08'::date, 2, 'camino', '093-03', 4.0, 6.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-08'::date, 1, 'rp', 'RP91', 8.0, 10.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-11'::date, 1, 'camino', '093-13', 1.0, 2.0,
    'Corte de ramas, desmalezado de cunetas. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-12'::date, 3, 'camino', '093-13', 0.0, 0.2,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', '12-08-25', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 5::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-12'::date, 4, 'rp', 'RP30', 263.0, 264.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-13'::date, 3, 'camino', '093-13', 0.2, 0.5,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', '13-08-25', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 5::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-14'::date, 3, 'camino', '093-13', 0.5, 0.7,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', '14-08-25', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 5::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-14'::date, 6, 'rp', 'RP44', 30.0, 31.7,
    NULL, '14-08-25 Villa Moll', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-15'::date, 6, 'rp', 'RP44', 31.7, 34.4,
    NULL, '15-08-25 Navarro', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-18'::date, 3, 'camino', '093-13', 0.5, 0.7,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 5::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-22'::date, 2, 'rp', 'RP51', 273.0, 276.0,
    NULL, '22-08-25 RP51', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-25'::date, 2, 'rp', 'RP51', 229.0, 235.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-26'::date, 2, 'rp', 'RP51', 220.0, 225.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='37073';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-27'::date, 2, 'rp', 'RP30', 422.0, 425.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-27'::date, 3, 'camino', '093-13', 0.7, 1.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', '27-08-25 093-13', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-28'::date, 2, 'rp', 'RP30', 425.0, 427.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-28'::date, 3, 'camino', '093-13', 1.0, 1.15,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-08-29'::date, 3, 'camino', '093-13', 1.1, 1.2,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', '29-08-25 093-13', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-02'::date, 2, 'rp', 'RP30', 427.0, 430.0,
    NULL, '02-09-25 RP30', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-03'::date, 2, 'rp', 'RP51', 340.0, 345.0,
    NULL, '03-09-25 RP51', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-04'::date, 2, 'rp', 'RP30', 270.0, 275.0,
    NULL, '04-09-25 RP30', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-05'::date, 2, 'rp', 'RP51', 278.0, 279.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-05'::date, 2, 'camino', '093-02', 0.0, 4.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-08'::date, 2, 'rp', 'RP30', 265.0, 270.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-08'::date, 6, 'camino', '093-08', 0.0, 4.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-09'::date, 6, 'camino', '093-08', 4.0, 8.0,
    NULL, '09-09-25 093-08', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-09'::date, 3, 'rp', 'RP51', 255.5, 256.5,
    NULL, '09-09-25 RP51 Calzado banquinas', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-09'::date, 4, 'rp', 'RP51', 256.0, 256.7,
    NULL, '09-09-25 RP51 Señalización curva', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-09'::date, 1, 'rp', 'RP51', 266.0, 276.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-10'::date, 1, 'camino', '093-08', 1.0, 2.0,
    'Desmalezado manual.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-10'::date, 6, 'camino', '093-08', 8.0, 12.0,
    NULL, '10-09-25 093-08', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-10'::date, 1, 'rp', 'RP51', 255.0, 266.0,
    NULL, '10-09-25 RP51 Corte de Paso y Señalización', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-10'::date, 4, 'rp', 'RP51', 262.0, 263.0,
    'Colocación de señalización en curva.', '10-09-25 RP51 Corte de Paso y Señalización', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-11'::date, 6, 'camino', '093-08', 12.0, 14.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-11'::date, 2, 'rp', 'RP41', 139.0, 145.0,
    NULL, '11-09-25 RP41', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-11'::date, 1, 'rp', 'RP51', 250.0, 255.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-12'::date, 1, 'camino', '093-08', 1.0, 1.2,
    'Desmalezado manual.', '12-09-25 093-08 ACC. EL CRISTO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-12'::date, 1, 'rp', 'RP51', 245.0, 250.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-12'::date, 6, 'camino', '093-08', 14.0, 16.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-15'::date, 1, 'rp', 'RP51', 240.0, 245.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-16'::date, 6, 'camino', '093-08', 16.0, 18.0,
    NULL, '16-09-25 093-08', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-16'::date, 1, 'rp', 'RP51', 220.0, 240.0,
    NULL, '16-09-25 RP51 y Cno. 093-08 Corte de pasto', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-16'::date, 1, 'camino', '093-08', 1.2, 1.4,
    'Desmalezado manual.', '16-09-25 RP51 y Cno. 093-08 Corte de pasto', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-17'::date, 1, 'rp', 'RP51', 214.0, 220.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21715'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-17'::date, 6, 'camino', '093-08', 18.0, 20.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-17'::date, 4, 'rp', 'RP51', 244.0, 244.01,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-17'::date, 1, 'camino', '093-08', 1.4, 1.6,
    'Desmalezado manual. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-18'::date, 6, 'camino', '093-08', 20.0, 22.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-22'::date, 4, 'rp', 'RP51', 321.0, 322.0,
    NULL, '22-09-25 RP51', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-22'::date, 2, 'rp', 'RP61', 138.0, 142.0,
    NULL, '22-09-25 RP61', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-22'::date, 2, 'rp', 'RP51', 319.0, 321.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-22'::date, 1, 'rp', 'RP41', 160.0, 164.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9734';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-22'::date, 4, 'rp', 'RP51', 322.0, 323.0,
    NULL, '22-09-25 RP51', NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-23'::date, 6, 'camino', '093-08', 22.0, 24.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-23'::date, 2, 'rp', 'RP51', 320.0, 330.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-23'::date, 1, 'camino', '093-13', 6.0, 10.0,
    NULL, '23-09-25 Cno. 093-13', NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-24'::date, 6, 'camino', '093-08', 24.0, 26.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-24'::date, 2, 'rp', 'RP51', 260.0, 290.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-24'::date, 3, 'camino', '093-13', 0.0, 4.0,
    NULL, '24-09-25 Cno. 093-13 Rot. La Campana', NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-09-24'::date, 4, 'camino', '093-13', 2.0, 3.0,
    NULL, NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-01'::date, 1, 'camino', '093-08', 1.0, 4.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-01'::date, 1, 'camino', '093-08', 1.0, 2.0,
    'Desmalezado manual en acceso. No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-01'::date, 1, 'rp', 'RP51', 277.0, 284.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-02'::date, 1, 'camino', '093-08', 2.0, 3.0,
    'Desmalezado manual en acceso.', '02-10-25 corte pasto Cno 093-08', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-02'::date, 1, 'rp', 'RP51', 245.0, 260.0,
    NULL, '02-10-25 corte pasto RP51', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-02'::date, 1, 'camino', '093-13', 0.0, 4.0,
    'No se registran imágenes fotográficas. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-02'::date, 8, 'rp', 'RP46', 13.0, 13.1,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-06'::date, 1, 'rp', 'RP51', 230.0, 245.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-06'::date, 2, 'camino', '093-03', 1.0, 5.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-07'::date, 2, 'camino', '093-03', 0.0, 7.0,
    NULL, '07-10-25 bacheo Cno 093-03', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-10-07'::date, 1, 'rp', 'RP51', 213.0, 230.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-03'::date, 1, 'rp', 'RP91', 0.0, 10.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-03'::date, 1, 'rp', 'RP91', 10.0, 25.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-03'::date, 4, 'rp', 'RP91', 9.0, 9.5,
    NULL, '03-11-25 RP91 alcantarilla y rot la campana', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-05'::date, 1, 'rp', 'RP91', 25.0, 35.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-06'::date, 1, 'rp', 'RP51', 279.0, 284.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-06'::date, 1, 'rp', 'RP91', 35.0, 45.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-10'::date, 2, 'rp', 'RP51', 319.0, 321.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-10'::date, 1, 'rp', 'RP91', 45.0, 52.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-11'::date, 2, 'rp', 'RP91', 41.0, 45.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-11'::date, 1, 'rp', 'RP61', 56.0, 62.0,
    'No se registran imágenes fotográficas.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-11'::date, 2, 'rp', 'RP30', 282.0, 288.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-12'::date, 1, 'rp', 'RP30', 280.0, 288.0,
    'El tramo ejecutado es en RP30 aunque el tag de la fotografía indica RP61 por referencias erróneas de Google Maps.', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-12'::date, 1, 'rp', 'RP51', 283.0, 293.0,
    'La desmalezadora no cuenta con RO/OI indentificable', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-13'::date, 8, 'rp', 'RP46', 16.0, 16.01,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-13'::date, 6, 'camino', '093-08', 4.0, 7.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-13'::date, 1, 'rp', 'RP91', 42.0, 52.0,
    'Trayecto por mano opuesta (de progresiva superior a inferior)', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-13'::date, 1, 'rp', 'RP51', 293.0, 303.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-14'::date, 6, 'camino', '093-08', 7.0, 10.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-14'::date, 1, 'rp', 'RP91', 26.0, 42.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-14'::date, 1, 'rp', 'RP51', 303.0, 313.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-14'::date, 8, 'rp', 'RP46', 16.0, 16.01,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-17'::date, 1, 'rp', 'RP91', 10.0, 26.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-18'::date, 2, 'rp', 'RP30', 415.0, 425.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-18'::date, 1, 'rp', 'RP91', 0.0, 10.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-19'::date, 6, 'camino', '093-08', 10.0, 13.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-19'::date, 1, 'camino', '093-13', 0.0, 11.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-19'::date, 2, 'rp', 'RP30', 423.0, 430.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-19'::date, 2, 'camino', '062-02', 0.0, 4.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18736';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-20'::date, 6, 'camino', '093-08', 13.0, 15.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-20'::date, 2, 'rp', 'RP51', 278.0, 279.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-25'::date, 1, 'rp', 'RP51', 313.0, 323.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-25'::date, 6, 'camino', '093-08', 15.0, 18.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-26'::date, 6, 'camino', '093-08', 18.0, 22.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-26'::date, 2, 'rp', 'RP40', 27.0, 37.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-26'::date, 4, 'rp', 'RP41', 193.0, 193.1,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-26'::date, 1, 'rp', 'RP30', 272.0, 282.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-27'::date, 1, 'rp', 'RP30', 265.0, 272.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-27'::date, 6, 'camino', '093-08', 18.0, 22.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-27'::date, 2, 'rp', 'RP40', 27.0, 37.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-28'::date, 6, 'camino', '093-08', 22.0, 24.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-28'::date, 1, 'camino', '093-08', 1.0, 4.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-11-28'::date, 1, 'rp', 'RP30', 265.0, 272.0,
    'Trayecto por mano opuesta (de progresiva superior a inferior)', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-02'::date, 2, 'rp', 'RP51', 214.0, 225.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-02'::date, 1, 'rp', 'RP30', 272.0, 287.0,
    'Trayecto por mano opuesta (de progresiva superior a inferior)', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-02'::date, 6, 'camino', '093-08', 24.0, 26.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-02'::date, 1, 'rp', 'RP51', 323.0, 333.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-03'::date, 6, 'camino', '093-08', 26.0, 27.5,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-03'::date, 2, 'rp', 'RP51', 240.0, 250.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-03'::date, 1, 'rp', 'RP51', 333.0, 340.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-04'::date, 6, 'camino', '093-08', 27.5, 29.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-04'::date, 2, 'rp', 'RP51', 318.0, 320.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-04'::date, 2, 'rp', 'RP61', 138.0, 145.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-04'::date, 6, 'camino', '093-08', 29.0, 31.0,
    'Regreso por mano opuesta', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-04'::date, 1, 'rp', 'RP51', 319.0, 321.0,
    'Desmalezado en Rotonda RP51-RP61', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-04'::date, 1, 'rp', 'RP51', 265.0, 276.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-09'::date, 1, 'rp', 'RP51', 250.0, 265.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-09'::date, 1, 'rp', 'RP51', 319.0, 321.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-09'::date, 2, 'rp', 'RP51', 279.0, 280.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-10'::date, 1, 'rp', 'RP51', 321.0, 331.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-10'::date, 1, 'rp', 'RP51', 277.0, 283.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-11'::date, 3, 'rp', 'RP51', 264.0, 265.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-11'::date, 1, 'rp', 'RP91', 0.5, 9.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-11'::date, 1, 'rp', 'RP51', 331.0, 339.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-12'::date, 3, 'rp', 'RP51', 264.0, 265.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-12'::date, 1, 'rp', 'RP91', 0.0, 0.5,
    'Desmalezado en Rotonda RP51-RP91', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-12'::date, 1, 'rp', 'RP51', 339.0, 346.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='52501';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-12'::date, 1, 'camino', '093-13', 10.0, 15.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-16'::date, 1, 'rp', 'RP51', 336.0, 346.0,
    'Trayecto por mano opuesta (de progresiva superior a inferior)', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-16'::date, 1, 'rp', 'RP51', 244.0, 256.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-16'::date, 4, 'rp', 'RP51', 279.5, 279.6,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-17'::date, 1, 'rp', 'RP51', 230.0, 244.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-17'::date, 2, 'rp', 'RP30', 386.0, 420.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-17'::date, 4, 'camino', '093-08', 9.5, 9.6,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-18'::date, 1, 'rp', 'RP51', 230.0, 244.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-18'::date, 2, 'rp', 'RP30', 390.0, 400.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-18'::date, 1, 'rp', 'RP51', 326.0, 336.0,
    'Trayecto por mano opuesta (de progresiva superior a inferior)', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-19'::date, 1, 'rp', 'RP51', 215.0, 230.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-19'::date, 2, 'rp', 'RP61', 130.0, 140.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-22'::date, 2, 'camino', '093-03', 0.0, 7.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-22'::date, 1, 'rp', 'RP51', 225.0, 240.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-22'::date, 4, 'rp', 'RP51', 255.5, 256.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-23'::date, 1, 'camino', '093-08', 0.0, 4.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-23'::date, 1, 'rp', 'RP46', 23.0, 34.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-29'::date, 1, 'rp', 'RP46', 10.0, 23.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='31556';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2025-12-29'::date, 2, 'rp', 'RP51', 279.0, 280.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-05'::date, 2, 'rp', 'RP61', 138.0, 148.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-05'::date, 1, 'rp', 'RP41', 145.0, 160.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9734';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-05'::date, 1, 'camino', '093-08', 3.0, 4.0,
    'Desmalezado manual', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-06'::date, 2, 'rp', 'RP51', 320.0, 340.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-06'::date, 1, 'rp', 'RP41', 145.0, 160.0,
    'Trayecto por mano opuesta (de progresiva superior a inferior)', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9734';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-06'::date, 1, 'camino', '093-08', 1.5, 3.0,
    'Desmalezado manual', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-07'::date, 1, 'camino', '093-08', 0.5, 1.5,
    'Desmalezado manual', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-07'::date, 2, 'rp', 'RP51', 285.0, 320.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-08'::date, 2, 'camino', '093-03', 0.0, 4.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-08'::date, 1, 'camino', '093-13', 7.0, 10.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-08'::date, 1, 'camino', '093-13', 7.0, 8.0,
    'Desmalezado manual. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-09'::date, 1, 'camino', '093-13', 8.0, 9.0,
    'Desmalezado manual. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-09'::date, 2, 'camino', '093-03', 6.0, 8.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-09'::date, 1, 'camino', '093-13', 4.0, 7.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-12'::date, 2, 'rp', 'RP51', 279.0, 280.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-12'::date, 1, 'camino', '093-13', 1.0, 4.0,
    'Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-12'::date, 1, 'camino', '093-13', 6.0, 8.0,
    'Desmalezado manual. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-13'::date, 1, 'camino', '093-05', 0.0, 2.0,
    'Desmalezado manual', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-13'::date, 2, 'rp', 'RP51', 250.0, 275.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-14'::date, 2, 'rp', 'RP30', 380.0, 430.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-15'::date, 1, 'rp', 'RP91', 9.0, 20.0,
    'Desmalezado manual de señalizaciones y alcantarillas.', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-15'::date, 2, 'rp', 'RP30', 380.0, 430.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-16'::date, 1, 'camino', '093-13', 12.0, 13.0,
    'Desmalezado manual. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-19'::date, 2, 'rp', 'RP30', 390.0, 410.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-19'::date, 1, 'camino', '093-13', 11.5, 13.0,
    'Desmalezado manual. Camino secundario 093-13 (no está registrado en la base de datos del formulario).', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-19'::date, 6, 'camino', '093-08', 18.0, 20.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-19'::date, 1, 'camino', '093-05', 0.0, 5.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-20'::date, 2, 'rp', 'RP51', 279.0, 280.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-20'::date, 6, 'camino', '093-08', 20.0, 22.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-20'::date, 1, 'camino', '093-13', 10.0, 14.0,
    NULL, 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-20'::date, 1, 'camino', '093-13', 10.0, 11.5,
    'Desmalezado manual.', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-21'::date, 6, 'camino', '093-08', 22.0, 24.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-21'::date, 1, 'camino', '093-13', 13.0, 14.0,
    'Desmalezado manual.', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-21'::date, 1, 'camino', '093-13', 13.0, 14.0,
    NULL, 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-21'::date, 1, 'camino', '093-13', 0.0, 5.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-22'::date, 6, 'camino', '093-08', 24.0, 26.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-22'::date, 1, 'rp', 'RP30', 284.5, 285.5,
    'Desmalezado manual de flex beam y señalizaciones en puente. Corte de arbustos en cunetas.', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-22'::date, 2, 'rp', 'RP40', 70.0, 72.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-23'::date, 6, 'camino', '093-08', 26.0, 28.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-23'::date, 1, 'rp', 'RP30', 285.5, 287.0,
    'Desmalezado manual', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-23'::date, 2, 'rp', 'RP40', 70.0, 72.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-26'::date, 1, 'rp', 'RP61', 55.0, 62.0,
    'Desmalezado manual de señalizaciones, alcantarilas y cruces.', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-26'::date, 4, 'rp', 'RP40', 70.0, 71.0,
    NULL, 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-27'::date, 1, 'rp', 'RP51', 333.0, 340.0,
    'Coords.: -36.1536769054435, -59.93886438786027', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-27'::date, 1, 'rp', 'RP91', 25.0, 40.0,
    'Coords.: -35.83057, -59.52566', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-27'::date, 1, 'rp', 'RP91', 10.0, 15.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.746840742824325, -59.642114677316776', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-27'::date, 6, 'camino', '093-08', 28.0, 30.0,
    'Ejecución de tramo por mano contraria (regreso). Coords.: -35.87039950391094, -59.93921884861424', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51423';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-28'::date, 6, 'camino', '093-08', 26.0, 30.0,
    'Ejecución de tramo (progresiva descendente) y repaso. Coords.: -35.86887459010237, -59.93870614116624', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-28'::date, 1, 'rp', 'RP91', 40.0, 52.0,
    'Coords.: -35.862771082170624, -59.4278131681477', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-28'::date, 1, 'rp', 'RP51', 340.0, 344.0,
    'Regreso progresiva descendente. Coords.: -36.19393, -59.95525', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-28'::date, 1, 'rp', 'RP91', 30.0, 42.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.83057, -59.52566', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-28'::date, 1, 'rp', 'RP91', 42.0, 47.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.87745, -59.40134', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-29'::date, 1, 'rp', 'RP51', 344.0, 348.0,
    'Regreso progresiva descendente.', 'SI', 'Coords.: -36.23082, -59.96762', NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-29'::date, 1, 'rp', 'RP61', 50.0, 63.0,
    'Coords.: -36.01197026859618, -59.194886021892025', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-29'::date, 1, 'rp', 'RP61', 56.0, 63.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -36.00279011119007, -59.21716950382905', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-29'::date, 1, 'rp', 'RP91', 47.0, 51.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.90424840172229, -59.37610572717161', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-30'::date, 1, 'rp', 'RP30', 270.0, 282.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -36.095688243269876, -59.08714325860155', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51385';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-01-30'::date, 1, 'rp', 'RP91', 29.0, 40.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.83079690670953, -59.52551661186518', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-02'::date, 1, 'rp', 'RP51', 340.0, 346.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -36.23082, -59.96762', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-02'::date, 1, 'rp', 'RP51', 277.0, 280.0,
    'Coords.: -35.65158, -59.83706', 'NO', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-02'::date, 3, 'rp', 'RP51', 278.0, 279.0,
    NULL, 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-03'::date, 1, 'rp', 'RP46', 0.0, 10.0,
    'No se registran imágenes fotográficas. Coords.: -35.41633, -60.14242', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-04'::date, 6, 'camino', '093-08', 4.0, 7.0,
    NULL, 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-04'::date, 1, 'rp', 'RP46', 10.0, 20.0,
    'No se registran imágenes fotográficas. Coords.: -35.37799, -60.21091', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-04'::date, 1, 'rp', 'RP51', 335.0, 340.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -36.14176, -59.93317', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-04'::date, 4, 'rp', 'RP51', 254.0, 256.0,
    'Coords de fotografías no coinciden con las verdaderas. Coords.: -35.55883, -60.01975', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-05'::date, 2, 'rp', 'RP41', 164.0, 186.0,
    'No se registran imágenes fotográficas. Coords.: -35.13002, -59.17305', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-05'::date, 1, 'rp', 'RP51', 335.0, 340.0,
    'Desmalezado manual de señalizaciones y alcantarilas. No se registran imágenes fotográficas. Coords.: -36.16643, -59.94724', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-05'::date, 1, 'rp', 'RP46', 20.0, 30.0,
    'No se registran imágenes fotográficas. Coords.: -35.30308, -60.30979', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-05'::date, 6, 'camino', '093-08', 10.0, 13.0,
    'Coords.: -35.74430, -59.87153', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-06'::date, 6, 'camino', '093-08', 7.0, 10.0,
    'Coords.: -35.72959, -59.86282', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-06'::date, 1, 'rp', 'RP51', 330.0, 335.0,
    'Desmalezado manual de señalizaciones y alcantarilas. No se registran imágenes fotográficas. Coords.: -36.11292, -59.92390', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-06'::date, 6, 'camino', '093-08', 13.0, 16.0,
    'Coords.: -35.76287, -59.88153', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-06'::date, 1, 'camino', '109-01', 0.0, 10.0,
    'Coords.: -35.43692, -60.22403', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-06'::date, 2, 'rp', 'RP51', 278.0, 279.0,
    'Coords.: -35.66725, -59.81844', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-09'::date, 2, 'camino', '093-03', 0.0, 8.0,
    'Coords.: -35.47083, -59.570616', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-09'::date, 1, 'rp', 'RP51', 325.0, 330.0,
    'Desmalezado manual de señalizaciones y alcantarilas. No se registran imágenes fotográficas. Coords.: -36.07352, -59.91119', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-09'::date, 1, 'camino', '109-01', 10.0, 25.0,
    'Coords.: -35.52033, -60.32179', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-09'::date, 6, 'camino', '093-08', 16.0, 20.0,
    'Coords.: -35.79863, -59.90082', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-10'::date, 1, 'rp', 'RP51', 320.0, 325.0,
    'Desmalezado manual de señalizaciones y alcantarilas. No se registran imágenes fotográficas. Coords.: -36.04133, -59.90021', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-10'::date, 1, 'rp', 'RP51', 276.0, 279.0,
    'Coords.: -35.65134, -59.83753', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-10'::date, 1, 'camino', '109-01', 25.0, 37.0,
    'Coords.: -35.62712, -60.43865', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-10'::date, 6, 'camino', '093-08', 20.0, 24.0,
    'Coords.: -35.82605, -59.91564', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-11'::date, 6, 'camino', '093-08', 24.0, 29.0,
    'Coords.: -35.86646, -59.93735', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-11'::date, 4, 'rp', 'RP51', 270.0, 279.0,
    NULL, 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-11'::date, 1, 'rp', 'RP51', 245.0, 260.0,
    'Coords.: -35.51001, -60.04921', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-12'::date, 1, 'rp', 'RP51', 260.0, 276.0,
    'Coors.: -35.59953, -59.92081', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-12'::date, 1, 'rp', 'RP51', 270.0, 276.0,
    'Desmalezado manual de señalizaciones y alcantarilas. No se registran imágenes fotográficas. Coords.: -35.62967, -59.86708', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-12'::date, 4, 'rp', 'RP40', 78.0, 82.0,
    'Coords.: -34.97779, -59.21468', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-13'::date, 6, 'camino', '109-14', 0.0, 9.0,
    'Aplanadora sin ID (marca Iron). Coords.: -35.61088, -60.53622', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-13'::date, 4, 'rp', 'RP40', 75.0, 82.0,
    'Coords.: -34.95483, -59.17288', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-13'::date, 1, 'rp', 'RP51', 265.0, 270.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.57915, -59.97093', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-16'::date, 1, 'rp', 'RP51', 255.0, 265.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.55430, -60.02672', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-16'::date, 1, 'rp', 'RP51', 245.0, 260.0,
    'Coords.: -35.51267, -60.04784', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-16'::date, 4, 'rp', 'RP40', 70.0, 75.0,
    'Coords.: -34.95539, -59.15228', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-17'::date, 4, 'rp', 'RP40', 45.0, 55.0,
    'Coords.: -34.94519, -59.08267', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-17'::date, 6, 'camino', '093-08', 4.0, 7.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-17'::date, 1, 'rp', 'RP51', 250.0, 255.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords.: -35.55217, -60.02788', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-17'::date, 6, 'camino', '109-14', 0.0, 9.0,
    'Aplanadora sin ID (marca Iron). Coords.: -35.60306, -60.54607', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-18'::date, 1, 'rp', 'RP51', 279.0, 280.0,
    'Coords.: -35.66894, -59.81644', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-18'::date, 2, 'rp', 'RP51', 279.0, 279.5,
    'Coords.: -35.66472, -59.82155', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-19'::date, 6, 'camino', '109-14', 0.0, 9.0,
    'Aplanadora sin ID (marca Iron). Coords. PROG. INTERMEDIA: -35.63956, -60.49174. PROG. INICIAL: -35.65372, -60.47382. PROG. FINAL: -35.60262, -60.54671', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-19'::date, 6, 'camino', '093-08', 7.0, 10.0,
    'PROG. INICIAL: -35.68572, -59.83831; PROG. FINAL: -35.70977, -59.85299', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-19'::date, 1, 'rp', 'RP30', 376.0, 382.0,
    'Coords. PROG. INTERMEDIA: -35.35476, -59.47140.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-19'::date, 1, 'rp', 'RP51', 240.0, 250.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INTERMEDIA: -35.44920, -60.08320; PROG. INICIAL:  -35.41794, -60.08436; PROG. FINAL: -35.50233, -60.05290', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-19'::date, 2, 'rp', 'RP30', 376.0, 385.0,
    'Coords. PROG. INTERMEDIA: -35.34790, -59.48101', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-20'::date, 6, 'camino', '093-08', 10.0, 13.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-20'::date, 2, 'rp', 'RP30', 382.0, 390.0,
    'Coords. PROG. INTERMEDIA: -35.33620, -59.49749', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-20'::date, 6, 'camino', '109-14', 5.0, 9.0,
    'Aplanadora sin ID (marca Iron). Coords.: -35.614522, -60.53149; PROG. INICIAL: -35.62259, -60.51363; PROG. FINAL: -35.60262, -60.54671', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-20'::date, 1, 'rp', 'RP30', 382.0, 400.0,
    'Coords. PROG. INTERMEDIA: -35.33715, -59.53856', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-20'::date, 1, 'rp', 'RP51', 280.0, 282.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INTERMEDIA: -35.68135, -59.80077; PROG. INICIAL:  -35.67201, -59.81236; PROG. FINAL:  -35.68494, -59.79618', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-25'::date, 6, 'camino', '093-08', 13.0, 15.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-25'::date, 3, 'rp', 'RP51', 279.0, 279.5,
    'PROG. INICIAL: -35.66865, -59.81667; PROG. FINAL: -35.66582, -59.82017', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-25'::date, 1, 'rp', 'RP51', 230.0, 240.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INICIAL: -35.32759, -60.09830; PROG. FINAL:  -35.41794, -60.08436;', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-25'::date, 1, 'rp', 'RP30', 400.0, 415.0,
    'PROG. INICIAL: -35.33750, -59.53373; PROG. FINAL: -35.24218, -59.70443', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-25'::date, 4, 'rp', 'RP40', 55.0, 57.0,
    'Coords. PROG. INTERMEDIA: -34.95560, -59.15374', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-26'::date, 1, 'rp', 'RP51', 215.0, 230.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INICIAL: 34.92028, -58.95641; PROG. FINAL: -35.32759, -60.09830', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-26'::date, 1, 'rp', 'RP30', 415.0, 430.0,
    'PROG. INICIAL: -35.24218, -59.70443; PROG. FINAL: -35.12777, -59.74606', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-26'::date, 6, 'camino', '093-08', 15.0, 18.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-26'::date, 4, 'rp', 'RP40', 47.0, 50.0,
    'Coords. PROG. INTERMEDIA: -34.93995, -59.05932', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-26'::date, 1, 'camino', '093-13', 11.0, 13.0,
    'Coords. PROG. INTERMEDIA: -35.61975,-59.78540', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-27'::date, 1, 'rp', 'RP30', 400.0, 415.0,
    'CORTE DE PASTO Y TRASLADO DE EQUIPOS CON CAMION Y CARRETÓN DEL MUNIICPIO DE ROQUE PÉREZ. PROG. INICIAL: -35.33750, -59.53373; PROG. FINAL: -35.24218, -59.70443', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-27'::date, 4, 'rp', 'RP40', 45.0, 47.0,
    'PROG. INICIAL: -34.93232, -58.99285; PROG. FINAL: -34.94280, -59.03109', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-27'::date, 8, 'rp', 'RP51', 215.0, 216.0,
    'PROG. INICIAL: -35.19191, -60.11375; PROG. FINAL: -35.20127, -60.11285', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-03-27'::date, 6, 'camino', '093-08', 18.0, 21.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-06'::date, 2, 'rp', 'RP51', 230.0, 240.0,
    'PROG. INICIAL: -35.33095, -60.09693; PROG. FINAL: -35.41745, -60.08440', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-06'::date, 1, 'camino', '093-13', 6.0, 10.0,
    '-35.66847, -59.73787; -35.64573, -59.76882', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-06'::date, 1, 'rp', 'RP91', 0.0, 9.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INICIAL: -35.69216, -59.78670; PROG. FINAL: -35.71016, -59.69311', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-06'::date, 1, 'rp', 'RP91', 0.0, 10.0,
    'Coords. PROG. INICIAL: -35.69216, -59.78670; PROG. FINAL: -35.71016, -59.69311', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-06'::date, 3, 'rp', 'RP51', 279.0, 279.5,
    '-35.66575, -59.82023; -35.66856, -59.81689', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-07'::date, 1, 'rp', 'RP91', 0.0, 10.0,
    'Continuación por traza descendente. Coords. PROG. INICIAL: -35.69216, -59.78670; PROG. FINAL: -35.71016, -59.69311', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-07'::date, 4, 'camino', '093-13', 4.0, 10.0,
    '-35.68428, -59.71838; -35.64573, -59.76882', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 1, 'camino', '093-13', 4.5, 7.5,
    '-35.6797, -59.72325 ; -35.66101, -59.74785', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 1, 'camino', '093-08', 1.0, 4.0,
    'Desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INICIAL: -35.64943, -59.79201; PROG. FINAL: -35.67007, -59.81488', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 1, 'camino', '093-08', 1.0, 4.0,
    'Coords. PROG. INICIAL: -35.64943, -59.79201; PROG. FINAL: -35.67007, -59.81488', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 1, 'rp', 'RP51', 230.0, 244.0,
    '-35.32972, -60.09711; -35.45424, -60.08389', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 2, 'rp', 'RP46', 0.0, 20.0,
    '-35.45773, -60.08286; -35.27197, -60.35065', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 1, 'camino', '093-02', 0.0, 4.0,
    'Desmonte y limpieza de malezas. Coords.: -35.53987, -59.6969; -35.56374, -59.66437', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 5, 'rp', 'RP40', 30.0, 42.0,
    'Relevamiento luminarias. Coords. -34.85509, -58.89565; -34.93538, -59.00336', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='58191';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-08'::date, 5, 'rp', 'RP6', 120.0, 130.0,
    'Relevamiento luminarias.', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='58191';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-09'::date, 1, 'camino', '093-08', 1.0, 4.0,
    'Continuación de tareas de desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INICIAL: -35.64943, -59.79201; PROG. FINAL: -35.67007, -59.81488', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-09'::date, 1, 'camino', '093-08', 1.0, 4.0,
    'Continuación de tareas. Coords. PROG. INICIAL: -35.64943, -59.79201; PROG. FINAL: -35.67007, -59.81488', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-09'::date, 1, 'rp', 'RP51', 215.0, 230.0,
    '-35.19233, -60.11307; -35.32717, -60.09779', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-09'::date, 1, 'camino', '093-02', 0.0, 4.0,
    'Continuación de tareas de desmonte y limpieza de malezas. Coords.: -35.53987, -59.6969; -35.56374, -59.66437', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-09'::date, 2, 'rp', 'RP51', 258.0, 275.0,
    '-35.56337, -60.00890; -35.64422, -59.84734', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-10'::date, 1, 'rp', 'RP51', 215.0, 230.0,
    'Retorno por mano progresiva creciente. -35.19233, -60.11307; -35.32717, -60.09779', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-10'::date, 1, 'camino', '093-08', 3.0, 4.0,
    'Continuación de tareas de desmalezado manual de señalizaciones y alcantarilas. Coords. PROG. INICIAL: -35.64943, -59.79201; PROG. FINAL: -35.67007, -59.81488', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-10'::date, 1, 'camino', '093-08', 2.0, 4.0,
    'Continuación de tareas. Coords. PROG. INICIAL: -35.64943, -59.79201; PROG. FINAL: -35.67007, -59.81488', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-10'::date, 2, 'rp', 'RP30', 267.0, 280.0,
    '-36.21866, -59.04482; -36.09100, -59.08894', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-13'::date, 1, 'camino', '093-13', 10.0, 13.0,
    '-35.62458, -59.77885; -35.60578, -59.80432', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-13'::date, 2, 'rp', 'RP91', 0.0, 9.0,
    '-35.69308, -59.78524; -35.70894, -59.69681', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-13'::date, 2, 'rp', 'RP51', 318.0, 319.0,
    'Relevamiento de pavimento rígido. -36.00419, -59.88765; -36.00646, -59.88843', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-14'::date, 1, 'camino', '093-05', 0.0, 10.0,
    '-35.6797, -59.72325 ; -35.63436, -59.626', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-14'::date, 1, 'camino', '093-13', 10.0, 13.0,
    'Continuación de tareas en la misma traza. -35.62458, -59.77885; -35.60578, -59.80432', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-14'::date, 1, 'camino', '093-02', 0.0, 4.0,
    'Continuación de tareas de desmonte y limpieza de malezas. Coords.: -35.53987, -59.6969; -35.56374, -59.66437', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-14'::date, 2, 'rp', 'RP51', 285.0, 300.0,
    '-35.70972, -59.79172; -35.84537, -59.83601', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-15'::date, 2, 'rp', 'RP51', 320.0, 345.0,
    '-36.01287, -59.89231; -36.01287, -59.89231', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-15'::date, 1, 'camino', '093-05', 0.0, 10.0,
    'Continuación de tareas. -35.6797, -59.72325 ; -35.63436, -59.626', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-15'::date, 1, 'camino', '093-13', 10.0, 13.0,
    'Continuación de tareas en la misma traza. -35.62458, -59.77885; -35.60578, -59.80432', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-15'::date, 1, 'camino', '093-02', 0.0, 4.0,
    'Continuación de tareas de desmonte y limpieza de malezas. Coords.: -35.53987, -59.6969; -35.56374, -59.66437', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-16'::date, 2, 'rp', 'RP51', 320.0, 345.0,
    'Continuación de tareas. -36.01287, -59.89231; -36.01287, -59.89231', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-16'::date, 1, 'camino', '093-05', 0.0, 10.0,
    'Continuación de tareas. -35.6797, -59.72325 ; -35.63436, -59.626', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-16'::date, 1, 'camino', '093-13', 10.0, 13.0,
    'Continuación de tareas en la misma traza. -35.62458, -59.77885; -35.60578, -59.80432', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-17'::date, 1, 'camino', '093-05', 0.0, 10.0,
    'Continuación de tareas. -35.6797, -59.72325 ; -35.63436, -59.626', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-17'::date, 2, 'camino', '093-13', 10.0, 13.0,
    'Tareas de bacheo en el tramo comprendido entre las coords.: -35.62458, -59.77885; -35.60578, -59.80432', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-22'::date, 4, 'rp', 'RP30', 267.5, 282.6,
    'PROG. INICIAL: -36.21450, -59.04533; PROG. FINAL: -36.06652, -59.09640', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-22'::date, 1, 'rp', 'RP30', 418.1, 419.1,
    'DESMALEZADO MANUAL. PROG. INICIAL: -35.22297, -59.71807; PROG. FINAL: -35.21554, -59.72125', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-22'::date, 2, 'camino', '093-03', 0.0, 6.0,
    'PROG. INICIAL: -35.46248, -59.58209; PROG. FINAL: -35.49804, -59.53365', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-23'::date, 1, 'rp', 'RP30', 419.2, 421.5,
    'DESMALEZADO MANUAL. PROG. INICIAL: -35.20615, -59.72340; PROG. FINAL: -35.19506, -59.72580', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-23'::date, 1, 'camino', '093-05', 0.0, 8.0,
    '-35.6797, -59.72325; -35.64408, -59.64729', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-23'::date, 1, 'camino', '093-02', 0.0, 4.0,
    'Continuación de tareas de desmonte y limpieza de malezas. Coords.: -35.53987, -59.6969; -35.56374, -59.66437', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-24'::date, 1, 'rp', 'RP30', 417.1, 418.1,
    'DESMALEZADO MANUAL. PROG. INICIAL: -35.23006, -59.71464; PROG. FINAL: -35.21554, -59.72125', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-24'::date, 1, 'rp', 'RP91', 1.0, 9.0,
    'PROG. INICIAL: -35.69338, -59.78584; PROG. FINAL: -35.70960, -59.69470', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-24'::date, 1, 'camino', '093-13', 0.0, 4.5,
    'PROG. INICIAL: -35.70965, -59.69278; PROG. FINAL: -35.6797, -59.72325', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 1, 'rp', 'RP30', 415.0, 417.1,
    'DESMALEZADO MANUAL. PROG. INICIAL: -35.24204, -59.70443; PROG. FINAL: -35.23006, -59.71464', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 1, 'rp', 'RP91', 1.0, 9.0,
    'Regreso por mano opuesta en progresiva descendendete. PROG. INICIAL: -35.69338, -59.78584; PROG. FINAL: -35.70960, -59.69470', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 1, 'camino', '093-02', 0.0, 4.0,
    'Continuación de tareas de desmonte y limpieza de malezas. Coords.: -35.53987, -59.6969; -35.56374, -59.66437', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 3, 'rp', 'RP51', 279.0, 279.4,
    'PROG. INICIAL: -35.66566, -59.82045; PROG. FINAL: -35.66851, -59.81695', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 6, 'camino', '093-08', 4.0, 7.0,
    'PROG. INICIAL: -35.66759, -59.81826; PROG. FINAL: -35.68808, -59.84097', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 2, 'rp', 'RP51', 278.0, 279.4,
    'PROG. INICIAL: -35.65939, -59.82820; PROG. FINAL: -35.66851, -59.81695', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 2, 'rp', 'RP91', 1.0, 9.0,
    'PROG. INICIAL: -35.69338, -59.78584; PROG. FINAL: -35.70960, -59.69470', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-27'::date, 2, 'camino', '093-08', 2.0, 4.0,
    'PROG. INICIAL: -35.65513, -59.79819; PROG. FINAL: -35.67007, -59.81488', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-28'::date, 1, 'camino', '093-02', 0.0, 4.0,
    'Continuación de tareas de desmonte y limpieza de malezas. Coords.: -35.53987, -59.6969; -35.56374, -59.66437', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-28'::date, 1, 'rp', 'RP51', 282.2, 283.6,
    'ROTONDA "LA GALLARETA" (NODO RP51 - RP91). PROG. INICIAL: -35.69028, -59.78955; PROG. FINAL: 35.69651, -59.78689', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-28'::date, 1, 'rp', 'RP30', 419.1, 422.1,
    'DESMALEZADO MANUAL. PROG. INICIAL: -35.21554, -59.72125; PROG. FINAL: -35.19114, -59.72752', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-28'::date, 6, 'camino', '093-08', 7.0, 10.0,
    'PROG. INICIAL: -35.68808, -59.84097 ; PROG. FINAL: -35.71308, -59.85472', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-28'::date, 2, 'rp', 'RP47', 5.0, 20.0,
    '-34.97059, -59.26802; -34.86016, -59.21288', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-29'::date, 2, 'rp', 'RP47', 5.0, 20.0,
    'CONTINUACIÓN DE TAREAS. -34.97059, -59.26802; -34.86016, -59.21288', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-29'::date, 1, 'rp', 'RP30', 422.1, 432.0,
    'DESMALEZADO MANUAL. -35.19114, -59.72752; -35.11261, -59.74760', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-29'::date, 1, 'camino', '093-01', 11.0, 12.0,
    'Tareas de desmonte y limpieza de malezas. Coords.: -35.58053, -59.67379; -35.57823, -59.66534', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-29'::date, 6, 'camino', '093-08', 10.0, 14.0,
    '-35.71206, -59.85423; -35.74396, -59.87136', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-30'::date, 1, 'rp', 'RP30', 422.1, 432.0,
    'CONTINUACIÓN DE TAREAS DE DESMALEZADO MANUAL. -35.19114, -59.72752; -35.11261, -59.74760', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-30'::date, 6, 'camino', '093-08', 14.0, 18.0,
    '-35.74396, -59.87136; -35.77834, -59.88974', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-04-30'::date, 2, 'rp', 'RP51', 246.0, 250.0,
    '-35.50244, -60.05289; -35.50244, -60.05289', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-04'::date, 1, 'rp', 'RP51', 284.0, 289.3,
    'TAREAS DE DESMALEZADO MANUAL. COORDS: -35.70017, -59.78824; -35.74679, -59.80322', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-04'::date, 1, 'rp', 'RP91', 10.0, 25.0,
    '-35.71028, -59.69271; -35.80215, -59.56641', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-04'::date, 1, 'rp', 'RP51', 284.0, 290.2,
    '-35.70017, -59.78824; -35.75459, -59.80614', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-05'::date, 1, 'rp', 'RP51', 290.0, 295.0,
    'DESMALEZADO MANUAL. -35.75320, -59.80545; -35.79749, -59.81996', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-05'::date, 1, 'rp', 'RP51', 290.0, 295.0,
    '-35.75320, -59.80545; -35.79749, -59.81996', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-05'::date, 2, 'rp', 'RP47', 4.0, 15.0,
    'BACHEO EN RP47 Y VARIANTE A RP41. COORDS.: -34.97572, -59.27034; -34.93728, -59.24081. VARIANTE: -34.974967, -59.276406; -34.985723, -59.313693', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-06'::date, 1, 'rp', 'RP51', 295.0, 300.0,
    'DESMALEZADO MANUAL. -35.79749, -59.81996; -35.84193, -59.83420', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-06'::date, 1, 'rp', 'RP51', 295.0, 300.0,
    'DESMALEZADO MECÁNICO. -35.79749, -59.81996; -35.84193, -59.83420', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-06'::date, 1, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-07'::date, 1, 'rp', 'RP51', 276.5, 277.0,
    'DESMALEZADO EN PREDIO DE LA DVBA ZONA VI. COORDS. -35.65147, -59.83733; -35.65233, -59.83617', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-07'::date, 1, 'rp', 'RP51', 276.5, 277.0,
    'DESMALEZADO EN PREDIO DE LA DVBA ZONA VI. COORDS. -35.65147, -59.83733; -35.65233, -59.83617', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-07'::date, 1, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-08'::date, 1, 'rp', 'RP51', 276.5, 277.0,
    'DESMALEZADO EN PREDIO DE LA DVBA ZONA VI. COORDS. -35.65147, -59.83733; -35.65233, -59.83617', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-08'::date, 1, 'rp', 'RP51', 276.5, 277.0,
    'DESMALEZADO EN PREDIO DE LA DVBA ZONA VI. COORDS. -35.65147, -59.83733; -35.65233, -59.83617', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-08'::date, 1, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-08'::date, 1, 'rp', 'RP51', 300.0, 315.0,
    'DESMALEZADO MANUAL. -35.84193, -59.8342; -35.97301, -59.87738', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-08'::date, 1, 'rp', 'RP51', 300.0, 315.0,
    'DESMALEZADO MECÁNICO. -35.84193, -59.83420; -35.97301, -59.87738', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-08'::date, 1, 'rp', 'RP91', 10.5, 25.0,
    '-35.71251, -59.68906; -35.80264, -59.56547', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-11'::date, 1, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-11'::date, 1, 'rp', 'RP51', 315.0, 320.0,
    'DESMALEZADO MANUAL. -35.97301, -59.87738; -36.01278, -59.89181', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-11'::date, 1, 'rp', 'RP51', 315.0, 320.0,
    'DESMALEZADO MECÁNICO. -35.97301, -59.87738; -36.01278, -59.89181', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-11'::date, 1, 'rp', 'RP91', 25.0, 40.0,
    '-35.80264, -59.56547; -35.86511, -59.42495', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-11'::date, 6, 'rp', 'RP44', 28.0, 31.7,
    '-35.03386, -59.61164; -35.05843, -59.63926', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22108';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-12'::date, 1, 'rp', 'RP51', 320.0, 330.0,
    'DESMALEZADO MANUAL. -36.01278, -59.89181; -36.10043, -59.91943', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-12'::date, 1, 'rp', 'RP51', 320.0, 330.0,
    'DESMALEZADO MECÁNICO. -36.01278, -59.89181; -36.10043, -59.91943', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-12'::date, 1, 'rp', 'RP91', 40.0, 51.7,
    '-35.86511, -59.42495; -35.93914, -59.33251', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-12'::date, 1, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-13'::date, 1, 'rp', 'RP51', 330.0, 340.0,
    'DESMALEZADO MANUAL. -36.10043, -59.91943; -36.18777, -59.95359', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-13'::date, 1, 'rp', 'RP51', 330.0, 340.0,
    'DESMALEZADO MECÁNICO. -36.10043, -59.91943; -36.18777, -59.95359', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-13'::date, 1, 'rp', 'RP61', 60.0, 78.0,
    '-36.02402, -59.15342; -35.93924, -59.33240', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-13'::date, 1, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2084'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-13'::date, 2, 'camino', '093-13', 10.0, 10.6,
    '-35.62464, -59.77879; -35.62111, -59.7836', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-14'::date, 1, 'rp', 'RP51', 340.0, 346.5,
    'DESMALEZADO MANUAL. -36.10043, -59.91943; -36.24391, -59.97217', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-14'::date, 1, 'rp', 'RP51', 340.0, 346.5,
    'DESMALEZADO MECÁNICO. -36.10043, -59.91943; -36.24391, -59.97217', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-14'::date, 1, 'rp', 'RP30', 279.0, 289.2,
    '-36.10089, -59.08589; -36.02466, -59.15172', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-14'::date, 2, 'camino', '093-13', 10.0, 10.6,
    '-35.62464, -59.77879; -35.62111, -59.7836', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-14'::date, 4, 'camino', '093-13', 10.0, 11.2,
    '-35.62464, -59.77879; -35.61759, -59.78838', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-15'::date, 1, 'rp', 'RP30', 267.0, 279.0,
    '-36.21821, -59.04479; -36.02466, -59.15172', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-15'::date, 1, 'rp', 'RP51', 340.0, 346.5,
    'DESMALEZADO MANUAL. -36.10043, -59.91943; -36.24391, -59.97217', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-15'::date, 2, 'camino', '093-13', 10.0, 10.6,
    'COLOCACIÓN DE REDUCTORES DE VELOCIDAD (LOMOS DE BURRO). USO DE CAMIÓN VOLVO DE OTRA ZONA (R.O.: 26724). -35.62464, -59.77879; -35.62111, -59.7836.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21202';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-18'::date, 1, 'rp', 'RP51', 330.0, 340.0,
    'DESMALEZADO MANUAL. -36.10043, -59.91943; -36.18749, -59.95342', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-18'::date, 1, 'rp', 'RP30', 267.0, 279.0,
    'RETORNO EN SENTIDO PROG ASCENDENTE. -36.21821, -59.04479; -36.02466, -59.15172', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-18'::date, 6, 'camino', '093-08', 11.0, 14.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-18'::date, 1, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-19'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-19'::date, 1, 'rp', 'RP51', 320.0, 330.0,
    'DESMALEZADO MANUAL. -36.01301, -59.89283; -36.10043, -59.91943', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-19'::date, 1, 'rp', 'RP61', 59.9, 78.0,
    '-36.02434, -59.15254; -35.93952, -59.33205', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-20'::date, 2, 'rp', 'RP30', 187.1, 187.2,
    '-36.03938, -59.13198; -36.03860, -59.13301', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-20'::date, 1, 'rp', 'RP91', 40.0, 51.6,
    '-35.86506, -59.42498; -35.93887, -59.33280', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-20'::date, 6, 'camino', '093-08', 14.0, 17.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-20'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Se adjuntas fotrografías de fecha 18-05-26 faltantes. Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-21'::date, 1, 'rp', 'RP51', 335.0, 340.0,
    'Desmalezado manual en límite de Pdos. Gral Alvear - Tapalqué.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-21'::date, 1, 'rp', 'RP91', 20.0, 40.0,
    '-35.77214, -59.60907; -35.86506, -59.42498', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-21'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', 'SI', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 5::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-22'::date, 1, 'rp', 'RP51', 340.0, 345.0,
    'Desmalezado manual en límite de Pdos. Gral Alvear - Tapalqué.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-22'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 5::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-22'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-27'::date, 2, 'rp', 'RP51', 224.0, 228.0,
    '-35.27316, -60.10526; -35.30938, -60.10174', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-27'::date, 4, 'camino', '093-05', 4.0, 10.0,
    '-35.63436, -59.626; -35.59163, -59.50609', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-28'::date, 2, 'rp', 'RP40', 125.0, 130.0,
    '-35.26559, -59.69203; -35.27307, -59.75851', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-28'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-28'::date, 6, 'camino', '093-08', 17.0, 20.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-29'::date, 2, 'rp', 'RP40', 125.0, 130.0,
    '-35.26559, -59.69203; -35.27307, -59.75851', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-05-29'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-01'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-01'::date, 2, 'rp', 'RP61', 137.0, 146.0,
    '-36.00591, -59.89092; -36.02508, -59.97449', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-01'::date, 5, 'rp', 'RP91', 9.0, 10.0,
    'Mantenimiento de luminarias. -35.70890, -59.69687: -35.71204, -59.68957', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18805';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-02'::date, 5, 'rp', 'RP91', 9.0, 10.0,
    'Mantenimiento de luminarias. -35.70890, -59.69687: -35.71204, -59.68957', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18805';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-02'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-02'::date, 2, 'rp', 'RP30', 377.0, 411.0,
    '-35.39476, -59.41543; -35.26810, -59.68720', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-02'::date, 6, 'camino', '093-08', 20.0, 23.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-03'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-03'::date, 2, 'rp', 'RP30', 377.0, 411.0,
    '-35.39476, -59.41543; -35.26810, -59.68720', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-03'::date, 6, 'camino', '093-08', 23.0, 26.0,
    NULL, NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-03'::date, 5, 'rp', 'RP91', 9.0, 10.0,
    'Mantenimiento de luminarias. -35.70890, -59.69687: -35.71204, -59.68957', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18805';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-09'::date, 1, 'rp', 'RP51', 284.0, 294.0,
    'Desmalezado mecánico. Coords.: -35.70021, -59.78816; -35.79178, -59.81833', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-09'::date, 1, 'rp', 'RP51', 284.0, 294.0,
    'Desmalezado manual. Coords.: -35.70021, -59.78816; -35.79178, -59.81833', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-10'::date, 2, 'rp', 'RP51', 245.0, 275.0,
    'Coords.: -35.46193, -60.07839; -35.64474, -59.84631.', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-10'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-10'::date, 6, 'camino', '093-08', 9.0, 12.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-11'::date, 6, 'camino', '093-08', 5.0, 8.0,
    'Coords.: -35.70404, -59.84988; -35.72766, -59.86258', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-12'::date, 6, 'camino', '093-08', 8.0, 11.0,
    'Coords: -35.72766, -59.86258; -35.75388, -59.87668', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2066'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='51426';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-12'::date, 1, 'rp', 'RP51', 295.0, 305.0,
    'Coords.: -35.79763, -59.82004; -35.88613, -59.84991', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-12'::date, 1, 'rp', 'RP51', 295.0, 305.0,
    'Desmalezado manual. Coords.: -35.79763, -59.82004; -35.88613, -59.84991', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-12'::date, 2, 'rp', 'RP51', 215.0, 235.0,
    'Coords.: -35.19149, -60.11410; -35.37197, -60.08904', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-16'::date, 1, 'rp', 'RP51', 335.0, 346.0,
    'Desmalezado mecánico. Coords.: -36.14481, -59.93437; -36.24372, -59.97265', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-16'::date, 1, 'rp', 'RP51', 335.0, 346.0,
    'Desmalezado manual. Coords.: -36.14481, -59.93437; -36.24372, -59.97265}', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-16'::date, 3, 'camino', '093-13', 6.0, 9.0,
    'Tareas de limpieza de canales. Coords.: -35.67053, -59.7352; -35.65241, -59.75969', NULL, NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-17'::date, 1, 'rp', 'RP51', 318.0, 335.0,
    NULL, 'si*', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-17'::date, 1, 'rp', 'RP51', 260.0, 276.0,
    NULL, 'si*', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-17'::date, 3, 'camino', '093-13', 6.0, 8.0,
    'Tareas de limpieza de canales', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-18'::date, 3, 'camino', '093-13', 6.0, 7.0,
    'Tareas de limpieza de canales', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-18'::date, 1, 'rp', 'RP51', 245.0, 260.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-18'::date, 1, 'rp', 'RP51', 310.0, 318.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-18'::date, 1, 'rp', 'RP41', 162.0, 175.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9734';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-19'::date, 1, 'rp', 'RP51', 276.0, 277.0,
    'DESMALEZADO EN PREDIO DE LA DVBA ZONA VI. COORDS. -35.65147, -59.83733; -35.65233, -59.83617', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21503';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-22'::date, 1, 'rp', 'RP51', 300.0, 310.0,
    NULL, 'si*', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-22'::date, 1, 'rp', 'RP51', 230.0, 245.0,
    NULL, 'si*', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-22'::date, 1, 'rp', 'RP51', 276.0, 277.0,
    'DESMALEZADO MANUAL EN PREDIO DE LA DVBA ZONA VI. COORDS. -35.65147, -59.83733; -35.65233, -59.83617', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='2918';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-22'::date, 3, 'camino', '093-13', 6.0, 7.0,
    'Tareas de limpieza de canales', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 4::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-22'::date, 1, 'rp', 'RP41', 175.0, 190.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9734';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-23'::date, 3, 'camino', '093-13', 6.0, 7.0,
    'Tareas de limpieza de canales', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-23'::date, 1, 'rp', 'RP51', 215.0, 230.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-23'::date, 1, 'rp', 'RP51', 285.0, 300.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='9667'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-23'::date, 2, 'rp', 'RP40', 40.0, 60.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-24'::date, 1, 'rp', 'RP51', 215.0, 230.0,
    'Regreso desde progresiva ascendente', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-24'::date, 3, 'camino', '093-13', 6.0, 7.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-24'::date, 2, 'rp', 'RP40', 28.0, 35.0,
    NULL, 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-25'::date, 1, 'rp', 'RP51', 230.0, 245.0,
    'Regreso desde progresiva ascendente', 'no', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='26395';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-25'::date, 2, 'rp', 'RP41', 165.0, 185.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-26'::date, 3, 'camino', '093-13', 6.0, 7.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='18785'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-26'::date, 1, 'rp', 'RP46', 0.0, 15.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-29'::date, 4, 'rp', 'RP91', 9.0, 29.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-29'::date, 1, 'camino', '093-13', 10.0, 16.0,
    'Desmalezado manual.', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-29'::date, 1, 'rp', 'RP46', 15.0, 30.0,
    NULL, 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-29'::date, 2, 'rp', 'RP46', 10.0, 20.0,
    'Se reenvía actividad por rectificación de progresivas.', 'si', NULL, NULL, NULL, true)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-30'::date, 3, 'camino', '093-13', 6.0, 7.0,
    NULL, 'si', NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='22127'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='41020';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-30'::date, 1, 'rp', 'RP46', 15.0, 30.0,
    'Regreso desde progresiva ascendente', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-06-30'::date, 2, 'rp', 'RP41', 160.0, 180.0,
    NULL, 'si', NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-07-01'::date, 2, 'rp', 'RP41', 170.0, 190.0,
    NULL, NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='40990'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='44808'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='1307';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-07-01'::date, 1, 'rp', 'RP46', 15.0, 30.0,
    'Regreso desde progresiva ascendente', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
WITH p AS (
  INSERT INTO partes_diarios (fecha, tarea_id, tipo_via, ruta, prog_ini, prog_fin,
    observaciones, foto_previa_url, foto_posterior_url,
    combustible_l, mezcla_asfaltica_tn, enviado_admin)
  VALUES ('2026-07-02'::date, 1, 'rp', 'RP46', 0.0, 15.0,
    'Regreso desde progresiva ascendente y culminación de la tarea en esa RP', NULL, NULL, NULL, NULL, false)
  RETURNING id
)
INSERT INTO parte_maquinarias (parte_id, orden, vehiculo_id)
  SELECT (SELECT id FROM p), 1::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21806'
  UNION ALL
  SELECT (SELECT id FROM p), 2::smallint, v.id FROM vehiculos v WHERE v.identificador='O.I.' AND v.numero='21803'
  UNION ALL
  SELECT (SELECT id FROM p), 3::smallint, v.id FROM vehiculos v WHERE v.identificador='R.O.' AND v.numero='29792';
COMMIT;

-- Verificar
SELECT COUNT(*) AS partes FROM partes_diarios;
SELECT COUNT(*) AS vinculaciones_maquinarias FROM parte_maquinarias;
SELECT tarea_id, COUNT(*) FROM partes_diarios GROUP BY tarea_id ORDER BY 1;
SELECT tipo_via, COUNT(*) FROM partes_diarios GROUP BY tipo_via ORDER BY 1;