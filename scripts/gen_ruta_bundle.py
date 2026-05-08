#!/usr/bin/env python3
"""
gen_ruta_bundle.py v2.1 - DVBA Zona VI Saladillo
Genera datos/rutas_rpXX.js desde dos GeoJSON (traza + mojones).

USO:
    python scripts/gen_ruta_bundle.py <traza.geojson> <mojones.geojson> --ruta XX [opciones]

OPCIONES:
    --ruta XX           Numero de ruta - REQUERIDO
    --color #rrggbb     Color hex para el mapa (defecto: #6ab0cc)
    --paso N            Intervalo mojones sinteticos en km (defecto: 5)
    --gap-threshold N   Umbral km para gaps automaticos (defecto: 15)
    --prog-ini N        Progresiva real del inicio (calcula desde mojones si no)
    --ini-lng/lat       Coords del inicio zona VI (para subtramos)
    --fin-lng/lat       Coords del fin zona VI (para subtramos)
    --out-dir DIR       Carpeta salida (defecto: . - guarda en datos/rutas_rpXX.js)

CAMPO es_gap EN EL GEOJSON (recomendado):
    Si el GeoJSON tiene un campo 'es_gap' a nivel feature, el script lo usa.
    es_gap=1 -> gap fisico (rojo en mapa)
    es_gap=0 -> tramo normal continuo

PARA CREAR EL TEST HTML (no lo hace el script):
    cp tests/test_rp40.html tests/test_rpXX.html
    sed -i "s|RP40|RPXX|g; s|rp40|rpXX|g" tests/test_rpXX.html
"""
import json
import math
import sys
import argparse
from pathlib import Path


def hav(a, b):
    R = 6371
    dlat = math.radians(b[1] - a[1])
    dlng = math.radians(b[0] - a[0])
    x = math.sin(dlat/2)**2 + math.cos(math.radians(a[1])) * math.cos(math.radians(b[1])) * math.sin(dlng/2)**2
    return R * 2 * math.atan2(math.sqrt(x), math.sqrt(1-x))


def nearest_idx(pts, target):
    best_i, best_d = 0, 1e9
    for i, pt in enumerate(pts):
        d = math.sqrt((pt[0]-target[0])**2 + (pt[1]-target[1])**2) * 111
        if d < best_d:
            best_d = d
            best_i = i
    return best_i, best_d


def interp_point(pts, acum, target_acc):
    for i in range(1, len(pts)):
        if acum[i] >= target_acc:
            seg_len = acum[i] - acum[i-1]
            if seg_len < 1e-10:
                return pts[i]
            frac = (target_acc - acum[i-1]) / seg_len
            return [
                round(pts[i-1][0] + frac * (pts[i][0]-pts[i-1][0]), 7),
                round(pts[i-1][1] + frac * (pts[i][1]-pts[i-1][1]), 7),
            ]
    return pts[-1]


def feat_to_segment(feat):
    """Extrae geometria + es_gap de una feature: (puntos, es_gap)."""
    geom = feat['geometry']
    props = feat.get('properties', {}) or {}
    es_gap_raw = props.get('es_gap', props.get('gap', 0))
    try:
        es_gap = int(float(str(es_gap_raw))) if es_gap_raw not in (None, '', 'NULL', 'null') else 0
    except Exception:
        es_gap = 0
    if geom['type'] == 'LineString':
        coords = geom['coordinates']
    else:  # MultiLineString -> aplanar
        coords = [p for s in geom['coordinates'] for p in s]
    pts = [[round(p[0], 7), round(p[1], 7)] for p in coords]
    return pts, es_gap


