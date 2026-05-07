#!/usr/bin/env python3
"""bump_version.py - Bumpea version de cada artefacto del proyecto DVBA.

Artefactos (cada uno con su propia version):
  - campo         dvba_campo.html (footer + var JS sello + comentario) + sw.js cache
  - escritorio    index.html (header + reportes)
  - guia          docs/guia_dvba_campo.html (textual)
  - guia_visual   docs/guia_visual_dvba_campo.html (mockups celular)
  - bitacora      docs/bitacora.html

Uso:
  python scripts/bump_version.py --show
  python scripts/bump_version.py campo v9.3
  python scripts/bump_version.py escritorio v7.0
  python scripts/bump_version.py guia v1.1
  python scripts/bump_version.py guia_visual v1.1
  python scripts/bump_version.py bitacora v3.3
  python scripts/bump_version.py todos v9.3   (uso ocasional - sincroniza todo)
"""
import re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

ARTEFACTOS = {
    "campo": [
        ("dvba_campo.html", "footer visible",
         r"<span id=['\"]app-ver['\"]>v?(?P<v>[^<]+)</span>",
         "<span id='app-ver'>{ver}</span>"),
        ("dvba_campo.html", "var JS (sello fotos)",
         r"APP_VER\s*=\s*'(?P<v>[^']+)'",
         "APP_VER = '{ver}'"),
        ("dvba_campo.html", "comentario JS",
         r"/\* DVBA Campo (?P<v>v[0-9.]+) - GPS/Camara/Sello/Sync \*/",
         "/* DVBA Campo {ver} - GPS/Camara/Sello/Sync */"),
        ("sw.js", "cache PWA",
         r"const CACHE_NAME\s*=\s*'dvba-campo-(?P<v>[^']+)'",
         "const CACHE_NAME = 'dvba-campo-{ver}'"),
    ],
    "escritorio": [
        ("index.html", "header + reportes",
         r"const APP_VERSION\s*=\s*'(?P<v>[^']+)'",
         "const APP_VERSION = '{ver}'"),
    ],
    "guia": [
        ("docs/guia_dvba_campo.html", "header",
         r"<span class=\"lbl\">Versión app</span><span class=\"val\">v?(?P<v>[^<]+)</span>",
         "<span class=\"lbl\">Versión app</span><span class=\"val\">{ver}</span>"),
        ("docs/guia_dvba_campo.html", "footer",
         r"App de Campo DVBA Zona VI Saladillo · v?(?P<v>[0-9.]+)",
         "App de Campo DVBA Zona VI Saladillo · {ver}"),
    ],
    "guia_visual": [
        ("docs/guia_visual_dvba_campo.html", "header",
         r"<span class=\"lbl\">Versión guía visual</span><span class=\"val\">v?(?P<v>[^<]+)</span>",
         "<span class=\"lbl\">Versión guía visual</span><span class=\"val\">{ver}</span>"),
        ("docs/guia_visual_dvba_campo.html", "footer",
         r"Guía visual · App de Campo DVBA Zona VI Saladillo · v?(?P<v>[0-9.]+)",
         "Guía visual · App de Campo DVBA Zona VI Saladillo · {ver}"),
    ],
    "bitacora": [
        ("docs/bitacora.html", "header",
         r"<span class=\"val\">v?(?P<v>[0-9.]+) — apps v[0-9.]+</span>",
         "<span class=\"val\">{ver} — apps v9.2</span>"),
    ],
}


def normalize(ver):
    ver = ver.strip().lstrip("v")
    if not re.match(r"^\d+(\.\d+)*$", ver):
        sys.exit("ERROR: version invalida: " + repr(ver))
    return "v" + ver


def show_one(art_name, targets):
    print("\n[" + art_name + "]")
    for fname, label, regex, _ in targets:
        p = ROOT / fname
        if not p.exists():
            print("  [!] " + fname + " no existe"); continue
        m = re.search(regex, p.read_text(encoding="utf-8"))
        ver = m.group('v') if m else "(no encontrado)"
        if m and not ver.startswith("v") and re.match(r"^\d", ver):
            ver = "v" + ver
        print("  " + fname.ljust(36) + label.ljust(22) + ver)


def show_all():
    print("Repo: " + str(ROOT))
    for art, targets in ARTEFACTOS.items():
        show_one(art, targets)


def bump(art_name, new_ver):
    new_ver = normalize(new_ver)
    print("Bumpeando '" + art_name + "' a " + new_ver + "\n")
    if art_name == "todos":
        artefactos = ARTEFACTOS
    elif art_name in ARTEFACTOS:
        artefactos = {art_name: ARTEFACTOS[art_name]}
    else:
        sys.exit("ERROR: artefacto desconocido. Opciones: " +
                 ", ".join(list(ARTEFACTOS.keys()) + ["todos"]))
    mods = 0
    for art, targets in artefactos.items():
        for fname, label, regex, tpl in targets:
            p = ROOT / fname
            if not p.exists():
                print("  [!] " + fname + " no existe"); continue
            txt = p.read_text(encoding="utf-8")
            m = re.search(regex, txt)
            if not m:
                print("  [!] " + fname + " (" + label + ") patron no hallado"); continue
            old_v = m.group('v')
            old_norm = old_v if old_v.startswith("v") else "v" + old_v
            if old_norm == new_ver:
                print("  [-] " + fname + " (" + label + ") ya en " + new_ver); continue
            new_txt = re.sub(regex, tpl.format(ver=new_ver), txt, count=1)
            p.write_text(new_txt, encoding="utf-8", newline="")
            print("  [OK] " + fname.ljust(36) + label.ljust(22) + old_norm + " -> " + new_ver)
            mods += 1
    if mods:
        print("\nProximos pasos:")
        print("  git add -A")
        print('  git commit -m "Bump ' + art_name + ' -> ' + new_ver + '"')
        print("  git push")


def main():
    a = sys.argv[1:]
    if not a or a[0] in ("-h", "--help"):
        print(__doc__); return
    if a[0] in ("--show", "-s"):
        show_all(); return
    if len(a) == 2:
        bump(a[0], a[1]); return
    print("Uso: python scripts/bump_version.py <artefacto> <vX.Y>")
    print("     python scripts/bump_version.py --show")
    print("Artefactos: " + ", ".join(list(ARTEFACTOS.keys()) + ["todos"]))
    sys.exit(1)


if __name__ == "__main__":
    main()
