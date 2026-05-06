"""
DVBA_Z6_VALIDACION_COMPLETA.py
===========================================================
VALIDACIÓN COMPLETA: Capas generadas vs Base oficial
"""

import geopandas as gpd
import pandas as pd
import numpy as np
import os
import glob
from pathlib import Path

# CONFIGURACIÓN DE DIRECTORIOS
CONFIG = {
    'base_path': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    'tablas_csv': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\04_TABLAS",
    'capas_generadas': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\03_CAPAS_GENERADAS",
    'salida_validacion': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\07_VALIDACION"
}

# PARTIDOS ZONA VI (confirmados del análisis)
PARTIDOS_ZONA_VI = {
    '034': 'General Alvear',
    '041': 'General Las Heras', 
    '058': 'Las Flores',
    '062': 'Lobos',
    '075': 'Navarro',
    '091': 'Roque Pérez',
    '093': 'Saladillo',
    '109': '25 de Mayo'
}

def cargar_base_oficial():
    """Carga la base oficial ya que sabemos que funciona con latin-1"""
    csv_path = os.path.join(CONFIG['tablas_csv'], 'SALADILLO_RED.csv')
    
    try:
        df = pd.read_csv(csv_path, sep=';', encoding='latin-1')
        print(f"✅ Base oficial cargada: {len(df)} registros")
        
        # Limpiar datos
        df['RUTA'] = df['RUTA'].astype(str).str.strip()
        df['PARTIDO'] = df['PARTIDO'].astype(str).str.strip().str.zfill(3)
        df['Longitud en metros'] = pd.to_numeric(df['Longitud en metros'], errors='coerce')
        
        return df
    except Exception as e:
        print(f"❌ Error cargando base oficial: {e}")
        return None

def encontrar_todas_las_capas():
    """Encuentra TODAS las capas de rutas generadas"""
    print("\n🔍 Buscando todas las capas generadas...")
    
    # Patrones de búsqueda
    patrones = [
        os.path.join(CONFIG['capas_generadas'], "**", "*POR_PARTIDOS", "*.shp"),
        os.path.join(CONFIG['capas_generadas'], "**", "RP*", "*.shp"),
        os.path.join(CONFIG['capas_generadas'], "**", "RP*.shp")
    ]
    
    todas_las_capas = []
    for patron in patrones:
        archivos = glob.glob(patron, recursive=True)
        for archivo in archivos:
            # Excluir archivos temporales y de backup
            if not any(x in archivo.lower() for x in ['temp', 'backup', 'corregida']):
                todas_las_capas.append(archivo)
    
    # Agrupar por ruta
    capas_por_ruta = {}
    for archivo in todas_las_capas:
        nombre = os.path.basename(archivo)
        
        # Extraer número de ruta de diferentes patrones
        ruta_num = None
        if nombre.startswith('RP'):
            # Patrones: RP91_Segmentada_Por_Partidos.shp, RP91_Saladillo.shp, etc.
            if '_' in nombre:
                ruta_num = nombre.split('_')[0][2:]  # "RP91" -> "91"
            else:
                ruta_num = nombre[2:4] if nombre[2:4].isdigit() else nombre[2:3]
        
        if ruta_num and ruta_num.isdigit():
            if ruta_num not in capas_por_ruta:
                capas_por_ruta[ruta_num] = []
            capas_por_ruta[ruta_num].append(archivo)
    
    print(f"✅ Encontradas {len(todas_las_capas)} capas para {len(capas_por_ruta)} rutas")
    return capas_por_ruta

def analizar_capa_detallado(archivo):
    """Análisis detallado de una capa"""
    try:
        gdf = gpd.read_file(archivo)
        print(f"\n📊 ANALISIS: {os.path.basename(archivo)}")
        print(f"   • Segmentos: {len(gdf)}")
        print(f"   • CRS: {gdf.crs}")
        
        # Campos disponibles
        campos_importantes = []
        for campo in gdf.columns:
            if any(palabra in campo.lower() for palabra in ['partido', 'codigo', 'longitud', 'ruta', 'length']):
                valores_unicos = gdf[campo].dropna().unique()
                print(f"   • {campo}: {list(valores_unicos[:3])}..." if len(valores_unicos) > 3 else f"   • {campo}: {list(valores_unicos)}")
                campos_importantes.append(campo)
        
        # Calcular longitudes si no existen
        if 'longitud_m' not in gdf.columns and 'longitud_km' not in gdf.columns:
            gdf['longitud_calculada_m'] = gdf.geometry.length
            longitud_total = gdf.geometry.length.sum()
            print(f"   • Longitud total calculada: {longitud_total/1000:.2f} km")
        
        return gdf
        
    except Exception as e:
        print(f"❌ Error analizando {archivo}: {e}")
        return None

