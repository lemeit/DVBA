-- ═════════════════════════════════════════════════════════════════════════════
-- SQL_34 · Batch de usuarios de prueba para zonas piloto IV/V/VI
-- ═════════════════════════════════════════════════════════════════════════════
-- Fecha: 2026-08-31
-- Autor: DVBA Zona VI Saladillo
--
-- QUÉ HACE
--   1. Sube lulamaita@vialidad.gba.gov.ar de "gerencia" a "admin" (backup admin).
--   2. Elimina los 2 alias viejos (tecnica.dvba.z6+z4/+z5@gmail.com).
--   3. Crea 15 usuarios de prueba nuevos en auth.users + usuarios_perfil,
--      completando los 7 roles operativos zonales en las 3 zonas piloto (IV, V, VI).
--
-- NAMING: {rol}.{zona}@dvba.test  (zonas romanas en minúscula)
--   capataz.iv    · jefetecnica.iv · jefeoperativa.iv · jefeadmin.iv · jefeautomot.iv
--   jefezona.iv   · tecnico.iv     · [idem V y VI]
--
-- PASSWORD INICIAL para todos los .test:  Dvba2026!
--   (cambiar al primer login, o el admin puede resetear)
--
-- IMPORTANTE
--   Este SQL corre como postgres/superuser en el Supabase SQL Editor y usa
--   auth.users directo. En producción real conviene usar el Admin API.
-- ═════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) Subir lulamaita@ a admin
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE public.usuarios_perfil
   SET rol = 'admin', zona = NULL
 WHERE user_id = (SELECT id FROM auth.users WHERE email = 'lulamaita@vialidad.gba.gov.ar');

-- Actualizar el nombre para reflejar el rol nuevo
UPDATE public.usuarios_perfil
   SET nombre = 'Luciano Lamaita (Vialidad · admin)'
 WHERE user_id = (SELECT id FROM auth.users WHERE email = 'lulamaita@vialidad.gba.gov.ar');


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Eliminar los 2 alias viejos (+z4 y +z5)
-- ─────────────────────────────────────────────────────────────────────────────
-- Primero borrar del perfil (FK), después del auth
DELETE FROM public.usuarios_perfil
 WHERE user_id IN (SELECT id FROM auth.users WHERE email IN (
   'tecnica.dvba.z6+z4@gmail.com',
   'tecnica.dvba.z6+z5@gmail.com'
 ));

DELETE FROM auth.users
 WHERE email IN (
   'tecnica.dvba.z6+z4@gmail.com',
   'tecnica.dvba.z6+z5@gmail.com'
 );


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Crear usuarios de prueba en batch
-- ─────────────────────────────────────────────────────────────────────────────
-- Definimos la lista en un CTE. Cada fila se convierte en:
--   · una entrada en auth.users (con password hasheado + email confirmado)
--   · una entrada en usuarios_perfil (con rol + zona + nombre)
--
-- ON CONFLICT: si el email ya existe, no lo re-crea (idempotente).

