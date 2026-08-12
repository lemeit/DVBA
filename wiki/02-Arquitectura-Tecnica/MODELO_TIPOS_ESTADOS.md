# Modelo de Tipos ↔ Estados — DVBA Zona VI

> Ver también: [[07-App-Movil-Modo-Basico|App móvil · Modo Básico]] · [[08-App-Movil-Modo-Avanzado|App móvil · Modo Avanzado]] (guía de usuario) · [[bitacora]]

**Versión:** v1.1 (2026-07-18) · `dvba_campo` v9.70 · `index` v8.0.1

Este documento es la **referencia única** para entender cómo se relacionan las categorías de relevamiento, los ítems específicos, los estados válidos y los sub-atributos condicionales en el sistema. Sirve para desarrolladores, operadores de campo y para integraciones futuras con QGIS / Supabase / reportes.

---

## 1. Conceptos

El sistema separa el registro vial en **3 dimensiones**:

| Dimensión | Definición | Ejemplo |
|---|---|---|
| **Elemento** | Qué objeto físico se está relevando | Calzada, señal, puente, banquina, luminaria |
| **Condición** | Cómo está ese elemento | Bueno / Regular / Malo / Crítico |
| **Acción** | Qué tarea se hizo o hay que hacer | Reconformado, desmalezado, bacheo |

Antes de v9.18 estas 3 dimensiones estaban mezcladas en el dropdown único de "Tipo" + un dropdown de Estado universal. Ahora cada categoría tiene su propio set de estados coherentes.

---

## 2. Árbol de categorías (10 categorías)

Definido en `dvba_tipos.js → DVBA_TIPOS.ARBOL`

### A. Relevamiento (estado de algo físico)

| Cat key | Label | Ítems destacados |
|---|---|---|
| `calzada` | 🛣️ Calzada | Bache · Bache crítico · Pavimento fisurado · Huellas (camino tierra) · Anegamiento por mala conformación · Erosión de calzada · Calzada en buen estado |
| `drenaje` | 💧 Banquinas y drenaje | Banquina deteriorada · Cuneta obstruida/dañada · Alcantarilla tapada/dañada · Erosión de talud |
| `estructura` | 🌉 Puentes y estructuras | Puente — fisura tablero/estribo · Junta deteriorada · Baranda dañada · Alcantarilla mayor · Muro de contención dañado |
| `senial_vertical` | 🚧 Señalización vertical | Submenú extenso MSV 2017: P-, R-, I-, mojones, carteles destino, guardarrails, delineadores |
| `demarcacion` | 🛑 Demarcación horizontal | Eje borrado · Demarcación lateral borrada · Tachones faltantes · Demarcación inexistente · Línea de frenado · Senda peatonal |
| `iluminacion` | 💡 Iluminación | Columna dañada/faltante · Lámpara fundida · Fallo eléctrico ramal · Tendido afectado |
| `entorno` | 🌿 Entorno | Vegetación a desmalezar · Inundación · Derrumbe · Árbol caído · Tranquera dañada · Animal muerto |
| `seguridad` | 🚨 Seguridad vial | Siniestro vial · Punto negro · Zona peligrosa sin señalizar · Cámara de control · Radar de velocidad · Emergencia |

### B. Tarea / Acción

| Cat key | Label | Ítems destacados |
|---|---|---|
| `mantenimiento` | 🚜 Mantenimiento / Tarea | Reconformado de tierra · Desmalezado manual/mecánico · Limpieza de cuneta/canal · Bacheo en frío/caliente/profundo · Sellado de fisuras · Repavimentación · Riego asfáltico · Repintado · Reposición señal/mojón · Mejoramiento dolomita/suelo cal · Poda |

### C. Catch-all

| Cat key | Label | Ítems |
|---|---|---|
| `otro` | 📝 Otro | Otro |

---

## 3. Estados válidos por categoría

Definido en `datos/dvba_estados.js → DVBA_ESTADOS.POR_CAT`

Cada estado tiene `{ key, label, color }`. La `key` es el valor que se guarda en la BD (string corto). El `label` es lo que se ve en el `<select>`.

| Categoría | Estados (key → label) |
|---|---|
| **calzada / drenaje** | `bueno` Bueno · `regular` Regular · `malo` Malo · `critico` Crítico · `pendiente` Pendiente · `en_obra` En obra · `reparado` Reparado |
| **estructura** | Igual que calzada **+** `inspeccion_urg` Inspección urgente |
| **senial_vertical** | `ok` OK/Visible · `danada` Dañada · `ilegible` Ilegible · `falta` Falta · `mal_ubic` Mal ubicada · `pendiente` Pendiente · `en_reposicion` En reposición · `reemplazada` Reemplazada |
| **demarcacion** | `visible` Visible · `borrada` Borrada · `inexistente` Inexistente · `pendiente` Pendiente · `en_ejec` En ejecución · `repintado` Repintado |
| **iluminacion** | `funciona` Funciona · `parcial` Funciona parcial · `no_funciona` No funciona · `pendiente` Pendiente · `en_reparacion` En reparación · `reparado` Reparado |
| **entorno** | `activo` Activo · `monitoreo` Bajo monitoreo · `pendiente` Pendiente · `en_limpieza` En limpieza · `resuelto` Resuelto |
| **seguridad** | `activo` Activo · `monitoreo` Bajo monitoreo · `resuelto` Resuelto |
| **mantenimiento** | `programado` Programado · `en_ejecucion` En ejecución · `finalizado` Finalizado · `suspendido` Suspendido · `cancelado` Cancelado |
| **otro** | `sin_esp` Sin especificar · `pendiente` Pendiente · `en_obra` En obra · `reparado` Reparado |

