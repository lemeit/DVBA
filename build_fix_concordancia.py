#!/usr/bin/env python3
"""Fix concordancia gramatical post-rename Zona Departamental → Departamento Zona.
Reemplaza 'la Departamento' → 'el Departamento' y variantes con contracciones."""
import os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

REPLACEMENTS = [
    # Contracciones (más específicas primero)
    ('de la **Departamento',   'del **Departamento'),
    ('de la Departamento',     'del Departamento'),
    ('a la Departamento',      'al Departamento'),
    # Artículos determinados
    ('en la Departamento',     'en el Departamento'),
    ('con la Departamento',    'con el Departamento'),
    ('por la Departamento',    'por el Departamento'),
    ('para la Departamento',   'para el Departamento'),
    ('sobre la Departamento',  'sobre el Departamento'),
    ('desde la Departamento',  'desde el Departamento'),
    ('hasta la Departamento',  'hasta el Departamento'),
    # Al inicio de oración o después de coma/paréntesis
    ('La Departamento',        'El Departamento'),
    ('la Departamento',        'el Departamento'),
    # Indefinidos
    ('una Departamento',       'un Departamento'),
    ('Una Departamento',       'Un Departamento'),
    ('esta Departamento',      'este Departamento'),
    ('esa Departamento',       'ese Departamento'),
    ('aquella Departamento',   'aquel Departamento'),
]

EXTS = ('.html', '.md', '.js', '.json', '.py', '.sql')
EXCLUDE_PATHS_PREFIX = ('archivo/', '.git/', 'output/', 'geojson_procesados/', 'datos/zona_vi/')

files_touched = 0
total = 0

for root, dirs, files in os.walk(REPO):
    rel_root = os.path.relpath(root, REPO).replace('\\','/')
    if rel_root == '.': rel_root = ''
    rel_root_norm = rel_root + ('/' if rel_root else '')
    if any(rel_root_norm.startswith(p) for p in EXCLUDE_PATHS_PREFIX): continue
    for fname in files:
        if not fname.endswith(EXTS): continue
        if fname.startswith('build_') and fname.endswith('.py'): continue
        full = os.path.join(root, fname)
        rel = os.path.join(rel_root, fname).replace('\\','/')
        try:
            with open(full, 'r', encoding='utf-8') as f: content = f.read()
        except UnicodeDecodeError: continue
        orig = content
        n_local = 0
        for old, new in REPLACEMENTS:
            n = content.count(old)
            if n:
                content = content.replace(old, new)
                n_local += n
        if content != orig:
            with open(full, 'w', encoding='utf-8') as f: f.write(content)
            files_touched += 1
            total += n_local
            print(f'  {rel}: {n_local} fixes')

print(f'\nTotal: {files_touched} archivos modificados, {total} correcciones.')
