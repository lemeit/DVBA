"""
DVBA_Z6_ANALISIS_RAPIDO_CORREGIDO.py
===========================================================
ANÁLISIS RÁPIDO: Estado actual de rutas por partido - CORREGIDO
"""

import pandas as pd
import os
import glob

def analisis_rapido():
    """Análisis rápido de la base oficial con manejo de codificación"""
    csv_path = r"C:\Users\Of. Técnica Z6\OneDrive\Documentos\QGIS FIles\Proyecto_Redes_Viales\04_TABLAS\SALADILLO_RED.csv"
    
    # Intentar diferentes codificaciones
    codificaciones = ['latin-1', 'iso-8859-1', 'utf-8', 'cp1252']
    df = None
    
    for codificacion in codificaciones:
        try:
            df = pd.read_csv(csv_path, sep=';', encoding=codificacion)
            print(f"✅ Archivo cargado con codificación: {codificacion}")
            break
        except:
            continue
    
    if df is None:
        print("❌ No se pudo cargar el archivo con ninguna codificación")
        return
    
    # Diccionario de partidos
    PARTIDOS_ZONA_VI = {
        '034': 'General Alvear',
        '041': 'General Las Heras', 
        '058': 'Las Flores',
        '062': 'Lobos',
        '075': 'Navarro',
        '091': 'Roque Pérez',
        '093': 'Saladillo',
        '109': '25 de Mayo'
    }
    
    print("\n📊 ANÁLISIS RÁPIDO BASE OFICIAL")
    print("=" * 50)
    
    # Limpiar datos
    df['RUTA'] = df['RUTA'].astype(str).str.strip()
    df['PARTIDO'] = df['PARTIDO'].astype(str).str.strip().str.zfill(3)
    df['Longitud en metros'] = pd.to_numeric(df['Longitud en metros'], errors='coerce')
    
    # Rutas presentes
    rutas = sorted(df['RUTA'].unique())
    print(f"🛣️  Rutas en Zona VI: {rutas}")
    
    # Longitud total por ruta
    print("\n📏 Longitud por Ruta (km):")
    long_por_ruta = df.groupby('RUTA')['Longitud en metros'].sum() / 1000
    for ruta, longitud in long_por_ruta.items():
        print(f"  RP{ruta}: {longitud:.2f} km")
    
    # Longitud por partido
    print("\n🏛️  Longitud por Partido (km):")
    long_por_partido = df.groupby('PARTIDO')['Longitud en metros'].sum() / 1000
    for partido, longitud in long_por_partido.items():
        nombre_partido = PARTIDOS_ZONA_VI.get(partido, 'Desconocido')
        print(f"  {partido} - {nombre_partido}: {longitud:.2f} km")
    
    # Tipos de superficie
    print("\n🛣️  Tipos de Superficie:")
    superficie_counts = df['CLASE'].value_counts()
    for superficie, count in superficie_counts.items():
        longitud_total = df[df['CLASE'] == superficie]['Longitud en metros'].sum() / 1000
        print(f"  {superficie}: {count} tramos ({longitud_total:.2f} km)")
    
    # Total general
    total_km = df['Longitud en metros'].sum() / 1000
    print(f"\n🎯 LONGITUD TOTAL ZONA VI: {total_km:.2f} km")

if __name__ == "__main__":
    analisis_rapido()