"""
calcular_longitudes_red_vial.py
================================
Calcula longitudes geodésicas (elipsoide WGS84) para la red secundaria
de caminos provinciales DVBA.

Soporta dos modos de entrada:
  A) GeoJSON completo PBA  → filtra por zona y procesa
  B) GeoPackage de zona    → procesa directamente
     (acepta tanto el GeoPackage original del KMZ como el _final.gpkg
      generado por este mismo script — detección automática de columnas)

Uso modo A (recomendado — fuente canónica):
    python calcular_longitudes_red_vial.py
        --input Caminos_Secundarios_Provincia_de_Buenos_Aires.geojson
        --output resultados/
        --zona VI
        --ref referencias/partidos_pba.json

Uso modo B (GeoPackage por zona):
    python calcular_longitudes_red_vial.py
        --input red_secundaria_zonavia.gpkg
        --output resultados/
        --zona VI
        --ref referencias/partidos_pba.json

Salidas generadas:
    <nombre>_longitudes.csv       — detalle por segmento
    <nombre>_resumen.csv          — totales por partido
    <nombre>_final.gpkg           — GeoPackage con todos los campos nuevos
    <nombre>_final.geojson        — GeoJSON listo para mapa web

Dependencias:
    pip install geopandas fiona pyproj pandas shapely

Autor: DVBA - División Técnica Zona Departamental VI Saladillo

NOTAS SOBRE FUENTES Y ERRORES CONOCIDOS:
  - Fuente canónica: GeoJSON oficial completo PBA (MultiLineString).
  - El GeoPackage exportado del KMZ tiene errores de geometría en algunos
    segmentos (comparado con el GeoJSON oficial):
      091-07: ORIG=10.811 km vs GEO=5.662 km (-47.6%) en GeoPackage
              Corregido en GeoJSON: GEO=166.24 km para Roque Pérez total.
  - Errores de nomenclatura en datos provinciales (corregidos vía ARBA):
      Partido 041 → General Las Heras  (NO "General Paz", ese es el 043)
      Partido 075 → Navarro            (NO "Monte", ese es el 073)
      Partido 109 → Veinticinco de Mayo (NO "Tapalqué", ese es el 104)
  - La columna LONGITUD original tiene corrupción de separador de miles:
      '17.670.000.000.000.000' → el valor real es 17.670 km (primeros 2 grupos)
"""

import argparse
import json
import re
import sys
from pathlib import Path

import geopandas as gpd
import pandas as pd
from pyproj import Geod
from shapely.geometry import shape

# ─── Configuración ────────────────────────────────────────────────────────────

GEOD        = Geod(ellps='WGS84')
REF_DEFAULT = Path(__file__).parent / 'referencias' / 'partidos_pba.json'


# ─── Referencia oficial ARBA ──────────────────────────────────────────────────

def cargar_referencia(ref_path: str) -> tuple:
    with open(ref_path, encoding='utf-8') as f:
        data = json.load(f)
    # El JSON ARBA usa 'numero' como int (ej: 41) pero los GeoPackages del
    # KMZ guardan PARTIDO como string padeado a 3 dígitos (ej: '041').
    # Para que el lookup matchee desde cualquier formato, indexamos por
    # ambas variantes (int y string a 3 dígitos).
    lookup = {}
    for p in data['partidos']:
        n = p['numero']
        lookup[n]              = p['nombre']           # int → nombre
        lookup[str(n)]         = p['nombre']           # '41' → nombre
        lookup[f"{int(n):03d}"] = p['nombre']           # '041' → nombre
    zonas_dvba = data.get('zonas_dvba', {})
    return lookup, zonas_dvba


# ─── Cálculo de longitud geodésica ───────────────────────────────────────────

def decode_longitud_corrupta(val) -> float | None:
    """
    '17.670.000.000.000.000' → 17.670 km
    El valor real son los dos primeros grupos separados por punto.
    """
    if not val or pd.isna(val):
        return None
    parts = str(val).strip().split('.')
    try:
        return round(float(parts[0] + '.' + parts[1]), 3)
    except (IndexError, ValueError):
        return None


