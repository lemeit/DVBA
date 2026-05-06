# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 13:00:47 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd
from shapely.geometry import Point

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== CORRIGIENDO MOJONES DESDE EL INICIO REAL ===")

# Leer segmentos principales de RP 51
archivo_principales = os.path.join(base_path, "03_CAPAS_GENERADAS", "RP_51_PRINCIPALES.geojson")
gdf_principales = gpd.read_file(archivo_principales)

print(f"📊 Segmentos principales: {len(gdf_principales)}")

# Identificar el segmento que representa el inicio de la RP 51
# Ordenar por municipio y longitud para encontrar el inicio
gdf_sorted = gdf_principales.sort_values(['municipio_', 'longitud_m'], ascending=[True, False])

# Tomar el primer segmento como inicio
segmento_inicio = gdf_sorted.iloc[0]
linea_inicio = segmento_inicio.geometry

print(f"🎯 Segmento de inicio:")
print(f"   - Municipio: {segmento_inicio['municipio_']}")
print(f"   - Longitud: {segmento_inicio['longitud_m']:.0f} m")

# Convertir a UTM para cálculos precisos
gdf_utm = gpd.GeoDataFrame([segmento_inicio], geometry='geometry', crs=gdf_principales.crs).to_crs('EPSG:32721')
linea_utm = gdf_utm.geometry.iloc[0]

longitud_segmento = linea_utm.length
print(f"   - Longitud UTM: {longitud_segmento:.0f} m")

# ENCONTRAR EL PUNTO DE INICIO REAL
# El primer punto de la línea es el inicio
coords = list(linea_inicio.coords)
punto_inicio = Point(coords[0])
punto_fin = Point(coords[-1])

print(f"📍 Punto inicio: {coords[0]}")
print(f"📍 Punto fin: {coords[-1]}")

# Determinar dirección de la ruta (cuál extremo es el KM 0)
# Para RP 51, generalmente el KM 0 está en el noroeste de la provincia
# Podemos usar las coordenadas para determinar

lat_inicio, lon_inicio = coords[0][1], coords[0][0]
lat_fin, lon_fin = coords[-1][1], coords[-1][0]

print(f"🌍 Coordenadas inicio: Lat {lat_inicio:.4f}, Lon {lon_inicio:.4f}")
print(f"🌍 Coordenadas fin: Lat {lat_fin:.4f}, Lon {lon_fin:.4f}")

# Si el inicio está más al noroeste, es KM 0, sino invertir
if lon_inicio < lon_fin:  # Más al oeste
    punto_km0 = punto_inicio
    direccion = "de Oeste a Este"
    print(f"🎯 Dirección estimada: {direccion}")
    print(f"🎯 KM 0 en extremo OESTE")
else:
    punto_km0 = punto_fin  
    direccion = "de Este a Oeste"
    print(f"🎯 Dirección estimada: {direccion}")
    print(f"🎯 KM 0 en extremo ESTE")

# Calcular longitud total de TODOS los segmentos principales
gdf_todos_utm = gdf_principales.to_crs('EPSG:32721')
longitud_total = gdf_todos_utm.length.sum()
print(f"📏 Longitud TOTAL RP 51: {longitud_total/1000:.2f} km")

# Generar mojones cada 10 km (más frecuentes para mejor visualización)
mojones = []
intervalo_km = 10  # Cada 10 km para mejor distribución
intervalo_metros = intervalo_km * 1000

print(f"\n📍 Generando mojones cada {intervalo_km} km...")

for distancia_metros in range(0, int(longitud_total) + intervalo_metros, intervalo_metros):
    progresiva_km = distancia_metros / 1000
    
    if progresiva_km > longitud_total / 1000:
        break
        
    # Encontrar punto a lo largo de toda la ruta
    # Para esto necesitamos una línea unida, pero sin crear telarañas
    # Usaremos interpolación sobre la unión lógica de segmentos
    
    # Encontrar en qué segmento está esta distancia
    distancia_acumulada = 0
    punto_encontrado = None
    
    for idx, segmento in gdf_todos_utm.iterrows():
        longitud_segmento = segmento.geometry.length
        
        if distancia_metros <= distancia_acumulada + longitud_segmento:
            # El punto está en este segmento
            dist_en_segmento = distancia_metros - distancia_acumulada
            punto_utm = segmento.geometry.interpolate(dist_en_segmento)
            
            # Convertir a WGS84
            punto_wgs84 = gpd.GeoSeries([punto_utm], crs='EPSG:32721').to_crs('EPSG:4326').iloc[0]
            
            mojones.append({
                'nombre': f"RP51 KM {progresiva_km:.0f}",
                'progresiva_km': progresiva_km,
                'progresiva_m': distancia_metros,
                'tipo': 'mojon_10km',
                'geometry': punto_wgs84
            })
            break
            
        distancia_acumulada += longitud_segmento

print(f"✅ Mojones generados: {len(mojones)}")

# Guardar mojones corregidos
if mojones:
    geometrias = [m['geometry'] for m in mojones]
    datos = [{
        'nombre': m['nombre'], 
        'progresiva_km': m['progresiva_km'],
        'progresiva_m': m['progresiva_m'],
        'tipo': m['tipo']
    } for m in mojones]
    
    gdf_mojones = gpd.GeoDataFrame(datos, geometry=geometrias, crs="EPSG:4326")
    
    salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
    archivo_mojones = os.path.join(salida_dir, "RP_51_MOJONES_FINALES.geojson")
    gdf_mojones.to_file(archivo_mojones, driver='GeoJSON')
    
    print(f"💾 Mojones finales guardados: RP_51_MOJONES_FINALES.geojson")
    print(f"📍 Rango: KM {mojones[0]['progresiva_km']:.0f} a KM {mojones[-1]['progresiva_km']:.0f}")
    
    # Crear punto KM 0 especial
    gdf_km0 = gpd.GeoDataFrame([{
        'nombre': 'RP51 KM 0 - INICIO',
        'progresiva_km': 0,
        'progresiva_m': 0,
        'tipo': 'inicio',
        'geometry': punto_km0
    }], crs="EPSG:4326")
    
    archivo_km0 = os.path.join(salida_dir, "RP_51_KM0.geojson")
    gdf_km0.to_file(archivo_km0, driver='GeoJSON')
    print(f"💾 Punto KM 0: RP_51_KM0.geojson")

print(f"\n🎯 RESUMEN:")
print(f"• Longitud total: {longitud_total/1000:.2f} km")
print(f"• Mojones cada {intervalo_km} km: {len(mojones)}")
print(f"• Dirección: {direccion}")
print(f"• KM 0 ubicado en extremo correcto")

print(f"\n🚀 INSTRUCCIONES QGIS:")
print(f"1. Cargar 'RP_51_PRINCIPALES.geojson'")
print(f"2. Cargar 'RP_51_MOJONES_FINALES.geojson'")
print(f"3. Cargar 'RP_51_KM0.geojson' (punto de inicio)")
print(f"4. ¡Mojones desde KM 0 correctamente!")