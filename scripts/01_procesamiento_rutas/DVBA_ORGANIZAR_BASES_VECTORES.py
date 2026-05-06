"""
DVBA_ORGANIZAR_BASES_VECTORES.py
===========================================================
ORGANIZACIÓN: Separa partidos y mojones en carpetas específicas
"""

import os
import glob
import shutil
from pathlib import Path

# CONFIGURACIÓN
CONFIG = {
    'bases_vectores': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales_ORGANIZADO\00_DATOS_FUENTE\02_BASES_VECTORES"
}

# DICCIONARIO DE PARTIDOS
PARTIDOS = {
    '034': 'General_Alvear',
    '041': 'General_Las_Heras', 
    '058': 'Las_Flores',
    '062': 'Lobos',
    '075': 'Navarro',
    '091': 'Roque_Perez',
    '093': 'Saladillo',
    '109': '25_de_Mayo'
}

def organizar_partidos():
    """Organiza los shapefiles de partidos en carpetas por nombre"""
    print("🏛️ ORGANIZANDO SHAPEFILES DE PARTIDOS...")
    
    # Patrones para identificar archivos de partidos
    patrones_partidos = [
        "*partido*", "*partidos*", "*part_*", "*part_*",
        "*limite*", "*limites*", "*boundary*", "*boundaries*",
        "*.shp"  # Revisar todos los shapefiles
    ]
    
    partidos_organizados = 0
    
    for patron in patrones_partidos:
        busqueda = os.path.join(CONFIG['bases_vectores'], patron)
        archivos = glob.glob(busqueda)
        
        for archivo in archivos:
            if not archivo.endswith('.shp'):
                continue
                
            nombre = os.path.basename(archivo)
            nombre_lower = nombre.lower()
            
            # Determinar a qué partido pertenece
            partido_detectado = None
            codigo_partido = None
            
            # Buscar por códigos
            for codigo, nombre_partido in PARTIDOS.items():
                if codigo in nombre:
                    partido_detectado = nombre_partido
                    codigo_partido = codigo
                    break
            
            # Buscar por nombres
            if not partido_detectado:
                for codigo, nombre_partido in PARTIDOS.items():
                    nombre_partido_simple = nombre_partido.replace('_', ' ').lower()
                    if nombre_partido_simple in nombre_lower or nombre_partido.lower() in nombre_lower:
                        partido_detectado = nombre_partido
                        codigo_partido = codigo
                        break
            
            # Si es un archivo general de partidos (sin específico)
            if not partido_detectado and any(palabra in nombre_lower for palabra in ['partido', 'partidos', 'limite', 'boundary']):
                partido_detectado = 'PARTIDOS_GENERAL'
                codigo_partido = 'GENERAL'
            
            if partido_detectado:
                # Crear carpeta del partido
                carpeta_partido = os.path.join(CONFIG['bases_vectores'], "PARTIDOS", f"{codigo_partido}_{partido_detectado}")
                os.makedirs(carpeta_partido, exist_ok=True)
                
                # Mover archivo y relacionados
                base_origen = os.path.splitext(archivo)[0]
                base_destino = os.path.join(carpeta_partido, os.path.splitext(nombre)[0])
                
                movidos = 0
                for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx']:
                    archivo_origen = base_origen + ext
                    archivo_destino = base_destino + ext
                    
                    if os.path.exists(archivo_origen):
                        shutil.move(archivo_origen, archivo_destino)
                        movidos += 1
                
                if movidos > 0:
                    print(f"   ✅ {nombre} → PARTIDOS/{codigo_partido}_{partido_detectado}/")
                    partidos_organizados += 1
    
    return partidos_organizados

