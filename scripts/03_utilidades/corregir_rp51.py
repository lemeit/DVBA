# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 12:56:38 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd
import pandas as pd

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== CORRIGIENDO RP 51 - ELIMINANDO TELA DE ARAÑA ===")

# Leer shapefile original
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")
gdf = gpd.read_file(archivo_shp)

# Filtrar solo RP 51
rp51_segmentos = gdf[gdf['rtn'].astype(str) == '51'].copy()
print(f"📊 Segmentos de RP 51: {len(rp51_segmentos)}")

# SOLUCIÓN 1: Mantener segmentos originales pero ordenados
print("🔄 Organizando segmentos por continuidad geográfica...")

# Agrupar segmentos por municipio y proximidad
rp51_segmentos = rp51_segmentos.sort_values('municipio_')

# Crear nueva capa con segmentos organizados
gdf_corregido = gpd.GeoDataFrame(rp51_segmentos, crs=gdf.crs)

# Agregar información de orden
gdf_corregido['orden'] = range(1, len(rp51_segmentos) + 1)
gdf_corregido['longitud_m'] = gdf_corregido.to_crs('EPSG:32721').length

# Guardar segmentos organizados
salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
os.makedirs(salida_dir, exist_ok=True)

archivo_segmentos = os.path.join(salida_dir, "RP_51_SEGMENTOS.geojson")
gdf_corregido.to_file(archivo_segmentos, driver='GeoJSON')
print(f"💾 Segmentos organizados: RP_51_SEGMENTOS.geojson")

# SOLUCIÓN 2: Crear mojones solo para segmentos principales
print("\n📍 Generando mojones para segmentos principales...")

# Calcular longitud total
longitud_total = gdf_corregido.to_crs('EPSG:32721').length.sum()
print(f"📏 Longitud total RP 51: {longitud_total/1000:.2f} km")

# Encontrar el segmento más largo (probablemente el principal)
segmento_principal = gdf_corregido.loc[gdf_corregido['longitud_m'].idxmax()]
print(f"🎯 Segmento principal: {segmento_principal['longitud_m']/1000:.2f} km")

# Generar mojones solo para el segmento principal
linea_principal = segmento_principal.geometry
gdf_principal = gpd.GeoDataFrame([segmento_principal], crs=gdf.crs)
gdf_principal_utm = gdf_principal.to_crs('EPSG:32721')
linea_principal_utm = gdf_principal_utm.geometry.iloc[0]

longitud_principal = linea_principal_utm.length
print(f"📏 Longitud segmento principal: {longitud_principal/1000:.2f} km")

# Generar mojones cada 50 km para el segmento principal
mojones = []
intervalo_km = 50
intervalo_metros = intervalo_km * 1000

for distancia_metros in range(0, int(longitud_principal), intervalo_metros):
    progresiva_km = distancia_metros / 1000
    
    punto_utm = linea_principal_utm.interpolate(distancia_metros)
    punto_wgs84 = gpd.GeoSeries([punto_utm], crs='EPSG:32721').to_crs('EPSG:4326').iloc[0]
    
    mojones.append({
        'nombre': f"RP51 KM {progresiva_km:.0f}",
        'progresiva_km': progresiva_km,
        'tipo': 'mojon_50km',
        'geometry': punto_wgs84
    })

# Guardar mojones corregidos
if mojones:
    geometrias = [m['geometry'] for m in mojones]
    datos = [{'nombre': m['nombre'], 'progresiva_km': m['progresiva_km'], 'tipo': m['tipo']} for m in mojones]
    
    gdf_mojones = gpd.GeoDataFrame(datos, geometry=geometrias, crs="EPSG:4326")
    
    archivo_mojones = os.path.join(salida_dir, "RP_51_MOJONES_CORREGIDOS.geojson")
    gdf_mojones.to_file(archivo_mojones, driver='GeoJSON')
    
    print(f"💾 Mojones corregidos: {len(mojones)} puntos")
    print(f"📍 Rango: KM {mojones[0]['progresiva_km']:.0f} a KM {mojones[-1]['progresiva_km']:.0f}")

# SOLUCIÓN 3: Crear capa solo con segmentos largos (eliminar ramales cortos)
print("\n🔍 Filtrando segmentos principales...")
segmentos_largos = gdf_corregido[gdf_corregido['longitud_m'] > 1000]  # Más de 1km
print(f"📊 Segmentos principales (>1km): {len(segmentos_largos)}")

if len(segmentos_largos) > 0:
    archivo_principales = os.path.join(salida_dir, "RP_51_PRINCIPALES.geojson")
    segmentos_largos.to_file(archivo_principales, driver='GeoJSON')
    print(f"💾 Segmentos principales: RP_51_PRINCIPALES.geojson")

print(f"\n🎯 ARCHIVOS CORREGIDOS:")
print(f"✅ RP_51_SEGMENTOS.geojson - Todos los segmentos organizados")
print(f"✅ RP_51_PRINCIPALES.geojson - Solo segmentos largos") 
print(f"✅ RP_51_MOJONES_CORREGIDOS.geojson - Mojones en segmento principal")

print(f"\n🚀 INSTRUCCIONES QGIS:")
print(f"1. Cargar 'RP_51_PRINCIPALES.geojson' para ver la ruta real")
print(f"2. Cargar 'RP_51_MOJONES_CORREGIDOS.geojson' para los mojones")
print(f"3. ¡Sin telarañas!")