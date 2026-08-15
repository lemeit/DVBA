# PLAN DE ROLES Y MULTI-ZONA

> Documento de diseño — visión y roadmap
> Autor: Ing. Luciano Lamaita · Div. Técnica DVBA Zona VI
> Iniciado: 2026-07-13
> Estado: **draft — pendiente de discusión con Gerencia**

---

## 1. Contexto y motivación

Al día de hoy el sistema opera como si toda la DVBA fuera Zona VI Saladillo. Auth existe (Supabase Auth), pero cualquier usuario autenticado tiene los mismos permisos: ve todo, edita todo, borra todo. Las políticas RLS actuales verifican sólo `auth.role() = 'authenticated'`.

La visión que estamos definiendo es escalar el sistema a las **12 zonas viales** de la Provincia, con niveles de acceso diferenciados que reflejen la estructura organizacional real de la DVBA:

- **Cada zona** administra sus propias tareas, partes diarios, relevamientos, reportes.
- **Gerencia y Auditoría central** ven todas las zonas para métricas comparativas y control.
- **El sistema entero** sigue siendo consultable públicamente (mapa + info de rutas), sin datos sensibles.
- **Un rol admin/desarrollador** por encima para mantenimiento del sistema.

Este documento define los 4 niveles, el modelo de datos, la migración desde el estado actual y las fases del roadmap.

---

## 2. Los 4 niveles de usuario

### Nivel 1 · Público (sin login)

**Quién:** cualquier visitante del portal.
**Puede:**
- Ver el mapa completo con las 15 RPs, 100+ caminos secundarios, mojones, partidos.
- Consultar progresivas al mover el cursor sobre una traza.
- Filtrar por partido/clase/estado los caminos secundarios.
- Ver el listado y detalle SIG Vial de rutas y caminos.

**No puede:**
- Ver relevamientos (fotos con sello), partes diarios, ni ningún dato operativo.
- Cargar, editar, ni borrar nada.

**Implementación:** el portal `index.html` en modo "solo lectura" es este nivel. Ya funciona así hoy cuando no estás logueado.

### Nivel 2 · Técnico de Zona (usuario más común)

**Quién:** empleados del sector técnico de cada zona (ej. vos como Ing. Zona VI).
**Puede — sobre SU zona únicamente:**
- Todo lo del nivel público.
- Cargar relevamientos desde el móvil (fotos con sello GPS).
- Aprobar/rechazar registros pendientes (workflow de armonización).
- Editar sellos, rotar fotos, mover puntos en el mapa.
- Cargar partes diarios (Plan de Seguridad en la Circulación).
- Ver reportes de su zona (dashboards, exports CSV).
- Gestionar vehículos, tareas, catálogos locales.

**No puede:**
- Ver ni editar datos de otras zonas.
- Generar reportes globales o inter-zonales.
- Gestionar usuarios o cambiar roles.

**Aclaración:** el técnico ve el mapa entero de la Provincia (rutas + caminos son datos públicos), pero los relevamientos, partes, fotos y estadísticas están filtradas por su zona.

### Nivel 3 · Gerencia / Auditoría (nivel supervisión)

**Quién:** Gerencia Ejecutiva, Auditoría interna, jefaturas del Ministerio.
**Puede:**
- Todo lo del técnico de zona, pero **sobre TODAS las zonas**.
- Ver comparativos inter-zonales: qué zona ejecutó más km, qué tareas se hicieron dónde, uso de maquinaria.
- **Generar reportes PDF oficiales** con el layout DVBA definido en `docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`: portada con km por zona, bar chart 8 tareas, 2 hojas por zona (administrativa + GIS), página especial luminarias LED con tabla ubicación/cantidad, paleta de 8 colores por categoría.
- Exportar a Excel/CSV la vista consolidada.
- Marcar partes como "enviado a admin" (workflow oficial).
- Auditar quién cargó/editó qué (log de cambios).

**No puede:**
- Modificar catálogos base (tareas, tipos de vía, clases).
- Gestionar usuarios/roles del sistema.

### Nivel 4 · Admin / Desarrollador (nivel sistema)

**Quién:** vos, mientras estés al frente del sistema; en el futuro un equipo TI.
**Puede:**
- Todo lo del nivel gerencia.
- Gestionar usuarios: alta, baja, cambio de rol, cambio de zona asignada.
- Editar catálogos base (tareas, maquinarias, clases, RLS policies).
- Reprocesar bundles, correr migraciones SQL, deploys.
- Ver logs técnicos, métricas de uso del sistema.

