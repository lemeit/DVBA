# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 16:42:38 2025

@author: Luciano
"""

import os
import geopandas as gpd
import pandas as pd
from shapely.geometry import LineString
import numpy as np

base_path = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== GENERANDO RUTAS USANDO CSV CON LONGITUDES REALES ===")

# Cargar ambos archivos
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")
archivo_csv = os.path.join(base_path, "04_TABLAS", "SALADILLO_RED.csv")

print("📁 Cargando archivos...")
gdf = gpd.read_file(archivo_shp)
df_csv = pd.read_csv(archivo_csv)

print(f"📊 Shapefile: {len(gdf)} features")
print(f"📊 CSV: {len(df_csv)} registros")

# Filtrar solo rutas de Zona VI del CSV
rutas_csv = df_csv['RPRUTA'].unique()
print(f"🎯 Rutas en CSV: {list(rutas_csv)}")

# Crear directorio de salida
salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS", "ZONA_VI_CON_CSV")
os.makedirs(salida_dir, exist_ok=True)

resultados = []

for ruta in rutas_csv:
    if pd.isna(ruta):
        continue
        
    print(f"\n🛣️  PROCESANDO: {ruta}")
    
    # FILTRAR SEGMENTOS DE ESTA RUTA EN CSV
    segmentos_csv = df_csv[df_csv['RPRUTA'] == ruta].copy()
    print(f"   📋 Segmentos en CSV: {len(segmentos_csv)}")
    
    # CALCULAR LONGITUD REAL DESDE CSV
    longitud_real_csv = segmentos_csv['Longitud en metros'].sum()
    print(f"   📏 Longitud REAL (desde CSV): {longitud_real_csv/1000:.2f} km")
    
    # BUSCAR GEOMETRÍAS EN SHAPEFILE
    # Extraer número de ruta (ej: "RP 51" → "51")
    numero_ruta = ruta.replace('RP ', '').strip()
    
    segmentos_shp = gdf[gdf['rtn'].astype(str) == numero_ruta].copy()
    print(f"   🗺️  Segmentos en shapefile: {len(segmentos_shp)}")
    
    if len(segmentos_shp) > 0 and len(segmentos_csv) > 0:
        # CALCULAR LONGITUD DESDE SHAPEFILE (para comparar)
        segmentos_utm = segmentos_shp.to_crs('EPSG:32721')
        segmentos_utm['longitud_shp'] = segmentos_utm.length
        longitud_shp = segmentos_utm['longitud_shp'].sum()
        
        print(f"   📐 Longitud shapefile: {longitud_shp/1000:.2f} km")
        print(f"   📊 Diferencia: {abs(longitud_real_csv - longitud_shp)/1000:.2f} km")
        
        # ORDENAR SEGMENTOS (mejor visualización)
        def latitud_promedio(geometry):
            coords = list(geometry.coords)
            if coords:
                latitudes = [coord[1] for coord in coords]
                return np.mean(latitudes)
            return 0
        
        segmentos_shp['latitud_promedio'] = segmentos_shp.geometry.apply(latitud_promedio)
        segmentos_ordenados = segmentos_shp.sort_values('latitud_promedio', ascending=False)
        
        # AGREGAR INFORMACIÓN DEL CSV A LA GEOMETRÍA
        segmentos_ordenados['longitud_real_metros'] = longitud_real_csv
        segmentos_ordenados['longitud_real_km'] = longitud_real_csv / 1000
        segmentos_ordenados['segmentos_csv'] = len(segmentos_csv)
        segmentos_ordenados['clase_predominante'] = segmentos_csv['CLASE'].mode()[0] if len(segmentos_csv) > 0 else 'DESCONOCIDO'
        
        # GUARDAR CAPA
        archivo_salida = os.path.join(salida_dir, f"{ruta.replace(' ', '_')}.geojson")
        segmentos_ordenados.to_file(archivo_salida, driver='GeoJSON')
        
        # GUARDAR INFO DEL CSV COMO ARCHIVO ADICIONAL
        info_csv = {
            'Ruta': ruta,
            'Longitud_real_km': longitud_real_csv / 1000,
            'Segmentos_csv': len(segmentos_csv),
            'Clase_predominante': segmentos_csv['CLASE'].mode()[0] if len(segmentos_csv) > 0 else 'DESCONOCIDO',
            'Municipios': len(segmentos_csv['PARTIDO'].unique()) if 'PARTIDO' in segmentos_csv.columns else 'N/A'
        }
        
        resultados.append(info_csv)
        
        print(f"   💾 Guardado: {ruta.replace(' ', '_')}.geojson")
        print(f"   🏷️  Clase: {info_csv['Clase_predominante']}")
        
    else:
        print(f"   ❌ No hay datos suficientes para {ruta}")

# GENERAR REPORTE CON INFORMACIÓN REAL DEL CSV
print(f"\n📊 GENERANDO REPORTE CON DATOS REALES...")

if resultados:
    df_reporte = pd.DataFrame(resultados)
    
    # Calcular totales
    longitud_total = df_reporte['Longitud_real_km'].sum()
    segmentos_total = df_reporte['Segmentos_csv'].sum()
    
    print(f"\n🎯 REPORTE FINAL - DATOS REALES DEL CSV")
    print("=" * 70)
    print(df_reporte.to_string(index=False))
    print("=" * 70)
    print(f"📏 LONGITUD TOTAL RED: {longitud_total:.2f} km")
    print(f"📋 TOTAL SEGMENTOS: {segmentos_total}")
    
    # Guardar reporte
    archivo_reporte = os.path.join(salida_dir, "REPORTE_RUTAS_CON_DATOS_REALES.csv")
    df_reporte.to_csv(archivo_reporte, index=False, encoding='utf-8')
    print(f"💾 Reporte guardado: REPORTE_RUTAS_CON_DATOS_REALES.csv")

# CREAR ARCHIVO COMBINADO CON INFORMACIÓN COMPLETA
print(f"\n🔗 CREANDO ARCHIVO COMBINADO CSV + SHAPEFILE...")

datos_combinados = []

for ruta in rutas_csv:
    if pd.isna(ruta):
        continue
        
    segmentos_csv = df_csv[df_csv['RPRUTA'] == ruta]
    numero_ruta = ruta.replace('RP ', '').strip()
    segmentos_shp = gdf[gdf['rtn'].astype(str) == numero_ruta]
    
    if len(segmentos_csv) > 0 and len(segmentos_shp) > 0:
        # Información del CSV
        longitud_real = segmentos_csv['Longitud en metros'].sum()
        clases = segmentos_csv['CLASE'].value_counts()
        
        datos_combinados.append({
            'RUTA': ruta,
            'LONGITUD_REAL_KM': longitud_real / 1000,
            'SEGMENTOS_CSV': len(segmentos_csv),
            'SEGMENTOS_SHP': len(segmentos_shp),
            'PAVIMENTADO_KM': segmentos_csv[segmentos_csv['CLASE'] == 'PAVIMENTADO']['Longitud en metros'].sum() / 1000,
            'TIERRA_KM': segmentos_csv[segmentos_csv['CLASE'] == 'DE TIERRA']['Longitud en metros'].sum() / 1000,
            'CONSOLIDADO_KM': segmentos_csv[segmentos_csv['CLASE'] == 'CONSOLIDADO']['Longitud en metros'].sum() / 1000,
            'MUNICIPIOS': len(segmentos_csv['PARTIDO'].unique()) if 'PARTIDO' in segmentos_csv.columns else 'N/A'
        })

if datos_combinados:
    df_combinado = pd.DataFrame(datos_combinados)
    archivo_combinado = os.path.join(salida_dir, "DATOS_COMBINADOS_RUTAS.csv")
    df_combinado.to_csv(archivo_combinado, index=False, encoding='utf-8')
    print(f"💾 Datos combinados: DATOS_COMBINADOS_RUTAS.csv")

print(f"\n✅ PROCESO COMPLETADO")
print(f"📍 Carpeta: {salida_dir}")
print(f"📁 Archivos generados:")
print(f"   • [RUTA].geojson - Geometrías con datos reales")
print(f"   • REPORTE_RUTAS_CON_DATOS_REALES.csv - Estadísticas")
print(f"   • DATOS_COMBINADOS_RUTAS.csv - Información detallada")