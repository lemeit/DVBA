"""
DVBA_Z6_CORRECCION_UNIFICADA_ATRIBUTOS.py
===========================================================
CORRECCIÓN UNIFICADA: Limpieza y estandarización de atributos en capas existentes
DVBA - DIRECCIÓN DE VIALIDAD DE LA PROVINCIA DE BUENOS AIRES
"""

import geopandas as gpd
import pandas as pd
import os
import glob
import numpy as np

# CONFIGURACIÓN
CONFIG = {
    'capas_generadas': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\03_CAPAS_GENERADAS",
    'backup_dir': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\03_CAPAS_GENERADAS_BACKUP"
}

# DICCIONARIO OFICIAL DE PARTIDOS - NOMBRES Y CÓDIGOS ESTANDARIZADOS (CORREGIDO)
PARTIDOS_OFICIALES = {
    '034': {
        'nombre_oficial': 'General Alvear',
        'variantes': ['General Alvear', 'General_Alvear', 'Alvear', 'Gral Alvear', 'Gral. Alvear']
    },
    '041': {
        'nombre_oficial': 'General Las Heras', 
        'variantes': ['General Las Heras', 'General_Las_Heras', 'Generallasheras', 'Gral Las Heras', 'Gral. Las Heras', 'Las Heras', 'General Las Heras']  # RP6 corregido
    },
    '058': {
        'nombre_oficial': 'Las Flores',
        'variantes': ['Las Flores', 'Lasflores', 'Las_Flores']
    },
    '062': {
        'nombre_oficial': 'Lobos',
        'variantes': ['Lobos']
    },
    '075': {
        'nombre_oficial': 'Navarro',
        'variantes': ['Navarro']
    },
    '091': {
        'nombre_oficial': 'Roque Pérez',
        'variantes': ['Roque Pérez', 'Roque_Perez', 'Roqueperez', 'Roque Perez']
    },
    '093': {
        'nombre_oficial': 'Saladillo',
        'variantes': ['Saladillo']
    },
    '109': {
        'nombre_oficial': '25 de Mayo',
        'variantes': ['25 de Mayo', '25_de_Mayo', '25Demayo', 'Veinticinco_De_Mayo', 'Veinticinco de Mayo', '25 de Mayo']
    }
}

# CREAR DICCIONARIO INVERTIDO PARA BÚSQUEDA RÁPIDA
VARIANTES_A_CODIGO = {}
for codigo, datos in PARTIDOS_OFICIALES.items():
    for variante in datos['variantes']:
        VARIANTES_A_CODIGO[variante.lower()] = codigo

# METADATOS INSTITUCIONALES DVBA - ESTANDARIZADOS
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

def crear_backup(archivo):
    """Crea backup de archivo antes de modificarlo"""
    nombre_archivo = os.path.basename(archivo)
    directorio_backup = os.path.join(CONFIG['backup_dir'], os.path.dirname(archivo).split('\\')[-1])
    os.makedirs(directorio_backup, exist_ok=True)
    
    archivo_backup = os.path.join(directorio_backup, f"BACKUP_{nombre_archivo}")
    
    # Copiar archivo y todos sus componentes
    import shutil
    for extension in ['.shp', '.shx', '.dbf', '.prj', '.cpg']:
        archivo_original = archivo.replace('.shp', extension)
        if os.path.exists(archivo_original):
            shutil.copy2(archivo_original, archivo_backup.replace('.shp', extension))
    
    return archivo_backup

def normalizar_nombre_partido(nombre_crudo):
    """Normaliza nombres de partidos a formato oficial"""
    if pd.isna(nombre_crudo) or nombre_crudo == '':
        return None
    
    nombre_str = str(nombre_crudo).strip()
    nombre_lower = nombre_str.lower()
    
    # Buscar en variantes
    for variante, codigo in VARIANTES_A_CODIGO.items():
        if variante in nombre_lower:
            return PARTIDOS_OFICIALES[codigo]['nombre_oficial']
    
    # Búsquedas específicas comunes
    if 'alvear' in nombre_lower and 'las heras' not in nombre_lower:
        return 'General Alvear'
    elif 'heras' in nombre_lower or 'las heras' in nombre_lower:
        return 'General Las Heras'
    elif '25' in nombre_lower or 'veinticinco' in nombre_lower:
        return '25 de Mayo'
    elif 'flores' in nombre_lower:
        return 'Las Flores'
    elif 'roque' in nombre_lower:
        return 'Roque Pérez'
    elif 'lobos' in nombre_lower:
        return 'Lobos'
    elif 'navarro' in nombre_lower:
        return 'Navarro'
    elif 'saladillo' in nombre_lower:
        return 'Saladillo'
    
    return nombre_str  # Devolver original si no se encuentra

