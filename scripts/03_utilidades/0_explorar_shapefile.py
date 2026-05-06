# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 12:50:20 2025

@author: Of. Técnica Z6
"""

import os
import geopandas as gpd

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== EXPLORANDO SHAPEFILE ===")

# Leer shapefile
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")
gdf = gpd.read_file(archivo_shp)

print(f"📊 Total de features: {len(gdf)}")
print(f"📋 Columnas disponibles: {list(gdf.columns)}")

# Explorar columna 'rtn' (probablemente rutas)
print(f"\n🔍 VALORES ÚNICOS EN 'rtn':")
valores_rtn = gdf['rtn'].unique()
print(f"Total valores únicos: {len(valores_rtn)}")
print("Primeros 30 valores:")
for i, valor in enumerate(valores_rtn[:30]):
    print(f"  {i+1:2d}. {valor}")

# Buscar cualquier mención de 51
print(f"\n🔍 BUSCANDO '51' EN TODAS LAS COLUMNAS:")
for columna in gdf.columns:
    if gdf[columna].dtype == 'object':  # Columnas de texto
        try:
            mask = gdf[columna].astype(str).str.contains('51', na=False)
            if mask.any():
                print(f"✅ '{columna}': {mask.sum()} coincidencias")
                valores = gdf[mask][columna].unique()[:5]  # Primeros 5 valores
                for val in valores:
                    print(f"   - {val}")
        except:
            pass

# Verificar si hay valores numéricos 51
print(f"\n🔍 BUSCANDO VALOR NUMÉRICO 51:")
if 'rtn' in gdf.columns:
    mask_51 = gdf['rtn'] == 51
    print(f"Valor exacto 51 en 'rtn': {mask_51.sum()} features")
    
    # Mostrar información de esos features
    if mask_51.any():
        features_51 = gdf[mask_51]
        print(f"Información de features con rtn=51:")
        print(features_51[['rtn', 'typ', 'rst', 'municipio_']].head())