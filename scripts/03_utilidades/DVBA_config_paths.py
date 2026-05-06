"""
DVBA_config_paths.py
===========================================================
SCRIPT: Configuración Centralizada de Paths del Proyecto
DVBA - DIRECCIÓN DE VIALIDAD DE LA PROVINCIA DE BUENOS AIRES
AUTOR: Ing. Luciano Lamaita - División Técnica Departamento Zonal VI Saladillo
SCRIPT: DVBA_config_paths.py
VERSION: 2025.10.1.1 (Generado: 2025-10-19)
CODIGO: DVBA-Z6-CONFIG-PATHS-001
CONTACTO: lulamaita@vialidad.gba.gov.ar

DESCRIPCIÓN:
    - Configuración centralizada de paths para proyecto Zona VI
    - Definición de estructura completa de carpetas
    - Configuración de rutas de entrada y salida
    - Constantes del proyecto y parámetros globales

DERECHOS: Dirección de Vialidad de la Provincia de Buenos Aires
DEPARTAMENTO: Zona VI Saladillo - División Técnica
"""

import os

# =============================================================================
# CONFIGURACIÓN PRINCIPAL DE PATHS - ACTUALIZAR CON PATHS REALES
# =============================================================================

# Path base del proyecto
BASE_PATH = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"

# Configuración centralizada de paths
config = {
    # Paths de entrada - DATOS REALES (ACTUALIZAR SEGÚN RESULTADO DE BÚSQUEDA)
    'BASE_PATH': BASE_PATH,
    
    # ❌ ACTUALIZAR ESTOS PATHS CON LAS UBICACIONES REALES
    'RUTAS_ZONAVI': os.path.join(BASE_PATH, "02_BASES_VECTORES", "rutas_provinciales", "rutas_zona_VI.shp"),  # ACTUALIZAR
    'MOJONES_ZONAVI': os.path.join(BASE_PATH, "02_BASES_VECTORES", "mojones", "shp", "Mojones_DVBA_ZN6.shp"),  # ACTUALIZAR
    
    # Path de red vial completa (si existe)
    'RED_VIAL_COMPLETA': os.path.join(BASE_PATH, "02_BASES_VECTORES", "red_vial_pba", "shp"),
    
    # Paths de salida - resultados
    'OUTPUT_ZONAVI': os.path.join(BASE_PATH, "03_CAPAS_GENERADAS", "ZONA_VI"),
    'OUTPUT_TABLAS': os.path.join(BASE_PATH, "04_TABLAS"),
    'OUTPUT_BACKUP': os.path.join(BASE_PATH, "07_BACKUPS"),
    'OUTPUT_IMAGENES': os.path.join(BASE_PATH, "05_IMAGENES"),
    'OUTPUT_EXPORTS': os.path.join(BASE_PATH, "06_EXPORTS"),
    
    # Paths de scripts
    'SCRIPTS_PRINCIPAL': os.path.join(BASE_PATH, "08_SCRIPTS", "01_PROCESAMIENTO_RUTAS"),
    'SCRIPTS_TOPOLOGIA': os.path.join(BASE_PATH, "08_SCRIPTS", "02_ANALISIS_TOPOLOGIA"),
    'SCRIPTS_UTILIDADES': os.path.join(BASE_PATH, "08_SCRIPTS", "03_UTILIDADES"),
    'SCRIPTS_REPORTES': os.path.join(BASE_PATH, "08_SCRIPTS", "04_REPORTES")
}

# =============================================================================
# PARÁMETROS DEL PROYECTO
# =============================================================================

# Rutas de Zona VI para procesamiento
RUTAS_ZONA_VI = ['6', '20', '24', '30', '40', '41', '42', '43', '44', '46', '47', '48', '51', '61', '91']

# Parámetros de procesamiento
PARAMETROS_PROCESAMIENTO = {
    'buffer_asignacion_mojones': 100,  # metros
    'tolerancia_geometrias': 0.001,   # tolerancia para operaciones geométricas
    'sistema_referencia_principal': 'EPSG:5347',  # POSGAR 2007 Argentina
    'unidades_trabajo': 'metros'
}

# =============================================================================
# METADATOS INSTITUCIONALES
# =============================================================================

METADATOS_DVBA = {
    'institucion': 'Dirección de Vialidad de la Provincia de Buenos Aires',
    'departamento_zonal': 'Zona VI Saladillo',
    'division_tecnica': 'División Técnica',
    'autor_principal': 'Ing. Luciano Lamaita',
    'contacto_oficial': 'lulamaita@vialidad.gba.gov.ar',
    'version_proyecto': '2025.10.1.1',
    'codigo_proyecto': 'DVBA-Z6-PROCESAMIENTO-2025'
}

# =============================================================================
# FUNCIÓN PARA VERIFICAR ARCHIVOS
# =============================================================================

def verificar_archivos_entrada():
    """
    Verifica que los archivos de entrada requeridos existan
    """
    print("🔍 DVBA - Verificando archivos de entrada...")
    
    archivos_requeridos = [
        ('Rutas Zona VI', config['RUTAS_ZONAVI']),
        ('Mojones Zona VI', config['MOJONES_ZONAVI'])
    ]
    
    archivos_ok = 0
    for nombre, path in archivos_requeridos:
        if os.path.exists(path):
            print(f"  ✅ {nombre}: {os.path.basename(path)}")
            archivos_ok += 1
        else:
            print(f"  ❌ {nombre}: NO ENCONTRADO - {path}")
    
    return archivos_ok == len(archivos_requeridos)

if __name__ == "__main__":
    print("=" * 70)
    print("CONFIGURACIÓN DVBA - VERIFICACIÓN DE ARCHIVOS")
    print("=" * 70)
    
    if verificar_archivos_entrada():
        print("\n🎉 Todos los archivos de entrada están disponibles")
    else:
        print("\n⚠️  ALGUNOS ARCHIVOS NO SE ENCUENTRAN")
        print("   Por favor, actualiza los paths en DVBA_config_paths.py")
        print("   con las ubicaciones reales de los archivos.")