WITH nuevos AS (
  SELECT * FROM (VALUES
    -- ── Zona IV Junín ────────────────────────────────────────────────────────
    ('tecnico.iv@dvba.test',        'tecnico',              'IV',   'Técnico IV (testing)'),
    ('capataz.iv@dvba.test',        'capataz',              'IV',   'Capataz IV (testing)'),
    ('jefetecnica.iv@dvba.test',    'jefe_tecnica',         'IV',   'Jefe Div. Técnica IV'),
    ('jefeadmin.iv@dvba.test',      'jefe_administrativa',  'IV',   'Jefe Div. Administrativa IV'),
    ('jefeautomot.iv@dvba.test',    'jefe_automotores',     'IV',   'Jefe Div. Automotores IV'),
    ('jefezona.iv@dvba.test',       'jefe_zona',            'IV',   'Jefe Zona IV'),

    -- ── Zona V Chivilcoy ─────────────────────────────────────────────────────
    ('tecnico.v@dvba.test',         'tecnico',              'V',    'Técnico V (testing)'),
    ('capataz.v@dvba.test',         'capataz',              'V',    'Capataz V (testing)'),
    ('jefetecnica.v@dvba.test',     'jefe_tecnica',         'V',    'Jefe Div. Técnica V'),
    ('jefeadmin.v@dvba.test',       'jefe_administrativa',  'V',    'Jefe Div. Administrativa V'),
    ('jefeautomot.v@dvba.test',     'jefe_automotores',     'V',    'Jefe Div. Automotores V'),
    ('jefezona.v@dvba.test',        'jefe_zona',            'V',    'Jefe Zona V'),

    -- ── Zona VI Saladillo · roles que faltan ─────────────────────────────────
    -- (capataz1.vi, jefeoperativa.vi, jefetecnica.vi, jefezona.vi ya existen)
    -- (tecnica.dvba.z6@gmail.com es jefe_tecnica VI real de producción)
    ('tecnico.vi@dvba.test',        'tecnico',              'VI',   'Técnico VI (testing)'),
    ('jefeadmin.vi@dvba.test',      'jefe_administrativa',  'VI',   'Jefe Div. Administrativa VI'),
    ('jefeautomot.vi@dvba.test',    'jefe_automotores',     'VI',   'Jefe Div. Automotores VI')
  ) AS t(email, rol, zona, nombre)
),
-- Insertar en auth.users. gen_random_uuid genera el UUID y crypt hashea la pass.
insert_auth AS (
  INSERT INTO auth.users (
    id, instance_id, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    aud, role, is_super_admin
  )
  SELECT
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000000',
    n.email,
    crypt('Dvba2026!', gen_salt('bf')),
    NOW(),  -- email confirmed
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('nombre', n.nombre),
    'authenticated',
    'authenticated',
    FALSE
  FROM nuevos n
  WHERE NOT EXISTS (SELECT 1 FROM auth.users WHERE email = n.email)
  RETURNING id, email
)
-- Insertar en usuarios_perfil con los UUIDs recién creados
INSERT INTO public.usuarios_perfil (user_id, nombre, rol, zona, activo)
SELECT
  ia.id,
  n.nombre,
  n.rol,
  n.zona,
  TRUE
FROM insert_auth ia
JOIN nuevos n ON n.email = ia.email
ON CONFLICT (user_id) DO NOTHING;


COMMIT;

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
SELECT u.email, p.nombre, p.rol, p.zona, p.activo
  FROM public.usuarios_perfil p
  JOIN auth.users u ON u.id = p.user_id
 WHERE u.email LIKE '%@dvba.test'
    OR u.email LIKE '%gmail.com'
    OR u.email LIKE '%vialidad.gba.gov.ar'
 ORDER BY p.zona NULLS FIRST, p.rol, u.email;

-- Total esperado post-SQL_34:
--   1  admin (lucianolamaita@gmail.com)
--   1  admin (lulamaita@vialidad.gba.gov.ar · promovido)
--   1  gerencia (gerencia@dvba.test)
--   1  jefe_tecnica VI (tecnica.dvba.z6@gmail.com · producción real)
--   6  Zona IV (7 roles menos jefe_operativa que ya existe = 6 nuevos)
--   6  Zona V  (idem)
--   3  Zona VI (tecnico, jefeadmin, jefeautomot · faltantes)
--   +ya existentes: capataz1.vi, jefeoperativa.iv/v/vi, jefezona.vi, jefetecnica.vi

-- ─────────────────────────────────────────────────────────────────────────────
-- CREDENCIALES DE PRUEBA
-- ─────────────────────────────────────────────────────────────────────────────
-- Email: cualquiera de la lista (@dvba.test)
-- Password: Dvba2026!
-- Al primer login se puede cambiar la password desde el módulo Auth.
-- Admin puede resetear cualquiera con el botón 🔑 Reset del panel de usuarios.
