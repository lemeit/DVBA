import pandas as pd
import geopandas as gpd
from shapely.geometry import Point
import os
from datetime import datetime
import numpy as np

# Diccionario de códigos de municipios
CODIGOS_MUNICIPIOS = {
    'Las Flores': '058', 'Roque Perez': '091', '25 de Mayo': '109', 
    'Navarro': '075', 'Gral. Las Heras': '041', 'Lobos': '062',
    'Saladillo': '093', 'Gral. Alvear': '034', 'Suipacha': '102',
    'Chivilcoy': '028', 'Mercedes': '071', 'Cañuelas': '015',
    'Marcos Paz': '068'
}

def determinar_direccion_ruta(gdf_mojones):
    """
    Determina la dirección de la ruta analizando la secuencia de mojones
    Retorna: 'creciente' o 'decreciente'
    """
    if gdf_mojones.empty or len(gdf_mojones) < 2:
        return 'creciente'  # Por defecto asumimos creciente
    
    # Ordenar mojones por km_value
    mojones_ordenados = gdf_mojones.sort_values('km_value')
    
    # Tomar primeros y últimos mojones
    primer_mojon = mojones_ordenados.iloc[0]
    ultimo_mojon = mojones_ordenados.iloc[-1]
    
    # Calcular dirección basada en coordenadas
    # Si el mojón con km menor está al oeste/norte del mojón con km mayor, es creciente
    if primer_mojon.geometry.x < ultimo_mojon.geometry.x:  # Este-Oeste
        return 'creciente'
    elif primer_mojon.geometry.x > ultimo_mojon.geometry.x:
        return 'decreciente'
    elif primer_mojon.geometry.y < ultimo_mojon.geometry.y:  # Norte-Sur
        return 'creciente' 
    else:
        return 'decreciente'

def calcular_progresiva_con_direccion(punto, gdf_mojones, crs_puntos, max_distancia=5000):
    """
    Calcula la progresiva considerando la dirección de la ruta
    """
    if gdf_mojones.empty:
        return None, None, None, None
    
    # Asegurarse que están en el mismo sistema
    if gdf_mojones.crs != crs_puntos:
        gdf_mojones = gdf_mojones.to_crs(crs_puntos)
    
    # Determinar dirección de la ruta
    direccion = determinar_direccion_ruta(gdf_mojones)
    
    # Calcular distancias a todos los mojones
    distancias = gdf_mojones.geometry.distance(punto)
    
    # Encontrar el mojón más cercano
    idx_cercano = distancias.idxmin()
    distancia_min = distancias.iloc[idx_cercano]
    mojon_cercano = gdf_mojones.iloc[idx_cercano]
    km_mojon = mojon_cercano.get('km_value', None)
    
    # Si está dentro de la distancia máxima, calcular progresiva
    if distancia_min <= max_distancia and km_mojon is not None:
        # Determinar si sumar o restar la distancia según la dirección
        if direccion == 'creciente':
            progresiva_calculada = km_mojon + (distancia_min / 1000)  # Convertir metros a km
        else:
            progresiva_calculada = km_mojon - (distancia_min / 1000)
        
        return (round(progresiva_calculada, 2), 
                round(distancia_min, 0), 
                km_mojon, 
                direccion)
    else:
        return None, round(distancia_min, 0) if km_mojon is not None else None, km_mojon, direccion

def calcular_error_porcentual(prog_calc, prog_mojon):
    """
    Calcula el error porcentual entre PROG_CALC y prog_mojon
    """
    if prog_calc is None or prog_mojon is None:
        return None
    
    if prog_calc == 0:  # Evitar división por cero
        return None
    
    error_absoluto = abs(prog_mojon - prog_calc)
    error_porcentual = (error_absoluto / prog_calc) * 100
    
    return round(error_porcentual, 2)

