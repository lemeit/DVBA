# Análisis · Informe Mensual Gerencia Ejecutiva DVBA

**Referencia:** *Informe MAYO 2026 - Gerencia Ejecutiva.pdf* (Ministerio de Infraestructura y Servicios Públicos, Gobierno de la Provincia de Buenos Aires)

Documento base para diseñar el módulo **Partes Diarios** del sistema DVBA. Guarda la estructura oficial que debe poder generar el sistema a partir de los datos capturados en campo por cada zona.

## Estructura del reporte oficial

### 1. Datos generales de la provincia (portada + resumen)

**Total km intervenidos** en el mes por las 12 zonas de PBA. Ejemplo mayo 2026:

| Zona | Km intervenidos |
|------|----------------|
| Zona I - Arrecifes | 801,45 |
| Zona II - Morón | 23,36 |
| Zona III - Ensenada | 439,74 |
| Zona IV - Junín | 189,45 |
| Zona V - Chivilcoy | 267,19 |
| **Zona VI - Saladillo** | **343,90** |
| Zona VII - Dolores | 29,00 |
| Zona VIII - Pehuajó | 81,10 |
| Zona IX - Azul | 548,60 |
| Zona X - Mar del Plata | 462,30 |
| Zona XI - Bahía Blanca | 167,50 |
| Zona XII - Necochea | 77,40 |
| **TOTAL** | **3.430,99 km** |

**Km por tipo de tarea** (8 categorías, totales provinciales):

| Tarea | Km mayo 2026 |
|-------|--------------|
| Corte de pasto | 2.591,09 |
| Mantenimiento de pavimento | 194,30 |
| Caminos rurales | 425,70 |
| Calzado de banquinas | 147,98 |
| Señalización y demarcación | 65,32 |
| Reparación de alcantarillas | 5,40 |
| Alumbrado | 1,20 |
| Reemplazo de barandas Flex Beam | 0,00 |

**Recuento de tareas ejecutadas** (cantidad de eventos, no km): bar chart con las 8 categorías. Corte de pasto suele ser el número más alto (~160 en mayo).

**Registro de formularios cargados por zona** (últimos 5 meses en gráfico de barras + línea de tendencia). Zona VI en mayo cargó 53 formularios (venía de 59 → 0 → 67 → 61 → 53 en los últimos 5 meses).

### 2. Página por zona (2 hojas cada una)

**Hoja A - Administrativa** (fondo turquesa DVBA):
- **Rutas intervenidas:**
  - Red Primaria: lista de RPs con formato `RP 030 | RP 044 | RP 047 | RP 051 | RP 061 | RP 091`
  - Red Secundaria: códigos de caminos `093-08 | 093-13`
  - Km totales por red (primaria y secundaria)
- **Equipos utilizados** por tipo de tarea:
  - Calzado de banquina: `CAMIONETA – CAMIÓN – PALA CARGADORA FRONTAL - MOTONIVELADORA`
  - Caminos rurales: `CAMIONETA – MOTONIVELADORA - RETROEXCAVADORA`
  - Corte de pasto: `CAMIONETA – TRACTOR – DESMALEZADORA - RETROEXCAVADORA`
  - Mant. de pavimento: `CAMIONETA – CAMIÓN – MINI CARGADORA`
  - Señalización y dem.: `CAMIONETA`
- **6-8 fotos** de las tareas del mes en grid

**Hoja B - GIS/QGIS** (fondo turquesa DVBA):
- Mapa del partido con marcas por tipo de tarea
- Leyenda con 8 íconos de colores (uno por tarea)
- Km por tipo con totales
- Total general de la zona destacado

### 3. Zona VI Saladillo — Mayo 2026 (nuestro caso)

- **Red Primaria intervenida:** RP 030, 044, 047, 051, 061, 091 (307,90 km)
- **Red Secundaria:** 093-08, 093-13 (33 km)
- **Total zona:** 343,90 km
- **Desagregado por tarea:**
  - Corte de pasto: 315,10 km
  - Calzado de banquina: 12,00 km
  - Caminos rurales: 9,70 km
  - Mantenimiento de pavimento: 5,90 km
  - Señalización y demarcación: 1,20 km

### 4. Página especial - Luminarias LED