def auto_order_segments(segments):
    """Reordena segmentos por proximidad de extremos para evitar saltos rectos.

    Estrategia bidireccional:
      - Empieza con el primer segmento como semilla.
      - En cada iteracion busca el mejor candidato considerando los CUATRO casos:
          1) candidato.inicio cerca del fin de la cadena → append directo
          2) candidato.fin    cerca del fin de la cadena → append invertido
          3) candidato.fin    cerca del inicio de la cadena → prepend directo
          4) candidato.inicio cerca del inicio de la cadena → prepend invertido
      - Esto permite construir la cadena en ambas direcciones desde la semilla,
        evitando dejar segmentos "huérfanos" al final si su lugar natural era el inicio.

    Retorna (lista_ordenada, lista_saltos_detectados).
    """
    if len(segments) <= 1:
        return list(segments), []

    remaining = list(segments)
    ordered = [remaining.pop(0)]
    saltos = []

    while remaining:
        chain_start = ordered[0][0][0]
        chain_end = ordered[-1][0][-1]
        best_idx, best_dist = None, float('inf')
        best_op = None  # 'append' / 'append_inv' / 'prepend' / 'prepend_inv'
        for i, (pts, eg) in enumerate(remaining):
            d1 = hav(chain_end, pts[0])     # append directo (fin->ini)
            d2 = hav(chain_end, pts[-1])    # append invertido (fin->fin)
            d3 = hav(chain_start, pts[-1])  # prepend directo (ini<-fin)
            d4 = hav(chain_start, pts[0])   # prepend invertido (ini<-ini)
            for d, op in [(d1, 'append'), (d2, 'append_inv'),
                          (d3, 'prepend'), (d4, 'prepend_inv')]:
                if d < best_dist:
                    best_dist, best_idx, best_op = d, i, op
        chosen_pts, chosen_eg = remaining.pop(best_idx)
        if best_op == 'append':
            ordered.append((chosen_pts, chosen_eg))
        elif best_op == 'append_inv':
            ordered.append((list(reversed(chosen_pts)), chosen_eg))
        elif best_op == 'prepend':
            ordered.insert(0, (chosen_pts, chosen_eg))
        elif best_op == 'prepend_inv':
            ordered.insert(0, (list(reversed(chosen_pts)), chosen_eg))
        if best_dist > 1.0:
            saltos.append({
                'distancia_km': round(best_dist, 3),
                'op': best_op,
            })
    return ordered, saltos


def load_chain(path):
    """Carga la traza concatenando features con auto-ordenamiento por proximidad."""
    gj = json.loads(Path(path).read_text(encoding='utf-8'))
    feats = gj['features']

    raw_segments = [feat_to_segment(f) for f in feats]

    # Auto-ordenar por proximidad si hay multiples features
    if len(raw_segments) > 1:
        segments, saltos = auto_order_segments(raw_segments)
        if saltos:
            print('  [AUTO-ORDEN] Reordenadas ' + str(len(segments)) + ' features. Saltos detectados:')
            for s in saltos:
                print('    -> salto de ' + str(s['distancia_km']) + ' km (op=' + s['op'] + ')')
            big = [s for s in saltos if s['distancia_km'] > 5.0]
            if big:
                print('  [!] Hay saltos > 5km — verificar continuidad real en QGIS,')
                print('      o estos saltos seran gaps reales (marcalos con es_gap=1)')
        else:
            print('  [AUTO-ORDEN] ' + str(len(segments)) + ' features ordenadas, sin saltos significativos')
    else:
        segments = raw_segments

    all_pts = []
    gap_ranges = []
    idx = 0
    for pts_feat, es_gap in segments:
        if all_pts and pts_feat and pts_feat[0] == all_pts[-1]:
            pts_feat = pts_feat[1:]
        if es_gap and pts_feat:
            gap_ranges.append((idx, idx + len(pts_feat) - 1))
        all_pts.extend(pts_feat)
        idx += len(pts_feat)
    return all_pts, gap_ranges


def detect_gaps_auto(pts, acum, threshold):
    gaps = []
    for i in range(1, len(pts)):
        d = hav(pts[i-1], pts[i])
        if d > threshold:
            gaps.append({
                'id': 'gap_' + str(len(gaps)+1),
                'label': 'Gap ' + str(len(gaps)+1),
                'acc_desde': round(acum[i-1], 4),
                'acc_hasta': round(acum[i], 4),
                'dist_recta_km': round(d, 3),
                'tipo': 'auto_detectado',
            })
    return gaps


