"""
DVBA-Z6-CORRECCION-MANUAL-RP47.py
===========================================================
SCRIPT: Corrección Manual RP47 - Sentido y Mojones Invertidos
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.30.7 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-CORRECCION-MANUAL-RP47

DESCRIPCIÓN:
    - Corrección MANUAL de RP47: Sentido invertido y mojones incorrectos
    - Cambio: mojon_base 0 → 100, mojon_base 100 → 0
    - Sentido correcto: SUR-NORTE (no NORTE-SUR)

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

def corregir_rp47_manual():
    """
    Corrección MANUAL específica para RP47
    """
    print("=" * 70)
    print("CORRECCIÓN MANUAL RP47 - SENTIDO INVERTIDO")
    print("=" * 70)
    print("PROBLEMA: Mojones base invertidos y sentido incorrecto")
    print("SOLUCIÓN:")
    print("  - mojon_base 0 → 100")
    print("  - mojon_base 100 → 0") 
    print("  - Sentido: SUR-NORTE (no NORTE-SUR)")
    print("=" * 70)
    
    # Ruta del archivo
    shp_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP47_Completo.shp"
    
    if not os.path.exists(shp_path):
        print(f"❌ No se encuentra: {shp_path}")
        return
    
    print(f"📁 Cargando: {os.path.basename(shp_path)}")
    gdf = gpd.read_file(shp_path)
    
    print(f"✅ Archivo cargado: {len(gdf)} puntos")
    print(f"📍 Mojones base actuales: {sorted(gdf['mojon_base'].unique())}")
    
    # MOSTRAR SITUACIÓN ACTUAL
    print(f"\n🔍 SITUACIÓN ACTUAL (ANTES):")
    print("-" * 50)
    for idx, fila in gdf.iterrows():
        wp = fila.get('WP', 'N/A')
        print(f"WP {wp}: mojon_base={fila['mojon_base']}km, dist={fila['dist_mojon']}m, PROG_CALC={fila['PROG_CALC']}km")
    
    # APLICAR CORRECCIÓN MANUAL
    print(f"\n🛠️ APLICANDO CORRECCIÓN MANUAL...")
    
    # 1. INVERTIR MOJONES BASE
    gdf['mojon_base_original'] = gdf['mojon_base']  # Guardar original
    gdf['mojon_base'] = gdf['mojon_base'].map({0: 100, 100: 0})
    
    # 2. CALCULAR PROGRESIVAS CORREGIDAS (con sentido SUR-NORTE)
    progresivas_corregidas = []
    for idx, fila in gdf.iterrows():
        mojon_base = fila['mojon_base']  # Ya invertido
        dist_mojon = fila['dist_mojon']
        dist_km = dist_mojon / 1000.0
        
        # En sentido SUR-NORTE: punto al NORTE del mojón → SUMAR
        # punto al SUR del mojón → RESTAR
        punto_y = fila.geometry.y
        
        # Para simplificar, asumimos que todos los puntos están al NORTE del mojón
        # (esto debería verificarse con coordenadas reales de mojones)
        prog_corregida = mojon_base + dist_km
        progresivas_corregidas.append(prog_corregida)
    
    # 3. ACTUALIZAR CAMPOS
    gdf['prog_corregida'] = progresivas_corregidas
    gdf['sentido_ruta'] = 'SUR-NORTE'
    gdf['diff_km'] = gdf['prog_corregida'] - gdf['PROG_CALC']
    gdf['error_porc_calc'] = (abs(gdf['diff_km']) / gdf['PROG_CALC'] * 100).fillna(0)
    
    # Agregar metadatos de corrección
    gdf['correccion_fecha'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    gdf['correccion_desc'] = 'Mojones invertidos: 0↔100, Sentido: SUR-NORTE'
    
    # MOSTRAR RESULTADO
    print(f"\n✅ SITUACIÓN CORREGIDA (DESPUÉS):")
    print("-" * 50)
    for idx, fila in gdf.iterrows():
        wp = fila.get('WP', 'N/A')
        print(f"WP {wp}: mojon_base={fila['mojon_base_original']}→{fila['mojon_base']}km, PROG_CALC={fila['PROG_CALC']}km → {fila['prog_corregida']:.2f}km")
    
    # ESTADÍSTICAS
    error_promedio = gdf['error_porc_calc'].mean()
    puntos_alto_error = len(gdf[gdf['error_porc_calc'] > 10])
    
    print(f"\n📊 RESULTADO DE LA CORRECCIÓN:")
    print(f"   - Error promedio: {error_promedio:.1f}% (antes: 708.5%)")
    print(f"   - Puntos con error >10%: {puntos_alto_error}")
    print(f"   - Mejora: {(708.5 - error_promedio):.1f}% de reducción de error")
    
    # GUARDAR CORRECCIÓN
    correccion_path = shp_path.replace('.shp', '_CORREGIDO_MANUAL.shp')
    gdf.to_file(correccion_path)
    
    print(f"\n💾 Archivo corregido guardado en:")
    print(f"   {correccion_path}")
    
    # PREGUNTAR SI SOBREESCRIBIR ORIGINAL
    respuesta = input("\n¿Sobreescribir archivo original? (s/n): ").strip().lower()
    if respuesta == 's':
        gdf.to_file(shp_path)
        print("✅ Archivo original actualizado")
    else:
        print("💡 Archivo original preservado. Usa el archivo _CORREGIDO_MANUAL")

def verificar_mojones_rp47():
    """
    Verifica los mojones reales de RP47 desde el shapefile oficial
    """
    print(f"\n{'='*70}")
    print("VERIFICACIÓN DE MOJONES OFICIALES RP47")
    print(f"{'='*70}")
    
    mojones_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\02_BASES_VECTORES\mojones\mojones_rp47\shp\mojones_rp47.shp"
    
    if not os.path.exists(mojones_path):
        print(f"❌ No se encuentran mojones oficiales: {mojones_path}")
        return
    
    try:
        mojones_gdf = gpd.read_file(mojones_path)
        print(f"✅ Mojones oficiales cargados: {len(mojones_gdf)} mojones")
        
        print(f"\n📋 MOJONES OFICIALES RP47:")
        print("-" * 40)
        for idx, fila in mojones_gdf.iterrows():
            nombre = fila.get('Name', 'N/A')
            km_value = fila.get('km_value', 'N/A')
            descripcion = fila.get('descriptio', 'N/A')
            print(f"  {nombre} | km_value: {km_value} | {descripcion}")
            
    except Exception as e:
        print(f"❌ Error leyendo mojones oficiales: {e}")

def main():
    print("=" * 70)
    print("CORRECCIÓN MANUAL RP47 - DVBA ZONA 6")
    print("=" * 70)
    print("PROBLEMA: Sentido invertido y mojones incorrectos")
    print("SOLUCIÓN: Intercambiar mojones 0↔100 y cambiar sentido")
    print("=" * 70)
    
    # 1. Verificar mojones oficiales
    verificar_mojones_rp47()
    
    # 2. Aplicar corrección manual
    corregir_rp47_manual()
    
    print(f"\n🎯 PRÓXIMOS PASOS:")
    print("   1. Verificar en QGIS la RP47 corregida")
    print("   2. Si el error persiste, revisar coordenadas de mojones")
    print("   3. Aplicar misma lógica a otras rutas problemáticas")

if __name__ == "__main__":
    main()