---

## 3. Modelo de datos (Supabase)

### 3.1. Tabla `usuarios_perfil` (nueva)

Extiende `auth.users` con datos operativos.

```sql
CREATE TABLE usuarios_perfil (
  user_id     UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre      TEXT NOT NULL,
  rol         TEXT NOT NULL CHECK (rol IN ('publico','tecnico','gerencia','admin')),
  zona        TEXT,                          -- 'I'..'XII', NULL para gerencia/admin (todas)
  activo      BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX ON usuarios_perfil(zona);
CREATE INDEX ON usuarios_perfil(rol);
```

**Convención clave:** el rol `gerencia` y `admin` tienen `zona = NULL` (interpretado como "todas"). Los técnicos tienen `zona` obligatorio.

### 3.2. Columna `zona` en tablas operativas

Agregar `zona TEXT` (nullable en partes históricos, obligatorio en nuevos) a:
- `partes_diarios`
- `relevamientos`
- (`parte_maquinarias` y `parte_fotos` no necesitan — heredan por FK)

El valor se llena al INSERT desde el perfil del usuario logueado, o se detecta automáticamente a partir del partido detectado (ya que cada partido pertenece a una única zona).

### 3.3. Políticas RLS por rol

Reemplazar las policies actuales (que son "authenticated puede todo") por policies zone-aware:

```sql
-- SELECT: todos los authenticated pueden leer datos de SU zona.
-- Gerencia y admin ven todas.
CREATE POLICY partes_read_zona ON partes_diarios
FOR SELECT USING (
  auth.role() = 'authenticated' AND (
    zona = (SELECT zona FROM usuarios_perfil WHERE user_id = auth.uid())
    OR (SELECT rol FROM usuarios_perfil WHERE user_id = auth.uid()) IN ('gerencia','admin')
  )
);

-- INSERT: cada uno escribe en su zona; admin puede en cualquiera.
CREATE POLICY partes_insert_zona ON partes_diarios
FOR INSERT WITH CHECK (
  auth.role() = 'authenticated' AND (
    zona = (SELECT zona FROM usuarios_perfil WHERE user_id = auth.uid())
    OR (SELECT rol FROM usuarios_perfil WHERE user_id = auth.uid()) = 'admin'
  )
);

-- UPDATE/DELETE: mismo criterio que INSERT (owner o admin).
```

La consulta a `usuarios_perfil` se cachea con `security definer` en una función helper para evitar N+1:

```sql
CREATE OR REPLACE FUNCTION current_user_zona() RETURNS TEXT
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
  SELECT zona FROM usuarios_perfil WHERE user_id = auth.uid()
$$;
CREATE OR REPLACE FUNCTION current_user_rol() RETURNS TEXT
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
  SELECT rol FROM usuarios_perfil WHERE user_id = auth.uid()
$$;
```

Y las policies quedan más legibles:

```sql
CREATE POLICY partes_read_zona ON partes_diarios FOR SELECT USING (
  zona = current_user_zona() OR current_user_rol() IN ('gerencia','admin')
);
```

### 3.4. Views para gerencia

```sql
CREATE VIEW v_dashboard_zonas AS
SELECT
  zona,
  COUNT(*) AS partes,
  SUM(km_recorridos) AS km_totales,
  COUNT(DISTINCT DATE_TRUNC('month', fecha)) AS meses_activos
FROM partes_diarios
GROUP BY zona
ORDER BY zona;
```

---

## 4. Cambios en el frontend

### 4.1. Login mejorado

El login actual pide email + password. Post-migración, después del login exitoso:

```js
const { data: perfil } = await _supa
  .from('usuarios_perfil').select('rol, zona, nombre')
  .eq('user_id', session.user.id).single();

localStorage.setItem('dvba_perfil', JSON.stringify(perfil));
// El header ya lee 'dvba_zona' — actualizar para leer de perfil.
```

### 4.2. Header por rol

- **Técnico**: header muestra su zona fija (no se puede cambiar). Dropdown de zona se oculta.
- **Gerencia**: dropdown permite navegar entre zonas (o "Todas" para vista consolidada).
- **Admin**: igual que gerencia + botón "⚙ Admin" al panel de gestión de usuarios.