def geodesic_multilinestring(geom_coords: list) -> float:
    """Longitud geodésica WGS84 de una MultiLineString (lista de listas de [lon,lat])."""
    total_m = 0.0
    for line in geom_coords:
        for i in range(len(line) - 1):
            total_m += GEOD.inv(line[i][0], line[i][1], line[i+1][0], line[i+1][1])[2]
    return round(total_m / 1000, 4)


def geodesic_linestring(geom) -> float:
    """Longitud geodésica WGS84 desde una geometría Shapely LineString."""
    return round(abs(GEOD.geometry_length(geom)) / 1000, 4)


def longitud_desde_attr_texto(coord_str: str) -> float | None:
    """Fallback: parsea pares lon lat desde atributo de texto plano."""
    nums = re.findall(r'-?\d+\.\d+', str(coord_str))
    pts  = [(float(nums[i]), float(nums[i+1])) for i in range(0, len(nums)-1, 2)]
    if len(pts) < 2:
        return None
    return round(
        sum(GEOD.inv(pts[i][0],pts[i][1],pts[i+1][0],pts[i+1][1])[2]
            for i in range(len(pts)-1)) / 1000, 4)


def longitud_desde_wkt_multiline(wkt_str: str) -> float | None:
    """Fallback para atributos con múltiples LINESTRING en formato WKT."""
    segs    = re.findall(r'LINESTRING\s*\(([^)]+)\)', str(wkt_str))
    total_m = 0.0
    for seg in segs:
        nums = re.findall(r'-?\d+\.\d+', seg)
        pts  = [(float(nums[i]), float(nums[i+1])) for i in range(0, len(nums)-1, 2)]
        for i in range(len(pts)-1):
            total_m += GEOD.inv(pts[i][0],pts[i][1],pts[i+1][0],pts[i+1][1])[2]
    return round(total_m / 1000, 4) if total_m > 0 else None


# ─── Loaders por formato ──────────────────────────────────────────────────────

def cargar_geojson(path: str, partidos_zona: list, lookup: dict) -> pd.DataFrame:
    """Carga y filtra un GeoJSON completo PBA por los partidos de la zona."""
    with open(path, encoding='utf-8') as f:
        gj = json.load(f)

    features = [f for f in gj['features']
                if f['properties'].get('PARTIDO') in partidos_zona]
    print(f"  Features filtradas ({len(partidos_zona)} partidos): {len(features)}")

    rows = []
    for f in features:
        p      = f['properties']
        coords = f['geometry']['coordinates']
        # Campos opcionales de orden/sentido: aceptamos los nombres del GPKG
        # (temporal, long_inicial, ...) y también los renombrados del script
        # (TRAMO_NUM, LON_INI, ...).
        def _get(key1, key2):
            v = p.get(key1)
            if v is None:
                v = p.get(key2)
            return v
        rows.append({
            'NOMEMCLATURA':     p.get('NOMEMCLATURA', '') or p.get('NOMENCLATURA', ''),
            'PARTIDO':          p.get('PARTIDO'),
            'PARTIDO_NOMBRE':   lookup.get(p.get('PARTIDO'), 'Desconocido'),
            'ZONA':             p.get('ZONA'),
            'DENOMINACION':     p.get('DENOMINACION') or '',
            'CLASE':            p.get('CLASE', ''),
            'TRANSITABIlIDAD':  p.get('TRANSITABIlIDAD', ''),
            'TIPO':             p.get('TIPO', ''),
            'LONGITUD_KM_ORIG': decode_longitud_corrupta(p.get('LONGITUD')),
            'LONGITUD_KM_WGS84':geodesic_multilinestring(coords),
            'N_VERTICES':       sum(len(l) for l in coords),
            'N_LINEAS':         len(coords),
            'TRAMO_NUM':        _get('TRAMO_NUM', 'temporal'),
            'LON_INI':          _get('LON_INI', 'long_inicial'),
            'LAT_INI':          _get('LAT_INI', 'lat_inicial'),
            'LON_FIN':          _get('LON_FIN', 'long_final'),
            'LAT_FIN':          _get('LAT_FIN', 'lat_final'),
            'geometry':         shape(f['geometry']),
        })
    return pd.DataFrame(rows)


