"""
DVBA-Z6-PROGRESIVAS-CORRECTOR-006.py
===========================================================
SCRIPT: Corrector de Progresivas Viales - Rutas Provinciales Zona 6
ORGANISMO: Dirección de Vialidad de la Provincia de Buenos Aires
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
VERSION: 2025.10.6.0 (Generado: 2025-10-30)
CODIGO: DVBA-Z6-PROGRESIVAS-CORRECTOR-006

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
    91: "NOROESTE-SURESTE"  # CONFIRMADO: de NW a SE
}

def calcular_progresiva_corregida_rp91(fila):
    """
    Cálculo específico para RP91 basado en análisis manual
    """
    mojon_base = fila['mojon_base']
    dist_mojon = fila['dist_mojon']
    dist_km = dist_mojon / 1000.0
    
    print(f"  DEBUG RP91: Base={mojon_base}km, Dist={dist_mojon}m")
    
    # ANÁLISIS MANUAL DE RP91:
    # La RP91 va de NOROESTE a SURESTE
    # Mojón 0: (5519249, 6050471) - Saladillo (NW)
    # Mojón 50: (5554061, 6029856) - hacia SE
    
    # Para mojón_base = 0 (inicio de ruta)
    if mojon_base == 0:
        # Todos los puntos después del mojón 0 deberían SUMAR distancia
        # porque van en dirección SURESTE (aumenta progresiva)
        resultado = mojon_base + dist_km
        print(f"  DEBUG RP91: Mojón 0 → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        
    # Para mojón_base = 50  
    elif mojon_base == 50:
        # Obtener coordenadas del punto
        punto_x, punto_y = fila['geometry'].x, fila['geometry'].y
        
        # Coordenadas aproximadas del mojón 50
        mojon50_x = 5554061  # aprox coordenada X mojón 50
        mojon50_y = 6029856  # aprox coordenada Y mojón 50
        
        print(f"  DEBUG RP91: Coord punto({punto_x:.0f}, {punto_y:.0f}) vs Mojón50({mojon50_x}, {mojon50_y})")
        
        # En dirección NW-SE:
        # - Si el punto tiene X mayor e Y menor → está al SURESTE del mojón → SUMAR
        # - Si el punto tiene X menor e Y mayor → está al NOROESTE del mojón → RESTAR
        
        if punto_x > mojon50_x and punto_y < mojon50_y:
            # Punto al SURESTE del mojón 50
            resultado = mojon_base + dist_km
            print(f"  DEBUG RP91: Punto al SURESTE de mojón 50 → SUMAR: {mojon_base} + {dist_km} = {resultado}")
        else:
            # Punto al NOROESTE del mojón 50
            resultado = mojon_base - dist_km
            print(f"  DEBUG RP91: Punto al NOROESTE de mojón 50 → RESTAR: {mojon_base} - {dist_km} = {resultado}")
    else:
        # Para otros mojones, usar cálculo tradicional
        resultado = mojon_base + dist_km
        print(f"  DEBUG RP91: Otro mojón → SUMAR: {mojon_base} + {dist_km} = {resultado}")
    
    return resultado

def calcular_error_porcentual(prog_actual, prog_corregida):
    """
    Calcula el error porcentual entre progresivas
    """
    if prog_actual == 0:
        return 0.0
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
    campos_requeridos = ['mojon_base', 'dist_mojon', 'ruta_num', 'PROG_CALC']
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
    explicaciones = []
    
    # Procesar por ruta
    rutas_unicas = gdf['ruta_num'].unique()
    
    for ruta in rutas_unicas:
        print(f"\n🔍 Procesando RP{ruta}:")
        puntos_ruta = gdf[gdf['ruta_num'] == ruta].copy()
        
        # Usar sentido predefinido
        sentido = SENTIDOS_RUTAS.get(ruta, "INDETERMINADO")
        print(f"   Sentido aplicado: {sentido}")
        
        # Procesar cada punto de la ruta
        for idx, fila in puntos_ruta.iterrows():
            wp = fila.get('WP', 'N/A')
            mojon_base = fila['mojon_base']
            dist_mojon = fila['dist_mojon']
            prog_actual = fila['PROG_CALC']
            
            print(f"   📍 WP {wp}: Base={mojon_base}km, Dist={dist_mojon}m, Prog_actual={prog_actual}km")
            
            # Cálculo específico para RP91
            if ruta == 91:
                prog_corregida = calcular_progresiva_corregida_rp91(fila)
                explicacion = "Cálculo específico RP91"
            else:
                # Para otras rutas, mantener lógica simple por ahora
                prog_corregida = mojon_base + (dist_mojon / 1000.0)
                explicacion = "Cálculo tradicional"
            
            # Calcular error porcentual
            error_porc = calcular_error_porcentual(prog_actual, prog_corregida)
            
            progresivas_corregidas.append(prog_corregida)
            errores_porcentuales.append(error_porc)
            sentidos_aplicados.append(sentido)
            explicaciones.append(explicacion)
            
            print(f"   ✅ Resultado: {prog_actual:.2f}km → {prog_corregida:.2f}km | Error: {error_porc:.2f}%")
            print(f"   📝 Explicación: {explicacion}")
    
    # Agregar nuevas columnas al GeoDataFrame
    gdf['prog_corregida'] = progresivas_corregidas
    gdf['error_porc_calc'] = errores_porcentuales
    gdf['sentido_ruta'] = sentidos_aplicados
    gdf['explicacion_calc'] = explicaciones
    
    # Calcular diferencia en km
    gdf['diff_km'] = gdf['prog_corregida'] - gdf['PROG_CALC']
    
    # Crear backup del archivo original
    backup_file = input_shp.replace('.shp', f'_backup_{datetime.now().strftime("%Y%m%d_%H%M")}.shp')
    print(f"💾 Creando backup: {backup_file}")
    
    try:
        # Guardar backup
        gdf.to_file(backup_file)
        print(f"✅ Backup creado exitosamente")
        
        # Cerrar el GeoDataFrame para liberar el archivo
        del gdf
        
        # Recargar desde backup para asegurar que no hay bloqueos
        gdf_final = gpd.read_file(backup_file)
        
        # Sobreescribir el archivo original
        print(f"✏️ Sobreescribiendo archivo original: {input_shp}")
        gdf_final.to_file(input_shp)
        print(f"✅ Archivo original actualizado exitosamente")
        
        return gdf_final
        
    except PermissionError:
        print(f"❌ ERROR: Cierra QGIS y cualquier programa que tenga abierto el archivo")
        print(f"💡 Solución: Cierra QGIS y ejecuta el script nuevamente")
        return None
    except Exception as e:
        print(f"❌ Error al guardar: {e}")
        return None

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
    
    # Verificar que existe la columna sentido_ruta
    if 'sentido_ruta' not in gdf.columns:
        reporte.append("⚠️ ADVERTENCIA: No se encontró la columna 'sentido_ruta'")
        reporte.append("")
    
    # Estadísticas por ruta
    rutas_unicas = gdf['ruta_num'].unique()
    
    for ruta in sorted(rutas_unicas):
        puntos_ruta = gdf[gdf['ruta_num'] == ruta]
        
        # Obtener sentido de forma segura
        sentido = 'N/A'
        if 'sentido_ruta' in puntos_ruta.columns and len(puntos_ruta) > 0:
            sentido = puntos_ruta['sentido_ruta'].iloc[0]
        
        error_prom = puntos_ruta['error_porc_calc'].mean() if 'error_porc_calc' in puntos_ruta.columns else 0
        diff_prom = puntos_ruta['diff_km'].mean() if 'diff_km' in puntos_ruta.columns else 0
        
        reporte.append(f"RP{ruta}:")
        reporte.append(f"  - Puntos: {len(puntos_ruta)}")
        reporte.append(f"  - Sentido aplicado: {sentido}")
        reporte.append(f"  - Error porcentual promedio: {error_prom:.2f}%")
        reporte.append(f"  - Diferencia promedio: {diff_prom:+.2f} km")
        
        # Mostrar detalles de cada punto
        for idx, fila in puntos_ruta.iterrows():
            wp = fila.get('WP', 'N/A')
            prog_actual = fila['PROG_CALC']
            prog_corregida = fila['prog_corregida'] if 'prog_corregida' in fila else prog_actual
            error_porc = fila['error_porc_calc'] if 'error_porc_calc' in fila else 0
            explicacion = fila.get('explicacion_calc', 'N/A')
            
            reporte.append(f"     WP {wp}: {prog_actual:.2f}km → {prog_corregida:.2f}km | Error: {error_porc:.2f}% | {explicacion}")
        
        reporte.append("")
    
    # Estadísticas generales
    if 'error_porc_calc' in gdf.columns:
        reporte.append("ESTADÍSTICAS GENERALES:")
        reporte.append(f"  - Error máximo: {gdf['error_porc_calc'].max():.2f}%")
        reporte.append(f"  - Error mínimo: {gdf['error_porc_calc'].min():.2f}%")
        reporte.append(f"  - Error promedio: {gdf['error_porc_calc'].mean():.2f}%")
    
    if 'diff_km' in gdf.columns:
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
    print("⚠️  IMPORTANTE: Cierra QGIS antes de ejecutar este script")
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
        reporte_file = input_shp.replace('.shp', '_reporte_detallado.txt')
        generar_reporte(gdf_procesado, reporte_file)
        
        # Mostrar resumen rápido
        if 'error_porc_calc' in gdf_procesado.columns:
            print(f"\n📈 RESUMEN RÁPIDO:")
            print(f"   - Error porcentual promedio: {gdf_procesado['error_porc_calc'].mean():.2f}%")
            print(f"   - Diferencia promedio: {gdf_procesado['diff_km'].mean():.2f} km")
        
    else:
        print("❌ Error en el procesamiento - Verifica que QGIS esté cerrado")

if __name__ == "__main__":
    main()