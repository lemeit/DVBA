"""
DVBA-Z6-PROGRESIVAS-CALCULADOR-002.py
===========================================================
SCRIPT: Calculador de Progresivas Viales - Rutas Provinciales Zona 6
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.2.0 (Generado: 2025-10-21)
CODIGO: DVBA-Z6-PROGRESIVAS-CALCULADOR-002

DESCRIPCIÓN:
    - Cálculo de progresivas kilométricas para puntos viales
    - Determinación automática del sentido de crecimiento por ruta
    - Integración con capa oficial de mojones cienkilométricos
    - Generación de metadatos institucionales DVBA

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

def determinar_sentido_desde_descripcion(descripcion):
    """
    Determina el sentido principal desde la descripción del mojón
    """
    descripcion = descripcion.upper()
    if 'NORTE' in descripcion or 'N' in descripcion:
        return 'NORTE-SUR'
    elif 'SUR' in descripcion or 'S' in descripcion:
        return 'SUR-NORTE'
    elif 'ESTE' in descripcion or 'E' in descripcion:
        return 'ESTE-OESTE'
    elif 'OESTE' in descripcion or 'O' in descripcion:
        return 'OESTE-ESTE'
    elif 'NOROESTE' in descripcion or 'NO' in descripcion:
        return 'NOROESTE-SURESTE'
    elif 'SURESTE' in descripcion or 'SE' in descripcion:
        return 'SURESTE-NOROESTE'
    elif 'NORESTE' in descripcion or 'NE' in descripcion:
        return 'NORESTE-SUROESTE'
    elif 'SUROESTE' in descripcion or 'SO' in descripcion:
        return 'SUROESTE-NORESTE'
    else:
        return None

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

def procesar_ruta_completa(puntos_gdf, ruta_numero):
    """
    Procesa todos los puntos de una ruta aplicando corrección de sentido
    """
    print(f"\n{'='*60}")
    print(f"PROCESANDO RUTA RP{ruta_numero}")
    print(f"{'='*60}")
    
    # Filtrar puntos de la ruta actual
    puntos_ruta = puntos_gdf[puntos_gdf['ruta_num'] == ruta_numero].copy()
    
    if len(puntos_ruta) == 0:
        print(f"❌ No hay puntos para la RP{ruta_numero}")
        return None
    
    # Obtener sentido de la ruta
    sentido = SENTIDOS_RUTAS.get(ruta_numero)
    if not sentido:
        print(f"⚠️  Sentido no definido para RP{ruta_numero}. Usando cálculo tradicional.")
        sentido = 'INDETERMINADO'
    
    print(f"📏 Sentido de crecimiento: {sentido}")
    print(f"📍 Cantidad de puntos a procesar: {len(puntos_ruta)}")
    
    # Aplicar corrección a cada punto
    progresivas_corregidas = []
    diferencias = []
    
    for idx, punto in puntos_ruta.iterrows():
        wp = punto.get('WP', 'N/A')
        mojon_base = punto['mojon_base']
        dist_mojon = punto['dist_mojon']
        prog_actual = punto.get('PROG_CALC', 0)
        
        # Calcular progresiva corregida
        progresiva_corregida = calcular_progresiva_corregida(punto, sentido)
        
        # Calcular diferencia
        diferencia = progresiva_corregida - prog_actual
        
        progresivas_corregidas.append(progresiva_corregida)
        diferencias.append(diferencia)
        
        print(f"   WP {wp}: Base={mojon_base}km, Dist={dist_mojon}m | "
              f"Actual: {prog_actual:.2f}km → Corregida: {progresiva_corregida:.2f}km | "
              f"Δ: {diferencia:+.2f}km")
    
    # Agregar resultados al GeoDataFrame
    puntos_ruta['PROG_CORREGIDA'] = progresivas_corregidas
    puntos_ruta['DIFERENCIA_KM'] = diferencias
    puntos_ruta['SENTIDO_RUTA'] = sentido
    
    # Estadísticas
    diff_abs = np.abs(diferencias)
    print(f"\n📊 Estadísticas RP{ruta_numero}:")
    print(f"   Diferencia máxima: {max(diferencias):.2f}km")
    print(f"   Diferencia mínima: {min(diferencias):.2f}km") 
    print(f"   Diferencia promedio: {np.mean(diferencias):.2f}km")
    print(f"   Desviación estándar: {np.std(diferencias):.2f}km")
    
    return puntos_ruta

def main():
    """Función principal"""
    print("=" * 70)
    print("CALCULADOR DE PROGRESIVAS VIALES - DVBA ZONA 6")
    print("=" * 70)
    print(f"ORGANISMO: {METADATOS_DVBA['organismo']}")
    print(f"DEPARTAMENTO: {METADATOS_DVBA['departamento']}")
    print(f"AUTOR: {METADATOS_DVBA['autor']}")
    print(f"PROYECTO: {METADATOS_DVBA['proyecto']}")
    print(f"FECHA: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)
    
    # RUTAS A PROCESAR
    rutas = [6, 20, 24, 30, 40, 41, 42, 43, 44, 46, 47, 48, 51, 61, 91]
    
    # CARGAR DATOS DE PUNTOS (ejemplo - adaptar según tu estructura)
    try:
        # Aquí cargarías tu GeoDataFrame de puntos
        # puntos_gdf = gpd.read_file("tu_archivo_puntos.shp")
        
        # Por ahora usaremos datos de ejemplo basados en tu estructura RP51
        print("📁 Cargando datos de puntos viales...")
        
        # SIMULACIÓN - crear datos de ejemplo para prueba
        datos_ejemplo = []
        for ruta in rutas:
            for i in range(3):  # 3 puntos por ruta de ejemplo
                datos_ejemplo.append({
                    'geometry': gpd.points_from_xy([-60 + i*0.1], [-35 + i*0.1])[0],
                    'ruta_num': ruta,
                    'WP': f"{ruta}.{i+1:02d}",
                    'mojon_base': 50 * (i + 1),
                    'dist_mojon': 5000 + i*1000,
                    'PROG_CALC': 50 * (i + 1) + (5000 + i*1000)/1000,
                    'lat_posgar': -35 + i*0.1,
                    'lon_posgar': -60 + i*0.1
                })
        
        puntos_gdf = gpd.GeoDataFrame(datos_ejemplo, crs="EPSG:5347")
        print(f"✅ Datos cargados: {len(puntos_gdf)} puntos totales")
        
    except Exception as e:
        print(f"❌ Error cargando datos: {e}")
        return
    
    # PROCESAR CADA RUTA
    resultados_completos = []
    
    for ruta in rutas:
        resultado_ruta = procesar_ruta_completa(puntos_gdf, ruta)
        if resultado_ruta is not None:
            resultados_completos.append(resultado_ruta)
    
    # COMBINAR RESULTADOS
    if resultados_completos:
        resultados_finales = pd.concat(resultados_completos, ignore_index=True)
        
        print(f"\n{'='*70}")
        print("RESUMEN FINAL DEL PROCESAMIENTO")
        print(f"{'='*70}")
        print(f"✅ Total de rutas procesadas: {len(resultados_completos)}")
        print(f"✅ Total de puntos corregidos: {len(resultados_finales)}")
        
        # Guardar resultados
        output_file = f"Progresivas_Corregidas_DVBA_{datetime.now().strftime('%Y%m%d_%H%M')}.csv"
        resultados_finales.to_csv(output_file, index=False, encoding='utf-8')
        print(f"💾 Resultados guardados en: {output_file}")
        
        # Mostrar resumen por ruta
        print(f"\n📋 Resumen por ruta:")
        for ruta in rutas:
            puntos_ruta = resultados_finales[resultados_finales['ruta_num'] == ruta]
            if len(puntos_ruta) > 0:
                sentido = puntos_ruta['SENTIDO_RUTA'].iloc[0]
                diff_prom = puntos_ruta['DIFERENCIA_KM'].mean()
                print(f"   RP{ruta}: {len(puntos_ruta)} puntos | Sentido: {sentido} | Δ prom: {diff_prom:+.2f}km")
    
    else:
        print("❌ No se procesaron resultados.")

if __name__ == "__main__":
    main()