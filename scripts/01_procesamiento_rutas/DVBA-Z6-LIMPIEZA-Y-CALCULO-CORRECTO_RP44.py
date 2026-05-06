"""
DVBA-Z6-LIMPIEZA-EXTREMA-ESENCIAL.py
===========================================================
SCRIPT: Limpieza Extrema - Solo Campos Esenciales
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.30.16 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-LIMPIEZA-EXTREMA-ESENCIAL

DESCRIPCIÓN:
    - Limpieza EXTREMA - Solo campos absolutamente esenciales
    - Información básica del punto + progresivas
    - Nada de metadatos duplicados o campos temporales

DERECHOS: Dirección de Vialidad de la Provincia de Buenos Aires
DEPARTAMENTO: Zona VI Saladillo - División Técnica
"""

import os
import pandas as pd
import geopandas as gpd
import numpy as np
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

def limpieza_extrema_rp44():
    """
    Limpieza EXTREMA - Solo campos esenciales para trabajo
    """
    print("=" * 70)
    print("LIMPIEZA EXTREMA - SOLO CAMPOS ESENCIALES")
    print("=" * 70)
    print("OBJETIVO: Dejar solo lo necesario para identificar y ubicar puntos")
    print("=" * 70)
    
    # Cargar el archivo
    puntos_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP44_Completo.shp"
    
    if not os.path.exists(puntos_path):
        print(f"❌ No se encuentra: {puntos_path}")
        return None
    
    print(f"📁 Cargando RP44...")
    puntos_gdf = gpd.read_file(puntos_path)
    
    print(f"✅ Puntos cargados: {len(puntos_gdf)}")
    print(f"📍 Campos originales: {len(puntos_gdf.columns)}")
    
    # DEFINIR CAMPOS ABSOLUTAMENTE ESENCIALES
    campos_esenciales = [
        # Identificación básica
        'WP', 'RUTA', 'ruta_num',
        
        # Características del punto
        'TIPO', 'ESTADO', 'PARTIDO', 'mpio_nom', 'mpio_cod',
        
        # Dimensiones viales
        'ANCHO_CALZ', 'ANCHO_CAM',
        
        # Progresivas y mojones (lo más importante)
        'PROG_CALC', 'dist_mojon', 'mojon_base',
        
        # Coordenadas (ubicación)
        'lat_wgs84', 'lon_wgs84', 'lat_posgar', 'lon_posgar',
        
        # Geometría
        'geometry'
    ]
    
    # FILTRAR SOLO CAMPOS QUE EXISTAN
    campos_finales = [campo for campo in campos_esenciales if campo in puntos_gdf.columns]
    
    print(f"\n🎯 CAMPOS ESENCIALES SELECCIONADOS ({len(campos_finales)}):")
    for i, campo in enumerate(campos_finales):
        print(f"  {i+1:2d}. {campo}")
    
    # CREAR DATAFRAME EXTREMADAMENTE LIMPIO
    puntos_limpio = puntos_gdf[campos_finales].copy()
    
    # VERIFICAR Y CORREGIR MOJONES BASE
    print(f"\n🔍 VERIFICANDO MOJONES BASE...")
    mojones_corregidos = []
    
    for idx, fila in puntos_limpio.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        mojon_actual = fila['mojon_base']
        prog_calc = fila.get('PROG_CALC', 0)
        
        # CORREGIR MOJONES INCONSISTENTES
        if mojon_actual == 100 and prog_calc < 50:
            mojon_corregido = 0
            print(f"  🔄 {wp}: mojon_base {mojon_actual} → {mojon_corregido} (inconsistente)")
        else:
            mojon_corregido = mojon_actual
            print(f"  ✅ {wp}: mojon_base {mojon_actual} (correcto)")
        
        mojones_corregidos.append(mojon_corregido)
    
    # AGREGAR MOJÓN CORREGIDO
    puntos_limpio['mojon_base_C'] = mojones_corregidos
    
    # CALCULAR PROGRESIVA DEFINITIVA
    print(f"\n📊 CALCULANDO PROGRESIVA DEFINITIVA...")
    progresivas_definitivas = []
    
    for idx, fila in puntos_limpio.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        mojon_base_c = fila['mojon_base_C']
        dist_mojon = fila['dist_mojon']
        prog_calc = fila.get('PROG_CALC', 0)
        
        dist_km = dist_mojon / 1000.0
        
        # Lógica ESTE-OESTE
        if prog_calc > mojon_base_c:
            progresiva_def = mojon_base_c + dist_km  # OESTE → SUMAR
            direccion = "OESTE"
        else:
            progresiva_def = mojon_base_c - dist_km  # ESTE → RESTAR
            direccion = "ESTE"
        
        progresivas_definitivas.append(progresiva_def)
        
        print(f"  📍 {wp}: {progresiva_def:.3f}km (desde mojón {mojon_base_c}km, {direccion})")
    
    # AGREGAR PROGRESIVA DEFINITIVA
    puntos_limpio['prog_km'] = progresivas_definitivas
    
    # CALCULAR DIFERENCIA CON MEDICIÓN MANUAL (solo para referencia)
    if 'PROG_CALC' in puntos_limpio.columns:
        puntos_limpio['diff_manual'] = puntos_limpio['prog_km'] - puntos_limpio['PROG_CALC']
        puntos_limpio['error_%'] = (abs(puntos_limpio['diff_manual']) / puntos_limpio['PROG_CALC'] * 100).fillna(0)
    
    # AGREGAR FECHA DE PROCESAMIENTO
    puntos_limpio['fecha_proc'] = datetime.now().strftime('%Y-%m-%d')
    
    # ORDEN FINAL DE CAMPOS (más lógico)
    orden_campos = [
        'WP', 'RUTA', 'ruta_num',                           # Identificación
        'TIPO', 'ESTADO', 'PARTIDO', 'mpio_nom', 'mpio_cod', # Características  
        'ANCHO_CALZ', 'ANCHO_CAM',                          # Dimensiones
        'prog_km', 'PROG_CALC', 'diff_manual', 'error_%',   # Progresivas
        'mojon_base_C', 'dist_mojon',                       # Relación mojones
        'lat_wgs84', 'lon_wgs84', 'lat_posgar', 'lon_posgar', # Coordenadas
        'fecha_proc', 'geometry'                            # Metadata y geometría
    ]
    
    # Reordenar campos (solo los que existan)
    campos_ordenados = [campo for campo in orden_campos if campo in puntos_limpio.columns]
    puntos_limpio = puntos_limpio[campos_ordenados]
    
    # MOSTRAR RESUMEN FINAL
    print(f"\n📋 ESTRUCTURA FINAL - {len(puntos_limpio.columns)} CAMPOS:")
    print("=" * 50)
    for i, campo in enumerate(puntos_limpio.columns):
        print(f"  {i+1:2d}. {campo}")
    
    # ESTADÍSTICAS
    if 'error_%' in puntos_limpio.columns:
        errores_validos = puntos_limpio[puntos_limpio['PROG_CALC'] > 0]['error_%']
        error_promedio = errores_validos.mean() if len(errores_validos) > 0 else 0
        
        print(f"\n📊 ESTADÍSTICAS FINALES:")
        print(f"   - Error promedio vs manual: {error_promedio:.1f}%")
        print(f"   - Puntos con error >10%: {len(puntos_limpio[puntos_limpio['error_%'] > 10])}")
    
    # GUARDAR ARCHIVO EXTREMADAMENTE LIMPIO
    archivo_final = puntos_path.replace('.shp', '_ESENCIAL.shp')
    puntos_limpio.to_file(archivo_final)
    
    print(f"\n💾 ARCHIVO ESENCIAL GUARDADO:")
    print(f"   {os.path.basename(archivo_final)}")
    print(f"   Campos: {len(puntos_limpio.columns)} (antes: {len(puntos_gdf.columns)})")
    print(f"   Reducción: {len(puntos_gdf.columns) - len(puntos_limpio.columns)} campos eliminados")
    
    # MOSTRAR DATOS FINALES
    print(f"\n🎯 DATOS FINALES RP44:")
    print("=" * 60)
    for idx, fila in puntos_limpio.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        print(f"  {wp}: {fila['prog_km']:.2f}km | Mojón: {fila['mojon_base_C']}km | Dist: {fila['dist_mojon']}m")
    
    return puntos_limpio

def main():
    print("=" * 70)
    print("LIMPIEZA EXTREMA - SOLO ESENCIAL - DVBA ZONA 6")
    print("=" * 70)
    print("FILOSOFÍA: Menos es más - Solo lo necesario para trabajar")
    print("=" * 70)
    
    resultado = limpieza_extrema_rp44()
    
    if resultado is not None:
        print(f"\n✅✅✅ LIMPIEZA EXTREMA COMPLETADA")
        print(f"🎯 Archivo listo para uso profesional")
        print(f"📊 {len(resultado.columns)} campos esenciales vs {54} originales")

if __name__ == "__main__":
    main()