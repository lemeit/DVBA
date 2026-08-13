# Plan de escalado multi-zona · SIG Vial PBAᵝ

**Estado actual:** v8.52 · Zona VI Saladillo en producción · infraestructura multi-zona lista (Fases 1-4 completas: roles, RLS zonal, panel admin).

**Objetivo:** escalar el sistema a las 12 zonas viales de la DVBA con la misma calidad de data que la Zona VI.

---

## Estructura de carpetas propuesta

```
datos/
├── zona_I/            # Arrecifes
│   ├── partidos_zonaI.geojson
│   ├── red_secundaria_zonaI_final.geojson
│   ├── rp_bundles_zonaI/       # 1 archivo JS por RP
│   │   ├── rutas_rp8.js
│   │   ├── rutas_rp51.js
│   │   └── ...
│   ├── mojones_zonaI.js
│   └── caracteristicas_viales_zonaI.js
├── zona_II/           # Morón
│   ├── ...
├── zona_III/          # Ensenada
├── zona_IV/           # Junín  ← siguiente objetivo (ya tenemos usuario piloto)
├── zona_V/            # 9 de Julio
├── zona_VI/           # Saladillo  ← COMPLETA (referencia)
├── zona_VII/          # ...
├── zona_VIII/         # Pehuajó
├── zona_IX/           # Azul
├── zona_X/            # Mar del Plata
├── zona_XI/           # Bahía Blanca
└── zona_XII/          # Necochea
```

**Cargador dinámico** (a implementar en `datos/loader_zona.js`):

Al login, el sistema detecta la zona del usuario (`DVBA_PERFIL.zonaActual()`) y carga dinámicamente:
- `datos/zona_XX/partidos_zonaXX.geojson`
- `datos/zona_XX/red_secundaria_zonaXX_final.geojson`
- `datos/zona_XX/rp_bundles_zonaXX/*.js`
- `datos/zona_XX/mojones_zonaXX.js`
- `datos/zona_XX/caracteristicas_viales_zonaXX.js`

Admin ve todas las zonas (carga bajo demanda desde el picker de zona).

---

## Assets requeridos por zona

| Asset | Descripción | Estado Zona VI |
|-------|-------------|----------------|
| **Partidos** | Polígonos de partidos de la zona (IGN o INDEC) en WGS84 | ✅ 8 partidos |
| **RPs geojson** | Trazas de rutas provinciales con atributos (nombre, sección vial) | ✅ 15 RPs |
| **RP bundles calibrados** | Un `rutas_rpXX.js` por ruta con CHAIN_DATA + ANCHORS_DATA (km→lat/lng) | ✅ 8 RPs con bundle · 7 pendientes |
| **Caminos secundarios** | GeoJSON con NOMEMCLATURA, TRAMO_NUM, DENOMINACION, CLASE, LONGITUD_KM_WGS84, LONGITUD_KM_ORIG | ✅ 100 caminos · 129 tramos |
| **Mojones** | Puntos kilométricos oficiales georreferenciados por RP | ✅ 198 mojones |
| **CARACT_VIALES** | Data oficial del CSV SALADILLO_RED con tramos oficiales por RP | ✅ 15 RPs con tramos |

---

## Checklist paso a paso: habilitar una zona nueva

### Etapa 1 · Preparación de data (offline, QGIS)

**1.1** Obtener del área central de DVBA o del INDEC:
- Polígonos de partidos que integran la zona (formato original: shp, geojson, gpkg)
- Trazas oficiales de las RPs de la zona (misma fuente)
- CSV oficial de RPs con tramos (equivalente a SALADILLO_RED.csv)
- Ubicación de mojones (si están relevados)

**1.2** Procesar en QGIS:
- Reproyectar todo a **WGS84 (EPSG:4326)**
- Simplificar geometrías (Douglas-Peucker con tolerancia ~5m para ahorrar peso)
- Validar topología (sin gaps, sin overlaps)
- Recortar caminos secundarios al bounding box de la zona (usar `caminos_secundarios_PBA.geojson` como fuente y filtrar por PARTIDO_NOMBRE)

**1.3** Exportar como geojson:
- `partidos_zonaXX.geojson` — MultiPolygon con properties.partido
- `red_secundaria_zonaXX_final.geojson` — MultiLineString con properties NOMEMCLATURA, TRAMO_NUM, DENOMINACION, CLASE, LONGITUD_KM_WGS84, LONGITUD_KM_ORIG, PARTIDO_NOMBRE
- Para RPs: geojson por ruta o un solo archivo con properties.ruta

### Etapa 2 · Calibración de RPs (opcional pero recomendado)

**2.1** Para cada RP, generar bundle calibrado (`rutas_rpXX.js`):
- `CHAIN_DATA[XX]` = array de `[lng, lat]` ordenados según sentido oficial de progresivas
- `ANCHOR_DATA[XX]` = array de `{km: N, acc: idx}` con anchors cada 10-50 km (usar mojones como anchors)

**2.2** Testear la calibración:
- Que `progresivaAPunto(rid, km)` devuelva el punto correcto
- Que `_proyectarCursor` calcule progresivas coherentes al hover

