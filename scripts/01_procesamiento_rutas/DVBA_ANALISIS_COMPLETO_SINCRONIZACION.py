"""
DVBA_ANALISIS_COMPLETO_SINCRONIZACION.py
===========================================================
ANÁLISIS COMPLETO: Estructura actual y plan para sincronización OneDrive/Google Drive
"""

import os
import glob
import shutil
import pandas as pd
from datetime import datetime
from pathlib import Path

# CONFIGURACIÓN MULTI-ENTORNO
CONFIG = {
    'local_onedrive': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    'remoto_google_drive': r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales",
    'proyecto_organizado': r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales_ORGANIZADO"
}

def verificar_entornos():
    """Verifica qué entornos están disponibles"""
    print("🔍 VERIFICANDO ENTORNOS DISPONIBLES...")
    print("=" * 50)
    
    entornos_disponibles = {}
    
    for nombre, ruta in CONFIG.items():
        if os.path.exists(ruta):
            entornos_disponibles[nombre] = ruta
            print(f"   ✅ {nombre}: {ruta}")
            
            # Información adicional del directorio
            if os.path.isdir(ruta):
                archivos_shp = glob.glob(os.path.join(ruta, "**", "*.shp"), recursive=True)
                print(f"      📊 {len(archivos_shp)} archivos .shp encontrados")
        else:
            print(f"   ❌ {nombre}: NO DISPONIBLE")
    
    return entornos_disponibles

def analizar_estructura_detallada(ruta_proyecto):
    """Análisis detallado de la estructura del proyecto"""
    print(f"\n📊 ANALIZANDO ESTRUCTURA DETALLADA...")
    print(f"   📍 Ubicación: {ruta_proyecto}")
    print("=" * 60)
    
    estructura = {}
    problemas = []
    archivos_por_tipo = {}
    
    # Recorrer estructura
    for root, dirs, files in os.walk(ruta_proyecto):
        nivel = root.replace(ruta_proyecto, "").count(os.sep)
        
        # Analizar solo hasta nivel 2 para no saturar
        if nivel <= 2:
            carpeta = os.path.basename(root)
            shp_files = [f for f in files if f.endswith('.shp')]
            otros_archivos = [f for f in files if not f.endswith('.shp')]
            
            # Clasificar archivos .shp
            for shp in shp_files:
                ruta_completa = os.path.join(root, shp)
                
                # Clasificar por tipo
                if 'RP61' in shp and 'Las_Heras' in shp:
                    tipo = '❌ RP61_INCORRECTO'
                elif 'RP6' in shp and 'Alvear' in shp:
                    tipo = '❌ RP6_INCORRECTO'
                elif 'INTEGRADO' in shp:
                    tipo = '🔄 INTEGRADO'
                elif any(rp in shp for rp in ['RP6', 'RP61']):
                    tipo = '🛣️  RUTA_PRINCIPAL'
                elif any(partido in shp.lower() for partido in ['alvear', 'las heras', 'flores', 'lobos', 'navarro', 'roque', 'saladillo', '25', 'mayo']):
                    tipo = '🏛️  POR_PARTIDO'
                else:
                    tipo = '📄 OTROS_SHAPES'
                
                if tipo not in archivos_por_tipo:
                    archivos_por_tipo[tipo] = []
                archivos_por_tipo[tipo].append(ruta_completa)
            
            # Guardar información de la carpeta
            estructura[root] = {
                'nivel': nivel,
                'carpeta': carpeta,
                'shp_count': len(shp_files),
                'otros_archivos': len(otros_archivos),
                'tamaño_aprox': sum(os.path.getsize(os.path.join(root, f)) for f in files) / 1024 / 1024  # MB
            }
    
    # Mostrar estructura organizada
    print("\n📁 ESTRUCTURA ACTUAL:")
    for ruta, info in sorted(estructura.items(), key=lambda x: x[1]['nivel']):
        indent = "  " * info['nivel']
        print(f"{indent}📁 {info['carpeta']}/")
        
        if info['shp_count'] > 0:
            print(f"{indent}  🗺️  {info['shp_count']} capas .shp")
        if info['otros_archivos'] > 0:
            print(f"{indent}  📄 {info['otros_archivos']} otros archivos")
        if info['tamaño_aprox'] > 1:
            print(f"{indent}  💾 {info['tamaño_aprox']:.1f} MB")
    
    # Mostrar análisis por tipo
    print(f"\n📈 ANÁLISIS POR TIPO DE ARCHIVOS:")
    for tipo, archivos in archivos_por_tipo.items():
        print(f"   {tipo}: {len(archivos)} archivos")
        
        # Mostrar ubicaciones únicas
        carpetas = set(os.path.dirname(archivo) for archivo in archivos)
        if len(carpetas) > 1:
            print(f"      ⚠️  Disperso en {len(carpetas)} carpetas")
        
        # Mostrar ejemplos problemáticos
        if 'INCORRECTO' in tipo:
            print(f"      🚨 PROBLEMÁTICOS:")
            for archivo in archivos[:3]:
                nombre = os.path.basename(archivo)
                carpeta = os.path.basename(os.path.dirname(archivo))
                print(f"        • {nombre} en {carpeta}/")
    
    return estructura, archivos_por_tipo

