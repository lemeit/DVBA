"""
DVBA_Z6_VALIDACION_MULTIDISCO_CORREGIDO.py
===========================================================
VALIDACIÓN MULTIDISCO: Valida capas corregidas en todos los discos
"""

import geopandas as gpd
import pandas as pd
import os
import glob

# CONFIGURACIÓN MULTIDISCO CORREGIDA
CONFIG = {
    'discos': [
        # OneDrive
        r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
        
        # Google Drive - RUTA CORREGIDA
        r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales",
        
        # Discos alternativos
        r"C:\Users\Of. Técnica Z6\Documents\QGIS FIles\Proyecto_Redes_Viales",
        r"C:\DVBA_CAPAS_CORREGIDAS"
    ],
    'tablas_csv': [
        r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\04_TABLAS",
        r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\04_TABLAS"
    ],
    'salida_reportes': r"C:\DVBA_REPORTES_VALIDACION"
}

def cargar_base_oficial_multidisco():
    """Carga la base oficial desde múltiples ubicaciones"""
    print("🔍 BUSCANDO BASE OFICIAL...")
    
    for ubicacion in CONFIG['tablas_csv']:
        if os.path.exists(ubicacion):
            csv_path = os.path.join(ubicacion, 'SALADILLO_RED.csv')
            if os.path.exists(csv_path):
                try:
                    df = pd.read_csv(csv_path, sep=';', encoding='latin-1')
                    print(f"✅ Base cargada desde: {csv_path}")
                    print(f"   📊 Registros: {len(df)}")
                    
                    # Limpiar datos
                    df['RUTA'] = df['RUTA'].astype(str).str.strip()
                    df['PARTIDO'] = df['PARTIDO'].astype(str).str.strip().str.zfill(3)
                    df['Longitud en metros'] = pd.to_numeric(df['Longitud en metros'], errors='coerce')
                    
                    # Mostrar estadísticas
                    rutas_unicas = df['RUTA'].unique()
                    partidos_unicos = df['PARTIDO'].unique()
                    print(f"   🛣️  Rutas en base: {sorted(rutas_unicas)}")
                    print(f"   🏛️  Partidos en base: {sorted(partidos_unicos)}")
                    print(f"   📏 Longitud total: {df['Longitud en metros'].sum() / 1000:.2f} km")
                    
                    return df
                except Exception as e:
                    print(f"❌ Error cargando {csv_path}: {e}")
    
    print("❌ No se pudo cargar la base oficial")
    return None

def encontrar_capas_para_validar():
    """Encuentra capas para validar en todos los discos"""
    print("\n📁 BUSCANDO CAPAS PARA VALIDAR...")
    
    capas_encontradas = []
    
    for disco in CONFIG['discos']:
        if os.path.exists(disco):
            print(f"🔍 Explorando: {disco}")
            
            patrones = [
                os.path.join(disco, "03_CAPAS_GENERADAS", "**", "*POR_PARTIDOS", "RP*.shp"),
                os.path.join(disco, "**", "RP*_POR_PARTIDOS", "*.shp"),
            ]
            
            capas_en_disco = 0
            for patron in patrones:
                try:
                    capas = glob.glob(patron, recursive=True)
                    for capa in capas:
                        nombre_capa = os.path.basename(capa)
                        # Filtrar capas individuales
                        if ('Segmentada_Por_Partidos' not in nombre_capa and 
                            'consolidada' not in nombre_capa.lower() and
                            capa not in capas_encontradas):
                            capas_encontradas.append(capa)
                            capas_en_disco += 1
                except Exception as e:
                    print(f"   ❌ Error en {patron}: {e}")
            
            if capas_en_disco > 0:
                print(f"   📊 Encontradas: {capas_en_disco} capas")
    
    print(f"\n🎯 TOTAL CAPAS ENCONTRADAS: {len(capas_encontradas)}")
    return capas_encontradas

