"""
DVBA_Z6_CORRECCION_MULTIDISCO.py
===========================================================
CORRECCIÓN MULTIDISCO: Busca en múltiples ubicaciones y corrige atributos
DVBA - DIRECCIÓN DE VIALIDAD DE LA PROVINCIA DE BUENOS AIRES
"""

import geopandas as gpd
import pandas as pd
import os
import glob
import shutil
from pathlib import Path

# CONFIGURACIÓN MULTIDISCO - TODAS LAS POSIBLES UBICACIONES
CONFIG = {
    'discos': [
        # Disco local C
        r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
        r"C:\Users\Of. Técnica Z6\Documents\QGIS FIles\Proyecto_Redes_Viales",
        r"C:\QGIS_Files\Proyecto_Redes_Viales",
        
        # OneDrive
        r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
        r"C:\Users\Of. Técnica Z6\OneDrive - Dirección de Vialidad\Documentos\QGIS FIles\Proyecto_Redes_Viales",
        
        # Google Drive
        r"G:\Mi unidad\QGIS Files\Proyecto_Redes_Viales",
        r"G:\Mi unidad\DVBA\QGIS\Proyecto_Redes_Viales",
        r"G:\Shared drives\DVBA_ZonaVI\QGIS Files\Proyecto_Redes_Viales",
        
        # Unidades de red/Discos externos
        r"D:\QGIS_Files\Proyecto_Redes_Viales",
        r"E:\DVBA\QGIS\Proyecto_Redes_Viales",
        r"F:\Proyecto_Redes_Viales",
        
        # Rutas alternativas
        r"C:\DVBA\ZonaVI\QGIS\Proyecto_Redes_Viales",
        r"C:\Proyecto_Redes_Viales",
    ],
    'backup_dir': r"C:\DVBA_BACKUP_CORRECCION",
    'salida_corregidas': r"C:\DVBA_CAPAS_CORREGIDAS"
}

# DICCIONARIO OFICIAL DE PARTIDOS
PARTIDOS_OFICIALES = {
    '034': 'General Alvear',
    '041': 'General Las Heras', 
    '058': 'Las Flores',
    '062': 'Lobos',
    '075': 'Navarro',
    '091': 'Roque Pérez',
    '093': 'Saladillo',
    '109': '25 de Mayo'
}

# METADATOS INSTITUCIONALES DVBA
METADATOS_DVBA = {
    'institucion': 'Dirección de Vialidad de la Provincia de Buenos Aires',
    'departamento': 'Zona VI Saladillo - División Técnica',
    'responsable': 'Ing. Luciano Lamaita',
    'contacto': 'lulamaita@vialidad.gba.gov.ar',
    'proyecto': 'Segmentación de Rutas Provinciales por Partidos',
    'crs_oficial': 'EPSG:5347',
    'version': '2025.10.2.0',
    'uso': 'Uso Interno DVBA',
    'fuente': 'Base Oficial DVBA - Departamento Zonal VI'
}

def explorar_discos():
    """Explora todos los discos configurados y encuentra proyectos válidos"""
    print("🔍 EXPLORANDO DISCOS CONFIGURADOS...")
    
    proyectos_encontrados = []
    
    for disco in CONFIG['discos']:
        if os.path.exists(disco):
            print(f"✅ Disco accesible: {disco}")
            
            # Buscar estructura de proyecto
            estructura_valida = verificar_estructura_proyecto(disco)
            if estructura_valida:
                proyectos_encontrados.append(disco)
                print(f"   📁 Proyecto válido encontrado")
        else:
            print(f"❌ Disco no accesible: {disco}")
    
    return proyectos_encontrados

def verificar_estructura_proyecto(ruta_base):
    """Verifica si la ruta tiene la estructura de proyecto esperada"""
    carpetas_esperadas = [
        '03_CAPAS_GENERADAS',
        '04_TABLAS', 
        '05_RESULTADOS',
        '08_SCRIPTS'
    ]
    
    for carpeta in carpetas_esperadas:
        ruta_carpeta = os.path.join(ruta_base, carpeta)
        if not os.path.exists(ruta_carpeta):
            print(f"   ⚠️  Falta carpeta: {carpeta}")
            return False
    
    return True