- Cantidad total colocadas en el mes (167 en mayo)
- Mapa provincial con puntos amarillos
- **Tabla detalle** con: `Zona | Ubicación | Cantidad`. Ejemplos Zona VI en mayo:
  - Zona VI – Saladillo · Tramo Navarro - Las Heras · **12**
  - Zona VI - Saladillo · General las Heras - RP 6 · **12**
  - Zona VI – Saladillo · Intersección con variante rotonda RP47 · **12**
  - Zona VI – Saladillo · Intersección RP 91 · **36**
  - Zona VI - Saladillo · Intersección con camino 093-13 · **36**

## Modelo de datos que necesita el módulo Partes Diarios

### Tabla `partes_diarios` (existente, ampliar)

Campos ya presentes en v9.19+:
- fecha, ruta, prog, tipo, estado, partido, lat, lng, obs, foto_url

Campos a agregar:
- `zona` (por ahora fijo = "VI Saladillo", futuro = todas)
- `categoria_tarea`: enum de 8 categorías (`alumbrado`, `calzado_banquinas`, `caminos_rurales`, `corte_pasto`, `mant_pavimento`, `reemplazo_flex_beam`, `rep_alcantarillas`, `senalizacion_demarcacion`)
- `km_intervenidos`: NUMERIC(6,2) — total km cubiertos por el parte
- `km_ini` / `km_fin`: progresivas de inicio y fin (para tareas lineales)
- `equipos_usados`: TEXT[] — array de equipos (camioneta, camión, motoniveladora, etc.)
- `cuadrilla`: TEXT — nombres/cantidad de personal
- `materiales`: JSONB — para casos especiales (ej: `{"luminarias_led": 12, "tipo": "150W"}` para alumbrado)
- `duracion_horas`: NUMERIC(4,1)
- `foto_url_2`, `foto_url_3`, `foto_url_4`: fotos múltiples opcionales

### Tabla `equipos_disponibles` (catálogo)

Ya tenemos 49 vehículos del CSV. Estructura:
- id, tipo (camioneta/camión/tractor/etc.), modelo, patente, año, activo (bool), disponible (bool)

### Tabla `categorias_tareas` (catálogo)

Las 8 categorías DVBA + los tipos actuales de relevamiento del sistema. Combinar en un solo taxonomía.

## UI que necesita el módulo

### App móvil - Carga de parte diario

Wizard rápido para cuadrilla en campo:
1. Fecha (default hoy)
2. Categoría de tarea (8 botones grandes con íconos)
3. Ruta / Camino (usa el mismo selector actual del wizard)
4. Km inicio / Km fin (o "puntual")
5. Equipos usados (multi-select del catálogo)
6. Cuadrilla (texto libre + botones rápidos)
7. Materiales (opcional, si es alumbrado → cantidad LED)
8. Foto(s)
9. Observaciones
10. Guardar

### App escritorio - Revisión y aprobación

Kanban / lista con filtros por fecha, ruta, categoría, cuadrilla. Similar a la cola de pendientes actual pero con vista mensual.

### App escritorio - Reportes tipo DVBA

- Bar chart por categoría
- Total km por zona
- Mapa con puntos por categoría (colores como el informe oficial)
- Tabla luminarias LED (o cualquier categoría con "materiales" especiales)
- Export a PDF/PPTX en formato oficial

## Prioridad de implementación

1. **Fase 1** — Modelo de datos ampliado en Supabase + bulk insert de los 657 partes históricos del CSV
2. **Fase 2** — UI wizard móvil para carga de parte diario
3. **Fase 3** — UI escritorio revisión/aprobación
4. **Fase 4** — Dashboard estadístico con gráficos tipo el informe
5. **Fase 5** — Export a PDF con layout oficial (usar librería tipo pdfmake o jsPDF con plantilla)

## Referencia gráfica

Los 8 íconos de leyenda del informe usan estos colores:

| Categoría | Color |
|-----------|-------|
| Alumbrado | Amarillo |
| Calzado de banquinas | Rojo bordó |
| Caminos rurales | Violeta claro |
| Corte de pasto | Verde |
| Mantenimiento de pavimento | Gris claro |
| Reemplazo de barandas Flex Beam | Rosa |
| Reparación de alcantarillas | Naranja |
| Señalización y demarcación | Azul oscuro |

Estos colores deberían reutilizarse en el UI del portal para mantener continuidad visual con el informe oficial.
