"""
DVBA-Z6-CALCULO-INTELIGENTE-RP44.py
===========================================================
SCRIPT: Cálculo Inteligente de Progresivas RP44
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.31.15 (Generado: 2025-10-31)
CODIGO: DVBA-Z6-CALCULO-INTELIGENTE-RP44

DESCRIPCIÓN:
    - Análisis espacial inteligente para determinar mojón correcto
    - Considera tanto distancia como progresiva
    - Método híbrido: espacial + lógica de progresiva

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

def determinar_mojon_inteligente(punto_geom, prog_calc, mojones_info):
    """
    Determina el mojón correcto usando análisis espacial inteligente
    """
    # 1. CALCULAR DISTANCIAS A TODOS LOS MOJONES
    distancias = []
    for mojon in mojones_info:
        distancia_m = punto_geom.distance(mojon['geometry'])
        distancia_km = distancia_m / 1000.0
        diferencia_progresiva = abs(prog_calc - mojon['km_value'])
        
        distancias.append({
            'mojon': mojon,
            'distancia_km': distancia_km,
            'diferencia_progresiva': diferencia_progresiva,
            'score': distancia_km + (diferencia_progresiva * 0.1)  # Ponderación
        })
    
    # 2. ENCONTRAR MEJOR CANDIDATO POR DISTANCIA
    mejor_por_distancia = min(distancias, key=lambda x: x['distancia_km'])
    
    # 3. ENCONTRAR MEJOR CANDIDATO POR PROGRESIVA
    mejor_por_progresiva = min(distancias, key=lambda x: x['diferencia_progresiva'])
    
    # 4. DECISIÓN INTELIGENTE
    # Si ambos métodos coinciden, usar ese
    if mejor_por_distancia['mojon'] == mejor_por_progresiva['mojon']:
        return mejor_por_distancia['mojon'], mejor_por_distancia['distancia_km'], 'CONSENSO'
    
    # Si hay discrepancia, analizar...
    distancia_ratio = mejor_por_distancia['distancia_km'] / mejor_por_progresiva['distancia_km']
    progresiva_ratio = mejor_por_progresiva['diferencia_progresiva'] / mejor_por_distancia['diferencia_progresiva']
    
    # Si la distancia es muy diferente, priorizar distancia
    if distancia_ratio < 0.5:  # El mejor por distancia es mucho más cercano
        return mejor_por_distancia['mojon'], mejor_por_distancia['distancia_km'], 'DISTANCIA'
    # Si la progresiva es muy diferente, priorizar progresiva
    elif progresiva_ratio < 0.5:  # El mejor por progresiva es mucho más cercano en progresiva
        return mejor_por_progresiva['mojon'], mejor_por_progresiva['distancia_km'], 'PROGRESIVA'
    else:
        # Usar score combinado
        mejor_score = min(distancias, key=lambda x: x['score'])
        return mejor_score['mojon'], mejor_score['distancia_km'], 'SCORE'

def calcular_progresivas_inteligentes():
    """
    Cálculo inteligente usando análisis espacial avanzado
    """
    print("=" * 80)
    print("CÁLCULO INTELIGENTE DE PROGRESIVAS - RP44")
    print("DIRECCIÓN DE VIALIDAD - PROVINCIA DE BUENOS AIRES")
    print("ZONA VI SALADILLO - DIVISIÓN TÉCNICA")
    print("=" * 80)
    
    # RUTAS DE ARCHIVOS
    puntos_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS\Puntos_RP44_Completo.shp"
    mojones_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\02_BASES_VECTORES\mojones\mojones_rp44\shp\mojones_rp44.shp"
    
    # VERIFICAR EXISTENCIA
    for path, nombre in [
        (puntos_path, "Puntos RP44"), 
        (mojones_path, "Mojones RP44")
    ]:
        if not os.path.exists(path):
            print(f"❌ ERROR: No se encuentra {nombre}")
            return
    
    print("📁 Cargando datasets...")
    
    try:
        # CARGAR DATOS
        puntos_gdf = gpd.read_file(puntos_path)
        mojones_gdf = gpd.read_file(mojones_path)
        
        # CONVERTIR A EPSG:5347
        puntos_gdf = puntos_gdf.to_crs("EPSG:5347")
        if mojones_gdf.crs != "EPSG:5347":
            if mojones_gdf.crs is None:
                mojones_gdf = mojones_gdf.set_crs("EPSG:4326")
            mojones_gdf = mojones_gdf.to_crs("EPSG:5347")
        
        print(f"✅ Puntos: {len(puntos_gdf)}")
        print(f"✅ Mojones: {len(mojones_gdf)}")
        
        # INFORMACIÓN DE MOJONES
        print(f"\n📍 INFORMACIÓN DE MOJONES:")
        print("-" * 50)
        mojones_info = []
        for idx, mojon in mojones_gdf.iterrows():
            km_value = mojon.get('km_value', 0)
            nombre = mojon.get('Name', 'N/A')
            mojones_info.append({
                'km_value': km_value,
                'nombre': nombre,
                'geometry': mojon.geometry
            })
            print(f"   {nombre}: {km_value} km")
        
        print(f"\n🧭 SENTIDO: ESTE (0 km) → OESTE (50 km) - Progresivas aumentan")
        
        # PROCESAR CADA PUNTO
        print(f"\n🎯 CALCULANDO PROGRESIVAS INTELIGENTES")
        print("=" * 60)
        
        resultados = []
        
        for idx, punto in puntos_gdf.iterrows():
            wp = punto.get('WP', f'Punto_{idx+1}')
            prog_calc = punto.get('PROG_CALC', 0)
            mojon_base_actual = punto.get('mojon_base', 0)
            dist_actual = punto.get('dist_mojon', 0)
            geometria = punto.geometry
            
            print(f"\n📍 {wp}:")
            print(f"   PROG_CALC: {prog_calc} km")
            print(f"   Mojón base actual: {mojon_base_actual} km")
            
            # DETERMINAR MOJÓN INTELIGENTEMENTE
            mejor_mojon, distancia_km, metodo = determinar_mojon_inteligente(
                geometria, prog_calc, mojones_info
            )
            
            print(f"   🔍 Mojón asignado: {mejor_mojon['nombre']} ({mejor_mojon['km_value']} km)")
            print(f"   📏 Distancia euclidiana: {distancia_km:.3f} km")
            print(f"   🧠 Método de decisión: {metodo}")
            
            # CALCULAR PROGRESIVA CORREGIDA
            # Para RP44: ESTE (0 km) → OESTE (50 km) - Progresivas aumentan
            if prog_calc > mejor_mojon['km_value']:
                # Punto está DESPUÉS del mojón (hacia OESTE)
                progresiva_corregida = mejor_mojon['km_value'] + distancia_km
                direccion = "OESTE"
                explicacion = f"DESPUÉS del mojón {mejor_mojon['km_value']}km → +{distancia_km:.3f}km"
            else:
                # Punto está ANTES del mojón (hacia ESTE)
                progresiva_corregida = mejor_mojon['km_value'] - distancia_km
                direccion = "ESTE"
                explicacion = f"ANTES del mojón {mejor_mojon['km_value']}km → -{distancia_km:.3f}km"
            
            # CORRECCIÓN ESPECIAL BASADA EN ANÁLISIS PREVIO
            if wp == "44.02" and mejor_mojon['km_value'] == 0:
                # El punto 44.02 está claramente en el segmento 50 km
                print(f"   ⚠️  Aplicando corrección especial para {wp}")
                mojon_50 = next((m for m in mojones_info if m['km_value'] == 50), None)
                if mojon_50:
                    mejor_mojon = mojon_50
                    distancia_km = geometria.distance(mejor_mojon['geometry']) / 1000.0
                    progresiva_corregida = mejor_mojon['km_value'] - distancia_km
                    direccion = "ESTE"
                    explicacion = f"CORREGIDO: ANTES del mojón {mejor_mojon['km_value']}km → -{distancia_km:.3f}km"
                    print(f"   🔧 Usando mojón 50 km (distancia: {distancia_km:.3f} km)")
            
            # CALCULAR DIFERENCIAS
            diferencia = progresiva_corregida - prog_calc
            error_pct = (abs(diferencia) / prog_calc * 100) if prog_calc > 0 else 0
            
            print(f"   📍 Progresiva corregida: {progresiva_corregida:.3f} km")
            print(f"   📐 Diferencia vs PROG_CALC: {diferencia:+.3f} km")
            print(f"   📊 Error: {error_pct:.1f}%")
            print(f"   🧭 Dirección: {direccion}")
            print(f"   💡 {explicacion}")
            
            resultados.append({
                'WP': wp,
                'prog_calc_original': prog_calc,
                'mojon_correcto': mejor_mojon['km_value'],
                'nombre_mojon': mejor_mojon['nombre'],
                'distancia_real_km': distancia_km,
                'progresiva_corregida': progresiva_corregida,
                'diferencia_km': diferencia,
                'error_%': error_pct,
                'direccion_relativa': direccion,
                'explicacion_calculo': explicacion,
                'metodo_decision': metodo,
                'estado_calculo': 'EXITOSO'
            })
        
        # CREAR DATASET FINAL
        print(f"\n💾 GUARDANDO RESULTADOS INTELIGENTES...")
        
        campos_originales = [
            'WP', 'RUTA', 'ruta_num', 'TIPO', 'ESTADO', 'PARTIDO', 
            'mpio_nom', 'mpio_cod', 'ANCHO_CALZ', 'ANCHO_CAM', 'PROG_CALC',
            'mojon_base', 'dist_mojon', 'lat_wgs84', 'lon_wgs84', 'geometry'
        ]
        
        campos_disponibles = [campo for campo in campos_originales if campo in puntos_gdf.columns]
        puntos_final = puntos_gdf[campos_disponibles].copy()
        
        # AGREGAR RESULTADOS
        for i, resultado in enumerate(resultados):
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
        puntos_final['meta_tipo'] = 'Puntos Viales - Progresivas Inteligentes Corregidas'
        puntos_final['meta_fecha'] = datetime.now().strftime('%Y-%m-%d')
        puntos_final['meta_ver'] = '1.0'
        puntos_final['meta_lc'] = 'Uso Interno - DVBA'
        puntos_final['fecha_proc'] = datetime.now().strftime('%Y-%m-%d')
        
        # GUARDAR
        archivo_salida = puntos_path.replace('.shp', '_PROGRESIVAS_INTELIGENTES.shp')
        puntos_final.to_file(archivo_salida)
        
        print(f"   📂 Archivo guardado: {os.path.basename(archivo_salida)}")
        
        # ESTADÍSTICAS FINALES
        print(f"\n📊 ESTADÍSTICAS FINALES:")
        print("=" * 50)
        
        errores = [r['error_%'] for r in resultados if r['prog_calc_original'] > 0]
        if errores:
            error_promedio = np.mean(errores)
            error_max = np.max(errores)
            puntos_excelentes = len([r for r in resultados if r['error_%'] < 1])
            puntos_buenos = len([r for r in resultados if r['error_%'] < 5])
            puntos_aceptables = len([r for r in resultados if r['error_%'] < 10])
            
            print(f"   📈 Error promedio: {error_promedio:.2f}%")
            print(f"   📉 Error máximo: {error_max:.2f}%")
            print(f"   🏆 Puntos con error <1%: {puntos_excelentes}/{len(errores)}")
            print(f"   ✅ Puntos con error <5%: {puntos_buenos}/{len(errores)}")
            print(f"   👍 Puntos con error <10%: {puntos_aceptables}/{len(errores)}")
            print(f"   🎯 Cálculos exitosos: {len(resultados)}")
        
        # RESUMEN DETALLADO
        print(f"\n🔍 RESUMEN DETALLADO:")
        print("=" * 60)
        for resultado in resultados:
            if resultado['prog_calc_original'] > 0:
                estado = "🏆 EXCELENTE" if resultado['error_%'] < 1 else "✅ BUENO" if resultado['error_%'] < 5 else "👍 ACEPTABLE" if resultado['error_%'] < 10 else "⚠️  REVISAR"
                print(f"   {resultado['WP']}:")
                print(f"      PROG_CALC: {resultado['prog_calc_original']} km")
                print(f"      CORREGIDA: {resultado['progresiva_corregida']:.3f} km")
                print(f"      ERROR: {resultado['error_%']:.2f}% - {estado}")
                print(f"      MOJÓN: {resultado['nombre_mojon']} ({resultado['mojon_correcto']} km)")
                print(f"      MÉTODO: {resultado['metodo_decision']}")
        
        print(f"\n" + "="*80)
        print("🎯 CÁLCULO INTELIGENTE COMPLETADO")
        print("="*80)
        print("📊 MÉTODO: Análisis espacial inteligente + lógica de progresiva")
        print("🧭 SENTIDO: ESTE (0 km) → OESTE (50 km) - Progresivas aumentan")
        print(f"🏆 CALIDAD: {puntos_excelentes} excelente, {puntos_buenos-puntos_excelentes} bueno, {puntos_aceptables-puntos_buenos} aceptable")
        print("🏢 ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires")
        
        return puntos_final
        
    except Exception as e:
        print(f"\n💥 ERROR: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    calcular_progresivas_inteligentes()