def encontrar_capas_multidisco(proyectos):
    """Encuentra todas las capas en todos los proyectos"""
    print(f"\n📁 BUSCANDO CAPAS EN {len(proyectos)} PROYECTOS...")
    
    todas_las_capas = []
    
    for proyecto in proyectos:
        print(f"\n🔍 Explorando: {proyecto}")
        
        # Patrones de búsqueda
        patrones = [
            os.path.join(proyecto, "**", "*POR_PARTIDOS", "RP*.shp"),
            os.path.join(proyecto, "03_CAPAS_GENERADAS", "**", "RP*", "*.shp"),
            os.path.join(proyecto, "05_RESULTADOS", "**", "RP*", "*.shp"),
        ]
        
        for patron in patrones:
            try:
                capas = glob.glob(patron, recursive=True)
                for capa in capas:
                    if 'Segmentada_Por_Partidos' not in capa and capa not in todas_las_capas:
                        todas_las_capas.append(capa)
                        print(f"   ✅ Encontrada: {os.path.basename(capa)}")
            except Exception as e:
                print(f"   ❌ Error en patrón {patron}: {e}")
    
    print(f"\n🎯 TOTAL CAPAS ENCONTRADAS: {len(todas_las_capas)}")
    return todas_las_capas

def detectar_partido_desde_nombre(nombre_archivo):
    """Detecta partido desde el nombre del archivo"""
    nombre_lower = nombre_archivo.lower()
    
    # Mapeo de patrones a códigos
    patrones = {
        'alvear': '034',
        'heras': '041',
        'flores': '058', 
        'lobos': '062',
        'navarro': '075',
        'roque': '091',
        'saladillo': '093',
        '25': '109',
        'veinticinco': '109'
    }
    
    for patron, codigo in patrones.items():
        if patron in nombre_lower:
            return PARTIDOS_OFICIALES[codigo], codigo
    
    return 'Partido No Identificado', '000'

def crear_backup_multidisco(archivo):
    """Crea backup manteniendo estructura de directorios"""
    nombre_archivo = os.path.basename(archivo)
    
    # Determinar proyecto de origen
    proyecto_origen = None
    for disco in CONFIG['discos']:
        if archivo.startswith(disco):
            proyecto_origen = disco
            break
    
    if proyecto_origen:
        # Mantener estructura relativa
        ruta_relativa = os.path.relpath(os.path.dirname(archivo), proyecto_origen)
        directorio_backup = os.path.join(CONFIG['backup_dir'], ruta_relativa)
    else:
        directorio_backup = os.path.join(CONFIG['backup_dir'], 'ORIGEN_DESCONOCIDO')
    
    os.makedirs(directorio_backup, exist_ok=True)
    
    # Copiar todos los archivos relacionados
    base_name = os.path.splitext(archivo)[0]
    for extension in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx']:
        archivo_original = base_name + extension
        if os.path.exists(archivo_original):
            shutil.copy2(archivo_original, os.path.join(directorio_backup, os.path.basename(archivo_original)))
    
    return os.path.join(directorio_backup, nombre_archivo)

def corregir_capa(archivo):
    """Corrige una capa individual"""
    nombre_archivo = os.path.basename(archivo)
    
    print(f"\n🔧 PROCESANDO: {nombre_archivo}")
    print(f"   📍 Ubicación: {archivo}")
    
    try:
        # Crear backup
        backup_path = crear_backup_multidisco(archivo)
        print(f"   💾 Backup: {backup_path}")
        
        # Cargar capa
        gdf = gpd.read_file(archivo)
        print(f"   📊 Estado: {len(gdf)} segmentos, {len(gdf.columns)} campos")
        
        # Detectar partido
        partido_nombre, partido_codigo = detectar_partido_desde_nombre(nombre_archivo)
        print(f"   🎯 Partido: {partido_nombre} ({partido_codigo})")
        
        # 1. LIMPIAR CAMPOS EXISTENTES
        campos_a_eliminar = []
        for campo in gdf.columns:
            if any(palabra in campo.lower() for palabra in ['partido_no', 'partido_co', 'partido_nombre_normalizado']):
                campos_a_eliminar.append(campo)
        
        if campos_a_eliminar:
            gdf = gdf.drop(columns=campos_a_eliminar)
            print(f"   🧹 Eliminados: {campos_a_eliminar}")
        
        # 2. CREAR CAMPOS ESTANDAR
        gdf['partido_nombre'] = partido_nombre
        gdf['partido_codigo'] = partido_codigo
        
        # 3. ACTUALIZAR LONGITUDES
        if 'longitud_m' not in gdf.columns or gdf['longitud_m'].isna().any():
            gdf['longitud_m'] = gdf.geometry.length.round(2)
            print("   📏 Longitudes calculadas")
        
        gdf['longitud_km'] = (gdf['longitud_m'] / 1000).round(3)
        
        # 4. ACTUALIZAR IDENTIFICADORES
        ruta_num = nombre_archivo[2:4] if nombre_archivo[2:4].isdigit() else nombre_archivo[2:3]
        gdf['segmento_id'] = [f"RP{ruta_num}_{partido_codigo}_{i:03d}" for i in range(len(gdf))]
        gdf['ruta'] = f"RP{ruta_num}"
        
        # 5. AGREGAR METADATOS
        for key, value in METADATOS_DVBA.items():
            gdf[f'meta_{key}'] = value
        
        # 6. ORDENAR CAMPOS
        campos_primarios = ['segmento_id', 'ruta', 'partido_nombre', 'partido_codigo', 'longitud_m', 'longitud_km']
        otros_campos = [col for col in gdf.columns if col not in campos_primarios and col != 'geometry']
        gdf = gdf[campos_primarios + otros_campos + ['geometry']]
        
        # 7. VERIFICAR CRS
        if gdf.crs is None or str(gdf.crs) != 'EPSG:5347':
            gdf = gdf.to_crs('EPSG:5347')
            print("   🌍 CRS corregido a EPSG:5347")
        
        # 8. GUARDAR
        gdf.to_file(archivo)
        print(f"   💾 Guardado: {partido_nombre} ({partido_codigo})")
        
        # 9. VERIFICAR
        gdf_verif = gpd.read_file(archivo)
        if 'partido_nombre' in gdf_verif.columns and 'partido_codigo' in gdf_verif.columns:
            print(f"   ✅ VERIFICADO: Campos correctos")
            return True
        else:
            print("   ❌ FALLÓ VERIFICACIÓN")
            return False
            
    except Exception as e:
        print(f"   💥 ERROR: {e}")
        return False

