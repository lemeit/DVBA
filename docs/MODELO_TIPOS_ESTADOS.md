# Modelo de Tipos ↔ Estados — DVBA Zona VI

**Versión:** v1.3 (2026-08-14) · `dvba_campo` v9.95.7 · `index` v8.75
**Modelo Tipos v2** con eje NATURALEZA (Relevamiento vs Tarea).

Este documento es la **referencia única** para entender cómo se relacionan las categorías, ítems, estados y sub-atributos condicionales en el sistema. Sirve para desarrolladores, operadores de campo e integraciones futuras con QGIS / Supabase / reportes.

---

## 1. Concepto central — Modelo Tipos v2

Un registro sobre la red vial tiene tres dimensiones ortogonales:

| Dimensión | Preguntas | Ejemplos |
|---|---|---|
| **Naturaleza** | ¿Es una observación o una acción? | Relevamiento · Tarea |
| **Elemento** | ¿Sobre qué elemento vial? | Calzada · Puentes · Señalización · Drenaje |
| **Ítem específico** | ¿Qué específicamente? | Bache · Cebras · Mojón · Cuneta obstruida |

El modelo anterior (v1) tenía la naturaleza mezclada con la categoría: había una categoría plana `mantenimiento` que agrupaba tareas de cualquier elemento (bacheo, colocación de cebras, desmalezado, etc.). Eso mezclaba dos ejes distintos y hacía difícil responder preguntas como *"¿cuánto trabajo hicimos sobre señalización este mes vs cuánto tenemos por relevar?"*.

En v2, la categoría `mantenimiento` **desaparece como categoría separada** y pasa a ser una naturaleza que se combina con cada elemento.

---

## 2. Naturaleza

| Key | Label | Cuándo se usa |
|---|---|---|
| `relevamiento` | 🔍 **Relevamiento** | Se observa el estado de un elemento vial existente. Ejemplos: *"Este bache está crítico"*, *"Este mojón falta"*, *"Cuneta obstruida"*, *"Puente con fisura en tablero"*. |
| `tarea` | 🚜 **Tarea de mantenimiento** | Se registra una acción ejecutada o programada sobre el elemento. Ejemplos: *"Bacheé este tramo"*, *"Coloqué cebras en este cabezal"*, *"Repuse este mojón"*, *"Desmalezado mecánico"*. |

La naturaleza se guarda en la BD en la columna `naturaleza` (ver §7 · Migración BD).

---

## 3. Elemento (categorías) — 8 categorías

Definido en `dvba_tipos.js → DVBA_TIPOS.ARBOL_V2`. Todas las categorías admiten AMBAS naturalezas excepto `seguridad`, que solo admite relevamiento (los siniestros y puntos negros son observaciones, no tareas).

| Cat key | Label | 🔍 Ítems relev (destacados) | 🚜 Ítems tarea (destacados) |
|---|---|---|---|
| `calzada` | 🛣️ Calzada | Bache · Bache crítico · Pavimento fisurado/ondulado/descascarado · Huellas (camino tierra) · Anegamiento · Erosión · Calzada en buen estado | **Mantenimiento de caminos rurales** · Reconformado de tierra · Bacheo frío/caliente/profundo · Sellado de fisuras · Repavimentación · Riego asfáltico · Mejoramiento dolomita/suelo cal |
| `drenaje` | 💧 Banquinas y drenaje | Banquina deteriorada · Cuneta obstruida/dañada · Alcantarilla tapada/dañada · Erosión de talud | Limpieza cuneta/canal/alcantarilla · Reparación cuneta/alcantarilla · Reconformado de banquina |
| `estructura` | 🌉 Puentes y estructuras | Puente — fisura tablero/estribo · Junta deteriorada · Baranda dañada · Deterioro tablero · Alcantarilla mayor · Muro contención dañado | Reparación puente (tablero/estribo) · Reparación junta · Reparación baranda/guardarrail · Reparación alcantarilla mayor · Reparación muro contención |
| `senial_vertical` | 🚧 Señalización vertical | MSV 2017 completo (P-, R-, I-) · Mojones · Guardarrail · Delineadores · **Cebras (cabezal alcantarilla / puente)** | Reposición señal · Reposición mojón · Colocación guardarrail/delineador/cebras · Repintado de cebras |
| `demarcacion` | 🛑 Demarcación horizontal | Eje borrado · Demarcación lateral borrada · Tachones faltantes · Demarcación inexistente · Línea de frenado · Senda peatonal borrada | Repintado eje/lateral/senda/línea frenado · Reposición de tachas |
| `iluminacion` | 💡 Iluminación | Columna dañada/faltante · Lámpara fundida · Fallo eléctrico ramal · Tendido afectado | Reposición columna/lámpara · Reparación tendido eléctrico · Migración a LED |
| `entorno` | 🌿 Entorno | Vegetación a desmalezar · Inundación · Derrumbe · Árbol caído · Tranquera dañada · Animal muerto | Desmalezado manual/mecánico · Poda · Limpieza general de ramal · Retiro árbol/animal · Reparación tranquera |
| `seguridad` | 🚨 Seguridad vial *(solo relev)* | Siniestro vial · Punto negro · Zona peligrosa sin señalizar · Zona de curva peligrosa · Emergencia · Cámara/Radar | — |
| `otro` | 📝 Otro | Otro | Otra tarea de mantenimiento |

