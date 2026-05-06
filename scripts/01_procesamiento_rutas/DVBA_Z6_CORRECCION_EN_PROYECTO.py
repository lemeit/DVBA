"""
DVBA_Z6_LIMPIEZA_Y_UNIFICACION.py
===========================================================
LIMPIEZA Y UNIFICACIÓN: Elimina campos duplicados y unifica nombres
DVBA - DIRECCIÓN DE VIALIDAD DE LA PROVINCIA DE BUENOS AIRES
"""

import geopandas as gpd
import pandas as pd
import os
import glob
import shutil

# CONFIGURACIÓN
CONFIG = {
    'proyecto': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    'backup_dir': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\07_BACKUPS"
}

# METADATOS UNIFICADOS
METADATOS_DVBA = {
    'institucion': 'Dirección de Vialidad de la Provincia de Buenos Aires',
    'departamento': 'Zona VI Saladillo - División Técnica',
    'responsable': 'Ing. Luciano Lamaita',
    'contacto': 'lulamaita@vialidad.gba.gov.ar',
    'proyecto': 'Segmentación de Rutas Provinciales por Partidos - Zona VI',
    'crs_oficial': 'EPSG:5347',
    'version': '2025.10.3.0',
    'uso': 'Uso Interno DVBA'
}

def encontrar_capas():
    """Encuentra todas las capas en el proyecto"""
    print("📁 BUSCANDO CAPAS...")
    
    patrones = [
        os.path.join(CONFIG['proyecto'], "03_CAPAS_GENERADAS", "**", "RP*_POR_PARTIDOS", "*.shp"),
        os.path.join(CONFIG['proyecto'], "05_RESULTADOS", "**", "RP*", "*.shp"),
    ]
    
    todas_capas = []
    for patron in patrones:
        try:
            capas = glob.glob(patron, recursive=True)
            for capa in capas:
                nombre = os.path.basename(capa)
                if 'Segmentada_Por_Partidos' not in nombre and capa not in todas_capas:
                    todas_capas.append(capa)
                    print(f"   ✅ {nombre}")
        except Exception as e:
            print(f"❌ Error: {e}")
    
    print(f"🎯 TOTAL: {len(todas_capas)} capas")
    return todas_capas

def crear_backup(archivo):
    """Crea backup del archivo"""
    nombre_archivo = os.path.basename(archivo)
    ruta_relativa = os.path.relpath(archivo, CONFIG['proyecto'])
    directorio_relativo = os.path.dirname(ruta_relativa)
    
    backup_final_dir = os.path.join(CONFIG['backup_dir'], directorio_relativo)
    os.makedirs(backup_final_dir, exist_ok=True)
    
    base_name = os.path.splitext(archivo)[0]
    for extension in ['.shp', '.shx', '.dbf', '.prj', '.cpg']:
        archivo_original = base_name + extension
        if os.path.exists(archivo_original):
            shutil.copy2(archivo_original, os.path.join(backup_final_dir, os.path.basename(archivo_original)))
    
    return os.path.join(backup_final_dir, nombre_archivo)

def analizar_duplicados(gdf):
    """Analiza campos duplicados y sus valores"""
    print("   🔍 ANALIZANDO CAMPOS DUPLICADOS...")
    
    # Agrupar campos por tipo
    campos_por_tipo = {}
    
    for campo in gdf.columns:
        if campo == 'geometry':
            continue
            
        # Determinar tipo de campo por nombre y valores
        valores_unicos = gdf[campo].dropna().unique()
        
        if any(x in campo.lower() for x in ['segmento', 'segmen']):
            tipo = 'segmento_id'
        elif any(x in campo.lower() for x in ['partido_no', 'partido_n', 'partido__']):
            tipo = 'partido_nombre'
        elif any(x in campo.lower() for x in ['partido_co', 'partido_c', 'partido__']):
            tipo = 'partido_codigo'
        elif any(x in campo.lower() for x in ['longitud', 'length']):
            tipo = 'longitud'
        elif any(x in campo.lower() for x in ['ruta', 'route']):
            tipo = 'ruta'
        elif campo.startswith('meta_'):
            tipo = 'metadato'
        else:
            tipo = 'otro'
        
        if tipo not in campos_por_tipo:
            campos_por_tipo[tipo] = []
        
        campos_por_tipo[tipo].append({
            'nombre': campo,
            'valores_unicos': len(valores_unicos),
            'ejemplo': valores_unicos[0] if len(valores_unicos) > 0 else 'N/A'
        })
    
    return campos_por_tipo

