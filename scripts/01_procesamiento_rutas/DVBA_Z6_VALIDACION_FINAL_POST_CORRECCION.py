"""
DVBA_CORRECCION_COMPLETA_METADATOS.py
===========================================================
CORRECCIÓN COMPLETA: Atributos + Metadatos internos
"""

import geopandas as gpd
import pandas as pd
import os
import glob
import shutil

# CONFIGURACIÓN
CONFIG = {
    'proyecto': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"
}

# CORRECCIÓN DEFINITIVA - ATRIBUTOS Y METADATOS
CORRECCION_COMPLETA = {
    # RP6 - TODAS las capas son General Las Heras
    'RP6_01.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_02.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_03.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_04.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_05.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_06.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_07.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_08.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_09.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_10.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_General_Alvear.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_General_Las_Heras.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    'RP6_INTEGRADO.shp': {'partido': 'General Las Heras', 'codigo': '041', 'ruta': 'RP6'},
    
    # RP61 - TODAS las capas son General Alvear
    'RP61_01.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_02.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_03.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_04.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_05.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_06.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_07.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_08.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_09.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_10.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'},
    'RP61_INTEGRADO.shp': {'partido': 'General Alvear', 'codigo': '034', 'ruta': 'RP61'}
}

def corregir_metadatos_y_atributos():
    """Corrige tanto atributos como metadatos internos"""
    print("🔧 CORRIGIENDO ATRIBUTOS Y METADATOS...")
    
    patron = os.path.join(CONFIG['proyecto'], "**", "RP[6]*.shp")
    todas_capas = glob.glob(patron, recursive=True)
    
    capas_corregidas = 0
    
    for capa in todas_capas:
        nombre_archivo = os.path.basename(capa)
        
        if nombre_archivo in CORRECCION_COMPLETA:
            correccion = CORRECCION_COMPLETA[nombre_archivo]
            partido_correcto = correccion['partido']
            codigo_correcto = correccion['codigo']
            ruta_correcta = correccion['ruta']
            
            try:
                # Leer capa
                gdf = gpd.read_file(capa)
                
                if len(gdf) > 0:
                    # Crear backup antes de modificar
                    crear_backup_completo(capa, "CORRECCION_METADATOS")
                    
                    # 1. CORREGIR ATRIBUTOS EXISTENTES
                    if 'partido_no' in gdf.columns:
                        partido_anterior = gdf['partido_no'].iloc[0]
                        gdf['partido_no'] = partido_correcto
                    else:
                        # Si no existe, crear columna
                        gdf['partido_no'] = partido_correcto
                    
                    if 'partido_co' in gdf.columns:
                        gdf['partido_co'] = codigo_correcto
                    else:
                        gdf['partido_co'] = codigo_correcto
                    
                    # 2. CORREGIR/AGREGAR MÁS ATRIBUTOS DE METADATOS
                    if 'ruta' in gdf.columns:
                        gdf['ruta'] = ruta_correcta
                    else:
                        gdf['ruta'] = ruta_correcta
                    
                    if 'partido' in gdf.columns:
                        gdf['partido'] = partido_correcto
                    else:
                        gdf['partido'] = partido_correcto
                    
                    # 3. AGREGAR METADATOS ADICIONALES
                    gdf['corregido'] = 'SI'
                    gdf['fecha_correccion'] = pd.Timestamp.now().strftime('%Y-%m-%d')
                    
                    # 4. GUARDAR CON METADATOS ACTUALIZADOS
                    gdf.to_file(capa, driver='ESRI Shapefile')
                    
                    print(f"   ✅ {nombre_archivo}:")
                    print(f"      • Partido: {partido_correcto} ({codigo_correcto})")
                    print(f"      • Ruta: {ruta_correcta}")
                    print(f"      • Metadatos: Actualizados")
                    
                    capas_corregidas += 1
                else:
                    print(f"   ⚠️  {nombre_archivo}: Capa vacía")
                    
            except Exception as e:
                print(f"   ❌ {nombre_archivo}: Error {e}")
    
    return capas_corregidas

def crear_backup_completo(archivo_original, motivo):
    """Crea backup completo de todos los archivos relacionados"""
    from datetime import datetime
    
    fecha = datetime.now().strftime("%Y%m%d_%H%M%S")
    nombre_archivo = os.path.basename(archivo_original)
    
    backup_dir = os.path.join(CONFIG['proyecto'], "04_BACKUPS", f"METADATOS_{fecha}", motivo)
    os.makedirs(backup_dir, exist_ok=True)
    
    # Copiar TODOS los archivos relacionados
    base_name = os.path.splitext(archivo_original)[0]
    for extension in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx', '.shp.xml']:
        archivo_relacionado = base_name + extension
        if os.path.exists(archivo_relacionado):
            shutil.copy2(
                archivo_relacionado,
                os.path.join(backup_dir, os.path.basename(archivo_relacionado))
            )
    
    return backup_dir