def identificar_archivos_sincronizacion(archivos_por_tipo):
    """Identifica archivos que pueden causar problemas de sincronización"""
    print(f"\n🔄 IDENTIFICANDO PROBLEMAS DE SINCRONIZACIÓN...")
    print("=" * 60)
    
    problemas_sincronizacion = []
    
    # Archivos que NO deberían sincronizarse
    patrones_problematicos = [
        "*BACKUP*", "*backup*", "*temp*", "*tmp*", "*.tmp",
        "*CORREGIDO*", "*FINAL*", "*VERSION*", "*COPY*",
        "Thumbs.db", ".DS_Store", "*.lock"
    ]
    
    for patron in patrones_problematicos:
        busqueda_local = os.path.join(CONFIG['local_onedrive'], "**", patron)
        archivos_encontrados = glob.glob(busqueda_local, recursive=True)
        
        for archivo in archivos_encontrados:
            problemas_sincronizacion.append(archivo)
    
    # Archivos duplicados entre carpetas
    todos_shp = []
    for tipo, archivos in archivos_por_tipo.items():
        todos_shp.extend(archivos)
    
    nombres_archivos = {}
    for archivo in todos_shp:
        nombre = os.path.basename(archivo)
        if nombre not in nombres_archivos:
            nombres_archivos[nombre] = []
        nombres_archivos[nombre].append(archivo)
    
    duplicados = {nombre: ubicaciones for nombre, ubicaciones in nombres_archivos.items() if len(ubicaciones) > 1}
    
    if duplicados:
        print(f"   🚨 ARCHIVOS DUPLICADOS ({len(duplicados)}):")
        for nombre, ubicaciones in list(duplicados.items())[:5]:  # Mostrar solo 5
            print(f"      • {nombre}")
            for ubicacion in ubicaciones:
                carpeta = os.path.basename(os.path.dirname(ubicacion))
                print(f"        📍 {carpeta}/")
    
    if problemas_sincronizacion:
        print(f"   ⚠️  ARCHIVOS PROBLEMÁTICOS PARA SINCRONIZACIÓN ({len(problemas_sincronizacion)}):")
        for archivo in problemas_sincronizacion[:5]:
            print(f"      • {os.path.basename(archivo)}")
    
    return problemas_sincronizacion, duplicados

