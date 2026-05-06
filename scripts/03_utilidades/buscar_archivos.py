import os

def buscar_archivos():
    base = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"
    
    # Buscar archivos de rutas
    print("🔍 BUSCANDO ARCHIVOS DE RUTAS...")
    for root, dirs, files in os.walk(os.path.join(base, "02_BASES_VECTORES", "rutas_provinciales")):
        for file in files:
            if file.endswith('.shp'):
                print(f"📍 Ruta encontrada: {os.path.join(root, file)}")
    
    # Buscar archivos de mojones
    print("\n🔍 BUSCANDO ARCHIVOS DE MOJONES...")
    for root, dirs, files in os.walk(os.path.join(base, "02_BASES_VECTORES", "mojones")):
        for file in files:
            if file.endswith('.shp'):
                print(f"📍 Mojón encontrado: {os.path.join(root, file)}")

buscar_archivos()