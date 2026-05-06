"""
DVBA_MIGRACION_COMPLETA_CON_TODOS_DATOS.py
===========================================================
MIGRACIÓN COMPLETA: Incluye todas las carpetas importantes
"""

import os
import glob
import shutil
from datetime import datetime

# CONFIGURACIÓN
CONFIG = {
    'origen': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    'destino': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales_ORGANIZADO"
}

def migrar_capas_generadas():
    """Migra las capas generadas de 03_CAPAS_GENERADAS"""
    print("📁 MIGRANDO CAPAS GENERADAS...")
    
    origen_capas = os.path.join(CONFIG['origen'], "03_CAPAS_GENERADAS")
    destino_capas = os.path.join(CONFIG['destino'], "00_DATOS_FUENTE", "03_CAPAS_GENERADAS")
    
    if os.path.exists(origen_capas):
        os.makedirs(destino_capas, exist_ok=True)
        
        # Copiar todos los archivos .shp
        patron_shp = os.path.join(origen_capas, "**", "*.shp")
        archivos_shp = glob.glob(patron_shp, recursive=True)
        
        for archivo in archivos_shp:
            nombre = os.path.basename(archivo)
            
            # Excluir archivos problemáticos
            if any(incorrecto in nombre for incorrecto in [
                'RP61_General_Las_Heras', 
                'RP6_General_Alvear'
            ]):
                continue
                
            # Copiar archivo y relacionados
            base_origen = os.path.splitext(archivo)[0]
            base_destino = os.path.join(destino_capas, os.path.splitext(nombre)[0])
            
            copiados = 0
            for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg']:
                archivo_origen = base_origen + ext
                archivo_destino = base_destino + ext
                
                if os.path.exists(archivo_origen):
                    shutil.copy2(archivo_origen, archivo_destino)
                    copiados += 1
            
            if copiados > 0:
                print(f"   ✅ {nombre}")
        
        # Copiar otros archivos importantes
        for item in os.listdir(origen_capas):
            ruta_item = os.path.join(origen_capas, item)
            if os.path.isfile(ruta_item) and not item.endswith('.shp'):
                shutil.copy2(ruta_item, os.path.join(destino_capas, item))
                print(f"   ✅ {item}")
    else:
        print("   ⚠️  Carpeta 03_CAPAS_GENERADAS no encontrada")

def migrar_tablas_centrales():
    """Migra las bases de datos CSV centrales de 05_TABLAS"""
    print("\n📊 MIGRANDO TABLAS CENTRALES...")
    
    origen_tablas = os.path.join(CONFIG['origen'], "05_TABLAS")
    destino_tablas = os.path.join(CONFIG['destino'], "00_DATOS_FUENTE", "05_TABLAS")
    
    if os.path.exists(origen_tablas):
        os.makedirs(destino_tablas, exist_ok=True)
        
        # Copiar todos los archivos CSV y otros importantes
        extensiones_importantes = ['.csv', '.xlsx', '.xls', '.txt', '.json']
        
        for extension in extensiones_importantes:
            patron = os.path.join(origen_tablas, f"*{extension}")
            archivos = glob.glob(patron)
            
            for archivo in archivos:
                nombre = os.path.basename(archivo)
                shutil.copy2(archivo, os.path.join(destino_tablas, nombre))
                print(f"   ✅ {nombre}")
        
        # Buscar archivos específicamente nombrados
        archivos_especiales = ['SALADILLO_RED.csv', 'RED_VIAL.csv', 'RUTAS.csv']
        for archivo_especial in archivos_especiales:
            ruta_especial = os.path.join(origen_tablas, archivo_especial)
            if os.path.exists(ruta_especial):
                shutil.copy2(ruta_especial, os.path.join(destino_tablas, archivo_especial))
                print(f"   ✅ {archivo_especial} (especial)")
    else:
        print("   ⚠️  Carpeta 05_TABLAS no encontrada")