### 4.3. Menú por rol

```
Público       → [Mapa]
Técnico       → [Mapa] [Cola pendientes] [Plan de Seguridad] [Reportes de mi zona]
Gerencia      → [Mapa] [Cola global] [Plan de Seguridad] [Reportes] [Dashboard Consolidado] [📄 PDF Oficial]
Admin         → todo lo anterior + [👥 Usuarios] [⚙ Sistema]
```

### 4.4. Reportes PDF oficiales (nivel gerencia)

Aprovechamos el layout ya analizado en `docs/ANALISIS_INFORME_GERENCIAL_DVBA.md` para armar plantilla DVBA:
- Portada con logo + fecha + zona/período
- Resumen ejecutivo (KPIs: km recorridos, partes, tareas, uso de flota)
- Tabla de tareas por partido
- Gráficos de barras (chart.js server-side o mermaid → PNG)
- Tabla de luminarias LED (o el detalle que corresponda)
- Anexo fotográfico (fotos de relevamientos con GPS)
- Pie institucional

Stack técnico probable: **jsPDF + jsPDF-autotable** (client-side, ya usamos vanilla JS) o generación en Supabase Edge Function con `pdf-lib`.

---

## 5. Migración desde el estado actual

### Fase 0 — Datos actuales (hoy)

- Todos los partes históricos y relevamientos tienen `responsable_id` NULL o el tuyo (Ing. Luciano).
- No hay tabla `usuarios_perfil`.
- Todo authenticated tiene acceso total.

### Fase 1 — Preparar backend (1 sesión, ~2h) — SQL listo v7.92, pendiente correr

1. ✅ `docs/SQL_7_usuarios_perfil.sql` (v7.92): tabla `usuarios_perfil` con CHECK constraint rol↔zona, índices, trigger `updated_at`, funciones helper `current_user_zona()` y `current_user_rol()` (security definer stable), RLS de la propia tabla (self-read + admin-write).
2. ✅ `docs/SQL_8_zona_en_tablas.sql` (v7.92): ALTER `partes_diarios` + `relevamientos` con columna `zona`, backfill a `'VI'`, índices, view `v_partes_diarios_export` actualizada para incluir columna Zona en el CSV.
3. ⏳ **Correr los dos SQLs en Supabase** (SQL Editor con service_role — bypasea RLS). Verificar con los `SELECT` de cada archivo.
4. ⏳ **Bootstrap admin**: dentro de `SQL_7` hay un bloque comentado con el INSERT del primer perfil. Sacar el UID con:
   ```sql
   SELECT id, email FROM auth.users WHERE email = 'admin.zonavi@vialidad.gba.gov.ar';
   ```
   Descomentar y ejecutar el `INSERT INTO usuarios_perfil (user_id, nombre, rol, zona) VALUES ('<UID>', 'Luciano Lamaita', 'admin', 'VI');`
5. ⏳ Verificación final: todos los partes tienen `zona='VI'`, tu perfil existe con `rol='admin'`.

**NOTA importante:** estos SQLs son 100 % aditivos y no tocan policies vigentes. El sistema sigue funcionando idéntico hasta que arranque Fase 2 (frontend zone-aware) o Fase 3 (RLS zonal en SQL 9).

### Fase 2 — Frontend zone-aware (1-2 sesiones)

5. ✅ v7.93/v9.69 · **Core**: nuevo módulo `datos/perfil.js` compartido (cacheado en SW). `DVBA_PERFIL.cargar(_supa)` trae la fila de `usuarios_perfil` y la guarda en `localStorage['dvba_perfil']`. `DVBA_PERFIL.zonaActual()` devuelve zona con fallback a `'VI'`. Loader activo en `partes_diarios.html` y `dvba_campo_lite.html` (la full usa dvbaAuth wrapper y queda para Fase 2b). Fill automático de `zona` en INSERT/UPDATE de `partes_diarios` + INSERT de `relevamientos` en las 4 apps.
6. ⏳ Fase 2b · Header con zona/rol visible + carga proactiva del perfil en `dvba_campo.html` (requiere refactor del auth wrapper).
7. ✅ v7.93 · Al guardar un parte/relevamiento nuevo, llenar `zona` desde `DVBA_PERFIL.zonaActual()`.
8. ⏳ Fase 2c · Menú lateral filtrado por rol (esperar a que haya usuarios técnicos creados).

