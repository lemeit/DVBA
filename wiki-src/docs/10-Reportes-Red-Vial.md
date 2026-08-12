> [← Plan de Seguridad en la Circulación](09-Plan-Seguridad-Circulacion.md) · [Índice](00-Indice.md) · [Módulo Reportes (dashboard gerencial) →](11-Reportes-Dashboard-Gerencial.md)

# Reportes de Red Vial Provincial (portal)

El **portal principal** (`index.html`) incluye en su sidebar un panel de reportes unificado para la **Red Vial Provincial** — tanto Primaria (Rutas) como Secundaria (Caminos). Diseñado como *información pública*: los datos oficiales de la red vial son consultables por cualquier ciudadano, técnico o autoridad, sin necesidad de login. Los relevamientos con fotos (uso técnico DVBA interno) son un módulo aparte con acceso restringido.

### Flujo de selección (por click en el mapa)

1. Hacé click sobre cualquier ruta o camino visible en el mapa.

2. Se abre el modal *SIG Vial* con los datos oficiales de esa vía.

3. Tocá el botón verde **"+ Agregar al reporte"** en el footer del modal.

4. La vía queda marcada con **halo dorado** (`#ffb800`) en el mapa y aparece en el chip contador del sidebar.

5. Repetí para tantas rutas y caminos como quieras — se acumulan RPs + Caminos en la misma selección.

Chips del panel Mapa vs. selección del reporte:

los chips de rutas y filtros de caminos del panel Mapa

solo controlan qué se ve dibujado en el mapa

, NO entran al reporte. Para el reporte, la única forma de agregar es con click en la vía + botón "Agregar al reporte". Esto evita confusiones (antes se reportaban las 15 RPs si tildabas todas).

### Chip contador + lista expandible

Encima de las columnas del reporte, un chip verde muestra en tiempo real **"✓ 🛣 N rutas · 🚜 M tramos"**. Al lado, botón *"▾ Ver"* despliega la lista completa con:

- Cada RP con su color oficial + km oficial + cantidad de tramos + botón × para quitar

- Cada tramo de camino con su nomenclatura (034-01), tramo N°, denominación + botón × para quitar

- Botón "✕ Limpiar todos" para vaciar toda la selección

### Tabla y opciones del PDF

Las columnas se controlan con checkboxes: Long GIS · Long Oficial · Clase/Superficie · Prog. inicio/fin · Coords · Partido · Registros asociados · Mojones asociados. Además hay opciones del PDF:

- **Incluir mapa SVG** — genera un mapa vectorial en el PDF con contornos de partidos + ciudades de referencia + trazas coloreadas por clase + mojones y registros dentro del bbox del reporte

- **Captura real del mapa** — usa `leaflet-image` para capturar el mapa Leaflet completo (con basemap OSM real de tiles) y embebe el PNG en el PDF

### PDF unificado con secciones

Si tenés seleccionados solo RPs, el PDF sale como **Reporte de Red Vial Provincial Primaria**. Si son solo caminos, sale como **Reporte de Red Vial Provincial Secundaria**. Si tenés ambos, el PDF combina las 2 secciones consecutivas con salto de página, cada una con su header institucional (logo DVBA + título + fecha) y tabla homogénea de 8 columnas: *Partido · Nomencl · Tramo · Denominación · Clase (chip color) · Sentido/Transitabilidad · Km GIS · Km Oficial*.

Al pie de cada PDF: banner sello institucional *"📋 Datos oficiales de la Red Vial Provincial (Primaria + Secundaria) de Zona VI Saladillo · Fuente: Dirección de Vialidad de la Provincia de Buenos Aires"*.

### Exports

- **▶ Generar reporte** — muestra la tabla en el sidebar

- **↓ CSV** — descarga CSV con 12 columnas por tramo (Ruta, Partido, Nomenclatura, Tramo, Denominación, Clase, Sentido, Km_GIS_estimado, Km_Oficial, Mojones, Registros, Es_Resumen). En modo mixto descarga 2 archivos (rutas + caminos)

- **↓ PDF** — PDF landscape A4 institucional con logo DVBA y paleta PBA

- **↓ PDF de relevamientos con fotos** (sección aparte, uso técnico DVBA) — agrupa registros con fotos por ruta, con mapa SVG de ubicación

!!! note "📷 Screenshot:"
    panel de reportes del sidebar con chip contador, columnas, opciones del PDF y banner "Datos oficiales".