def cargar_mojones_ruta(ruta_base, ruta):
    """
    Carga la capa de mojones para una ruta específica
    """
    ruta_num = ruta.replace('RP', '').lower()
    
    # ESTRUCTURA CORRECTA
    ruta_mojones = os.path.join(ruta_base, "02_BASES_VECTORES", "mojones", f"mojones_rp{ruta_num}", "shp")
    
    if not os.path.exists(ruta_mojones):
        print(f"   ❌ No existe directorio: {ruta_mojones}")
        return gpd.GeoDataFrame()
    
    # Buscar archivo .shp
    archivos_shp = [f for f in os.listdir(ruta_mojones) if f.lower().endswith('.shp')]
    
    if not archivos_shp:
        print(f"   ❌ No hay archivos .shp en: {ruta_mojones}")
        return gpd.GeoDataFrame()
    
    shp_file = os.path.join(ruta_mojones, archivos_shp[0])
    print(f"   ✅ Archivo encontrado: {archivos_shp[0]}")
    
    try:
        gdf_mojones = gpd.read_file(shp_file)
        print(f"   ✅ Mojones cargados: {len(gdf_mojones)} puntos")
        print(f"   - Sistema CRS: {gdf_mojones.crs}")
        
        # Verificar campos importantes
        campos_importantes = ['Name', 'rtn', 'km_value']
        for campo in campos_importantes:
            if campo in gdf_mojones.columns:
                print(f"   - ✅ {campo}: encontrado")
            else:
                print(f"   - ❌ {campo}: NO encontrado")
        
        if not gdf_mojones.empty and 'km_value' in gdf_mojones.columns:
            km_min = gdf_mojones['km_value'].min()
            km_max = gdf_mojones['km_value'].max()
            print(f"   - Rango km_value: {km_min} - {km_max}")
            
            # Determinar dirección
            direccion = determinar_direccion_ruta(gdf_mojones)
            print(f"   - Dirección de ruta: {direccion}")
            
            # Mostrar mojones extremos
            mojones_ordenados = gdf_mojones.sort_values('km_value')
            primer_mojon = mojones_ordenados.iloc[0]
            ultimo_mojon = mojones_ordenados.iloc[-1]
            print(f"   - Mojón inicial: km {primer_mojon['km_value']}")
            print(f"   - Mojón final: km {ultimo_mojon['km_value']}")
        
        return gdf_mojones
        
    except Exception as e:
        print(f"   ❌ Error cargando mojones: {e}")
        return gpd.GeoDataFrame()

