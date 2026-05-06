# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 12:51:47 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd
from shapely.geometry import LineString

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== PASO 1: UNIENDO RP 51 (CORREGIDO) ===")

# Leer shapefile
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")
gdf = gpd.read_file(archivo_shp)

# Buscar RP 51 como STRING (no numérico)
rp51_segmentos = gdf[gdf['rtn'].astype(str) == '51'].copy()
print(f"📊 Segmentos de RP 51 encontrados: {len(rp51_segmentos)}")

if len(rp51_segmentos) == 0:
    print("❌ No se encontró RP 51")
    exit()

# Unir todos los segmentos
todas_coordenadas = []
for geometria in rp51_segmentos.geometry:
    if geometria.geom_type == 'LineString':
        todas_coordenadas.extend(list(geometria.coords))
    elif geometria.geom_type == 'MultiLineString':
        for linea in geometria.geoms:
            todas_coordenadas.extend(list(linea.coords))

print(f"📍 Coordenadas recolectadas: {len(todas_coordenadas)}")

# Crear línea única
linea_unica = LineString(todas_coordenadas)

# Crear GeoDataFrame unido
gdf_unido = gpd.GeoDataFrame([{
    'RPRUTA': 'RP 51',
    'rtn': '51',
    'segmentos_originales': len(rp51_segmentos),
    'municipios': ', '.join(rp51_segmentos['municipio_'].astype(str).unique()),
    'geometry': linea_unica
}], crs=gdf.crs)

# Guardar
salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
os.makedirs(salida_dir, exist_ok=True)

archivo_salida = os.path.join(salida_dir, "RP_51_UNIDA.geojson")
gdf_unido.to_file(archivo_salida, driver='GeoJSON')

print(f"✅ RP 51 unida correctamente")
print(f"📍 Puntos en la línea: {len(linea_unica.coords)}")
print(f"💾 Guardado: RP_51_UNIDA.geojson")