### Etapa 3 · Subida al repo

**3.1** Crear carpeta `datos/zona_XX/` con los archivos generados en Etapa 1

**3.2** Editar `datos/loader_zona.js` (a implementar en v8.53) para agregar la zona a la lista de zonas activas

**3.3** Test manual:
- Crear un usuario técnico de esa zona en Supabase
- Loguearse y verificar que ve el mapa con partidos+rutas correctos
- Cargar un registro de prueba y confirmar que `zona=XX` en la BD

### Etapa 4 · Habilitación institucional

**4.1** Contactar a Jefe de la zona nueva

**4.2** Crear usuarios técnicos desde el Panel Admin (`admin_usuarios.html`)

**4.3** Enviar mail de invitación (via Supabase Dashboard) a los técnicos

**4.4** Sesión de capacitación (30-60 min): tour del sistema + PWA móvil + primeras cargas

**4.5** Habilitar la zona en producción y comunicar a Gerencia

---

## Prioridades y tiempos estimados

| Zona | Contacto | Prioridad | ETA data | ETA producción |
|------|----------|-----------|----------|----------------|
| **VI Saladillo** | Ing. Lamaita | ✅ COMPLETA | — | En producción |
| **IV Junín** | *pendiente* | 🟡 Media (piloto extra) | 2 semanas | +2 semanas |
| **V 9 de Julio** | *pendiente* | 🟡 Media (limítrofe con VI) | 2 semanas | +2 semanas |
| I, II, III, VII, VIII, IX, X, XI, XII | *pendientes* | 🔵 Baja (a demanda) | 2-4 semanas c/u | según equipo |

**Estrategia sugerida**: hacer primero IV y V (limítrofes con VI, fáciles de validar). Después usar como referencia para el resto.

---

## Cambios en el código requeridos para escalado (v8.53+)

### 1. Cargador dinámico de data (`datos/loader_zona.js`)

Nueva función `cargarDataZona(zonaCod)` que:
- Fetchea los geojsons de esa zona
- Popula variables globales `PARTIDOS_GEO`, `RUTAS_DATA`, `RUTA_META`, `MOJONES_DATA`, `CARACT_VIALES` según la zona
- Refresca los layers Leaflet

Se llama:
- En login/reload cuando hay perfil con zona asignada
- Cuando admin cambia de zona con el picker

### 2. Refactor de imports en HTML

Hoy los `rutas_rpXX.js` se importan estáticamente en el `<head>`:

```html
<script src="datos/rutas_rp30.js" defer></script>
<script src="datos/rutas_rp40.js" defer></script>
```

Migrarlos al cargador dinámico. Beneficio: el portal público arranca ~50% más rápido porque solo carga lo necesario.

### 3. Panel Admin · lista de zonas habilitadas

En `admin_usuarios.html`, agregar sección "Zonas" que muestre el estado de cada una (habilitada / en preparación / no iniciada) con checklist visible.

### 4. Trigger extendido en Supabase

El trigger de SQL_10 (`forzar_zona_por_rol`) ya funciona para cualquier zona. No requiere cambio.

Se sugiere agregar validación adicional: si la zona del user no está en la lista de zonas habilitadas, rechazar el insert con mensaje amigable.

---

## Presupuesto de esfuerzo

**Por zona** (con data ya disponible):
- Etapa 1 (QGIS): 4-8 horas
- Etapa 2 (calibración): 2-4 horas por RP (15 RPs → 30-60 h ideal)
- Etapa 3 (subida): 1 hora
- Etapa 4 (capacitación): 2 horas

**Total por zona:** 40-70 horas (~1 semana intensiva o 2 semanas normales)

**Total para las 11 zonas restantes:** 11 × 50 h = **550 horas** (~14 semanas dedicadas)

Este esfuerzo puede paralelizarse si se involucra a las divisiones técnicas de cada zona.

---

## Riesgos y mitigación

| Riesgo | Mitigación |
|--------|-----------|
| Data de otras zonas no está en formato estándar | Documentar el proceso QGIS en un HANDOFF por zona |
| Trazas oficiales tienen errores | Usar `caminos_secundarios_PBA.geojson` como referencia base (ya validado) |
| Falta de tiempo del Ing. Lamaita para todas las zonas | Documentar el flujo bien para que otros técnicos puedan replicar |
| Divisiones técnicas de otras zonas no tienen QGIS | Ofrecer procesamiento centralizado (Ing. Lamaita hace el geojson, ellos validan) |

---

## Roadmap sugerido 2026-2027

**Trimestre 1 (Sept-Nov 2026)**
- Entrega institucional interna (mediados septiembre)
- Si hay interés institucional, formalizar el proyecto
- Habilitar Zona IV (Junín) como segunda zona piloto

**Trimestre 2 (Dic 2026 - Feb 2027)**
- Zonas IV + V + I en producción
- Panel de métricas por zona en el sidebar

**Trimestre 3-4 (Mar-Ago 2027)**
- Resto de zonas escalonadas según prioridad
- v9.0 institucional (sacar el badge BETA cuando esté validado por Gerencia)
