# -*- coding: utf-8 -*-
"""
Created on Fri Oct 17 15:29:19 2025

@author: Luciano
"""

import os
import geopandas as gpd
import pandas as pd

base_path = r"G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales"

print("=== GENERANDO TODAS LAS RUTAS - ZONA VI DVBA ===")

# Leer shapefile original
archivo_shp = os.path.join(base_path, "02_BASES_VECTORES", "red_vial_pba", "shp", "red-vial-pba.shp")
gdf = gpd.read_file(archivo_shp)

print(f"📊 Total de features en shapefile: {len(gdf)}")

# RUTAS DE LA ZONA VI (según tu CSV original)
RUTAS_ZONA_VI = [
    'RP 6', 'RP 20', 'RP 30', 'RP 40', 'RP 41', 'RP 42', 'RP 43', 'RP 44', 
    'RP 46', 'RP 47', 'RP 48', 'RP 51', 'RP 61', 'RP 91'
]

print(f"🎯 Rutas a procesar: {len(RUTAS_ZONA_VI)}")
print(f"📋 Lista: {RUTAS_ZONA_VI}")

# Mapeo de nombres de ruta a valores en el shapefile
# Basado en lo que aprendimos con RP 51 (columna 'rtn' contiene números)
mapeo_rutas = {
    'RP 6': '6',
    'RP 20': '20', 
    'RP 30': '30',
    'RP 40': '40',
    'RP 41': '41',
    'RP 42': '42',
    'RP 43': '43',
    'RP 44': '44',
    'RP 46': '46',
    'RP 47': '47',
    'RP 48': '48',
    'RP 51': '51',
    'RP 61': '61',
    'RP 91': '91'
}

# Crear directorio de salida
salida_dir = os.path.join(base_path, "03_CAPAS_GENERADAS", "ZONA_VI")
os.makedirs(salida_dir, exist_ok=True)

# Procesar cada ruta
resultados = []

for ruta_nombre in RUTAS_ZONA_VI:
    print(f"\n🛣️  PROCESANDO: {ruta_nombre}")
    
    # Buscar en el shapefile
    valor_rtn = mapeo_rutas[ruta_nombre]
    segmentos_ruta = gdf[gdf['rtn'].astype(str) == valor_rtn].copy()
    
    print(f"   📊 Segmentos encontrados: {len(segmentos_ruta)}")
    
    if len(segmentos_ruta) > 0:
        # Convertir a UTM para cálculos
        segmentos_utm = segmentos_ruta.to_crs('EPSG:32721')
        segmentos_utm['longitud_segmento'] = segmentos_utm.length
        
        # Calcular longitud total
        longitud_total = segmentos_utm['longitud_segmento'].sum()
        longitud_km = longitud_total / 1000
        
        print(f"   📏 Longitud total: {longitud_km:.2f} km")
        print(f"   🏙️  Municipios: {len(segmentos_ruta['municipio_'].unique())}")
        
        # Guardar segmentos originales
        archivo_segmentos = os.path.join(salida_dir, f"{ruta_nombre.replace(' ', '_')}_SEGMENTOS.geojson")
        segmentos_ruta.to_file(archivo_segmentos, driver='GeoJSON')
        
        # Crear versión unida (sin telarañas - solo segmentos organizados)
        # Ordenar por latitud para mejor visualización
        def latitud_promedio(geometry):
            coords = list(geometry.coords)
            if coords:
                latitudes = [coord[1] for coord in coords]
                return sum(latitudes) / len(latitudes)
            return 0
        
        segmentos_ruta['latitud_promedio'] = segmentos_ruta.geometry.apply(latitud_promedio)
        segmentos_ordenados = segmentos_ruta.sort_values('latitud_promedio', ascending=False)
        
        # Guardar versión ordenada
        archivo_ordenado = os.path.join(salida_dir, f"{ruta_nombre.replace(' ', '_')}_ORDENADA.geojson")
        segmentos_ordenados.to_file(archivo_ordenado, driver='GeoJSON')
        
        resultados.append({
            'Ruta': ruta_nombre,
            'Segmentos': len(segmentos_ruta),
            'Longitud_km': round(longitud_km, 2),
            'Municipios': len(segmentos_ruta['municipio_'].unique()),
            'Archivo_Segmentos': f"{ruta_nombre.replace(' ', '_')}_SEGMENTOS.geojson",
            'Archivo_Ordenado': f"{ruta_nombre.replace(' ', '_')}_ORDENADA.geojson"
        })
        
        print(f"   💾 Guardado: {ruta_nombre.replace(' ', '_')}_ORDENADA.geojson")
        
    else:
        print(f"   ❌ No se encontraron segmentos para {ruta_nombre}")
        resultados.append({
            'Ruta': ruta_nombre,
            'Segmentos': 0,
            'Longitud_km': 0,
            'Municipios': 0,
            'Archivo_Segmentos': 'NO_ENCONTRADO',
            'Archivo_Ordenado': 'NO_ENCONTRADO'
        })

# Generar reporte
print(f"\n📊 REPORTE FINAL - ZONA VI")
print("=" * 60)

df_resultados = pd.DataFrame(resultados)
print(df_resultados.to_string(index=False))

# Guardar reporte como CSV
archivo_reporte = os.path.join(salida_dir, "REPORTE_RUTAS_ZONA_VI.csv")
df_resultados.to_csv(archivo_reporte, index=False, encoding='utf-8')
print(f"\n💾 Reporte guardado: REPORTE_RUTAS_ZONA_VI.csv")