### Estados universales (UNIVERSALES)

```js
pendiente · en_obra · reparado
```

Aparecen al final del dropdown en la mayoría de las categorías, para que siempre se pueda marcar el seguimiento operativo independiente de la condición específica del elemento.

---

## 4. Sub-atributos condicionales

Aparecen en la UI **solo cuando la categoría del tipo elegido los soporta**.

### Tipo de superficie

Aplica en: `calzada`, `mantenimiento`

Definido en `DVBA_ESTADOS.SUPERFICIES`:

| key | label |
|---|---|
| `asfalto` | Asfalto (pav. flexible) |
| `hormigon` | Hormigón (pav. rígido) |
| `tierra` | Tierra |
| `estabilizado` | Estabilizado |
| `dolomita` | Mejorado con dolomita |
| `suelo_cal` | Mejorado con suelo cal |

### Modalidad de tarea

Aplica en: `mantenimiento`

Definido en `DVBA_ESTADOS.MODALIDADES`:

| key | label |
|---|---|
| `manual` | Manual |
| `mecanico` | Mecánico |
| `mixto` | Mixto |

### Sub-atributos implícitos (v9.18a · 2026-06-24)

Algunos tipos ya incluyen la modalidad o el tipo de superficie en el propio nombre. Ej: "Desmalezado mecánico" ya dice "mecánico"; mostrar además un selector de Modalidad con Manual/Mecánico/Mixto sería redundante y permitiría contradicciones.

Para estos casos hay dos funciones nuevas en `dvba_estados.js` que detectan la modalidad o superficie a partir del nombre del tipo:

```js
DVBA_ESTADOS.modalidadImplicita('Desmalezado mecánico')     // → 'mecanico'
DVBA_ESTADOS.superficieImplicita('Mejoramiento con dolomita')// → 'dolomita'
```

**Patrones matcheados:**

| Función | Patrones (regex `\b...\b`) | Devuelve |
|---|---|---|
| `modalidadImplicita` | `manual` | `'manual'` |
| | `mecánica?` | `'mecanico'` |
| | `mixt[oa]` | `'mixto'` |
| `superficieImplicita` | `dolomita` | `'dolomita'` |
| | `suelo cal` | `'suelo_cal'` |
| | `camino tierra` + `reconformado` | `'tierra'` |
| | `hormigón` | `'hormigon'` |
| | `asfáltic[oa]` o `riego asf` | `'asfalto'` |

**Comportamiento en la UI (`onTipoChange`):**

- Si la categoría aplica el sub-atributo Y el nombre del tipo lo tiene implícito → **oculta** el selector pero **setea** el valor en el `<select>` para que la metadata serializada lo capture igual.
- Si la categoría aplica el sub-atributo pero NO está implícito → muestra el selector para que el usuario elija.
- Si la categoría no aplica el sub-atributo → selector oculto (comportamiento previo).

**Ejemplos concretos:**

| Tipo elegido | Modalidad selector | Modalidad guardada | Superficie selector | Superficie guardada |
|---|---|---|---|---|
| Bacheo en frío | oculto | (vacío) | visible | usuario elige |
| Bacheo asfáltico | oculto | (vacío) | oculto | `asfalto` |
| Desmalezado manual | oculto | `manual` | oculto | (no aplica) |
| Desmalezado mecánico | oculto | `mecanico` | oculto | (no aplica) |
| Reconformado camino tierra | oculto | (no aplica) | oculto | `tierra` |
| Mejoramiento con dolomita | oculto | (no aplica) | oculto | `dolomita` |
| Repavimentación | oculto | (no aplica) | visible | usuario elige |

**Cómo extender:** agregar el patrón regex a la función correspondiente en `dvba_estados.js` (sin tocar HTML ni JS de las apps).

---

## 5. Decisión de NO migrar la BD (Opción B)

Los registros antiguos en Supabase (que tienen `estado` = "Bueno", "Crítico", "Regular", "En obra", etc. — strings del modelo viejo) **se mantienen tal cual**. No se ejecuta script de migración.

**Comportamiento:**
- Al **listar** registros viejos en escritorio o móvil: se muestran tal como están (string libre).
- Al **editar** un registro viejo: el dropdown se inicializa **vacío** porque el string viejo no matchea con las nuevas `key`. El usuario elige nuevo estado del modelo actual y al guardar se sobrescribe.
- Al **insertar nuevos** registros: se usan las `key` del nuevo modelo (`bueno`, `regular`, `critico`, etc.).