def generar_reporte_final(capas_procesadas, exitosas):
    """Genera reporte final del proceso"""
    print(f"\n{'='*70}")
    print("🎯 INFORME FINAL DE CORRECCIÓN MULTIDISCO")
    print(f"{'='*70}")
    
    print(f"📊 ESTADÍSTICAS:")
    print(f"   • Proyectos explorados: {len(CONFIG['discos'])}")
    print(f"   • Capas encontradas: {len(capas_procesadas)}")
    print(f"   • Capas corregidas: {exitosas}")
    print(f"   • Tasa de éxito: {(exitosas/len(capas_procesadas))*100:.1f}%")
    
    print(f"\n📁 UBICACIONES:")
    print(f"   • Backup: {CONFIG['backup_dir']}")
    print(f"   • Capas corregidas: En sus ubicaciones originales")
    
    # Agrupar por ruta
    rutas_procesadas = {}
    for capa in capas_procesadas:
        nombre = os.path.basename(capa)
        if nombre.startswith('RP'):
            ruta_num = nombre[2:4] if nombre[2:4].isdigit() else nombre[2:3]
            if ruta_num not in rutas_procesadas:
                rutas_procesadas[ruta_num] = 0
            rutas_procesadas[ruta_num] += 1
    
    print(f"\n🛣️  RUTAS PROCESADAS:")
    for ruta, cantidad in sorted(rutas_procesadas.items()):
        print(f"   • RP{ruta}: {cantidad} capas")

def main():
    """Función principal - CORRECCIÓN MULTIDISCO"""
    print("=" * 70)
    print("DVBA - CORRECCIÓN MULTIDISCO DE CAPAS")
    print("=" * 70)
    
    # Crear directorios de trabajo
    os.makedirs(CONFIG['backup_dir'], exist_ok=True)
    os.makedirs(CONFIG['salida_corregidas'], exist_ok=True)
    
    # 1. EXPLORAR DISCOS
    proyectos_validos = explorar_discos()
    
    if not proyectos_validos:
        print("❌ No se encontraron proyectos válidos")
        return
    
    # 2. ENCONTRAR CAPAS
    todas_capas = encontrar_capas_multidisco(proyectos_validos)
    
    if not todas_capas:
        print("❌ No se encontraron capas para corregir")
        return
    
    # 3. PROCESAR CAPAS
    print(f"\n🔧 INICIANDO CORRECCIÓN DE {len(todas_capas)} CAPAS...")
    
    exitosas = 0
    for i, capa in enumerate(todas_capas, 1):
        print(f"\n[{i}/{len(todas_capas)}] ", end="")
        if corregir_capa(capa):
            exitosas += 1
    
    # 4. REPORTE FINAL
    generar_reporte_final(todas_capas, exitosas)

if __name__ == "__main__":
    main()