# Generar archivo de proyecto QGIS (QML) para estilos básicos
print(f"\n🎨 Generando estilos básicos para QGIS...")

qml_content = """<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.0-Białowieża" simplifyDrawingTol="1" labelsEnabled="0" simplifyAlgorithm="0" maxScale="0" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" simplifyDrawingHints="1" minScale="100000000" readOnly="0" simplifyLocal="1" styleCategories="AllStyleCategories">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <renderer-v2 type="singleSymbol" forceraster="0" referencescale="-1" enableorderby="0" symbollevels="0">
    <symbols>
      <symbol type="line" name="0" clip_to_extent="1" alpha="1" force_rhr="0">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" name="name" value=""/>
            <Option name="properties"/>
            <Option type="QString" name="type" value="collection"/>
          </Option>
        </data_defined_properties>
        <layer class="SimpleLine" locked="0" enabled="1" pass="0">
          <Option type="Map">
            <Option type="QString" name="align_dash_pattern" value="0"/>
            <Option type="QString" name="capstyle" value="square"/>
            <Option type="QString" name="customdash" value="5;2"/>
            <Option type="QString" name="customdash_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="customdash_unit" value="MM"/>
            <Option type="QString" name="dash_pattern_offset" value="0"/>
            <Option type="QString" name="dash_pattern_offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="dash_pattern_offset_unit" value="MM"/>
            <Option type="QString" name="draw_inside_polygon" value="0"/>
            <Option type="QString" name="joinstyle" value="bevel"/>
            <Option type="QString" name="line_color" value="227,26,28,255"/>
            <Option type="QString" name="line_style" value="solid"/>
            <Option type="QString" name="line_width" value="0.66"/>
            <Option type="QString" name="line_width_unit" value="MM"/>
            <Option type="QString" name="offset" value="0"/>
            <Option type="QString" name="offset_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="offset_unit" value="MM"/>
            <Option type="QString" name="ring_filter" value="0"/>
            <Option type="QString" name="trim_distance_end" value="0"/>
            <Option type="QString" name="trim_distance_end_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_end_unit" value="MM"/>
            <Option type="QString" name="trim_distance_start" value="0"/>
            <Option type="QString" name="trim_distance_start_map_unit_scale" value="3x:0,0,0,0,0,0"/>
            <Option type="QString" name="trim_distance_start_unit" value="MM"/>
            <Option type="QString" name="tweak_dash_pattern_on_corners" value="0"/>
            <Option type="QString" name="use_custom_dash" value="0"/>
            <Option type="QString" name="width_map_unit_scale" value="3x:0,0,0,0,0,0"/>
          </Option>
          <prop v="0" k="align_dash_pattern"/>
          <prop v="square" k="capstyle"/>
          <prop v="5;2" k="customdash"/>
          <prop v="3x:0,0,0,0,0,0" k="customdash_map_unit_scale"/>
          <prop v="MM" k="customdash_unit"/>
          <prop v="0" k="dash_pattern_offset"/>
          <prop v="3x:0,0,0,0,0,0" k="dash_pattern_offset_map_unit_scale"/>
          <prop v="MM" k="dash_pattern_offset_unit"/>
          <prop v="0" k="draw_inside_polygon"/>
          <prop v="bevel" k="joinstyle"/>
          <prop v="227,26,28,255" k="line_color"/>
          <prop v="solid" k="line_style"/>
          <prop v="0.66" k="line_width"/>
          <prop v="MM" k="line_width_unit"/>
          <prop v="0" k="offset"/>
          <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
          <prop v="MM" k="offset_unit"/>
          <prop v="0" k="ring_filter"/>
          <prop v="0" k="trim_distance_end"/>
          <prop v="3x:0,0,0,0,0,0" k="trim_distance_end_map_unit_scale"/>
          <prop v="MM" k="trim_distance_end_unit"/>
          <prop v="0" k="trim_distance_start"/>
          <prop v="3x:0,0,0,0,0,0" k="trim_distance_start_map_unit_scale"/>
          <prop v="MM" k="trim_distance_start_unit"/>
          <prop v="0" k="tweak_dash_pattern_on_corners"/>
          <prop v="0" k="use_custom_dash"/>
          <prop v="3x:0,0,0,0,0,0" k="width_map_unit_scale"/>
          <data_defined_properties>
            <Option type="Map">
              <Option type="QString" name="name" value=""/>
              <Option name="properties"/>
              <Option type="QString" name="type" value="collection"/>
            </Option>
          </data_defined_properties>
        </layer>
      </symbol>
    </symbols>
    <rotation/>
    <sizescale/>
  </renderer-v2>
</qgis>"""

archivo_qml = os.path.join(salida_dir, "estilo_base.qml")
with open(archivo_qml, 'w', encoding='utf-8') as f:
    f.write(qml_content)

print(f"💾 Estilo QGIS: estilo_base.qml")

print(f"\n🎯 PROCESO COMPLETADO")
print(f"📍 Ubicación: {salida_dir}")
print(f"📁 Total rutas procesadas: {len([r for r in resultados if r['Segmentos'] > 0])}")
print(f"📊 Longitud total red vial: {df_resultados['Longitud_km'].sum():.0f} km")

print(f"\n🚀 INSTRUCCIONES QGIS:")
print(f"1. Abrir carpeta '03_CAPAS_GENERADAS/ZONA_VI/'")
print(f"2. Cargar archivos '*_ORDENADA.geojson'")
print(f"3. Aplicar estilo 'estilo_base.qml' si deseas")
print(f"4. ¡Tendrás toda la red vial de Zona VI!")