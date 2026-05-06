"""
DVBA-Z6-DIAGNOSTICO-GEOMETRIA-RP44.py
===========================================================
SCRIPT: Diagnóstico y Corrección de Geometría RP44
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.31.6 (Generado: 2025-10-31)
CODIGO: DVBA-Z6-DIAGNOSTICO-GEOMETRIA-RP44

DESCRIPCIÓN:
    - Diagnóstico completo de geometrías
    - Corrección de sistemas de coordenadas
    - Método alternativo de cálculo de distancias

DERECHOS: Dirección de Vialidad de la Provincia de Buenos Aires
DEPARTAMENTO: Zona VI Saladillo - División Técnica
"""

import os
import pandas as pd
import geopandas as gpd
import numpy as np
from datetime import datetime
import warnings
from shapely.geometry import Point, LineString, MultiLineString
from shapely.ops import linemerge, transform
import math
warnings.filterwarnings('ignore')

def diagnosticar_geometrias(puntos_gdf, mojones_gdf, ruta_gdf):
    """
    Diagnóstico completo de las geometrías
    """
    print("🔍 DIAGNÓSTICO DE GEOMETRÍAS")
    print("=" * 50)
    
    # INFORMACIÓN DE SISTEMAS DE COORDENADAS
    print("\n📐 SISTEMAS DE COORDENADAS:")
    print(f"   Puntos: {puntos_gdf.crs}")
    print(f"   Mojones: {mojones_gdf.crs}")
    print(f"   Ruta: {ruta_gdf.crs}")
    
    # DIAGNÓSTICO DE RUTA
    print("\n🛣️  DIAGNÓSTICO DE RUTA:")
    for i, (idx, segmento) in enumerate(ruta_gdf.iterrows()):
        geom = segmento.geometry
        print(f"   Segmento {i+1}:")
        print(f"     Tipo: {geom.geom_type}")
        print(f"     Longitud: {geom.length:.2f} m")
        if hasattr(geom, 'coords'):
            print(f"     Puntos: {len(list(geom.coords))}")
            if len(list(geom.coords)) > 0:
                primer_punto = list(geom.coords)[0]
                ultimo_punto = list(geom.coords)[-1]
                print(f"     Primer punto: {primer_punto}")
                print(f"     Último punto: {ultimo_punto}")
    
    # DIAGNÓSTICO DE PUNTOS
    print("\n📍 DIAGNÓSTICO DE PUNTOS:")
    for i, (idx, punto) in enumerate(puntos_gdf.iterrows()):
        wp = punto.get('WP', f'Punto_{i+1}')
        geom = punto.geometry
        print(f"   {wp}: ({geom.x:.6f}, {geom.y:.6f})")
    
    # DIAGNÓSTICO DE MOJONES
    print("\n📏 DIAGNÓSTICO DE MOJONES:")
    for i, (idx, mojon) in enumerate(mojones_gdf.iterrows()):
        nombre = mojon.get('Name', f'Mojon_{i+1}')
        km_value = mojon.get('km_value', 'N/A')
        geom = mojon.geometry
        print(f"   {nombre} ({km_value} km): ({geom.x:.6f}, {geom.y:.6f})")
    
    # VERIFICAR SUPERPOSICIÓN ESPACIAL
    print("\n🗺️  SUPERPOSICIÓN ESPACIAL:")
    bbox_puntos = puntos_gdf.total_bounds
    bbox_mojones = mojones_gdf.total_bounds
    bbox_ruta = ruta_gdf.total_bounds
    
    print(f"   Puntos BBOX: {bbox_puntos}")
    print(f"   Mojones BBOX: {bbox_mojones}")
    print(f"   Ruta BBOX: {bbox_ruta}")

