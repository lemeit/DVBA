# scripts/ — Scripts Python del proyecto DVBA Zona VI

Código Python que apoya la generación de datos para las apps web. Estos scripts NO se ejecutan en GitHub Pages; viven en el repo solo para versionar el código y poder regenerarlo.

## Setup

```bash
cd C:\GitHub\DVBA
python -m venv venv
venv\Scripts\activate
pip install -r scripts/requirements.txt
```

## Scripts principales

| Archivo | Propósito |
|---|---|
| `gen_ruta_bundle.py` | Genera `datos/rutas_rpXX.js` desde GeoJSON unificado + mojones ajustados |
| `build_campo.py` | Build pipeline de la app de campo |
| `Armonizar_mojones.py` | Limpieza y unificación de capas de mojones por ruta |

## Subcarpetas

- **`01_procesamiento_rutas/`** — Cálculo de progresivas, validación, corrección de coordenadas, scripts de progresivas calculadores.
- **`02_analisis_topologia/`** — Análisis topológico de la red vial.
- **`03_utilidades/`** — Exploración de SHP, generación de mojones, scripts auxiliares.
- **`04_reportes/`** — Generación de reportes desde capas procesadas.

## Convenciones de paths

Los scripts asumen que las **fuentes pesadas** (proyecto QGIS, SHP, etc.) viven en `C:\DVBA_fuentes\qgis\…` (fuera del repo). Si tu instalación las tiene en otra ruta, ajustá `DVBA_config_paths.py` en `03_utilidades/`.
