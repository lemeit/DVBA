#!/usr/bin/env python3
"""
recortar_zonavi.py v1.1 - DVBA Zona VI Saladillo

Detecta los puntos de entrada y salida de una RP en Zona VI y calcula
--ini-lng/lat --fin-lng/lat --prog-ini para pasar a gen_ruta_bundle.py.

v1.1 (2026-07-06): calcular el punto EXACTO de cruce del segmento con el
      borde del poligono del partido, en lugar del vertex interior mas
      cercano. Asi la traza recortada llega exactamente a la linea de
      limite del partido en el mapa.
"""
import json
import math
import sys
import argparse
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from gen_ruta_bundle import load_chain, load_mojones, hav


def point_in_poly(point, poly):
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
    for nombre, mp in partidos.items():
        for poly in mp:
            if point_in_poly(pt, poly[0]):
                return nombre
    return None


def segment_polygon_crossing(a, b, partidos):
    """Cruce del segmento a->b con el borde de algun poligono Zona VI.
    Devuelve [lng, lat] o None si no cruza."""
    ax, ay = a
    bx, by = b
    dx, dy = bx - ax, by - ay
    mejor_t = None
    for nombre, mp in partidos.items():
        for poly in mp:
            ring = poly[0]
            n = len(ring)
            for i in range(n):
                cx, cy = ring[i]
                nx, ny = ring[(i+1) % n]
                dx2, dy2 = nx - cx, ny - cy
                denom = dx * dy2 - dy * dx2
                if abs(denom) < 1e-14:
                    continue
                t = ((cx - ax) * dy2 - (cy - ay) * dx2) / denom
                s = ((cx - ax) * dy  - (cy - ay) * dx ) / denom
                if 0.0 <= t <= 1.0 and 0.0 <= s <= 1.0:
                    if mejor_t is None or t < mejor_t:
                        mejor_t = t
    if mejor_t is None:
        return None
    return [round(ax + mejor_t * dx, 7), round(ay + mejor_t * dy, 7)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('traza')
    ap.add_argument('mojones')
    ap.add_argument('--ruta', required=True)
    ap.add_argument('--partidos', default='datos/partidos_zona_vi.geojson')
    ap.add_argument('--order-by', default='fid', choices=['fid', 'mojones', 'proximity'],
                    dest='order_by')
    ap.add_argument('--color', default='#6ab0cc')
    ap.add_argument('--clase', default='Mixto')
    ap.add_argument('--out-dir', default='.')
    args = ap.parse_args()

    print('\n=== Detectar entrada/salida Zona VI para RP{} ==='.format(args.ruta))
    partidos = cargar_partidos_zona_vi(args.partidos)
    print('Partidos cargados: {} - {}'.format(len(partidos), ', '.join(partidos.keys())))

    mojones_pre = load_mojones(args.mojones)
    pts_all, _ = load_chain(args.traza, mojones=mojones_pre, order_mode=args.order_by)
    print('Cadena ordenada: {} puntos'.format(len(pts_all)))

    acum = [0.0]
    for i in range(1, len(pts_all)):
        acum.append(acum[-1] + hav(pts_all[i-1], pts_all[i]))
    print('Longitud total cadena: {:.3f} km'.format(acum[-1]))

    first_idx = None; last_idx = None
    first_partido = None; last_partido = None
    partidos_atravesados = []
    for i, pt in enumerate(pts_all):
        p = en_zona_vi(pt, partidos)
        if p:
            if first_idx is None:
                first_idx = i; first_partido = p
            last_idx = i; last_partido = p
            if not partidos_atravesados or partidos_atravesados[-1] != p:
                partidos_atravesados.append(p)

    if first_idx is None:
        print('\nERROR: la cadena no pasa por ningun partido Zona VI')
        return 1

    partidos_unicos = []
    for p in partidos_atravesados:
        if p not in partidos_unicos:
            partidos_unicos.append(p)
    print('\nPartidos atravesados: {}'.format(' -> '.join(partidos_unicos)))

    # v1.1: Cruce exacto con el borde en entrada y salida
    if first_idx > 0:
        cross_ini = segment_polygon_crossing(pts_all[first_idx-1], pts_all[first_idx], partidos)
    else:
        cross_ini = None
    if cross_ini:
        d_cross = hav(pts_all[first_idx-1], cross_ini)
        acc_ini = acum[first_idx-1] + d_cross
        ini_lng, ini_lat = cross_ini
    else:
        acc_ini = acum[first_idx]
        ini_lng, ini_lat = pts_all[first_idx]
    print('\nEntrada Zona VI:')
    print('  idx interior={} partido={}'.format(first_idx, first_partido))
    print('  coord cruce=({}, {})'.format(ini_lng, ini_lat))
    print('  acc={:.3f} km <- prog_ini sugerido'.format(acc_ini))

    if last_idx < len(pts_all) - 1:
        cross_fin = segment_polygon_crossing(pts_all[last_idx], pts_all[last_idx+1], partidos)
    else:
        cross_fin = None
    if cross_fin:
        d_cross = hav(pts_all[last_idx], cross_fin)
        acc_fin = acum[last_idx] + d_cross
        fin_lng, fin_lat = cross_fin
    else:
        acc_fin = acum[last_idx]
        fin_lng, fin_lat = pts_all[last_idx]
    print('\nSalida Zona VI:')
    print('  idx interior={} partido={}'.format(last_idx, last_partido))
    print('  coord cruce=({}, {})'.format(fin_lng, fin_lat))
    print('  acc={:.3f} km'.format(acc_fin))

    print('\nLongitud Zona VI (borde a borde): {:.3f} km'.format(acc_fin - acc_ini))

    print('\n' + '=' * 60)
    print('COMANDO PARA REGENERAR BUNDLE:')
    print('=' * 60)
    print('python3 -B scripts/gen_ruta_bundle.py \\')
    print('  "{}" \\'.format(args.traza))
    print('  "{}" \\'.format(args.mojones))
    print('  --ruta {} --color "{}" --clase "{}" --order-by {} \\'.format(
        args.ruta, args.color, args.clase, args.order_by))
    print('  --ini-lng {} --ini-lat {} \\'.format(ini_lng, ini_lat))
    print('  --fin-lng {} --fin-lat {} \\'.format(fin_lng, fin_lat))
    print('  --prog-ini {:.2f} \\'.format(acc_ini))
    print('  --out-dir {}'.format(args.out_dir))
    return 0


if __name__ == '__main__':
    sys.exit(main() or 0)
