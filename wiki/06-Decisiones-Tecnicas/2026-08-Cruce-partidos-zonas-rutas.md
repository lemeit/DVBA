# Decisión técnica: Cruce Partidos ↔ Zonas DVBA ↔ Rutas

**Fecha:** agosto 2026
**Contexto:** se necesitaba, a partir de las capas `partidos_pba.geojson` y `rutas_pba.geojson` en QGIS, generar un listado de qué rutas atraviesan cada partido, y luego agrupar ese listado por las 12 zonas viales de la DVBA.

Ver también: [[REFERENCIA_NOMENCLADOR_1989]] · [[PLAN_ESCALADO_MULTIZONA]] · [[HANDOFF_caminos_secundarios]]

---

## 1. Método elegido para el cruce espacial (partido → rutas)

Se probaron 3 opciones en QGIS:

1. **Herramienta nativa** "Join attributes by location (summary)" — usa índice espacial (R-tree), rápida.
2. **SQL vía Capa Virtual (SpatiaLite)** — cómoda de leer/mantener, pero **sin índice espacial automático**: con capas grandes puede colgar QGIS (fuerza bruta O(n×m)).
3. **PyQGIS con `QgsSpatialIndex`** — igual de rápida que la opción 1, más flexible para exportar a CSV directo.

**Resultado:** funcionó con la opción SQL (capa virtual). Query final:

```sql
SELECT
  p."PARTIDO" AS partido,
  group_concat(DISTINCT r.rtn) AS rutas
FROM partidos_pba AS p
JOIN rutas_pba AS r
  ON ST_Intersects(p.geometry, r.geometry)
GROUP BY p."PARTIDO"
ORDER BY p."PARTIDO"
```

Output: `partidos_rutas.csv` (columnas `partido`, `rutas`).

---

## 2. Cruce partido → zona DVBA

Inicialmente se intentó parsear a mano el texto de zonas (nombres de partido separados por espacios, con `*` marcando cabecera). Se abandonó ese enfoque en favor de usar `partidos_pba.json` — catálogo oficial con `numero` de partido + `zonas_dvba` (mapeo directo numero→zona), mucho más confiable.

Script final: normaliza nombres (sin tildes, sin paréntesis, `GRAL.`→`GENERAL`, etc.), matchea contra el catálogo por nombre, y usa el `numero` para resolver la zona. Ver script completo: `cruzar_partidos_zonas_rutas.py` (en `/scripts` del repo).

---

## 3. Inconsistencias encontradas en `partidos_pba.json` (v2.1)

Validación cruzada contra el documento oficial *"Códigos de Partido — Deptos de Registración y Publicidad (D.A.D.P. 194/2013)"*.

### 🔴 Error 1 — `zonas_dvba.IX` referencia un número inexistente
- La Zona IX lista el partido **N° 48**, que **no existe** en el catálogo de 135 partidos.
- El partido **N° 40 = "General La Madrid"** (nombre_corto "General Lamadrid") existe en el catálogo pero **no está en ninguna zona**.
- Confirmado por validación cruzada automática (48 sobra, 40 falta — encajan).
- **Fix:** en `zonas_dvba.IX.partidos`, reemplazar `48` por `40`.

### 🟡 Error 2 (a confirmar con ARBA) — Número de Ituzaingó
- El JSON asigna **numero: 112** a "Ituzaingó" (nota: *"Añadido en v8.60"*).
- El documento oficial dice: **112 = Islas**, **136 = Ituzaingó**.
- No rompe el cruce interno (se usa 112 consistentemente en todo el JSON), pero generará desfasaje si se cruza contra el Registro de la Propiedad / folio real oficial.
- **Fix sugerido:** cambiar Ituzaingó de 112 a 136.

### ✅ Validado sin problemas
José C. Paz (132), Malvinas Argentinas (133), Punta Indio (134), Hurlingham (135), Lezama (137), Coronel Rosales (113), General Madariaga (39), General Lamadrid (40) — todos coinciden entre el JSON y el documento oficial.

---

## 4. Pendiente

- [ ] Corregir `partidos_pba.json` (errores 1 y 2 de arriba).
- [ ] Correr `cruzar_partidos_zonas_rutas.py` con el CSV real de rutas y confirmar que no queden partidos `sin_match.csv`.
- [ ] Evaluar si conviene versionar el catálogo corregido o mantener el actual documentando las excepciones.