def obtener_codigo_partido(nombre_normalizado):
    """Obtiene código de partido desde nombre normalizado"""
    if pd.isna(nombre_normalizado):
        return None
    
    for codigo, datos in PARTIDOS_OFICIALES.items():
        if nombre_normalizado.lower() == datos['nombre_oficial'].lower():
            return codigo
    
    return None

def detectar_partido_desde_archivo(nombre_archivo):
    """Detecta partido desde el nombre del archivo"""
    nombre_sin_ext = os.path.splitext(nombre_archivo)[0].lower()
    
    # Búsqueda específica para casos conocidos
    if 'rp6' in nombre_sin_ext and ('heras' in nombre_sin_ext or 'lasheras' in nombre_sin_ext):
        return 'General Las Heras', '041'
    
    for variante, codigo in VARIANTES_A_CODIGO.items():
        if variante in nombre_sin_ext:
            return PARTIDOS_OFICIALES[codigo]['nombre_oficial'], codigo
    
    return None, None

def limpiar_y_estandarizar_atributos(gdf, nombre_archivo):
    """Limpia y estandariza todos los atributos de la capa"""
    
    # 1. DETECTAR PARTIDO PRINCIPAL
    partido_principal_nombre, partido_principal_codigo = detectar_partido_desde_archivo(nombre_archivo)
    
    print(f"    🎯 Partido detectado: {partido_principal_nombre} ({partido_principal_codigo})")
    
    # 2. NORMALIZAR CAMPOS EXISTENTES DE PARTIDO
    campos_partido = ['partido_no', 'partido_nombre', 'partido', 'nombre_partido', 'partido_name']
    campos_existentes = [campo for campo in campos_partido if campo in gdf.columns]
    
    if campos_existentes:
        campo_principal = campos_existentes[0]
        print(f"    📝 Normalizando campo: {campo_principal}")
        
        # Normalizar todos los valores del campo
        gdf['partido_nombre_normalizado'] = gdf[campo_principal].apply(normalizar_nombre_partido)
        
        # Si hay un partido principal detectado, usar ese para consistencia
        if partido_principal_nombre:
            gdf['partido_nombre_normalizado'] = partido_principal_nombre
    else:
        # Si no hay campos de partido, crear uno
        if partido_principal_nombre:
            gdf['partido_nombre_normalizado'] = partido_principal_nombre
        else:
            gdf['partido_nombre_normalizado'] = 'Partido No Identificado'
    
    # 3. ASIGNAR CÓDIGO DE PARTIDO
    if partido_principal_codigo:
        gdf['partido_codigo'] = partido_principal_codigo
    else:
        gdf['partido_codigo'] = gdf['partido_nombre_normalizado'].apply(obtener_codigo_partido)
    
    # 4. CORREGIR CAMPOS DE LONGITUD
    if 'longitud_m' not in gdf.columns or gdf['longitud_m'].isna().all():
        print("    📏 Calculando longitudes desde geometrías...")
        gdf['longitud_m'] = gdf.geometry.length.round(2)
    
    # Recalcular si hay valores sospechosos
    longitudes_invalidas = gdf['longitud_m'].isna() | (gdf['longitud_m'] <= 0) | (gdf['longitud_m'] > 100000)
    if longitudes_invalidas.any():
        print(f"    🔧 Corrigiendo {longitudes_invalidas.sum()} longitudes inválidas...")
        gdf.loc[longitudes_invalidas, 'longitud_m'] = gdf.loc[longitudes_invalidas].geometry.length.round(2)
    
    # Calcular kilómetros
    gdf['longitud_km'] = (gdf['longitud_m'] / 1000).round(3)
    
    # 5. LIMPIAR CAMPOS REDUNDANTES
    campos_a_eliminar = []
    for campo in gdf.columns:
        if any(palabra in campo.lower() for palabra in ['partido_co', 'partido_no', 'info_parti', 'meta_']):
            if campo not in ['partido_codigo', 'partido_nombre_normalizado']:
                campos_a_eliminar.append(campo)
    
    if campos_a_eliminar:
        print(f"    🧹 Eliminando campos redundantes: {campos_a_eliminar}")
        gdf = gdf.drop(columns=campos_a_eliminar)
    
    # 6. ESTANDARIZAR NOMBRES DE CAMPOS FINALES
    gdf = gdf.rename(columns={
        'partido_nombre_normalizado': 'partido_nombre'
    })
    
    # 7. AGREGAR INFORMACIÓN DE RUTA
    if 'ruta' not in gdf.columns:
        # Extraer de nombre de archivo
        if nombre_archivo.startswith('RP'):
            ruta_num = nombre_archivo[2:4] if nombre_archivo[2:4].isdigit() else nombre_archivo[2:3]
            gdf['ruta'] = f"RP{ruta_num}"
    
    # 8. AGREGAR IDENTIFICADOR DE SEGMENTO
    if 'segmento_id' not in gdf.columns:
        ruta = gdf['ruta'].iloc[0] if 'ruta' in gdf.columns else 'RPXX'
        partido_cod = gdf['partido_codigo'].iloc[0] if 'partido_codigo' in gdf.columns else '000'
        gdf['segmento_id'] = [f"{ruta}_{partido_cod}_{i:03d}" for i in range(len(gdf))]
    
    # 9. AGREGAR METADATOS INSTITUCIONALES ESTANDARIZADOS
    for key, value in METADATOS_DVBA.items():
        gdf[f'meta_{key}'] = value
    
    # 10. ORDENAR CAMPOS DE MANERA LÓGICA
    campos_primarios = ['segmento_id', 'ruta', 'partido_nombre', 'partido_codigo', 'longitud_m', 'longitud_km', 'geometry']
    campos_existentes = [campo for campo in gdf.columns if campo not in campos_primarios and campo != 'geometry']
    orden_campos = campos_primarios[:-1] + campos_existentes + ['geometry']
    
    gdf = gdf[orden_campos]
    
    return gdf