def seleccionar_mejor_campo(campos_del_mismo_tipo):
    """Selecciona el mejor campo de entre los duplicados"""
    if not campos_del_mismo_tipo:
        return None
    
    # Priorizar nombres estándar
    nombres_prioritarios = {
        'segmento_id': ['segmento_id', 'segmento_i'],
        'partido_nombre': ['partido_nombre', 'partido_no'],
        'partido_codigo': ['partido_codigo', 'partido_co'],
        'longitud': ['longitud_m', 'longitud_km'],
        'ruta': ['ruta']
    }
    
    for campo_info in campos_del_mismo_tipo:
        nombre = campo_info['nombre']
        
        # Buscar en nombres prioritarios
        for tipo, nombres_preferidos in nombres_prioritarios.items():
            if nombre in nombres_preferidos:
                return campo_info
    
    # Si no encuentra prioritarios, usar el que tenga más valores únicos
    return max(campos_del_mismo_tipo, key=lambda x: x['valores_unicos'])

def limpiar_y_unificar_campos(gdf, nombre_archivo):
    """Limpia campos duplicados y unifica nombres"""
    print("   🧹 LIMPIANDO CAMPOS DUPLICADOS...")
    
    # Analizar duplicados
    campos_por_tipo = analizar_duplicados(gdf)
    
    # Campos a mantener
    campos_a_mantener = ['geometry']
    campos_a_eliminar = []
    
    # Procesar cada tipo de campo
    for tipo, campos in campos_por_tipo.items():
        if tipo in ['segmento_id', 'partido_nombre', 'partido_codigo', 'longitud', 'ruta']:
            # Seleccionar el mejor campo
            mejor_campo = seleccionar_mejor_campo(campos)
            
            if mejor_campo:
                campos_a_mantener.append(mejor_campo['nombre'])
                print(f"     ✅ Manteniendo: {mejor_campo['nombre']} ({tipo})")
                
                # Marcar los demás para eliminar
                for campo_info in campos:
                    if campo_info['nombre'] != mejor_campo['nombre']:
                        campos_a_eliminar.append(campo_info['nombre'])
                        print(f"     🗑️  Eliminando: {campo_info['nombre']} (duplicado de {mejor_campo['nombre']})")
        
        elif tipo == 'metadato':
            # Mantener todos los metadatos por ahora
            for campo_info in campos:
                campos_a_mantener.append(campo_info['nombre'])
        
        else:
            # Mantener campos técnicos (rtn, typ, rst, etc.)
            for campo_info in campos:
                campos_a_mantener.append(campo_info['nombre'])
    
    # Eliminar duplicados
    gdf_limpiado = gdf[campos_a_mantener]
    
    # Renombrar campos a nombres estándar si es necesario
    mapeo_renombres = {
        'partido_no': 'partido_nombre',
        'partido_co': 'partido_codigo', 
        'longitud_k': 'longitud_km',
        'segmento_i': 'segmento_id'
    }
    
    for viejo, nuevo in mapeo_renombres.items():
        if viejo in gdf_limpiado.columns and nuevo not in gdf_limpiado.columns:
            gdf_limpiado = gdf_limpiado.rename(columns={viejo: nuevo})
            print(f"     🔄 Renombrado: {viejo} -> {nuevo}")
    
    return gdf_limpiado

def verificar_y_completar_campos(gdf, nombre_archivo):
    """Verifica y completa campos faltantes"""
    print("   ✅ VERIFICANDO CAMPOS ESENCIALES...")
    
    # Extraer información del nombre del archivo
    if nombre_archivo.startswith('RP'):
        ruta_num = nombre_archivo[2:4] if nombre_archivo[2:4].isdigit() else nombre_archivo[2:3]
    else:
        ruta_num = 'XX'
    
    # Detectar partido del nombre
    nombre_lower = nombre_archivo.lower()
    if 'alvear' in nombre_lower:
        partido_nombre, partido_codigo = 'General Alvear', '034'
    elif 'heras' in nombre_lower:
        partido_nombre, partido_codigo = 'General Las Heras', '041'
    elif 'flores' in nombre_lower:
        partido_nombre, partido_codigo = 'Las Flores', '058'
    elif 'lobos' in nombre_lower:
        partido_nombre, partido_codigo = 'Lobos', '062'
    elif 'navarro' in nombre_lower:
        partido_nombre, partido_codigo = 'Navarro', '075'
    elif 'roque' in nombre_lower:
        partido_nombre, partido_codigo = 'Roque Pérez', '091'
    elif 'saladillo' in nombre_lower:
        partido_nombre, partido_codigo = 'Saladillo', '093'
    elif '25' in nombre_lower or 'veinticinco' in nombre_lower:
        partido_nombre, partido_codigo = '25 de Mayo', '109'
    else:
        partido_nombre, partido_codigo = 'Partido No Identificado', '000'
    
    # Completar campos faltantes
    if 'ruta' not in gdf.columns:
        gdf['ruta'] = f"RP{ruta_num}"
        print(f"     ➕ Campo agregado: ruta = RP{ruta_num}")
    
    if 'partido_nombre' not in gdf.columns:
        gdf['partido_nombre'] = partido_nombre
        print(f"     ➕ Campo agregado: partido_nombre = {partido_nombre}")
    
    if 'partido_codigo' not in gdf.columns:
        gdf['partido_codigo'] = partido_codigo
        print(f"     ➕ Campo agregado: partido_codigo = {partido_codigo}")
    
    if 'longitud_m' not in gdf.columns:
        gdf['longitud_m'] = gdf.geometry.length.round(2)
        print(f"     ➕ Campo agregado: longitud_m (calculado)")
    
    if 'longitud_km' not in gdf.columns:
        gdf['longitud_km'] = (gdf['longitud_m'] / 1000).round(3)
        print(f"     ➕ Campo agregado: longitud_km (calculado)")
    
    if 'segmento_id' not in gdf.columns:
        partido_cod_actual = gdf['partido_codigo'].iloc[0] if 'partido_codigo' in gdf.columns else partido_codigo
        gdf['segmento_id'] = [f"RP{ruta_num}_{partido_cod_actual}_{i:03d}" for i in range(len(gdf))]
        print(f"     ➕ Campo agregado: segmento_id")
    
    return gdf

