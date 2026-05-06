import os
import glob

def verificar_estructura_rutas():
    base = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"
    
    print("🔍 VERIFICANDO ESTRUCTURA DE RUTAS...")
    
    # 1. Buscar archivo consolidado
    ruta_consolidada = os.path.join(base, "02_BASES_VECTORES", "rutas_provinciales", "rutas_zona_VI.shp")
    if os.path.exists(ruta_consolidada):
        print("✅ ENCONTRADO: rutas_zona_VI.shp (consolidado)")
        return "consolidado", ruta_consolidada
    
    # 2. Buscar shapefiles de rutas individuales
    rutas_individuales = []
    for ruta in ['6', '20', '24', '30', '40', '41', '42', '43', '44', '46', '47', '48', '51', '61', '91']:
        patron = os.path.join(base, "02_BASES_VECTORES", "rutas_provinciales", f"rp_{ruta}", "shapes", f"rp_{ruta}_completa.shp")
        if os.path.exists(patron):
            rutas_individuales.append(patron)
            print(f"✅ ENCONTRADO: RP-{ruta} -> {os.path.basename(patron)}")
    
    if rutas_individuales:
        print(f"✅ ENCONTRADOS: {len(rutas_individuales)} shapefiles individuales de rutas")
        return "individuales", rutas_individuales
    
    # 3. Buscar cualquier shapefile de ruta
    print("Buscando cualquier shapefile de ruta...")
    todos_shp = glob.glob(os.path.join(base, "02_BASES_VECTORES", "rutas_provinciales", "**", "*.shp"), recursive=True)
    
    rutas_encontradas = [shp for shp in todos_shp if any(ruta in shp for ruta in ['6', '20', '24', '30', '40', '41', '42', '43', '44', '46', '47', '48', '51', '61', '91'])]
    
    for ruta in rutas_encontradas:
        print(f"📍 POSIBLE RUTA: {ruta}")
    
    if rutas_encontradas:
        return "mixto", rutas_encontradas
    
    print("❌ No se encontraron shapefiles de rutas")
    return "no_encontrado", []

# Ejecutar verificación
tipo, rutas = verificar_estructura_rutas()
print(f"\n📋 RESUMEN: Tipo = {tipo}, Cantidad = {len(rutas) if isinstance(rutas, list) else 1}")