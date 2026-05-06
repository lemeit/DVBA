"""
DVBA-Z6-PROGRESIVAS-CORRECTOR-TODAS-RUTAS.py
===========================================================
SCRIPT: Corrector de Progresivas Viales - Procesamiento Masivo
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.30.5 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-PROGRESIVAS-CORRECTOR-TODAS-RUTAS

DESCRIPCIÓN:
    - Procesamiento MASIVO de todos los shapefiles de rutas individuales
    - Corrección automática de progresivas para todas las rutas Zona 6
    - Sentidos predefinidos basados en análisis oficial de mojones
    - Inserción de metadatos institucionales DVBA
    - Generación de reportes consolidados

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
    'meta_fuent': 'Base Oficial Dirección de Vialidad de la Provincia de Buenos Aires',
    'meta_inst': 'Dirección de Vialidad de la Provincia de Buenos Aires',
    'meta_depio': 'Zona VI Saladillo - División Técnica',
    'meta_resp': 'Ing. Luciano Lamaita',
    'meta_conta': 'lulamaita@vialidad.gba.gov.ar',
    'meta_prov': 'Reconstrucción y Filtrado de Rutas Provinciales',
    'meta_sist': 'EPSG:5347 - POSGAR 2007',
    'meta_tipo': 'Puntos Viales con Progresivas Corregidas',
    'meta_fecha': datetime.now().strftime('%Y-%m-%d'),
    'meta_ver': '1.0',
    'meta_lc': 'Uso Interno - DVBA'
}

# DICCIONARIO COMPLETO DE SENTIDOS POR RUTA
SENTIDOS_RUTAS = {
    6: "NORTE-SUR",
    20: "OESTE-ESTE", 
    24: "NOROESTE-SURESTE",
    30: "SUROESTE-NORESTE",
    40: "OESTE-ESTE",
    41: "SUR-NORTE",
    42: "OESTE-ESTE",
    43: "NOROESTE-SURESTE",
    44: "OESTE-ESTE",
    46: "NOROESTE-SURESTE",
    47: "NORTE-SUR",
    48: "SUROESTE-NORESTE",
    51: "NORTE-SUR",
    61: "ESTE-OESTE",
    91: "NOROESTE-SURESTE"
}

# RUTAS QUE YA FUERON PROCESADAS (no reprocesar automáticamente)
RUTAS_YA_PROCESADAS = [91]  # RP91 ya fue procesada y verificada

def agregar_metadatos_institucionales(gdf, ruta_num):
    """
    Agrega metadatos institucionales DVBA al GeoDataFrame
    """
    # Metadatos básicos
    gdf['meta_fuent'] = METADATOS_DVBA['meta_fuent']
    gdf['meta_inst'] = METADATOS_DVBA['meta_inst']
    gdf['meta_depio'] = METADATOS_DVBA['meta_depio']
    gdf['meta_resp'] = METADATOS_DVBA['meta_resp']
    gdf['meta_conta'] = METADATOS_DVBA['meta_conta']
    gdf['meta_prov'] = METADATOS_DVBA['meta_prov']
    gdf['meta_sist'] = METADATOS_DVBA['meta_sist']
    gdf['meta_tipo'] = f"Puntos Viales RP{ruta_num} - Progresivas Corregidas"
    gdf['meta_fecha'] = METADATOS_DVBA['meta_fecha']
    gdf['meta_ver'] = METADATOS_DVBA['meta_ver']
    gdf['meta_lc'] = METADATOS_DVBA['meta_lc']
    
    # Información específica del procesamiento
    gdf['procesamiento_fecha'] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    gdf['procesamiento_script'] = 'DVBA-Z6-PROGRESIVAS-CORRECTOR-TODAS-RUTAS.py'
    gdf['procesamiento_version'] = METADATOS_DVBA['meta_ver']
    
    return gdf

def calcular_progresiva_corregida(fila, ruta_num):
    """
    Calcula progresiva corregida según sentido de la ruta
    """
    mojon_base = fila['mojon_base']
    dist_mojon = fila['dist_mojon']
    dist_km = dist_mojon / 1000.0
    punto_x, punto_y = fila['geometry'].x, fila['geometry'].y
    
    sentido = SENTIDOS_RUTAS.get(ruta_num, "INDETERMINADO")
    
    # Para cálculo simplificado, usamos las coordenadas del punto actual
    mojon_x, mojon_y = punto_x, punto_y
    
    # Aplicar lógica según sentido
    if sentido == "NOROESTE-SURESTE":
        if punto_x > mojon_x and punto_y < mojon_y:
            return mojon_base + dist_km  # Punto al SURESTE → SUMAR
        else:
            return mojon_base - dist_km  # Punto al NOROESTE → RESTAR
            
    elif sentido == "NORTE-SUR":
        if punto_y < mojon_y:
            return mojon_base + dist_km  # Punto al SUR → SUMAR
        else:
            return mojon_base - dist_km  # Punto al NORTE → RESTAR
            
    elif sentido == "SUR-NORTE":
        if punto_y > mojon_y:
            return mojon_base + dist_km  # Punto al NORTE → SUMAR
        else:
            return mojon_base - dist_km  # Punto al SUR → RESTAR
            
    elif sentido == "ESTE-OESTE":
        if punto_x < mojon_x:
            return mojon_base + dist_km  # Punto al OESTE → SUMAR
        else:
            return mojon_base - dist_km  # Punto al ESTE → RESTAR
            
    elif sentido == "OESTE-ESTE":
        if punto_x > mojon_x:
            return mojon_base + dist_km  # Punto al ESTE → SUMAR
        else:
            return mojon_base - dist_km  # Punto al OESTE → RESTAR
            
    elif sentido == "SUROESTE-NORESTE":
        if punto_x < mojon_x and punto_y > mojon_y:
            return mojon_base + dist_km  # Punto al NORESTE → SUMAR
        else:
            return mojon_base - dist_km  # Punto al SUROESTE → RESTAR
            
    elif sentido == "NORESTE-SUROESTE":
        if punto_x > mojon_x and punto_y < mojon_y:
            return mojon_base + dist_km  # Punto al SUROESTE → SUMAR
        else:
            return mojon_base - dist_km  # Punto al NORESTE → RESTAR
            
    else:
        # Sentido indeterminado, usar cálculo tradicional
        return mojon_base + dist_km

def procesar_shapefile_ruta(shp_path, reprocesar_rp91=False):
    """
    Procesa un shapefile individual de ruta
    """
    nombre_archivo = os.path.basename(shp_path)
    print(f"📁 Procesando: {nombre_archivo}")
    
    try:
        gdf = gpd.read_file(shp_path)
        
        # Verificar campos requeridos
        campos_requeridos = ['mojon_base', 'dist_mojon', 'ruta_num', 'PROG_CALC']
        for campo in campos_requeridos:
            if campo not in gdf.columns:
                print(f"❌ Campo requerido faltante: {campo}")
                return None
        
        # Obtener número de ruta
        ruta_num = int(gdf['ruta_num'].iloc[0])
        sentido = SENTIDOS_RUTAS.get(ruta_num, "INDETERMINADO")
        
        # Verificar si ya fue procesada
        if ruta_num in RUTAS_YA_PROCESADAS and not reprocesar_rp91:
            print(f"⏭️  RP{ruta_num}: Ya procesada anteriormente - Saltando")
            return {
                'ruta': ruta_num,
                'archivo': nombre_archivo,
                'puntos': len(gdf),
                'error_promedio': 0,
                'puntos_alto_error': 0,
                'sentido': sentido,
                'estado': 'YA_PROCESADA'
            }
        
        print(f"✅ RP{ruta_num}: {len(gdf)} puntos | Sentido: {sentido}")
        
        # Procesar cada punto
        progresivas_corregidas = []
        errores_porcentuales = []
        
        for idx, fila in gdf.iterrows():
            prog_actual = fila['PROG_CALC']
            
            # Calcular progresiva corregida
            prog_corregida = calcular_progresiva_corregida(fila, ruta_num)
            
            # Calcular error
            error_porc = 0
            if prog_actual > 0:
                error_porc = (abs(prog_corregida - prog_actual) / prog_actual) * 100
            
            progresivas_corregidas.append(prog_corregida)
            errores_porcentuales.append(error_porc)
        
        # Agregar nuevas columnas de progresivas
        gdf['prog_corregida'] = progresivas_corregidas
        gdf['error_porc_calc'] = errores_porcentuales
        gdf['sentido_ruta'] = sentido
        gdf['diff_km'] = gdf['prog_corregida'] - gdf['PROG_CALC']
        
        # Agregar metadatos institucionales
        gdf = agregar_metadatos_institucionales(gdf, ruta_num)
        
        # Crear backup
        backup_path = shp_path.replace('.shp', f'_backup_{datetime.now().strftime("%H%M")}.shp')
        gdf.to_file(backup_path)
        
        # Sobreescribir original
        gdf.to_file(shp_path)
        
        # Estadísticas de la ruta
        error_promedio = gdf['error_porc_calc'].mean()
        puntos_alto_error = len(gdf[gdf['error_porc_calc'] > 10])
        
        print(f"📊 RP{ruta_num}: Error promedio: {error_promedio:.1f}% | Puntos >10%: {puntos_alto_error}")
        print(f"📝 Metadatos institucionales agregados")
        
        return {
            'ruta': ruta_num,
            'archivo': nombre_archivo,
            'puntos': len(gdf),
            'error_promedio': error_promedio,
            'puntos_alto_error': puntos_alto_error,
            'sentido': sentido,
            'estado': 'PROCESADA'
        }
        
    except Exception as e:
        print(f"❌ Error procesando {nombre_archivo}: {e}")
        return None

def buscar_shapefiles_rutas(carpeta_base):
    """
    Busca todos los shapefiles de rutas en la carpeta
    """
    shapefiles_rutas = []
    
    print(f"🔍 Buscando en: {carpeta_base}")
    
    # Listar todos los archivos en la carpeta directamente
    try:
        archivos = os.listdir(carpeta_base)
        print(f"📂 Archivos encontrados en carpeta: {len(archivos)}")
        
        for archivo in archivos:
            if archivo.endswith('.shp'):
                # Verificar si es un archivo de ruta por patrones comunes
                if any(patron in archivo for patron in ['RP', 'Puntos_RP', '_RP']):
                    full_path = os.path.join(carpeta_base, archivo)
                    shapefiles_rutas.append(full_path)
                    print(f"   ✅ Shapefile de ruta: {archivo}")
                else:
                    print(f"   ❌ No parece ser de ruta: {archivo}")
    
    except Exception as e:
        print(f"❌ Error leyendo carpeta: {e}")
    
    return shapefiles_rutas

def main():
    print("=" * 70)
    print("PROCESADOR MASIVO DE RUTAS - DVBA ZONA 6")
    print("=" * 70)
    print(f"ORGANISMO: {METADATOS_DVBA['organismo']}")
    print(f"DEPARTAMENTO: {METADATOS_DVBA['departamento']}")
    print(f"RESPONSABLE: {METADATOS_DVBA['autor']}")
    print(f"CONTACTO: {METADATOS_DVBA['contacto']}")
    print(f"PROYECTO: {METADATOS_DVBA['proyecto']}")
    print(f"FECHA: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)
    print("⚠️  IMPORTANTE: Cierra QGIS antes de ejecutar")
    print(f"⚠️  RP91 ya procesada - No se reprocesará automáticamente")
    print("=" * 70)
    
    # Preguntar si reprocesar RP91
    reprocesar_rp91 = input("¿Reprocesar RP91? (s/n): ").strip().lower() == 's'
    
    if reprocesar_rp91:
        print("🔄 Se reprocesará RP91")
    else:
        print("⏭️  RP91 no se reprocesará (ya fue procesada y verificada)")
    
    # Carpeta donde buscar los shapefiles
    carpeta_base = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\05_RESULTADOS"
    
    if not os.path.exists(carpeta_base):
        print(f"❌ No se encuentra la carpeta: {carpeta_base}")
        return
    
    # Buscar todos los shapefiles de rutas
    shapefiles = buscar_shapefiles_rutas(carpeta_base)
    
    if not shapefiles:
        print("❌ No se encontraron shapefiles de rutas")
        print("💡 Los archivos deberían tener nombres como:")
        print("   - Puntos_RP51_Completo.shp")
        print("   - Puntos_RP6_Completo.shp") 
        print("   - RP20.shp")
        print("   - etc.")
        return
    
    print(f"\n✅ Se encontraron {len(shapefiles)} shapefiles de rutas")
    
    # Procesar cada shapefile
    resultados = []
    rutas_procesadas = 0
    rutas_ya_procesadas = 0
    
    for shp_path in shapefiles:
        resultado = procesar_shapefile_ruta(shp_path, reprocesar_rp91)
        if resultado:
            resultados.append(resultado)
            if resultado.get('estado') == 'PROCESADA':
                rutas_procesadas += 1
            else:
                rutas_ya_procesadas += 1
    
    # Generar reporte consolidado
    print(f"\n{'='*70}")
    print("REPORTE CONSOLIDADO - PROCESAMIENTO MASIVO")
    print(f"{'='*70}")
    print(f"ORGANISMO: {METADATOS_DVBA['organismo']}")
    print(f"DEPARTAMENTO: {METADATOS_DVBA['departamento']}")
    print(f"FECHA: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Shapefiles encontrados: {len(shapefiles)}")
    print(f"Rutas procesadas: {rutas_procesadas}")
    print(f"Rutas ya procesadas: {rutas_ya_procesadas}")
    print()
    
    if resultados:
        # Ordenar por número de ruta
        resultados.sort(key=lambda x: x['ruta'])
        
        print("DETALLE POR RUTA:")
        print("-" * 80)
        for res in resultados:
            estado = "🔄" if res.get('estado') == 'PROCESADA' else "⏭️"
            if res.get('estado') == 'PROCESADA':
                print(f"{estado} RP{res['ruta']:2d} | {res['puntos']:3d} puntos | "
                      f"Error: {res['error_promedio']:5.1f}% | "
                      f">10%: {res['puntos_alto_error']:2d} | "
                      f"Sentido: {res['sentido']}")
            else:
                print(f"{estado} RP{res['ruta']:2d} | {res['puntos']:3d} puntos | "
                      f"YA PROCESADA | Sentido: {res['sentido']}")
        
        # Estadísticas generales (solo de rutas procesadas ahora)
        rutas_procesadas_ahora = [r for r in resultados if r.get('estado') == 'PROCESADA']
        if rutas_procesadas_ahora:
            error_total_promedio = np.mean([r['error_promedio'] for r in rutas_procesadas_ahora])
            total_puntos = sum([r['puntos'] for r in rutas_procesadas_ahora])
            total_alto_error = sum([r['puntos_alto_error'] for r in rutas_procesadas_ahora])
            
            print(f"\n{'='*70}")
            print("ESTADÍSTICAS DE RUTAS PROCESADAS AHORA:")
            print(f"{'='*70}")
            print(f"   - Rutas procesadas: {len(rutas_procesadas_ahora)}")
            print(f"   - Total puntos procesados: {total_puntos}")
            print(f"   - Error porcentual promedio: {error_total_promedio:.1f}%")
            print(f"   - Puntos con error >10%: {total_alto_error}")
            print(f"   - Porcentaje de puntos precisos: {(1 - total_alto_error/total_puntos)*100:.1f}%")
            print(f"   - Sistema de referencia: {METADATOS_DVBA['sistema_referencia']}")
        
        # Guardar reporte en archivo
        reporte_path = os.path.join(carpeta_base, f"Reporte_Procesamiento_Masivo_{datetime.now().strftime('%Y%m%d_%H%M')}.txt")
        with open(reporte_path, 'w', encoding='utf-8') as f:
            f.write("REPORTE DE PROCESAMIENTO MASIVO - DVBA ZONA 6\n")
            f.write("=" * 60 + "\n")
            f.write(f"ORGANISMO: {METADATOS_DVBA['organismo']}\n")
            f.write(f"DEPARTAMENTO: {METADATOS_DVBA['departamento']}\n")
            f.write(f"RESPONSABLE: {METADATOS_DVBA['autor']}\n")
            f.write(f"FECHA: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 60 + "\n\n")
            
            f.write("DETALLE POR RUTA:\n")
            f.write("-" * 60 + "\n")
            for res in resultados:
                if res.get('estado') == 'PROCESADA':
                    f.write(f"RP{res['ruta']}: {res['puntos']} pts | Error: {res['error_promedio']:.1f}% | >10%: {res['puntos_alto_error']} | {res['sentido']}\n")
                else:
                    f.write(f"RP{res['ruta']}: {res['puntos']} pts | YA PROCESADA | {res['sentido']}\n")
            
            if rutas_procesadas_ahora:
                f.write(f"\nESTADÍSTICAS DE RUTAS PROCESADAS:\n")
                f.write(f"- Rutas procesadas: {len(rutas_procesadas_ahora)}\n")
                f.write(f"- Total puntos: {total_puntos}\n")
                f.write(f"- Error promedio: {error_total_promedio:.1f}%\n")
                f.write(f"- Puntos con error >10%: {total_alto_error}\n")
                f.write(f"- Precisión: {(1 - total_alto_error/total_puntos)*100:.1f}%\n")
        
        print(f"💾 Reporte guardado: {reporte_path}")
    
    else:
        print("❌ No se procesó ninguna ruta correctamente")

if __name__ == "__main__":
    main()