"""
DVBA_CORRECCION_RP61_POR_PARTIDOS.py
===========================================================
CORRECCIÓN ESPECÍFICA: Carpeta RP61_POR_PARTIDOS
"""

import geopandas as gpd
import pandas as pd
import os
import glob
import shutil
from datetime import datetime

# CONFIGURACIÓN ESPECÍFICA
CARPETA_RP61 = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\03_CAPAS_GENERADAS\RP61_POR_PARTIDOS"

def corregir_carpeta_rp61_por_partidos():
    """Corrige EXCLUSIVAMENTE la carpeta RP61_POR_PARTIDOS"""
    print("🔧 CORRIGIENDO CARPETA RP61_POR_PARTIDOS...")
    print(f"   📍 Ubicación: {CARPETA_RP61}")
    
    if not os.path.exists(CARPETA_RP61):
        print("   ❌ La carpeta no existe")
        return 0
    
    # Buscar todos los archivos .shp en esta carpeta específica
    patron = os.path.join(CARPETA_RP61, "RP61*.shp")
    archivos_rp61 = glob.glob(patron)
    
    capas_corregidas = 0
    
    for archivo in archivos_rp61:
        nombre_actual = os.path.basename(archivo)
        
        try:
            # Leer la capa
            gdf = gpd.read_file(archivo)
            
            if len(gdf) > 0:
                # Verificar campos disponibles
                campos = list(gdf.columns)
                print(f"\n   📄 Procesando: {nombre_actual}")
                print(f"      Campos disponibles: {campos}")
                
                # CORREGIR según el nombre del archivo y contenido
                if "General_Las_Heras" in nombre_actual:
                    # Este archivo NO debería existir para RP61
                    print(f"      🚨 ARCHIVO INCORRECTO: {nombre_actual}")
                    print(f"      RP61 NO pasa por General Las Heras")
                    
                    # Crear backup
                    crear_backup_especifico(archivo, "ELIMINACION_INCORRECTO")
                    
                    # Opción 1: Renombrar a General Alvear
                    nuevo_nombre = nombre_actual.replace("General_Las_Heras", "General_Alvear")
                    renombrar_archivo_completo(archivo, nuevo_nombre)
                    
                    # Corregir atributos
                    gdf_corregido = gpd.read_file(os.path.join(CARPETA_RP61, nuevo_nombre))
                    gdf_corregido['partido_no'] = 'General Alvear'
                    gdf_corregido['partido_co'] = '034'
                    gdf_corregido.to_file(os.path.join(CARPETA_RP61, nuevo_nombre))
                    
                    print(f"      ✅ RENOMBRADO: {nombre_actual} → {nuevo_nombre}")
                    print(f"      ✅ ATRIBUTOS: General Las Heras → General Alvear")
                    capas_corregidas += 1
                
                elif "General_Alvear" in nombre_actual:
                    # Verificar que los atributos sean correctos
                    if 'partido_no' in gdf.columns:
                        partido_actual = gdf['partido_no'].iloc[0]
                        if partido_actual != "General Alvear":
                            crear_backup_especifico(archivo, "CORRECCION_ATRIBUTOS")
                            gdf['partido_no'] = 'General Alvear'
                            gdf['partido_co'] = '034'
                            gdf.to_file(archivo)
                            print(f"      ✅ CORREGIDO: {partido_actual} → General Alvear")
                            capas_corregidas += 1
                        else:
                            print(f"      ✅ OK: Ya está correcto (General Alvear)")
                    else:
                        print(f"      ⚠️  No tiene campo partido_no")
                
                else:
                    # Para otros archivos de RP61, verificar que no estén en General Las Heras
                    if 'partido_no' in gdf.columns:
                        partido_actual = gdf['partido_no'].iloc[0]
                        if partido_actual == "General Las Heras":
                            crear_backup_especifico(archivo, "CORRECCION_PARTIDO")
                            gdf['partido_no'] = 'General Alvear'
                            gdf['partido_co'] = '034'
                            gdf.to_file(archivo)
                            print(f"      ✅ CORREGIDO: General Las Heras → General Alvear")
                            capas_corregidas += 1
                        else:
                            print(f"      ℹ️  Partido actual: {partido_actual}")
                    
            else:
                print(f"   ⚠️  {nombre_actual}: Capa vacía")
                
        except Exception as e:
            print(f"   ❌ {nombre_actual}: Error - {e}")
    
    return capas_corregidas

def crear_backup_especifico(archivo_original, motivo):
    """Crea backup específico para esta operación"""
    fecha = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = os.path.join(os.path.dirname(CARPETA_RP61), "..", "04_BACKUPS", f"RP61_POR_PARTIDOS_{fecha}")
    os.makedirs(backup_dir, exist_ok=True)
    
    # Copiar todos los archivos relacionados
    base_name = os.path.splitext(archivo_original)[0]
    for extension in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx']:
        archivo_relacionado = base_name + extension
        if os.path.exists(archivo_relacionado):
            shutil.copy2(
                archivo_relacionado,
                os.path.join(backup_dir, os.path.basename(archivo_relacionado))
            )

