"""
DVBA-Z6-PROGRESIVAS-CORRECTOR-004.py
===========================================================
SCRIPT: Corrector de Progresivas Viales - Rutas Provinciales Zona 6
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.4.0 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-PROGRESIVAS-CORRECTOR-004

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

# DICCIONARIO DE SENTIDOS POR RUTA (CORREGIDO)
SENTIDOS_RUTAS = {
    6: "NORTE-SUR",      # Aumenta en direccion N (de 0km a 150km hacia el N)
    20: "OESTE-ESTE",    # Aumenta en direccion O/SO (de 0km a 200km hacia el O)
    24: "NOROESTE-SURESTE", # Aumenta en direccion SO (de 0km a 100km hacia el SO)  
    30: "SUROESTE-NORESTE", # Aumenta en direccion NO/N (de 0km a 550km hacia el NO)
    40: "OESTE-ESTE",    # Aumenta en direccion O/SO (de 0km a 200km hacia el O)
    41: "SUR-NORTE",     # Aumenta en direccion N/NO (de 0km a 300km hacia el N)
    42: "OESTE-ESTE",    # Aumenta en direccion N/SO (de 0km a 200km hacia el N)
    43: "NOROESTE-SURESTE", # Aumenta en direccion NO (de 0km a 100km hacia el NO)
    44: "OESTE-ESTE",    # Aumenta en direccion O (de 0km a 100km hacia el O)
    46: "NOROESTE-SURESTE", # Aumenta en direccion NO (de 0km a 100km hacia el NO)
    47: "NORTE-SUR",     # Aumenta en direccion N (de 0km a 100km hacia el N)
    48: "SUROESTE-NORESTE", # Aumenta en direccion SO (solo 0km)
    51: "NORTE-SUR",     # Aumenta en direccion S (de 0km a 700km hacia el S)
    61: "ESTE-OESTE",    # Aumenta en direccion O (de 0km a 250km hacia el O)
    91: "NOROESTE-SURESTE" # Aumenta en direccion SE (de 0km a 50km hacia el SE)
}

def analizar_sentido_ruta(gdf_ruta):
    """
    Analiza automáticamente el sentido de la ruta basado en las coordenadas de los puntos
    """
    if len(gdf_ruta) < 2:
        return "INDETERMINADO"
    
    # Ordenar por PROG_CALC para ver la progresión
    gdf_ordenado = gdf_ruta.sort_values('PROG_CALC')
    
    # Tomar primer y último punto según progresiva
    primer_punto = gdf_ordenado.iloc[0]
    ultimo_punto = gdf_ordenado.iloc[-1]
    
    # Obtener coordenadas
    x1, y1 = primer_punto['geometry'].x, primer_punto['geometry'].y
    x2, y2 = ultimo_punto['geometry'].x, ultimo_punto['geometry'].y
    
    # Determinar dirección principal
    dx = x2 - x1
    dy = y2 - y1
    
    # Calcular ángulo
    angulo = np.degrees(np.arctan2(dy, dx))
    
    # Determinar sentido basado en ángulo
    if -45 <= angulo <= 45:
        return "OESTE-ESTE" if dx > 0 else "ESTE-OESTE"
    elif 45 < angulo <= 135:
        return "SUR-NORTE" if dy > 0 else "NORTE-SUR"
    elif -135 <= angulo < -45:
        return "NORTE-SUR" if dy < 0 else "SUR-NORTE"
    else:
        return "ESTE-OESTE" if dx < 0 else "OESTE-ESTE"

def calcular_progresiva_corregida(fila, sentido_ruta):
    """
    Calcula la progresiva corregida según el sentido de la ruta
    """
    mojon_base = fila['mojon_base']
    dist_mojon = fila['dist_mojon']
    dist_km = dist_mojon / 1000.0
    
    # Obtener coordenadas del punto (geometría) y mojón (campos lat_posgar, lon_posgar)
    punto_x, punto_y = fila['geometry'].x, fila['geometry'].y
    
    # Las coordenadas del mojón están en los campos lon_posgar, lat_posgar
    mojon_x = fila['lon_posgar']
    mojon_y = fila['lat_posgar']
    
    print(f"  DEBUG: Punto({punto_x:.1f}, {punto_y:.1f}) vs Mojón({mojon_x:.1f}, {mojon_y:.1f})")
    print(f"  DEBUG: Base={mojon_base}km, Dist={dist_mojon}m, Sentido={sentido_ruta}")
    
    # Aplicar corrección según sentido - REVISADO
    if sentido_ruta == 'NORTE-SUR':
        # Progresiva aumenta hacia el SUR (coordenada Y disminuye)
        if punto_y < mojon_y:  # Punto está al SUR del mojón
            resultado = mojon_base + dist_km
            print(f"  DEBUG: Punto al SUR → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        else:  # Punto está al NORTE del mojón
            resultado = mojon_base - dist_km
            print(f"  DEBUG: Punto al NORTE → RESTAR: {mojon_base} - {dist_km} = {resultado}")
            
    elif sentido_ruta == 'SUR-NORTE':
        # Progresiva aumenta hacia el NORTE (coordenada Y aumenta)  
        if punto_y > mojon_y:  # Punto está al NORTE del mojón
            resultado = mojon_base + dist_km
            print(f"  DEBUG: Punto al NORTE → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        else:  # Punto está al SUR del mojón
            resultado = mojon_base - dist_km
            print(f"  DEBUG: Punto al SUR → RESTAR: {mojon_base} - {dist_km} = {resultado}")
            
    elif sentido_ruta == 'ESTE-OESTE':
        # Progresiva aumenta hacia el OESTE (coordenada X disminuye)
        if punto_x < mojon_x:  # Punto está al OESTE del mojón
            resultado = mojon_base + dist_km
            print(f"  DEBUG: Punto al OESTE → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        else:  # Punto está al ESTE del mojón
            resultado = mojon_base - dist_km
            print(f"  DEBUG: Punto al ESTE → RESTAR: {mojon_base} - {dist_km} = {resultado}")
            
    elif sentido_ruta == 'OESTE-ESTE':
        # Progresiva aumenta hacia el ESTE (coordenada X aumenta)
        if punto_x > mojon_x:  # Punto está al ESTE del mojón
            resultado = mojon_base + dist_km
            print(f"  DEBUG: Punto al ESTE → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        else:  # Punto está al OESTE del mojón
            resultado = mojon_base - dist_km
            print(f"  DEBUG: Punto al OESTE → RESTAR: {mojon_base} - {dist_km} = {resultado}")
            
    elif sentido_ruta == 'NOROESTE-SURESTE':
        # RP91: Aumenta hacia el SURESTE (X aumenta, Y disminuye)
        if punto_x > mojon_x and punto_y < mojon_y:  # Punto está al SURESTE
            resultado = mojon_base + dist_km
            print(f"  DEBUG: Punto al SURESTE → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        else:  # Punto está al NOROESTE
            resultado = mojon_base - dist_km
            print(f"  DEBUG: Punto al NOROESTE → RESTAR: {mojon_base} - {dist_km} = {resultado}")
            
    elif sentido_ruta == 'SURESTE-NOROESTE':
        # Progresiva aumenta hacia el NOROESTE (X disminuye, Y aumenta)
        if punto_x < mojon_x and punto_y > mojon_y:  # Punto está al NOROESTE
            resultado = mojon_base + dist_km
            print(f"  DEBUG: Punto al NOROESTE → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        else:  # Punto está al SURESTE
            resultado = mojon_base - dist_km
            print(f"  DEBUG: Punto al SURESTE → RESTAR: {mojon_base} - {dist_km} = {resultado}")
            
    else:
        # Sentido no determinado, usar cálculo tradicional
        resultado = mojon_base + dist_km
        print(f"  DEBUG: Sentido indeterminado → SUMAR: {mojon_base} + {dist_km} = {resultado}")
    
    return resultado

def calcular_error_porcentual(prog_actual, prog_corregida):
    """
    Calcula el error porcentual entre progresivas
    """
    if prog_actual == 0:
        return 0.0  # Evitar división por cero, error 0% si no hay progresiva anterior
    diferencia = abs(prog_corregida - prog_actual)
    return (diferencia / prog_actual) * 100

def procesar_shapefile(input_shp):
    """
    Procesa el shapefile completo y sobreescribe con progresivas corregidas
    """
    print(f"📁 Cargando shapefile: {input_shp}")
    
    # Cargar el shapefile
    gdf = gpd.read_file(input_shp)
    
    # Verificar campos necesarios
    campos_requeridos = ['mojon_base', 'dist_mojon', 'ruta_num', 'lon_posgar', 'lat_posgar', 'PROG_CALC']
    campos_faltantes = [campo for campo in campos_requeridos if campo not in gdf.columns]
    
    if campos_faltantes:
        print(f"❌ Error: Campos requeridos faltantes: {campos_faltantes}")
        return None
    
    print(f"✅ Shapefile cargado: {len(gdf)} puntos")
    print(f"✅ Rutas encontradas: {sorted(gdf['ruta_num'].unique())}")
    
    # Lista para almacenar resultados
    progresivas_corregidas = []
    errores_porcentuales = []
    sentidos_aplicados = []
    
    # Procesar por ruta
    rutas_unicas = gdf['ruta_num'].unique()
    
    for ruta in rutas_unicas:
        print(f"\n🔍 Procesando RP{ruta}:")
        puntos_ruta = gdf[gdf['ruta_num'] == ruta].copy()
        
        # Determinar sentido (usar predefinido o analizar automáticamente)
        sentido = SENTIDOS_RUTAS.get(ruta)
        if not sentido:
            sentido = analizar_sentido_ruta(puntos_ruta)
            print(f"   Sentido determinado automáticamente: {sentido}")
        else:
            print(f"   Sentido predefinido: {sentido}")
        
        # Procesar cada punto de la ruta
        for idx, fila in puntos_ruta.iterrows():
            wp = fila.get('WP', 'N/A')
            mojon_base = fila['mojon_base']
            dist_mojon = fila['dist_mojon']
            prog_actual = fila['PROG_CALC']
            
            print(f"   📍 WP {wp}: Base={mojon_base}km, Dist={dist_mojon}m, Prog_actual={prog_actual}km")
            
            # Calcular progresiva corregida
            prog_corregida = calcular_progresiva_corregida(fila, sentido)
            
            # Calcular error porcentual
            error_porc = calcular_error_porcentual(prog_actual, prog_corregida)
            
            progresivas_corregidas.append(prog_corregida)
            errores_porcentuales.append(error_porc)
            sentidos_aplicados.append(sentido)
            
            print(f"   ✅ Resultado: {prog_actual:.2f}km → {prog_corregida:.2f}km | Error: {error_porc:.2f}%")
    
    # Agregar nuevas columnas al GeoDataFrame
    gdf['prog_corregida'] = progresivas_corregidas
    gdf['error_porc_calc'] = errores_porcentuales
    gdf['sentido_ruta'] = sentidos_aplicados
    
    # Calcular diferencia en km
    gdf['diff_km'] = gdf['prog_corregida'] - gdf['PROG_CALC']
    
    # Crear backup del archivo original
    backup_file = input_shp.replace('.shp', f'_backup_{datetime.now().strftime("%Y%m%d_%H%M")}.shp')
    print(f"💾 Creando backup: {backup_file}")
    
    # Guardar backup
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
        
    else:
        print("❌ Error en el procesamiento")

if __name__ == "__main__":
    main()