def gaps_from_field(pts, acum, gap_ranges):
    gaps = []
    for idx_d, idx_h in gap_ranges:
        idx_d = max(0, min(idx_d, len(acum)-1))
        idx_h = max(0, min(idx_h, len(acum)-1))
        gaps.append({
            'id': 'gap_' + str(len(gaps)+1),
            'label': 'Gap ' + str(len(gaps)+1),
            'acc_desde': round(acum[idx_d], 4),
            'acc_hasta': round(acum[idx_h], 4),
            'dist_recta_km': round(hav(pts[idx_d], pts[min(idx_h, len(pts)-1)]), 3),
            'tipo': 'es_gap_field',
        })
    return gaps


def load_mojones(path):
    gj = json.loads(Path(path).read_text(encoding='utf-8'))
    mojs = []
    for feat in gj['features']:
        props = feat['properties'] or {}
        coords = feat['geometry']['coordinates'][:2]
        name = (props.get('Name') or props.get('name') or '').upper().replace('KM', '').strip()
        km_val = props.get('km_value')
        if km_val is None:
            try:
                km_val = float(name)
            except Exception:
                km_val = 0.0
        mojs.append({
            'km': float(km_val),
            'lng': round(coords[0], 7),
            'lat': round(coords[1], 7),
            'sentido': props.get('sentido_prog', props.get('description', '')) or '',
            'tipo': props.get('tipo_mojon', 'Cincuentakilometrico'),
            'fuente': props.get('meta_fuent', 'Base Oficial DVBA'),
            'resp': props.get('meta_resp', 'Ing. Luciano Lamaita'),
            'fecha': props.get('meta_fecha', '2026-05-08'),
        })
    mojs.sort(key=lambda m: m['km'])
    return mojs


