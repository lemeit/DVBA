# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 13:04:22 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd
from shapely.geometry import Point
import pandas as pd

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== RP 51 COMPLETA: RAMALLO A BAHÍA BLANCA ===")

# Leer TODOS los segmentos de RP 51 del shapefile original
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")
gdf = gpd.read_file(archivo_shp)

# Filtrar RP 51
rp51_todos = gdf[gdf['rtn'].astype(str) == '51'].copy()
print(f"📊 Segmentos totales RP 51: {len(rp51_todos)}")

# Convertir a UTM para cálculos
rp51_utm = rp51_todos.to_crs('EPSG:32721')
rp51_utm['longitud_segmento'] = rp51_utm.length

# Calcular longitud total
longitud_total = rp51_utm['longitud_segmento'].sum()
print(f"📏 Longitud TOTAL RP 51: {longitud_total/1000:.2f} km")

# IDENTIFICAR EXTREMOS: Ramallo (Norte) vs Bahía Blanca (Sur)
print("\n🔍 Identificando extremos de la ruta...")

# Agrupar por municipio y encontrar coordenadas extremas
municipios_coords = []

for idx, segmento in rp51_todos.iterrows():
    municipio = segmento['municipio_']
    coords = list(segmento.geometry.coords)
    
    # Tomar primer y último punto del segmento
    if coords:
        municipios_coords.append({
            'municipio': municipio,
            'punto_inicio': Point(coords[0]),
            'punto_fin': Point(coords[-1]),
            'lat_inicio': coords[0][1],
            'lon_inicio': coords[0][0],
            'lat_fin': coords[-1][1], 
            'lon_fin': coords[-1][0]
        })

# Crear DataFrame de puntos
df_puntos = pd.DataFrame(municipios_coords)

# Encontrar punto más al NORTE (Ramallo) - mayor latitud
punto_norte = df_puntos.loc[df_puntos['lat_inicio'].idxmax()]
print(f"📍 Extremo NORTE (Ramallo):")
print(f"   - Municipio: {punto_norte['municipio']}")
print(f"   - Coordenadas: {punto_norte['punto_inicio'].x:.4f}, {punto_norte['punto_inicio'].y:.4f}")

# Encontrar punto más al SUR (Bahía Blanca) - menor latitud  
punto_sur = df_puntos.loc[df_puntos['lat_inicio'].idxmin()]
print(f"📍 Extremo SUR (Bahía Blanca):")
print(f"   - Municipio: {punto_sur['municipio']}")
print(f"   - Coordenadas: {punto_sur['punto_inicio'].x:.4f}, {punto_sur['punto_inicio'].y:.4f}")

# DEFINIR: KM 0 en Ramallo (Norte), KM final en Bahía Blanca (Sur)
print(f"\n🎯 Dirección: RAMALLO (KM 0) → BAHÍA BLANCA (KM {longitud_total/1000:.0f})")

# ORDENAR segmentos de Norte a Sur
print("\n🔄 Ordenando segmentos de Norte a Sur...")