#### 2d · Brand dinámico por zona en apps móviles (pendiente)

Actualmente `dvba_campo.html` y `dvba_campo_lite.html` muestran hardcoded `"Zona VI Saladillo"` en el header y footer. Esto no rompe nada si alguien de Zona VII se loguea (los INSERT ya usan `DVBA_PERFIL.zonaActual()` que trae la zona real del `usuarios_perfil`), pero **visualmente sería incorrecto** — el técnico verá "Zona VI Saladillo" arriba mientras que sus registros se guardan como `zona='VII'`.

**Fix planeado** (v9.7X futuro):
- Agregar un `<span data-zona-brand>Zona VI Saladillo</span>` en los 3 lugares hardcoded (header lite, footer full, modal Info).
- Mapping de zona → nombre en `datos/perfil.js`:
  ```js
  const ZONAS_LABEL = {
    'I': 'Zona I La Plata', 'II': 'Zona II Mercedes', 'III': 'Zona III San Nicolás',
    'IV': 'Zona IV Junín', 'V': 'Zona V Pehuajó', 'VI': 'Zona VI Saladillo',
    'VII': 'Zona VII Bahía Blanca', 'VIII': 'Zona VIII Mar del Plata',
    'IX': 'Zona IX Trenque Lauquen', 'X': 'Zona X Azul',
    'XI': 'Zona XI Chascomús', 'XII': 'Zona XII Necochea'
  };
  DVBA_PERFIL.zonaLabel = () => ZONAS_LABEL[DVBA_PERFIL.zonaActual()] || 'Zona ??';
  ```
- Al cargar el perfil, `perfil.js` reemplaza `document.querySelectorAll('[data-zona-brand]')` con el label correspondiente.
- Idem para el sello v4: prefijo del texto principal.

**Bloqueo actual:** confirmar con Vialidad el nombre oficial de cabecera de cada zona (los 12 nombres arriba son la interpretación estándar del listado DVBA, pero conviene validarlos contra un documento oficial antes de hardcodearlos en el mapping).

### Fase 3 — Activar RLS zonal (1 sesión)

9. ✅ **v8.23 · SQL creado en `docs/SQL_9_rls_zonal.sql`** — reemplaza las policies "authenticated puede todo" (SQL_5 + SETUP_AUTH) por versiones zone-aware. Cubre 4 tablas: `relevamientos`, `partes_diarios`, `parte_maquinarias`, `parte_fotos`. Incluye:
   - Sanity check (verifica que funciones current_user_zona/rol de SQL_7 existan + columna zona de SQL_8).
   - 4 policies por tabla principal (SELECT/INSERT/UPDATE/DELETE) que respetan los 4 roles: público lee mapa · técnico solo su zona · gerencia lee todo · admin CRUD global.
   - Fallback para usuarios legacy sin perfil (`current_user_rol() IS NULL`) → tratados como técnicos de zona VI (default histórico, no rompe el flujo actual).
   - Trato de `zona IS NULL` como accesible (protege registros históricos que no llegaron con backfill).
   - Bloque **ROLLBACK completo comentado** al final para volver a SQL_5 si algo falla.
   - SELECT de verificación (listar policies activas + contar registros por zona).
10. ⏳ **Correr en Supabase** con service_role (SQL Editor).
11. ⏳ Testear desde el frontend:
    - Técnico Zona VI → solo ve zona VI.
    - Técnico Zona VII (crear uno de prueba) → solo ve zona VII.
    - Gerencia → ve todo, no puede editar.
    - Admin → CRUD global.
12. ⏳ Migrar `zona IS NULL` residuales a `'VI'` (comando comentado en el header del SQL_9).

### Fase 4 — Panel Admin (1-2 sesiones)

13. Nueva página `admin_usuarios.html`: listar, crear, editar, desactivar usuarios. Cambiar rol/zona.
14. Import inicial: crear usuarios para los técnicos de las otras 11 zonas (con emails de la Provincia).

### Fase 5 — Reportes PDF Gerencia (2-3 sesiones)

15. Elegir librería PDF (jsPDF vs Edge Function).
16. Plantilla base con logo + tipografía DVBA.
17. Reporte "Resumen mensual por zona".
18. Reporte "Consolidado 12 zonas" (solo gerencia).
19. Anexo fotográfico automático.

---

## 6. Relación con lo que ya está pendiente