---

## 4. Estados por naturaleza

Definidos en `datos/dvba_estados.js`. Cada estado tiene `{ key, label, color }`.

### 🔍 Estados de RELEVAMIENTO (condición del elemento)

| Categoría | Estados (key → label · color) |
|---|---|
| **calzada / drenaje** | `bueno` verde · `regular` amarillo · `malo` naranja · `critico` rojo |
| **estructura** | Igual a calzada **+** `inspeccion_urg` rojo oscuro |
| **senial_vertical** | `ok` verde · `danada` amarillo · `ilegible` naranja · `falta` rojo · `mal_ubic` gris |
| **demarcacion** | `visible` verde · `borrada` amarillo · `inexistente` rojo |
| **iluminacion** | `funciona` verde · `parcial` amarillo · `no_funciona` rojo |
| **entorno / seguridad** | `activo` rojo · `monitoreo` amarillo · `resuelto` verde |
| **otro** | `sin_esp` gris |

### 🚜 Estados de TAREA (ejecución) — únicos, comunes a todas las categorías

| Key | Label | Color |
|---|---|---|
| `programado` | Programado | violeta `#9c27b0` |
| `en_ejecucion` | En ejecución | ámbar `#f0a500` |
| `finalizado` | Finalizado | verde `#28a745` |
| `suspendido` | Suspendido | amarillo `#ffc107` |
| `cancelado` | Cancelado | gris `#6c757d` |

**Regla:** el set de estados que aparece en el `<select>` depende de `naturaleza`:
- `naturaleza='relevamiento'` → `DVBA_ESTADOS.getEstadosRelev(cat)`
- `naturaleza='tarea'`        → `DVBA_ESTADOS.getEstadosTarea()`
- Orquestador: `DVBA_ESTADOS.getEstadosPorNaturaleza(cat, naturaleza)`

---

## 5. Sub-atributos condicionales

### Tipo de superficie

Aplica cuando el elemento tiene superficie física visible: **calzada** (siempre) y en **tareas** sobre calzada/entorno.

Opciones (`DVBA_ESTADOS.SUPERFICIES`): asfalto · hormigón · tierra · estabilizado · mejorado con dolomita · mejorado con suelo cal.

### Modalidad de tarea

Aplica **solo cuando naturaleza = 'tarea'**. Un elemento no tiene modalidad; una tarea sí (se ejecuta manual, mecánica o mixta).

Opciones (`DVBA_ESTADOS.MODALIDADES`): manual · mecánico · mixto.

### Sub-atributos implícitos

Si el nombre del ítem ya incluye la modalidad o superficie, el selector se oculta y el valor se setea automáticamente:

| Patrón detectado | Sub-atributo → valor implícito |
|---|---|
| `manual` | modalidad → `manual` |
| `mecánica?` | modalidad → `mecanico` |
| `mixt[oa]` | modalidad → `mixto` |
| `motoniveladora` | modalidad → `mecanico` |
| `dolomita` | superficie → `dolomita` |
| `suelo cal` | superficie → `suelo_cal` |
| `tierra` + `reconformado` | superficie → `tierra` |
| `camino tierra` | superficie → `tierra` |
| `camino rural` / `caminos rurales` | superficie → `tierra` |
| `hormigón` | superficie → `hormigon` |
| `asfáltico` o `riego asf` | superficie → `asfalto` |

**Ejemplos:**