def procesar_capa_completa(archivo):
    """Procesa una capa completa con todas las correcciones"""
    nombre_archivo = os.path.basename(archivo)
    print(f"\n🔧 PROCESANDO: {nombre_archivo}")
    
    try:
        # Crear backup
        backup_path = crear_backup(archivo)
        print(f"    💾 Backup creado: {os.path.basename(backup_path)}")
        
        # Cargar capa
        gdf = gpd.read_file(archivo)
        print(f"    📊 Estado inicial: {len(gdf)} segmentos, {len(gdf.columns)} campos")
        
        # Aplicar todas las correcciones
        gdf_corregido = limpiar_y_estandarizar_atributos(gdf, nombre_archivo)
        
        # Verificar CRS
        if gdf_corregido.crs is None or str(gdf_corregido.crs) != 'EPSG:5347':
            gdf_corregido = gdf_corregido.to_crs('EPSG:5347')
            print("    🌍 CRS corregido a EPSG:5347")
        
        # Guardar SOBREESCRIBIENDO el archivo original
        gdf_corregido.to_file(archivo)
        
        # Estadísticas finales
        long_total = gdf_corregido['longitud_m'].sum() / 1000
        partido_nombre = gdf_corregido['partido_nombre'].iloc[0] if 'partido_nombre' in gdf_corregido.columns else 'No identificado'
        partido_codigo = gdf_corregido['partido_codigo'].iloc[0] if 'partido_codigo' in gdf_corregido.columns else '000'
        
        print(f"    ✅ CORREGIDO: {partido_nombre} ({partido_codigo})")
        print(f"    📏 {len(gdf_corregido)} segmentos, {long_total:.2f} km total")
        print(f"    🏷️  {len(gdf_corregido.columns)} campos estandarizados")
        
        return True
        
    except Exception as e:
        print(f"    ❌ ERROR: {e}")
        return False

