"""
DVBA-Z6-PROGRESIVAS-CORRECTOR-003.py
===========================================================
SCRIPT: Corrector de Progresivas Viales - Rutas Provinciales Zona 6
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.3.0 (Generado: 2025-10-21)
CODIGO: DVBA-Z6-PROGRESIVAS-CORRECTOR-003

DESCRIPCIÓN:
    - Corrección de progresivas kilométricas basada en mojones oficiales
    - Determinación automática del sentido de crecimiento por ruta
    - Cálculo de error porcentual entre progresivas
    - Sobreescritura del shapefile original con datos corregidos

DERECHOS: Dirección de Vialidad de la Provincia de Buenos Aires
DEPARTAMENTO: Zona VI Saladillo - División Técnica
"""

import os
import pandas as pd
import geopandas as gpd
import numpy as np
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# CONFIGURACIÓN INSTITUCIONAL
METADATOS_DVBA = {
    'organismo': 'Dirección de Vialidad de la Provincia de Buenos Aires',
    'departamento': 'Zona VI Saladillo - División Técnica', 
    'autor': 'Ing. Luciano Lamaita',
    'contacto': 'lulamaita@vialidad.gba.gov.ar',
    'proyecto': 'Reconstrucción y Filtrado de Rutas Provinciales',
    'sistema_referencia': 'EPSG:5347 - POSGAR 2007',
    'tipo_dato': 'Mojones cienkilométricos cada 50 km'
}

# DICCIONARIO DE SENTIDOS POR RUTA (extraído de los datos de mojones)
SENTIDOS_RUTAS = {
    6: "NORTE-SUR",      # Aumenta en direccion N (de 0km a 150km hacia el N)
    20: "SUR-NORTE",     # Aumenta en direccion O/SO (de 0km a 200km hacia el O)
    24: "SUR-NORTE",     # Aumenta en direccion SO (de 0km a 100km hacia el SO)  
    30: "SUR-NORTE",     # Aumenta en direccion NO/N (de 0km a 550km hacia el NO)
    40: "SUR-NORTE",     # Aumenta en direccion O/SO (de 0km a 200km hacia el O)
    41: "SUR-NORTE",     # Aumenta en direccion N/NO (de 0km a 300km hacia el N)
    42: "SUR-NORTE",     # Aumenta en direccion N/SO (de 0km a 200km hacia el N)
    43: "SUR-NORTE",     # Aumenta en direccion NO (de 0km a 100km hacia el NO)
    44: "SUR-NORTE",     # Aumenta en direccion O (de 0km a 100km hacia el O)
    46: "SUR-NORTE",     # Aumenta en direccion NO (de 0km a 100km hacia el NO)
    47: "NORTE-SUR",     # Aumenta en direccion N (de 0km a 100km hacia el N)
    48: "SUR-NORTE",     # Aumenta en direccion SO (solo 0km)
    51: "NORTE-SUR",     # Aumenta en direccion S (de 0km a 700km hacia el S)
    61: "ESTE-OESTE",    # Aumenta en direccion O (de 0km a 250km hacia el O)
    91: "NOROESTE-SURESTE" # Aumenta en direccion SE (de 0km a 50km hacia el SE)
}