def organizar_mojones():
    """Organiza los mojones por ruta"""
    print("\n📍 ORGANIZANDO MOJONES POR RUTA...")
    
    # Patrones para identificar mojones
    patrones_mojones = [
        "*mojon*", "*mojones*", "*mile*", "*point*", 
        "*hito*", "*poste*", "*referencia*"
    ]
    
    mojones_organizados = 0
    
    for patron in patrones_mojones:
        busqueda = os.path.join(CONFIG['bases_vectores'], patron)
        archivos = glob.glob(busqueda)
        
        for archivo in archivos:
            if not archivo.endswith('.shp'):
                continue
                
            nombre = os.path.basename(archivo)
            nombre_lower = nombre.lower()
            
            # Detectar ruta del mojón
            ruta_detectada = None
            
            # Buscar por patrones de rutas
            rutas_posibles = ['RP6', 'RP61', 'RP20', 'RP24', 'RP30', 'RP40', 'RP41', 'RP42', 'RP43', 'RP44', 'RP46', 'RP47', 'RP48', 'RP51', 'RP91']
            
            for ruta in rutas_posibles:
                if ruta in nombre:
                    ruta_detectada = ruta
                    break
            
            # Si no se detecta ruta específica, poner en general
            if not ruta_detectada:
                ruta_detectada = 'MOJONES_GENERAL'
            
            # Crear carpeta de mojones para la ruta
            carpeta_mojones = os.path.join(CONFIG['bases_vectores'], "MOJONES", ruta_detectada)
            os.makedirs(carpeta_mojones, exist_ok=True)
            
            # Mover archivo y relacionados
            base_origen = os.path.splitext(archivo)[0]
            base_destino = os.path.join(carpeta_mojones, os.path.splitext(nombre)[0])
            
            movidos = 0
            for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx']:
                archivo_origen = base_origen + ext
                archivo_destino = base_destino + ext
                
                if os.path.exists(archivo_origen):
                    shutil.move(archivo_origen, archivo_destino)
                    movidos += 1
            
            if movidos > 0:
                print(f"   ✅ {nombre} → MOJONES/{ruta_detectada}/")
                mojones_organizados += 1
    
    return mojones_organizados

def organizar_red_vial():
    """Organiza la red vial general"""
    print("\n🛣️ ORGANIZANDO RED VIAL...")
    
    # Patrones para red vial
    patrones_red_vial = [
        "*red*vial*", "*rutas*", "*roads*", "*highway*",
        "*via*", "*calle*", "*calle*", "*ruta*"
    ]
    
    red_vial_organizada = 0
    
    for patron in patrones_red_vial:
        busqueda = os.path.join(CONFIG['bases_vectores'], patron)
        archivos = glob.glob(busqueda)
        
        for archivo in archivos:
            if not archivo.endswith('.shp'):
                continue
                
            nombre = os.path.basename(archivo)
            nombre_lower = nombre.lower()
            
            # Excluir archivos que ya fueron movidos (mojones, partidos)
            if any(excluir in nombre_lower for excluir in ['mojon', 'partido', 'limite']):
                continue
            
            # Crear carpeta de red vial
            carpeta_red_vial = os.path.join(CONFIG['bases_vectores'], "RED_VIAL")
            os.makedirs(carpeta_red_vial, exist_ok=True)
            
            # Mover archivo
            base_origen = os.path.splitext(archivo)[0]
            base_destino = os.path.join(carpeta_red_vial, os.path.splitext(nombre)[0])
            
            movidos = 0
            for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx']:
                archivo_origen = base_origen + ext
                archivo_destino = base_destino + ext
                
                if os.path.exists(archivo_origen):
                    shutil.move(archivo_origen, archivo_destino)
                    movidos += 1
            
            if movidos > 0:
                print(f"   ✅ {nombre} → RED_VIAL/")
                red_vial_organizada += 1
    
    return red_vial_organizada

