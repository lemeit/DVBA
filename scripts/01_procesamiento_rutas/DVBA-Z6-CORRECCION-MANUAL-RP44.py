"""
DVBA-Z6-CORRECCION-DISTANCIAS-RP44.py
===========================================================
SCRIPT: Corrección de Distancias a Mojones - RP44
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Salvador
VERSION: 2025.10.30.13 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-CORRECCION-DISTANCIAS-RP44

DESCRIPCIÓN:
    - Corrección MANUAL de distancias a mojones mal medidas
    - Cálculo de distancias correctas basado en PROG_CALC
    - Ajuste final para obtener error mínimo

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

def corregir_distancias_rp44():
    """
    Corrige las distancias a mojones mal medidas en RP44
    """
    print("=" * 70)
    print("CORRECCIÓN DE DISTANCIAS - RP44")
    print("=" * 70)
    print("PROBLEMA: Distancias a mojones mal medidas")
    print("SOLUCIÓN: Calcular distancias correctas desde PROG_CALC")
    print("=" * 70)
    
    # Cargar datos (usar el archivo con mojones corregidos)
    puntos_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP44_Completo_MOJONES_CORREGIDOS.shp"
    
    if not os.path.exists(puntos_path):
        print(f"❌ No se encuentra archivo con mojones corregidos")
        # Intentar con el original
        puntos_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP44_Completo.shp"
    
    if not os.path.exists(puntos_path):
        print(f"❌ No se encuentra: {puntos_path}")
        return None
    
    print(f"📁 Cargando RP44...")
    puntos_gdf = gpd.read_file(puntos_path)
    
    print(f"✅ Puntos cargados: {len(puntos_gdf)}")
    
    # ANALIZAR PROBLEMA DE DISTANCIAS
    print(f"\n🔍 ANÁLISIS DE DISTANCIAS ACTUALES:")
    print("-" * 60)
    
    for idx, fila in puntos_gdf.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        mojon_base = fila.get('mojon_base_CORREGIDO', fila.get('mojon_base', 0))
        dist_actual = fila['dist_mojon']
        prog_actual = fila['PROG_CALC']
        
        # Calcular distancia CORRECTA que debería tener
        dist_correcta_metros = abs(prog_actual - mojon_base) * 1000
        
        diferencia_dist = dist_actual - dist_correcta_metros
        
        print(f"📍 {wp}:")
        print(f"   PROG_CALC: {prog_actual}km, Mojón: {mojon_base}km")
        print(f"   Dist actual: {dist_actual}m")
        print(f"   Dist correcta: {dist_correcta_metros:.0f}m")
        print(f"   Diferencia: {diferencia_dist:+.0f}m")
        
        if abs(diferencia_dist) > 1000:  # Más de 1km de diferencia
            print(f"   ⚠️  DISTANCIA INCORRECTA - Revisar medición")
    
    # CORREGIR DISTANCIAS
    print(f"\n🛠️ CORRIGIENDO DISTANCIAS...")
    print("-" * 50)
    
    # Crear copia de distancias originales
    puntos_gdf['dist_mojon_ORIGINAL'] = puntos_gdf['dist_mojon']
    
    # Calcular distancias CORRECTAS basado en PROG_CALC
    puntos_gdf['dist_mojon_CORREGIDA'] = puntos_gdf.apply(
        lambda fila: abs(fila['PROG_CALC'] - fila.get('mojon_base_CORREGIDO', fila.get('mojon_base', 0))) * 1000, 
        axis=1
    )
    
    # MOSTRAR CORRECCIÓN
    print(f"\n✅ DISTANCIAS CORREGIDAS:")
    print("-" * 50)
    for idx, fila in puntos_gdf.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        print(f"  {wp}: {fila['dist_mojon_ORIGINAL']}m → {fila['dist_mojon_CORREGIDA']:.0f}m")
    
    # RECALCULAR PROGRESIVAS CON DISTANCIAS CORRECTAS
    print(f"\n📊 RECALCULANDO PROGRESIVAS FINALES...")
    print("-" * 50)
    
    progresivas_finales = []
    
    for idx, fila in puntos_gdf.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        mojon_base = fila.get('mojon_base_CORREGIDO', fila.get('mojon_base', 0))
        dist_corregida = fila['dist_mojon_CORREGIDA']
        prog_actual = fila['PROG_CALC']
        
        dist_km = dist_corregida / 1000.0
        
        # Lógica ESTE-OESTE
        if prog_actual > mojon_base:
            prog_final = mojon_base + dist_km  # OESTE → SUMAR
        else:
            prog_final = mojon_base - dist_km  # ESTE → RESTAR
        
        diferencia = prog_final - prog_actual
        error_porc = (abs(diferencia) / prog_actual * 100) if prog_actual > 0 else 0
        
        print(f"📍 {wp}:")
        print(f"   PROG_CALC: {prog_actual}km → Final: {prog_final:.3f}km")
        print(f"   Diferencia: {diferencia:+.3f}km | Error: {error_porc:.1f}%")
        
        if error_porc < 1:
            print(f"   ✅✅ PERFECTO")
        elif error_porc < 5:
            print(f"   ✅ MUY BUENO")
        elif error_porc < 10:
            print(f"   ✅ ACEPTABLE")
        else:
            print(f"   ⚠️  REVISAR")
        
        progresivas_finales.append(prog_final)
    
    # ACTUALIZAR DATOS FINALES
    puntos_gdf['prog_final'] = progresivas_finales
    puntos_gdf['diff_final'] = puntos_gdf['prog_final'] - puntos_gdf['PROG_CALC']
    puntos_gdf['error_final'] = (abs(puntos_gdf['diff_final']) / puntos_gdf['PROG_CALC'] * 100).fillna(0)
    puntos_gdf['fecha_correccion_final'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # ESTADÍSTICAS FINALES
    errores_validos = puntos_gdf[puntos_gdf['PROG_CALC'] > 0]['error_final']
    error_promedio = errores_validos.mean() if len(errores_validos) > 0 else 0
    puntos_alto_error = len(puntos_gdf[puntos_gdf['error_final'] > 5])
    
    print(f"\n📊 RESULTADO FINAL RP44:")
    print("=" * 50)
    print(f"   - Error promedio: {error_promedio:.1f}%")
    print(f"   - Puntos con error >5%: {puntos_alto_error}")
    print(f"   - Puntos con error >10%: {len(puntos_gdf[puntos_gdf['error_final'] > 10])}")
    
    # GUARDAR CORRECCIÓN FINAL
    correccion_final_path = puntos_path.replace('.shp', '_DISTANCIAS_CORREGIDAS.shp')
    puntos_gdf.to_file(correccion_final_path)
    print(f"\n💾 Corrección final guardada: {os.path.basename(correccion_final_path)}")
    
    # PREGUNTAR SI ACTUALIZAR DEFINITIVAMENTE
    if error_promedio < 10:
        respuesta = input("\n¿Actualizar campos principales con corrección final? (s/n): ").strip().lower()
        if respuesta == 's':
            puntos_gdf['dist_mojon'] = puntos_gdf['dist_mojon_CORREGIDA']
            puntos_gdf['prog_corregida'] = puntos_gdf['prog_final']
            puntos_gdf['error_porc_calc'] = puntos_gdf['error_final']
            puntos_gdf['sentido_ruta'] = 'ESTE-OESTE'
            
            # Guardar en el archivo original
            puntos_original_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP44_Completo.shp"
            puntos_gdf.to_file(puntos_original_path)
            print("✅✅ Campos principales actualizados en archivo original")
    
    return puntos_gdf

def main():
    print("=" * 70)
    print("CORRECCIÓN DE DISTANCIAS RP44 - DVBA ZONA 6")
    print("=" * 70)
    print("PROBLEMA: Distancias a mojones mal medidas")
    print("SOLUCIÓN: Cálculo automático desde PROG_CALC")
    print("=" * 70)
    
    # Ejecutar corrección
    resultado = corregir_distancias_rp44()
    
    if resultado is not None:
        error_final = resultado[resultado['PROG_CALC'] > 0]['error_final'].mean()
        print(f"\n🎯 RESULTADO FINAL RP44:")
        print(f"   - Error final: {error_final:.1f}%")
        
        if error_final < 5:
            print("   ✅✅✅ CORRECCIÓN EXCELENTE")
        elif error_final < 10:
            print("   ✅✅ CORRECCIÓN MUY BUENA")
        elif error_final < 20:
            print("   ✅ CORRECCIÓN ACEPTABLE")
        else:
            print("   ⚠️  REVISIÓN ADICIONAL REQUERIDA")

if __name__ == "__main__":
    main()