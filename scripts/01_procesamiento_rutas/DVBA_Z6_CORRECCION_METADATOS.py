import os
import pandas as pd
import glob
import sys

# Ruta base del proyecto
base_path = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"

def extraer_info_ruta(nombre_archivo):
    """Extrae información de partido y ruta del nombre del archivo"""
    # Extraer número de ruta (ej: RP44, RP6, RP61, etc.)
    nombre_sin_ext = nombre_archivo.replace('.shp', '')
    
    if nombre_sin_ext.startswith('RP'):
        partes = nombre_sin_ext.split('_')
        if len(partes) >= 2:
            ruta = partes[0].replace('RP', '')
            # Limpiar letras del número de ruta
            ruta_limpia = ''.join(filter(str.isdigit, ruta))
            
            # Extraer nombre del partido (puede ser la segunda parte o más)
            partido = '_'.join(partes[1:])
            
            # Limpiar sufijos comunes
            partido = partido.replace('CORREGIDO', '').replace('BACKUP', '').replace('FINAL', '').strip('_')
            
            # Mapear nombres de partidos inconsistentes
            mapeo_partidos = {
                '25Demayo': '25 de Mayo',
                '25deMayo': '25 de Mayo', 
                '25_de_Mayo': '25 de Mayo',
                'Veinticinco_De_Mayo': '25 de Mayo',
                'Generallasheras': 'General Las Heras',
                'General_Las_Heras': 'General Las Heras',
                'General_Alvear': 'General Alvear',
                'Lasflores': 'Las Flores',
                'Las_Flores': 'Las Flores',
                'Roqueperez': 'Roque Pérez',
                '25Demayo': '25 de Mayo'
            }
            
            partido_limpio = mapeo_partidos.get(partido, partido)
            
            # Mapear códigos de partido
            codigos_partido = {
                '25 de Mayo': '025',
                'General Las Heras': '038', 
                'General Alvear': '037',
                'Las Flores': '049',
                'Navarro': '058',
                'Lobos': '051',
                'Saladillo': '076',
                'Roque Pérez': '069',
                '01': '001',
                '05': '005', 
                '07': '007',
                '08': '008'
            }
            
            codigo = codigos_partido.get(partido_limpio, '000')
            
            return ruta_limpia, partido_limpio, codigo
    
    return None, None, None

def corregir_shapefiles():
    """Corrige todos los shapefiles con problemas"""
    
    # Encontrar todos los shapefiles en el proyecto
    pattern = os.path.join(base_path, "**", "*.shp")
    shapefiles = glob.glob(pattern, recursive=True)
    
    print(f"Encontrados {len(shapefiles)} shapefiles")
    print("=" * 60)
    
    corregidos = 0
    errores = 0
    
    for shp_path in shapefiles:
        try:
            # Leer el shapefile
            gdf = gpd.read_file(shp_path)
            
            # Extraer información del nombre del archivo
            nombre_archivo = os.path.basename(shp_path)
            ruta, partido_nombre, partido_codigo = extraer_info_ruta(nombre_archivo)
            
            if ruta and partido_nombre and partido_codigo:
                print(f"Procesando: {nombre_archivo}")
                print(f"  → Ruta: {ruta}, Partido: {partido_nombre}, Código: {partido_codigo}")
                
                cambios = []
                
                # Agregar campos faltantes si no existen
                if 'partido_nombre' not in gdf.columns:
                    gdf['partido_nombre'] = partido_nombre
                    cambios.append("+ partido_nombre")
                else:
                    gdf['partido_nombre'] = partido_nombre
                    cambios.append("✓ partido_nombre")
                
                if 'partido_codigo' not in gdf.columns:
                    gdf['partido_codigo'] = partido_codigo
                    cambios.append("+ partido_codigo")
                else:
                    gdf['partido_codigo'] = partido_codigo
                    cambios.append("✓ partido_codigo")
                
                # Corregir campo de ruta si existe y tiene letras
                campos_ruta = ['ruta', 'ruta_numero', 'numero_ruta', 'ruta_nacional', 'ruta_provincial']
                for campo_ruta in campos_ruta:
                    if campo_ruta in gdf.columns:
                        # Verificar si el campo actual tiene letras
                        valores_actuales = gdf[campo_ruta].astype(str).unique()
                        if any(any(c.isalpha() for c in str(val)) for val in valores_actuales):
                            gdf[campo_ruta] = ruta
                            cambios.append(f"✓ {campo_ruta} (limpiado)")
                
                # Limpiar datos institucionales repetidos
                campos_institucionales = ['institucion', 'organismo', 'entidad', 'fuente', 'responsable']
                for campo in campos_institucionales:
                    if campo in gdf.columns:
                        # Reemplazar valores repetidos con uno consistente
                        gdf[campo] = 'Dirección de Vialidad de la Provincia de Buenos Aires'
                        cambios.append(f"✓ {campo} (unificado)")
                
                # Guardar el shapefile corregido
                gdf.to_file(shp_path, driver='ESRI Shapefile')
                print(f"  → Cambios: {', '.join(cambios)}")
                print(f"  ✅ CORREGIDO: {nombre_archivo}\n")
                corregidos += 1
                
            else:
                print(f"  ❌ NO CORREGIDO: {nombre_archivo} (no se pudo extraer información)\n")
                errores += 1
                
        except Exception as e:
            print(f"  ❌ ERROR: {os.path.basename(shp_path)} - {str(e)}\n")
            errores += 1
    
    print("=" * 60)
    print(f"RESUMEN: {corregidos} corregidos, {errores} errores")

