"""
DVBA_Z6_CORRECCION_CAMPOS_COMPLETA.py
===========================================================
CORRECCIÓN COMPLETA: Arregla campos faltantes, datos institucionales y números de ruta
DVBA - DIRECCIÓN DE VIALIDAD DE LA PROVINCIA DE BUENOS AIRES
"""

import geopandas as gpd
import pandas as pd
import os
import glob
import shutil
import re

# CONFIGURACIÓN MULTIDISCO
CONFIG = {
    'discos': [
        r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
        r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    ],
    'backup_dir': r"C:\DVBA_BACKUP_CAMPOS_CORREGIDOS",
    'salida_corregidas': r"C:\DVBA_CAPAS_CAMPOS_CORREGIDOS"
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

# METADATOS INSTITUCIONALES DVBA - ÚNICOS Y CORRECTOS
METADATOS_DVBA = {
    'institucion': 'Dirección de Vialidad de la Provincia de Buenos Aires',
    'departamento': 'Zona VI Saladillo - División Técnica',
    'responsable': 'Ing. Luciano Lamaita',
    'contacto': 'lulamaita@vialidad.gba.gov.ar',
    'proyecto': 'Segmentación de Rutas Provinciales por Partidos - Zona VI',
    'crs_oficial': 'EPSG:5347',
    'version': '2025.10.3.0',
    'uso': 'Uso Interno DVBA',
    'fuente': 'Base Oficial DVBA - Departamento Zonal VI',
    'fecha_actualizacion': '2025-10-23',
    'codigo_proyecto': 'DVBA-Z6-REDES-VIALES-001'
}

def explorar_discos():
    """Explora todos los discos configurados"""
    print("🔍 EXPLORANDO DISCOS...")
    
    proyectos_encontrados = []
    
    for disco in CONFIG['discos']:
        if os.path.exists(disco):
            print(f"✅ Disco accesible: {disco}")
            proyectos_encontrados.append(disco)
        else:
            print(f"❌ Disco no accesible: {disco}")
    
    return proyectos_encontrados

def encontrar_capas_recientes(proyectos):
    """Encuentra capas generadas recientemente"""
    print(f"\n📁 BUSCANDO CAPAS EN {len(proyectos)} PROYECTOS...")
    
    todas_las_capas = []
    
    for proyecto in proyectos:
        print(f"\n🔍 Explorando: {proyecto}")
        
        # Buscar en carpetas de capas generadas y resultados
        patrones = [
            os.path.join(proyecto, "03_CAPAS_GENERADAS", "**", "RP*_POR_PARTIDOS", "*.shp"),
            os.path.join(proyecto, "03_CAPAS_GENERADAS_CORREGIDAS", "**", "RP*_POR_PARTIDOS", "*.shp"),
            os.path.join(proyecto, "05_RESULTADOS", "**", "RP*", "*.shp"),
        ]
        
        capas_en_proyecto = 0
        for patron in patrones:
            try:
                capas = glob.glob(patron, recursive=True)
                for capa in capas:
                    nombre_capa = os.path.basename(capa)
                    # Solo capas individuales por partido
                    if ('Segmentada_Por_Partidos' not in nombre_capa and 
                        'consolidada' not in nombre_capa.lower() and
                        capa not in todas_las_capas):
                        todas_las_capas.append(capa)
                        capas_en_proyecto += 1
            except Exception as e:
                print(f"   ❌ Error en patrón {patron}: {e}")
        
        if capas_en_proyecto > 0:
            print(f"   📊 Encontradas: {capas_en_proyecto} capas")
    
    print(f"\n🎯 TOTAL CAPAS ENCONTRADAS: {len(todas_las_capas)}")
    return todas_las_capas

def extraer_numero_ruta(nombre_archivo):
    """Extrae el número de ruta del nombre del archivo de manera robusta"""
    # Patrones para extraer número de ruta
    patrones = [
        r'RP(\d{1,3})_',  # RP6_, RP91_
        r'RP(\d{1,3})\.',  # RP6.shp, RP91.shp
        r'^RP(\d{1,3})',   # RP6Saladillo.shp
    ]
    
    for patron in patrones:
        match = re.search(patron, nombre_archivo)
        if match:
            return match.group(1)
    
    # Si no encuentra con patrones, buscar manualmente
    if nombre_archivo.startswith('RP'):
        # Extraer los primeros dígitos después de "RP"
        digitos = ''
        for char in nombre_archivo[2:]:
            if char.isdigit():
                digitos += char
            else:
                break
        if digitos:
            return digitos
    
    return 'XX'  # Valor por defecto si no se puede determinar

def detectar_partido_desde_nombre(nombre_archivo):
    """Detecta partido desde el nombre del archivo de manera robusta"""
    nombre_lower = nombre_archivo.lower()
    
    # Mapeo mejorado de patrones
    patrones = {
        'alvear': ('034', 'General Alvear'),
        'heras': ('041', 'General Las Heras'),
        'flores': ('058', 'Las Flores'), 
        'lobos': ('062', 'Lobos'),
        'navarro': ('075', 'Navarro'),
        'roque': ('091', 'Roque Pérez'),
        'saladillo': ('093', 'Saladillo'),
        '25': ('109', '25 de Mayo'),
        'veinticinco': ('109', '25 de Mayo'),
        '25demayo': ('109', '25 de Mayo'),
        '25_de_mayo': ('109', '25 de Mayo'),
    }
    
    for patron, (codigo, nombre) in patrones.items():
        if patron in nombre_lower:
            return nombre, codigo
    
    return 'Partido No Identificado', '000'

def limpiar_metadatos_repetidos(gdf):
    """Limpia metadatos repetidos y asegura valores únicos"""
    # Lista de campos meta que deben tener valores únicos
    campos_meta = [col for col in gdf.columns if col.startswith('meta_')]
    
    for campo in campos_meta:
        if campo in METADATOS_DVBA:
            # Asignar valor único del diccionario
            valor_unico = METADATOS_DVBA[campo.replace('meta_', '')]
            gdf[campo] = valor_unico
    
    return gdf

def corregir_campo_ruta(gdf, nombre_archivo):
    """Corrige el campo ruta con el número correcto"""
    numero_ruta = extraer_numero_ruta(nombre_archivo)
    gdf['ruta'] = f"RP{numero_ruta}"
    return gdf, numero_ruta

def verificar_y_corregir_campos_esenciales(gdf, nombre_archivo):
    """Verifica y corrige todos los campos esenciales"""
    print(f"   🔍 VERIFICANDO CAMPOS...")
    
    # 1. CORREGIR CAMPO RUTA
    gdf, numero_ruta = corregir_campo_ruta(gdf, nombre_archivo)
    print(f"   🛣️  Ruta corregida: RP{numero_ruta}")
    
    # 2. DETECTAR Y CORREGIR PARTIDO
    partido_nombre, partido_codigo = detectar_partido_desde_nombre(nombre_archivo)
    
    # Verificar si los campos de partido existen y tienen valores correctos
    if 'partido_nombre' not in gdf.columns:
        gdf['partido_nombre'] = partido_nombre
        print(f"   🏷️  partido_nombre CREADO: {partido_nombre}")
    else:
        # Verificar si el valor actual es correcto
        valor_actual = gdf['partido_nombre'].iloc[0]
        if valor_actual != partido_nombre:
            gdf['partido_nombre'] = partido_nombre
            print(f"   🔧 partido_nombre CORREGIDO: {valor_actual} -> {partido_nombre}")
    
    if 'partido_codigo' not in gdf.columns:
        gdf['partido_codigo'] = partido_codigo
        print(f"   🔢 partido_codigo CREADO: {partido_codigo}")
    else:
        valor_actual = gdf['partido_codigo'].iloc[0]
        if valor_actual != partido_codigo:
            gdf['partido_codigo'] = partido_codigo
            print(f"   🔧 partido_codigo CORREGIDO: {valor_actual} -> {partido_codigo}")
    
    # 3. VERIFICAR LONGITUDES
    if 'longitud_m' not in gdf.columns:
        gdf['longitud_m'] = gdf.geometry.length.round(2)
        print(f"   📏 longitud_m CREADO")
    elif gdf['longitud_m'].isna().any():
        gdf['longitud_m'] = gdf.geometry.length.round(2)
        print(f"   📏 longitud_m RECALCULADO (valores nulos)")
    
    if 'longitud_km' not in gdf.columns:
        gdf['longitud_km'] = (gdf['longitud_m'] / 1000).round(3)
        print(f"   📐 longitud_km CREADO")
    
    # 4. VERIFICAR SEGMENTO_ID
    if 'segmento_id' not in gdf.columns:
        gdf['segmento_id'] = [f"RP{numero_ruta}_{partido_codigo}_{i:03d}" for i in range(len(gdf))]
        print(f"   🆔 segmento_id CREADO")
    
    # 5. LIMPIAR METADATOS REPETIDOS
    gdf = limpiar_metadatos_repetidos(gdf)
    print(f"   🧹 Metadatos limpiados y unificados")
    
    return gdf, numero_ruta, partido_nombre, partido_codigo

def eliminar_campos_problematicos(gdf):
    """Elimina campos problemáticos o duplicados"""
    campos_a_eliminar = []
    
    for campo in gdf.columns:
        campo_lower = campo.lower()
        
        # Eliminar campos duplicados o problemáticos
        if any(palabra in campo_lower for palabra in [
            'partido_no', 'partido_co', 'partido_nombre_normalizado',
            'meta_meta', 'institucion', 'departamento', 'responsable'  # Campos duplicados
        ]):
            # Pero no eliminar los campos esenciales que vamos a usar
            if not campo_lower.startswith('meta_') or campo in ['meta_institucion', 'meta_departamento', 'meta_responsable']:
                continue
            campos_a_eliminar.append(campo)
        
        # Eliminar campos meta duplicados (si hay múltiples versiones)
        if campo_lower.startswith('meta_') and campo != 'meta_institucion':
            # Verificar si es un duplicado
            if f"meta_{campo_lower.replace('meta_', '')}" in gdf.columns:
                campos_a_eliminar.append(campo)
    
    if campos_a_eliminar:
        gdf = gdf.drop(columns=campos_a_eliminar)
        print(f"   🗑️  Campos eliminados: {campos_a_eliminar}")
    
    return gdf

def agregar_metadatos_faltantes(gdf):
    """Agrega metadatos DVBA faltantes"""
    campos_meta_actuales = [col for col in gdf.columns if col.startswith('meta_')]
    campos_meta_faltantes = []
    
    for key in METADATOS_DVBA.keys():
        campo_meta = f'meta_{key}'
        if campo_meta not in campos_meta_actuales:
            gdf[campo_meta] = METADATOS_DVBA[key]
            campos_meta_faltantes.append(campo_meta)
    
    if campos_meta_faltantes:
        print(f"   📋 Metadatos agregados: {campos_meta_faltantes}")
    
    return gdf

def ordenar_campos_logicamente(gdf):
    """Ordena los campos de manera lógica"""
    # Definir orden preferido
    campos_primarios = ['segmento_id', 'ruta', 'partido_nombre', 'partido_codigo', 'longitud_m', 'longitud_km']
    campos_meta = [col for col in gdf.columns if col.startswith('meta_')]
    otros_campos = [col for col in gdf.columns if col not in campos_primarios + campos_meta and col != 'geometry']
    
    # Orden final
    orden_final = campos_primarios + otros_campos + campos_meta + ['geometry']
    
    # Solo mantener campos que existen
    orden_final = [campo for campo in orden_final if campo in gdf.columns]
    
    return gdf[orden_final]

def crear_backup_seguro(archivo):
    """Crea backup seguro del archivo"""
    nombre_archivo = os.path.basename(archivo)
    directorio_origen = os.path.dirname(archivo)
    nombre_directorio = os.path.basename(directorio_origen)
    
    directorio_backup = os.path.join(CONFIG['backup_dir'], nombre_directorio)
    os.makedirs(directorio_backup, exist_ok=True)
    
    # Copiar todos los archivos relacionados
    base_name = os.path.splitext(archivo)[0]
    for extension in ['.shp', '.shx', '.dbf', '.prj', '.cpg']:
        archivo_original = base_name + extension
        if os.path.exists(archivo_original):
            shutil.copy2(archivo_original, os.path.join(directorio_backup, os.path.basename(archivo_original)))
    
    return os.path.join(directorio_backup, nombre_archivo)

def corregir_capa_completa(archivo):
    """Corrección completa de una capa"""
    nombre_archivo = os.path.basename(archivo)
    
    print(f"\n🔧 PROCESANDO: {nombre_archivo}")
    print(f"   📍 Ubicación: {archivo}")
    
    try:
        # Crear backup
        backup_path = crear_backup_seguro(archivo)
        print(f"   💾 Backup creado")
        
        # Cargar capa
        gdf = gpd.read_file(archivo)
        print(f"   📊 Estado inicial: {len(gdf)} segmentos, {len(gdf.columns)} campos")
        
        # Mostrar campos problemáticos actuales
        campos_actuales = list(gdf.columns)
        print(f"   📋 Campos actuales: {campos_actuales}")
        
        # 1. ELIMINAR CAMPOS PROBLEMÁTICOS
        gdf = eliminar_campos_problematicos(gdf)
        
        # 2. VERIFICAR Y CORREGIR CAMPOS ESENCIALES
        gdf, numero_ruta, partido_nombre, partido_codigo = verificar_y_corregir_campos_esenciales(gdf, nombre_archivo)
        
        # 3. AGREGAR METADATOS FALTANTES
        gdf = agregar_metadatos_faltantes(gdf)
        
        # 4. ORDENAR CAMPOS
        gdf = ordenar_campos_logicamente(gdf)
        
        # 5. VERIFICAR CRS
        if gdf.crs is None or str(gdf.crs) != 'EPSG:5347':
            gdf = gdf.to_crs('EPSG:5347')
            print("   🌍 CRS corregido a EPSG:5347")
        
        # 6. GUARDAR
        gdf.to_file(archivo)
        print(f"   💾 Guardado exitoso")
        
        # 7. VERIFICACIÓN INMEDIATA
        gdf_verif = gpd.read_file(archivo)
        campos_finales = list(gdf_verif.columns)
        
        # Verificar campos críticos
        campos_criticos = ['segmento_id', 'ruta', 'partido_nombre', 'partido_codigo', 'longitud_m', 'longitud_km']
        campos_faltantes_verif = [campo for campo in campos_criticos if campo not in campos_finales]
        
        if not campos_faltantes_verif:
            ruta_verif = gdf_verif['ruta'].iloc[0]
            pn_verif = gdf_verif['partido_nombre'].iloc[0]
            pc_verif = gdf_verif['partido_codigo'].iloc[0]
            print(f"   ✅ VERIFICADO: {ruta_verif} - {pn_verif} ({pc_verif})")
            print(f"   📊 Campos finales: {len(campos_finales)}")
            return True
        else:
            print(f"   ❌ FALTAN CAMPOS: {campos_faltantes_verif}")
            return False
            
    except Exception as e:
        print(f"   💥 ERROR: {e}")
        import traceback
        print(f"   📝 Detalle: {traceback.format_exc()}")
        return False

def main():
    """Función principal - CORRECCIÓN COMPLETA DE CAMPOS"""
    print("=" * 70)
    print("DVBA - CORRECCIÓN COMPLETA DE CAMPOS")
    print("=" * 70)
    
    # Crear directorios
    os.makedirs(CONFIG['backup_dir'], exist_ok=True)
    os.makedirs(CONFIG['salida_corregidas'], exist_ok=True)
    
    # 1. EXPLORAR DISCOS
    proyectos = explorar_discos()
    if not proyectos:
        print("❌ No se encontraron proyectos válidos")
        return
    
    # 2. ENCONTRAR CAPAS
    capas = encontrar_capas_recientes(proyectos)
    if not capas:
        print("❌ No se encontraron capas para corregir")
        return
    
    # 3. PROCESAR CAPAS
    print(f"\n🔧 INICIANDO CORRECCIÓN DE {len(capas)} CAPAS...")
    
    exitosas = 0
    for i, capa in enumerate(capas, 1):
        print(f"\n[{i}/{len(capas)}] ", end="")
        if corregir_capa_completa(capa):
            exitosas += 1
    
    # 4. REPORTE FINAL
    print(f"\n{'='*70}")
    print("🎯 CORRECCIÓN COMPLETA FINALIZADA")
    print(f"✅ {exitosas}/{len(capas)} capas corregidas exitosamente")
    print(f"💾 Backups en: {CONFIG['backup_dir']}")
    
    if exitosas == len(capas):
        print("\n🎉 ¡TODAS LAS CAPAS ESTÁN CORRECTAMENTE CONFIGURADAS!")
    else:
        print(f"\n⚠️  {len(capas) - exitosas} capas necesitan revisión manual")

if __name__ == "__main__":
    main()