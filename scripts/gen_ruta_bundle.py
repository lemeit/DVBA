#!/usr/bin/env python3
"""
gen_ruta_bundle.py — DVBA Zona VI Saladillo
Genera datos/rutas_rpXX.js y test_rpXX.html desde dos GeoJSON.

USO:
    python gen_ruta_bundle.py <traza.geojson> <mojones.geojson> [opciones]

OPCIONES:
    --ruta XX          Número de ruta (ej: 91, 51, 40)
    --color #rrggbb    Color hex para el mapa (defecto: #6ab0cc)
    --paso N           Intervalo mojones sintéticos en km (defecto: 5)
    --ini-lng LNG      Longitud del punto de inicio zona VI
    --ini-lat LAT      Latitud del punto de inicio zona VI
    --fin-lng LNG      Longitud del punto de fin zona VI
    --fin-lat LAT      Latitud del punto de fin zona VI
    --out-dir DIR      Carpeta de salida (defecto: . )
    --salida-nombre    Nombre base para los archivos de salida

EJEMPLO:
    python gen_ruta_bundle.py rp91_unificada.geojson mojones_rp91.geojson \\
        --ruta 91 --color #4aaa8a \\
        --ini-lng -59.123 --ini-lat -35.456 \\
        --fin-lng -60.789 --fin-lat -35.900

NOTAS:
    - El GeoJSON de traza debe ser una sola feature LineString o MultiLineString.
    - Los mojones deben tener campo Name="0KM","50KM",... y description=sentido.
    - Si no se especifican ini/fin, usa el inicio y fin de la traza completa.
    - Si la traza va de oeste a este en el GeoJSON, el script la invierte
      automáticamente para orientarla en sentido de progresiva creciente.
"""

import json, math, sys, argparse, os
from pathlib import Path

# ── Haversine ────────────────────────────────────────────────────────────────
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
            return [round(pts[i-1][0] + frac*(pts[i][0]-pts[i-1][0]), 7),
                    round(pts[i-1][1] + frac*(pts[i][1]-pts[i-1][1]), 7)]
    return pts[-1]

# ── Cargar traza ─────────────────────────────────────────────────────────────
def load_chain(geojson_path):
    with open(geojson_path, encoding='utf-8') as f:
        gj = json.load(f)
    feats = gj['features']
    if len(feats) == 1:
        geom = feats[0]['geometry']
        if geom['type'] == 'LineString':
            return geom['coordinates']
        elif geom['type'] == 'MultiLineString':
            # Aplanar en orden
            pts = []
            for seg in geom['coordinates']:
                for pt in seg:
                    if not pts or pt != pts[-1]:
                        pts.append(pt)
            return pts
    # Múltiples features: unir en orden geográfico simple (por longitud)
    all_pts = []
    feats_sorted = sorted(feats, key=lambda f: f['geometry']['coordinates'][0][0]
                         if f['geometry']['type']=='LineString'
                         else f['geometry']['coordinates'][0][0][0],
                         reverse=True)  # este → oeste
    for feat in feats_sorted:
        geom = feat['geometry']
        if geom['type'] == 'LineString':
            seg = geom['coordinates']
        else:
            seg = [pt for s in geom['coordinates'] for pt in s]
        for pt in seg:
            if not all_pts or pt != all_pts[-1]:
                all_pts.append(pt)
    return all_pts

# ── Cargar mojones ────────────────────────────────────────────────────────────
def load_mojones(geojson_path, ruta_num):
    with open(geojson_path, encoding='utf-8') as f:
        gj = json.load(f)
    mojs = {}
    for feat in gj['features']:
        props = feat['properties']
        coords = feat['geometry']['coordinates'][:2]
        name = props.get('Name', props.get('name', '')).upper().replace('KM','').strip()
        desc = props.get('description', props.get('Description', ''))
        try:
            km = float(name)
            mojs[km] = {'lng': round(coords[0],7), 'lat': round(coords[1],7), 'sentido': desc}
        except:
            pass
    return mojs