def main():
    p = argparse.ArgumentParser(description='Genera bundle JS para una ruta DVBA')
    p.add_argument('traza')
    p.add_argument('mojones')
    p.add_argument('--ruta', required=True)
    p.add_argument('--color', default='#6ab0cc')
    p.add_argument('--paso', type=float, default=5.0)
    p.add_argument('--gap-threshold', type=float, default=15.0, dest='gap_threshold')
    p.add_argument('--prog-ini', type=float, default=None, dest='prog_ini')
    p.add_argument('--ini-lng', type=float, default=None, dest='ini_lng')
    p.add_argument('--ini-lat', type=float, default=None, dest='ini_lat')
    p.add_argument('--fin-lng', type=float, default=None, dest='fin_lng')
    p.add_argument('--fin-lat', type=float, default=None, dest='fin_lat')
    p.add_argument('--out-dir', default='.')
    args = p.parse_args()

    rn = args.ruta.lstrip('0') or args.ruta
    var = 'RP' + rn
    print('\n=== Generando bundle RP' + rn + ' ===')

    pts_all, gap_ranges_field = load_chain(args.traza)
    print('Traza: ' + str(len(pts_all)) + ' puntos totales')
    has_gap_field = len(gap_ranges_field) > 0

    # Subtramo si se dieron coords ini/fin
    if args.ini_lng and args.ini_lat:
        idx_ini, d_ini = nearest_idx(pts_all, [args.ini_lng, args.ini_lat])
        print('Inicio zona VI: idx=' + str(idx_ini) + ', dist=' + str(round(d_ini, 3)) + 'km')
    else:
        idx_ini = 0
    if args.fin_lng and args.fin_lat:
        idx_fin, d_fin = nearest_idx(pts_all, [args.fin_lng, args.fin_lat])
        print('Fin zona VI: idx=' + str(idx_fin) + ', dist=' + str(round(d_fin, 3)) + 'km')
    else:
        idx_fin = len(pts_all) - 1

    if idx_ini > idx_fin:
        sub = list(reversed(pts_all[idx_fin:idx_ini+1]))
        n = idx_ini - idx_fin
        gap_ranges_sub = [(n-(b-idx_fin), n-(a-idx_fin)) for a, b in gap_ranges_field
                          if idx_fin <= a <= idx_ini]
    else:
        sub = pts_all[idx_ini:idx_fin+1]
        gap_ranges_sub = [(a-idx_ini, b-idx_ini) for a, b in gap_ranges_field
                          if idx_ini <= a <= idx_fin]

    # Orientar de menor a mayor longitud (E->O en Argentina)
    if sub[0][0] < sub[-1][0]:
        sub = list(reversed(sub))
        n = len(sub) - 1
        gap_ranges_sub = [(n-b, n-a) for a, b in gap_ranges_sub]
        print('Traza invertida para orientacion correcta')

    sub = [[round(pt[0], 7), round(pt[1], 7)] for pt in sub]

    # Acumulado
    acum = [0.0]
    for i in range(len(sub)-1):
        acum.append(acum[-1] + hav(sub[i], sub[i+1]))
    total_km = acum[-1]
    print('Subtramo: ' + str(len(sub)) + ' pts, ' + str(round(total_km, 3)) + ' km')

    # Gaps
    if has_gap_field and gap_ranges_sub:
        gaps = gaps_from_field(sub, acum, gap_ranges_sub)
        print('Gaps desde campo es_gap: ' + str(len(gaps)))
    else:
        gaps = detect_gaps_auto(sub, acum, args.gap_threshold)
        if gaps:
            print('Gaps detectados (umbral ' + str(args.gap_threshold) + 'km): ' + str(len(gaps)))
            for g in gaps:
                print('  ' + g['id'] + ': ' + str(g['acc_desde']) + ' -> ' + str(g['acc_hasta']) + ' (' + str(g['dist_recta_km']) + 'km)')
        else:
            print('Sin gaps (umbral ' + str(args.gap_threshold) + 'km) OK')

    # Mojones y anchors
    mojs = load_mojones(args.mojones)
    print('Mojones cargados: ' + str([m['km'] for m in mojs]))

    anchors, moj_fis = [], []
    prog_ini = args.prog_ini

    valid_mojs = []
    for m in mojs:
        bi, bd = nearest_idx(sub, [m['lng'], m['lat']])
        if bd < 2.0:
            valid_mojs.append((m, bi, bd))

    for m, bi, bd in valid_mojs:
        anchors.append({'km': m['km'], 'acc': round(acum[bi], 4)})
        moj_fis.append({
            'ruta': rn, 'km': m['km'], 'km_label': 'km ' + str(int(m['km'])),
            'lng': m['lng'], 'lat': m['lat'],
            'sintetico': False, 'en_gap': False, 'gap_id': '',
            'sentido': m['sentido'], 'tipo': m['tipo'],
            'fuente': m['fuente'], 'resp': m['resp'], 'fecha': m['fecha'],
        })
        print('  Anchor km' + str(m['km']) + ': acc=' + str(round(acum[bi], 4)) + ' dist=' + str(round(bd, 4)) + 'km OK')
        if prog_ini is None:
            prog_ini = round(m['km'] - acum[bi], 2)

    if not valid_mojs:
        print('  ! Sin mojones validos dentro de la cadena')
        prog_ini = prog_ini or 0.0

    prog_ini = prog_ini or 0.0

    if len(valid_mojs) > 1:
        estimaciones = [round(m['km'] - acum[bi], 2) for m, bi, bd in valid_mojs]
        prog_ini = round(sum(estimaciones) / len(estimaciones), 2)
        print('prog_ini refinado (promedio ' + str(len(estimaciones)) + ' mojones): km' + str(prog_ini))
    print('prog_ini: km' + str(prog_ini))

    anchors.sort(key=lambda a: a['km'])
    anchors.append({'km': round(prog_ini + total_km, 1), 'acc': round(total_km, 4)})
    moj_fis.sort(key=lambda m: m['km'])

    # Mojones sinteticos
    paso = args.paso
    km_start = math.ceil(prog_ini / paso) * paso if prog_ini > 0 else 0.0
    moj_sint = []
    km = km_start
    while km <= prog_ini + total_km + 0.01:
        acc = km - prog_ini
        if acc < 0 or acc > total_km + 0.01:
            km = round(km + paso, 4)
            continue
        acc = min(acc, total_km)
        pt = interp_point(sub, acum, acc)
        en_gap = any(g['acc_desde']-0.05 <= acc <= g['acc_hasta']+0.05 for g in gaps)
        moj_sint.append({
            'ruta': rn, 'km': km, 'km_label': 'km ' + str(int(km)),
            'acc_local': round(acc, 4), 'lng': pt[0], 'lat': pt[1],
            'sintetico': True, 'en_gap': en_gap, 'gap_id': '',
        })
        km = round(km + paso, 4)
    print('Mojones sinteticos: ' + str(len(moj_sint)) + ' (cada ' + str(paso) + ' km)')

    todos_moj = sorted(moj_fis + moj_sint, key=lambda m: m['km'])

    # Serializar
    sub_j = json.dumps(sub, separators=(',', ':'))
    anch_j = json.dumps(anchors, separators=(',', ':'))
    mf_j = json.dumps(moj_fis, separators=(',', ':'), ensure_ascii=False)
    tod_j = json.dumps(todos_moj, separators=(',', ':'), ensure_ascii=False)
    gaps_j = json.dumps(gaps, separators=(',', ':'), ensure_ascii=False)
    prog_fin = round(prog_ini + total_km, 1)

    gap_comment = 'desde campo es_gap' if has_gap_field else 'umbral ' + str(args.gap_threshold) + 'km'
    gap_method = 'es_gap_field' if has_gap_field else 'auto_threshold'

    js = (
        '// =================================================================\n'
        '// datos/rutas_rp' + rn + '.js  -  RP' + rn + ' DVBA Zona VI\n'
        '// Generado por gen_ruta_bundle.py v2.3 (auto-orden bidireccional)\n'
        '// ' + str(len(sub)) + ' pts | ' + str(round(total_km, 3)) + ' km | progIni:' + str(prog_ini) + ' | progFin:' + str(prog_fin) + '\n'
        '// Gaps: ' + str(len(gaps)) + ' | ' + gap_comment + '\n'
        '// =================================================================\n\n'
        'const CHAIN_' + var + '=' + sub_j + ';\n'
        'const ANCHORS_' + var + '=' + anch_j + ';\n'
        'const MOJONES_' + var + '=' + mf_j + ';\n'
        'const MOJONES_' + var + '_TODOS=' + tod_j + ';\n'
        'const GAPS_' + var + '=' + gaps_j + ';\n'
        'const META_' + var + '={\n'
        "  ruta:'" + rn + "',label:'RP " + rn + "',color:'" + args.color + "',weight:5,\n"
        "  clase:'Mixto',progIni:" + str(prog_ini) + ',progFin:' + str(prog_fin) + ',\n'
        '  longGis:' + str(round(total_km, 3)) + ',\n'
        '  mojonesF:' + str(len(moj_fis)) + ',mojonesS:' + str(len(moj_sint)) + ',gaps:' + str(len(gaps)) + ',\n'
        "  gapMethod:'" + gap_method + "'\n"
        '};\n'
    )

    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    datos_dir = out / 'datos'
    datos_dir.mkdir(exist_ok=True)
    js_path = datos_dir / ('rutas_rp' + rn + '.js')
    js_path.write_text(js, encoding='utf-8')

    print('\nOK: ' + str(js_path) + ' (' + str(js_path.stat().st_size // 1024) + ' KB)')
    print('\nPara generar test HTML, copiar plantilla:')
    print('  cp tests/test_rp40.html tests/test_rp' + rn + '.html')
    print('  sed -i "s|RP40|RP' + rn + '|g; s|rp40|rp' + rn + '|g" tests/test_rp' + rn + '.html')


if __name__ == '__main__':
    main()
