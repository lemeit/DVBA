"""
DVBA_Z6_ANALISIS_PROBLEMAS.py
===========================================================
ANÁLISIS DE PROBLEMAS: Identifica causas de discrepancias en validación
DVBA - DIRECCIÓN DE VIALIDAD DE LA PROVINCIA DE BUENOS AIRES
"""

import geopandas as gpd
import pandas as pd
import os
import glob

# CONFIGURACIÓN
CONFIG = {
    'proyecto': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    'tablas_csv': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\04_TABLAS",
    'reportes_dir': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\07_VALIDACIONES"
}

def cargar_base_oficial_detallada():
    """Carga la base oficial con todos los campos"""
    print("📊 CARGANDO BASE OFICIAL DETALLADA...")
    
    csv_path = os.path.join(CONFIG['tablas_csv'], 'SALADILLO_RED.csv')
    
    try:
        df = pd.read_csv(csv_path, sep=';', encoding='latin-1')
        print(f"✅ Base oficial cargada: {len(df)} registros")
        
        # Limpiar datos
        df['RUTA'] = df['RUTA'].astype(str).str.strip()
        df['PARTIDO'] = df['PARTIDO'].astype(str).str.strip().str.zfill(3)
        df['Longitud en metros'] = pd.to_numeric(df['Longitud en metros'], errors='coerce')
        df['CLASE'] = df['CLASE'].astype(str).str.strip()
        
        # Mostrar información detallada
        print(f"\n📋 INFORMACIÓN DE LA BASE OFICIAL:")
        print(f"   • Campos disponibles: {list(df.columns)}")
        print(f"   • Tipos de superficie: {df['CLASE'].unique()}")
        print(f"   • Zonas: {df['ZONA'].unique()}")
        
        return df
        
    except Exception as e:
        print(f"❌ Error cargando base oficial: {e}")
        return None

def analizar_problemas_especificos():
    """Analiza problemas específicos identificados en la validación"""
    print("\n🔍 ANALIZANDO PROBLEMAS ESPECÍFICOS...")
    
    # Cargar base oficial
    df_oficial = cargar_base_oficial_detallada()
    if df_oficial is None:
        return
    
    # PROBLEMA 1: RP61 - Grandes discrepancias
    print(f"\n🚨 PROBLEMA 1: RP61 - GRANDES DISCREPANCIAS")
    analizar_rp61(df_oficial)
    
    # PROBLEMA 2: RP40 - Navarro con diferencia del 31%
    print(f"\n🚨 PROBLEMA 2: RP40 - NAVARRO")
    analizar_rp40_navarro(df_oficial)
    
    # PROBLEMA 3: RP47 - General Las Heras
    print(f"\n🚨 PROBLEMA 3: RP47 - GENERAL LAS HERAS")
    analizar_rp47_las_heras(df_oficial)
    
    # PROBLEMA 4: Capas con partido no identificado
    print(f"\n🚨 PROBLEMA 4: CAMPOS DE PARTIDO INCORRECTOS")
    identificar_capas_partido_incorrecto()
    
    # PROBLEMA 5: Capas INTEGRADO sin datos
    print(f"\n🚨 PROBLEMA 5: CAPAS INTEGRADO SIN DATOS")
    analizar_capas_integrado()

def analizar_rp61(df_oficial):
    """Analiza los problemas específicos de RP61"""
    print("   📈 RP61 - ANÁLISIS DETALLADO:")
    
    # Filtrar datos oficiales de RP61
    rp61_oficial = df_oficial[df_oficial['RUTA'] == '61']
    
    if len(rp61_oficial) == 0:
        print("   ❌ No hay datos oficiales para RP61")
        return
    
    print(f"   • Tramos oficiales RP61: {len(rp61_oficial)}")
    print(f"   • Partidos en RP61: {rp61_oficial['PARTIDO'].unique()}")
    print(f"   • Longitud total oficial: {rp61_oficial['Longitud en metros'].sum() / 1000:.2f} km")
    
    # Mostrar por partido
    print(f"\n   📊 DISTRIBUCIÓN OFICIAL POR PARTIDO:")
    for partido in rp61_oficial['PARTIDO'].unique():
        datos_partido = rp61_oficial[rp61_oficial['PARTIDO'] == partido]
        longitud_km = datos_partido['Longitud en metros'].sum() / 1000
        tramos = len(datos_partido)
        clases = datos_partido['CLASE'].unique()
        print(f"     • Partido {partido}: {longitud_km:.2f} km, {tramos} tramos")
        print(f"       Tipos de superficie: {list(clases)}")
        
        # Mostrar algunos tramos específicos
        for _, tramo in datos_partido.head(2).iterrows():
            print(f"       - {tramo['SECCION VIAL']}: {tramo['Longitud en metros']:.0f} m - {tramo['CLASE']}")

def analizar_rp40_navarro(df_oficial):
    """Analiza RP40 Navarro"""
    print("   📈 RP40 - NAVARRO:")
    
    rp40_navarro = df_oficial[(df_oficial['RUTA'] == '40') & (df_oficial['PARTIDO'] == '075')]
    
    if len(rp40_navarro) == 0:
        print("   ❌ No hay datos oficiales para RP40 - Navarro")
        return
    
    print(f"   • Tramos oficiales: {len(rp40_navarro)}")
    print(f"   • Longitud oficial: {rp40_navarro['Longitud en metros'].sum() / 1000:.2f} km")
    print(f"   • Tipos de superficie: {rp40_navarro['CLASE'].unique()}")
    
    # Mostrar tramos específicos
    for _, tramo in rp40_navarro.iterrows():
        print(f"     - {tramo['SECCION VIAL']}: {tramo['Longitud en metros']:.0f} m - {tramo['CLASE']}")

