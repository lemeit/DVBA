"""
DVBA_Z6_CORRECCION_MASIVA_CAPAS.py
===========================================================
CORRECCIÓN MASIVA: Campos y metadatos de capas segmentadas
"""

import geopandas as gpd
import pandas as pd
import os
import glob
from pathlib import Path

# CONFIGURACIÓN
CONFIG = {
    'capas_generadas': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\03_CAPAS_GENERADAS",
    'salida_corregida': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\03_CAPAS_GENERADAS_CORREGIDAS"
}

# DICCIONARIO DE CORRECCIÓN DE PARTIDOS
CORRECCION_PARTIDOS = {
    '25 de Mayo': '109',
    '25Demayo': '109',
    '25_de_Mayo': '109',
    'Veinticinco_De_Mayo': '109',
    'General Alvear': '034',
    'General_Alvear': '034',
    'Alvear': '034',
    'General Las Heras': '041',
    'General_Las_Heras': '041',
    'Generallasheras': '041',
    'Las Flores': '058',
    'Lasflores': '058',
    'Lobos': '062',
    'Navarro': '075',
    'Roque Pérez': '091',
    'Roqueperez': '091',
    'Saladillo': '093'
}

def corregir_campo_partido_codigo(gdf, nombre_archivo):
    """Corrige el campo partido_codigo basado en partido_no y nombre de archivo"""
    
    # Intentar obtener el nombre del partido del archivo
    nombre_sin_ext = os.path.splitext(nombre_archivo)[0]
    partido_detectado = None
    
    # Buscar en el nombre del archivo
    for nombre_partido, codigo in CORRECCION_PARTIDOS.items():
        if nombre_partido in nombre_sin_ext:
            partido_detectado = (nombre_partido, codigo)
            break
    
    # Si no se encuentra en el nombre, buscar en partido_no
    if partido_detectado is None and 'partido_no' in gdf.columns:
        partido_no_valores = gdf['partido_no'].dropna().unique()
        if len(partido_no_valores) > 0:
            partido_no = str(partido_no_valores[0])
            for nombre_partido, codigo in CORRECCION_PARTIDOS.items():
                if nombre_partido.replace('_', ' ').replace(' ', '').lower() in partido_no.replace('_', ' ').replace(' ', '').lower():
                    partido_detectado = (nombre_partido, codigo)
                    break
    
    if partido_detectado:
        nombre_partido, codigo_partido = partido_detectado
        print(f"    ✅ Detectado: {nombre_partido} -> Código: {codigo_partido}")
        
        # Corregir partido_co
        if 'partido_co' in gdf.columns:
            gdf['partido_co'] = codigo_partido
        
        # Agregar partido_codigo si no existe
        if 'partido_codigo' not in gdf.columns:
            gdf['partido_codigo'] = codigo_partido
        
        # Corregir partido_nombre si existe
        if 'partido_nombre' in gdf.columns:
            gdf['partido_nombre'] = nombre_partido.replace('_', ' ')
        elif 'partido_no' in gdf.columns:
            gdf['partido_no'] = nombre_partido.replace('_', ' ')
        
        # Agregar info_partido
        gdf['info_partido'] = f"{nombre_partido.replace('_', ' ')} ({codigo_partido})"
    
    return gdf

def corregir_geometrias_longitudes(gdf):
    """Corrige geometrías y recalcula longitudes si es necesario"""
    
    # Verificar que las geometrías sean válidas
    gdf = gdf[~gdf.geometry.is_empty]
    
    # Recalcular longitudes si es necesario
    if 'longitud_m' not in gdf.columns or gdf['longitud_m'].isna().all():
        print("    📏 Recalculando longitudes desde geometrías...")
        gdf['longitud_m'] = gdf.geometry.length.round(2)
        gdf['longitud_km'] = (gdf['longitud_m'] / 1000).round(3)
    
    # Verificar que las longitudes sean realistas
    longitudes_sospechosas = gdf[gdf['longitud_m'] > 100000]  # Más de 100 km por segmento
    if len(longitudes_sospechosas) > 0:
        print(f"    ⚠️  {len(longitudes_sospechosas)} segmentos con longitudes sospechosas")
        # Recalcular desde geometría
        gdf.loc[longitudes_sospechosas.index, 'longitud_m'] = longitudes_sospechosas.geometry.length.round(2)
        gdf.loc[longitudes_sospechosas.index, 'longitud_km'] = (longitudes_sospechosas.geometry.length / 1000).round(3)
    
    return gdf

def agregar_metadatos_dvba(gdf, ruta_num):
    """Agrega metadatos DVBA estandarizados"""
    
    metadatos = {
        'meta_institucion': 'Dirección de Vialidad de la Provincia de Buenos Aires',
        'meta_departamento': 'Zona VI Saladillo - División Técnica',
        'meta_responsable': 'Ing. Luciano Lamaita',
        'meta_contacto': 'lulamaita@vialidad.gba.gov.ar',
        'meta_proyecto': 'Segmentación de Rutas Provinciales por Partidos',
        'meta_crs': 'EPSG:5347 - POSGAR 2007',
        'meta_fecha': '2025-10-23',
        'meta_version': '2.0',
        'meta_uso': 'Uso Interno DVBA'
    }
    
    for key, value in metadatos.items():
        gdf[key] = value
    
    # Agregar información de ruta
    gdf['ruta_numero'] = ruta_num
    gdf['ruta_nombre'] = f"RP{ruta_num}"
    gdf['zona_dvba'] = 'Zona VI'
    
    return gdf