def calcular_distancias_euclidianas(puntos_gdf, mojones_gdf):
    """
    Calcula distancias euclidianas como método alternativo
    """
    print("\n📏 CÁLCULO DE DISTANCIAS EUCLIDIANAS")
    print("=" * 50)
    
    resultados = []
    
    for idx_punto, punto in puntos_gdf.iterrows():
        wp = punto.get('WP', f'Punto_{idx_punto+1}')
        prog_calc = punto.get('PROG_CALC', 0)
        geometria_punto = punto.geometry
        
        print(f"\n📍 {wp}:")
        print(f"   PROG_CALC: {prog_calc} km")
        
        # ENCONTRAR MOJÓN MÁS CERCANO (euclidiano)
        mejor_mojon = None
        mejor_distancia = float('inf')
        mejor_km_value = 0
        
        for idx_mojon, mojon in mojones_gdf.iterrows():
            distancia = geometria_punto.distance(mojon.geometry)
            km_value = mojon.get('km_value', 0)
            
            if distancia < mejor_distancia:
                mejor_distancia = distancia
                mejor_mojon = mojon
                mejor_km_value = km_value
        
        if mejor_mojon is not None:
            distancia_km = mejor_distancia / 1000.0
            
            print(f"   🔍 Mojón más cercano: {mejor_km_value} km")
            print(f"   📏 Distancia euclidiana: {distancia_km:.3f} km")
            
            # CALCULAR PROGRESIVA (simplificado)
            # Asumimos sentido ESTE-OESTE para RP44
            progresiva_corregida = mejor_km_value + distancia_km
            
            diferencia = progresiva_corregida - prog_calc
            error_pct = (abs(diferencia) / prog_calc * 100) if prog_calc > 0 else 0
            
            print(f"   📍 Progresiva estimada: {progresiva_corregida:.3f} km")
            print(f"   📐 Diferencia: {diferencia:+.3f} km")
            print(f"   📊 Error: {error_pct:.1f}%")
            
            resultados.append({
                'WP': wp,
                'prog_calc_original': prog_calc,
                'mojon_correcto': mejor_km_value,
                'distancia_euclidiana_km': distancia_km,
                'progresiva_estimada': progresiva_corregida,
                'diferencia_km': diferencia,
                'error_%': error_pct
            })
    
    return resultados

def crear_ruta_sintetica(puntos_gdf, mojones_gdf):
    """
    Crea una ruta sintética basada en puntos y mojones
    """
    print("\n🛠️  CREANDO RUTA SINTÉTICA")
    print("=" * 50)
    
    # Recolectar todos los puntos de referencia
    puntos_referencia = []
    
    # Agregar mojones
    for idx, mojon in mojones_gdf.iterrows():
        puntos_referencia.append({
            'tipo': 'mojon',
            'geom': mojon.geometry,
            'km_value': mojon.get('km_value', 0),
            'nombre': mojon.get('Name', 'Mojon')
        })
    
    # Agregar puntos de la ruta (muestras)
    for idx, punto in puntos_gdf.iterrows():
        puntos_referencia.append({
            'tipo': 'punto_ruta',
            'geom': punto.geometry,
            'km_value': punto.get('PROG_CALC', 0),
            'nombre': punto.get('WP', 'Punto')
        })
    
    # Ordenar por longitud (aproximado)
    puntos_referencia.sort(key=lambda x: x['geom'].x)  # Ordenar por coordenada X
    
    # Crear línea sintética
    if len(puntos_referencia) >= 2:
        coordenadas = [(p['geom'].x, p['geom'].y) for p in puntos_referencia]
        ruta_sintetica = LineString(coordenadas)
        
        print(f"   Ruta sintética creada con {len(coordenadas)} puntos")
        print(f"   Longitud: {ruta_sintetica.length:.2f} m")
        
        return ruta_sintetica
    else:
        print("   ❌ No hay suficientes puntos para crear ruta sintética")
        return None

