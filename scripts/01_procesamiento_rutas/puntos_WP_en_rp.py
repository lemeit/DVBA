import pandas as pd
import geopandas as gpd
from shapely.geometry import Point
import os
from datetime import datetime

# Diccionario completo de códigos de municipios
CODIGOS_MUNICIPIOS = {
    'Adolfo Alsina': '001', 'Adolfo Gonzales Chaves': '051', 'Alberti': '002',
    'Almirante Brown': '003', 'Arrecifes': '010', 'Avellaneda': '004',
    'Ayacucho': '005', 'Azul': '006', 'Bahía Blanca': '007', 'Balcarce': '008',
    'Baradero': '009', 'Benito Juárez': '053', 'Berazategui': '120',
    'Berisso': '114', 'Bolívar': '011', 'Bragado': '012', 'Brandsen': '013',
    'Campana': '014', 'Cañuelas': '015', 'Capitán Sarmiento': '121',
    'Carlos Casares': '016', 'Carlos Tejedor': '017', 'Carmen de Areco': '018',
    'Castelli': '020', 'Chacabuco': '026', 'Chascomús': '027', 'Chivilcoy': '028',
    'Colón': '021', 'Coronel Dorrego': '022', 'Coronel Pringles': '023',
    'Coronel Rosales': '113', 'Coronel Suárez': '024', 'Daireaux': '019',
    'Dolores': '029', 'Ensenada': '115', 'Escobar': '118', 'Esteban Echeverría': '030',
    'Exaltación de la Cruz': '031', 'Ezeiza': '130', 'Florencio Varela': '032',
    'Florentino Ameghino': '128', 'General Alvarado': '033', 'General Alvear': '034',
    'General Arenales': '035', 'General Belgrano': '036', 'General Guido': '037',
    'General La Madrid': '040', 'General Las Heras': '041', 'General Lavalle': '042',
    'General Madariaga': '039', 'General Paz': '043', 'General Pinto': '044',
    'General Pueyrredón': '045', 'General Rodríguez': '046', 'General San Martín': '047',
    'General Viamonte': '049', 'General Villegas': '050', 'Guaminí': '052',
    'Hipólito Yrigoyen': '119', 'Hurlingham': '135', 'Islas Baradero': '309',
    'Islas Campana': '314', 'Islas de San Nicolas': '398', 'Islas de Zárate': '338',
    'Islas Ramallo': '387', 'Islas San Fernando': '396', 'Islas San Pedro': '399',
    'Islas Tigre': '357', 'Ituzaingó': '136', 'José C. Paz': '132', 'Junín': '054',
    'La Costa': '123', 'La Matanza': '070', 'La Plata': '055', 'Lanús': '025',
    'Laprida': '056', 'Las Flores': '058', 'Leandro N. Alem': '059', 'Lezama': '137',
    'Lincoln': '060', 'Lobería': '061', 'Lobos': '062', 'Lomas de Zamora': '063',
    'Luján': '064', 'Magdalena': '065', 'Maipú': '066', 'Malvinas Argentinas': '133',
    'Mar Chiquita': '069', 'Marcos Paz': '068', 'Mercedes': '071', 'Merlo': '072',
    'Monte': '073', 'Monte Hermoso': '126', 'Moreno': '074', 'Morón': '101',
    'Navarro': '075', 'Necochea': '076', 'Nueve de Julio': '077', 'Olavarría': '078',
    'Patagones': '079', 'Pehuajó': '080', 'Pellegrini': '081', 'Pergamino': '082',
    'Pila': '083', 'Pilar': '084', 'Pinamar': '124', 'Presidente Perón': '129',
    'Puan': '085', 'Punta Indio': '134', 'Quilmes': '086', 'Ramallo': '087',
    'Rauch': '088', 'Rivadavia': '089', 'Rojas': '090', 'Roque Pérez': '091',
    'Saavedra': '092', 'Saladillo': '093', 'Salliqueló': '122', 'Salto': '067',
    'San Andrés de Giles': '094', 'San Antonio de Areco': '095', 'San Cayetano': '116',
    'San Fernando': '096', 'San Isidro': '097', 'San Miguel': '131', 'San Nicolás': '098',
    'San Pedro': '099', 'San Vicente': '100', 'Suipacha': '102', 'Tandil': '103',
    'Tapalqué': '104', 'Tigre': '057', 'Tordillo': '105', 'Tornquist': '106',
    'Trenque Lauquen': '107', 'Tres Arroyos': '108', 'Tres de Febrero': '117',
    'Tres Lomas': '127', 'Veinticinco de Mayo': '109', 'Vicente López': '110',
    'Villa Gesell': '125', 'Villarino': '111', 'Zárate': '038'
}

