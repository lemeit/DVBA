#!/usr/bin/env python3
"""bump_version.py - Bumpea version en dvba_campo.html, index.html y sw.js.
Uso: python scripts/bump_version.py v9.1
     python scripts/bump_version.py --show
"""
import re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# (archivo, etiqueta_uso, regex con grupo 'v', plantilla)
TARGETS = [
    ("dvba_campo.html", "footer visible",
     r"<span id=['\"]app-ver['\"]>v?(?P<v>[^<]+)</span>",
     "<span id='app-ver'>{ver}</span>"),
    ("dvba_campo.html", "var JS (sello fotos)",
     r"APP_VER\s*=\s*'(?P<v>[^']+)'",
     "APP_VER = '{ver}'"),
    ("dvba_campo.html", "comentario JS",
     r"/\* DVBA Campo (?P<v>v[0-9.]+) - GPS/Camara/Sello/Sync \*/",
     "/* DVBA Campo {ver} - GPS/Camara/Sello/Sync */"),
    ("index.html", "header + reportes",
     r"const APP_VERSION\s*=\s*'(?P<v>[^']+)'",
     "const APP_VERSION = '{ver}'"),
    ("sw.js", "cache PWA",
     r"const CACHE_NAME\s*=\s*'dvba-campo-(?P<v>[^']+)'",
     "const CACHE_NAME = 'dvba-campo-{ver}'"),
]


def normalize(ver):
    ver = ver.strip().lstrip("v")
    if not re.match(r"^\d+(\.\d+)*$", ver):
        sys.exit("ERROR: version invalida: " + repr(ver))
    # asegurar que el "v" capturado en el footer no quede sin v
    return "v" + ver


def show_current():
    print("Repo: " + str(ROOT) + "\n")
    print("  archivo".ljust(22) + "uso".ljust(24) + "version")
    print("  " + "-" * 60)
    for fname, label, regex, _ in TARGETS:
        p = ROOT / fname
        if not p.exists():
            print("  [!] " + fname + " no existe"); continue
        m = re.search(regex, p.read_text(encoding="utf-8"))
        ver = m.group('v') if m else "(no encontrado)"
        # normalizar display: si capturó "9.0" sin v, mostrar como "v9.0"
        if m and not ver.startswith("v") and re.match(r"^\d", ver):
            ver = "v" + ver
        print("  " + fname.ljust(20) + label.ljust(24) + ver)


def bump(new_ver):
    new_ver = normalize(new_ver)
    print("Bumpeando a " + new_ver + "\n")
    mods = 0
    for fname, label, regex, tpl in TARGETS:
        p = ROOT / fname
        if not p.exists(): continue
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
        print("  [OK] " + fname.ljust(20) + label.ljust(24) + old_norm + " -> " + new_ver)
        mods += 1
    if mods:
        print("\nProximos pasos:")
        print("  git add -A && git commit -m \"Bump version -> " + new_ver + "\" && git push")


def main():
    a = sys.argv[1:]
    if not a or a[0] in ("-h", "--help"): print(__doc__); return
    if a[0] in ("--show", "-s"): show_current(); return
    bump(a[0])


if __name__ == "__main__":
    main()