def organizar_archivos_restantes():
    """Organiza archivos restantes no clasificados"""
    print("\n📄 ORGANIZANDO ARCHIVOS RESTANTES...")
    
    # Buscar todos los shapefiles restantes
    patron_shp = os.path.join(CONFIG['bases_vectores'], "*.shp")
    archivos_restantes = glob.glob(patron_shp)
    
    otros_organizados = 0
    
    for archivo in archivos_restantes:
        nombre = os.path.basename(archivo)
        
        # Crear carpeta para otros shapefiles
        carpeta_otros = os.path.join(CONFIG['bases_vectores'], "OTROS_SHP")
        os.makedirs(carpeta_otros, exist_ok=True)
        
        # Mover archivo
        base_origen = os.path.splitext(archivo)[0]
        base_destino = os.path.join(carpeta_otros, os.path.splitext(nombre)[0])
        
        movidos = 0
        for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx']:
            archivo_origen = base_origen + ext
            archivo_destino = base_destino + ext
            
            if os.path.exists(archivo_origen):
                shutil.move(archivo_origen, archivo_destino)
                movidos += 1
        
        if movidos > 0:
            print(f"   ✅ {nombre} → OTROS_SHP/")
            otros_organizados += 1
    
    return otros_organizados

def organizar_archivos_no_shp():
    """Organiza archivos que no son shapefiles"""
    print("\n📎 ORGANIZANDO ARCHIVOS NO SHAPEFILE...")
    
    # Buscar todos los archivos no .shp
    todos_archivos = os.listdir(CONFIG['bases_vectores'])
    archivos_no_shp = [f for f in todos_archivos if os.path.isfile(os.path.join(CONFIG['bases_vectores'], f)) and not f.endswith('.shp')]
    
    for archivo in archivos_no_shp:
        nombre = archivo
        extension = os.path.splitext(nombre)[1].lower()
        
        # Clasificar por tipo de archivo
        if extension in ['.csv', '.xlsx', '.xls']:
            carpeta_destino = "TABLAS"
        elif extension in ['.pdf', '.doc', '.docx', '.txt']:
            carpeta_destino = "DOCUMENTACION"
        elif extension in ['.jpg', '.jpeg', '.png', '.tif', '.tiff']:
            carpeta_destino = "IMAGENES"
        elif extension in ['.zip', '.rar', '.7z']:
            carpeta_destino = "COMPRIMIDOS"
        else:
            carpeta_destino = "OTROS_ARCHIVOS"
        
        carpeta_final = os.path.join(CONFIG['bases_vectores'], carpeta_destino)
        os.makedirs(carpeta_final, exist_ok=True)
        
        shutil.move(
            os.path.join(CONFIG['bases_vectores'], nombre),
            os.path.join(carpeta_final, nombre)
        )
        
        print(f"   ✅ {nombre} → {carpeta_destino}/")

def crear_readmes():
    """Crea archivos README en cada carpeta"""
    print("\n📝 CREANDO ARCHIVOS README...")
    
    readmes_creados = 0
    
    # README para PARTIDOS
    partidos_dir = os.path.join(CONFIG['bases_vectores'], "PARTIDOS")
    if os.path.exists(partidos_dir):
        readme_content = """
PARTIDOS - Límites departamentales
===================================
Contiene los shapefiles de límites de partidos de la provincia de Buenos Aires.

Estructura:
- 034_General_Alvear/    - Límites de General Alvear
- 041_General_Las_Heras/ - Límites de General Las Heras
- 058_Las_Flores/        - Límites de Las Flores
- ... etc.

Uso: Para cortes espaciales y análisis por jurisdicción.
"""
        with open(os.path.join(partidos_dir, "README.txt"), 'w', encoding='utf-8') as f:
            f.write(readme_content)
        readmes_creados += 1
    
    # README para MOJONES
    mojones_dir = os.path.join(CONFIG['bases_vectores'], "MOJONES")
    if os.path.exists(mojones_dir):
        readme_content = """
MOJONES - Puntos de referencia vial
===================================
Contiene los mojones kilométricos de las rutas provinciales.

Estructura:
- RP6/    - Mojones de Ruta Provincial 6
- RP61/   - Mojones de Ruta Provincial 61  
- RP20/   - Mojones de Ruta Provincial 20
- ... etc.
- MOJONES_GENERAL/ - Mojones no asignados a ruta específica

Uso: Para referencia kilométrica y ubicación en rutas.
"""
        with open(os.path.join(mojones_dir, "README.txt"), 'w', encoding='utf-8') as f:
            f.write(readme_content)
        readmes_creados += 1
    
    # README para RED_VIAL
    red_vial_dir = os.path.join(CONFIG['bases_vectores'], "RED_VIAL")
    if os.path.exists(red_vial_dir):
        readme_content = """
RED VIAL - Red de caminos y rutas
=================================
Contiene la red vial completa de la zona de estudio.

Incluye:
- Rutas provinciales
- Caminos rurales
- Vías terciarias
- Red vial general

Uso: Para análisis de red y conectividad.
"""
        with open(os.path.join(red_vial_dir, "README.txt"), 'w', encoding='utf-8') as f:
            f.write(readme_content)
        readmes_creados += 1
    
    print(f"   ✅ {readmes_creados} archivos README creados")

