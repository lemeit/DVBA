# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 12:33:50 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd
import pandas as pd

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")

print("=== EXPLORANDO RP 51 EN SHAPEFILE ===")
print(f"Archivo: {os.path.basename(archivo_shp)}")
print(f"Total de features: 2449\n")

# Leer el shapefile
gdf = gpd.read_file(archivo_shp)

# Explorar la columna 'municipio_'
print("🔍 EXPLORANDO COLUMNA 'municipio_':")
municipios_con_51 = gdf[gdf['municipio_'].astype(str).str.contains('51', na=False)]
print(f"Registros que contienen '51': {len(municipios_con_51)}")
print("Valores únicos encontrados:")
print(municipios_con_51['municipio_'].unique())
print()

# Explorar la columna 'rtn' (probablemente sea "ruta")
print("🔍 EXPLORANDO COLUMNA 'rtn':")
rtn_con_51 = gdf[gdf['rtn'].astype(str).str.contains('51', na=False)]
print(f"Registros que contienen '51': {len(rtn_con_51)}")
print("Valores únicos encontrados:")
print(rtn_con_51['rtn'].unique())
print()

# Mostrar información de las rutas que contienen 51
if len(rtn_con_51) > 0:
    print("📊 INFORMACIÓN DETALLADA DE RUTAS CON '51':")
    print(rtn_con_51[['rtn', 'typ', 'rst', 'municipio_']].value_counts().head(10))
    print()
    
    # Mostrar geometrías de las rutas con 51
    print("📍 GUARDANDO GEOMETRÍAS DE RP 51...")
    
    # Filtrar solo las que claramente son RP 51
    # Patrones comunes para RP 51
    patrones_rp51 = ['RP 51', 'RP51', '51', 'Ruta Provincial 51']
    
    rp51_filtrada = gdf[gdf['rtn'].astype(str).str.contains('|'.join(patrones_rp51), case=False, na=False)]
    
    if len(rp51_filtrada) > 0:
        print(f"✅ Se encontraron {len(rp51_filtrada)} segmentos de RP 51")
        
        # Crear carpeta de salida si no existe
        salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS")
        os.makedirs(salida_dir, exist_ok=True)
        
        # Guardar como shapefile
        ruta_salida = os.path.join(salida_dir, "RP_51.shp")
        rp51_filtrada.to_file(ruta_salida)
        print(f"💾 RP 51 guardada en: {ruta_salida}")
        
        # Mostrar resumen
        print("\n📈 RESUMEN RP 51:")
        print(f"   - Segmentos: {len(rp51_filtrada)}")
        print(f"   - Longitud total: {rp51_filtrada.length.sum():.2f} metros")
        print(f"   - Municipios: {rp51_filtrada['municipio_'].unique()}")
        print(f"   - Tipo de ruta: {rp51_filtrada['typ'].unique()}")
        
    else:
        print("⚠️  No se encontraron segmentos claros de RP 51")

# Mostrar todos los valores únicos en la columna 'rtn' para referencia
print("\n🔍 TODOS LOS VALORES ÚNICOS EN 'rtn':")
valores_rtn = gdf['rtn'].unique()
print(f"Total de valores únicos en 'rtn': {len(valores_rtn)}")
print("Algunos ejemplos:")
for i, valor in enumerate(valores_rtn[:20]):  # Mostrar primeros 20
    print(f"  {i+1}. {valor}")

print("\n✅ EXPLORACIÓN COMPLETADA")