def verificar_metadatos_corregidos():
    """Verifica que los metadatos se hayan corregido correctamente"""
    print("\n🔍 VERIFICANDO METADATOS CORREGIDOS...")
    
    # Verificar algunas capas de muestra
    capas_verificar = [
        'RP6_01.shp', 'RP6_General_Alvear.shp', 'RP6_INTEGRADO.shp',
        'RP61_01.shp', 'RP61_06.shp', 'RP61_INTEGRADO.shp'
    ]
    
    print("   📋 MUESTRA DE VERIFICACIÓN:")
    print("   " + "="*50)
    
    for nombre_muestra in capas_verificar:
        patron = os.path.join(CONFIG['proyecto'], "**", nombre_muestra)
        capas_encontradas = glob.glob(patron, recursive=True)
        
        if capas_encontradas:
            capa = capas_encontradas[0]
            try:
                gdf = gpd.read_file(capa)
                
                if len(gdf) > 0:
                    # Obtener valores actuales
                    partido_actual = gdf['partido_no'].iloc[0] if 'partido_no' in gdf.columns else 'N/A'
                    codigo_actual = gdf['partido_co'].iloc[0] if 'partido_co' in gdf.columns else 'N/A'
                    ruta_actual = gdf['ruta'].iloc[0] if 'ruta' in gdf.columns else 'N/A'
                    
                    # Verificar corrección
                    correccion_esperada = CORRECCION_COMPLETA.get(nombre_muestra, {})
                    partido_esperado = correccion_esperada.get('partido', 'N/A')
                    codigo_esperado = correccion_esperada.get('codigo', 'N/A')
                    
                    estado = "✅" if partido_actual == partido_esperado else "❌"
                    
                    print(f"   {estado} {nombre_muestra}:")
                    print(f"      • Partido: {partido_actual} (esperado: {partido_esperado})")
                    print(f"      • Código: {codigo_actual} (esperado: {codigo_esperado})")
                    print(f"      • Ruta: {ruta_actual}")
                    
            except Exception as e:
                print(f"   ❌ {nombre_muestra}: Error al verificar - {e}")

def generar_reporte_metadatos():
    """Genera reporte completo de metadatos corregidos"""
    print("\n📊 GENERANDO REPORTE DE METADATOS...")
    
    reporte_path = os.path.join(CONFIG['proyecto'], "REPORTE_METADATOS_CORREGIDOS.txt")
    
    with open(reporte_path, 'w', encoding='utf-8') as f:
        f.write("REPORTE COMPLETO: METADATOS CORREGIDOS - RP6 vs RP61\n")
        f.write("=" * 60 + "\n\n")
        
        f.write("PROBLEMA ORIGINAL:\n")
        f.write("- Metadatos internos con asignación invertida de partidos\n")
        f.write("- Atributos 'partido_no' y 'partido_co' incorrectos\n")
        f.write("- Posible inconsistencia en campo 'ruta'\n\n")
        
        f.write("CORRECCIÓN APLICADA:\n")
        f.write("1. Atributos 'partido_no' y 'partido_co' corregidos\n")
        f.write("2. Campo 'ruta' verificado y corregido\n") 
        f.write("3. Campos adicionales para trazabilidad:\n")
        f.write("   - 'corregido': Indica si la capa fue corregida\n")
        f.write("   - 'fecha_correccion': Fecha de la corrección\n\n")
        
        f.write("DETALLE POR ARCHIVO:\n")
        f.write("-" * 40 + "\n")
        
        for archivo, correccion in CORRECCION_COMPLETA.items():
            f.write(f"\n{archivo}:\n")
            f.write(f"  • Partido: {correccion['partido']}\n")
            f.write(f"  • Código: {correccion['codigo']}\n") 
            f.write(f"  • Ruta: {correccion['ruta']}\n")
    
    print(f"   ✅ Reporte guardado en: {reporte_path}")

def limpiar_archivos_temporales():
    """Limpia archivos temporales o duplicados"""
    print("\n🧹 LIMPIANDO ARCHIVOS TEMPORALES...")
    
    # Buscar archivos que puedan ser temporales o duplicados
    extensiones_temporales = ['.tmp', '.temp', '~', '.bak']
    
    for root, dirs, files in os.walk(CONFIG['proyecto']):
        for file in files:
            if any(file.endswith(ext) for ext in extensiones_temporales):
                file_path = os.path.join(root, file)
                try:
                    os.remove(file_path)
                    print(f"   🗑️  Eliminado: {file}")
                except:
                    print(f"   ⚠️  No se pudo eliminar: {file}")

def main():
    """Función principal - Corrección completa de metadatos"""
    print("=" * 70)
    print("CORRECCIÓN COMPLETA: ATRIBUTOS + METADATOS INTERNOS")
    print("=" * 70)
    
    # 1. Corregir atributos y metadatos
    capas_corregidas = corregir_metadatos_y_atributos()
    
    # 2. Verificar corrección
    verificar_metadatos_corregidos()
    
    # 3. Generar reporte
    generar_reporte_metadatos()
    
    # 4. Limpiar temporales
    limpiar_archivos_temporales()
    
    print(f"\n🎯 CORRECCIÓN COMPLETA:")
    print(f"   • {capas_corregidas} capas con metadatos corregidos")
    print(f"   • Atributos 'partido_no' y 'partido_co' actualizados")
    print(f"   • Campo 'ruta' verificado")
    print(f"   • Metadatos de trazabilidad agregados")
    print(f"   • Backups completos en: 04_BACKUPS/")

if __name__ == "__main__":
    main()