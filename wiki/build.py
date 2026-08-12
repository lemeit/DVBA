#!/usr/bin/env python3
"""
build.py · Convierte la Guía de Usuario (Obsidian source) a formato MkDocs.

Fuente:  ./01-Guia-de-Usuario/*.md    (wikilinks estilo Obsidian [[Nota]])
Destino: ./docs/*.md                   (links markdown estándar [texto](Nota.md))

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

# [[Nota]]        → [Nota](Nota.md)
# [[Nota|Alias]]  → [Alias](Nota.md)
WIKILINK_RE = re.compile(r'\[\[([^\]|]+)(?:\|([^\]]+))?\]\]')

def convertir_wikilinks(texto: str) -> str:
    def repl(m):
        destino = m.group(1).strip()
        alias   = (m.group(2) or destino).strip()
        return f'[{alias}]({destino}.md)'
    return WIKILINK_RE.sub(repl, texto)

def main():
    clean = '--clean' in sys.argv
    if not SRC.exists():
        print(f'[error] fuente no existe: {SRC}')
        sys.exit(1)
    if clean and DST.exists():
        shutil.rmtree(DST)
        print(f'[clean] borrado {DST}')
    DST.mkdir(exist_ok=True, parents=True)

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

if __name__ == '__main__':
    main()