def migrar_bases_vectores():
    """Migra las capas base de 02_BASES_VECTORES"""
    print("\n🗺️ MIGRANDO BASES VECTORIALES...")
    
    origen_vectores = os.path.join(CONFIG['origen'], "02_BASES_VECTORES")
    destino_vectores = os.path.join(CONFIG['destino'], "00_DATOS_FUENTE", "02_BASES_VECTORES")
    
    if os.path.exists(origen_vectores):
        os.makedirs(destino_vectores, exist_ok=True)
        
        # Copiar todos los shapefiles
        patron_shp = os.path.join(origen_vectores, "**", "*.shp")
        archivos_shp = glob.glob(patron_shp, recursive=True)
        
        for archivo in archivos_shp:
            nombre = os.path.basename(archivo)
            
            # Copiar archivo y relacionados
            base_origen = os.path.splitext(archivo)[0]
            base_destino = os.path.join(destino_vectores, os.path.splitext(nombre)[0])
            
            copiados = 0
            for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx']:
                archivo_origen = base_origen + ext
                archivo_destino = base_destino + ext
                
                if os.path.exists(archivo_origen):
                    shutil.copy2(archivo_origen, archivo_destino)
                    copiados += 1
            
            if copiados > 0:
                print(f"   ✅ {nombre}")
        
        # Copiar otros archivos de la carpeta principal
        for item in os.listdir(origen_vectores):
            ruta_item = os.path.join(origen_vectores, item)
            if os.path.isfile(ruta_item):
                shutil.copy2(ruta_item, os.path.join(destino_vectores, item))
                print(f"   ✅ {item}")
    else:
        print("   ⚠️  Carpeta 02_BASES_VECTORES no encontrada")

def migrar_rutas_por_partidos():
    """Migra y organiza las carpetas RP_*_POR_PARTIDOS"""
    print("\n🏛️ MIGRANDO RUTAS POR PARTIDOS...")
    
    # Buscar todas las carpetas RP_*_POR_PARTIDOS
    patron_carpetas = os.path.join(CONFIG['origen'], "**", "*POR_PARTIDOS")
    carpetas_partidos = glob.glob(patron_carpetas, recursive=True)
    
    for carpeta_origen in carpetas_partidos:
        nombre_carpeta = os.path.basename(carpeta_origen)
        print(f"   📂 Procesando: {nombre_carpeta}")
        
        # Crear carpeta correspondiente en destino
        carpeta_destino = os.path.join(CONFIG['destino'], "03_PROCESAMIENTO", "RUTAS_POR_PARTIDOS", nombre_carpeta)
        os.makedirs(carpeta_destino, exist_ok=True)
        
        # Copiar shapefiles válidos
        patron_shp = os.path.join(carpeta_origen, "*.shp")
        archivos_shp = glob.glob(patron_shp)
        
        for archivo in archivos_shp:
            nombre = os.path.basename(archivo)
            
            # Excluir archivos problemáticos
            if any(incorrecto in nombre for incorrecto in [
                'RP61_General_Las_Heras', 
                'RP6_General_Alvear'
            ]):
                continue
                
            # Copiar archivo y relacionados
            base_origen = os.path.splitext(archivo)[0]
            base_destino = os.path.join(carpeta_destino, os.path.splitext(nombre)[0])
            
            copiados = 0
            for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg']:
                archivo_origen = base_origen + ext
                archivo_destino = base_destino + ext
                
                if os.path.exists(archivo_origen):
                    shutil.copy2(archivo_origen, archivo_destino)
                    copiados += 1
            
            if copiados > 0:
                print(f"      ✅ {nombre}")
        
        # Copiar archivos de texto y reportes
        for extension in ['.txt', '.log', '.csv']:
            patron = os.path.join(carpeta_origen, f"*{extension}")
            archivos = glob.glob(patron)
            
            for archivo in archivos:
                nombre = os.path.basename(archivo)
                shutil.copy2(archivo, os.path.join(carpeta_destino, nombre))
                print(f"      ✅ {nombre}")

def migrar_scripts_actualizados():
    """Migra scripts actualizados y organizados"""
    print("\n📜 MIGRANDO SCRIPTS ACTUALIZADOS...")
    
    origen_scripts = os.path.join(CONFIG['origen'], "08_SCRIPTS")
    destino_scripts = os.path.join(CONFIG['destino'], "03_PROCESAMIENTO", "SCRIPTS")
    
    if os.path.exists(origen_scripts):
        os.makedirs(destino_scripts, exist_ok=True)
        
        # Copiar todos los archivos .py
        patron_python = os.path.join(origen_scripts, "**", "*.py")
        scripts_python = glob.glob(patron_python, recursive=True)
        
        for script in scripts_python:
            nombre = os.path.basename(script)
            shutil.copy2(script, os.path.join(destino_scripts, nombre))
            print(f"   ✅ {nombre}")
        
        # Crear estructura organizada de scripts
        crear_estructura_scripts_organizada(destino_scripts)
    else:
        print("   ⚠️  Carpeta 08_SCRIPTS no encontrada")

