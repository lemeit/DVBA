"""
DVBA_Z6_DIAGNOSTICO_COMPLETO.py
===========================================================
DIAGNÓSTICO: Estado actual de todas las capas generadas
"""

import geopandas as gpd
import pandas as pd
import os
import glob
from pathlib import Path

# CONFIGURACIÓN COMPLETA DE DIRECTORIOS
CONFIG = {
    'base_path': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    'capas_generadas': [
        r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\03_CAPAS_GENERADAS",
        r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS"
    ],
    'tablas_csv': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\04_TABLAS",
    'salida_diagnostico': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\07_VALIDACION"
}

def explorar_directorios():
    """Explora todos los directorios para entender la estructura"""
    print("🔍 EXPLORANDO DIRECTORIOS...")
    
    for nombre_dir, path_dir in CONFIG.items():
        if nombre_dir != 'base_path':
            if isinstance(path_dir, list):
                for sub_dir in path_dir:
                    if os.path.exists(sub_dir):
                        print(f"📁 {nombre_dir}: {sub_dir}")
                        # Contar archivos shapefile
                        shp_files = glob.glob(os.path.join(sub_dir, "**", "*.shp"), recursive=True)
                        print(f"   • Shapefiles encontrados: {len(shp_files)}")
                        if shp_files:
                            for shp in shp_files[:5]:  # Mostrar primeros 5
                                print(f"     - {os.path.basename(shp)}")
                    else:
                        print(f"❌ No existe: {sub_dir}")
            else:
                if os.path.exists(path_dir):
                    print(f"📁 {nombre_dir}: {path_dir}")
                    shp_files = glob.glob(os.path.join(path_dir, "**", "*.shp"), recursive=True)
                    print(f"   • Shapefiles encontrados: {len(shp_files)}")
                else:
                    print(f"❌ No existe: {path_dir}")

def encontrar_todas_las_rutas():
    """Encuentra TODAS las rutas en TODOS los directorios"""
    print("\n🛣️  BUSCANDO TODAS LAS RUTAS...")
    
    todos_los_shp = []
    for directorio in CONFIG['capas_generadas']:
        if os.path.exists(directorio):
            patron = os.path.join(directorio, "**", "*.shp")
            archivos = glob.glob(patron, recursive=True)
            todos_los_shp.extend(archivos)
    
    print(f"📁 Total shapefiles encontrados: {len(todos_los_shp)}")
    
    # Agrupar por ruta
    rutas_encontradas = {}
    for archivo in todos_los_shp:
        nombre = os.path.basename(archivo)
        
        # Extraer número de ruta
        if nombre.startswith('RP'):
            # Diferentes patrones: RP91, RP91_Saladillo, RP91_Segmentada, etc.
            ruta_num = nombre[2:4] if nombre[2:4].isdigit() else nombre[2:3]
            
            if ruta_num.isdigit():
                if ruta_num not in rutas_encontradas:
                    rutas_encontradas[ruta_num] = []
                rutas_encontradas[ruta_num].append({
                    'archivo': archivo,
                    'nombre': nombre,
                    'directorio': os.path.dirname(archivo)
                })
    
    print(f"🎯 Rutas encontradas: {sorted(rutas_encontradas.keys())}")
    
    # Mostrar detalle por ruta
    for ruta_num, archivos in rutas_encontradas.items():
        print(f"\n📋 RP{ruta_num}: {len(archivos)} archivos")
        for arch in archivos[:3]:  # Mostrar primeros 3
            print(f"   • {arch['nombre']}")
            print(f"     → {arch['directorio']}")
    
    return rutas_encontradas

def analizar_problemas_rp91():
    """Análisis específico de los problemas con RP91"""
    print("\n🔧 ANALIZANDO PROBLEMAS RP91...")
    
    # Buscar todas las capas de RP91
    patron_rp91 = os.path.join(CONFIG['capas_generadas'][0], "**", "*RP91*", "*.shp")
    archivos_rp91 = glob.glob(patron_rp91, recursive=True)
    
    if not archivos_rp91:
        print("❌ No se encontraron archivos RP91")
        return
    
    for archivo in archivos_rp91:
        print(f"\n📊 ANALIZANDO: {os.path.basename(archivo)}")
        try:
            gdf = gpd.read_file(archivo)
            print(f"   • Segmentos: {len(gdf)}")
            print(f"   • Campos: {list(gdf.columns)}")
            
            # Verificar partidos y longitudes
            if 'partido_codigo' in gdf.columns and 'longitud_m' in gdf.columns:
                partidos_unicos = gdf['partido_codigo'].unique()
                print(f"   • Partidos: {partidos_unicos}")
                
                for partido in partidos_unicos:
                    segmentos_partido = gdf[gdf['partido_codigo'] == partido]
                    longitudes = segmentos_partido['longitud_m'].sum()
                    print(f"     - Partido {partido}: {longitudes/1000:.2f} km ({len(segmentos_partido)} segmentos)")
            
            # Verificar geometrías
            if len(gdf) > 0:
                primera_geom = gdf.geometry.iloc[0]
                print(f"   • Tipo geometría: {primera_geom.geom_type}")
                print(f"   • Longitud primer segmento: {primera_geom.length:.2f} m")
                
        except Exception as e:
            print(f"❌ Error analizando {archivo}: {e}")

