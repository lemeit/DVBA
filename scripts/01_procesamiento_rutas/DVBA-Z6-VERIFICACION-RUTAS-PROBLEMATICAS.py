"""
DVBA-Z6-VERIFICACION-RUTAS-PROBLEMATICAS.py
===========================================================
SCRIPT: Verificación Rutas Problemáticas (RP43, RP44, RP46)
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.30.10 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-VERIFICACION-RUTAS-PROBLEMATICAS

DESCRIPCIÓN:
    - Verificación masiva de rutas con alto error
    - RP43, RP44, RP46 - Patrón similar a RP47
    - Corrección automática de sentidos y mojones

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

# CONFIGURACIÓN DE RUTAS PROBLEMÁTICAS
RUTAS_PROBLEMATICAS = {
    43: {
        'sentido_correcto': 'SURESTE-NOROESTE',  # Posible inversión
        'mojones_esperados': [0, 100]
    },
    44: {
        'sentido_correcto': 'ESTE-OESTE',  # Posible inversión  
        'mojones_esperados': [0, 100]
    },
    46: {
        'sentido_correcto': 'SURESTE-NOROESTE',  # Posible inversión
        'mojones_esperados': [0, 50, 100]
    }
}

def verificar_ruta_problematica(ruta_num):
    """
    Verifica y corrige una ruta problemática
    """
    print(f"\n{'='*70}")
    print(f"VERIFICACIÓN RP{ruta_num}")
    print(f"{'='*70}")
    
    # Cargar datos
    puntos_path = f"C:\\Users\\Of. Técnica Z6\\OneDrive\\Documentos\\QGIS FIles\\Proyecto_Redes_Viales\\05_RESULTADOS\\Puntos_RP{ruta_num}_Completo.shp"
    
    if not os.path.exists(puntos_path):
        print(f"❌ No se encuentra: {puntos_path}")
        return None
    
    print(f"📁 Cargando RP{ruta_num}...")
    puntos_gdf = gpd.read_file(puntos_path)
    
    print(f"✅ Puntos cargados: {len(puntos_gdf)}")
    
    # VERIFICAR SITUACIÓN ACTUAL
    mojones_actuales = sorted(puntos_gdf['mojon_base'].unique())
    print(f"📍 Mojones base actuales: {mojones_actuales}")
    
    if 'sentido_ruta' in puntos_gdf.columns:
        sentidos = puntos_gdf['sentido_ruta'].unique()
        print(f"📍 Sentido actual: {sentidos}")
    
    # ANÁLISIS POR PUNTO
    print(f"\n🔍 ANÁLISIS DETALLADO RP{ruta_num}:")
    print("-" * 60)
    
    progresivas_corregidas = []
    errores_porcentuales = []
    
    for idx, fila in puntos_gdf.iterrows():
        wp = fila.get('WP', f'Punto_{idx+1}')
        mojon_base = fila['mojon_base']
        dist_mojon = fila['dist_mojon']
        prog_actual = fila['PROG_CALC']
        
        # CÁLCULO ACTUAL (puede estar invertido)
        dist_km = dist_mojon / 1000.0
        prog_actual_calc = mojon_base + dist_km
        
        diferencia_actual = prog_actual_calc - prog_actual
        error_actual = (abs(diferencia_actual) / prog_actual * 100) if prog_actual > 0 else 0
        
        print(f"📍 {wp}:")
        print(f"   PROG_CALC: {prog_actual} km")
        print(f"   Cálculo actual: {prog_actual_calc:.3f} km")
        print(f"   Error actual: {error_actual:.1f}%")
        
        # INTENTAR CÁLCULO INVERTIDO (posible corrección)
        prog_invertido = mojon_base - dist_km
        diferencia_invertido = prog_invertido - prog_actual
        error_invertido = (abs(diferencia_invertido) / prog_actual * 100) if prog_actual > 0 else 0
        
        print(f"   Cálculo invertido: {prog_invertido:.3f} km")
        print(f"   Error invertido: {error_invertido:.1f}%")
        
        # USAR EL CÁLCULO CON MENOR ERROR
        if error_invertido < error_actual:
            prog_corregida = prog_invertido
            error_final = error_invertido
            explicacion = "🔄 USANDO CÁLCULO INVERTIDO (mejor)"
        else:
            prog_corregida = prog_actual_calc
            error_final = error_actual
            explicacion = "📏 USANDO CÁLCULO ACTUAL"
        
        print(f"   {explicacion}")
        
        progresivas_corregidas.append(prog_corregida)
        errores_porcentuales.append(error_final)
    
    # ESTADÍSTICAS
    error_promedio = np.mean([e for e in errores_porcentuales if e < 1000])  # Excluir outliers
    puntos_alto_error = len([e for e in errores_porcentuales if e > 10])
    
    print(f"\n📊 ESTADÍSTICAS RP{ruta_num}:")
    print(f"   - Error promedio: {error_promedio:.1f}%")
    print(f"   - Puntos con error >10%: {puntos_alto_error}")
    print(f"   - Precisión: {(1 - puntos_alto_error/len(puntos_gdf))*100:.1f}%")
    
    # ACTUALIZAR DATOS
    puntos_gdf['prog_verificada'] = progresivas_corregidas
    puntos_gdf['error_verificada'] = errores_porcentuales
    puntos_gdf['fecha_verificacion'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # DETERMINAR SENTIDO CORRECTO
    if error_promedio < 20:  # Si el error es aceptable
        sentido_recomendado = RUTAS_PROBLEMATICAS[ruta_num]['sentido_correcto']
    else:
        sentido_recomendado = "REVISIÓN MANUAL REQUERIDA"
    
    puntos_gdf['sentido_recomendado'] = sentido_recomendado
    
    # GUARDAR RESULTADO
    verificacion_path = puntos_path.replace('.shp', f'_VERIFICADO_{datetime.now().strftime("%H%M")}.shp')
    puntos_gdf.to_file(verificacion_path)
    print(f"💾 Verificación guardada: {os.path.basename(verificacion_path)}")
    
    return {
        'ruta': ruta_num,
        'error_promedio': error_promedio,
        'puntos_alto_error': puntos_alto_error,
        'sentido_recomendado': sentido_recomendado,
        'archivo': verificacion_path
    }

def main():
    print("=" * 70)
    print("VERIFICACIÓN RUTAS PROBLEMÁTICAS - DVBA ZONA 6")
    print("=" * 70)
    print("RUTAS: RP43, RP44, RP46")
    print("PROBLEMA: Sentidos posiblemente invertidos")
    print("=" * 70)
    
    resultados = []
    
    # VERIFICAR CADA RUTA PROBLEMÁTICA
    for ruta_num in [43, 44, 46]:
        resultado = verificar_ruta_problematica(ruta_num)
        if resultado:
            resultados.append(resultado)
    
    # REPORTE CONSOLIDADO
    print(f"\n{'='*70}")
    print("REPORTE CONSOLIDADO - RUTAS PROBLEMÁTICAS")
    print(f"{'='*70}")
    
    for res in resultados:
        estado = "✅ ACEPTABLE" if res['error_promedio'] < 20 else "⚠️ REVISAR"
        print(f"RP{res['ruta']:2d} | Error: {res['error_promedio']:5.1f}% | >10%: {res['puntos_alto_error']:2d} | {estado} | {res['sentido_recomendado']}")
    
    # RECOMENDACIONES
    print(f"\n🎯 RECOMENDACIONES:")
    for res in resultados:
        if res['error_promedio'] > 20:
            print(f"📍 RP{res['ruta']}: Revisión manual requerida - Error muy alto")
        elif res['error_promedio'] > 10:
            print(f"📍 RP{res['ruta']}: Aceptable pero revisar puntos específicos")
        else:
            print(f"📍 RP{res['ruta']}: ✅ Situación aceptable")
    
    print(f"\n💡 PRÓXIMOS PASOS:")
    print("   1. Revisar archivos _VERIFICADO en QGIS")
    print("   2. Aplicar correcciones si son necesarias")
    print("   3. Continuar con RP91 para ajuste final")

if __name__ == "__main__":
    main()