def encontrar_todas_capas_partidos():
    """Encuentra todas las capas segmentadas por partidos"""
    print("🔍 BUSCANDO CAPAS POR PARTIDOS...")
    
    patron = os.path.join(CONFIG['capas_generadas'], "**", "*POR_PARTIDOS", "RP*.shp")
    todas_capas = glob.glob(patron, recursive=True)
    
    # Filtrar para excluir capas consolidadas
    capas_individuales = [c for c in todas_capas if 'Segmentada_Por_Partidos' not in c]
    
    print(f"📁 Encontradas {len(capas_individuales)} capas individuales por partido")
    
    # Agrupar por ruta para mostrar resumen
    rutas_encontradas = {}
    for capa in capas_individuales:
        nombre = os.path.basename(capa)
        if nombre.startswith('RP'):
            ruta_num = nombre[2:4] if nombre[2:4].isdigit() else nombre[2:3]
            if ruta_num not in rutas_encontradas:
                rutas_encontradas[ruta_num] = []
            rutas_encontradas[ruta_num].append(capa)
    
    print(f"🛣️  Rutas encontradas: {len(rutas_encontradas)}")
    for ruta_num, archivos in rutas_encontradas.items():
        print(f"   • RP{ruta_num}: {len(archivos)} capas")
    
    return capas_individuales

def generar_reporte_final():
    """Genera reporte final de la corrección"""
    print("\n📊 GENERANDO REPORTE FINAL...")
    
    # Verificar capas corregidas
    patron = os.path.join(CONFIG['capas_generadas'], "**", "*POR_PARTIDOS", "RP*.shp")
    capas_corregidas = [c for c in glob.glob(patron, recursive=True) if 'Segmentada_Por_Partidos' not in c]
    
    estadisticas = []
    for capa in capas_corregidas[:10]:  # Muestra de 10 capas
        try:
            gdf = gpd.read_file(capa)
            nombre = os.path.basename(capa)
            
            stats = {
                'archivo': nombre,
                'segmentos': len(gdf),
                'partido_nombre': gdf['partido_nombre'].iloc[0] if 'partido_nombre' in gdf.columns else 'N/A',
                'partido_codigo': gdf['partido_codigo'].iloc[0] if 'partido_codigo' in gdf.columns else 'N/A',
                'longitud_km': gdf['longitud_m'].sum() / 1000 if 'longitud_m' in gdf.columns else 0,
                'campos': len(gdf.columns)
            }
            estadisticas.append(stats)
            
        except Exception as e:
            print(f"❌ Error leyendo {capa}: {e}")
    
    if estadisticas:
        print("\n🎯 MUESTRA DE CAPAS CORREGIDAS:")
        for stats in estadisticas:
            print(f"   • {stats['archivo']}: {stats['partido_nombre']} ({stats['partido_codigo']}) - {stats['longitud_km']:.2f} km")

def main():
    """Función principal"""
    print("=" * 70)
    print("DVBA - CORRECCIÓN UNIFICADA DE ATRIBUTOS EN CAPAS")
    print("=" * 70)
    
    # Crear directorio de backup
    os.makedirs(CONFIG['backup_dir'], exist_ok=True)
    
    # 1. Encontrar todas las capas
    capas_a_corregir = encontrar_todas_capas_partidos()
    
    if not capas_a_corregir:
        print("❌ No se encontraron capas para corregir")
        return
    
    # 2. Procesar todas las capas
    print(f"\n🔧 INICIANDO CORRECCIÓN DE {len(capas_a_corregir)} CAPAS...")
    
    exitosos = 0
    for i, capa in enumerate(capas_a_corregir, 1):
        print(f"\n[{i}/{len(capas_a_corregir)}] ", end="")
        if procesar_capa_completa(capa):
            exitosos += 1
    
    # 3. Reporte final
    print(f"\n{'='*70}")
    print("🎯 CORRECCIÓN COMPLETADA")
    print(f"✅ {exitosos}/{len(capas_a_corregir)} capas corregidas exitosamente")
    print(f"💾 Backups guardados en: {CONFIG['backup_dir']}")
    
    # 4. Generar reporte de muestra
    generar_reporte_final()
    
    print(f"\n📋 TODAS LAS CAPAS AHORA TIENEN:")
    print("   • partido_nombre: Nombre oficial estandarizado")
    print("   • partido_codigo: Código oficial de 3 dígitos") 
    print("   • longitud_m: Longitud en metros precisa")
    print("   • longitud_km: Longitud en kilómetros")
    print("   • Metadatos DVBA estandarizados")
    print("   • Campos limpios y ordenados")

if __name__ == "__main__":
    main()