def calcular_progresiva_corregida(fila, sentido_ruta):
    """
    Calcula la progresiva corregida según el sentido de la ruta
    """
    mojon_base = fila['mojon_base']
    dist_mojon = fila['dist_mojon']
    dist_km = dist_mojon / 1000.0
    
    # Obtener coordenadas del punto y mojón
    punto_x, punto_y = fila['geometry'].x, fila['geometry'].y
    mojon_x, mojon_y = fila['lon_posgar'], fila['lat_posgar']
    
    # Aplicar corrección según sentido
    if sentido_ruta == 'NORTE-SUR':
        # Progresiva aumenta hacia el SUR
        if punto_y < mojon_y:  # Punto está al SUR del mojón
            return mojon_base + dist_km
        else:  # Punto está al NORTE del mojón
            return mojon_base - dist_km
            
    elif sentido_ruta == 'SUR-NORTE':
        # Progresiva aumenta hacia el NORTE  
        if punto_y > mojon_y:  # Punto está al NORTE del mojón
            return mojon_base + dist_km
        else:  # Punto está al SUR del mojón
            return mojon_base - dist_km
            
    elif sentido_ruta == 'ESTE-OESTE':
        # Progresiva aumenta hacia el OESTE
        if punto_x < mojon_x:  # Punto está al OESTE del mojón
            return mojon_base + dist_km
        else:  # Punto está al ESTE del mojón
            return mojon_base - dist_km
            
    elif sentido_ruta == 'OESTE-ESTE':
        # Progresiva aumenta hacia el ESTE
        if punto_x > mojon_x:  # Punto está al ESTE del mojón
            return mojon_base + dist_km
        else:  # Punto está al OESTE del mojón
            return mojon_base - dist_km
            
    elif sentido_ruta == 'NOROESTE-SURESTE':
        # Progresiva aumenta hacia el SURESTE
        if punto_x < mojon_x and punto_y < mojon_y:  # Punto está al SURESTE
            return mojon_base + dist_km
        else:  # Punto está al NOROESTE
            return mojon_base - dist_km
            
    elif sentido_ruta == 'SURESTE-NOROESTE':
        # Progresiva aumenta hacia el NOROESTE
        if punto_x > mojon_x and punto_y > mojon_y:  # Punto está al NOROESTE
            return mojon_base + dist_km
        else:  # Punto está al SURESTE
            return mojon_base - dist_km
            
    else:
        # Sentido no determinado, usar cálculo tradicional
        return mojon_base + dist_km

def calcular_error_porcentual(prog_actual, prog_corregida):
    """
    Calcula el error porcentual entre progresivas
    """
    if prog_actual == 0:
        return 100.0  # Evitar división por cero
    return abs((prog_corregida - prog_actual) / prog_actual) * 100

def procesar_shapefile(input_shp):
    """
    Procesa el shapefile completo y sobreescribe con progresivas corregidas
    """
    print(f"📁 Cargando shapefile: {input_shp}")
    
    # Cargar el shapefile
    gdf = gpd.read_file(input_shp)
    
    # Verificar campos necesarios
    campos_requeridos = ['mojon_base', 'dist_mojon', 'ruta_num', 'lon_posgar', 'lat_posgar']
    for campo in campos_requeridos:
        if campo not in gdf.columns:
            print(f"❌ Error: Campo requerido '{campo}' no encontrado")
            return None
    
    print(f"✅ Shapefile cargado: {len(gdf)} puntos")
    print(f"✅ Rutas encontradas: {sorted(gdf['ruta_num'].unique())}")
    
    # Lista para almacenar resultados
    progresivas_corregidas = []
    errores_porcentuales = []
    sentidos_aplicados = []
    
    # Procesar cada punto
    for idx, fila in gdf.iterrows():
        ruta_num = fila['ruta_num']
        sentido = SENTIDOS_RUTAS.get(ruta_num, 'INDETERMINADO')
        
        # Calcular progresiva corregida
        prog_corregida = calcular_progresiva_corregida(fila, sentido)
        
        # Obtener progresiva actual (PROG_CALC si existe, sino prog_mojon)
        prog_actual = fila.get('PROG_CALC', fila.get('prog_mojon', 0))
        
        # Calcular error porcentual
        error_porc = calcular_error_porcentual(prog_actual, prog_corregida)
        
        progresivas_corregidas.append(prog_corregida)
        errores_porcentuales.append(error_porc)
        sentidos_aplicados.append(sentido)
    
    # Agregar nuevas columnas al GeoDataFrame
    gdf['prog_corregida'] = progresivas_corregidas
    gdf['error_porc_calc'] = errores_porcentuales
    gdf['sentido_ruta'] = sentidos_aplicados
    
    # Calcular diferencia en km
    gdf['diff_km'] = gdf['prog_corregida'] - gdf.get('PROG_CALC', gdf.get('prog_mojon', 0))
    
    # Crear backup del archivo original
    backup_file = input_shp.replace('.shp', f'_backup_{datetime.now().strftime("%Y%m%d_%H%M")}.shp')
    print(f"💾 Creando backup: {backup_file}")
    gdf.to_file(backup_file)
    
    # Sobreescribir el archivo original con los nuevos datos
    print(f"✏️ Sobreescribiendo archivo original: {input_shp}")
    gdf.to_file(input_shp)
    
    return gdf