def validar_ruta_completa(ruta_num, archivos_capa, base_oficial):
    """Valida una ruta completa contra la base oficial"""
    print(f"\n{'='*50}")
    print(f"VALIDANDO RP{ruta_num}")
    print(f"{'='*50}")
    
    resultados_ruta = []
    
    for archivo in archivos_capa:
        if 'Segmentada_Por_Partidos' in archivo or 'consolidada' in archivo.lower():
            print(f"📁 Usando capa consolidada: {os.path.basename(archivo)}")
            
            try:
                gdf = gpd.read_file(archivo)
                
                # Para cada partido en la base oficial para esta ruta
                partidos_oficial = base_oficial[base_oficial['RUTA'] == ruta_num]['PARTIDO'].unique()
                
                for partido_cod in partidos_oficial:
                    if partido_cod in PARTIDOS_ZONA_VI:
                        # Filtrar segmentos de este partido en la capa
                        segmentos_partido = gdf[gdf['partido_codigo'] == partido_cod] if 'partido_codigo' in gdf.columns else gdf
                        
                        # Calcular longitud generada
                        if len(segmentos_partido) > 0:
                            if 'longitud_m' in segmentos_partido.columns:
                                longitud_generada = segmentos_partido['longitud_m'].sum()
                            else:
                                longitud_generada = segmentos_partido.geometry.length.sum()
                            
                            # Longitud oficial
                            filtro_oficial = (base_oficial['RUTA'] == ruta_num) & (base_oficial['PARTIDO'] == partido_cod)
                            longitud_oficial = base_oficial[filtro_oficial]['Longitud en metros'].sum()
                            
                            diferencia = abs(longitud_generada - longitud_oficial)
                            diferencia_porc = (diferencia / longitud_oficial * 100) if longitud_oficial > 0 else 100
                            
                            resultado = {
                                'ruta': f"RP{ruta_num}",
                                'partido_codigo': partido_cod,
                                'partido_nombre': PARTIDOS_ZONA_VI[partido_cod],
                                'longitud_generada_m': round(longitud_generada, 2),
                                'longitud_oficial_m': round(longitud_oficial, 2),
                                'diferencia_m': round(diferencia, 2),
                                'diferencia_porc': round(diferencia_porc, 2),
                                'segmentos_encontrados': len(segmentos_partido),
                                'valido': diferencia_porc <= 2.0,  # Tolerancia más estricta
                                'archivo': os.path.basename(archivo)
                            }
                            resultados_ruta.append(resultado)
                            
                            print(f"   ✅ {PARTIDOS_ZONA_VI[partido_cod]}: {longitud_generada/1000:.2f} km vs {longitud_oficial/1000:.2f} km oficial")
                
            except Exception as e:
                print(f"❌ Error procesando {archivo}: {e}")
    
    return resultados_ruta

def generar_reporte_completo(resultados):
    """Genera reporte completo de validación"""
    os.makedirs(CONFIG['salida_validacion'], exist_ok=True)
    
    if not resultados:
        print("❌ No hay resultados para reportar")
        return
    
    df = pd.DataFrame(resultados)
    
    # Reporte CSV detallado
    reporte_csv = os.path.join(CONFIG['salida_validacion'], 'validacion_completa_detalle.csv')
    df.to_csv(reporte_csv, index=False, encoding='utf-8')
    
    # Reporte resumido por ruta
    resumen_rutas = df.groupby('ruta').agg({
        'longitud_generada_m': 'sum',
        'longitud_oficial_m': 'sum',
        'diferencia_m': 'sum',
        'valido': 'sum',
        'partido_codigo': 'count'
    }).round(2)
    
    resumen_rutas['diferencia_%'] = (resumen_rutas['diferencia_m'] / resumen_rutas['longitud_oficial_m'] * 100).round(2)
    resumen_rutas['%_valido'] = (resumen_rutas['valido'] / resumen_rutas['partido_codigo'] * 100).round(1)
    
    reporte_resumen = os.path.join(CONFIG['salida_validacion'], 'validacion_completa_resumen.csv')
    resumen_rutas.to_csv(reporte_resumen, encoding='utf-8')
    
    # Estadísticas generales
    total_segmentos = len(df)
    segmentos_validos = df['valido'].sum()
    longitud_total_generada = df['longitud_generada_m'].sum() / 1000
    longitud_total_oficial = df['longitud_oficial_m'].sum() / 1000
    
    print(f"\n🎯 REPORTE FINAL DE VALIDACIÓN")
    print(f"{'='*60}")
    print(f"• Total segmentos validados: {total_segmentos}")
    print(f"• Segmentos dentro de tolerancia: {segmentos_validos} ({segmentos_validos/total_segmentos*100:.1f}%)")
    print(f"• Longitud total generada: {longitud_total_generada:.2f} km")
    print(f"• Longitud total oficial: {longitud_total_oficial:.2f} km")
    print(f"• Diferencia total: {abs(longitud_total_generada - longitud_total_oficial):.2f} km")
    print(f"• Reportes guardados en: {CONFIG['salida_validacion']}")
    
    return df, resumen_rutas

def main():
    """Función principal"""
    print("=" * 70)
    print("DVBA - VALIDACIÓN COMPLETA CAPAS vs BASE OFICIAL")
    print("=" * 70)
    
    # 1. Cargar base oficial
    base_oficial = cargar_base_oficial()
    if base_oficial is None:
        return
    
    # 2. Encontrar capas
    capas_por_ruta = encontrar_todas_las_capas()
    if not capas_por_ruta:
        print("❌ No se encontraron capas para validar")
        return
    
    # 3. Analizar algunas capas para entender la estructura
    print("\n🔍 ANALIZANDO ESTRUCTURA DE CAPAS...")
    for ruta_num in list(capas_por_ruta.keys())[:3]:  # Analizar primeras 3 rutas
        for archivo in capas_por_ruta[ruta_num][:1]:  # Primer archivo de cada ruta
            analizar_capa_detallado(archivo)
    
    # 4. Validar todas las rutas
    print("\n📏 INICIANDO VALIDACIÓN COMPLETA...")
    todos_resultados = []
    
    rutas_para_validar = ['91', '6', '30']  # Empezar con estas rutas que sabemos existen
    
    for ruta_num in rutas_para_validar:
        if ruta_num in capas_por_ruta:
            resultados = validar_ruta_completa(ruta_num, capas_por_ruta[ruta_num], base_oficial)
            todos_resultados.extend(resultados)
        else:
            print(f"⚠️  No hay capas para RP{ruta_num}")
    
    # 5. Generar reporte
    if todos_resultados:
        generar_reporte_completo(todos_resultados)
    else:
        print("❌ No se pudieron validar las capas")

if __name__ == "__main__":
    main()