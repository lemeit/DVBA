# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 14:58:37 2025

@author: Luciano
"""

import os
import geopandas as gpd
from shapely.geometry import Point, LineString
import pandas as pd
import numpy as np

base_path = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== MOJONES SOBRE LA RUTA REAL RP 51 ===")

# Leer segmentos de RP 51
archivo_segmentos = os.path.join(base_path, "03_CAPAS_GENERADAS", "RP_51_SEGMENTOS_FILTRADOS.geojson")
gdf_segmentos = gpd.read_file(archivo_segmentos)

print(f"📊 Segmentos RP 51: {len(gdf_segmentos)}")

# LONGITUD REAL: 735 km
LONGITUD_REAL_KM = 735
LONGITUD_REAL_METROS = LONGITUD_REAL_KM * 1000

print(f"🎯 Longitud objetivo: {LONGITUD_REAL_KM} km")

# CONVERTIR A UTM para cálculos precisos
gdf_utm = gdf_segmentos.to_crs('EPSG:32721')
gdf_utm['longitud_segmento'] = gdf_utm.length

# Calcular longitud actual en UTM
longitud_actual_utm = gdf_utm['longitud_segmento'].sum()
print(f"📏 Longitud actual en shapefile: {longitud_actual_utm/1000:.2f} km")

# Si la longitud no coincide con 735 km, necesitamos escalar
factor_escala = LONGITUD_REAL_METROS / longitud_actual_utm
print(f"📐 Factor de escala necesario: {factor_escala:.4f}")

# ESTRATEGIA: Ordenar segmentos y crear ruta continua
print("\n🔄 Ordenando segmentos para crear ruta continua...")

# Encontrar el segmento más al NORTE (Ramallo)
def latitud_promedio(geometry):
    coords = list(geometry.coords)
    if coords:
        latitudes = [coord[1] for coord in coords]
        return np.mean(latitudes)
    return 0

gdf_segmentos['latitud_promedio'] = gdf_segmentos.geometry.apply(latitud_promedio)
segmento_norte = gdf_segmentos.loc[gdf_segmentos['latitud_promedio'].idxmax()]
segmento_sur = gdf_segmentos.loc[gdf_segmentos['latitud_promedio'].idxmin()]

print(f"📍 Segmento más al norte: Lat {segmento_norte['latitud_promedio']:.4f}")
print(f"📍 Segmento más al sur: Lat {segmento_sur['latitud_promedio']:.4f}")

# Crear lista ordenada de segmentos (simplificado - en producción usaríamos algoritmo de conectividad)
segmentos_ordenados = gdf_segmentos.sort_values('latitud_promedio', ascending=False)

# Unir coordenadas en orden (esto es una aproximación - en producción conectaríamos por proximidad)
todas_coordenadas = []
for idx, segmento in segmentos_ordenados.iterrows():
    coords = list(segmento.geometry.coords)
    todas_coordenadas.extend(coords)

print(f"📍 Total de coordenadas: {len(todas_coordenadas)}")

# Crear línea continua (esto puede tener saltos, pero es mejor que línea recta)
linea_continua = LineString(todas_coordenadas)

# Convertir a UTM y escalar a longitud correcta
gdf_linea = gpd.GeoDataFrame([{'geometry': linea_continua}], crs=gdf_segmentos.crs)
gdf_linea_utm = gdf_linea.to_crs('EPSG:32721')

longitud_linea_utm = gdf_linea_utm.length.iloc[0]
print(f"📏 Longitud línea continua: {longitud_linea_utm/1000:.2f} km")

# Si la longitud no es 735 km, necesitamos interpolación más inteligente
# Por ahora, usaremos la línea continua aunque tenga saltos

# GENERAR MOJONES SOBRE LA RUTA REAL
print(f"\n📍 Generando mojones sobre la ruta real...")

mojones = []
intervalo_km = 50
intervalo_metros = intervalo_km * 1000

# Usar la línea continua (con geometría real, no recta)
linea_utm = gdf_linea_utm.geometry.iloc[0]

for distancia_metros in range(0, int(longitud_linea_utm) + intervalo_metros, intervalo_metros):
    if distancia_metros > longitud_linea_utm:
        break
        
    progresiva_km = distancia_metros / 1000
    
    # Interpolar punto SOBRE LA RUTA REAL
    punto_utm = linea_utm.interpolate(distancia_metros)
    
    # Convertir a WGS84
    punto_wgs84 = gpd.GeoSeries([punto_utm], crs='EPSG:32721').to_crs('EPSG:4326').iloc[0]
    
    mojones.append({
        'nombre': f"KM {progresiva_km:.0f}",
        'progresiva_km': progresiva_km,
        'progresiva_m': distancia_metros,
        'tipo': f'mojon_{intervalo_km}km',
        'geometry': punto_wgs84
    })

print(f"✅ Mojones generados sobre ruta real: {len(mojones)}")

# Guardar resultados
salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
os.makedirs(salida_dir, exist_ok=True)

# Guardar mojones sobre ruta real
if mojones:
    geometrias = [m['geometry'] for m in mojones]
    datos = [{
        'nombre': m['nombre'], 
        'progresiva_km': m['progresiva_km'],
        'progresiva_m': m['progresiva_m'],
        'tipo': m['tipo']
    } for m in mojones]
    
    gdf_mojones = gpd.GeoDataFrame(datos, geometry=geometrias, crs="EPSG:4326")
    
    archivo_mojones = os.path.join(salida_dir, "RP_51_MOJONES_RUTA_REAL.geojson")
    gdf_mojones.to_file(archivo_mojones, driver='GeoJSON')
    
    print(f"💾 Mojones sobre ruta real: RP_51_MOJONES_RUTA_REAL.geojson")
    print(f"📍 Rango: KM {mojones[0]['progresiva_km']:.0f} a KM {mojones[-1]['progresiva_km']:.0f}")

# Guardar la línea continua para referencia
archivo_linea = os.path.join(salida_dir, "RP_51_LINEA_CONTINUA.geojson")
gdf_linea.to_file(archivo_linea, driver='GeoJSON')
print(f"💾 Línea continua: RP_51_LINEA_CONTINUA.geojson")

print(f"\n🎯 RESULTADO:")
print(f"• Mojones generados SOBRE la geometría real de RP 51")
print(f"• No en línea recta, sino siguiendo la ruta")
print(f"• Total mojones: {len(mojones)}")
print(f"• Longitud aproximada: {longitud_linea_utm/1000:.1f} km")

print(f"\n⚠️  NOTA: Si la ruta tiene segmentos desconectados,")
print(f"   los mojones pueden saltar entre ellos")
print(f"   pero seguirán la traza real, no línea recta")

print(f"\n🚀 INSTRUCCIONES QGIS:")
print(f"1. Cargar 'RP_51_SEGMENTOS_FILTRADOS.geojson' - Segmentos originales")
print(f"2. Cargar 'RP_51_MOJONES_RUTA_REAL.geojson' - Mojones SOBRE la ruta")
print(f"3. Cargar 'RP_51_LINEA_CONTINUA.geojson' - Línea de referencia")
print(f"4. Verificar que mojones siguen la ruta real")