def crear_estructura_scripts_organizada(destino_scripts):
    """Crea estructura organizada para los scripts"""
    subcarpetas = {
        '01_PROCESAMIENTO_RUTAS': 'Procesamiento de rutas provinciales',
        '02_ANALISIS_DATOS': 'Análisis y validación de datos',
        '03_ORGANIZACION': 'Organización y estructuración',
        '04_UTILIDADES': 'Utilidades y herramientas',
        '05_REPORTES': 'Generación de reportes'
    }
    
    for carpeta, descripcion in subcarpetas.items():
        ruta_carpeta = os.path.join(destino_scripts, carpeta)
        os.makedirs(ruta_carpeta, exist_ok=True)
        
        # Crear README en cada carpeta
        with open(os.path.join(ruta_carpeta, "README.txt"), 'w', encoding='utf-8') as f:
            f.write(f"{carpeta}\n{'='*40}\n{descripcion}\n")
        
        print(f"   📂 {carpeta}/ - {descripcion}")

def migrar_proyecto_qgis():
    """Migra el proyecto QGIS principal"""
    print("\n🎨 MIGRANDO PROYECTO QGIS...")
    
    origen_proyecto = os.path.join(CONFIG['origen'], "01_PROYECTO_QGIS")
    destino_proyecto = os.path.join(CONFIG['destino'], "07_PROYECTO_QGIS")
    
    if os.path.exists(origen_proyecto):
        os.makedirs(destino_proyecto, exist_ok=True)
        
        # Copiar archivos de proyecto QGIS
        for extension in ['.qgz', '.qgs']:
            patron = os.path.join(origen_proyecto, f"*{extension}")
            archivos = glob.glob(patron)
            
            for archivo in archivos:
                nombre = os.path.basename(archivo)
                shutil.copy2(archivo, os.path.join(destino_proyecto, nombre))
                print(f"   ✅ {nombre}")
        
        # Copiar otros archivos de configuración
        for item in os.listdir(origen_proyecto):
            ruta_item = os.path.join(origen_proyecto, item)
            if os.path.isfile(ruta_item):
                shutil.copy2(ruta_item, os.path.join(destino_proyecto, item))
    else:
        print("   ⚠️  Carpeta 01_PROYECTO_QGIS no encontrada")

def crear_estructura_completa():
    """Crea la estructura completa organizada"""
    print("🏗️ CREANDO ESTRUCTURA COMPLETA ORGANIZADA...")
    
    estructura = {
        '00_DATOS_FUENTE': {
            '02_BASES_VECTORES': 'Capas vectoriales base',
            '03_CAPAS_GENERADAS': 'Capas generadas en procesamiento', 
            '05_TABLAS': 'Tablas y bases de datos',
            'DATOS_REFERENCIA': 'Otros datos de referencia'
        },
        '01_RUTAS_OFICIALES': 'Rutas provinciales validadas',
        '02_RED_VIAL_POR_PARTIDO': {
            '034_General_Alvear': 'Red vial General Alvear',
            '041_General_Las_Heras': 'Red vial General Las Heras',
            '058_Las_Flores': 'Red vial Las Flores',
            '062_Lobos': 'Red vial Lobos',
            '075_Navarro': 'Red vial Navarro',
            '091_Roque_Perez': 'Red vial Roque Pérez',
            '093_Saladillo': 'Red vial Saladillo', 
            '109_25_de_Mayo': 'Red vial 25 de Mayo'
        },
        '03_PROCESAMIENTO': {
            'SCRIPTS': 'Scripts Python organizados',
            'RUTAS_POR_PARTIDOS': 'Procesamiento por partido',
            'TEMPORALES': 'Archivos temporales'
        },
        '04_CONTROL_CALIDAD': {
            'REPORTES': 'Reportes de validación',
            'ESTADISTICAS': 'Estadísticas y métricas',
            'VALIDACIONES': 'Validaciones de datos'
        },
        '05_BACKUPS': {
            '2024': 'Resguardos 2024',
            '2025': 'Resguardos 2025'
        },
        '06_SINCRONIZACION': 'Configuración multi-entorno',
        '07_PROYECTO_QGIS': 'Proyectos QGIS principales'
    }
    
    for carpeta_principal, subestructura in estructura.items():
        ruta_principal = os.path.join(CONFIG['destino'], carpeta_principal)
        os.makedirs(ruta_principal, exist_ok=True)
        print(f"   ✅ {carpeta_principal}/")
        
        if isinstance(subestructura, dict):
            for subcarpeta, descripcion in subestructura.items():
                ruta_sub = os.path.join(ruta_principal, subcarpeta)
                os.makedirs(ruta_sub, exist_ok=True)
                
                # Crear README descriptivo
                with open(os.path.join(ruta_sub, "README.txt"), 'w', encoding='utf-8') as f:
                    f.write(f"{subcarpeta}\n{'='*40}\n{descripcion}\n")
                
                print(f"      📂 {subcarpeta}/ - {descripcion}")
        else:
            # Crear README para carpeta principal
            with open(os.path.join(ruta_principal, "README.txt"), 'w', encoding='utf-8') as f:
                f.write(f"{carpeta_principal}\n{'='*40}\n{subestructura}\n")

