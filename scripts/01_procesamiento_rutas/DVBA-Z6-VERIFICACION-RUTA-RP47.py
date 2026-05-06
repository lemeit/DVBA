"""
DVBA-Z6-VERIFICACION-RUTA-RP47.py
===========================================================
SCRIPT: Verificación Específica RP47 - Mojones Corregidos
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.30.9 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-VERIFICACION-RUTA-RP47

DESCRIPCIÓN:
    - Verificación específica para RP47 con mojones corregidos
    - Validación de progresivas y sentidos
    - Cálculo preciso con datos actualizados

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

def verificar_rp47_corregida():
    """
    Verifica RP47 con mojones corregidos (0 km y 50 km)
    """
    print("=" * 70)
    print("VERIFICACIÓN RP47 - MOJONES CORREGIDOS")
    print("=" * 70)
    print("Mojones correctos: 0 km (inicio) y 50 km")
    print("Sentido: SUR-NORTE (aumenta hacia el NORTE)")
    print("=" * 70)
    
    # Cargar datos
    puntos_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP47_Completo.shp"
    mojones_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\02_BASES_VECTORES\mojones\mojones_rp47\shp\mojones_rp47.shp"
    
    if not os.path.exists(puntos_path):
        print(f"❌ No se encuentran puntos: {puntos_path}")
        return None
    
    print("📁 Cargando datos RP47...")
    puntos_gdf = gpd.read_file(puntos_path)
    
    # Verificar si existen mojones oficiales
    if os.path.exists(mojones_path):
        mojones_gdf = gpd.read_file(mojones_path)
        print(f"✅ Mojones oficiales: {len(mojones_gdf)} mojones")
        
        print(f"\n📋 MOJONES OFICIALES RP47:")
        print("-" * 40)
        for idx, fila in mojones_gdf.iterrows():
            nombre = fila.get('Name', 'N/A')
            km_value = fila.get('km_value', 'N/A')
            descripcion = fila.get('descriptio', 'N/A')
            print(f"  {nombre} | {km_value} km | {descripcion}")
    
    print(f"\n✅ Puntos RP47 cargados: {len(puntos_gdf)}")
    print(f"📍 Campos disponibles: {list(puntos_gdf.columns)}")
    
    # VERIFICAR MOJONES BASE ACTUALES
    mojones_actuales = sorted(puntos_gdf['mojon_base'].unique())
    print(f"📍 Mojones base en datos: {mojones_actuales}")
    
    # VERIFICAR SENTIDO ACTUAL
    if 'sentido_ruta' in puntos_gdf.columns:
        sentidos = puntos_gdf['sentido_ruta'].unique()
        print(f"📍 Sentido actual: {sentidos}")
    
    # ANÁLISIS DETALLADO DE CADA PUNTO
    print(f"\n🔍 ANÁLISIS DETALLADO POR PUNTO:")
    print("=" * 80)
    
    progresivas_corregidas = []
    explicaciones = []
    
    for idx, fila in puntos_gdf.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        mojon_base = fila['mojon_base']
        dist_mojon = fila['dist_mojon']
        prog_actual = fila['PROG_CALC']
        punto_x, punto_y = fila.geometry.x, fila.geometry.y
        
        print(f"\n📍 {wp}:")
        print(f"   Coord: ({punto_x:.0f}, {punto_y:.0f})")
        print(f"   Mojón base: {mojon_base} km")
        print(f"   Distancia al mojón: {dist_mojon} m")
        print(f"   PROG_CALC: {prog_actual} km")
        
        # CÁLCULO CORRECTO para SUR-NORTE
        dist_km = dist_mojon / 1000.0
        
        # En sentido SUR-NORTE:
        # - Si el punto está al NORTE del mojón → SUMAR distancia
        # - Si el punto está al SUR del mojón → RESTAR distancia
        
        # Para simplificar (sin coordenadas exactas de mojones), asumimos:
        # Los puntos están después del mojón en dirección NORTE → SUMAR
        prog_corregida = mojon_base + dist_km
        progresivas_corregidas.append(prog_corregida)
        
        diferencia = prog_corregida - prog_actual
        error_porc = (abs(diferencia) / prog_actual * 100) if prog_actual > 0 else 0
        
        print(f"   Prog corregida: {prog_corregida:.3f} km")
        print(f"   Diferencia: {diferencia:+.3f} km")
        print(f"   Error: {error_porc:.1f} %")
        
        # Análisis de la situación
        if error_porc > 10:
            if diferencia > 0:
                explicacion = "⚠️ SOBREESTIMADO - Posible mojón incorrecto o distancia mal medida"
            else:
                explicacion = "⚠️ SUBESTIMADO - Revisar asignación de mojón"
        else:
            explicacion = "✅ DIFERENCIA ACEPTABLE"
            
        explicaciones.append(explicacion)
        print(f"   {explicacion}")
    
    # ACTUALIZAR DATOS CON CÁLCULO CORRECTO
    puntos_gdf['prog_verificada'] = progresivas_corregidas
    puntos_gdf['diff_verificada'] = puntos_gdf['prog_verificada'] - puntos_gdf['PROG_CALC']
    puntos_gdf['error_verificada'] = (abs(puntos_gdf['diff_verificada']) / puntos_gdf['PROG_CALC'] * 100).fillna(0)
    puntos_gdf['explicacion_verificada'] = explicaciones
    puntos_gdf['sentido_verificado'] = 'SUR-NORTE'
    puntos_gdf['fecha_verificacion'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # ESTADÍSTICAS FINALES
    error_promedio = puntos_gdf['error_verificada'].mean()
    puntos_alto_error = len(puntos_gdf[puntos_gdf['error_verificada'] > 10])
    
    print(f"\n📊 ESTADÍSTICAS DE VERIFICACIÓN RP47:")
    print("=" * 50)
    print(f"   - Puntos verificados: {len(puntos_gdf)}")
    print(f"   - Error promedio: {error_promedio:.1f}%")
    print(f"   - Puntos con error >10%: {puntos_alto_error}")
    print(f"   - Precisión: {(1 - puntos_alto_error/len(puntos_gdf))*100:.1f}%")
    
    # IDENTIFICAR PUNTOS PROBLEMÁTICOS
    if puntos_alto_error > 0:
        print(f"\n⚠️ PUNTOS QUE REQUIEREN REVISIÓN:")
        print("-" * 40)
        puntos_problematicos = puntos_gdf[puntos_gdf['error_verificada'] > 10]
        for idx, fila in puntos_problematicos.iterrows():
            wp = fila.get('WP', f'Punto_{idx+1}')
            print(f"   {wp}: Error {fila['error_verificada']:.1f}% - {fila['explicacion_verificada']}")
    
    # GUARDAR VERIFICACIÓN
    verificacion_path = puntos_path.replace('.shp', '_VERIFICADO.shp')
    puntos_gdf.to_file(verificacion_path)
    print(f"\n💾 Verificación guardada en: {verificacion_path}")
    
    # PREGUNTAR SI ACTUALIZAR
    respuesta = input("\n¿Actualizar campos de progresivas con valores verificados? (s/n): ").strip().lower()
    if respuesta == 's':
        if 'prog_corregida' in puntos_gdf.columns:
            puntos_gdf['prog_corregida'] = puntos_gdf['prog_verificada']
            puntos_gdf['error_porc_calc'] = puntos_gdf['error_verificada']
            puntos_gdf['sentido_ruta'] = puntos_gdf['sentido_verificado']
        
        puntos_gdf.to_file(puntos_path)
        print("✅ Campos actualizados con valores verificados")
    
    return puntos_gdf

def main():
    print("=" * 70)
    print("VERIFICACIÓN ESPECÍFICA RP47 - DVBA ZONA 6")
    print("=" * 70)
    print("OBJETIVO: Validar RP47 con mojones corregidos (0 km y 50 km)")
    print("SENTIDO: SUR-NORTE (aumenta hacia el NORTE)")
    print("=" * 70)
    
    # Verificar RP47
    resultado = verificar_rp47_corregida()
    
    if resultado is not None:
        print(f"\n🎯 RESULTADO RP47:")
        print("   - Verificación completada")
        print("   - Archivo _VERIFICADO.shp generado")
        print("   - Revisar puntos con alto error si los hay")
        
        print(f"\n📝 PRÓXIMAS RUTAS A VERIFICAR:")
        print("   1. RP43 - Revisar sentido y mojones")
        print("   2. RP44 - Revisar sentido y mojones") 
        print("   3. RP46 - Revisar sentido y mojones")
        print("   4. RP91 - Verificar cálculo específico")

if __name__ == "__main__":
    main()