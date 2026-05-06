# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 12:47:12 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd
from shapely.geometry import Point

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== PASO 2: GENERANDO MOJONES CADA 50 KM ===")

# Leer RP 51 unida
archivo_rp51 = os.path.join(base_path, "03_CAPAS_GENERADAS", "RP_51_UNIDA.geojson")

if not os.path.exists(archivo_rp51):
    print("❌ Primero ejecuta el Paso 1 para crear RP_51_UNIDA.geojson")
    exit()

gdf_rp51 = gpd.read_file(archivo_rp51)
linea = gdf_rp51.geometry[0]

print(f"📍 Puntos en la línea: {len(linea.coords)}")

# Convertir a UTM para cálculos precisos
print("🔄 Convirtiendo a UTM para cálculos...")
gdf_utm = gdf_rp51.to_crs('EPSG:32721')  # UTM 21S para Buenos Aires
linea_utm = gdf_utm.geometry[0]

# Calcular longitud total
longitud_total_metros = linea_utm.length
longitud_total_km = longitud_total_metros / 1000

print(f"📏 Longitud total RP 51: {longitud_total_km:.2f} km")

# Generar mojones cada 50 km
mojones = []
intervalo_km = 50
intervalo_metros = intervalo_km * 1000

print(f"📍 Generando mojones cada {intervalo_km} km...")

for distancia_metros in range(0, int(longitud_total_metros), intervalo_metros):
    progresiva_km = distancia_metros / 1000
    
    # Encontrar punto a lo largo de la línea
    punto_utm = linea_utm.interpolate(distancia_metros)
    
    # Convertir de vuelta a WGS84
    punto_wgs84 = gpd.GeoSeries([punto_utm], crs='EPSG:32721').to_crs('EPSG:4326').iloc[0]
    
    mojones.append({
        'nombre': f"RP51 KM {progresiva_km:.0f}",
        'progresiva_km': progresiva_km,
        'tipo': 'mojon_50km',
        'geometry': punto_wgs84
    })

print(f"✅ Mojones generados: {len(mojones)}")

# Guardar mojones
if mojones:
    geometrias = [m['geometry'] for m in mojones]
    datos = [{'nombre': m['nombre'], 'progresiva_km': m['progresiva_km'], 'tipo': m['tipo']} for m in mojones]
    
    gdf_mojones = gpd.GeoDataFrame(datos, geometry=geometrias, crs="EPSG:4326")
    
    salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
    archivo_mojones = os.path.join(salida_dir, "RP_51_MOJONES.geojson")
    gdf_mojones.to_file(archivo_mojones, driver='GeoJSON')
    
    print(f"💾 Guardado: RP_51_MOJONES.geojson")
    print(f"📍 Rango: KM {mojones[0]['progresiva_km']:.0f} a KM {mojones[-1]['progresiva_km']:.0f}")
else:
    print("❌ No se generaron mojones")

print("🎯 Mojones listos para QGIS")