def cargar_gpkg(path: str, lookup: dict) -> pd.DataFrame:
    """
    Carga un GeoPackage de zona ya filtrado.

    Acepta dos variantes:
      - GeoPackage original del KMZ: tiene columna 'LONGITUD' (texto corrupto)
        y opcionalmente 'Coordenadas_Trayectoria'.
      - GeoPackage _final.gpkg generado por este script: ya tiene
        'LONGITUD_KM_ORIG' y 'LONGITUD_KM_WGS84' calculadas; la geometría
        corregida es la fuente de verdad para el recálculo.
    """
    gdf = gpd.read_file(path)
    cols = set(gdf.columns)

    # ── Detección de variante ─────────────────────────────────────────────────
    es_output_propio = 'LONGITUD_KM_ORIG' in cols and 'LONGITUD' not in cols
    if es_output_propio:
        print("  [INFO] GeoPackage generado por este script detectado "
              "(sin columna LONGITUD original).")
        print("         LONGITUD_KM_ORIG se conserva; LONGITUD_KM_WGS84 se recalcula "
              "desde la geometría corregida.\n")

    # ── Longitud original ─────────────────────────────────────────────────────
    if 'LONGITUD' in cols:
        # GeoPackage original del KMZ
        gdf['LONGITUD_KM_ORIG'] = gdf['LONGITUD'].apply(decode_longitud_corrupta)
    elif 'LONGITUD_KM_ORIG' in cols:
        # Ya viene calculada, la dejamos tal cual (puede ser float o None)
        gdf['LONGITUD_KM_ORIG'] = pd.to_numeric(gdf['LONGITUD_KM_ORIG'], errors='coerce')
    else:
        print("  [AVISO] No se encontró columna LONGITUD ni LONGITUD_KM_ORIG. "
              "LONGITUD_KM_ORIG quedará vacía.")
        gdf['LONGITUD_KM_ORIG'] = None

    # ── Longitud geodésica (siempre recalculada desde geometría) ──────────────
    def calc_long(row):
        geom = row['geometry']
        if geom is not None:
            try:
                return geodesic_linestring(geom)
            except Exception:
                pass
        # Fallback por atributo de texto (solo presente en GeoPackage original)
        attr = ''
        if 'Coordenadas_Trayectoria' in row.index:
            v = row['Coordenadas_Trayectoria']
            attr = str(v) if pd.notna(v) else ''
        if 'LINESTRING' in attr:
            return longitud_desde_wkt_multiline(attr)
        return longitud_desde_attr_texto(attr)

    gdf['LONGITUD_KM_WGS84'] = gdf.apply(calc_long, axis=1)

    # ── Campos auxiliares ─────────────────────────────────────────────────────
    gdf['PARTIDO_NOMBRE'] = gdf['PARTIDO'].map(lookup).fillna('Desconocido')

    gdf['N_VERTICES'] = gdf['geometry'].apply(
        lambda g: sum(len(list(part.coords)) for part in g.geoms)
                  if g is not None and g.geom_type == 'MultiLineString'
                  else (len(list(g.coords)) if g is not None else 0)
    )
    gdf['N_LINEAS'] = gdf['geometry'].apply(
        lambda g: len(list(g.geoms)) if g is not None and g.geom_type == 'MultiLineString'
                  else (1 if g is not None else 0)
    )

    # ── Campos opcionales de orden y sentido del tramo ────────────────────────
    # En el GeoPackage el usuario puede cargar (vía QGIS) los siguientes campos
    # para distinguir y ordenar tramos dentro de un mismo NOMENCLATURA y
    # documentar el sentido (cabecera → cola) de cada tramo:
    #   TRAMO_NUM  → número de orden del tramo (1, 2, 3...)
    #   LON_INI    → longitud del punto inicial
    #   LAT_INI    → latitud  del punto inicial
    #   LON_FIN    → longitud del punto final
    #   LAT_FIN    → latitud  del punto final
    # Como los GeoPackages fueron generados en distintos momentos del
    # proyecto, aceptamos varias variantes case-insensitive del nombre:
    #   - temporal / Temporal / TEMPORAL / TRAMO_NUM / tramo_num
    #   - long_inicial / lon_ini / LON_INI / longitud_inicial / Long_Inicial
    #   - (idem para las otras 3 coords)
    # Si no existen, se completan con valores neutros (TRAMO_NUM=999 → al final
    # del grupo en el sort; coordenadas en None).
    aliases = {
        'TRAMO_NUM': ['tramo_num', 'temporal'],
        'LON_INI':   ['lon_ini',   'long_inicial', 'longitud_inicial'],
        'LAT_INI':   ['lat_ini',   'lat_inicial',  'latitud_inicial'],
        'LON_FIN':   ['lon_fin',   'long_final',   'longitud_final'],
        'LAT_FIN':   ['lat_fin',   'lat_final',    'latitud_final'],
    }
    # Mapa de columnas reales del GPKG en minúsculas → nombre real
    cols_lower = {c.lower(): c for c in gdf.columns}
    rename_real = {}
    for destino, lista_alias in aliases.items():
        # Si la columna destino YA existe con el nombre canónico (en cualquier caja), respeta
        if destino.lower() in cols_lower:
            real = cols_lower[destino.lower()]
            if real != destino:
                rename_real[real] = destino
            continue
        # Si no, buscar el primer alias presente (case-insensitive)
        for a in lista_alias:
            if a.lower() in cols_lower:
                rename_real[cols_lower[a.lower()]] = destino
                break
    if rename_real:
        gdf = gdf.rename(columns=rename_real)
        print(f"  [INFO] Campos de orden/sentido detectados y renombrados: "
              f"{', '.join(f'{k} → {v}' for k, v in rename_real.items())}\n")
    faltantes = [d for d in aliases if d not in gdf.columns]
    if faltantes:
        print(f"  [AVISO] Faltan estos campos en el GPKG: {', '.join(faltantes)}\n"
              f"          Quedarán en NULL/999. Cargalos en QGIS si los necesitás "
              f"para el ordenamiento de tramos del HTML.\n")

    return pd.DataFrame(gdf)