def validar_capa_vs_oficial(archivo, base_oficial):
    """Valida una capa contra la base oficial"""
    nombre_archivo = os.path.basename(archivo)
    
    try:
        gdf = gpd.read_file(archivo)
        
        # Verificar campos esenciales
        campos_requeridos = ['partido_nombre', 'partido_codigo']
        campos_faltantes = [campo for campo in campos_requeridos if campo not in gdf.columns]
        
        if campos_faltantes:
            return {
                'archivo': nombre_archivo,
                'ubicacion': archivo,
                'estado': 'ERROR_CAMPOS',
                'partido_nombre': 'N/A',
                'partido_codigo': 'N/A',
                'longitud_generada_km': 0,
                'longitud_oficial_km': 0,
                'diferencia_km': 0,
                'diferencia_%': 100,
                'campos_faltantes': ', '.join(campos_faltantes)
            }
        
        partido_nombre = gdf['partido_nombre'].iloc[0]
        partido_codigo = gdf['partido_codigo'].iloc[0]
        
        # Calcular longitud generada
        if 'longitud_m' in gdf.columns:
            longitud_generada = gdf['longitud_m'].sum()
        else:
            longitud_generada = gdf.geometry.length.sum()
        
        # Extraer ruta del nombre de archivo
        ruta_num = nombre_archivo[2:4] if nombre_archivo[2:4].isdigit() else nombre_archivo[2:3]
        
        # Buscar en base oficial
        filtro = (base_oficial['RUTA'] == ruta_num) & (base_oficial['PARTIDO'] == partido_codigo)
        tramos_oficiales = base_oficial[filtro]
        
        if len(tramos_oficiales) == 0:
            return {
                'archivo': nombre_archivo,
                'ubicacion': archivo,
                'estado': 'NO_ENCONTRADO_OFICIAL',
                'partido_nombre': partido_nombre,
                'partido_codigo': partido_codigo,
                'longitud_generada_km': round(longitud_generada / 1000, 2),
                'longitud_oficial_km': 0,
                'diferencia_km': 0,
                'diferencia_%': 100
            }
        
        longitud_oficial = tramos_oficiales['Longitud en metros'].sum()
        diferencia = abs(longitud_generada - longitud_oficial)
        diferencia_porc = (diferencia / longitud_oficial * 100) if longitud_oficial > 0 else 100
        
        estado = 'VALIDO' if diferencia_porc <= 5 else 'FUERA_TOLERANCIA'
        
        return {
            'archivo': nombre_archivo,
            'ubicacion': archivo,
            'estado': estado,
            'partido_nombre': partido_nombre,
            'partido_codigo': partido_codigo,
            'longitud_generada_km': round(longitud_generada / 1000, 2),
            'longitud_oficial_km': round(longitud_oficial / 1000, 2),
            'diferencia_km': round(diferencia / 1000, 2),
            'diferencia_%': round(diferencia_porc, 1)
        }
        
    except Exception as e:
        return {
            'archivo': nombre_archivo,
            'ubicacion': archivo,
            'estado': f'ERROR_LECTURA',
            'partido_nombre': 'N/A',
            'partido_codigo': 'N/A',
            'longitud_generada_km': 0,
            'longitud_oficial_km': 0,
            'diferencia_km': 0,
            'diferencia_%': 100,
            'error': str(e)
        }

def main():
    """Función principal - VALIDACIÓN MULTIDISCO"""
    print("=" * 70)
    print("DVBA - VALIDACIÓN MULTIDISCO DE CAPAS")
    print("=" * 70)
    
    # Crear directorio de reportes
    os.makedirs(CONFIG['salida_reportes'], exist_ok=True)
    
    # 1. Cargar base oficial
    base_oficial = cargar_base_oficial_multidisco()
    if base_oficial is None:
        return
    
    # 2. Encontrar capas
    capas = encontrar_capas_para_validar()
    if not capas:
        print("❌ No se encontraron capas para validar")
        return
    
    # 3. Validar
    print(f"\n📏 VALIDANDO {len(capas)} CAPAS...")
    
    resultados = []
    for i, capa in enumerate(capas, 1):
        print(f"[{i}/{len(capas)}] {os.path.basename(capa)}")
        resultado = validar_capa_vs_oficial(capa, base_oficial)
        resultados.append(resultado)
        
        # Mostrar resultado inmediato
        if resultado['estado'] == 'VALIDO':
            print(f"   ✅ {resultado['partido_nombre']} - Diferencia: {resultado['diferencia_%']}%")
        elif resultado['estado'] == 'FUERA_TOLERANCIA':
            print(f"   ⚠️  {resultado['partido_nombre']} - Diferencia: {resultado['diferencia_%']}%")
        else:
            print(f"   ❌ {resultado['estado']}")
    
    # 4. Generar reportes
    df_resultados = pd.DataFrame(resultados)
    
    # Reporte CSV completo
    reporte_csv = os.path.join(CONFIG['salida_reportes'], 'validacion_multidisco_detalle.csv')
    df_resultados.to_csv(reporte_csv, index=False, encoding='utf-8')
    
    # Estadísticas
    validos = len(df_resultados[df_resultados['estado'] == 'VALIDO'])
    fuera_tolerancia = len(df_resultados[df_resultados['estado'] == 'FUERA_TOLERANCIA'])
    con_errores = len(df_resultados[df_resultados['estado'].str.startswith('ERROR')])
    no_encontrados = len(df_resultados[df_resultados['estado'] == 'NO_ENCONTRADO_OFICIAL'])
    
    print(f"\n🎯 REPORTE FINAL:")
    print(f"   • Total capas validadas: {len(resultados)}")
    print(f"   • ✅ Válidas: {validos} ({(validos/len(resultados))*100:.1f}%)")
    print(f"   • ⚠️  Fuera de tolerancia: {fuera_tolerancia}")
    print(f"   • ❌ Con errores: {con_errores}")
    print(f"   • 🔍 No encontradas en base oficial: {no_encontrados}")
    print(f"   • 📊 Reporte guardado: {reporte_csv}")

if __name__ == "__main__":
    main()