"""
DVBA-Z6-PROGRESIVAS-CORRECTOR-RP91.py
===========================================================
SCRIPT: Corrector de Progresivas Viales - RP91 Específico
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.30.1 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-PROGRESIVAS-CORRECTOR-RP91

DESCRIPCIÓN:
    - Corrección ESPECÍFICA para RP91 basada en análisis manual
    - Sentido: NOROESTE → SURESTE
    - Cálculo preciso considerando posición relativa a mojones
"""

import os
import pandas as pd
import geopandas as gpd
import numpy as np
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

def calcular_progresiva_rp91_corregida(fila):
    """
    Cálculo MANUAL específico para RP91 basado en análisis de coordenadas
    """
    mojon_base = fila['mojon_base']
    dist_mojon = fila['dist_mojon']
    dist_km = dist_mojon / 1000.0
    punto_x, punto_y = fila['geometry'].x, fila['geometry'].y
    
    print(f"  Punto: ({punto_x:.0f}, {punto_y:.0f})")
    print(f"  Base: {mojon_base}km, Dist: {dist_mojon}m")
    
    # ANÁLISIS MANUAL RP91 - Coordenadas aproximadas:
    # Mojón 0: (5519249, 6050471) - NOROESTE (Saladillo)
    # Mojón 50: (5554061, 6029856) - SURESTE 
    # Dirección: NW → SE (X aumenta, Y disminuye)
    
    if mojon_base == 0:
        # Para mojón 0: Todos los puntos están DESPUÉS (hacia SE) → SUMAR
        resultado = mojon_base + dist_km
        print(f"  → Mojón 0: Punto después → SUMAR {dist_km} = {resultado}km")
        
    elif mojon_base == 50:
        # Coordenadas del mojón 50
        mojon50_x, mojon50_y = 5554061, 6029856
        
        # Determinar si el punto está ANTES o DESPUÉS del mojón 50
        # En dirección NW-SE:
        # - Punto con X mayor e Y menor → DESPUÉS (SE) → SUMAR
        # - Punto con X menor e Y mayor → ANTES (NW) → RESTAR
        
        if punto_x > mojon50_x and punto_y < mojon50_y:
            # Punto al SURESTE del mojón 50 → DESPUÉS → SUMAR
            resultado = mojon_base + dist_km
            print(f"  → Punto al SURESTE de mojón 50 → SUMAR {dist_km} = {resultado}km")
        else:
            # Punto al NOROESTE del mojón 50 → ANTES → RESTAR
            resultado = mojon_base - dist_km
            print(f"  → Punto al NOROESTE de mojón 50 → RESTAR {dist_km} = {resultado}km")
    else:
        # Para otros casos, usar cálculo tradicional
        resultado = mojon_base + dist_km
        print(f"  → Otro mojón → SUMAR {dist_km} = {resultado}km")
    
    return resultado

def main():
    """Función principal"""
    print("=" * 70)
    print("CORRECTOR ESPECÍFICO RP91 - DVBA ZONA 6")
    print("=" * 70)
    print("Sentido: NOROESTE → SURESTE")
    print("Mojón 0: (5519249, 6050471) - Saladillo")
    print("Mojón 50: (5554061, 6029856)")
    print("=" * 70)
    
    # Archivo específico para RP91
    input_shp = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP91_Completo.shp"
    
    if not os.path.exists(input_shp):
        print(f"❌ Error: El archivo no existe: {input_shp}")
        return
    
    print(f"📁 Cargando shapefile: {input_shp}")
    gdf = gpd.read_file(input_shp)
    
    print(f"✅ Shapefile cargado: {len(gdf)} puntos")
    
    # Listas para nuevos campos
    progresivas_corregidas = []
    explicaciones = []
    
    print(f"\n🔍 PROCESANDO RP91 - CÁLCULO ESPECÍFICO:")
    print("=" * 50)
    
    for idx, fila in gdf.iterrows():
        wp = fila.get('WP', 'N/A')
        prog_actual = fila['PROG_CALC']
        mojon_base = fila['mojon_base']
        dist_mojon = fila['dist_mojon']
        
        print(f"\n📍 WP {wp}:")
        print(f"   Prog actual: {prog_actual}km")
        print(f"   Mojón base: {mojon_base}km")
        print(f"   Dist al mojón: {dist_mojon}m")
        
        # Calcular progresiva corregida
        prog_corregida = calcular_progresiva_rp91_corregida(fila)
        
        # Calcular diferencia y error
        diferencia = prog_corregida - prog_actual
        error_porc = (abs(diferencia) / prog_actual * 100) if prog_actual > 0 else 0
        
        print(f"   📊 RESULTADO: {prog_actual:.2f}km → {prog_corregida:.2f}km")
        print(f"   📏 Diferencia: {diferencia:+.2f}km | Error: {error_porc:.1f}%")
        
        progresivas_corregidas.append(prog_corregida)
        explicaciones.append(f"Diferencia: {diferencia:+.2f}km")
    
    # Agregar nuevos campos
    gdf['prog_corregida'] = progresivas_corregidas
    gdf['diff_km'] = gdf['prog_corregida'] - gdf['PROG_CALC']
    gdf['error_porc_calc'] = (abs(gdf['diff_km']) / gdf['PROG_CALC'] * 100).fillna(0)
    gdf['sentido_ruta'] = 'NOROESTE-SURESTE'
    gdf['explicacion_calc'] = explicaciones
    
    # Crear backup
    backup_file = input_shp.replace('.shp', f'_backup_RP91_{datetime.now().strftime("%H%M")}.shp')
    print(f"\n💾 Creando backup: {backup_file}")
    gdf.to_file(backup_file)
    
    # Sobreescribir original
    print(f"✏️ Sobreescribiendo archivo original...")
    gdf.to_file(input_shp)
    
    print(f"\n✅ PROCESAMIENTO COMPLETADO!")
    print("=" * 50)
    
    # Mostrar resumen final
    print("\n📈 RESUMEN FINAL RP91:")
    for idx, fila in gdf.iterrows():
        wp = fila.get('WP', 'N/A')
        print(f"   WP {wp}: {fila['PROG_CALC']:.2f}km → {fila['prog_corregida']:.2f}km | Δ: {fila['diff_km']:+.2f}km | Error: {fila['error_porc_calc']:.1f}%")
    
    error_promedio = gdf['error_porc_calc'].mean()
    print(f"\n📊 Error promedio: {error_promedio:.1f}%")
    
    # Puntos problemáticos
    puntos_problematicos = gdf[gdf['error_porc_calc'] > 10]
    if len(puntos_problematicos) > 0:
        print(f"⚠️  Puntos con error >10%: {len(puntos_problematicos)}")
        for idx, fila in puntos_problematicos.iterrows():
            wp = fila.get('WP', 'N/A')
            print(f"   - WP {wp}: Error {fila['error_porc_calc']:.1f}%")

if __name__ == "__main__":
    main()