def main():
    """
    Función principal de diagnóstico
    """
    print("=" * 80)
    print("DIAGNÓSTICO DE GEOMETRÍAS - RP44")
    print("DIRECCIÓN DE VIALIDAD - PROVINCIA DE BUENOS AIRES")
    print("ZONA VI SALADILLO - DIVISIÓN TÉCNICA")
    print("=" * 80)
    
    # RUTAS DE ARCHIVOS
    puntos_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP44_Completo.shp"
    mojones_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\02_BASES_VECTORES\mojones\mojones_rp44\shp\mojones_rp44.shp"
    ruta_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\RP44\RP44_INTEGRADO.shp"
    
    # VERIFICAR EXISTENCIA DE ARCHIVOS
    for path, nombre in [
        (puntos_path, "Puntos RP44"), 
        (mojones_path, "Mojones RP44"), 
        (ruta_path, "Ruta RP44 Integrado")
    ]:
        if not os.path.exists(path):
            print(f"❌ ERROR: No se encuentra {nombre}")
            print(f"   Ruta: {path}")
            return
    
    print("📁 Cargando datasets...")
    
    try:
        # CARGAR DATOS
        puntos_gdf = gpd.read_file(puntos_path)
        mojones_gdf = gpd.read_file(mojones_path)
        ruta_gdf = gpd.read_file(ruta_path)
        
        print(f"✅ Puntos cargados: {len(puntos_gdf)}")
        print(f"✅ Mojones cargados: {len(mojones_gdf)}")
        print(f"✅ Segmentos de ruta: {len(ruta_gdf)}")
        
        # EJECUTAR DIAGNÓSTICO
        diagnosticar_geometrias(puntos_gdf, mojones_gdf, ruta_gdf)
        
        # MÉTODO ALTERNATivo: DISTANCIAS EUCLIDIANAS
        resultados_euclidianos = calcular_distancias_euclidianas(puntos_gdf, mojones_gdf)
        
        # CREAR RUTA SINTÉTICA SI ES NECESARIO
        ruta_sintetica = crear_ruta_sintetica(puntos_gdf, mojones_gdf)
        
        # CREAR DATASET CON RESULTADOS EUCLIDIANOS
        if resultados_euclidianos:
            print(f"\n💾 GUARDANDO RESULTADOS EUCLIDIANOS...")
            
            # Copiar geometría y campos originales
            campos_originales = [
                'WP', 'RUTA', 'ruta_num', 'TIPO', 'ESTADO', 'PARTIDO', 
                'mpio_nom', 'mpio_cod', 'ANCHO_CALZ', 'ANCHO_CAM', 'PROG_CALC',
                'mojon_base', 'dist_mojon', 'lat_wgs84', 'lon_wgs84', 'geometry'
            ]
            
            campos_disponibles = [campo for campo in campos_originales if campo in puntos_gdf.columns]
            puntos_final = puntos_gdf[campos_disponibles].copy()
            
            # AGREGAR CAMPOS CALCULADOS
            for i, resultado in enumerate(resultados_euclidianos):
                for campo, valor in resultado.items():
                    if campo != 'WP':
                        puntos_final.loc[puntos_final.index[i], campo] = valor
            
            # METADATOS INSTITUCIONALES
            puntos_final['meta_fuent'] = 'Base Oficial Dirección de Vialidad de la Provincia de Buenos Aires'
            puntos_final['meta_inst'] = 'Dirección de Vialidad de la Provincia de Buenos Aires'
            puntos_final['meta_depio'] = 'Zona VI Saladillo - División Técnica'
            puntos_final['meta_resp'] = 'Ing. Luciano Lamaita'
            puntos_final['meta_conta'] = 'lulamaita@vialidad.gba.gov.ar'
            puntos_final['meta_prov'] = 'Reconstrucción y Filtrado de Rutas Provinciales'
            puntos_final['meta_sist'] = 'EPSG:5347 - POSGAR 2007'
            puntos_final['meta_tipo'] = 'Puntos Viales con Distancias Euclidianas - Diagnóstico'
            puntos_final['meta_fecha'] = datetime.now().strftime('%Y-%m-%d')
            puntos_final['meta_ver'] = '1.0'
            puntos_final['meta_lc'] = 'Uso Interno - DVBA'
            puntos_final['fecha_proc'] = datetime.now().strftime('%Y-%m-%d')
            
            # GUARDAR RESULTADO
            archivo_salida = puntos_path.replace('.shp', '_DIAGNOSTICO_EUCLIDIANO.shp')
            puntos_final.to_file(archivo_salida)
            
            print(f"   📂 Archivo guardado: {os.path.basename(archivo_salida)}")
            
            # GUARDAR RUTA SINTÉTICA SI SE CREÓ
            if ruta_sintetica:
                ruta_sintetica_gdf = gpd.GeoDataFrame(
                    [{'nombre': 'Ruta_Sintetica_RP44', 'geometry': ruta_sintetica}],
                    crs=puntos_gdf.crs
                )
                archivo_ruta_sintetica = puntos_path.replace('.shp', '_RUTA_SINTETICA.shp')
                ruta_sintetica_gdf.to_file(archivo_ruta_sintetica)
                print(f"   🛣️  Ruta sintética guardada: {os.path.basename(archivo_ruta_sintetica)}")
        
        # RECOMENDACIONES
        print(f"\n💡 RECOMENDACIONES:")
        print("=" * 50)
        print("1. Verificar sistemas de coordenadas de todos los datasets")
        print("2. Asegurar que la ruta tenga geometría válida y longitud real")
        print("3. Usar método euclidiano como alternativa temporal")
        print("4. Revisar la fuente original de la geometría de la ruta")
        
    except Exception as e:
        print(f"\n💥 ERROR EN DIAGNÓSTICO: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()