def proponer_estructura_organizada():
    """Propone estructura organizada para multi-entorno"""
    print(f"\n💡 PROPUESTA DE ESTRUCTURA ORGANIZADA")
    print("=" * 60)
    
    estructura_definitiva = {
        '00_DATOS_FUENTE': {
            'descripcion': 'Datos originales de referencia (solo lectura)',
            'contenido': ['SALADILLO_RED.csv', 'Límites_partidarios.shp', 'Capas base oficiales']
        },
        '01_RUTAS_OFICIALES': {
            'descripcion': 'Rutas provinciales validadas y corregidas',
            'contenido': ['RP6_General_Las_Heras.shp', 'RP61_General_Alvear.shp', 'Todas las rutas validadas']
        },
        '02_RED_VIAL_POR_PARTIDO': {
            'descripcion': 'PRODUCTO FINAL - Red vial organizada por partido',
            'subcarpetas': [
                '034_General_Alvear', '041_General_Las_Heras', '058_Las_Flores',
                '062_Lobos', '075_Navarro', '091_Roque_Perez', 
                '093_Saladillo', '109_25_de_Mayo'
            ]
        },
        '03_PROCESAMIENTO': {
            'descripcion': 'Scripts y procesos intermedios',
            'contenido': ['Scripts Python', 'Capas temporales', 'Procesos de validación']
        },
        '04_CONTROL_CALIDAD': {
            'descripcion': 'Reportes y validaciones de calidad',
            'contenido': ['Reportes longitud', 'Validación atributos', 'Estadísticas']
        },
        '05_BACKUPS': {
            'descripcion': 'Resguardos organizados por fecha',
            'subcarpetas': ['2024', '2025']  # Organizado por año
        },
        '06_SINCRONIZACION': {
            'descripcion': 'Archivos de configuración para multi-entorno',
            'contenido': ['.gitignore', 'sync_config.txt', 'readme_sincronizacion.txt']
        }
    }
    
    print("🏗️ ESTRUCTURA DEFINITIVA PROPUESTA:")
    for carpeta, info in estructura_definitiva.items():
        print(f"\n   📁 {carpeta}/")
        print(f"      📝 {info['descripcion']}")
        
        if 'contenido' in info:
            for item in info['contenido'][:3]:  # Mostrar solo 3 items
                print(f"      • {item}")
            if len(info['contenido']) > 3:
                print(f"      ... y {len(info['contenido']) - 3} más")
        
        if 'subcarpetas' in info:
            for subcarpeta in info['subcarpetas'][:3]:  # Mostrar solo 3
                print(f"      📂 {subcarpeta}/")
            if len(info['subcarpetas']) > 3:
                print(f"      ... y {len(info['subcarpetas']) - 3} más")
    
    return estructura_definitiva

def generar_plan_migracion_multi_entorno(archivos_por_tipo, problemas_sincronizacion):
    """Genera plan de migración para multi-entorno"""
    print(f"\n🔄 PLAN DE MIGRACIÓN MULTI-ENTORNO")
    print("=" * 60)
    
    print("📋 FASES DE MIGRACIÓN:")
    
    print(f"\n   1. 🗑️  LIMPIEZA INICIAL")
    print(f"      • Eliminar archivos RP61_General_Las_Heras.shp")
    print(f"      • Eliminar archivos RP6_General_Alvear.shp") 
    print(f"      • Limpiar archivos temporales y duplicados")
    
    print(f"\n   2. 🏗️  CREAR ESTRUCTURA ORGANIZADA")
    print(f"      • Crear proyecto en: {CONFIG['proyecto_organizado']}")
    print(f"      • Establecer estructura definitiva")
    print(f"      • Configurar .gitignore para sincronización")
    
    print(f"\n   3. 📁 MIGRAR DATOS ESENCIALES")
    print(f"      • Copiar rutas oficiales validadas")
    print(f"      • Organizar por partido en 02_RED_VIAL_POR_PARTIDO/")
    print(f"      • Mantener solo una versión de cada archivo")
    
    print(f"\n   4. 🔄 CONFIGURAR SINCRONIZACIÓN")
    print(f"      • OneDrive: {CONFIG['local_onedrive']}")
    print(f"      • Google Drive: {CONFIG['remoto_google_drive']}")
    print(f"      • Excluir carpetas de backup y temporales")
    
    print(f"\n   5. ✅ VALIDACIÓN FINAL")
    print(f"      • Verificar que ambos entornos tengan misma estructura")
    print(f"      • Confirmar que no hay archivos problemáticos")
    print(f"      • Documentar procedimiento de trabajo")