| Ítem elegido | Naturaleza | Modalidad selector | Modalidad implícita | Superficie selector | Superficie implícita |
|---|---|---|---|---|---|
| Bache crítico | relevamiento | oculto | (no aplica) | visible | usuario elige |
| Bacheo con material en frío | tarea | visible | usuario elige | visible | usuario elige |
| Bacheo asfáltico | tarea | visible | usuario elige | oculto | `asfalto` |
| Desmalezado manual | tarea | oculto | `manual` | oculto | (no aplica) |
| Desmalezado mecánico | tarea | oculto | `mecanico` | oculto | (no aplica) |
| Mantenimiento de caminos rurales | tarea | visible | usuario elige | oculto | `tierra` |
| Reconformado de tierra | tarea | visible | usuario elige | oculto | `tierra` |
| Mejoramiento con dolomita | tarea | visible | usuario elige | oculto | `dolomita` |
| Cebras (cabezal alcantarilla / puente) | relevamiento | oculto | (no aplica) | oculto | (no aplica) |
| Colocación de cebras | tarea | visible | usuario elige | oculto | (no aplica) |

---

## 6. Codificación visual en el mapa (Opción C)

Roadmap de rediseño de pins en el mapa para reflejar el modelo v2. Tres dimensiones visuales ortogonales:

**Forma** — codifica el **elemento**:

| Categoría | Forma |
|---|---|
| calzada | círculo |
| drenaje | rombo |
| estructura | cuadrado |
| senial_vertical | triángulo |
| demarcacion | pentágono |
| iluminacion | cruz |
| entorno | hexágono |
| seguridad | estrella |
| otro | círculo pequeño |

**Color** — codifica la **severidad del estado**:

- 🟢 verde: bueno / ok / visible / funciona / resuelto / finalizado
- 🟡 amarillo: regular / danada / borrada / parcial / monitoreo / suspendido
- 🟠 naranja: malo / ilegible / en_ejecucion
- 🔴 rojo: crítico / falta / inexistente / no_funciona / inspeccion_urg / activo
- ⚪ gris: pendiente / cancelado / mal_ubic / sin_esp
- 🔵 azul: en_obra / en_reparacion / reparado
- 🟣 violeta: programado

**Borde** — codifica la **naturaleza**:

- **Línea sólida** = relevamiento
- **Línea doble o punteada** = tarea

Ejemplo: pin cuadrado 🔴 con borde punteado = "Estructura · Reparación programada de puente (aún no ejecutada) · condición crítica reportada" (tarea + severidad + forma).

**Estado:** roadmap — implementación en Fase C (sesión próxima).

---

## 7. Migración BD — columna `naturaleza`

Script: **`docs/SQL_15_naturaleza_registros.sql`**

Agrega columna `naturaleza TEXT NOT NULL DEFAULT 'relevamiento'` a la tabla `relevamientos`, más constraint CHECK e índice para filtros.

**Comportamiento con registros existentes:**
- Todos los registros previos a la migración quedan como `naturaleza = 'relevamiento'` (aplicación retroactiva del DEFAULT).
- Los registros que estaban con categoría `mantenimiento` en el modelo v1 **NO se remapean automáticamente a `naturaleza = 'tarea'`** — quedan como `relevamiento` salvo que el usuario los reclasifique manualmente al editarlos.
- Los INSERT nuevos desde el frontend v2 escriben `naturaleza` explícita.

Cero migración destructiva. Cero downtime.

---

## 8. Flujo en la app móvil (`dvba_campo.html`) · v2

1. Usuario elige **naturaleza** (relevamiento / tarea) — primer paso del wizard, obligatorio.
2. Usuario elige **categoría** (grilla de 8 iconos).
3. Usuario elige **ítem** dentro de la categoría, filtrado por naturaleza:
   `DVBA_TIPOS.itemsPorNaturaleza(cat, naturaleza)`.
4. Se dispara `tipoSeleccionar(valor)` → `onTipoChange(valor)`.
5. `onTipoChange`:
   - Setea la categoría con `DVBA_TIPOS.categoriaDeV2(valor)`.
   - Repuebla `<select id="f-estado">` con `DVBA_ESTADOS.getEstadosPorNaturaleza(cat, naturaleza)`.
   - Muestra `f-superficie-wrap` si `DVBA_ESTADOS.aplicaSuperficieV2(cat, naturaleza)`.
   - Muestra `f-modalidad-wrap` si `DVBA_ESTADOS.aplicaModalidadV2(cat, naturaleza)`.
6. Usuario completa estado + (opcional) superficie + (opcional) modalidad + observaciones + foto.
7. `guardarRegistro()` incluye `naturaleza` en el `INSERT`.

## 9. Flujo en la app de escritorio (`index.html`) · v2