def analizar_rp47_las_heras(df_oficial):
    """Analiza RP47 General Las Heras"""
    print("   📈 RP47 - GENERAL LAS HERAS:")
    
    rp47_heras = df_oficial[(df_oficial['RUTA'] == '47') & (df_oficial['PARTIDO'] == '041')]
    
    if len(rp47_heras) == 0:
        print("   ❌ No hay datos oficiales para RP47 - General Las Heras")
        return
    
    print(f"   • Tramos oficiales: {len(rp47_heras)}")
    print(f"   • Longitud oficial: {rp47_heras['Longitud en metros'].sum() / 1000:.2f} km")
    print(f"   • Tipos de superficie: {rp47_heras['CLASE'].unique()}")
    
    for _, tramo in rp47_heras.iterrows():
        print(f"     - {tramo['SECCION VIAL']}: {tramo['Longitud en metros']:.0f} m - {tramo['DENOMINACIÓN']}")

def identificar_capas_partido_incorrecto():
    """Identifica capas con problemas de detección de partido"""
    print("   🔍 IDENTIFICANDO CAMPOS DE PARTIDO INCORRECTOS...")
    
    patron = os.path.join(CONFIG['proyecto'], "**", "RP*.shp")
    capas = glob.glob(patron, recursive=True)
    
    problemas = []
    for capa in capas:
        nombre = os.path.basename(capa)
        try:
            gdf = gpd.read_file(capa)
            
            if 'partido_no' in gdf.columns:
                partido_nombre = gdf['partido_no'].iloc[0] if len(gdf) > 0 else 'N/A'
                if partido_nombre == 'Partido No Identificado':
                    problemas.append({
                        'archivo': nombre,
                        'partido_no': partido_nombre,
                        'segmentos': len(gdf),
                        'longitud_km': gdf.geometry.length.sum() / 1000 if len(gdf) > 0 else 0
                    })
        except:
            continue
    
    if problemas:
        print(f"   ❌ {len(problemas)} capas con partido no identificado:")
        for problema in problemas[:10]:  # Mostrar primeras 10
            print(f"     • {problema['archivo']}: {problema['longitud_km']:.2f} km, {problema['segmentos']} segmentos")
    else:
        print("   ✅ No hay capas con partido no identificado")

def analizar_capas_integrado():
    """Analiza las capas INTEGRADO que aparecen sin datos"""
    print("   🔍 ANALIZANDO CAPAS INTEGRADO...")
    
    patron = os.path.join(CONFIG['proyecto'], "**", "*INTEGRADO*.shp")
    capas = glob.glob(patron, recursive=True)
    
    for capa in capas:
        nombre = os.path.basename(capa)
        try:
            gdf = gpd.read_file(capa)
            longitud_km = gdf.geometry.length.sum() / 1000
            
            print(f"     • {nombre}: {longitud_km:.2f} km, {len(gdf)} segmentos")
            
            # Mostrar campos disponibles
            if 'partido_no' in gdf.columns:
                partidos = gdf['partido_no'].unique()
                print(f"       Partidos: {list(partidos)}")
                
        except Exception as e:
            print(f"     • {nombre}: ERROR - {e}")

def generar_recomendaciones():
    """Genera recomendaciones específicas basadas en el análisis"""
    print(f"\n💡 RECOMENDACIONES ESPECÍFICAS:")
    
    print(f"\n🎯 PROBLEMA RP61 - GRANDES DISCREPANCIAS:")
    print(f"   • Verificar si la capa generada incluye TODOS los tramos de RP61")
    print(f"   • Revisar superposición de geometrías en límites de partido")
    print(f"   • Confirmar que no hay segmentos duplicados")
    
    print(f"\n🎯 PROBLEMA RP40 - NAVARRO:")
    print(f"   • La diferencia del 31% sugiere que faltan tramos en la capa generada")
    print(f"   • Verificar si todos los tramos oficiales están representados")
    print(f"   • Revisar intersecciones con otras rutas")
    
    print(f"\n🎯 PROBLEMA CAMPOS DE PARTIDO:")
    print(f"   • Las capas con 'Partido No Identificado' necesitan corrección manual")
    print(f"   • Revisar nombres de archivo para detectar automáticamente el partido")
    
    print(f"\n🎯 CAPAS INTEGRADO:")
    print(f"   • Considerar eliminar capas INTEGRADO sin datos válidos")
    print(f"   • Mantener solo las capas por partido que tienen datos reales")

def main():
    """Función principal"""
    print("=" * 70)
    print("DVBA - ANÁLISIS DETALLADO DE PROBLEMAS")
    print("=" * 70)
    
    # Realizar análisis
    analizar_problemas_especificos()
    
    # Generar recomendaciones
    generar_recomendaciones()
    
    print(f"\n📁 Los reportes detallados están en: {CONFIG['reportes_dir']}")

if __name__ == "__main__":
    main()