def generar_reporte_migracion():
    """Genera reporte de lo que se migró"""
    print("\n📊 GENERANDO REPORTE DE MIGRACIÓN...")
    
    reporte_path = os.path.join(CONFIG['destino'], "REPORTE_MIGRACION.txt")
    
    with open(reporte_path, 'w', encoding='utf-8') as f:
        f.write("REPORTE DE MIGRACIÓN COMPLETA\n")
        f.write("=" * 50 + "\n\n")
        f.write(f"Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
        f.write(f"Origen: {CONFIG['origen']}\n")
        f.write(f"Destino: {CONFIG['destino']}\n\n")
        
        f.write("CARPETAS MIGRADAS:\n")
        f.write("- 02_BASES_VECTORES/\n")
        f.write("- 03_CAPAS_GENERADAS/\n") 
        f.write("- 05_TABLAS/\n")
        f.write("- 08_SCRIPTS/\n")
        f.write("- 01_PROYECTO_QGIS/\n")
        f.write("- Todas las carpetas RP_*_POR_PARTIDOS/\n\n")
        
        f.write("ARCHIVOS EXCLUIDOS:\n")
        f.write("- RP61_General_Las_Heras.* (INCORRECTO)\n")
        f.write("- RP6_General_Alvear.* (INCORRECTO)\n")
        f.write("- Archivos de backup temporales\n\n")
        
        f.write("ESTRUCTURA CREADA:\n")
        f.write("00_DATOS_FUENTE/     - Todos los datos de entrada\n")
        f.write("01_RUTAS_OFICIALES/  - Rutas validadas\n")
        f.write("02_RED_POR_PARTIDO/  - Producto final organizado\n")
        f.write("03_PROCESAMIENTO/    - Scripts y procesos\n")
        f.write("04_CONTROL_CALIDAD/  - Reportes y validaciones\n")
        f.write("05_BACKUPS/          - Resguardos organizados\n")
        f.write("06_SINCRONIZACION/   - Configuración\n")
        f.write("07_PROYECTO_QGIS/    - Proyectos QGIS\n")
    
    print(f"   ✅ Reporte guardado: {reporte_path}")

def main():
    """Función principal de migración completa"""
    print("=" * 70)
    print("MIGRACIÓN COMPLETA - TODOS LOS DATOS IMPORTANTES")
    print("=" * 70)
    
    # Verificar que el origen existe
    if not os.path.exists(CONFIG['origen']):
        print(f"❌ No se encuentra el directorio origen: {CONFIG['origen']}")
        return
    
    print(f"📍 Origen: {CONFIG['origen']}")
    print(f"📍 Destino: {CONFIG['destino']}")
    
    # 1. Crear estructura completa
    crear_estructura_completa()
    
    # 2. Migrar todas las carpetas importantes
    migrar_bases_vectores()
    migrar_capas_generadas() 
    migrar_tablas_centrales()
    migrar_rutas_por_partidos()
    migrar_scripts_actualizados()
    migrar_proyecto_qgis()
    
    # 3. Generar reporte
    generar_reporte_migracion()
    
    print(f"\n🎯 MIGRACIÓN COMPLETADA")
    print(f"\n📝 ESTRUCTURA FINAL ORGANIZADA:")
    print(f"   00_DATOS_FUENTE/     - Bases vectoriales, tablas, capas generadas")
    print(f"   01_RUTAS_OFICIALES/  - Rutas validadas y corregidas") 
    print(f"   02_RED_VIAL_POR_PARTIDO/ - Producto final organizado")
    print(f"   03_PROCESAMIENTO/    - Scripts y procesos intermedios")
    print(f"   04_CONTROL_CALIDAD/  - Reportes y validaciones")
    print(f"   05_BACKUPS/          - Resguardos organizados")
    print(f"   06_SINCRONIZACION/   - Configuración multi-entorno")
    print(f"   07_PROYECTO_QGIS/    - Proyectos QGIS principales")

if __name__ == "__main__":
    main()