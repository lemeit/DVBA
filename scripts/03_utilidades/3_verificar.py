# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 12:53:01 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== VERIFICANDO RESULTADOS ===")

archivos = [
    ("RP_51_UNIDA.geojson", "Ruta RP 51 unida"),
    ("RP_51_MOJONES.geojson", "Mojones cada 50 km")
]

for archivo, descripcion in archivos:
    ruta = os.path.join(base_path, "03_CAPAS_GENERADAS", archivo)
    if os.path.exists(ruta):
        gdf = gpd.read_file(ruta)
        print(f"✅ {descripcion}:")
        print(f"   - Archivo: {archivo}")
        print(f"   - Features: {len(gdf)}")
        if descripcion == "Mojones cada 50 km" and len(gdf) > 0:
            print(f"   - Progresiva min: {gdf['progresiva_km'].min():.0f} km")
            print(f"   - Progresiva max: {gdf['progresiva_km'].max():.0f} km")
            print(f"   - Total mojones: {len(gdf)}")
    else:
        print(f"❌ {descripcion}: No encontrado")

print("\n🎯 INSTRUCCIONES PARA QGIS:")
print("1. Cargar '03_CAPAS_GENERADAS/RP_51_UNIDA.geojson'")
print("2. Cargar '03_CAPAS_GENERADAS/RP_51_MOJONES.geojson'")
print("3. En mojones: Activar etiquetas → Campo 'nombre'")
print("4. ¡Tendrás RP 51 con mojones cada 50 km!")