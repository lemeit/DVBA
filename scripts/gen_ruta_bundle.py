#!/usr/bin/env python3
"""
gen_ruta_bundle.py v2 — DVBA Zona VI Saladillo
Genera datos/rutas_rpXX.js y test_rpXX.html desde dos GeoJSON.

USO:
    python gen_ruta_bundle.py <traza.geojson> <mojones.geojson> --ruta XX [opciones]

OPCIONES:
    --ruta XX           Número de ruta — REQUERIDO
    --color #rrggbb     Color hex para el mapa (defecto: #6ab0cc)
    --paso N            Intervalo mojones sintéticos en km (defecto: 5)
    --gap-threshold N   Umbral en km para detectar gaps automáticos (defecto: 15)
                        Solo aplica si el GeoJSON NO tiene campo es_gap.
                        Para rutas con pocos puntos en tramos rurales usar 15-20.
    --prog-ini N        Progresiva real del inicio de la cadena en km.
                        Si no se especifica, se calcula desde los mojones.
    --ini-lng/lat       Coordenadas del punto de inicio zona VI (para subtramos)
    --fin-lng/lat       Coordenadas del punto de fin zona VI (para subtramos)
    --out-dir DIR       Carpeta de salida (defecto: .)

CAMPO es_gap EN EL GEOJSON (recomendado):
    Si el GeoJSON tiene un campo 'es_gap' en los atributos, el script lo usa
    para identificar gaps reales en lugar del umbral automático.
    es_gap=1 (o true) → gap físico real (se pinta rojo en el mapa)
    es_gap=0 (o false) → tramo normal continuo

    Para agregar este campo en QGIS:
    1. Tabla de atributos → Calculadora de campos
    2. Nuevo campo: es_gap, tipo Entero, valor 0
    3. Seleccionar manualmente los segmentos gap → calcular valor 1
    4. Exportar como GeoJSON

EJEMPLOS:
    # Ruta completa desde km0, con campo es_gap en el GeoJSON
    python gen_ruta_bundle.py rp61_completa.geojson mojones_rp61.geojson --ruta 61

    # Subtramo con coordenadas de corte
    python gen_ruta_bundle.py rp51_completa.geojson mojones_rp51.geojson --ruta 51 ^
        --ini-lng -60.113 --ini-lat -35.188 --fin-lng -59.972 --fin-lat -36.243

    # Ruta rural con pocos puntos (subir umbral para evitar falsos gaps)
    python gen_ruta_bundle.py rp30.geojson mojones_rp30.geojson --ruta 30 ^
        --gap-threshold 15

    # Forzar prog-ini conocido
    python gen_ruta_bundle.py rp51.geojson mojones_rp51.geojson --ruta 51 ^
        --prog-ini 214.54
"""

import json, math, sys, argparse, os
from pathlib import Path

def hav(a, b):
    R = 6371
    dlat = math.radians(b[1]-a[1]); dlng = math.radians(b[0]-a[0])
    x = math.sin(dlat/2)**2 + math.cos(math.radians(a[1]))*math.cos(math.radians(b[1]))*math.sin(dlng/2)**2
    return R * 2 * math.atan2(math.sqrt(x), math.sqrt(1-x))

def nearest_idx(pts, target):
    best_i, best_d = 0, 1e9
    for i, pt in enumerate(pts):
        d = math.sqrt((pt[0]-target[0])**2+(pt[1]-target[1])**2)*111
        if d < best_d: best_d=d; best_i=i
    return best_i, best_d

def interp_point(pts, acum, target_acc):
    for i in range(1, len(pts)):
        if acum[i] >= target_acc:
            seg_len = acum[i] - acum[i-1]
            if seg_len < 1e-10: return pts[i]
            frac = (target_acc - acum[i-1]) / seg_len
            return [round(pts[i-1][0]+frac*(pts[i][0]-pts[i-1][0]),7),
                    round(pts[i-1][1]+frac*(pts[i][1]-pts[i-1][1]),7)]
    return pts[-1]

