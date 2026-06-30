#!/usr/bin/env python3
"""
recortar_zonavi.py - DVBA Zona VI Saladillo

Detecta los puntos de entrada y salida de una RP en Zona VI,
y calcula los parametros --ini-lng/lat --fin-lng/lat --prog-ini
para pasar a gen_ruta_bundle.py.

USO:
  python scripts/recortar_zonavi.py <traza.geojson> <mojones.geojson> --ruta XX [--order-by mojones]

OUTPUT:
  Imprime el comando completo de gen_ruta_bundle.py listo para copiar/pegar.

REQUIERE:
  datos/partidos_zona_vi.geojson - poligonos de los 8 partidos Zona VI
"""
import json
import math
import sys
import argparse
from pathlib import Path

# Reusar logica de orden del generador principal
sys.path.insert(0, str(Path(__file__).parent))
from gen_ruta_bundle import load_chain, load_mojones, hav


def point_in_poly(point, poly):
    """Ray casting puro. poly: lista de [lng, lat] vertices del anillo exterior."""
    x, y = point
    n = len(poly)
    inside = False
    p1x, p1y = poly[0]
    for i in range(n + 1):
        p2x, p2y = poly[i % n]
        if y > min(p1y, p2y) and y <= max(p1y, p2y) and x <= max(p1x, p2x):
            if p1y != p2y:
                xinters = (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x
                if p1x == p2x or x <= xinters:
                    inside = not inside
        p1x, p1y = p2x, p2y
    return inside


def cargar_partidos_zona_vi(path_geojson):
    """Devuelve {nombre_partido: [multipoly_coords]}."""
    gj = json.loads(Path(path_geojson).read_text(encoding='utf-8'))
    out = {}
    for f in gj['features']:
        nombre = f['properties'].get('partido') or f['properties'].get('PARTIDO_NOMBRE') or '?'
        geom = f['geometry']
        if geom['type'] == 'MultiPolygon':
            out[nombre] = geom['coordinates']
        elif geom['type'] == 'Polygon':
            out[nombre] = [geom['coordinates']]
    return out


def en_zona_vi(pt, partidos):
    """Devuelve nombre_partido si pt esta en algun partido, sino None."""
    for nombre, mp in partidos.items():
        for poly in mp:
            if point_in_poly(pt, poly[0]):
                return nombre
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('traza')
    ap.add_argument('mojones')
    ap.add_argument('--ruta', required=True)
    ap.add_argument('--partidos', default='datos/partidos_zona_vi.geojson')
    ap.add_argument('--order-by', default='mojones', choices=['fid', 'mojones', 'proximity'],
                    dest='order_by')
    ap.add_argument('--color', default='#6ab0cc')
    ap.add_argument('--out-dir', default='.')
    args = ap.parse_args()

    print(f'\n=== Detectar entrada/salida Zona VI para RP{args.ruta} ===\n')

    # Cargar partidos
    partidos = cargar_partidos_zona_vi(args.partidos)
    print(f'Partidos cargados: {len(partidos)} - {", ".join(partidos.keys())}')

    # Cargar y ordenar la cadena (igual que hace gen_ruta_bundle.py)
    mojones_pre = load_mojones(args.mojones)
    pts_all, _ = load_chain(args.traza, mojones=mojones_pre, order_mode=args.order_by)
    print(f'Cadena ordenada: {len(pts_all)} puntos')

    # Acumulado por punto
    acum = [0.0]
    for i in range(1, len(pts_all)):
        acum.append(acum[-1] + hav(pts_all[i-1], pts_all[i]))
    total = acum[-1]
    print(f'Longitud total cadena: {total:.3f} km')

    # Encontrar primer y ultimo punto en Zona VI
    first_idx = None
    last_idx = None
    first_partido = None
    last_partido = None
    partidos_atravesados = []
    for i, pt in enumerate(pts_all):
        p = en_zona_vi(pt, partidos)
        if p:
            if first_idx is None:
                first_idx = i
                first_partido = p
            last_idx = i
            last_partido = p
            if not partidos_atravesados or partidos_atravesados[-1] != p:
                partidos_atravesados.append(p)

    if first_idx is None:
        print('\nERROR: la cadena no pasa por ningun partido de Zona VI')
        return 1

    # Quitar duplicados consecutivos
    partidos_unicos = []
    for p in partidos_atravesados:
        if p not in partidos_unicos:
            partidos_unicos.append(p)

    print(f'\nPartidos atravesados (en orden): {" -> ".join(partidos_unicos)}')
    print(f'\nEntrada Zona VI:')
    print(f'  idx={first_idx} | partido={first_partido}')
    print(f'  coord=({pts_all[first_idx][0]}, {pts_all[first_idx][1]})')
    print(f'  acc={acum[first_idx]:.3f} km <- prog_ini sugerido')

    print(f'\nSalida Zona VI:')
    print(f'  idx={last_idx} | partido={last_partido}')
    print(f'  coord=({pts_all[last_idx][0]}, {pts_all[last_idx][1]})')
    print(f'  acc={acum[last_idx]:.3f} km')

    dist_zonavi = acum[last_idx] - acum[first_idx]
    print(f'\nLongitud dentro Zona VI: {dist_zonavi:.3f} km')

    # Comando listo
    print('\n' + '=' * 60)
    print('COMANDO PARA REGENERAR BUNDLE:')
    print('=' * 60)
    print(f'python3 scripts/gen_ruta_bundle.py \\')
    print(f'  "{args.traza}" \\')
    print(f'  "{args.mojones}" \\')
    print(f'  --ruta {args.ruta} --color "{args.color}" --order-by {args.order_by} \\')
    print(f'  --ini-lng {pts_all[first_idx][0]} --ini-lat {pts_all[first_idx][1]} \\')
    print(f'  --fin-lng {pts_all[last_idx][0]} --fin-lat {pts_all[last_idx][1]} \\')
    print(f'  --prog-ini {acum[first_idx]:.2f} \\')
    print(f'  --out-dir {args.out_dir}')

    return 0


if __name__ == '__main__':
    sys.exit(main() or 0)