# ── Detectar gaps ─────────────────────────────────────────────────────────────
def detect_gaps(sub, acum, threshold_km=2.0):
    gaps = []
    for i in range(1, len(sub)):
        d = hav(sub[i-1], sub[i])
        if d > threshold_km:
            gaps.append({
                'id': f'gap_{len(gaps)+1}',
                'label': f'Gap {len(gaps)+1}',
                'acc_desde': round(acum[i-1], 4),
                'acc_hasta': round(acum[i], 4),
                'dist_recta_km': round(d, 3),
                'tipo': 'digitalizado'
            })
    return gaps

# ── Generar mojones sintéticos ────────────────────────────────────────────────
def gen_mojones_sint(sub, acum, mojones_fisicos, paso_km, prog_ini):
    total_km = acum[-1]
    km_start = math.ceil(prog_ini / paso_km) * paso_km
    km_end = prog_ini + total_km

    result = []
    km = km_start
    while km <= km_end + 0.01:
        acc = km - prog_ini
        if acc < 0 or acc > total_km + 0.01:
            km = round(km + paso_km, 4)
            continue
        acc = min(acc, total_km)
        pt = interp_point(sub, acum, acc)
        en_gap = any(g['acc_desde']-0.05 <= acc <= g['acc_hasta']+0.05
                     for g in detect_gaps(sub, acum))
        result.append({
            'ruta': str(int(float(str(paso_km)))),  # placeholder, se reemplaza abajo
            'km': km, 'km_label': f'km {int(km)}',
            'acc_local': round(acc, 4),
            'lng': pt[0], 'lat': pt[1],
            'sintetico': True, 'en_gap': en_gap, 'gap_id': ''
        })
        km = round(km + paso_km, 4)
    return result