def generar_reporte_correccion():
    """Genera un reporte de los archivos corregidos"""
    reporte_dir = os.path.join(base_path, "DVBA_REPORTES_VALIDACION")
    os.makedirs(reporte_dir, exist_ok=True)
    
    reporte_path = os.path.join(reporte_dir, "reporte_correccion_campos.csv")
    
    datos_reporte = []
    pattern = os.path.join(base_path, "**", "*.shp")
    shapefiles = glob.glob(pattern, recursive=True)
    
    print("Generando reporte de corrección...")
    
    for shp_path in shapefiles:
        try:
            gdf = gpd.read_file(shp_path)
            nombre_archivo = os.path.basename(shp_path)
            
            ruta, partido_nombre, partido_codigo = extraer_info_ruta(nombre_archivo)
            
            # Verificar campos
            campos_ok = 'partido_nombre' in gdf.columns and 'partido_codigo' in gdf.columns
            estado = "CORREGIDO" if campos_ok else "PENDIENTE"
            
            datos_reporte.append({
                'archivo': nombre_archivo,
                'ubicacion': os.path.dirname(shp_path),
                'ruta_numero': ruta or 'N/A',
                'partido_nombre': partido_nombre or 'N/A', 
                'partido_codigo': partido_codigo or 'N/A',
                'estado': estado,
                'campos_faltantes': 'NINGUNO' if estado == "CORREGIDO" else 'partido_nombre, partido_codigo',
                'total_registros': len(gdf)
            })
            
        except Exception as e:
            datos_reporte.append({
                'archivo': os.path.basename(shp_path),
                'ubicacion': os.path.dirname(shp_path),
                'ruta_numero': 'ERROR',
                'partido_nombre': 'ERROR',
                'partido_codigo': 'ERROR', 
                'estado': 'ERROR',
                'campos_faltantes': str(e),
                'total_registros': 0
            })
    
    # Crear DataFrame y guardar reporte
    df_reporte = pd.DataFrame(datos_reporte)
    df_reporte.to_csv(reporte_path, index=False, encoding='utf-8')
    print(f"✅ Reporte generado: {reporte_path}")

if __name__ == "__main__":
    try:
        import geopandas as gpd
        print("INICIANDO CORRECCIÓN DE SHAPEFILES")
        print("=" * 60)
        
        corregir_shapefiles()
        print("\n" + "=" * 60)
        generar_reporte_correccion()
        
        print("\n" + "=" * 60)
        print("¡PROCESO COMPLETADO!")
        
    except ImportError:
        print("ERROR: Se requiere geopandas.")
        print("Instala con: pip install geopandas")
        sys.exit(1)