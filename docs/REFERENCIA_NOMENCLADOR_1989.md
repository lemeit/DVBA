# Nomenclador de Rutas · Zona VI (1989)

> **Cuadernillo original DVBA · Zona VI Saladillo**
> Referencia: *NOMENCLADOR DE RUTAS — Red Vial Total de la Provincia de Buenos Aires (Provincial: Primaria y Secundaria) (Nacional: Primaria) — ZONA VI*
> Emisor: Ministerio de Obras y Servicios Públicos · Dirección de Vialidad · Dirección Coordinación Técnica · Departamento Planificación Vial
> Fecha del listado: **18 de septiembre de 1989**
> Copia física en poder de: División Técnica DVBA Zona VI.

## Qué es

Cuadernillo institucional oficial de la DVBA con el detalle completo de **todas las Rutas Provinciales y Caminos Secundarios de la Zona VI Saladillo**, con:

- **Trazado**: origen y destino de cada tramo (dónde empieza y dónde termina).
- **Denominación oficial** de cada camino.
- **Longitud** en km por tramo.
- **Tipo de superficie** (pavimentado / consolidado / tierra).
- **Ancho de calzada** y calzada/banquinas.
- **Ubicación jurisdiccional** por partido.

## Por qué es importante

- Es la **fuente autoritativa histórica** de la traza y denominación de las rutas y caminos de la zona.
- Aunque los datos de **estado** (pavimento, transitabilidad, tráfico) están desactualizados (1989), la **ubicación, sentido de progresiva, denominación oficial y jurisdicción no cambiaron**.
- Sirve como cross-check contra:
  - Datos IGN (capas oficiales del Instituto Geográfico Nacional).
  - Datos ARBA (parcelas y límites de partido).
  - GeoJSONs actuales del proyecto (`red_secundaria_zonaVI_final.geojson`, `caminos_secundarios_PBA.geojson`).
  - Bundles procesados (`datos/rutas_rpXX.js`).
- Es una **reliquia institucional** — versión papel única, firmada por el jefe técnico de la zona en 1989. Vale digitalizarla progresivamente en la medida en que sirva para completar datos faltantes del sistema.

## Cómo se usa en el proyecto

- **Al verificar denominaciones**: si un camino secundario aparece con nombre distinto en el geojson vs el nomenclador, prevalece el nomenclador (salvo que el geojson tenga fecha más reciente confirmada).
- **Al verificar sentido de progresiva**: si una RP tiene progresiva con sentido dudoso, el nomenclador de 1989 confirma el origen histórico (mojón 0).
- **Al analizar tramos legacy**: los tramos que el nomenclador lista pero el geojson no tiene indican caminos que perdieron jurisdicción provincial (pasaron a rural o desaparecieron).
- **Para completar datos faltantes del SIG Vial** (`datos/caracteristicas_viales.js`): ancho de calzada, banquinas, etc. — los placeholders `null` pueden llenarse cross-checkeando con el nomenclador cuando corresponda (dejando marcado como "dato histórico 1989" para revisión de campo).

## Estado de digitalización

- **Pendiente**: escanear las páginas relevantes (Zona VI, RPs 6-91 + caminos 034/041/058/062/075/091/093/109) y guardarlas en `docs/nomenclador_1989/` como PNG/PDF.
- **Pendiente**: transcribir tabla de datos a CSV (`docs/nomenclador_1989.csv`) con columnas: `RP|Camino, Tramo, Origen, Destino, LongitudKm, Superficie, Ancho, Partido, Notas1989`.
- **Bloqueado hasta**: prioridad más baja que Reportes/Roles. Se puede hacer en paralelo por otro colaborador o cuando haya tiempo.

## Portada (para referencia visual)

La portada del cuadernillo muestra:
- Escudo "Dirección de Vialidad" (DVBA logo institucional)
- Título "NOMENCLADOR DE RUTAS"
- "RED VIAL TOTAL DE LA PROVINCIA DE BUENOS AIRES"
- "(Provincial: Primaria y Secundaria) (Nacional: Primaria)"
- "ZONA VI"
- Anotación manuscrita: "Saladillo"
- Sellos institucionales de la Jefatura de División Técnica · Zona VI · Dirección de Vialidad Bs. As. (dos veces, uno rotado)
- Marca de impresión con fecha 18 de septiembre de 1989

_Para agregar la foto de portada al repo:_
1. Guardar la imagen en `docs/nomenclador_1989/portada.jpg` (o `.png`).
2. Referenciarla acá con: `![Portada Nomenclador 1989](nomenclador_1989/portada.jpg)`.

---

_Doc creado: 2026-07-16 · v7.81_