# ── MAIN ──────────────────────────────────────────────────────────────────────
def main():
    p = argparse.ArgumentParser(description='Genera bundle JS para una ruta DVBA')
    p.add_argument('traza',   help='GeoJSON de la traza unificada con gaps')
    p.add_argument('mojones', help='GeoJSON de mojones ajustados')
    p.add_argument('--ruta',  required=True, help='Número de ruta (ej: 91)')
    p.add_argument('--color', default='#6ab0cc', help='Color hex para mapa')
    p.add_argument('--paso',  type=float, default=5.0, help='Paso mojones sintéticos (km)')
    p.add_argument('--ini-lng', type=float, default=None)
    p.add_argument('--ini-lat', type=float, default=None)
    p.add_argument('--fin-lng', type=float, default=None)
    p.add_argument('--fin-lat', type=float, default=None)
    p.add_argument('--out-dir', default='.', help='Carpeta de salida')
    args = p.parse_args()

    rn = args.ruta.zfill(2)
    print(f"\n=== Generando bundle RP{rn} ===")

    # Cargar
    pts_all = load_chain(args.traza)
    mojs_map = load_mojones(args.mojones, rn)
    print(f"Traza: {len(pts_all)} puntos totales")
    print(f"Mojones cargados: km {sorted(mojs_map.keys())}")

    # Extraer subtramo zona VI
    if args.ini_lng and args.ini_lat:
        idx_ini, d_ini = nearest_idx(pts_all, [args.ini_lng, args.ini_lat])
        print(f"Inicio zona VI: idx={idx_ini}, dist={d_ini:.3f}km")
    else:
        idx_ini = 0
        print("Sin ini especificado — usando inicio de la traza")

    if args.fin_lng and args.fin_lat:
        idx_fin, d_fin = nearest_idx(pts_all, [args.fin_lng, args.fin_lat])
        print(f"Fin zona VI: idx={idx_fin}, dist={d_fin:.3f}km")
    else:
        idx_fin = len(pts_all) - 1
        print("Sin fin especificado — usando fin de la traza")

    # Orientar: el índice de inicio debe ser menor si la traza va este→oeste
    if idx_ini > idx_fin:
        sub = list(reversed(pts_all[idx_fin:idx_ini+1]))
    else:
        sub = pts_all[idx_ini:idx_fin+1]

    # Verificar orientación (debe ir de este a oeste = lng decreciente)
    if sub[0][0] < sub[-1][0]:
        sub = list(reversed(sub))
        print("Traza invertida para orientación este→oeste")

    sub = [[round(p[0],7), round(p[1],7)] for p in sub]

    # Calcular acumulado
    acum = [0.0]
    for i in range(len(sub)-1):
        acum.append(acum[-1] + hav(sub[i], sub[i+1]))
    total_km = acum[-1]
    print(f"Subtramo: {len(sub)} pts, {total_km:.3f} km")

    # Detectar gaps
    gaps = detect_gaps(sub, acum)
    print(f"Gaps >2km detectados: {len(gaps)}")
    for g in gaps:
        print(f"  {g['id']}: acum {g['acc_desde']}→{g['acc_hasta']} ({g['dist_recta_km']}km)")

    # Calcular anchors
    anchors = []
    prog_ini = 0.0
    km0_moj = mojs_map.get(0.0)
    if km0_moj:
        # Estimar prog_ini como distancia desde el km0 al inicio de cadena
        # Verificar si el mojón km0 está fuera de la cadena
        _, d0 = nearest_idx(sub, [km0_moj['lng'], km0_moj['lat']])
        if d0 > 1.0:  # mojón 0 fuera del subtramo → estimar offset
            # Usar el primer mojón no-cero para calibrar
            km_refs = sorted(k for k in mojs_map if k > 0)
            if km_refs:
                km_ref = km_refs[0]
                m = mojs_map[km_ref]
                best_i, _ = nearest_idx(sub, [m['lng'], m['lat']])
                acc_ref = acum[best_i]
                prog_ini = km_ref - acc_ref
                print(f"Mojón km0 fuera del subtramo → prog_ini estimado: {prog_ini:.3f} km")

    for km_val in sorted(mojs_map.keys()):
        if km_val == 0 and prog_ini > 1:
            continue
        m = mojs_map[km_val]
        best_i, best_d = nearest_idx(sub, [m['lng'], m['lat']])
        anchors.append({'km': km_val, 'acc': round(acum[best_i], 4)})
        print(f"  Anchor km{km_val}: acc={acum[best_i]:.4f} km, dist_moj={best_d:.4f} km")
    # Agregar fin de zona
    anchors.append({'km': round(prog_ini + total_km, 1), 'acc': round(total_km, 4)})

    # Mojones físicos como lista
    mojones_fis = []
    for km_val, m in sorted(mojs_map.items()):
        mojones_fis.append({
            'ruta': args.ruta, 'km': km_val, 'km_label': f'km {int(km_val)}',
            'lng': m['lng'], 'lat': m['lat'],
            'sintetico': False, 'en_gap': False, 'gap_id': '', 'sentido': m['sentido']
        })

    # Mojones sintéticos
    mojones_sint = gen_mojones_sint(sub, acum, mojs_map, args.paso, prog_ini)
    for m in mojones_sint:
        m['ruta'] = args.ruta
    print(f"Mojones sintéticos: {len(mojones_sint)} (cada {args.paso} km)")

    todos_moj = sorted(mojones_fis + mojones_sint, key=lambda m: m['km'])

    # ── Serializar ──────────────────────────────────────────────────────────
    ruta_upper = f"RP{rn.lstrip('0') or rn}"
    var = f"RP{rn.lstrip('0') or rn}"  # e.g. RP91

    sub_j      = json.dumps(sub, separators=(',',':'))
    anchors_j  = json.dumps(anchors, separators=(',',':'))
    moj_fis_j  = json.dumps(mojones_fis, separators=(',',':'), ensure_ascii=False)
    todos_j    = json.dumps(todos_moj, separators=(',',':'), ensure_ascii=False)
    gaps_j     = json.dumps(gaps, separators=(',',':'), ensure_ascii=False)

    partidos_guess = ['(partidos pendientes de completar)']

    js_bundle = f"""// ================================================================
// datos/rutas_rp{rn.lstrip('0')}.js  —  RP{rn.lstrip('0')} DVBA Zona VI Saladillo
// Generado por: gen_ruta_bundle.py
// Fuente: GeoJSON suministrado por Luciano Lamaita / DVBA Zona VI
// Tramo: {len(sub)} pts · {total_km:.3f} km · {len(gaps)} gaps
// ================================================================

const CHAIN_{var}={sub_j};
const ANCHORS_{var}={anchors_j};
const MOJONES_{var}={moj_fis_j};
const MOJONES_{var}_TODOS={todos_j};
const GAPS_{var}={gaps_j};
const META_{var}={{
  ruta:'{args.ruta}',label:'RP {rn.lstrip('0')}',color:'{args.color}',weight:5,
  clase:'Mixto',progIni:{round(prog_ini,2)},progFin:{round(prog_ini+total_km,1)},
  longGis:{round(total_km,3)},
  mojonesF:{len(mojones_fis)},mojonesS:{len(mojones_sint)},gaps:{len(gaps)}
}};
"""

    # ── HTML de test ─────────────────────────────────────────────────────────
    center_lat = (sub[0][1] + sub[-1][1]) / 2
    center_lng = (sub[0][0] + sub[-1][0]) / 2

    html_test = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Test RP{rn.lstrip('0')} — Zona VI DVBA</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{font-family:Arial,sans-serif;background:#1a2a3a;color:#eee}}
#hdr{{background:#003366;padding:8px 14px;display:flex;align-items:center;gap:12px;flex-wrap:wrap}}
#hdr h1{{font-size:.92rem;color:#fff;white-space:nowrap}}
#stats{{font-size:.73rem;color:#adf;margin-left:auto}}
#map{{width:100%;height:calc(100vh - 40px)}}
.ctrl{{position:absolute;z-index:1000;background:rgba(255,255,255,.95);
       padding:10px;border-radius:6px;font-size:.75rem;color:#333;
       box-shadow:0 2px 8px rgba(0,0,0,.3)}}
#pnl-capa{{top:52px;right:10px}}
#pnl-capa label{{display:block;margin:3px 0;cursor:pointer}}
#pnl-capa hr{{margin:5px 0}}
#pnl-prog{{bottom:20px;left:10px;min-width:190px;
           background:rgba(0,51,102,.93);color:#fff;display:none}}
#pnl-ley{{bottom:20px;right:10px}}
#pnl-ley h4{{color:#003366;margin-bottom:5px}}
.dot{{display:inline-block;width:9px;height:9px;border-radius:50%;margin-right:4px;vertical-align:middle}}
.mjl{{background:transparent;border:none;font-size:.68rem;font-weight:bold;
      white-space:nowrap;text-shadow:1px 1px 2px #fff,-1px -1px 2px #fff}}
</style>
</head>
<body>
<div id="hdr">
  <h1>🗺 RP{rn.lstrip('0')} — Test integración | DVBA Zona VI</h1>
  <div id="stats">cargando...</div>
</div>
<div id="map"></div>
<div class="ctrl" id="pnl-capa">
  <b>Capas</b>
  <label><input type="checkbox" id="c-traza" checked> Traza oficial</label>
  <label><input type="checkbox" id="c-gaps"  checked> Gaps</label>
  <label><input type="checkbox" id="c-mf"    checked> Mojones físicos</label>
  <label><input type="checkbox" id="c-ms"    checked> Mojones sintéticos</label>
  <hr>
  Paso: <select id="sel-paso" style="font-size:.75rem;width:100%;margin-top:3px">
    <option value="5" selected>5 km</option>
    <option value="10">10 km</option>
    <option value="1">1 km</option>
  </select>
</div>
<div class="ctrl" id="pnl-ley">
  <h4>Referencias</h4>
  <div><span class="dot" style="background:{args.color}"></span>Traza RP{rn.lstrip('0')}</div>
  <div><span class="dot" style="background:#e05050;border-radius:0;width:18px;height:3px"></span>Gap</div>
  <div><span class="dot" style="background:#003366;border:2px solid #fff"></span>Mojón físico</div>
  <div><span class="dot" style="background:#888"></span>Mojón sintético</div>
</div>
<div class="ctrl" id="pnl-prog"><span id="prog-txt"></span></div>

<script src="datos/rutas_rp{rn.lstrip('0')}.js"></script>
<script src="datos/rutas.js"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
function hav(a,b){{
  const R=6371,dL=(b[1]-a[1])*Math.PI/180,dl=(b[0]-a[0])*Math.PI/180;
  const x=Math.sin(dL/2)**2+Math.cos(a[1]*Math.PI/180)*Math.cos(b[1]*Math.PI/180)*Math.sin(dl/2)**2;
  return R*2*Math.atan2(Math.sqrt(x),Math.sqrt(1-x));
}}
const CHAIN=CHAIN_{var}, ANCHORS=ANCHORS_{var}, GAPS=GAPS_{var}||[];
const META=META_{var}, MOJ_F=MOJONES_{var}, MOJ_T=MOJONES_{var}_TODOS;

const map=L.map('map').setView([{center_lat:.4f},{center_lng:.4f}],9);
L.tileLayer('https://{{s}}.tile.openstreetmap.org/{{z}}/{{x}}/{{y}}.png',
  {{attribution:'© OpenStreetMap',maxZoom:18}}).addTo(map);

const ACUM=[0];
for(let i=1;i<CHAIN.length;i++) ACUM.push(ACUM[i-1]+hav(CHAIN[i-1],CHAIN[i]));

function calcProg(acc){{
  if(!ANCHORS||!ANCHORS.length) return META.progIni+acc;
  if(acc<=ANCHORS[0].acc) return META.progIni+acc*(ANCHORS[0].km-META.progIni)/ANCHORS[0].acc;
  for(let i=0;i<ANCHORS.length-1;i++){{
    const a=ANCHORS[i],b=ANCHORS[i+1];
    if(acc>=a.acc&&acc<=b.acc) return a.km+(acc-a.acc)/(b.acc-a.acc)*(b.km-a.km);
  }}
  return META.progIni+acc;
}}
function getGap(acc){{return GAPS.find(g=>acc>=g.acc_desde-0.05&&acc<=g.acc_hasta+0.05)||null;}}

const segsN=[],segsG=[];
let seg=[CHAIN[0]],esG=false;
for(let i=1;i<CHAIN.length;i++){{
  const d=hav(CHAIN[i-1],CHAIN[i]),g=getGap(ACUM[i]),nuevo=d>2.0||!!g;
  if(nuevo!==esG){{(esG?segsG:segsN).push([...seg]);seg=[CHAIN[i-1]];esG=nuevo;}}
  seg.push(CHAIN[i]);
}}
(esG?segsG:segsN).push(seg);

const lyT=L.layerGroup(),lyG=L.layerGroup(),lyMF=L.layerGroup(),lyMS=L.layerGroup();
segsN.forEach(s=>L.polyline(s.map(p=>[p[1],p[0]]),{{color:'{args.color}',weight:5,opacity:.9}}).addTo(lyT));
segsG.forEach(s=>L.polyline(s.map(p=>[p[1],p[0]]),{{color:'#e05050',weight:3,dashArray:'10,6'}}).addTo(lyG));

function buildMF(){{
  lyMF.clearLayers();
  MOJ_F.filter(m=>m.km>0).forEach(m=>{{
    L.circleMarker([m.lat,m.lng],{{radius:8,fillColor:'#003366',color:'#fff',weight:2,fillOpacity:1}})
     .bindPopup(`<b>km ${{m.km}}</b><br>${{m.sentido||''}}<br><i>Mojón físico — datos internos DVBA</i>`)
     .addTo(lyMF);
    L.marker([m.lat,m.lng],{{icon:L.divIcon({{className:'mjl',html:`km ${{m.km}}`,iconAnchor:[-5,-3]}})}}).addTo(lyMF);
  }});
}}
function buildMS(paso){{
  lyMS.clearLayers();
  MOJ_T.filter(m=>m.sintetico&&m.km%paso===0).forEach(m=>{{
    const c=m.en_gap?'#e05050':'#888';
    L.circleMarker([m.lat,m.lng],{{radius:4,fillColor:c,color:'#fff',weight:1,fillOpacity:.85}})
     .bindPopup(`<b>km ${{m.km}}</b> (sint.)${{m.en_gap?'<br>⚠ en gap':''}}`)
     .addTo(lyMS);
    if(m.km%20===0) L.marker([m.lat,m.lng],{{icon:L.divIcon({{className:'mjl',
      html:`<span style="color:${{m.en_gap?'#c00':'#555'}}">${{m.km}}</span>`,
      iconAnchor:[-4,-3]}})}}).addTo(lyMS);
  }});
}}
buildMF(); buildMS(5);
[lyT,lyG,lyMF,lyMS].forEach(l=>l.addTo(map));

[['c-traza',lyT],['c-gaps',lyG],['c-mf',lyMF],['c-ms',lyMS]]
  .forEach(([id,l])=>document.getElementById(id).onchange=e=>e.target.checked?l.addTo(map):l.remove());
document.getElementById('sel-paso').onchange=e=>{{buildMS(+e.target.value);
  if(document.getElementById('c-ms').checked)lyMS.addTo(map);}};

map.on('click',e=>{{
  let bi=0,bd=1e9;
  CHAIN.forEach((p,i)=>{{const d=Math.sqrt((p[0]-e.latlng.lng)**2+(p[1]-e.latlng.lat)**2);if(d<bd){{bd=d;bi=i;}}}});
  const prog=calcProg(ACUM[bi]),g=getGap(ACUM[bi]);
  const box=document.getElementById('pnl-prog');box.style.display='block';
  document.getElementById('prog-txt').innerHTML=
    `<b>RP {rn.lstrip('0')}</b><br>Progresiva: <b>km ${{prog.toFixed(2)}}</b><br>Acum. local: ${{ACUM[bi].toFixed(3)}} km`+
    (g?`<br><span style="color:#f99">⚠ ${{g.label}}</span>`:'');
}});
map.fitBounds(L.latLngBounds(CHAIN.map(p=>[p[1],p[0]])).pad(.05));
document.getElementById('stats').textContent=
  `${{CHAIN.length}} pts | ${{META.longGis}} km | ${{META.mojonesF}} físicos + ${{META.mojonesS}} sint. | ${{GAPS.length}} gaps`;
</script>
</body>
</html>"""

    # ── Guardar ──────────────────────────────────────────────────────────────
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    datos_dir = out / 'datos'
    datos_dir.mkdir(exist_ok=True)

    js_path   = datos_dir / f"rutas_rp{rn.lstrip('0')}.js"
    html_path = out / f"test_rp{rn.lstrip('0')}.html"

    with open(js_path, 'w', encoding='utf-8') as f:
        f.write(js_bundle)
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html_test)

    print(f"\n✓ {js_path}  ({js_path.stat().st_size//1024} KB)")
    print(f"✓ {html_path}  ({html_path.stat().st_size//1024} KB)")
    print(f"\nPara probar: abrir {html_path} con la carpeta datos/ al lado.")
    print("Recordar agregar en datos/rutas.js:")
    print(f"  if (typeof CHAIN_{var} !== 'undefined') CHAINS_DATA['{args.ruta}'] = CHAIN_{var};")
    print(f"  if (typeof ANCHORS_{var} !== 'undefined') ANCHORS_DATA['{args.ruta}'] = ANCHORS_{var};")

if __name__ == '__main__':
    main()