def crear_capa_puntos_con_error(csv_puntos_path, ruta_base, resultados_dir):
    """
    Crea capas de puntos con progresivas, direccion y error porcentual
    """
    print("🔍 Leyendo archivo CSV de puntos...")
    
    # 1. Leer CSV de puntos
    df_puntos = pd.read_csv(csv_puntos_path, encoding='latin-1')
    print(f"✅ CSV leído: {len(df_puntos)} filas")
    
    # 2. Mapeo de columnas
    mapeo_columnas = {
        'LAT.': 'LAT', 'LONG.': 'LONG', 
        'DESCRIPCIÓN DEL TRAMO': 'DESCRIPCION',
        'PROGRESIVA GoogleMaps (km)': 'PROG_GOOGLE',
        'PROGRESIVA CALCULADA (km)': 'PROG_CALC', 
        'PROGRESIVA FÍSICA SEÑALADA (km)': 'PROG_FISICA',
        'ANCHO CALZADA (m)': 'ANCHO_CALZ',
        'ANCHO ZONA CAMIN.': 'ANCHO_CAM',
        'PARTIDO': 'PARTIDO'
    }
    
    df_puntos = df_puntos.rename(columns={k: v for k, v in mapeo_columnas.items() if k in df_puntos.columns})
    
    # 3. Limpiar datos
    df_puntos = df_puntos.dropna(subset=['RUTA'])
    df_puntos = df_puntos[df_puntos['RUTA'].str.strip() != '']
    df_puntos = df_puntos.dropna(subset=['LAT', 'LONG'], how='all')
    df_puntos['LAT'] = pd.to_numeric(df_puntos['LAT'], errors='coerce')
    df_puntos['LONG'] = pd.to_numeric(df_puntos['LONG'], errors='coerce')
    df_puntos = df_puntos.dropna(subset=['LAT', 'LONG'])
    df_puntos = df_puntos[(df_puntos['LAT'] != 0) & (df_puntos['LONG'] != 0)]
    
    print(f"📊 Puntos válidos: {len(df_puntos)}")
    
    # 4. Crear geometría en WGS84 primero
    geometry_wgs84 = [Point(xy) for xy in zip(df_puntos['LONG'], df_puntos['LAT'])]
    gdf_wgs84 = gpd.GeoDataFrame(df_puntos, geometry=geometry_wgs84, crs="EPSG:4326")
    print(f"✅ Geometría WGS84 creada")
    
    # Convertir a POSGAR 2007
    gdf = gdf_wgs84.to_crs("EPSG:5347")
    print(f"✅ Geometría convertida a POSGAR 2007")
    
    # 5. Procesar por rutas
    rutas_unicas = [r for r in gdf['RUTA'].unique() if pd.notna(r) and str(r).strip() != '']
    
    print(f"\n🛣️  Rutas a procesar: {sorted(rutas_unicas)}")
    
    rutas_procesadas = 0
    
    for ruta in rutas_unicas:
        try:
            gdf_ruta = gdf[gdf['RUTA'] == ruta].copy()
            
            print(f"\n📝 Procesando {ruta} con {len(gdf_ruta)} puntos...")
            
            # CARGAR MOJONES
            gdf_mojones = cargar_mojones_ruta(ruta_base, ruta)
            
            if gdf_mojones.empty:
                print(f"   ⚠️  No hay mojones disponibles")
                gdf_ruta['prog_mojon'] = None
                gdf_ruta['dist_mojon'] = None
                gdf_ruta['error_porc'] = None
                gdf_ruta['dir_ruta'] = None
            else:
                # CONVERTIR MOJONES AL MISMO SISTEMA QUE LOS PUNTOS
                if gdf_mojones.crs != gdf_ruta.crs:
                    print(f"   🔄 Convirtiendo mojones a {gdf_ruta.crs}...")
                    gdf_mojones = gdf_mojones.to_crs(gdf_ruta.crs)
                
                # CALCULAR PROGRESIVAS CON DIRECCIÓN
                print(f"   🎯 Calculando progresivas con dirección...")
                progresivas = []
                distancias = []
                mojones_base = []
                direcciones = []
                errores = []
                
                for idx, punto in gdf_ruta.iterrows():
                    progresiva, distancia, mojon_base, direccion = calcular_progresiva_con_direccion(
                        punto.geometry, 
                        gdf_mojones, 
                        gdf_ruta.crs,
                        max_distancia=10000
                    )
                    
                    progresivas.append(progresiva)
                    distancias.append(distancia)
                    mojones_base.append(mojon_base)
                    direcciones.append(direccion)
                    
                    # Calcular error porcentual
                    error = calcular_error_porcentual(punto.get('PROG_CALC'), progresiva)
                    errores.append(error)
                
                gdf_ruta['prog_mojon'] = progresivas
                gdf_ruta['dist_mojon'] = distancias
                gdf_ruta['mojon_base'] = mojones_base
                gdf_ruta['dir_ruta'] = direcciones
                gdf_ruta['error_porc'] = errores
                
                progresivas_calc = sum(1 for p in progresivas if p is not None)
                print(f"   📊 Resumen: {progresivas_calc}/{len(gdf_ruta)} progresivas calculadas")
                
                # Mostrar detalles de algunos puntos
                print(f"   📍 Ejemplos de cálculos:")
                for i in range(min(3, len(gdf_ruta))):
                    punto = gdf_ruta.iloc[i]
                    if punto['prog_mojon'] is not None:
                        print(f"     - WP {punto['WP']}:")
                        print(f"       · PROG_CALC: {punto['PROG_CALC']}")
                        print(f"       · prog_mojon: {punto['prog_mojon']}")
                        print(f"       · mojón base: {punto['mojon_base']}")
                        print(f"       · distancia: {punto['dist_mojon']}m")
                        print(f"       · dirección: {punto['dir_ruta']}")
                        print(f"       · error: {punto['error_porc']}%")
                
                # Análisis de errores
                errores_validos = [e for e in errores if e is not None]
                if errores_validos:
                    error_promedio = np.mean(errores_validos)
                    error_max = np.max(errores_validos)
                    print(f"   📈 Análisis de errores:")
                    print(f"     - Error promedio: {error_promedio:.2f}%")
                    print(f"     - Error máximo: {error_max:.2f}%")
            
            # METADATOS
            gdf_ruta['mpio_cod'] = gdf_ruta.get('PARTIDO', '').map(CODIGOS_MUNICIPIOS).fillna('')
            gdf_ruta['mpio_nom'] = gdf_ruta.get('PARTIDO', '')
            gdf_ruta['ruta_num'] = ruta.replace('RP', '')
            gdf_ruta['tipo_punto'] = gdf_ruta.get('TIPO', '')
            gdf_ruta['clase_pred'] = gdf_ruta.get('TIPO', '')
            
            # COORDENADAS DUALES
            gdf_ruta['lat_posgar'] = gdf_ruta.geometry.y.round(3)
            gdf_ruta['lon_posgar'] = gdf_ruta.geometry.x.round(3)
            gdf_ruta_wgs84 = gdf_ruta.to_crs("EPSG:4326")
            gdf_ruta['lat_wgs84'] = gdf_ruta_wgs84.geometry.y.round(6)
            gdf_ruta['lon_wgs84'] = gdf_ruta_wgs84.geometry.x.round(6)
            
            # CAMPOS FINALES
            campos_finales = [
                'RUTA', 'WP', 'DESCRIPCION', 'TIPO', 'ESTADO', 'PARTIDO',
                'PROG_GOOGLE', 'PROG_CALC', 'PROG_FISICA', 'prog_mojon', 
                'dist_mojon', 'mojon_base', 'dir_ruta', 'error_porc',
                'ANCHO_CALZ', 'ANCHO_CAM', 'mpio_cod', 'mpio_nom', 'ruta_num',
                'tipo_punto', 'clase_pred', 'lat_posgar', 'lon_posgar',
                'lat_wgs84', 'lon_wgs84', 'geometry'
            ]
            
            campos_existentes = [col for col in campos_finales if col in gdf_ruta.columns]
            gdf_ruta = gdf_ruta[campos_existentes]
            
            # GUARDAR
            shp_filename = f"Puntos_{ruta}_Completo.shp"
            shp_path = os.path.join(resultados_dir, shp_filename)
            
            # Limpiar archivos existentes
            for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg']:
                archivo = shp_path.replace('.shp', ext)
                if os.path.exists(archivo):
                    os.remove(archivo)
            
            gdf_ruta.to_file(shp_path, encoding='utf-8')
            
            # Mostrar resumen
            progresivas_no_nulas = gdf_ruta['prog_mojon'].notna().sum()
            print(f"✅ Shapefile: {shp_filename}")
            print(f"   - Puntos: {len(gdf_ruta)}")
            print(f"   - Progresivas calculadas: {progresivas_no_nulas}/{len(gdf_ruta)}")
            
            rutas_procesadas += 1
            
        except Exception as e:
            print(f"❌ Error en {ruta}: {e}")
            continue
    
    return rutas_procesadas

# Configuración
ruta_base = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"
csv_puntos_original = os.path.join(ruta_base, "04_TABLAS", "DETALLE_RED.csv")
resultados_dir = os.path.join(ruta_base, "05_RESULTADOS")

os.makedirs(resultados_dir, exist_ok=True)

print("🚀 CALCULANDO PROGRESIVAS CON DIRECCIÓN Y ERROR")
print("=" * 65)
print("🎯 NUEVAS FUNCIONALIDADES:")
print("   • Detección automática de dirección de ruta")
print("   • Cálculo correcto (suma/resta según dirección)")
print("   • Error porcentual entre PROG_CALC y prog_mojon")
print("   • Análisis de precisión")
print("=" * 65)

total_rutas = crear_capa_puntos_con_error(csv_puntos_original, ruta_base, resultados_dir)

print(f"\n🎉 PROCESO COMPLETADO: {total_rutas} rutas")