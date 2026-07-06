#!/usr/bin/env python3
"""
gen_ruta_bundle.py v2.10 - DVBA Zona VI Saladillo
Genera datos/rutas_rpXX.js desde dos GeoJSON (traza + mojones).

v2.10 (2026-07-06): si --ini-lng/lat o --fin-lng/lat NO coinciden con un
      vertex existente (dist > 5m), el punto se INSERTA en la cadena
      entre los dos vertices adyacentes. Asi la traza recortada llega
      exactamente al limite del partido en vez de al vertex interior
      mas cercano. Complementa recortar_zonavi.py v1.1 que ahora emite
      el punto exacto de cruce con el borde.

v2.9 (2026-07-06): descartar anchors cuyo snap cae dentro de un tramo
      GAP fisico (es_gap=1). El acc calculado en un gap es espurio porque
      la distancia recta del gap no representa la progresiva oficial de
      la ruta. Sin este filtro, un mojon en gap arrastra una interpolacion
      distorsionada que se ve como "rectas" en el mapa (bug RP61 v7.39).
      Los mojones descartados siguen en moj_fis con en_gap=True.

v2.7: agregar anchor inicial {km: prog_ini, acc: 0} para que el portal
      interpole correctamente la zona inicial (antes del primer mojon
      fisico). Sin esto, el portal extrapola desde el primer mojon y da
      progresivas incorrectas en la entrada Zona VI.

USO:
    python scripts/gen_ruta_bundle.py <traza.geojson> <mojones.geojson> --ruta XX [opciones]

OPCIONES:
    --ruta XX            Numero de ruta - REQUERIDO
    --color #rrggbb      Color hex para el mapa (defecto: #6ab0cc)
    --paso N             Intervalo mojones sinteticos en km (defecto: 5)
    --gap-threshold N    Umbral km para gaps automaticos (defecto: 15)
    --prog-ini N         Progresiva real del inicio (calcula desde mojones si no)
    --ini-lng/lat        Coords del inicio zona VI (para subtramos)
    --fin-lng/lat        Coords del fin zona VI (para subtramos)
    --out-dir DIR        Carpeta salida (defecto: . - guarda en datos/rutas_rpXX.js)
    --order-by MODE      Estrategia de orden (defecto: fid)
                           fid       -> orden estricto por columna 'fid' ascendente
                           mojones   -> orden por mojones como guia geografica
                           proximity -> orden por proximidad de extremos (legacy)

CAMPO fid (modo por defecto):
    Si el GeoJSON tiene 'fid' (o 'FID'), el script ordena los tramos por fid
    ascendente. La traza nace en fid=1 y crece hacia fids mayores. NO se
    invierten segmentos.

CAMPO es_gap:
    es_gap=1 -> tramo gap fisico (rojo en mapa). Su distancia SI suma al acumulado.
    es_gap=0 -> tramo normal continuo
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


def feat_to_segment(feat, default_fid=0):
    """Extrae geometria + es_gap + fid de una feature: (pts, es_gap, fid)."""
    geom = feat['geometry']
    props = feat.get('properties', {}) or {}

    es_gap_raw = props.get('es_gap', props.get('gap', 0))
    try:
        es_gap = int(float(str(es_gap_raw))) if es_gap_raw not in (None, '', 'NULL', 'null') else 0
    except Exception:
        es_gap = 0

    fid_raw = props.get('fid', props.get('FID', props.get('id', default_fid)))
    try:
        fid = int(float(str(fid_raw))) if fid_raw not in (None, '', 'NULL', 'null') else default_fid
    except Exception:
        fid = default_fid

    if geom['type'] == 'LineString':
        coords = geom['coordinates']
    else:
        coords = [p for s in geom['coordinates'] for p in s]
    pts = [[round(p[0], 7), round(p[1], 7)] for p in coords]
    return pts, es_gap, fid


def order_by_fid(segments_with_fid):
    """Ordena por fid ascendente. NO invierte ni reordena puntos internos."""
    sorted_segs = sorted(segments_with_fid, key=lambda s: s[2])
    ordered = [(pts, eg) for pts, eg, _ in sorted_segs]
    diag = [{'fid': fid, 'es_gap': eg, 'n_pts': len(pts)} for pts, eg, fid in sorted_segs]
    return ordered, diag


def auto_order_segments(segments, mojones=None):
    """Modo legacy: por mojones o proximidad (no se usa en --order-by fid)."""
    if len(segments) <= 1:
        return list(segments), []

    if mojones and len(mojones) >= 2:
        mojones_ord = sorted(mojones, key=lambda m: m['km'])

        def km_mojon_cercano(pt):
            best_km, best_d = mojones_ord[0]['km'], float('inf')
            for m in mojones_ord:
                d = hav(pt, [m['lng'], m['lat']])
                if d < best_d:
                    best_d, best_km = d, m['km']
            return best_km, best_d

        anotados = []
        for pts, eg in segments:
            km_ini, d_ini = km_mojon_cercano(pts[0])
            km_fin, d_fin = km_mojon_cercano(pts[-1])
            if km_fin < km_ini:
                pts = list(reversed(pts))
                km_ini, km_fin = km_fin, km_ini
                d_ini, d_fin = d_fin, d_ini
                invertido = True
            else:
                invertido = False
            anotados.append({
                'pts': pts, 'eg': eg,
                'km_repr': km_ini, 'km_fin': km_fin,
                'd_ini': d_ini, 'invertido': invertido,
            })
        anotados.sort(key=lambda a: (a['km_repr'], a['km_fin']))
        ordered = [(a['pts'], a['eg']) for a in anotados]
        diag = [{
            'km_inicio': a['km_repr'], 'km_fin': a['km_fin'],
            'invertido': a['invertido'], 'es_gap': a['eg'],
            'dist_a_mojon': round(a['d_ini'], 3),
        } for a in anotados]
        return ordered, diag

    remaining = list(segments)
    ordered = [remaining.pop(0)]
    saltos = []
    while remaining:
        chain_start = ordered[0][0][0]
        chain_end = ordered[-1][0][-1]
        best_idx, best_dist, best_op = None, float('inf'), None
        for i, (pts, eg) in enumerate(remaining):
            d1 = hav(chain_end, pts[0])
            d2 = hav(chain_end, pts[-1])
            d3 = hav(chain_start, pts[-1])
            d4 = hav(chain_start, pts[0])
            for d, op in [(d1, 'append'), (d2, 'append_inv'), (d3, 'prepend'), (d4, 'prepend_inv')]:
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
            saltos.append({'distancia_km': round(best_dist, 3), 'op': best_op})
    return ordered, saltos


def load_chain(path, mojones=None, order_mode='fid'):
    gj = json.loads(Path(path).read_text(encoding='utf-8'))
    feats = gj['features']

    raw_with_fid = []
    for i, f in enumerate(feats):
        pts, eg, fid = feat_to_segment(f, default_fid=i)
        if pts and len(pts) >= 2:
            raw_with_fid.append((pts, eg, fid))

    fids_leidos = sorted([s[2] for s in raw_with_fid])
    print('  [INPUT] ' + str(len(raw_with_fid)) + ' features. fids: ' + str(fids_leidos))

    if len(raw_with_fid) <= 1:
        segments = [(p, e) for p, e, _ in raw_with_fid]
    elif order_mode == 'fid':
        segments, diag = order_by_fid(raw_with_fid)
        print('  [ORDEN: FID asc] ' + str(len(segments)) + ' tramos:')
        for d in diag:
            eg = ' [es_gap=1]' if d['es_gap'] else ''
            print('    fid=' + str(d['fid']).rjust(3) + '  pts=' + str(d['n_pts']).rjust(4) + eg)
    else:
        raw_no_fid = [(p, e) for p, e, _ in raw_with_fid]
        segments, diag = auto_order_segments(
            raw_no_fid, mojones=mojones if order_mode == 'mojones' else None
        )
        if order_mode == 'mojones' and mojones and len(mojones) >= 2:
            print('  [ORDEN: MOJONES] ' + str(len(segments)) + ' features ordenadas')
        else:
            print('  [ORDEN: PROXIMIDAD] ' + str(len(segments)) + ' features.')

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
    p.add_argument('--order-by', default='fid', choices=['fid', 'mojones', 'proximity'],
                   dest='order_by',
                   help='Estrategia de orden de features (defecto: fid)')
    p.add_argument('--clase', default='Mixto',
                   help='Clase de calzada para META (Pavimentado / Mixto / De tierra / etc.)')
    args = p.parse_args()

    rn = args.ruta.lstrip('0') or args.ruta
    var = 'RP' + rn
    print('\n=== Generando bundle RP' + rn + ' ===')
    print('Modo de orden: ' + args.order_by)

    mojones_pre = load_mojones(args.mojones)
    pts_all, gap_ranges_field = load_chain(args.traza, mojones=mojones_pre, order_mode=args.order_by)
    print('Traza: ' + str(len(pts_all)) + ' puntos totales')
    has_gap_field = len(gap_ranges_field) > 0

    # v2.10 (2026-07-06) - Si --ini-lng/lat NO coinciden con un vertex existente
    # (dist > 5 metros), INSERTAR el punto en la cadena entre los dos vertices
    # adyacentes. Esto permite que la traza recortada llegue EXACTAMENTE al
    # limite del partido (recortar_zonavi.py v1.1 devuelve el cruce exacto).
    def _insertar_o_matchear(pts, target_lng, target_lat, gap_ranges):
        idx, d_km = nearest_idx(pts, [target_lng, target_lat])
        if d_km * 1000 < 5.0:  # menos de 5m -> matchea al vertex
            return idx, pts, gap_ranges
        # Buscar el segmento donde cae el punto (aproximacion: proyeccion escalar)
        best_i, best_dperp = 0, 1e18
        for i in range(len(pts) - 1):
            ax, ay = pts[i]
            bx, by = pts[i+1]
            dx, dy = bx - ax, by - ay
            L2 = dx*dx + dy*dy
            if L2 < 1e-14: continue
            t = ((target_lng - ax) * dx + (target_lat - ay) * dy) / L2
            t = max(0.0, min(1.0, t))
            px = ax + t*dx; py = ay + t*dy
            d = math.hypot(target_lng - px, target_lat - py)
            if d < best_dperp:
                best_dperp, best_i = d, i
        # Insertar entre best_i y best_i+1
        new_pts = pts[:best_i+1] + [[target_lng, target_lat]] + pts[best_i+1:]
        # Actualizar gap_ranges (indices >= best_i+1 shiftean +1)
        new_gaps = []
        for a, b in gap_ranges:
            na = a if a <= best_i else a + 1
            nb = b if b <= best_i else b + 1
            new_gaps.append((na, nb))
        return best_i + 1, new_pts, new_gaps

    if args.ini_lng and args.ini_lat:
        idx_ini, pts_all, gap_ranges_field = _insertar_o_matchear(
            pts_all, args.ini_lng, args.ini_lat, gap_ranges_field)
        print('Inicio zona VI: idx=' + str(idx_ini) + ' (vertex insertado o matcheado en borde)')
    else:
        idx_ini = 0
    if args.fin_lng and args.fin_lat:
        idx_fin, pts_all, gap_ranges_field = _insertar_o_matchear(
            pts_all, args.fin_lng, args.fin_lat, gap_ranges_field)
        print('Fin zona VI: idx=' + str(idx_fin) + ' (vertex insertado o matcheado en borde)')
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

    if args.order_by != 'fid' and len(sub) > 1 and sub[0][0] < sub[-1][0]:
        sub = list(reversed(sub))
        n = len(sub) - 1
        gap_ranges_sub = [(n-b, n-a) for a, b in gap_ranges_sub]
        print('Traza invertida (modo legacy)')

    sub = [[round(pt[0], 7), round(pt[1], 7)] for pt in sub]

    acum = [0.0]
    for i in range(len(sub)-1):
        acum.append(acum[-1] + hav(sub[i], sub[i+1]))
    total_km = acum[-1]
    print('Subtramo: ' + str(len(sub)) + ' pts, ' + str(round(total_km, 3)) + ' km (incluye gaps)')

    gaps_real = gaps_from_field(sub, acum, gap_ranges_sub) if (has_gap_field and gap_ranges_sub) else []
    gaps_auto = detect_gaps_auto(sub, acum, args.gap_threshold)

    if gaps_real:
        print('Gaps reales (es_gap=1): ' + str(len(gaps_real)))
        for g in gaps_real:
            print('  ' + g['id'] + ': acc ' + str(g['acc_desde']) + ' -> ' + str(g['acc_hasta']) + ' km')
    else:
        print('Gaps reales: 0')

    if gaps_auto:
        print('Gaps auto (umbral ' + str(args.gap_threshold) + 'km): ' + str(len(gaps_auto)))
        for g in gaps_auto:
            print('  ' + g['id'] + ': acc ' + str(g['acc_desde']) + ' -> ' + str(g['acc_hasta']) + ' km (' + str(g['dist_recta_km']) + 'km recta)')
    else:
        print('Sin saltos auto-detectados')

    gaps = gaps_real
    mojs = mojones_pre
    print('Mojones cargados: ' + str([m['km'] for m in mojs]))

    anchors, moj_fis = [], []
    prog_ini = args.prog_ini

    # v2.8 — Chequear si un indice del snap cae DENTRO de un tramo gap fisico.
    # Si es asi, el acc calculado va a ser espurio (el gap suma distancia recta
    # que NO corresponde a la progresiva oficial de la ruta). Descartar esos
    # mojones como anchors para no distorsionar la interpolacion.
    def _snap_en_gap(idx, gap_ranges):
        for a, b in gap_ranges:
            if a <= idx <= b:
                return True
        return False

    valid_mojs = []
    descartados_gap = []
    for m in mojs:
        bi, bd = nearest_idx(sub, [m['lng'], m['lat']])
        if bd >= 2.0:
            continue  # muy lejos de la traza, ignorar
        if _snap_en_gap(bi, gap_ranges_sub or []):
            descartados_gap.append((m, bi, bd))
            continue
        valid_mojs.append((m, bi, bd))

    if descartados_gap:
        print('  ! Anchors descartados por caer en tramo GAP:')
        for m, bi, bd in descartados_gap:
            print('      mojon km' + str(m['km']) + ' snap idx=' + str(bi)
                  + ' acc=' + str(round(acum[bi], 4)) + ' dist=' + str(round(bd, 4)) + 'km')

    # Mojones descartados por gap siguen siendo mojones fisicos (para el mapa),
    # solo no se usan como anchor. Los agregamos a moj_fis con en_gap=True.
    for m, bi, bd in descartados_gap:
        moj_fis.append({
            'ruta': rn, 'km': m['km'], 'km_label': 'km ' + str(int(m['km'])),
            'lng': m['lng'], 'lat': m['lat'],
            'sintetico': False, 'en_gap': True, 'gap_id': '',
            'sentido': m['sentido'], 'tipo': m['tipo'],
            'fuente': m['fuente'], 'resp': m['resp'], 'fecha': m['fecha'],
        })

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
        print('  ! Sin mojones validos')
        prog_ini = prog_ini or 0.0
    prog_ini = prog_ini or 0.0

    # Si hay mojon km=0 anclado al inicio de la traza (acc cercano a 0), forzar prog_ini=0.
    # Esto evita que los anchors posteriores a gaps (cuya distancia recta != progresiva oficial)
    # arrastren un desfasaje promedio que no representa nada real.
    moj0_inicio = next(((m, bi, bd) for m, bi, bd in valid_mojs
                        if abs(m['km']) < 0.01 and acum[bi] < 0.5), None)
    if moj0_inicio is not None and args.prog_ini is None:
        prog_ini = 0.0
        print('prog_ini forzado a 0 (mojon km=0 anclado al inicio de la traza)')
    elif len(valid_mojs) > 1 and args.prog_ini is None:
        estimaciones = [round(m['km'] - acum[bi], 2) for m, bi, bd in valid_mojs]
        prog_ini = round(sum(estimaciones) / len(estimaciones), 2)
        print('prog_ini refinado (promedio ' + str(len(estimaciones)) + ' mojones): km' + str(prog_ini))
    print('prog_ini: km' + str(prog_ini))

    anchors.sort(key=lambda a: a['km'])
    # v2.7 — Agregar anchor inicial {km: prog_ini, acc: 0} si no existe.
    # Esto permite al portal interpolar correctamente entre el inicio de la
    # cadena (entrada Zona VI = km prog_ini) y el primer mojon fisico.
    # Sin esto, el portal extrapola hacia atras desde el primer mojon
    # (ej km 50) y da progresivas incorrectas en la zona inicial.
    if not anchors or anchors[0]['acc'] > 0.01:
        anchors.insert(0, {'km': round(prog_ini, 2), 'acc': 0.0})
    anchors.append({'km': round(prog_ini + total_km, 1), 'acc': round(total_km, 4)})
    moj_fis.sort(key=lambda m: m['km'])

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

    sub_j = json.dumps(sub, separators=(',', ':'))
    anch_j = json.dumps(anchors, separators=(',', ':'))
    mf_j = json.dumps(moj_fis, separators=(',', ':'), ensure_ascii=False)
    tod_j = json.dumps(todos_moj, separators=(',', ':'), ensure_ascii=False)
    gaps_real_j = json.dumps(gaps_real, separators=(',', ':'), ensure_ascii=False)
    gaps_auto_j = json.dumps(gaps_auto, separators=(',', ':'), ensure_ascii=False)
    prog_fin = round(prog_ini + total_km, 1)

    n_sub = len(sub)
    tk_r = round(total_km, 3)
    n_real = len(gaps_real)
    n_auto = len(gaps_auto)
    n_mf = len(moj_fis)
    n_ms = len(moj_sint)

    js_lines = []
    js_lines = []
    js_lines.append('// =================================================================')
    js_lines.append('// datos/rutas_rp' + rn + '.js  -  RP' + rn + ' DVBA Zona VI')
    js_lines.append('// Generado por gen_ruta_bundle.py v2.10 (orden=' + args.order_by + ')')
    js_lines.append('// ' + str(n_sub) + ' pts | ' + str(tk_r) + ' km | progIni:'
                    + str(prog_ini) + ' | progFin:' + str(prog_fin))
    js_lines.append('// Gaps reales (es_gap=1): ' + str(n_real) + ' [GAPS_RP' + rn + ']')
    js_lines.append('// Gaps auto-detectados:   ' + str(n_auto) + ' [GAPS_AUTO_RP' + rn + ']')
    js_lines.append('// =================================================================')
    js_lines.append('')
    js_lines.append('const CHAIN_RP' + rn + '=' + sub_j + ';')
    js_lines.append('const ANCHORS_RP' + rn + '=' + anch_j + ';')
    js_lines.append('const MOJONES_RP' + rn + '=' + mf_j + ';')
    js_lines.append('const MOJONES_RP' + rn + '_TODOS=' + tod_j + ';')
    js_lines.append('// GAPS_RPxx: solo gaps reales (es_gap=1 en QGIS)')
    js_lines.append('const GAPS_RP' + rn + '=' + gaps_real_j + ';')
    js_lines.append('// GAPS_AUTO_RPxx: saltos auto-detectados, solo informativo')
    js_lines.append('const GAPS_AUTO_RP' + rn + '=' + gaps_auto_j + ';')
    js_lines.append('const META_RP' + rn + '={')
    js_lines.append("  ruta:'" + rn + "',label:'RP " + rn + "',color:'"
                    + args.color + "',weight:5,")
    js_lines.append("  clase:'" + args.clase + "',progIni:" + str(prog_ini)
                    + ',progFin:' + str(prog_fin) + ',')
    js_lines.append('  longGis:' + str(tk_r) + ',')
    js_lines.append('  mojonesF:' + str(n_mf) + ',mojonesS:' + str(n_ms) + ',')
    js_lines.append('  gapsReales:' + str(n_real) + ',gapsAuto:' + str(n_auto))
    js_lines.append('};')

    out_dir = Path(args.out_dir)
    (out_dir / 'datos').mkdir(parents=True, exist_ok=True)
    out_path = out_dir / 'datos' / ('rutas_rp' + rn + '.js')
    out_path.write_text('\n'.join(js_lines) + '\n', encoding='utf-8')
    size_kb = out_path.stat().st_size // 1024
    print('')
    print('OK: ' + str(out_path) + ' (' + str(size_kb) + ' KB)')


if __name__ == '__main__':
    main()