def load_chain(path):
    with open(path, encoding='utf-8') as f:
        gj = json.load(f)
    feats = gj['features']
    
    # Recopilar todos los puntos y el campo es_gap por segmento
    all_pts = []
    # es_gap_indices: set de índices de puntos que inician un gap
    gap_ranges = []  # lista de (idx_desde, idx_hasta) en la cadena aplanada
    
    if len(feats) == 1:
        geom = feats[0]['geometry']
        props = feats[0].get('properties', {})
        coords = geom['coordinates'] if geom['type']=='LineString' else [p for s in geom['coordinates'] for p in s]
        all_pts = [[round(p[0],7),round(p[1],7)] for p in coords]
        
        # Si tiene campo es_gap a nivel feature (toda la traza es gap o no)
        # Esto aplica si exportaste features separadas por tipo
        # Para LineString única con campo es_gap: no aplica por segmento
        
    else:
        # Múltiples features — cada una puede tener es_gap
        idx = 0
        for feat in feats:
            geom = feat['geometry']
            props = feat.get('properties', {}) or {}
            es_gap = props.get('es_gap', props.get('gap', 0))
            try: es_gap = int(float(str(es_gap))) if es_gap not in (None,'','NULL','null') else 0
            except: es_gap = 0
            
            coords = geom['coordinates'] if geom['type']=='LineString' else [p for s in geom['coordinates'] for p in s]
            pts_feat = [[round(p[0],7),round(p[1],7)] for p in coords]
            
            # Evitar punto duplicado en la unión
            if all_pts and pts_feat and pts_feat[0] == all_pts[-1]:
                pts_feat = pts_feat[1:]
            
            if es_gap and pts_feat:
                gap_ranges.append((idx, idx+len(pts_feat)-1))
            
            all_pts.extend(pts_feat)
            idx += len(pts_feat)
    
    return all_pts, gap_ranges

def detect_gaps_auto(pts, acum, threshold):
    """Detecta gaps automáticamente por distancia entre puntos consecutivos."""
    gaps = []
    for i in range(1, len(pts)):
        d = hav(pts[i-1], pts[i])
        if d > threshold:
            gaps.append({
                'id': f'gap_{len(gaps)+1}',
                'label': f'Gap {len(gaps)+1}',
                'acc_desde': round(acum[i-1],4),
                'acc_hasta': round(acum[i],4),
                'dist_recta_km': round(d,3),
                'tipo': 'auto_detectado'
            })
    return gaps

def gaps_from_field(pts, acum, gap_ranges):
    """Construye gaps desde el campo es_gap del GeoJSON."""
    gaps = []
    for idx_desde, idx_hasta in gap_ranges:
        idx_desde = max(0, min(idx_desde, len(acum)-1))
        idx_hasta = max(0, min(idx_hasta, len(acum)-1))
        gaps.append({
            'id': f'gap_{len(gaps)+1}',
            'label': f'Gap {len(gaps)+1}',
            'acc_desde': round(acum[idx_desde],4),
            'acc_hasta': round(acum[idx_hasta],4),
            'dist_recta_km': round(hav(pts[idx_desde], pts[min(idx_hasta,len(pts)-1)]),3),
            'tipo': 'es_gap_field'
        })
    return gaps

def load_mojones(path):
    with open(path, encoding='utf-8') as f:
        gj = json.load(f)
    mojs = []
    for feat in gj['features']:
        props = feat['properties'] or {}
        coords = feat['geometry']['coordinates'][:2]
        name = props.get('Name', props.get('name', props.get('name',''))).upper().replace('KM','').strip()
        km_val = props.get('km_value')
        if km_val is None:
            try: km_val = float(name)
            except: km_val = 0.0
        mojs.append({
            'km': float(km_val),
            'lng': round(coords[0],7), 'lat': round(coords[1],7),
            'sentido':  props.get('sentido_prog', props.get('description', '')),
            'tipo':     props.get('tipo_mojon', 'Cincuentakilométrico'),
            'fuente':   props.get('meta_fuent', 'Base Oficial DVBA'),
            'resp':     props.get('meta_resp',  'Ing. Luciano Lamaita'),
            'fecha':    props.get('meta_fecha', '2025-10-21'),
        })
    mojs.sort(key=lambda m: m['km'])
    return mojs

