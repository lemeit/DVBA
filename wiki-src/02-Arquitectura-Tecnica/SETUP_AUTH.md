# Setup de autenticación DVBA — Supabase Auth + RLS

> Ver también: [[04-Roles-y-Accesos|Roles y accesos]] (guía de usuario) · [[bitacora]] (20 mayo 2026 — Seguridad)

**Objetivo:** que solo usuarios autenticados puedan crear, editar o borrar
relevamientos. La lectura queda pública (para que el mapa siga funcionando
sin login para invitados).

---

## Orden de ejecución (IMPORTANTE)

Hay que hacerlo en este orden exacto para no romper la app durante la
migración:

1. **Crear usuarios en Supabase Dashboard** (primero, sin tocar nada más)
2. **Actualizar las apps con el código de login** (push del HTML)
3. **Activar RLS en Supabase** (SQL del paso 3 más abajo)
4. **Probar login + guardado**

Si activás RLS en el paso 3 antes de tener el login funcionando, la app
deja de poder escribir hasta que esté el código en producción.

---

## Paso 1 — Crear usuarios en Supabase Dashboard

1. Entrar a https://supabase.com/dashboard
2. Seleccionar el proyecto DVBA (`txjlfpffyzuhdqtfhlmc`)
3. Menú izquierdo: **Authentication → Users**
4. Botón **Add user → Create new user**
5. Llenar:
   - **Email:** ej. `tecnica.dvba.z6@gmail.com`
   - **Password:** clave fuerte (anotala en un gestor)
   - **Auto Confirm User:** ✓ tildado (sin esto el usuario tiene que
     confirmar el email antes de poder loguearse)
6. Repetir para cada persona del equipo que vaya a cargar datos

### Cerrar el registro libre (importante)

Para que nadie pueda registrarse desde la app:

1. **Authentication → Providers → Email**
2. Tildar `Enable Email provider`
3. Destildar `Enable Email signup` (esto bloquea sign-up desde la API)
4. Tildar `Confirm email` (solo afecta si el signup estuviera abierto)
5. Save

---

## Paso 2 — Actualizar las apps con el código de login

Después de hacer push de los cambios al repo (dvba_campo.html e
index.html con la pantalla de login integrada), esperá ~1 minuto a que
GitHub Pages publique.

Verificar que:
- Al abrir `lemeit.github.io/DVBA/dvba_campo.html` aparece la pantalla
  de login antes de poder usar la app.
- Login con un usuario válido entra a la app.
- Logout vuelve a la pantalla de login.

Mientras RLS no esté activado (paso 3), un usuario sin login todavía
podría escribir bypaseando la UI (con DevTools). Pero la mayoría de
usuarios ya queda bloqueada.

---

## Paso 3 — Activar RLS en Supabase

Abrí **SQL Editor** en el dashboard y corré este bloque:

```sql
-- ═══════════════════════════════════════════════════════════════
-- DVBA RLS Setup — Tabla relevamientos
-- Lectura pública, escritura solo authenticated
-- ═══════════════════════════════════════════════════════════════

-- 1) Habilitar RLS
ALTER TABLE public.relevamientos ENABLE ROW LEVEL SECURITY;

-- 2) Borrar políticas previas si existieran (idempotente)
DROP POLICY IF EXISTS "lectura_publica" ON public.relevamientos;
DROP POLICY IF EXISTS "insert_authenticated" ON public.relevamientos;
DROP POLICY IF EXISTS "update_authenticated" ON public.relevamientos;
DROP POLICY IF EXISTS "delete_authenticated" ON public.relevamientos;

-- 3) Lectura: cualquiera (anon o autenticado) puede SELECT
CREATE POLICY "lectura_publica" ON public.relevamientos
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- 4) Escritura: solo usuarios autenticados
CREATE POLICY "insert_authenticated" ON public.relevamientos
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "update_authenticated" ON public.relevamientos
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "delete_authenticated" ON public.relevamientos
  FOR DELETE
  TO authenticated
  USING (true);
```

### Storage — bucket `relevamientos` (fotos)

Las fotos también necesitan políticas. Por defecto Storage tiene RLS
habilitado pero puede que el bucket esté con política permisiva.
Asegurar:

```sql
-- Fotos: lectura pública, subida solo autenticados
DROP POLICY IF EXISTS "fotos_lectura"    ON storage.objects;
DROP POLICY IF EXISTS "fotos_subida_auth" ON storage.objects;
DROP POLICY IF EXISTS "fotos_borrar_auth" ON storage.objects;

CREATE POLICY "fotos_lectura" ON storage.objects
  FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'relevamientos');

CREATE POLICY "fotos_subida_auth" ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'relevamientos');

CREATE POLICY "fotos_borrar_auth" ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'relevamientos');
```

---

## Paso 4 — Verificar

Casos a probar:

| Caso | Esperado |
|---|---|
| Visitante sin login abre `dvba_campo.html` | Ve pantalla de login |
| Visitante sin login abre `index.html` | Ve mapa (lectura), pero no puede guardar |
| Intento de POST con DevTools sin token | Supabase rechaza 401 |
| Login con usuario válido | Acceso normal a guardar |
| Cerrar sesión | Vuelve a pantalla de login |
| Sesión expirada (>1h sin uso) | Auto-refresh transparente |
| Sin internet, ya logueado | Cola offline funciona; sincroniza al volver |

---

## Cómo agregar más usuarios después

Cada vez que necesites dar acceso a otra persona:

1. Dashboard → Authentication → Users → Add user
2. Email + password + Auto Confirm tildado
3. Pasale las credenciales por canal seguro
4. Le decís que entre al sitio y haga login

## Cómo revocar acceso

1. Dashboard → Authentication → Users
2. Buscar al usuario
3. Botón "..." → Delete user (borra usuario y todas sus sesiones)

O cambiar password desde el dashboard si solo querés invalidar la sesión.

---

## Detalles técnicos del frontend

- Módulo común: `datos/auth.js` — manejo de login, logout, refresh,
  token. Expone `window.dvbaAuth`.
- Sesión guardada en localStorage bajo clave `dvba_session`.
- Auto-refresh con refresh_token cuando el access_token está a <60s de
  expirar.
- Fetch helper `dvbaAuth.fetchAuth(url, opts)` agrega automáticamente
  los headers `apikey` y `Authorization: Bearer <token>`.
- Si una request devuelve 401, se borra la sesión local y se propaga el
  error.

### Anon key vs Bearer token

- La `anon key` (la que está en el JS) sigue funcionando para SELECT.
- Para INSERT/UPDATE/DELETE, el header `Authorization` debe ser
  `Bearer <access_token>` del usuario logueado. La anon key del mismo
  header **no alcanza** una vez activado RLS.
