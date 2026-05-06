import os
import geopandas as gpd

base_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales"

archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")

if os.path.exists(archivo_shp):
    print("Leyendo archivo shapefile...")
    gdf = gpd.read_file(archivo_shp)
    print("Columnas:", list(gdf.columns))
    print("Total features:", len(gdf))
    
    for col in gdf.columns:
        if gdf[col].dtype == 'object':
            if gdf[col].astype(str).str.contains('51', na=False).any():
                print("ENCONTRADO en columna:", col)
else:
    print("Archivo no encontrado")