def renombrar_archivo_completo(archivo_original, nuevo_nombre):
    """Renombra un archivo y todos sus relacionados"""
    directorio = os.path.dirname(archivo_original)
    base_actual = os.path.splitext(archivo_original)[0]
    base_nuevo = os.path.join(directorio, os.path.splitext(nuevo_nombre)[0])
    
    extensiones = ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx', '.shp.xml']
    
    for extension in extensiones:
        archivo_actual = base_actual + extension
        archivo_nuevo = base_nuevo + extension
        
        if os.path.exists(archivo_actual):
            os.rename(archivo_actual, archivo_nuevo)

def eliminar_archivos_incorrectos_rp61():
    """Elimina archivos incorrectos de RP61"""
    print("\n🗑️  ELIMINANDO ARCHIVOS INCORRECTOS...")
    
    # Archivos que NO deberían existir para RP61
    archivos_prohibidos = [
        "RP61_General_Las_Heras.*",
        "RP61*Las_Heras*"
    ]
    
    for patron in archivos_prohibidos:
        busqueda = os.path.join(CARPETA_RP61, patron)
        archivos_encontrados = glob.glob(busqueda)
        
        for archivo in archivos_encontrados:
            print(f"   🚨 ARCHIVO PROHIBIDO: {os.path.basename(archivo)}")
            print(f"      RP61 NO pasa por General Las Heras")
            
            # Mover a cuarentena en lugar de eliminar
            cuarentena_dir = os.path.join(CARPETA_RP61, "..", "00_CUARENTENA_RP61")
            os.makedirs(cuarentena_dir, exist_ok=True)
            
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            nombre_base = os.path.basename(archivo)
            destino = os.path.join(cuarentena_dir, f"{timestamp}_{nombre_base}")
            
            shutil.move(archivo, destino)
            print(f"      📦 MOVIDO A CUARENTENA: {nombre_base}")

def verificar_estado_final():
    """Verifica el estado final de la carpeta"""
    print("\n🔍 VERIFICANDO ESTADO FINAL...")
    
    patron = os.path.join(CARPETA_RP61, "*.shp")
    archivos = glob.glob(patron)
    
    print("   📋 CONTENIDO ACTUAL:")
    
    for archivo in archivos:
        nombre = os.path.basename(archivo)
        try:
            gdf = gpd.read_file(archivo)
            
            if len(gdf) > 0 and 'partido_no' in gdf.columns:
                partido = gdf['partido_no'].iloc[0]
                codigo = gdf['partido_co'].iloc[0] if 'partido_co' in gdf.columns else 'N/A'
                
                # Verificar corrección
                if "RP61" in nombre and partido == "General Las Heras":
                    estado = "❌ INCORRECTO"
                elif "RP61" in nombre and partido == "General Alvear":
                    estado = "✅ CORRECTO"
                else:
                    estado = "ℹ️  OTRO"
                
                print(f"   {estado} {nombre}: {partido} ({codigo})")
                
        except Exception as e:
            print(f"   ❌ {nombre}: Error al verificar")

def generar_reporte_final():
    """Genera reporte final específico"""
    print("\n📊 GENERANDO REPORTE FINAL...")
    
    reporte_path = os.path.join(CARPETA_RP61, "REPORTE_CORRECCION_RP61.txt")
    
    with open(reporte_path, 'w', encoding='utf-8') as f:
        f.write("REPORTE: CORRECCIÓN CARPETA RP61_POR_PARTIDOS\n")
        f.write("=" * 50 + "\n\n")
        
        f.write("REGLA DEFINITIVA RP61:\n")
        f.write("- RP61 SOLO puede contener segmentos en General Alvear\n")
        f.write("- RP61 NO pasa por General Las Heras\n")
        f.write("- Eliminar cualquier archivo que diga 'General_Las_Heras' para RP61\n\n")
        
        f.write("ARCHIVOS PERMITIDOS:\n")
        f.write("- RP61_General_Alvear.shp ✅\n")
        f.write("- RP61_25_de_Mayo.shp ✅\n")
        f.write("- RP61_Las_Flores.shp ✅\n")
        f.write("- RP61_Veinticinco_De_Mayo.shp ✅\n\n")
        
        f.write("ARCHIVOS PROHIBIDOS:\n")
        f.write("- RP61_General_Las_Heras.shp ❌\n")
        f.write("- Cualquier archivo RP61 con 'Las_Heras' ❌\n")
    
    print(f"   ✅ Reporte guardado en: {reporte_path}")

def main():
    """Función principal - Corrección específica"""
    print("=" * 70)
    print("CORRECCIÓN ESPECÍFICA: CARPETA RP61_POR_PARTIDOS")
    print("ELIMINANDO 'General_Las_Heras' DE RP61")
    print("=" * 70)
    
    # 1. Verificar estado inicial
    print("📋 ESTADO INICIAL:")
    verificar_estado_final()
    
    # 2. Corregir archivos
    print(f"\n🔄 APLICANDO CORRECCIONES...")
    capas_corregidas = corregir_carpeta_rp61_por_partidos()
    
    # 3. Eliminar archivos incorrectos
    eliminar_archivos_incorrectos_rp61()
    
    # 4. Verificar estado final
    print(f"\n🔍 VERIFICANDO RESULTADO...")
    verificar_estado_final()
    
    # 5. Generar reporte
    generar_reporte_final()
    
    print(f"\n🎯 CORRECCIÓN COMPLETADA:")
    print(f"   • {capas_corregidas} capas corregidas")
    print(f"   • Carpeta: {CARPETA_RP61}")
    print(f"   • Archivos con 'General_Las_Heras' eliminados")

if __name__ == "__main__":
    main()