#!/usr/bin/env python3
"""Reemplaza 'Zona Departamental' → 'Departamento Zona' en el repo.
Excluye los snapshots históricos bajo archivo/ (que son fotos del pasado)."""
import os

REPO = '/sessions/eager-tender-faraday/mnt/GitHub--DVBA'

# Reemplazos ordenados de más largo a más corto para no pisar
REPLACEMENTS = [
    # Nombres institucionales estándar
    ('Zona Departamental VI Saladillo', 'Departamento Zona VI Saladillo'),
    ('Zona Departamental VII',          'Departamento Zona VII'),
    ('Zona Departamental VI',           'Departamento Zona VI'),
    # Genérico por si aparece suelto
    ('Zona Departamental',              'Departamento Zona'),
    ('zona departamental',              'departamento zona'),
]

# Extensiones a procesar
EXTS = ('.html', '.md', '.js', '.json', '.py', '.sql')

# Directorios excluidos (snapshots históricos)
EXCLUDE_DIRS = {
    'archivo',   # bitacoras_historicas, guias_historicas, versiones
    '.git',
    'output',
    'geojson_procesados',  # data, no queremos tocar
    'scripts/output',
    'datos/zona_vi',   # geojson data
    'referencias',     # los json de referencia — ojo tienen los nombres
}
# En realidad SÍ queremos tocar referencias/partidos_pba.json (mencionado en el grep).
# Y NO queremos tocar geojson_procesados ni datos/zona_vi/*.geojson (data pesada).
# Refino:
EXCLUDE_PATHS_PREFIX = (
    'archivo/',
    '.git/',
    'output/',
    'geojson_procesados/',
    'datos/zona_vi/',
)

changes = []
files_touched = 0

for root, dirs, files in os.walk(REPO):
    # Filtrar dirs a excluir en tiempo real
    rel_root = os.path.relpath(root, REPO)
    if rel_root == '.':
        rel_root = ''
    rel_root_norm = rel_root.replace('\\','/') + ('/' if rel_root else '')
    if any(rel_root_norm.startswith(p) for p in EXCLUDE_PATHS_PREFIX):
        continue
    for fname in files:
        if not fname.endswith(EXTS): continue
        rel = os.path.join(rel_root, fname).replace('\\','/')
        # Excluir explícitamente los build_*.py de mi propio proceso
        if fname.startswith('build_') and fname.endswith('.py'):
            continue
        full = os.path.join(root, fname)
        try:
            with open(full, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            continue
        orig = content
        n_local = 0
        for old, new in REPLACEMENTS:
            n = content.count(old)
            if n:
                content = content.replace(old, new)
                n_local += n
                changes.append((rel, old, n))
        if content != orig:
            with open(full, 'w', encoding='utf-8') as f:
                f.write(content)
            files_touched += 1
            print(f'  {rel}: {n_local} reemplazos')

print(f'\nTotal: {files_touched} archivos modificados, {sum(c[2] for c in changes)} reemplazos.')