def crear_script_migracion_completo():
    """Crea script completo de migración"""
    print(f"\n⚙️  GENERANDO SCRIPT DE MIGRACIÓN COMPLETO...")
    
    script_content = f'''"""
DVBA_MIGRACION_COMPLETA_MULTI_ENTORNO.py
===========================================================
MIGRACIÓN COMPLETA: OneDrive + Google Drive con estructura organizada
"""

import os
import glob
import shutil
from datetime import datetime

# CONFIGURACIÓN MULTI-ENTORNO
CONFIG = {{
    'local_onedrive': r"{CONFIG['local_onedrive']}",
    'remoto_google_drive': r"{CONFIG['remoto_google_drive']}", 
    'proyecto_organizado': r"{CONFIG['proyecto_organizado']}"
}}

def crear_estructura_definitiva():
    """Crea la estructura organizada definitiva"""
    print("🏗️ CREANDO ESTRUCTURA DEFINITIVA...")
    
    estructura = {{
        '00_DATOS_FUENTE': [],
        '01_RUTAS_OFICIALES': [],
        '02_RED_VIAL_POR_PARTIDO': [
            '034_General_Alvear', '041_General_Las_Heras', '058_Las_Flores',
            '062_Lobos', '075_Navarro', '091_Roque_Perez', 
            '093_Saladillo', '109_25_de_Mayo'
        ],
        '03_PROCESAMIENTO': ['SCRIPTS', 'TEMPORALES'],
        '04_CONTROL_CALIDAD': ['REPORTES', 'VALIDACIONES'],
        '05_BACKUPS': ['2024', '2025'],
        '06_SINCRONIZACION': []
    }}
    
    for carpeta_principal, subcarpetas in estructura.items():
        ruta_principal = os.path.join(CONFIG['proyecto_organizado'], carpeta_principal)
        os.makedirs(ruta_principal, exist_ok=True)
        print(f"   ✅ {{carpeta_principal}}/")
        
        for subcarpeta in subcarpetas:
            ruta_sub = os.path.join(ruta_principal, subcarpeta)
            os.makedirs(ruta_sub, exist_ok=True)
            print(f"      📂 {{subcarpeta}}/")
    
    # Crear archivos de configuración
    crear_archivos_configuracion()

def crear_archivos_configuracion():
    """Crea archivos de configuración para sincronización"""
    print("\\n⚙️  CREANDO ARCHIVOS DE CONFIGURACIÓN...")
    
    # .gitignore para excluir archivos problemáticos
    gitignore_content = """
# Archivos temporales y de sistema
*.tmp
*.temp
Thumbs.db
.DS_Store
*.lock

# Backups automáticos  
*BACKUP*
*backup*
*CORREGIDO*
*FINAL_BACKUP*

# Carpetas de procesamiento
05_BACKUPS/
03_PROCESAMIENTO/TEMPORALES/

# Archivos grandes no esenciales
*.zip
*.rar
*.7z
"""
    
    gitignore_path = os.path.join(CONFIG['proyecto_organizado'], '.gitignore')
    with open(gitignore_path, 'w', encoding='utf-8') as f:
        f.write(gitignore_content)
    print(f"   ✅ .gitignore creado")
    
    # README de sincronización
    readme_content = f"""
PROYECTO REDES VIALES - CONFIGURACIÓN MULTI-ENTORNO
===================================================

ENTORNOS DE TRABAJO:
• OFICINA (OneDrive): {CONFIG['local_onedrive']}
• REMOTO (Google Drive): {CONFIG['remoto_google_drive']}

ESTRUCTURA ORGANIZADA:
00_DATOS_FUENTE/       - Datos originales (solo lectura)
01_RUTAS_OFICIALES/    - Rutas validadas y corregidas  
02_RED_VIAL_POR_PARTIDO/ - PRODUCTO FINAL organizado
03_PROCESAMIENTO/      - Scripts y procesos
04_CONTROL_CALIDAD/    - Reportes y validaciones
05_BACKUPS/            - Resguardos organizados
06_SINCRONIZACION/     - Esta documentación

INSTRUCCIONES:
1. Trabajar SIEMPRE en la estructura organizada
2. Sincronizar ambos entornos regularmente
3. No modificar archivos en 00_DATOS_FUENTE/
4. Usar 05_BACKUPS/ para resguardos manuales
"""
    
    readme_path = os.path.join(CONFIG['proyecto_organizado'], '06_SINCRONIZACION', 'INSTRUCCIONES_SINCRONIZACION.txt')
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(readme_content)
    print(f"   ✅ Instrucciones de sincronización creadas")

def migrar_datos_esenciales():
    """Migra solo los datos esenciales validados"""
    print("\\n📁 MIGRANDO DATOS ESENCIALES...")
    
    # Patrones de archivos a migrar (solo los correctos)
    patrones_migrar = [
        # Rutas oficiales validadas
        "RP6_General_Las_Heras*.shp",
        "RP61_General_Alvear*.shp", 
        "RP*_INTEGRADO.shp",
        
        # Datos fuente
        "SALADILLO_RED.csv",
        "*partido*.shp",
        "*limite*.shp"
    ]
    
    for patron in patrones_migrar:
        # Buscar en ambos entornos
        for entorno, ruta_base in [('onedrive', CONFIG['local_onedrive']), 
                                  ('gdrive', CONFIG['remoto_google_drive'])]:
            
            if os.path.exists(ruta_base):
                busqueda = os.path.join(ruta_base, "**", patron)
                archivos = glob.glob(busqueda, recursive=True)
                
                for archivo in archivos:
                    nombre = os.path.basename(archivo)
                    
                    # EXCLUIR archivos problemáticos
                    if ('RP61' in nombre and 'Las_Heras' in nombre) or 
                       ('RP6' in nombre and 'Alvear' in nombre) or
                       ('BACKUP' in nombre) or ('CORREGIDO' in nombre):
                        continue
                    
                    # Determinar destino según tipo
                    if 'SALADILLO_RED' in nombre:
                        destino_carpeta = '00_DATOS_FUENTE'
                    elif any(rp in nombre for rp in ['RP6', 'RP61', 'RP20', 'RP24', 'RP30', 'RP40', 'RP41', 'RP42', 'RP43', 'RP44', 'RP46', 'RP47', 'RP48', 'RP51', 'RP91']):
                        destino_carpeta = '01_RUTAS_OFICIALES'
                    else:
                        destino_carpeta = '00_DATOS_FUENTE'
                    
                    destino = os.path.join(CONFIG['proyecto_organizado'], destino_carpeta, nombre)
                    
                    # Copiar si no existe
                    if not os.path.exists(destino):
                        # Copiar archivos relacionados
                        base_origen = os.path.splitext(archivo)[0]
                        base_destino = os.path.splitext(destino)[0]
                        
                        for ext in ['.shp', '.shx', '.dbf', '.prj', '.cpg']:
                            archivo_origen = base_origen + ext
                            archivo_destino = base_destino + ext
                            
                            if os.path.exists(archivo_origen):
                                shutil.copy2(archivo_origen, archivo_destino)
                        
                        print(f"   ✅ {nombre} desde {entorno}")

def main():
    """Función principal de migración"""
    print("=" * 70)
    print("MIGRACIÓN COMPLETA - ESTRUCTURA ORGANIZADA MULTI-ENTORNO")
    print("=" * 70)
    
    # Verificar entornos
    print("🔍 Verificando entornos...")
    for nombre, ruta in CONFIG.items():
        if os.path.exists(ruta):
            print(f"   ✅ {nombre}: Disponible")
        else:
            print(f"   ⚠️  {nombre}: No disponible")
    
    # 1. Crear estructura
    crear_estructura_definitiva()
    
    # 2. Migrar datos esenciales
    migrar_datos_esenciales()
    
    print(f"\\n🎯 MIGRACIÓN COMPLETADA")
    print(f"   Proyecto organizado: {CONFIG['proyecto_organizado']}")
    print(f"\\n📝 PRÓXIMOS PASOS:")
    print(f"   1. Configurar sincronización en ambos entornos")
    print(f"   2. Trabajar SIEMPRE en la estructura organizada")
    print(f"   3. Sincronizar cambios regularmente")

if __name__ == "__main__":
    main()
'''
    
    script_path = os.path.join(CONFIG['local_onedrive'], "SCRIPT_MIGRACION_COMPLETA.py")
    with open(script_path, 'w', encoding='utf-8') as f:
        f.write(script_content)
    
    print(f"   ✅ Script generado: {script_path}")