1. Tabs superiores del form: **Relevamiento** | **Tarea de mantenimiento**.
2. Al elegir tab → `_naturalezaActual = 'relevamiento' | 'tarea'`.
3. Selector de tipo (cards con buscador) muestra `DVBA_TIPOS.todosPorNaturaleza(_naturalezaActual)`.
4. Al elegir tipo → `onTipoChange()` con misma lógica que móvil.
5. `guardar()` incluye `naturaleza: _naturalezaActual` en el `registro`.

---

## 10. Archivos involucrados

| Archivo | Rol | v2 |
|---|---|---|
| `dvba_tipos.js` | Árbol de categorías + ítems | ARBOL_V2 con items_relev/items_tarea |
| `datos/dvba_estados.js` | Estados por categoría + sub-atributos | POR_CAT_RELEV + ESTADOS_TAREA + helpers V2 |
| `dvba_campo.html` | App móvil | Wizard con paso naturaleza (Fase B) |
| `index.html` | Portal escritorio | Tabs de naturaleza + colores mapa Opción C (Fase C) |
| `admin_usuarios.html`, `reportes.html`, `partes_diarios.html` | Portales | Filtros y visualización por naturaleza (Fase C) |
| `sw.js` | Service Worker | Cachea dvba_estados.js + dvba_tipos.js actualizados |
| `docs/SQL_15_naturaleza_registros.sql` | Migración BD | Columna `naturaleza` + constraint + índice |

---

## 11. Extensibilidad

### Para agregar un nuevo ítem a una categoría existente
Editar `dvba_tipos.js` → `ARBOL_V2.<cat>.items_relev` o `items_tarea` según corresponda. Aparece automáticamente en ambas apps.

### Para agregar un nuevo estado a una categoría existente
- Si es de condición (relevamiento): editar `POR_CAT_RELEV.<cat>` en `dvba_estados.js`.
- Si es de ejecución (tarea): editar `ESTADOS_TAREA` en `dvba_estados.js`.

### Para agregar una nueva categoría de elemento
1. `dvba_tipos.js` → agregar entrada a `ARBOL_V2` con `{ icon, label, items_relev, items_tarea }`.
2. `dvba_estados.js` → agregar entrada a `POR_CAT_RELEV` con sus estados de condición específicos.
3. Si necesita superficie/modalidad: extender `aplicaSuperficieV2` y `aplicaModalidadV2`.
4. Bump versión y CACHE_NAME en sw.js.

---

## 12. Cambios v1.3 (2026-08-14) — **rediseño Modelo Tipos v2**

- **Nueva dimensión NATURALEZA** (`relevamiento` | `tarea`) ortogonal a la categoría.
- **Categoría plana `mantenimiento` eliminada** del árbol conceptual — cada elemento tiene ahora dos listas de ítems.
- **Nueva estructura `ARBOL_V2`** en `dvba_tipos.js` con `items_relev` + `items_tarea` por categoría.
- **Nuevos helpers en `dvba_tipos.js`:** `categoriasV2`, `itemsPorNaturaleza(cat, nat)`, `todosPorNaturaleza(nat)`, `categoriaDeV2(tipoStr)`, `naturalezaDelItem(tipoStr)`.
- **Nueva API en `dvba_estados.js`:** `POR_CAT_RELEV` (estados de condición limpios), `ESTADOS_TAREA` (estados de ejecución), `getEstadosPorNaturaleza(cat, nat)`, `getEstadosRelev(cat)`, `getEstadosTarea()`, `aplicaSuperficieV2(cat, nat)`, `aplicaModalidadV2(cat, nat)`.
- **Migración BD** — nueva columna `naturaleza` en `relevamientos` (`SQL_15`).
- **Retrocompatibilidad total** — API v1/v2 legacy sigue funcionando; los HTMLs viejos no se rompen. La migración de UIs se hace por fases (móvil, escritorio, reportes) sin big bang.
- **Nuevos patrones de detección implícita:** `motoniveladora` → mecánico; `caminos rurales` → superficie tierra.
- **Roadmap de colores en el mapa (Opción C)** documentado: forma×color×borde para representar elemento×estado×naturaleza.

### Cambios v1.2 (2026-08-14) — previos a v2

- Nuevo ítem `senial_vertical` · "Cebras (cabezal alcantarilla / puente)".
- Nuevo ítem `mantenimiento` · "Mantenimiento de caminos rurales" (en v2 pasa a `calzada.items_tarea`).

---

**Última actualización:** 2026-08-14 · Ing. Luciano Lamaita · versión app referencia: v9.95.7 / v8.75
