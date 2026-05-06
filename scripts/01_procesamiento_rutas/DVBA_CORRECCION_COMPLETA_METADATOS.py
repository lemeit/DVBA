"""
DVBA_CORRECCION_EXCLUSIVA_RP61.py
===========================================================
CORRECCIÓN EXCLUSIVA: Solo RP61 - Cambiar General Las Heras por General Alvear
"""

import geopandas as gpd
import pandas as pd
import os
import glob
import shutil
from datetime import datetime

# CONFIGURACIÓN
CONFIG = {
    'proyecto': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"
}

def corregir_exclusivamente_rp61():
    """Corrige EXCLUSIVAMENTE las capas de RP61"""
    print("🔧 CORRIGIENDO EXCLUSIVAMENTE RP61...")
    
    # Buscar SOLO archivos RP61
    patron_rp61 = os.path.join(CONFIG['proyecto'], "**", "RP61*.shp")
    archivos_rp61 = glob.glob(patron_rp61, recursive=True)
    
    capas_corregidas = 0
    
    for archivo in archivos_rp61:
        nombre_actual = os.path.basename(archivo)
        
        try:
            # Leer la capa
            gdf = gpd.read_file(archivo)
            
            if len(gdf) > 0 and 'partido_no' in gdf.columns:
                partido_actual = gdf['partido_no'].iloc[0]
                
                # SOLO corregir si dice "General Las Heras"
                if partido_actual == "General Las Heras":
                    # Crear backup
                    crear_backup_rp61(archivo)
                    
                    # CORREGIR: General Las Heras → General Alvear
                    gdf['partido_no'] = 'General Alvear'
                    gdf['partido_co'] = '034'
                    
                    # Guardar los cambios
                    gdf.to_file(archivo)
                    
                    print(f"   ✅ CORREGIDO: {nombre_actual}")
                    print(f"      • Partido: General Las Heras → General Alvear")
                    print(f"      • Código: 041 → 034")
                    capas_corregidas += 1
                else:
                    print(f"   ℹ️  OK: {nombre_actual} - Ya es {partido_actual}")
            else:
                print(f"   ⚠️  {nombre_actual}: No se pudo verificar")
                
        except Exception as e:
            print(f"   ❌ {nombre_actual}: Error - {e}")
    
    return capas_corregidas

def crear_backup_rp61(archivo_original):
    """Crea backup específico para RP61"""
    fecha = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = os.path.join(CONFIG['proyecto'], "04_BACKUPS", f"RP61_CORRECCION_{fecha}")
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

def verificar_correccion_rp61():
    """Verifica que la corrección se aplicó correctamente"""
    print("\n🔍 VERIFICANDO CORRECCIÓN RP61...")
    
    patron_rp61 = os.path.join(CONFIG['proyecto'], "**", "RP61*.shp")
    archivos_rp61 = glob.glob(patron_rp61, recursive=True)
    
    print("   📋 ESTADO ACTUAL RP61:")
    
    for archivo in archivos_rp61:
        nombre = os.path.basename(archivo)
        try:
            gdf = gpd.read_file(archivo)
            
            if len(gdf) > 0 and 'partido_no' in gdf.columns:
                partido = gdf['partido_no'].iloc[0]
                codigo = gdf['partido_co'].iloc[0] if 'partido_co' in gdf.columns else 'N/A'
                
                estado = "✅" if partido == "General Alvear" else "❌"
                print(f"   {estado} {nombre}: {partido} ({codigo})")
                
        except Exception as e:
            print(f"   ❌ {nombre}: Error al verificar")

def generar_reporte_rp61():
    """Genera reporte específico de RP61"""
    print("\n📊 GENERANDO REPORTE RP61...")
    
    reporte_path = os.path.join(CONFIG['proyecto'], "REPORTE_CORRECCION_RP61.txt")
    
    with open(reporte_path, 'w', encoding='utf-8') as f:
        f.write("REPORTE EXCLUSIVO: CORRECCIÓN RP61\n")
        f.write("=" * 40 + "\n\n")
        
        f.write("PROBLEMA ESPECÍFICO:\n")
        f.write("- RP61 estaba asignado a 'General Las Heras' (INCORRECTO)\n")
        f.write("- RP61 debe estar en 'General Alvear' (CORRECTO)\n\n")
        
        f.write("JUSTIFICACIÓN TERRITORIAL:\n")
        f.write("- RP61 se desarrolla completamente en General Alvear\n")
        f.write("- No atraviesa General Las Heras en ningún punto\n")
        f.write("- Traza: Empalme RP29 → Límite con 25 de Mayo (siempre en General Alvear)\n\n")
        
        f.write("CORRECCIÓN APLICADA:\n")
        f.write("- partido_no: 'General Las Heras' → 'General Alvear'\n")
        f.write("- partido_co: '041' → '034'\n")
    
    print(f"   ✅ Reporte guardado en: {reporte_path}")

def main():
    """Función principal - Corrección exclusiva RP61"""
    print("=" * 60)
    print("CORRECCIÓN EXCLUSIVA: RP61")
    print("General Las Heras → General Alvear")
    print("=" * 60)
    
    # 1. Verificar estado actual
    verificar_correccion_rp61()
    
    # 2. Aplicar corrección
    print(f"\n🔄 APLICANDO CORRECCIÓN...")
    capas_corregidas = corregir_exclusivamente_rp61()
    
    # 3. Verificar resultado
    print(f"\n🔍 VERIFICANDO RESULTADO...")
    verificar_correccion_rp61()
    
    # 4. Generar reporte
    generar_reporte_rp61()
    
    print(f"\n🎯 CORRECCIÓN RP61 COMPLETADA:")
    print(f"   • {capas_corregidas} capas de RP61 corregidas")
    print(f"   • Partido: General Las Heras → General Alvear")
    print(f"   • Código: 041 → 034")
    print(f"   • Backups en: 04_BACKUPS/")

if __name__ == "__main__":
    main()