def main():
    """Función principal - Análisis completo"""
    print("=" * 70)
    print("ANÁLISIS COMPLETO - ORGANIZACIÓN MULTI-ENTORNO")
    print("=" * 70)
    
    # 1. Verificar entornos disponibles
    entornos = verificar_entornos()
    
    if 'local_onedrive' not in entornos:
        print("❌ No se puede acceder al entorno local. Verifica la ruta.")
        return
    
    # 2. Analizar estructura actual
    estructura, archivos_por_tipo = analizar_estructura_detallada(entornos['local_onedrive'])
    
    # 3. Identificar problemas de sincronización
    problemas_sincronizacion, duplicados = identificar_archivos_sincronizacion(archivos_por_tipo)
    
    # 4. Proponer estructura organizada
    estructura_definitiva = proponer_estructura_organizada()
    
    # 5. Generar plan de migración
    generar_plan_migracion_multi_entorno(archivos_por_tipo, problemas_sincronizacion)
    
    # 6. Crear script de migración
    crear_script_migracion_completo()
    
    print(f"\n🎯 ANÁLISIS COMPLETADO")
    print(f"\n🚀 ACCIÓN RECOMENDADA:")
    print(f"   1. Revisa el análisis anterior")
    print(f"   2. Ejecuta: SCRIPT_MIGRACION_COMPLETA.py")
    print(f"   3. Configura la sincronización")
    print(f"   4. Comienza a trabajar en la nueva estructura")

if __name__ == "__main__":
    main()