def mostrar_estructura_final():
    """Muestra la estructura final organizada"""
    print("\n📁 ESTRUCTURA FINAL ORGANIZADA:")
    print("=" * 50)
    
    bases_path = Path(CONFIG['bases_vectores'])
    
    for item in sorted(bases_path.iterdir()):
        if item.is_dir():
            print(f"📂 {item.name}/")
            
            # Mostrar subcarpetas y archivos
            try:
                for subitem in sorted(item.iterdir()):
                    if subitem.is_dir():
                        print(f"   📁 {subitem.name}/")
                        
                        # Contar shapefiles en subcarpeta
                        shp_count = len(list(subitem.glob("*.shp")))
                        if shp_count > 0:
                            print(f"      🗺️  {shp_count} capas .shp")
                    else:
                        if subitem.suffix == '.shp':
                            print(f"   🗺️  {subitem.name}")
            except:
                pass

def main():
    """Función principal de organización"""
    print("=" * 70)
    print("ORGANIZACIÓN DE BASES VECTORIALES")
    print("Separando partidos, mojones y red vial")
    print("=" * 70)
    
    # Verificar que existe la carpeta
    if not os.path.exists(CONFIG['bases_vectores']):
        print(f"❌ No se encuentra la carpeta: {CONFIG['bases_vectores']}")
        return
    
    print(f"📍 Carpeta a organizar: {CONFIG['bases_vectores']}")
    
    # 1. Organizar partidos
    partidos_count = organizar_partidos()
    
    # 2. Organizar mojones
    mojones_count = organizar_mojones()
    
    # 3. Organizar red vial
    red_vial_count = organizar_red_vial()
    
    # 4. Organizar archivos restantes
    otros_count = organizar_archivos_restantes()
    
    # 5. Organizar archivos no shapefile
    organizar_archivos_no_shp()
    
    # 6. Crear READMEs
    crear_readmes()
    
    # 7. Mostrar estructura final
    mostrar_estructura_final()
    
    print(f"\n🎯 ORGANIZACIÓN COMPLETADA:")
    print(f"   • {partidos_count} partidos organizados")
    print(f"   • {mojones_count} mojones organizados") 
    print(f"   • {red_vial_count} archivos de red vial organizados")
    print(f"   • {otros_count} otros shapefiles organizados")
    print(f"\n📁 ESTRUCTURA FINAL:")
    print(f"   PARTIDOS/     - Límites departamentales organizados")
    print(f"   MOJONES/      - Mojones por ruta específica")
    print(f"   RED_VIAL/     - Red vial general")
    print(f"   OTROS_SHP/    - Shapefiles no clasificados")
    print(f"   TABLAS/       - Archivos de datos tabulares")
    print(f"   DOCUMENTACION/ - Documentos y textos")

if __name__ == "__main__":
    main()