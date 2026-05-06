# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 12:35:51 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd
import pandas as pd

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")

print("=== ANÁLISIS DETALLADO RP 51 ===")

# Leer el shapefile
gdf = gpd.read_file(archivo_shp)

# Filtrar RP 51 - en la columna 'rtn' el valor es 51 (numérico)
rp51 = gdf[gdf['rtn'] == 51].copy()

if len(rp51) == 0:
    print("❌ No se encontró RP 51 con valor 51 en columna 'rtn'")
    # Buscar de otras formas
    rp51 = gdf[gdf['rtn'].astype(str).str.contains('51', na=False)].copy()
    print(f"Encontrados {len(rp51)} segmentos con '51'")

print(f"✅ RP 51 encontrada: {len(rp51)} segmentos")

# Verificar y reproyectar CRS
print(f"\n📐 SISTEMA DE COORDENADAS ACTUAL: {rp51.crs}")

if rp51.crs and rp51.crs.to_epsg() == 4326:  # Si está en WGS84 (grados)
    print("🔄 Convirtiendo a CRS proyectado (UTM) para cálculos correctos...")
    # Reproyectar a UTM zone 21S (para Buenos Aires)
    rp51_proyectado = rp51.to_crs('EPSG:32721')
else:
    rp51_proyectado = rp51

# Calcular longitud real
longitud_metros = rp51_proyectado.length.sum()
longitud_km = longitud_metros / 1000

print(f"📏 LONGITUD REAL RP 51: {longitud_km:.2f} km")

# Información detallada
print(f"\n📊 INFORMACIÓN DETALLADA:")
print(f"   - Segmentos: {len(rp51)}")
print(f"   - Municipios que atraviesa: {len(rp51['municipio_'].unique())}")
print(f"   - Tipo de ruta: {rp51['typ'].unique()}")
print(f"   - Categoría de ruta: {rp51['rst'].unique()}")

# Mostrar algunos municipios con sus códigos
print(f"\n🏙️  MUNICIPIOS (primeros 10):")
municipios = rp51['municipio_'].unique()[:10]
for i, mun in enumerate(municipios):
    print(f"   {i+1}. {mun}")

# Guardar RP 51 con CRS correcto
print(f"\n💾 GUARDANDO RP 51...")
salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
os.makedirs(salida_dir, exist_ok=True)

# Guardar en diferentes formatos
formatos = {
    'shp': os.path.join(salida_dir, "RP_51.shp"),
    'geojson': os.path.join(salida_dir, "RP_51.geojson"),
    'kml': os.path.join(salida_dir, "RP_51.kml")
}

for formato, ruta in formatos.items():
    try:
        rp51.to_file(ruta, driver=formato.upper())
        print(f"   ✅ {formato.upper()}: {os.path.basename(ruta)}")
    except Exception as e:
        print(f"   ❌ Error guardando {formato}: {e}")

# Crear versión con CRS proyectado para análisis
rp51_proyectado.to_file(os.path.join(salida_dir, "RP_51_UTM.shp"))

# Generar reporte
print(f"\n📈 REPORTE FINAL RP 51:")
print(f"   ✅ ENCONTRADA en shapefile existente")
print(f"   📏 Longitud: {longitud_km:.2f} km")
print(f"   🛣️  Segmentos: {len(rp51)}")
print(f"   🏙️  Municipios: {len(rp51['municipio_'].unique())}")
print(f"   💾 Guardada en: {salida_dir}")

print("\n🎯 ¡LISTO! Ya tienes la RP 51 en tu proyecto QGIS")