def leer_csv_con_codificaciones(archivo_path):
    """Lee CSV probando múltiples codificaciones sin perder datos"""
    codificaciones = ['latin-1', 'ISO-8859-1', 'cp1252', 'windows-1252', 'utf-8']
    
    for encoding in codificaciones:
        try:
            print(f"📖 Intentando leer con codificación: {encoding}")
            df = pd.read_csv(archivo_path, encoding=encoding)
            print(f"✅ Éxito con codificación: {encoding}")
            print(f"📊 Filas leídas: {len(df)}")
            
            # Mostrar rutas únicas encontradas
            rutas_unicas = df['RUTA'].dropna().unique()
            print(f"🛣️  Rutas encontradas: {sorted(rutas_unicas)}")
            
            return df
        except UnicodeDecodeError:
            continue
        except Exception as e:
            print(f"❌ Error con {encoding}: {e}")
            continue
    
    # Último intento con engine python
    try:
        print("🔄 Intentando con engine='python' y latin-1")
        df = pd.read_csv(archivo_path, encoding='latin-1', engine='python')
        print(f"✅ Éxito con engine python")
        return df
    except Exception as e:
        print(f"❌ Error crítico: {e}")
        return None

def crear_capa_puntos_coordenadas_duales(csv_puntos_path, resultados_dir):
    """
    Crea capas de puntos con coordenadas en ambos sistemas:
    - Geometría principal: POSGAR 2007 (EPSG:5347)
    - Campos adicionales: Grados decimales (EPSG:4326)
    """
    print("🔍 Leyendo archivo CSV original...")
    
    # 1. Leer CSV original
    df_puntos = leer_csv_con_codificaciones(csv_puntos_path)
    if df_puntos is None:
        print("❌ No se pudo leer el archivo de puntos")
        return 0
    
    # 2. Mapeo de columnas
    mapeo_columnas = {
        'LAT.': 'LAT', 'LONG.': 'LONG', 
        'DESCRIPCIÓN DEL TRAMO': 'DESCRIPCION',
        'PROGRESIVA GoogleMaps (km)': 'PROG_GOOGLE',
        'PROGRESIVA CALCULADA (km)': 'PROG_CALC', 
        'PROGRESIVA FÍSICA SEÑALADA (km)': 'PROG_FISICA',
        'ANCHO CALZADA (m)': 'ANCHO_CALZADA',
        'ANCHO ZONA CAMIN.': 'ANCHO_CAMINO',
        'PARTIDO': 'PARTIDO'
    }
    
    df_puntos = df_puntos.rename(columns={k: v for k, v in mapeo_columnas.items() if k in df_puntos.columns})
    
    # 3. Limpiar datos
    df_puntos = df_puntos.dropna(subset=['RUTA'])
    df_puntos = df_puntos[df_puntos['RUTA'].str.strip() != '']
    df_puntos = df_puntos.dropna(subset=['LAT', 'LONG'], how='all')
    
    # 4. Convertir coordenadas a numérico
    df_puntos['LAT'] = pd.to_numeric(df_puntos['LAT'], errors='coerce')
    df_puntos['LONG'] = pd.to_numeric(df_puntos['LONG'], errors='coerce')
    df_puntos = df_puntos.dropna(subset=['LAT', 'LONG'])
    df_puntos = df_puntos[(df_puntos['LAT'] != 0) & (df_puntos['LONG'] != 0)]
    
    print(f"📊 Filas con coordenadas válidas: {len(df_puntos)}")
    
    # 5. CREAR GEOMETRÍA PRINCIPAL EN POSGAR 2007 (EPSG:5347)
    # Primero crear en WGS84 y luego proyectar a POSGAR
    geometry_wgs84 = [Point(xy) for xy in zip(df_puntos['LONG'], df_puntos['LAT'])]
    gdf_wgs84 = gpd.GeoDataFrame(df_puntos, geometry=geometry_wgs84, crs="EPSG:4326")
    
    # Proyectar a POSGAR 2007 para la geometría principal
    gdf = gdf_wgs84.to_crs("EPSG:5347")
    
    print("✅ Geometría principal en EPSG:5347 (POSGAR 2007)")
    
    # 6. METADATOS ACTUALIZADOS
    metadatos_base = {
        'municipio_cod': '',
        'municipio_nom': '',
        'ruta_num': '',
        'tipo_punto': '',
        'restriccion': '',
        'hct': '',
        'fuente_datos': 'DVP Buenos Aires',
        'sistema_geod': 'IGN',
        'segmentos': '',
        'clase_pred': '',
        'meta_fuente': 'Relevamiento de la División Técnica Zona VI Saladillo DVBA',
        'meta_instit': 'Dirección de Vialidad de la Provincia de Buenos Aires',
        'meta_depto': 'Zona VI Saladillo - División Técnica',
        'meta_resp': 'Ing. Luciano Lamaita',
        'meta_contacto': 'lulamaita@vialidad.gba.gov.ar',
        'meta_prov': 'Reconstrucción y Filtrado de Rutas Provinciales',
        'meta_sist': 'EPSG:5347 - POSGAR 2007',  # Sistema principal
        'meta_tipo': '',
        'meta_fecha': datetime.now().strftime('%Y-%m-%d'),
        'meta_version': '1.0',
        'meta_licencia': 'Uso Interno - DVBA'
    }
    
    # 7. Procesar por rutas
    rutas_unicas = [r for r in gdf['RUTA'].unique() if pd.notna(r) and str(r).strip() != '']
    
    print(f"🛣️  Rutas a procesar: {sorted(rutas_unicas)}")
    
    rutas_procesadas = 0
    
    for ruta in rutas_unicas:
        try:
            gdf_ruta = gdf[gdf['RUTA'] == ruta].copy()
            
            print(f"📝 Procesando {ruta} con {len(gdf_ruta)} puntos...")
            
            # Agregar metadatos
            gdf_ruta['municipio_nom'] = gdf_ruta.get('PARTIDO', '')
            gdf_ruta['municipio_cod'] = gdf_ruta['municipio_nom'].map(CODIGOS_MUNICIPIOS).fillna('')
            gdf_ruta['ruta_num'] = ruta.replace('RP', '')
            gdf_ruta['tipo_punto'] = gdf_ruta.get('TIPO', '')
            gdf_ruta['clase_pred'] = gdf_ruta.get('TIPO', '')
            gdf_ruta['meta_tipo'] = f'Red Vial Vialidad - {ruta}'
            
            # Agregar campos de metadatos base
            for key, value in metadatos_base.items():
                if key not in gdf_ruta.columns:
                    gdf_ruta[key] = value
            
            # 🎯 COORDENADAS PRINCIPALES EN POSGAR 2007 (metros)
            gdf_ruta['latitud_posgar'] = gdf_ruta.geometry.y.round(3)  # metros con 3 decimales
            gdf_ruta['longitud_posgar'] = gdf_ruta.geometry.x.round(3)  # metros con 3 decimales
            
            # 🎯 COORDENADAS ADICIONALES EN GRADOS DECIMALES (WGS84)
            # Convertir geometría de vuelta a WGS84 para obtener grados decimales
            gdf_ruta_wgs84 = gdf_ruta.to_crs("EPSG:4326")
            gdf_ruta['latitud_wgs84'] = gdf_ruta_wgs84.geometry.y.round(6)  # grados con 6 decimales
            gdf_ruta['longitud_wgs84'] = gdf_ruta_wgs84.geometry.x.round(6)  # grados con 6 decimales
            
            # Columnas en orden
            columnas_base = ['RUTA', 'WP', 'DESCRIPCION', 'TIPO', 'ESTADO', 'PARTIDO']
            columnas_tecnicas = ['PROG_GOOGLE', 'PROG_CALC', 'PROG_FISICA', 'ANCHO_CALZADA', 'ANCHO_CAMINO']
            columnas_meta = ['municipio_cod', 'municipio_nom', 'ruta_num', 'tipo_punto', 'clase_pred']
            columnas_coord_posgar = ['latitud_posgar', 'longitud_posgar']  # Coordenadas principales
            columnas_coord_wgs84 = ['latitud_wgs84', 'longitud_wgs84']    # Coordenadas adicionales
            columnas_instit = ['fuente_datos', 'sistema_geod', 'meta_fuente', 'meta_instit', 
                             'meta_depto', 'meta_resp', 'meta_contacto', 'meta_prov',
                             'meta_sist', 'meta_tipo', 'meta_fecha', 'meta_version', 'meta_licencia']
            
            columnas_orden = (columnas_base + columnas_tecnicas + columnas_meta + 
                            columnas_coord_posgar + columnas_coord_wgs84 + 
                            columnas_instit + ['geometry'])
            
            columnas_existentes = [col for col in columnas_orden if col in gdf_ruta.columns]
            gdf_ruta = gdf_ruta[columnas_existentes]
            
            # Guardar (sobreescribir)
            shp_filename = f"Puntos_{ruta}_Completo.shp"
            shp_path = os.path.join(resultados_dir, shp_filename)
            
            # Eliminar archivos existentes
            archivos_relacionados = [shp_path.replace('.shp', ext) for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg']]
            for archivo in archivos_relacionados:
                if os.path.exists(archivo):
                    os.remove(archivo)
            
            # Guardar en POSGAR 2007 (sistema principal)
            gdf_ruta.to_file(shp_path, encoding='utf-8')
            
            # Mostrar ejemplos de ambas coordenadas
            ejemplo = gdf_ruta.iloc[0]
            print(f"✅ Shapefile: {shp_filename}")
            print(f"   - Puntos: {len(gdf_ruta)}")
            print(f"   - POSGAR 2007: {ejemplo['longitud_posgar']:.3f}, {ejemplo['latitud_posgar']:.3f}")
            print(f"   - WGS84: {ejemplo['longitud_wgs84']:.6f}, {ejemplo['latitud_wgs84']:.6f}")
            print("")
            
            rutas_procesadas += 1
            
        except Exception as e:
            print(f"❌ Error procesando ruta {ruta}: {e}")
            continue
    
    return rutas_procesadas

# Configuración
ruta_base = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"
csv_puntos_original = os.path.join(ruta_base, "04_TABLAS", "DETALLE_RED.csv")
resultados_dir = os.path.join(ruta_base, "05_RESULTADOS")

# Crear directorio si no existe
os.makedirs(resultados_dir, exist_ok=True)

print("🚀 CREANDO CAPAS CON COORDENADAS DUALES")
print("=" * 65)
print("📝 SISTEMAS DE COORDENADAS:")
print("   • PRINCIPAL: EPSG:5347 (POSGAR 2007) - Geometría")
print("   • ADICIONAL: EPSG:4326 (WGS84) - Campos extra")
print("   • Campos POSGAR: latitud_posgar, longitud_posgar")
print("   • Campos WGS84: latitud_wgs84, longitud_wgs84")
print("=" * 65)

total_rutas = crear_capa_puntos_coordenadas_duales(csv_puntos_original, resultados_dir)

print(f"🎉 PROCESO COMPLETADO: {total_rutas} rutas")