def procesar_capa_individual(archivo):
    """Procesa y corrige una capa individual"""
    nombre_archivo = os.path.basename(archivo)
    print(f"🔧 Procesando: {nombre_archivo}")
    
    try:
        # Cargar capa
        gdf = gpd.read_file(archivo)
        
        # Extraer número de ruta
        ruta_num = nombre_archivo[2:4] if nombre_archivo[2:4].isdigit() else nombre_archivo[2:3]
        
        # 1. Corregir campo partido_codigo
        gdf = corregir_campo_partido_codigo(gdf, nombre_archivo)
        
        # 2. Corregir geometrías y longitudes
        gdf = corregir_geometrias_longitudes(gdf)
        
        # 3. Agregar metadatos DVBA
        gdf = agregar_metadatos_dvba(gdf, ruta_num)
        
        # 4. Asegurar CRS correcto
        if gdf.crs is None or str(gdf.crs) != 'EPSG:5347':
            gdf = gdf.to_crs('EPSG:5347')
        
        print(f"    ✅ Corregida: {len(gdf)} segmentos")
        return gdf
        
    except Exception as e:
        print(f"    ❌ Error procesando {nombre_archivo}: {e}")
        return None

def encontrar_capas_por_partidos():
    """Encuentra las capas segmentadas por partidos"""
    patron = os.path.join(CONFIG['capas_generadas'], "**", "*POR_PARTIDOS", "*.shp")
    archivos = glob.glob(patron, recursive=True)
    
    # Filtrar solo las capas individuales por partido (no las consolidadas)
    capas_individuales = []
    for archivo in archivos:
        nombre = os.path.basename(archivo)
        # Excluir capas consolidadas
        if not any(x in nombre for x in ['Segmentada_Por_Partidos', 'consolidada', 'CONSOLIDADA']):
            capas_individuales.append(archivo)
    
    print(f"📁 Encontradas {len(capas_individuales)} capas individuales por partido")
    return capas_individuales

def crear_capas_consolidadas_corregidas():
    """Crea nuevas capas consolidadas corregidas"""
    print("\n🔄 CREANDO CAPAS CONSOLIDADAS CORREGIDAS...")
    
    # Encontrar todas las rutas
    patron_rutas = os.path.join(CONFIG['capas_generadas'], "**", "RP*_POR_PARTIDOS")
    carpetas_rutas = glob.glob(patron_rutas, recursive=True)
    
    for carpeta_ruta in carpetas_rutas:
        ruta_num = os.path.basename(carpeta_ruta).replace('RP', '').replace('_POR_PARTIDOS', '')
        print(f"\n🛣️  Procesando RP{ruta_num}...")
        
        # Encontrar todas las capas individuales de esta ruta
        capas_ruta = glob.glob(os.path.join(carpeta_ruta, "RP*.shp"))
        capas_individuales = [c for c in capas_ruta if 'Segmentada_Por_Partidos' not in c]
        
        if not capas_individuales:
            print(f"   ⚠️  No hay capas individuales para RP{ruta_num}")
            continue
        
        # Procesar y unificar todas las capas individuales
        todas_capas = []
        for archivo in capas_individuales:
            gdf_corregido = procesar_capa_individual(archivo)
            if gdf_corregido is not None:
                todas_capas.append(gdf_corregido)
        
        if todas_capas:
            # Unificar todas las capas
            gdf_consolidado = gpd.GeoDataFrame(pd.concat(todas_capas, ignore_index=True))
            
            # Crear directorio de salida
            salida_ruta = os.path.join(CONFIG['salida_corregida'], f"RP{ruta_num}_POR_PARTIDOS")
            os.makedirs(salida_ruta, exist_ok=True)
            
            # Guardar capa consolidada
            output_consolidado = os.path.join(salida_ruta, f"RP{ruta_num}_Segmentada_Por_Partidos_CORREGIDA.shp")
            gdf_consolidado.to_file(output_consolidado)
            
            # Guardar capas individuales corregidas
            for gdf_individual in todas_capas:
                if 'partido_codigo' in gdf_individual.columns:
                    partidos_unicos = gdf_individual['partido_codigo'].unique()
                    if len(partidos_unicos) == 1:
                        partido_cod = partidos_unicos[0]
                        partido_nombre = gdf_individual['partido_no'].iloc[0] if 'partido_no' in gdf_individual.columns else f"Partido_{partido_cod}"
                        nombre_limpio = partido_nombre.replace(' ', '_').replace('/', '_')
                        output_individual = os.path.join(salida_ruta, f"RP{ruta_num}_{nombre_limpio}_CORREGIDO.shp")
                        gdf_individual.to_file(output_individual)
            
            print(f"   ✅ RP{ruta_num}: {len(todas_capas)} partidos, {len(gdf_consolidado)} segmentos total")
            
            # Estadísticas
            long_total = gdf_consolidado['longitud_m'].sum() / 1000
            print(f"   📏 Longitud total: {long_total:.2f} km")

def main():
    """Función principal"""
    print("=" * 70)
    print("DVBA - CORRECCIÓN MASIVA DE CAPAS SEGMENTADAS")
    print("=" * 70)
    
    # Crear directorio de salida
    os.makedirs(CONFIG['salida_corregida'], exist_ok=True)
    
    # 1. Encontrar y corregir capas individuales
    print("🔍 BUSCANDO CAPAS INDIVIDUALES POR PARTIDO...")
    capas_individuales = encontrar_capas_por_partidos()
    
    print(f"\n🔧 CORRIGIENDO {len(capas_individuales)} CAPAS INDIVIDUALES...")
    for archivo in capas_individuales[:10]:  # Procesar primeras 10 para prueba
        procesar_capa_individual(archivo)
    
    # 2. Crear capas consolidadas corregidas
    crear_capas_consolidadas_corregidas()
    
    print(f"\n✅ CORRECCIÓN COMPLETADA")
    print(f"📁 Capas corregidas en: {CONFIG['salida_corregida']}")

if __name__ == "__main__":
    main()