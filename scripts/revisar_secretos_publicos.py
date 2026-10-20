"""Detecta credenciales de servidor y contraseñas SQL literales sin imprimirlas."""
import base64
import json
import pathlib
import re
import subprocess
import sys

hallazgos = []
archivos = subprocess.check_output(["git", "ls-files"], text=True).splitlines()
for nombre in archivos:
    archivo = pathlib.Path(nombre)
    if archivo.suffix.lower() not in {".html", ".js", ".json", ".sql", ".yml", ".yaml", ".md", ".py"}:
        continue
    try:
        texto = archivo.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        continue
    for tipo, patron in [
        ("clave_secreta", r"sb_secret_[A-Za-z0-9_-]{12,}"),
        ("clave_privada", r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
        ("contrasena_sql_literal", r"\bcrypt\(\s*'[^']{4,}'\s*,\s*gen_salt"),
    ]:
        for match in re.finditer(patron, texto):
            hallazgos.append((nombre, texto.count("\n", 0, match.start()) + 1, tipo))
    for match in re.finditer(r"eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+", texto):
        try:
            payload = match.group().split(".")[1]
            datos = json.loads(base64.urlsafe_b64decode(payload + "=" * (-len(payload) % 4)))
        except (ValueError, UnicodeError):
            continue
        if datos.get("role") == "service_role":
            hallazgos.append((nombre, texto.count("\n", 0, match.start()) + 1, "jwt_privilegiado"))
for nombre, linea, tipo in hallazgos:
    print(f"{nombre}:{linea}: {tipo} (valor omitido)")
print(f"Revision de patrones: {len(hallazgos)} hallazgos. No cubre el historial ni prueba vigencia de credenciales.")
sys.exit(bool(hallazgos))