Este plan se puede trabajar **en paralelo** al resto del roadmap sin bloquearlo. Sinergias:

- **v7.71 detección de partido**: ya guarda `partido` en cada parte. La zona se deriva del partido (Zona VI = 8 partidos conocidos, misma lógica para otras zonas). Cuando llegue Fase 1 ya vamos a tener el mapping listo.
- **v7.72 dropdown de zona en header**: prepara terreno para Fase 2 (el dropdown eventualmente se filtra según rol).
- **Módulo Reportes (Bloque 3 Sesión 3)**: el reporte de zona podemos hacerlo con RLS activo (nivel técnico) desde el inicio. El PDF oficial (nivel gerencia) queda para Fase 5.
- **v7.72 mapa con partes sin foto**: la capa Leaflet nueva ya filtra por zona una vez que RLS esté activo — sin cambios en el código de la capa.
- **App móvil (v9.X)**: al login carga perfil. Si el técnico es de Zona III no puede cargar relevamientos en Zona VI (validación cliente + servidor).

**Dependencias duras** (cosas que sí bloquean):
- El bulk insert histórico ya cargó todo como Zona VI. Al migrar a multi-zona hay que decidir: ¿los 632 partes históricos quedan como `zona='VI'` fijo (probablemente sí, son datos tuyos) o abrir para reasignación manual?
- Los relevamientos actuales: mismo dilema.

---

## 7. Decisiones abiertas (para conversar con Gerencia)

1. **¿Cómo se dan de alta los usuarios?** Autoregistro con dominio institucional (@vialidad.gba.gob.ar), o alta manual por Admin.
2. **¿Compartir datos entre zonas linderas?** Ej. Zona VI y Zona VII a veces trabajan en el borde (RP61). ¿El técnico VII puede ver los partes VI en su borde? Cross-zone read con permiso especial.
3. **¿Un rol "supervisor de zona"** entre técnico y gerencia? Un jefe de zona que aprueba los partes de su equipo antes de enviar a admin central.
4. **¿Auditoría / log de cambios?** ¿Guardamos quién editó qué y cuándo? Es una tabla `audit_log` que crece rápido.
5. **¿Formato del PDF oficial?** Ya tenemos analizado el layout — ver **[`docs/ANALISIS_INFORME_GERENCIAL_DVBA.md`](ANALISIS_INFORME_GERENCIAL_DVBA.md)**, que descompone la estructura del *Informe Mensual Gerencia Ejecutiva DVBA* (mayo 2026): portada con km totales por zona, bar chart 8 tareas, 2 hojas por zona (administrativa + GIS), página especial luminarias LED con tabla ubicación/cantidad, paleta de 8 colores por categoría. Es la referencia para la Fase 5.
6. **¿Escalamos a las otras zonas ya (piloto)?** Si otra zona (VII u XI) quiere sumarse, ¿arrancamos con ellos como beta?

---

## 8. Estimación de esfuerzo

| Fase | Sesiones | Bloquea qué |
|---|---|---|
| 0. Este doc | 1 | — |
| 1. Backend prep | 1 | Todo lo demás |
| 2. Frontend zone-aware | 2 | Fase 3 |
| 3. RLS zonal | 1 | Fase 4-5 |
| 4. Panel admin | 2 | Onboarding otras zonas |
| 5. Reportes PDF | 3 | Presentación a Gerencia |

**Total: ~10 sesiones de desarrollo**, que se puede intercalar con el resto del roadmap (mapa con partes, módulo reportes básico, etc). No es un big bang — cada fase deja el sistema funcionando.

---

## 9. Próximos pasos concretos

1. **Vos**: revisar este doc, marcar disidencias, definir las 6 preguntas abiertas de la Sección 7.
2. **Vos**: conseguir emails institucionales de contactos en otras zonas (para piloto Fase 2b).
3. ~~Pasar adjunto del reporte PDF oficial~~ ✅ Ya está analizado en `docs/ANALISIS_INFORME_GERENCIAL_DVBA.md` (Informe MAYO 2026 · Gerencia Ejecutiva).
4. **Nosotros**: al arrancar la Fase 1, priorizar cerrar el trabajo pendiente actual (mapa con partes en v7.74+, módulo reportes básico) y arrancar Fase 1 en paralelo.

---

_Última actualización: 2026-07-13 · v7.73 del sistema._