def limpiar_metadatos(gdf):
    """Limpia y unifica metadatos"""
    print("   📋 UNIFICANDO METADATOS...")
    
    # Eliminar metadatos existentes
    campos_meta_existentes = [col for col in gdf.columns if col.startswith('meta_')]
    if campos_meta_existentes:
        gdf = gdf.drop(columns=campos_meta_existentes)
        print(f"     🗑️  Metadatos anteriores eliminados: {len(campos_meta_existentes)} campos")
    
    # Agregar metadatos unificados
    for key, value in METADATOS_DVBA.items():
        gdf[f'meta_{key}'] = value
    
    print(f"     ✅ Metadatos unificados agregados: {len(METADATOS_DVBA)} campos")
    return gdf

def procesar_capa(archivo):
    """Procesa una capa completa"""
    nombre_archivo = os.path.basename(archivo)
    
    print(f"\n🔧 PROCESANDO: {nombre_archivo}")
    print(f"   📍 {archivo}")
    
    try:
        # Crear backup
        backup_path = crear_backup(archivo)
        print(f"   💾 Backup creado")
        
        # Cargar capa
        gdf = gpd.read_file(archivo)
        print(f"   📊 Estado inicial: {len(gdf)} segmentos, {len(gdf.columns)} campos")
        
        # 1. LIMPIAR CAMPOS DUPLICADOS
        gdf_limpio = limpiar_y_unificar_campos(gdf, nombre_archivo)
        
        # 2. VERIFICAR Y COMPLETAR CAMPOS
        gdf_completo = verificar_y_completar_campos(gdf_limpio, nombre_archivo)
        
        # 3. LIMPIAR METADATOS
        gdf_final = limpiar_metadatos(gdf_completo)
        
        # 4. ORDENAR CAMPOS
        campos_ordenados = ['segmento_id', 'ruta', 'partido_nombre', 'partido_codigo', 'longitud_m', 'longitud_km']
        otros_campos = [col for col in gdf_final.columns if col not in campos_ordenados and col != 'geometry']
        gdf_final = gdf_final[campos_ordenados + otros_campos + ['geometry']]
        
        # 5. GUARDAR
        gdf_final.to_file(archivo)
        print(f"   💾 Guardado exitoso")
        
        # 6. VERIFICAR
        gdf_verif = gpd.read_file(archivo)
        campos_finales = list(gdf_verif.columns)
        
        print(f"   ✅ Estado final: {len(gdf_verif)} segmentos, {len(campos_finales)} campos")
        print(f"   📋 Campos finales: {campos_finales}")
        
        return True
        
    except Exception as e:
        print(f"   💥 ERROR: {e}")
        return False

def main():
    """Función principal"""
    print("=" * 70)
    print("DVBA - LIMPIEZA Y UNIFICACIÓN DE CAMPOS")
    print("=" * 70)
    
    # Verificar proyecto
    if not os.path.exists(CONFIG['proyecto']):
        print(f"❌ Proyecto no encontrado: {CONFIG['proyecto']}")
        return
    
    os.makedirs(CONFIG['backup_dir'], exist_ok=True)
    
    # Encontrar capas
    capas = encontrar_capas()
    if not capas:
        print("❌ No se encontraron capas")
        return
    
    # Procesar
    print(f"\n🔧 INICIANDO LIMPIEZA DE {len(capas)} CAPAS...")
    
    exitosas = 0
    for i, capa in enumerate(capas, 1):
        print(f"\n[{i}/{len(capas)}] ", end="")
        if procesar_capa(capa):
            exitosas += 1
    
    # Resultado
    print(f"\n{'='*70}")
    print("🎯 LIMPIEZA COMPLETADA")
    print(f"✅ {exitosas}/{len(capas)} capas limpiadas exitosamente")
    print(f"💾 Backups en: {CONFIG['backup_dir']}")

if __name__ == "__main__":
    main()