# ─── Procesamiento principal ───────────────────────────────────────────────────

def procesar(input_path: str, output_dir: str, zona_id: str, ref_path: str) -> None:
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    nombre_base = Path(input_path).stem
    # Si el input ya es un *_final.{gpkg,geojson} (el usuario lo re-cargó después
    # de editar TRAMO_NUM en QGIS), quitamos el sufijo "_final" para no terminar
    # generando "*_final_final.gpkg".
    if nombre_base.endswith('_final'):
        nombre_base = nombre_base[:-len('_final')]
        print(f"  [INFO] Input es un '_final' — base normalizada a '{nombre_base}'")
    ext         = Path(input_path).suffix.lower()

    lookup, zonas_dvba = cargar_referencia(ref_path)

    if zona_id not in zonas_dvba:
        print(f"ERROR: zona '{zona_id}' no encontrada en {ref_path}")
        print(f"  Disponibles: {list(zonas_dvba.keys())}")
        sys.exit(1)

    zona_nombre   = zonas_dvba[zona_id]['nombre']
    partidos_zona = zonas_dvba[zona_id]['partidos']

    print(f"\n{'='*64}")
    print(f"  Red Vial DVBA — Longitudes geodésicas WGS84")
    print(f"  {zona_nombre}")
    print(f"  Fuente: {Path(input_path).name}")
    print(f"  Referencia partidos: {Path(ref_path).name} (ARBA)")
    print(f"{'='*64}\n")

    print(f"Cargando: {input_path}")
    if ext == '.geojson':
        df = cargar_geojson(input_path, partidos_zona, lookup)
        fuente = 'GeoJSON-PBA'
    else:
        df = cargar_gpkg(input_path, lookup)
        fuente = 'GeoPackage'
    print(f"  {len(df)} segmentos cargados [{fuente}]\n")

    # ── Normalizar nombre de columna nomenclatura (typo histórico del dato oficial) ──
    # El dato provincial original usa 'NOMEMCLATURA' (con M doble, typo).
    # Si el GeoPackage de entrada tiene 'NOMENCLATURA' (correcto), lo renombramos
    # internamente para que el resto del script funcione igual en todos los casos.
    if 'NOMENCLATURA' in df.columns and 'NOMEMCLATURA' not in df.columns:
        print("  [INFO] Columna 'NOMENCLATURA' renombrada a 'NOMEMCLATURA' "
              "para consistencia interna.\n")
        df = df.rename(columns={'NOMENCLATURA': 'NOMEMCLATURA'})

    if 'NOMEMCLATURA' not in df.columns:
        print("  [AVISO] No se encontró columna NOMEMCLATURA ni NOMENCLATURA. "
              "Se agrega vacía.")
        df['NOMEMCLATURA'] = ''

    df['DIFF_PCT'] = (
        (df['LONGITUD_KM_WGS84'] - df['LONGITUD_KM_ORIG']) /
        df['LONGITUD_KM_ORIG'] * 100
    ).round(1)
    df['ALERTA'] = df['DIFF_PCT'].abs().apply(lambda d: 'REVISAR' if d > 10 else '')

    # ── Orden de tramos ───────────────────────────────────────────────────────
    # Si existe TRAMO_NUM lo usamos como criterio terciario para mantener el
    # orden topológico de los tramos dentro de un mismo NOMEMCLATURA. Los
    # registros sin TRAMO_NUM van al final del grupo (sort por NaN como 999).
    if 'TRAMO_NUM' not in df.columns:
        df['TRAMO_NUM'] = None
    df['TRAMO_NUM'] = pd.to_numeric(df['TRAMO_NUM'], errors='coerce')
    df['_tramo_sort'] = df['TRAMO_NUM'].fillna(999).astype(int)
    df = (df.sort_values(['PARTIDO', 'NOMEMCLATURA', '_tramo_sort'])
            .drop(columns=['_tramo_sort'])
            .reset_index(drop=True))

    # ── Consola ───────────────────────────────────────────────────────────────
    print(f"  {'PDO':>4}  {'PARTIDO':<26} {'SEG':>4} {'KM_ORIG':>9} {'KM_WGS84':>9} {'ALERTA':>7}")
    print('  ' + '─'*64)
    for num in partidos_zona:
        s = df[df['PARTIDO']==num]
        if len(s) == 0:
            continue
        a = (s['ALERTA']=='REVISAR').sum()
        print(f"  {num:>4}  {lookup.get(num,'?'):<26} {len(s):>4} "
              f"{s['LONGITUD_KM_ORIG'].sum():>9.2f} "
              f"{s['LONGITUD_KM_WGS84'].sum():>9.2f} "
              f"{'⚠ '+str(a) if a else '':>7}")
    print('  ' + '─'*64)
    print(f"  {'TOTAL':<31} {len(df):>4} "
          f"{df['LONGITUD_KM_ORIG'].sum():>9.2f} "
          f"{df['LONGITUD_KM_WGS84'].sum():>9.2f}\n")

    alertas = df[df['ALERTA']=='REVISAR']
    if len(alertas):
        print("Segmentos REVISAR (diff >10% — verificar traza en KMZ/GeoJSON):")
        for _, r in alertas.iterrows():
            print(f"  {r['NOMEMCLATURA']:10s} {r['DENOMINACION']:<36} "
                  f"ORIG={r['LONGITUD_KM_ORIG']:6.3f} km  "
                  f"GEO={r['LONGITUD_KM_WGS84']:6.3f} km  "
                  f"diff={r['DIFF_PCT']:+.1f}%")
        print()

    # ── Exportar ──────────────────────────────────────────────────────────────
    # Asegurar presencia de columnas de orden/sentido (con None si no existen)
    for col in ('TRAMO_NUM', 'LON_INI', 'LAT_INI', 'LON_FIN', 'LAT_FIN'):
        if col not in df.columns:
            df[col] = None

    cols_csv = ['NOMEMCLATURA','PARTIDO','PARTIDO_NOMBRE','DENOMINACION',
                'CLASE','TRANSITABIlIDAD','TIPO',
                'TRAMO_NUM','LON_INI','LAT_INI','LON_FIN','LAT_FIN',
                'LONGITUD_KM_ORIG','LONGITUD_KM_WGS84','N_VERTICES','N_LINEAS',
                'DIFF_PCT','ALERTA']

    # CSV detalle
    csv_d = output_path / f"{nombre_base}_longitudes.csv"
    df[cols_csv].to_csv(csv_d, index=False, encoding='utf-8-sig')
    print(f"✓ CSV detalle:   {csv_d}")

    # CSV resumen
    rows_res = []
    for num in partidos_zona:
        s = df[df['PARTIDO']==num]
        if len(s) == 0: continue
        rows_res.append({
            'PARTIDO': num, 'PARTIDO_NOMBRE': lookup.get(num,'?'),
            'N_SEGMENTOS': len(s),
            'LONG_KM_ORIG':  round(s['LONGITUD_KM_ORIG'].sum(), 2),
            'LONG_KM_WGS84': round(s['LONGITUD_KM_WGS84'].sum(), 2),
            'SEGMENTOS_REVISAR': (s['ALERTA']=='REVISAR').sum(),
        })
    rows_res.append({
        'PARTIDO': 0, 'PARTIDO_NOMBRE': f'TOTAL {zona_nombre}',
        'N_SEGMENTOS': len(df),
        'LONG_KM_ORIG':  round(df['LONGITUD_KM_ORIG'].sum(), 2),
        'LONG_KM_WGS84': round(df['LONGITUD_KM_WGS84'].sum(), 2),
        'SEGMENTOS_REVISAR': (df['ALERTA']=='REVISAR').sum(),
    })
    csv_r = output_path / f"{nombre_base}_resumen.csv"
    pd.DataFrame(rows_res).to_csv(csv_r, index=False, encoding='utf-8-sig')
    print(f"✓ CSV resumen:   {csv_r}")

    # GeoPackage
    gdf_out = gpd.GeoDataFrame(df[cols_csv+['geometry']], geometry='geometry', crs='EPSG:4326')
    gpkg_out = output_path / f"{nombre_base}_final.gpkg"
    gdf_out.to_file(gpkg_out, driver='GPKG', layer='red_secundaria')
    print(f"✓ GeoPackage:    {gpkg_out}")

    # GeoJSON
    geojson_out = output_path / f"{nombre_base}_final.geojson"
    gdf_out.to_file(geojson_out, driver='GeoJSON')
    print(f"✓ GeoJSON:       {geojson_out}")
    print()


# ─── Entry point ─────────────────────────────────────────────────────────────

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Longitudes geodésicas WGS84 — Red Vial Secundaria DVBA')
    parser.add_argument('--input',  required=True,
                        help='.geojson (PBA completo) o .gpkg (zona, original o _final)')
    parser.add_argument('--output', default='output',
                        help='Carpeta de salida')
    parser.add_argument('--zona',   default='VI',
                        help='ID de zona en partidos_pba.json (ej: VI)')
    parser.add_argument('--ref',    default=str(REF_DEFAULT),
                        help='Ruta a partidos_pba.json (fuente ARBA)')
    args = parser.parse_args()

    procesar(
        input_path=args.input,
        output_dir=args.output,
        zona_id=args.zona,
        ref_path=args.ref,
    )