def diagnosticar_estructura_capas():
    """Diagnóstico completo de la estructura de las capas"""
    print("\n🏗️  DIAGNÓSTICO DE ESTRUCTURA DE CAPAS...")
    
    rutas = encontrar_todas_las_rutas()
    
    problemas = []
    estadisticas = []
    
    for ruta_num, archivos in rutas.items():
        print(f"\n🔍 DIAGNOSTICANDO RP{ruta_num}...")
        
        for arch_info in archivos:
            archivo = arch_info['archivo']
            try:
                gdf = gpd.read_file(archivo)
                
                # Estadísticas básicas
                stats = {
                    'ruta': f"RP{ruta_num}",
                    'archivo': os.path.basename(archivo),
                    'segmentos': len(gdf),
                    'crs': str(gdf.crs),
                    'campos': list(gdf.columns)
                }
                
                # Verificar campos críticos
                campos_criticos = ['partido_codigo', 'longitud_m', 'ruta']
                campos_faltantes = [campo for campo in campos_criticos if campo not in gdf.columns]
                
                if campos_faltantes:
                    problemas.append({
                        'ruta': f"RP{ruta_num}",
                        'archivo': os.path.basename(archivo),
                        'problema': f"Campos faltantes: {campos_faltantes}",
                        'gravedad': 'ALTA'
                    })
                    print(f"   ❌ {os.path.basename(archivo)}: Faltan campos {campos_faltantes}")
                
                # Verificar valores de partido_codigo
                if 'partido_codigo' in gdf.columns:
                    codigos_partido = gdf['partido_codigo'].unique()
                    if '000' in codigos_partido or len(codigos_partido) == 1:
                        problemas.append({
                            'ruta': f"RP{ruta_num}",
                            'archivo': os.path.basename(archivo),
                            'problema': f"Códigos de partido sospechosos: {codigos_partido}",
                            'gravedad': 'MEDIA'
                        })
                        print(f"   ⚠️  {os.path.basename(archivo)}: Códigos partido {codigos_partido}")
                
                # Verificar longitudes
                if 'longitud_m' in gdf.columns:
                    longitudes = gdf['longitud_m'].sum()
                    stats['longitud_total_km'] = longitudes / 1000
                    
                    # Verificar si longitudes son realistas
                    if longitudes > 500000:  # Más de 500 km es sospechoso
                        problemas.append({
                            'ruta': f"RP{ruta_num}",
                            'archivo': os.path.basename(archivo),
                            'problema': f"Longitud total sospechosa: {longitudes/1000:.2f} km",
                            'gravedad': 'ALTA'
                        })
                        print(f"   🚨 {os.path.basename(archivo)}: Longitud sospechosa {longitudes/1000:.2f} km")
                
                estadisticas.append(stats)
                print(f"   ✅ {os.path.basename(archivo)}: {len(gdf)} segmentos, CRS: {gdf.crs}")
                
            except Exception as e:
                problemas.append({
                    'ruta': f"RP{ruta_num}",
                    'archivo': os.path.basename(archivo),
                    'problema': f"Error carga: {e}",
                    'gravedad': 'ALTA'
                })
                print(f"   💥 {os.path.basename(archivo)}: Error {e}")
    
    # Generar reporte
    generar_reporte_diagnostico(problemas, estadisticas)
    
    return problemas, estadisticas

def generar_reporte_diagnostico(problemas, estadisticas):
    """Genera reporte de diagnóstico"""
    os.makedirs(CONFIG['salida_diagnostico'], exist_ok=True)
    
    # Reporte de problemas
    if problemas:
        df_problemas = pd.DataFrame(problemas)
        reporte_problemas = os.path.join(CONFIG['salida_diagnostico'], 'diagnostico_problemas.csv')
        df_problemas.to_csv(reporte_problemas, index=False, encoding='utf-8')
        print(f"\n📋 Reporte de problemas: {reporte_problemas}")
    
    # Reporte de estadísticas
    if estadisticas:
        df_estadisticas = pd.DataFrame(estadisticas)
        reporte_estadisticas = os.path.join(CONFIG['salida_diagnostico'], 'diagnostico_estadisticas.csv')
        df_estadisticas.to_csv(reporte_estadisticas, index=False, encoding='utf-8')
        print(f"📊 Reporte de estadísticas: {reporte_estadisticas}")
    
    # Resumen
    print(f"\n🎯 RESUMEN DIAGNÓSTICO:")
    print(f"   • Total archivos analizados: {len(estadisticas)}")
    print(f"   • Problemas encontrados: {len(problemas)}")
    print(f"   • Rutas con problemas: {len(set(p['ruta'] for p in problemas))}")

def main():
    """Función principal de diagnóstico"""
    print("=" * 70)
    print("DVBA - DIAGNÓSTICO COMPLETO DE CAPAS GENERADAS")
    print("=" * 70)
    
    # 1. Explorar directorios
    explorar_directorios()
    
    # 2. Encontrar todas las rutas
    rutas = encontrar_todas_las_rutas()
    
    # 3. Análisis específico de problemas
    analizar_problemas_rp91()
    
    # 4. Diagnóstico completo
    problemas, estadisticas = diagnosticar_estructura_capas()
    
    print(f"\n✅ DIAGNÓSTICO COMPLETADO")
    print(f"📁 Reportes guardados en: {CONFIG['salida_diagnostico']}")

if __name__ == "__main__":
    main()