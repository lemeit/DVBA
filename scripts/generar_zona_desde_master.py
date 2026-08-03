#!/usr/bin/env python3
"""
scripts/generar_zona_desde_master.py
Genera los geojson de una zona (partidos + rutas) filtrando los master
`datos/referencias/partidos_pba.geojson` y `rutas_pba.geojson` según el
manifest de la zona (`datos/zonas/zona_XX/manifest.json`).

Aportado en v8.61 (2026-08-03) para poblar zonas más allá de VI.

USO:
    python scripts/generar_zona_desde_master.py IV
    python scripts/generar_zona_desde_master.py V

Escribe:
    datos/zonas/zona_XX/partidos_zonaXX.geojson   (filtrado por lista de partidos)
    datos/zonas/zona_XX/rutas_zonaXX.geojson      (todos los tramos que pasan por esos partidos)

NORMALIZACIÓN:
- El shp master tiene partidos en UPPERCASE sin tildes (ej. "ADOLFO ALSINA").
- El manifest usa nombres canónicos Title Case con tildes (ej. "Adolfo Alsina").
- Este script normaliza (uppercase + sin tildes) para hacer el match y en la salida
  reescribe la propiedad `PARTIDO` con el nombre canónico (con tildes) para
  consistencia con la BD y la UI.

NO TOCA zona VI (chequeo explícito → aborta si le pedís generar VI).
"""
import json, sys, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def strip_accents(s):
    return ''.join(c for c in unicodedata.normalize('NFD', s) if unicodedata.category(c) != 'Mn')

def norm(s):
    """Normaliza a UPPERCASE sin tildes ni espacios extra."""
    return strip_accents(str(s).upper().strip())

def cargar_catalogo():
    """Devuelve dict {NORM_UPPER_SIN_TILDES: 'Nombre Canónico'} desde partidos_pba.json."""
    with (ROOT / 'datos/referencias/partidos_pba.json').open(encoding='utf-8') as f:
        cat = json.load(f)
    canon = {}
    for p in cat['partidos']:
        canon[norm(p['nombre'])] = p['nombre']
        if p.get('nombre_corto'):
            canon[norm(p['nombre_corto'])] = p['nombre']
    return canon

def main(cod_zona):
    cod_zona = cod_zona.upper()
    if cod_zona == 'VI':
        print('❌ Zona VI YA ESTÁ EN PRODUCCIÓN con datos calibrados manualmente.')
        print('   No la sobreescribo. Si necesitás regenerar, borra --force manualmente.')
        sys.exit(1)

    zona_dir = ROOT / f'datos/zonas/zona_{cod_zona}'
    if not zona_dir.exists():
        print(f'❌ No existe {zona_dir}. Creá primero el manifest.json en esa carpeta.')
        sys.exit(1)
    manifest_path = zona_dir / 'manifest.json'
    if not manifest_path.exists():
        print(f'❌ No existe {manifest_path}. Escribí primero el manifest de la zona.')
        sys.exit(1)

    with manifest_path.open(encoding='utf-8') as f:
        manifest = json.load(f)

    # Lista de partidos canónicos + aliases del catálogo
    canon = cargar_catalogo()
    partidos_zona = [p['nombre'] for p in manifest['partidos']]
    partidos_norm = set()
    aliases = {}  # NORM_UPPER → nombre canónico (para reescribir salida)
    for p in partidos_zona:
        n = norm(p)
        partidos_norm.add(n)
        aliases[n] = p
        # Aliases del catálogo (ej "9 de Julio" ≡ "Nueve de Julio")
        for k, v in canon.items():
            if v == p and k != n:
                partidos_norm.add(k)
                aliases[k] = p

    print(f'\n━━━ Generando Zona {cod_zona} · {manifest["nombre"]} ━━━')
    print(f'Partidos esperados: {len(partidos_zona)}')

    # 1) Filtrar partidos
    with (ROOT / 'datos/referencias/partidos_pba.geojson').open(encoding='utf-8') as f:
        p_geo = json.load(f)
    p_out = {'type': 'FeatureCollection', 'features': []}
    encontrados = set()
    for feat in p_geo['features']:
        prop = feat['properties']
        n_partido = norm(prop.get('PARTIDO', ''))
        if n_partido in partidos_norm:
            canonico = aliases[n_partido]
            # Reescribir PARTIDO con el nombre canónico + agregar campo compat
            prop['PARTIDO'] = canonico
            prop['partido'] = canonico  # alias minúsculas para compat con código legacy
            p_out['features'].append(feat)
            encontrados.add(canonico)

    print(f'Partidos encontrados en shp: {len(p_out["features"])}/{len(partidos_zona)}')
    faltantes = set(partidos_zona) - encontrados
    if faltantes:
        print(f'⚠ Faltan en el shp: {faltantes}')

    p_dst = zona_dir / f'partidos_zona{cod_zona}.geojson'
    with p_dst.open('w', encoding='utf-8') as f:
        json.dump(p_out, f, ensure_ascii=False)
    print(f'✓ Escrito: {p_dst.relative_to(ROOT)} ({p_dst.stat().st_size/1024:.0f} KB)')

    # 2) Filtrar rutas (todos los tramos que pasan por esos partidos)
    with (ROOT / 'datos/referencias/rutas_pba.geojson').open(encoding='utf-8') as f:
        r_geo = json.load(f)
    r_out = {'type': 'FeatureCollection', 'features': []}
    rps_encontradas = set()
    for feat in r_geo['features']:
        prop = feat['properties']
        muni = norm(prop.get('municipi_1', ''))
        if muni in partidos_norm:
            # Reescribir el nombre del partido a canónico para consistencia
            prop['municipi_1'] = aliases[muni]
            prop['partido'] = aliases[muni]  # alias
            r_out['features'].append(feat)
            rps_encontradas.add(str(prop.get('rtn', '?')))

    print(f'Tramos RP encontrados: {len(r_out["features"])}')
    def sort_key(x):
        try: return (0, int(x))
        except: return (1, x)
    print(f'RPs que atraviesan la zona: {sorted(rps_encontradas, key=sort_key)}')

    r_dst = zona_dir / f'rutas_zona{cod_zona}.geojson'
    with r_dst.open('w', encoding='utf-8') as f:
        json.dump(r_out, f, ensure_ascii=False)
    print(f'✓ Escrito: {r_dst.relative_to(ROOT)} ({r_dst.stat().st_size/1024:.0f} KB)')

    print(f'\n✓ Zona {cod_zona} generada.')
    print(f'  Total: {len(p_out["features"])} partidos + {len(r_out["features"])} tramos RP.')
    print(f'  RPs distintas: {len(rps_encontradas)}')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Uso: python scripts/generar_zona_desde_master.py <COD_ZONA>')
        print('Ej.: python scripts/generar_zona_desde_master.py IV')
        sys.exit(1)
    main(sys.argv[1])