def main():
    p = argparse.ArgumentParser(description='Genera bundle JS para una ruta DVBA v2',
                                formatter_class=argparse.RawDescriptionHelpFormatter,
                                epilog=__doc__)
    p.add_argument('traza')
    p.add_argument('mojones')
    p.add_argument('--ruta',          required=True)
    p.add_argument('--color',         default='#6ab0cc')
    p.add_argument('--paso',          type=float, default=5.0)
    p.add_argument('--gap-threshold', type=float, default=15.0,
                   dest='gap_threshold',
                   help='Umbral km para gaps automáticos si no hay campo es_gap (defecto: 15)')
    p.add_argument('--prog-ini',      type=float, default=None, dest='prog_ini')
    p.add_argument('--ini-lng',       type=float, default=None, dest='ini_lng')
    p.add_argument('--ini-lat',       type=float, default=None, dest='ini_lat')
    p.add_argument('--fin-lng',       type=float, default=None, dest='fin_lng')
    p.add_argument('--fin-lat',       type=float, default=None, dest='fin_lat')
    p.add_argument('--out-dir',       default='.')
    args = p.parse_args()

    rn = args.ruta.lstrip('0') or args.ruta
    var = f"RP{rn}"
    print(f"\n=== Generando bundle RP{rn} ===")

    # ── Cargar traza ──────────────────────────────────────────────────────────
    pts_all, gap_ranges_field = load_chain(args.traza)
    print(f"Traza: {len(pts_all)} puntos totales")
    
    has_gap_field = len(gap_ranges_field) > 0

    # ── Extraer subtramo zona VI ──────────────────────────────────────────────
    if args.ini_lng and args.ini_lat:
        idx_ini, d_ini = nearest_idx(pts_all, [args.ini_lng, args.ini_lat])
        print(f"Inicio zona VI: idx={idx_ini}, dist={d_ini:.3f}km")
    else:
        idx_ini = 0

    if args.fin_lng and args.fin_lat:
        idx_fin, d_fin = nearest_idx(pts_all, [args.fin_lng, args.fin_lat])
        print(f"Fin zona VI:   idx={idx_fin}, dist={d_fin:.3f}km")
    else:
        idx_fin = len(pts_all)-1

    if idx_ini > idx_fin:
        sub = list(reversed(pts_all[idx_fin:idx_ini+1]))
        # Ajustar gap_ranges para el subtramo invertido
        n = idx_ini - idx_fin
        gap_ranges_sub = [(n-(b-idx_fin), n-(a-idx_fin)) for a,b in gap_ranges_field
                          if idx_fin <= a <= idx_ini]
    else:
        sub = pts_all[idx_ini:idx_fin+1]
        gap_ranges_sub = [(a-idx_ini, b-idx_ini) for a,b in gap_ranges_field
                          if idx_ini <= a <= idx_fin]

    # ── Orientar: debe ir de menor progresiva a mayor ─────────────────────────
    if sub[0][0] < sub[-1][0]:  # va de O a E → invertir para E→O
        sub = list(reversed(sub))
        n = len(sub)-1
        gap_ranges_sub = [(n-b, n-a) for a,b in gap_ranges_sub]
        print("Traza invertida para orientación correcta")

    sub = [[round(p[0],7),round(p[1],7)] for p in sub]

    # ── Acumulado ─────────────────────────────────────────────────────────────
    acum = [0.0]
    for i in range(len(sub)-1):
        acum.append(acum[-1]+hav(sub[i],sub[i+1]))
    total_km = acum[-1]
    print(f"Subtramo: {len(sub)} pts, {total_km:.3f} km")

    # ── Gaps ──────────────────────────────────────────────────────────────────
    if has_gap_field and gap_ranges_sub:
        gaps = gaps_from_field(sub, acum, gap_ranges_sub)
        print(f"Gaps desde campo es_gap: {len(gaps)}")
    else:
        gaps = detect_gaps_auto(sub, acum, args.gap_threshold)
        if gaps:
            print(f"Gaps detectados (umbral {args.gap_threshold}km): {len(gaps)}")
            for g in gaps:
                print(f"  {g['id']}: {g['acc_desde']}→{g['acc_hasta']} ({g['dist_recta_km']}km)")
        else:
            print(f"Sin gaps (umbral {args.gap_threshold}km) ✓")

    # ── Mojones y anchors ─────────────────────────────────────────────────────
    mojs = load_mojones(args.mojones)
    print(f"Mojones cargados: km {[m['km'] for m in mojs]}")

    anchors, moj_fis = [], []
    prog_ini = args.prog_ini

    # Solo usar mojones con distancia < 2km al punto más cercano de la cadena
    valid_mojs = []
    for m in mojs:
        bi, bd = nearest_idx(sub, [m['lng'], m['lat']])
        if bd < 2.0:
            valid_mojs.append((m, bi, bd))

    for m, bi, bd in valid_mojs:
        anchors.append({'km': m['km'], 'acc': round(acum[bi],4)})
        moj_fis.append({'ruta':rn,'km':m['km'],'km_label':f'km {int(m["km"])}',
            'lng':m['lng'],'lat':m['lat'],'sintetico':False,'en_gap':False,'gap_id':'',
            'sentido':m['sentido'],'tipo':m['tipo'],'fuente':m['fuente'],
            'resp':m['resp'],'fecha':m['fecha']})
        print(f"  Anchor km{m['km']:6.1f}: acc={acum[bi]:.4f}  dist={bd:.4f}km ✓")
        if prog_ini is None:
            prog_ini = round(m['km'] - acum[bi], 2)

    if not valid_mojs:
        print("  ⚠ Sin mojones válidos dentro de la cadena")
        prog_ini = prog_ini or 0.0

    prog_ini = prog_ini or 0.0
    print(f"prog_ini: km{prog_ini}")

    # Refinar prog_ini promediando todos los mojones válidos
    if len(valid_mojs) > 1:
        estimaciones = [round(m['km']-acum[bi],2) for m,bi,bd in valid_mojs]
        prog_ini = round(sum(estimaciones)/len(estimaciones), 2)
        print(f"prog_ini refinado (promedio de {len(estimaciones)} mojones): km{prog_ini}")

    anchors.sort(key=lambda a: a['km'])
    anchors.append({'km': round(prog_ini+total_km,1), 'acc': round(total_km,4)})
    moj_fis.sort(key=lambda m: m['km'])

    if not anchors or len(anchors) < 2:
        print("⚠ Pocos anchors — progresivas serán aproximadas")

    # ── Mojones sintéticos ────────────────────────────────────────────────────
    km_start = math.ceil(prog_ini/args.paso)*args.paso if prog_ini > 0 else 0.0
    moj_sint = []
    km = km_start
    while km <= prog_ini+total_km+0.01:
        acc = km-prog_ini
        if acc < 0 or acc > total_km+0.01: km=round(km+args.paso,4); continue
        acc = min(acc, total_km)
        pt = interp_point(sub, acum, acc)
        en_gap = any(g['acc_desde']-0.05 <= acc <= g['acc_hasta']+0.05 for g in gaps)
        moj_sint.append({'ruta':rn,'km':km,'km_label':f'km {int(km)}',
            'acc_local':round(acc,4),'lng':pt[0],'lat':pt[1],
            'sintetico':True,'en_gap':en_gap,'gap_id':''})
        km = round(km+args.paso,4)
    print(f"Mojones sintéticos: {len(moj_sint)} (cada {args.paso} km)")

    todos_moj = sorted(moj_fis+moj_sint, key=lambda m: m['km'])

    # ── Serializar ────────────────────────────────────────────────────────────
    sub_j    = json.dumps(sub,       separators=(',',':'))
    anch_j   = json.dumps(anchors,   separators=(',',':'))
    mf_j     = json.dumps(moj_fis,   separators=(',',':'), ensure_ascii=False)
    tod_j    = json.dumps(todos_moj, separators=(',',':'), ensure_ascii=False)
    gaps_j   = json.dumps(gaps,      separators=(',',':'), ensure_ascii=False)
    prog_fin = round(prog_ini+total_km,1)

    # ── Bundle JS ─────────────────────────────────────────────────────────────
    js = f"""// ================================================================
// datos/rutas_rp{rn}.js  —  RP{rn} DVBA Zona VI Saladillo
// Generado por gen_ruta_bundle.py v2
// {len(sub)} pts | {total_km:.3f} km | progIni:{prog_ini} | progFin:{prog_fin}
// Gaps: {len(gaps)} | {"desde campo es_gap" if has_gap_field else f"umbral {args.gap_threshold}km"}
// ================================================================

const CHAIN_{var}={sub_j};
const ANCHORS_{var}={anch_j};
const MOJONES_{var}={mf_j};
const MOJONES_{var}_TODOS={tod_j};
const GAPS_{var}={gaps_j};
const META_{var}={{
  ruta:'{rn}',label:'RP {rn}',color:'{args.color}',weight:5,
  clase:'Mixto',progIni:{prog_ini},progFin:{prog_fin},
  longGis:{round(total_km,3)},
  mojonesF:{len(moj_fis)},mojonesS:{len(moj_sint)},gaps:{len(gaps)},
  gapMethod:'{"es_gap_field" if has_gap_field else "auto_threshold"}'
}};
"""

    # ── HTML test ─────────────────────────────────────────────────────────────
    clat = (sub[0][1]+sub[-1][1])/2
    clng = (sub[0][0]+sub[-1][0])/2
    color = args.color

    html = f"""<!DOCTYPE html>
<html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Test RP{rn} — Zona VI DVBA</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{font-family:Arial,sans-serif;background:#f0f4f8;color:#1a2a3a}}
#hdr{{background:#003366;padding:8px 14px;display:flex;align-items:center;gap:12px;flex-wrap:wrap}}
#hdr h1{{font-size:.92rem;color:#fff;white-space:nowrap}}
#stats{{font-size:.72rem;color:#adf;margin-left:auto}}
#map{{width:100%;height:calc(100vh - 40px)}}
.ctrl{{position:absolute;z-index:1000;background:rgba(255,255,255,.96);padding:10px;
       border-radius:6px;font-size:.75rem;color:#1a2a3a;box-shadow:0 2px 8px rgba(0,0,0,.2)}}
#pnl-capa{{top:52px;right:10px}}
#pnl-capa label{{display:block;margin:3px 0;cursor:pointer}}
#pnl-capa hr{{margin:5px 0}}
#pnl-prog{{bottom:20px;left:10px;min-width:220px;background:rgba(0,51,102,.93);
           color:#fff;display:none;padding:10px 14px;border-radius:6px;font-size:.82rem;line-height:1.7}}
#pnl-ley{{bottom:20px;right:10px;font-size:.72rem}}
#pnl-ley h4{{color:#003366;margin-bottom:5px}}
.dot{{display:inline-block;width:9px;height:9px;border-radius:50%;margin-right:4px;vertical-align:middle}}
.mjl{{background:transparent;border:none;font-size:.68rem;font-weight:bold;
      white-space:nowrap;text-shadow:1px 1px 2px #fff,-1px -1px 2px #fff}}
</style></head><body>
<div id="hdr">
  <h1>🗺 RP{rn} — Test | DVBA Zona VI</h1>
  <div id="stats">cargando...</div>
</div>
<div id="map"></div>
<div class="ctrl" id="pnl-capa">
  <b>Capas</b>
  <label><input type="checkbox" id="c-t" checked> Traza</label>
  <label><input type="checkbox" id="c-g" checked> Gaps</label>
  <label><input type="checkbox" id="c-mf" checked> Mojones físicos</label>
  <label><input type="checkbox" id="c-ms" checked> Mojones sint.</label>
  <hr>Paso: <select id="sel-paso" style="font-size:.75rem;width:100%;margin-top:3px">
    <option value="5" selected>5 km</option><option value="10">10 km</option><option value="1">1 km</option>
  </select>
  <hr><div style="color:#555;font-size:.7rem">Clic → progresiva</div>
</div>
<div class="ctrl" id="pnl-ley">
  <h4>RP{rn}</h4>
  <div><span class="dot" style="background:{color}"></span>Traza</div>
  <div><span class="dot" style="background:#e05050;border-radius:0;width:18px;height:2px"></span> Gap</div>
  <div><span class="dot" style="background:#003366;border:2px solid #fff"></span>Mojón físico</div>
  <div><span class="dot" style="background:#888"></span>Sint.</div>
</div>
<div id="pnl-prog"></div>
<script src="datos/rutas_rp{rn}.js"></script>
<script src="datos/rutas.js"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(function(){{
  const falta=['CHAIN_{var}','ANCHORS_{var}','GAPS_{var}','MOJONES_{var}_TODOS','META_{var}']
    .filter(v=>typeof window[v]==='undefined');
  if(falta.length)document.getElementById('stats').textContent='⚠ Falta: '+falta.join(', ');
}})();
const map=L.map('map').setView([{clat:.5f},{clng:.5f}],10);
L.tileLayer('https://{{s}}.tile.openstreetmap.org/{{z}}/{{x}}/{{y}}.png',
  {{attribution:'© OpenStreetMap',maxZoom:18}}).addTo(map);
function hav(a,b){{
  const R=6371,dL=(b[1]-a[1])*Math.PI/180,dl=(b[0]-a[0])*Math.PI/180;
  const x=Math.sin(dL/2)**2+Math.cos(a[1]*Math.PI/180)*Math.cos(b[1]*Math.PI/180)*Math.sin(dl/2)**2;
  return R*2*Math.atan2(Math.sqrt(x),Math.sqrt(1-x));
}}
const ACUM=[0];
for(let i=1;i<CHAIN_{var}.length;i++) ACUM.push(ACUM[i-1]+hav(CHAIN_{var}[i-1],CHAIN_{var}[i]));
function calcProg(acc){{
  const A=ANCHORS_{var},pi=META_{var}.progIni;
  if(!A||A.length<2)return pi+acc;
  if(acc<=A[0].acc){{if(A[0].acc===0)return A[0].km;return A[0].km-(A[0].acc-acc)*(A[0].km-pi)/A[0].acc;}}
  for(let i=0;i<A.length-1;i++){{
    const a=A[i],b=A[i+1];
    if(acc>=a.acc&&acc<=b.acc)return a.km+(acc-a.acc)/(b.acc-a.acc)*(b.km-a.km);
  }}
  const last=A[A.length-1],prev=A[A.length-2];
  return last.km+(acc-last.acc)*(last.km-prev.km)/(last.acc-prev.acc);
}}
function getGap(acc){{return(GAPS_{var}||[]).find(g=>acc>=g.acc_desde-0.1&&acc<=g.acc_hasta+0.1)||null;}}
const segsN=[],segsG=[];
let seg=[CHAIN_{var}[0]],esG=!!getGap(ACUM[0]);
for(let i=1;i<CHAIN_{var}.length;i++){{
  const gk=!!getGap(ACUM[i]),nuevo=hav(CHAIN_{var}[i-1],CHAIN_{var}[i])>8.0||gk;
  if(nuevo!==esG){{(esG?segsG:segsN).push([...seg]);seg=[CHAIN_{var}[i-1]];esG=nuevo;}}
  seg.push(CHAIN_{var}[i]);
}}
(esG?segsG:segsN).push(seg);
const lyT=L.layerGroup(),lyG=L.layerGroup(),lyMF=L.layerGroup(),lyMS=L.layerGroup();
segsN.forEach(s=>L.polyline(s.map(p=>[p[1],p[0]]),{{color:'{color}',weight:5,opacity:.9}}).addTo(lyT));
segsG.forEach(s=>L.polyline(s.map(p=>[p[1],p[0]]),{{color:'#e05050',weight:3,dashArray:'10,6'}}).addTo(lyG));
function buildMF(){{
  lyMF.clearLayers();
  (MOJONES_{var}||[]).forEach(m=>{{
    L.circleMarker([m.lat,m.lng],{{radius:9,fillColor:'#003366',color:'#fff',weight:2,fillOpacity:1}})
     .bindPopup(`<b>km ${{m.km}}</b><br>${{m.sentido||''}}<br><i>${{m.tipo||''}}</i>`).addTo(lyMF);
    L.marker([m.lat,m.lng],{{icon:L.divIcon({{className:'mjl',html:`km ${{m.km}}`,iconAnchor:[-5,-4]}})}}).addTo(lyMF);
  }});
}}
function buildMS(paso){{
  lyMS.clearLayers();
  (MOJONES_{var}_TODOS||[]).filter(m=>m.sintetico&&m.km%paso===0).forEach(m=>{{
    const c=m.en_gap?'#e05050':'#888';
    L.circleMarker([m.lat,m.lng],{{radius:4,fillColor:c,color:'#fff',weight:1,fillOpacity:.85}})
     .bindPopup(`km ${{m.km}} (sint.)${{m.en_gap?' ⚠ gap':''}}`).addTo(lyMS);
    if(m.km%20===0)L.marker([m.lat,m.lng],{{icon:L.divIcon({{className:'mjl',
      html:`<span style="color:${{m.en_gap?'#c00':'#555'}}">${{m.km}}</span>`,iconAnchor:[-4,-3]}})}}).addTo(lyMS);
  }});
}}
buildMF();buildMS(5);
[lyT,lyG,lyMF,lyMS].forEach(l=>l.addTo(map));
[['c-t',lyT],['c-g',lyG],['c-mf',lyMF],['c-ms',lyMS]]
  .forEach(([id,l])=>document.getElementById(id).onchange=e=>e.target.checked?l.addTo(map):l.remove());
document.getElementById('sel-paso').onchange=e=>{{buildMS(+e.target.value);
  if(document.getElementById('c-ms').checked)lyMS.addTo(map);}};
map.on('click',e=>{{
  let bi=0,bd=1e9;
  CHAIN_{var}.forEach((p,i)=>{{const d=Math.sqrt((p[0]-e.latlng.lng)**2+(p[1]-e.latlng.lat)**2);if(d<bd){{bd=d;bi=i;}}}});
  const acc=ACUM[bi],prog=calcProg(acc),g=getGap(acc);
  const box=document.getElementById('pnl-prog');box.style.display='block';
  box.innerHTML=`<b>RP {rn}</b><br>Progresiva: <b>km ${{prog.toFixed(2)}}</b><br>`+
    `Acum. local: ${{acc.toFixed(3)}} km<br>prog_ini: ${{META_{var}.progIni}} km`+
    (g?`<br><span style="color:#f99">⚠ ${{g.label}}</span>`:'');
}});
map.fitBounds(L.latLngBounds(CHAIN_{var}.map(p=>[p[1],p[0]])).pad(.08));
document.getElementById('stats').textContent=
  `${{CHAIN_{var}.length}} pts | ${{META_{var}.longGis}}km | `+
  `progIni:km${{META_{var}.progIni}} | ${{META_{var}.mojonesF}}fis+${{META_{var}.mojonesS}}sint | `+
  `${{META_{var}.gaps}} gaps`;
</script></body></html>"""

    # ── Guardar ───────────────────────────────────────────────────────────────
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    datos_dir = out / 'datos'
    datos_dir.mkdir(exist_ok=True)

    js_path   = datos_dir / f"rutas_rp{rn}.js"
    html_path = out / f"test_rp{rn}.html"
    with open(js_path,   'w', encoding='utf-8') as f: f.write(js)
    with open(html_path, 'w', encoding='utf-8') as f: f.write(html)

    print(f"\n✓ {js_path}  ({js_path.stat().st_size//1024} KB)")
    print(f"✓ {html_path}")
    print(f"\nAgregar en datos/rutas.js:")
    print(f"  if (typeof CHAIN_{var}  !== 'undefined') CHAINS_DATA['{rn}']  = CHAIN_{var};")
    print(f"  if (typeof ANCHORS_{var} !== 'undefined') ANCHORS_DATA['{rn}'] = ANCHORS_{var};")

if __name__ == '__main__':
    main()
