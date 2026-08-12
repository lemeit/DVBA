#!/usr/bin/env python3
"""
build.py · Convierte la Guía de Usuario (Obsidian source) a formato MkDocs.

Fuente:  ./01-Guia-de-Usuario/*.md    (wikilinks estilo Obsidian [[Nota]])
Destino: ./docs/*.md                   (links markdown estándar [texto](Nota.md))

Además copia assets estáticos (CSS, imágenes) desde ./stylesheets/ y ./img/
a ./docs/ porque MkDocs sirve SOLO desde docs_dir. Se ejecutan en cada build.

Uso:
    python3 build.py              # convierte y escribe en ./docs/
    python3 build.py --clean      # limpia ./docs/ antes de regenerar

Después:
    mkdocs serve                  # preview local en http://localhost:8000
    mkdocs build                  # genera ./site/ para publicar
    mkdocs gh-deploy --force      # publica a branch gh-pages

Requisitos:
    pip install mkdocs mkdocs-material pymdown-extensions
"""
import re, shutil, sys
from pathlib import Path

HERE = Path(__file__).parent
SRC  = HERE / '01-Guia-de-Usuario'
DST  = HERE / 'docs'

# Assets estáticos a copiar a docs/ (MkDocs sirve solo desde docs_dir)
ASSETS = [
    ('stylesheets', 'stylesheets'),  # wiki/stylesheets/ → wiki/docs/stylesheets/
    ('img',         'img'),          # wiki/img/         → wiki/docs/img/ (si existe)
    ('01-Guia-de-Usuario/img', 'img'),  # wiki/01-Guia-de-Usuario/img/ → wiki/docs/img/
]

# [[Nota]]        → [Nota](Nota.md)
# [[Nota|Alias]]  → [Alias](Nota.md)
WIKILINK_RE = re.compile(r'\[\[([^\]|]+)(?:\|([^\]]+))?\]\]')

def convertir_wikilinks(texto: str) -> str:
    def repl(m):
        destino = m.group(1).strip()
        alias   = (m.group(2) or destino).strip()
        return f'[{alias}]({destino}.md)'
    return WIKILINK_RE.sub(repl, texto)

def copiar_assets():
    """Copia stylesheets/, img/ y similares desde el fuente a docs/"""
    total = 0
    for src_rel, dst_rel in ASSETS:
        src_path = HERE / src_rel
        dst_path = DST / dst_rel
        if not src_path.exists() or not src_path.is_dir():
            continue
        dst_path.mkdir(parents=True, exist_ok=True)
        for archivo in src_path.rglob('*'):
            if archivo.is_dir():
                continue
            rel = archivo.relative_to(src_path)
            destino = dst_path / rel
            destino.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(archivo, destino)
            total += 1
        print(f'[assets] {src_rel} → docs/{dst_rel}')
    if total:
        print(f'[assets] {total} archivos copiados')

def main():
    clean = '--clean' in sys.argv
    if not SRC.exists():
        print(f'[error] fuente no existe: {SRC}')
        sys.exit(1)
    if clean and DST.exists():
        shutil.rmtree(DST)
        print(f'[clean] borrado {DST}')
    DST.mkdir(exist_ok=True, parents=True)

    # 1. Copiar .md convertidos
    archivos = sorted(SRC.glob('*.md'))
    total = 0
    for src_file in archivos:
        contenido = src_file.read_text(encoding='utf-8')
        contenido_conv = convertir_wikilinks(contenido)
        dst_file = DST / src_file.name
        dst_file.write_text(contenido_conv, encoding='utf-8')
        n_wl = len(WIKILINK_RE.findall(contenido))
        marca = '' if n_wl == 0 else f' ({n_wl} wikilinks)'
        print(f'[ok]    {src_file.name}{marca}')
        total += 1
    print(f'\n{total} archivos convertidos → {DST}')

    # 2. Copiar assets estáticos
    copiar_assets()

if __name__ == '__main__':
    main()