Ventaja: cero riesgo de corrupción de datos. Cero downtime. Cero complejidad de scripts SQL.

---

## 6. Serialización de sub-atributos en `observaciones`

Como Supabase tiene una sola columna `observaciones` y no quisimos agregar columnas nuevas, **`superficie` y `modalidad` se serializan al final del campo observaciones** con este formato:

```
<observaciones del usuario>

[superficie:asfalto · modalidad:mecanico]
```

El parseo en reportes futuros puede hacerse con un regex simple:

```js
const match = obs.match(/\[(?:superficie:(\w+))?\s*·?\s*(?:modalidad:(\w+))?\]\s*$/);
const superficie = match?.[1] || null;
const modalidad  = match?.[2] || null;
```

Esto se puede revisar para una migración futura a columnas dedicadas si crece el uso.

---

## 7. Flujo en la app móvil (`dvba_campo.html`)

1. Usuario elige **categoría** en wizard (grilla de iconos)
2. Usuario elige **ítem** dentro de la categoría
3. Se dispara `tipoSeleccionar(valor)` → `onTipoChange(valor)`
4. `onTipoChange`:
   - Infiere categoría con `DVBA_TIPOS.categoriaDe(valor)`
   - Repuebla `<select id="f-estado">` con `DVBA_ESTADOS.getEstados(cat)`
   - Muestra `f-superficie-wrap` si `DVBA_ESTADOS.aplicaSuperficie(cat)`
   - Muestra `f-modalidad-wrap` si `DVBA_ESTADOS.aplicaModalidad(cat)`
5. Usuario completa estado + (opcional) superficie + (opcional) modalidad + observaciones + foto
6. `guardarRegistro()` concatena `superficie/modalidad` al final de `observaciones`

## 8. Flujo en la app de escritorio (`index.html`)

1. Usuario elige tipo desde `z6-tipo-display` (cards con buscador)
2. Se dispara `z6TipoSeleccionar(valor)` → `onTipoChange(valor)` (versión de index.html)
3. Misma lógica: select de estado se repuebla, `fsuperficie` y `fmodalidad` se muestran/ocultan
4. `guardar()` concatena los metadatos en `observaciones` antes de mandar a Supabase

---

## 9. Archivos involucrados

| Archivo | Rol |
|---|---|
| `dvba_tipos.js` | Árbol de 10 categorías + ítems + helper `categoriaDe()` |
| `datos/dvba_estados.js` | Modelo de estados por categoría + superficies + modalidades + flags `aplicaSuperficie/aplicaModalidad` |
| `dvba_campo.html` | Implementa onTipoChange + HTML del wizard con campos condicionales |
| `index.html` | Implementa onTipoChange + sidebar con campos condicionales |
| `sw.js` | Cachea `dvba_estados.js` en CACHE_URLS |

---

## 10. Extensibilidad

### Para agregar un nuevo ítem a una categoría existente
Editar `dvba_tipos.js` → `ARBOL.<cat>.items` y agregar el string. Listo, aparece en ambas apps automáticamente.

### Para agregar un nuevo estado a una categoría existente
Editar `dvba_estados.js` → `POR_CAT.<cat>` y agregar `{ key, label, color }`. Aparece en el dropdown automáticamente.

### Para agregar una nueva categoría
1. `dvba_tipos.js` → agregar entrada a `ARBOL` con `{ icon, label, items }`
2. `dvba_estados.js` → agregar entrada a `POR_CAT` con sus estados específicos
3. Si necesita sub-atributos nuevos: agregar a `SUPERFICIES` / `MODALIDADES` y a los Sets `CAT_CON_SUPERFICIE` / `CAT_CON_MODALIDAD`
4. Bump versión

### Para agregar un nuevo sub-atributo (ej. "Equipo usado")
1. `dvba_estados.js`: definir el array de opciones, función `getEquipos()`, función `aplicaEquipo(cat)` y Set `CAT_CON_EQUIPO`
2. Agregar `<select id="f-equipo">` (móvil) y `<select id="fequipo">` (escritorio) con `style="display:none"`
3. Extender `onTipoChange` con la lógica de mostrar/ocultar
4. Extender el handler de guardado para serializar `equipo:` en observaciones

---

## 11. Roadmap futuro

- [ ] Migrar `superficie` y `modalidad` de observaciones serializadas a **columnas dedicadas en Supabase** cuando se quieran cruzar en reportes.
- [ ] Filtros en lista de registros por **categoría** + **estado** (no solo por ruta).
- [ ] Dashboard agregado: "% Bueno vs Malo vs Crítico" por ruta y por categoría.
- [ ] Integración con la app de **caminos secundarios** para que use el mismo modelo Tipo↔Estado.
- [ ] Mapeo de estados viejos del modelo legacy (`Bueno`→`bueno`, `Crítico`→`critico`, etc.) al editar registros antiguos.

---

**Última actualización:** 2026-07-18 · Ing. Luciano Lamaita · versión app referencia: v9.70 / v8.0.1
