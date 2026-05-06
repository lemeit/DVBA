"""
DVBA_Z6_VALIDACION_FINAL.py
===========================================================
VALIDACIÓN FINAL: Capas limpias vs Base oficial
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

def cargar_base_oficial():
    """Carga la base oficial de tramos"""
    print("📊 CARGANDO BASE OFICIAL...")
    
    csv_path = os.path.join(CONFIG['tablas_csv'], 'SALADILLO_RED.csv')
    
    if not os.path.exists(csv_path):
        print(f"❌ No se encuentra el archivo: {csv_path}")
        return None
    
    try:
        df = pd.read_csv(csv_path, sep=';', encoding='latin-1')
        print(f"✅ Base oficial cargada: {len(df)} registros")
        
        # Limpiar y estandarizar datos
        df['RUTA'] = df['RUTA'].astype(str).str.strip()
        df['PARTIDO'] = df['PARTIDO'].astype(str).str.strip().str.zfill(3)
        df['Longitud en metros'] = pd.to_numeric(df['Longitud en metros'], errors='coerce')
        
        # Mostrar estadísticas
        rutas_unicas = df['RUTA'].unique()
        partidos_unicos = df['PARTIDO'].unique()
        longitud_total = df['Longitud en metros'].sum() / 1000
        
        print(f"   🛣️  Rutas en base: {sorted(rutas_unicas)}")
        print(f"   🏛️  Partidos en base: {sorted(partidos_unicos)}")
        print(f"   📏 Longitud total oficial: {longitud_total:.2f} km")
        
        return df
        
    except Exception as e:
        print(f"❌ Error cargando base oficial: {e}")
        return None

def encontrar_capas_limpias():
    """Encuentra las capas ya limpiadas"""
    print("\n📁 BUSCANDO CAPAS LIMPIAS...")
    
    patrones = [
        os.path.join(CONFIG['proyecto'], "03_CAPAS_GENERADAS", "**", "RP*_POR_PARTIDOS", "*.shp"),
        os.path.join(CONFIG['proyecto'], "05_RESULTADOS", "**", "RP*", "*.shp"),
    ]
    
    capas_encontradas = []
    for patron in patrones:
        try:
            capas = glob.glob(patron, recursive=True)
            for capa in capas:
                nombre = os.path.basename(capa)
                if 'Segmentada_Por_Partidos' not in nombre and capa not in capas_encontradas:
                    capas_encontradas.append(capa)
        except Exception as e:
            print(f"❌ Error: {e}")
    
    print(f"✅ Capas encontradas: {len(capas_encontradas)}")
    return capas_encontradas

def extraer_info_capa(archivo):
    """Extrae información básica de una capa"""
    nombre_archivo = os.path.basename(archivo)
    
    # Extraer número de ruta
    if nombre_archivo.startswith('RP'):
        ruta_num = nombre_archivo[2:4] if nombre_archivo[2:4].isdigit() else nombre_archivo[2:3]
    else:
        ruta_num = 'XX'
    
    return nombre_archivo, ruta_num

def validar_capa_vs_oficial(archivo, base_oficial):
    """Valida una capa contra la base oficial"""
    nombre_archivo, ruta_num = extraer_info_capa(archivo)
    
    try:
        gdf = gpd.read_file(archivo)
        
        # Verificar campos esenciales
        campos_requeridos = ['partido_no', 'partido_co', 'longitud_m']
        campos_faltantes = [campo for campo in campos_requeridos if campo not in gdf.columns]
        
        if campos_faltantes:
            return {
                'archivo': nombre_archivo,
                'ruta': f"RP{ruta_num}",
                'estado': 'ERROR_CAMPOS_FALTANTES',
                'partido_nombre': 'N/A',
                'partido_codigo': 'N/A',
                'longitud_generada_km': 0,
                'longitud_oficial_km': 0,
                'diferencia_km': 0,
                'diferencia_%': 100,
                'error': f'Faltan campos: {campos_faltantes}'
            }
        
        # Obtener datos de la capa
        partido_nombre = gdf['partido_no'].iloc[0]
        partido_codigo = gdf['partido_co'].iloc[0]
        longitud_generada = gdf['longitud_m'].sum()
        
        # Buscar en base oficial
        filtro_oficial = (base_oficial['RUTA'] == ruta_num) & (base_oficial['PARTIDO'] == partido_codigo)
        tramos_oficiales = base_oficial[filtro_oficial]
        
        if len(tramos_oficiales) == 0:
            return {
                'archivo': nombre_archivo,
                'ruta': f"RP{ruta_num}",
                'estado': 'NO_ENCONTRADO_OFICIAL',
                'partido_nombre': partido_nombre,
                'partido_codigo': partido_codigo,
                'longitud_generada_km': round(longitud_generada / 1000, 2),
                'longitud_oficial_km': 0,
                'diferencia_km': 0,
                'diferencia_%': 100,
                'error': f'No hay datos oficiales para RP{ruta_num} - Partido {partido_codigo}'
            }
        
        # Calcular diferencias
        longitud_oficial = tramos_oficiales['Longitud en metros'].sum()
        diferencia = abs(longitud_generada - longitud_oficial)
        diferencia_porc = (diferencia / longitud_oficial * 100) if longitud_oficial > 0 else 100
        
        # Determinar estado
        if diferencia_porc <= 2.0:
            estado = '✅ VÁLIDO'
        elif diferencia_porc <= 5.0:
            estado = '⚠️  TOLERANCIA'
        else:
            estado = '❌ FUERA_TOLERANCIA'
        
        return {
            'archivo': nombre_archivo,
            'ruta': f"RP{ruta_num}",
            'estado': estado,
            'partido_nombre': partido_nombre,
            'partido_codigo': partido_codigo,
            'longitud_generada_km': round(longitud_generada / 1000, 2),
            'longitud_oficial_km': round(longitud_oficial / 1000, 2),
            'diferencia_km': round(diferencia / 1000, 2),
            'diferencia_%': round(diferencia_porc, 1),
            'segmentos_generados': len(gdf),
            'tramos_oficiales': len(tramos_oficiales)
        }
        
    except Exception as e:
        return {
            'archivo': nombre_archivo,
            'ruta': f"RP{ruta_num}",
            'estado': 'ERROR_LECTURA',
            'partido_nombre': 'N/A',
            'partido_codigo': 'N/A',
            'longitud_generada_km': 0,
            'longitud_oficial_km': 0,
            'diferencia_km': 0,
            'diferencia_%': 100,
            'error': str(e)
        }

def generar_reporte_detallado(resultados, base_oficial):
    """Genera reporte detallado de validación"""
    print(f"\n📊 GENERANDO REPORTES...")
    
    os.makedirs(CONFIG['reportes_dir'], exist_ok=True)
    
    df_resultados = pd.DataFrame(resultados)
    
    # Reporte CSV completo
    reporte_csv = os.path.join(CONFIG['reportes_dir'], 'validacion_final_detalle.csv')
    df_resultados.to_csv(reporte_csv, index=False, encoding='utf-8')
    print(f"✅ Reporte detallado: {reporte_csv}")
    
    # Reporte resumido por ruta
    if len(df_resultados) > 0:
        resumen_rutas = df_resultados.groupby('ruta').agg({
            'longitud_generada_km': 'sum',
            'longitud_oficial_km': 'sum',
            'diferencia_km': 'sum',
            'archivo': 'count'
        }).round(2)
        
        resumen_rutas['diferencia_%'] = (resumen_rutas['diferencia_km'] / resumen_rutas['longitud_oficial_km'] * 100).round(1)
        resumen_rutas = resumen_rutas.rename(columns={'archivo': 'capas'})
        
        reporte_resumen = os.path.join(CONFIG['reportes_dir'], 'validacion_final_resumen.csv')
        resumen_rutas.to_csv(reporte_resumen, encoding='utf-8')
        print(f"✅ Reporte resumido: {reporte_resumen}")
    
    return df_resultados

def mostrar_estadisticas_finales(df_resultados, base_oficial):
    """Muestra estadísticas finales de la validación"""
    print(f"\n{'='*70}")
    print("🎯 ESTADÍSTICAS FINALES DE VALIDACIÓN")
    print(f"{'='*70}")
    
    if len(df_resultados) == 0:
        print("❌ No hay resultados para mostrar")
        return
    
    # Estadísticas generales
    total_capas = len(df_resultados)
    validas = len(df_resultados[df_resultados['estado'] == '✅ VÁLIDO'])
    tolerancia = len(df_resultados[df_resultados['estado'] == '⚠️  TOLERANCIA'])
    problemas = len(df_resultados[df_resultados['estado'] == '❌ FUERA_TOLERANCIA'])
    errores = len(df_resultados[df_resultados['estado'].str.startswith('ERROR')])
    no_encontrados = len(df_resultados[df_resultados['estado'] == 'NO_ENCONTRADO_OFICIAL'])
    
    # Longitudes
    longitud_total_generada = df_resultados['longitud_generada_km'].sum()
    longitud_total_oficial = df_resultados['longitud_oficial_km'].sum()
    diferencia_total = abs(longitud_total_generada - longitud_total_oficial)
    
    print(f"📊 RESUMEN GENERAL:")
    print(f"   • Capas validadas: {total_capas}")
    print(f"   • ✅ Válidas (<2%): {validas} ({(validas/total_capas)*100:.1f}%)")
    print(f"   • ⚠️  Tolerancia (2-5%): {tolerancia} ({(tolerancia/total_capas)*100:.1f}%)")
    print(f"   • ❌ Fuera tolerancia (>5%): {problemas} ({(problemas/total_capas)*100:.1f}%)")
    print(f"   • 🔍 No encontrados en base: {no_encontrados}")
    print(f"   • 💥 Con errores: {errores}")
    
    print(f"\n📏 LONGITUDES TOTALES:")
    print(f"   • Generada: {longitud_total_generada:.2f} km")
    print(f"   • Oficial: {longitud_total_oficial:.2f} km")
    print(f"   • Diferencia: {diferencia_total:.2f} km ({(diferencia_total/longitud_total_oficial)*100:.1f}%)")
    
    # Mostrar problemas específicos
    if problemas > 0:
        print(f"\n🔴 CAPAS CON PROBLEMAS (>5% diferencia):")
        problemas_df = df_resultados[df_resultados['estado'] == '❌ FUERA_TOLERANCIA']
        for _, row in problemas_df.iterrows():
            print(f"   • {row['archivo']}: {row['diferencia_%']}% dif")
    
    if no_encontrados > 0:
        print(f"\n🔍 CAPAS NO ENCONTRADAS EN BASE OFICIAL:")
        no_encontrados_df = df_resultados[df_resultados['estado'] == 'NO_ENCONTRADO_OFICIAL']
        for _, row in no_encontrados_df.iterrows():
            print(f"   • {row['archivo']}: {row['partido_nombre']}")

def main():
    """Función principal"""
    print("=" * 70)
    print("DVBA - VALIDACIÓN FINAL VS BASE OFICIAL")
    print("=" * 70)
    
    # 1. Cargar base oficial
    base_oficial = cargar_base_oficial()
    if base_oficial is None:
        return
    
    # 2. Encontrar capas limpias
    capas = encontrar_capas_limpias()
    if not capas:
        print("❌ No se encontraron capas para validar")
        return
    
    # 3. Validar cada capa
    print(f"\n📏 VALIDANDO {len(capas)} CAPAS...")
    
    resultados = []
    for i, capa in enumerate(capas, 1):
        print(f"[{i}/{len(capas)}] {os.path.basename(capa)}")
        resultado = validar_capa_vs_oficial(capa, base_oficial)
        resultados.append(resultado)
        
        # Mostrar resultado inmediato
        if resultado['estado'] == '✅ VÁLIDO':
            print(f"   ✅ {resultado['partido_nombre']} - Dif: {resultado['diferencia_%']}%")
        elif resultado['estado'] == '⚠️  TOLERANCIA':
            print(f"   ⚠️  {resultado['partido_nombre']} - Dif: {resultado['diferencia_%']}%")
        elif resultado['estado'] == '❌ FUERA_TOLERANCIA':
            print(f"   ❌ {resultado['partido_nombre']} - Dif: {resultado['diferencia_%']}%")
        else:
            print(f"   🔴 {resultado['estado']}")
    
    # 4. Generar reportes y estadísticas
    df_resultados = generar_reporte_detallado(resultados, base_oficial)
    mostrar_estadisticas_finales(df_resultados, base_oficial)
    
    print(f"\n💾 Reportes guardados en: {CONFIG['reportes_dir']}")

if __name__ == "__main__":
    main()