def generar_reporte(gdf, output_file):
    """
    Genera un reporte detallado del procesamiento
    """
    reporte = []
    reporte.append("=" * 70)
    reporte.append("REPORTE DE CORRECCIÓN DE PROGRESIVAS - DVBA ZONA 6")
    reporte.append("=" * 70)
    reporte.append(f"Fecha generación: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    reporte.append(f"Total puntos procesados: {len(gdf)}")
    reporte.append("")
    
    # Estadísticas por ruta
    rutas_unicas = gdf['ruta_num'].unique()
    
    for ruta in sorted(rutas_unicas):
        puntos_ruta = gdf[gdf['ruta_num'] == ruta]
        sentido = puntos_ruta['sentido_ruta'].iloc[0] if len(puntos_ruta) > 0 else 'N/A'
        
        error_prom = puntos_ruta['error_porc_calc'].mean()
        diff_prom = puntos_ruta['diff_km'].mean()
        
        reporte.append(f"RP{ruta}:")
        reporte.append(f"  - Puntos: {len(puntos_ruta)}")
        reporte.append(f"  - Sentido aplicado: {sentido}")
        reporte.append(f"  - Error porcentual promedio: {error_prom:.2f}%")
        reporte.append(f"  - Diferencia promedio: {diff_prom:+.2f} km")
        reporte.append("")
    
    # Estadísticas generales
    reporte.append("ESTADÍSTICAS GENERALES:")
    reporte.append(f"  - Error máximo: {gdf['error_porc_calc'].max():.2f}%")
    reporte.append(f"  - Error mínimo: {gdf['error_porc_calc'].min():.2f}%")
    reporte.append(f"  - Error promedio: {gdf['error_porc_calc'].mean():.2f}%")
    reporte.append(f"  - Diferencia máxima: {gdf['diff_km'].max():.2f} km")
    reporte.append(f"  - Diferencia mínima: {gdf['diff_km'].min():.2f} km")
    
    # Guardar reporte
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(reporte))
    
    print(f"📊 Reporte guardado: {output_file}")

def main():
    """Función principal"""
    print("=" * 70)
    print("CORRECTOR DE PROGRESIVAS VIALES - DVBA ZONA 6")
    print("=" * 70)
    print(f"ORGANISMO: {METADATOS_DVBA['organismo']}")
    print(f"DEPARTAMENTO: {METADATOS_DVBA['departamento']}")
    print(f"AUTOR: {METADATOS_DVBA['autor']}")
    print(f"PROYECTO: {METADATOS_DVBA['proyecto']}")
    print(f"FECHA: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)
    
    # Solicitar archivo shapefile al usuario
    input_shp = input("📁 Ingresa la ruta completa del shapefile a procesar: ").strip().strip('"')
    
    if not os.path.exists(input_shp):
        print(f"❌ Error: El archivo {input_shp} no existe")
        return
    
    # Procesar el shapefile
    gdf_procesado = procesar_shapefile(input_shp)
    
    if gdf_procesado is not None:
        print(f"✅ Procesamiento completado exitosamente!")
        print(f"✅ Total puntos procesados: {len(gdf_procesado)}")
        
        # Generar reporte
        reporte_file = input_shp.replace('.shp', '_reporte.txt')
        generar_reporte(gdf_procesado, reporte_file)
        
        # Mostrar resumen rápido
        print(f"\n📈 RESUMEN RÁPIDO:")
        print(f"   - Error porcentual promedio: {gdf_procesado['error_porc_calc'].mean():.2f}%")
        print(f"   - Diferencia promedio: {gdf_procesado['diff_km'].mean():.2f} km")
        
        # Mostrar algunos ejemplos
        print(f"\n🔍 EJEMPLOS (primeros 5 puntos):")
        for idx, fila in gdf_procesado.head().iterrows():
            wp = fila.get('WP', 'N/A')
            prog_actual = fila.get('PROG_CALC', fila.get('prog_mojon', 0))
            prog_corregida = fila['prog_corregida']
            error_porc = fila['error_porc_calc']
            
            print(f"   WP {wp}: {prog_actual:.2f}km → {prog_corregida:.2f}km | Error: {error_porc:.2f}%")
    
    else:
        print("❌ Error en el procesamiento")

if __name__ == "__main__":
    main()