# Calcular distancia de cada segmento al punto norte (para ordenar)
def distancia_al_norte(geometry):
    coords = list(geometry.coords)
    if coords:
        punto_medio = Point(coords[len(coords)//2])  # Punto medio del segmento
        # Calcular distancia vertical (diferencia de latitud)
        return abs(punto_medio.y - punto_norte['punto_inicio'].y)
    return 0

rp51_todos['distancia_al_norte'] = rp51_todos.geometry.apply(distancia_al_norte)
rp51_ordenada = rp51_todos.sort_values('distancia_al_norte')

# Guardar RP 51 ordenada
salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
os.makedirs(salida_dir, exist_ok=True)

archivo_ordenado = os.path.join(salida_dir, "RP_51_ORDENADA.geojson")
rp51_ordenada.to_file(archivo_ordenado, driver='GeoJSON')
print(f"💾 RP 51 ordenada: RP_51_ORDENADA.geojson")

# GENERAR MOJONES CADA 20 KM (más frecuentes para ruta larga)
print(f"\n📍 Generando mojones cada 20 km...")

mojones = []
intervalo_km = 20
intervalo_metros = intervalo_km * 1000

# Calcular progresivas acumuladas por segmento (ordenados de Norte a Sur)
distancias_acumuladas = [0]
segmentos_ordenados_utm = rp51_ordenada.to_crs('EPSG:32721')

for i, segmento in segmentos_ordenados_utm.iterrows():
    longitud_seg = segmento.geometry.length
    distancias_acumuladas.append(distancias_acumuladas[-1] + longitud_seg)

print(f"📏 Progresiva total: {distancias_acumuladas[-1]/1000:.1f} km")

# Generar mojones
for distancia_metros in range(0, int(distancias_acumuladas[-1]), intervalo_metros):
    progresiva_km = distancia_metros / 1000
    
    # Encontrar en qué segmento está esta distancia
    for i in range(len(distancias_acumuladas) - 1):
        if distancias_acumuladas[i] <= distancia_metros < distancias_acumuladas[i + 1]:
            # El punto está en este segmento
            segmento = segmentos_ordenados_utm.iloc[i]
            dist_en_segmento = distancia_metros - distancias_acumuladas[i]
            
            punto_utm = segmento.geometry.interpolate(dist_en_segmento)
            punto_wgs84 = gpd.GeoSeries([punto_utm], crs='EPSG:32721').to_crs('EPSG:4326').iloc[0]
            
            mojones.append({
                'nombre': f"KM {progresiva_km:.0f}",
                'progresiva_km': progresiva_km,
                'progresiva_m': distancia_metros,
                'tipo': f'mojon_{intervalo_km}km',
                'geometry': punto_wgs84
            })
            break

print(f"✅ Mojones generados: {len(mojones)}")

# Guardar mojones
if mojones:
    geometrias = [m['geometry'] for m in mojones]
    datos = [{
        'nombre': m['nombre'], 
        'progresiva_km': m['progresiva_km'],
        'progresiva_m': m['progresiva_m'],
        'tipo': m['tipo']
    } for m in mojones]
    
    gdf_mojones = gpd.GeoDataFrame(datos, geometry=geometrias, crs="EPSG:4326")
    
    archivo_mojones = os.path.join(salida_dir, "RP_51_MOJONES_COMPLETOS.geojson")
    gdf_mojones.to_file(archivo_mojones, driver='GeoJSON')
    
    print(f"💾 Mojones completos: RP_51_MOJONES_COMPLETOS.geojson")
    print(f"📍 Rango: KM {mojones[0]['progresiva_km']:.0f} a KM {mojones[-1]['progresiva_km']:.0f}")

# Crear puntos de inicio y fin especiales
puntos_especiales = [
    {
        'nombre': 'RP51 KM 0 - RAMALLO (INICIO)',
        'progresiva_km': 0,
        'tipo': 'inicio',
        'geometry': punto_norte['punto_inicio']
    },
    {
        'nombre': f'RP51 KM {longitud_total/1000:.0f} - BAHÍA BLANCA (FIN)',
        'progresiva_km': longitud_total / 1000,
        'tipo': 'fin',
        'geometry': punto_sur['punto_inicio']
    }
]

gdf_especiales = gpd.GeoDataFrame(puntos_especiales, crs="EPSG:4326")
archivo_especiales = os.path.join(salida_dir, "RP_51_EXTREMOS.geojson")
gdf_especiales.to_file(archivo_especiales, driver='GeoJSON')

print(f"💾 Puntos extremos: RP_51_EXTREMOS.geojson")

print(f"\n🎯 RESUMEN RP 51 COMPLETA:")
print(f"• Longitud: {longitud_total/1000:.2f} km")
print(f"• Segmentos: {len(rp51_todos)}")
print(f"• Mojones cada {intervalo_km} km: {len(mojones)}")
print(f"• Dirección: RAMALLO → BAHÍA BLANCA")
print(f"• KM 0 en Ramallo, KM {longitud_total/1000:.0f} en Bahía Blanca")

print(f"\n🚀 INSTRUCCIONES QGIS:")
print(f"1. Cargar 'RP_51_ORDENADA.geojson' - Toda la RP 51 ordenada")
print(f"2. Cargar 'RP_51_MOJONES_COMPLETOS.geojson' - Mojones cada 20 km")
print(f"3. Cargar 'RP_51_EXTREMOS.geojson' - Inicio y fin")
print(f"4. ¡RP 51 completa con mojones correctos!")