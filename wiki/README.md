# Wiki DVBA · Documentación del sistema SIG Vial PBA

Wiki interna del proyecto en **Obsidian** (edición local con vault + wikilinks) que se **publica como sitio web** con **MkDocs Material** (guía de usuario navegable con búsqueda + mockups CSS).

Fuente única, dos vistas:
- Local (Obsidian) para editar / vincular con `[[wikilinks]]`.
- Público (MkDocs → GitHub Pages) para técnicos, gerencia y cualquiera que quiera consultar el manual.

## Estructura de carpetas

```
wiki/
├── 00-Inicio.md                        ← landing interna (Obsidian)
│
├── 01-Guia-de-Usuario/                 ← ⭐ FUENTE PÚBLICA · lo que se publica
│   ├── 00-Indice.md
│   ├── 01-Que-es-el-sistema.md
│   ├── 02-Primeros-pasos.md
│   ├── … (14 capítulos numerados)
│   ├── Guia-Visual-Complementaria.md
│   └── index.md                        ← copia del índice como landing MkDocs
│
├── 02-Arquitectura-Tecnica/            ← interno · NO se publica
├── 03-Origen-e-Historia/               ← interno · NO se publica
├── 04-Desarrollo-y-Estado-Actual/      ← interno · NO se publica (bitácora)
├── 05-Roadmap-y-Proyecciones/          ← interno · NO se publica
├── 06-Decisiones-Tecnicas/             ← interno · NO se publica (ADRs)
├── 99-Informes-Gerenciales/            ← interno · NO se publica
│
├── stylesheets/
│   └── mockups.css                     ← CSS de los mockups de UI (frames, botones, etc.)
├── img/
│   └── logo_dvba_clean.png             ← logo para mockups (copia del datos/img/)
│
├── build.py                            ← convierte wikilinks Obsidian → markdown MkDocs
├── mkdocs.yml                          ← configuración del sitio (nav, tema Material, plugins)
├── README.md                           ← este archivo
│
└── docs/                               ← 🔄 GENERADO por build.py · NO EDITAR
    ├── 00-Indice.md                    (copia con wikilinks convertidos)
    ├── … (todas las notas de 01-Guia)
    ├── stylesheets/mockups.css         (copia de assets)
    └── img/logo_dvba_clean.png
```

**⚠ Importante:** editá SOLO en `01-Guia-de-Usuario/` (o carpetas internas). Todo lo que está en `docs/` se sobrescribe cada vez que corrés `build.py`.

## Flujo de trabajo

### 1. Editar

En Obsidian, abrí el vault (esta carpeta `wiki/`). Editá las notas de `01-Guia-de-Usuario/` con:
- `[[Nombre-de-nota]]` para linkear a otra nota
- `[[Nombre|Texto alternativo]]` para links con alias
- Markdown estándar (headings, listas, tablas, admonitions `!!! tip`, etc.)

Los mockups de la UI van embebidos como HTML dentro de `<div class="demo" markdown="0">…</div>` usando las clases de `stylesheets/mockups.css`.

### 2. Regenerar `docs/`

Cada vez que edités notas o assets:

```bash
cd wiki
python build.py --clean
```

Esto:
1. Borra `docs/` viejo.
2. Copia cada `.md` de `01-Guia-de-Usuario/` a `docs/`, convirtiendo `[[wikilinks]]` a `[texto](Nota.md)`.
3. Copia `stylesheets/` y `img/` a `docs/`.

### 3. Previsualizar local

```bash
mkdocs serve
```

Abrí `http://localhost:8000` — hot-reload al editar cualquier archivo.

### 4. Publicar

**Opción A · deploy manual** desde local (rápido):

```bash
mkdocs gh-deploy --force
```

Empuja `docs/` compilado a la rama `gh-pages` del repo.

**Opción B · GitHub Actions** (auto-deploy en cada `git push`):

Crear `.github/workflows/wiki-deploy.yml`:

```yaml
name: Deploy Wiki (MkDocs)
on:
  push:
    branches: [main]
    paths: ['wiki/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: '3.11'}
      - run: pip install mkdocs mkdocs-material pymdown-extensions
      - working-directory: wiki
        run: |
          python build.py --clean
          mkdocs build
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: wiki/site
          publish_branch: gh-pages
```

Después en el repo → Settings → Pages → Source: branch `gh-pages`.

## Requisitos

```bash
pip install mkdocs mkdocs-material pymdown-extensions
```

Python 3.9+. En Windows PowerShell usar `python` en vez de `python3`.

## Convenciones del sitio publicado

- **Numeración**: la da el prefijo del archivo (`01-…`, `02-…`) — reflejado en el sidebar por MkDocs. Los headings internos (`## Cómo se accede`) NO llevan número — evita duplicar.
- **Landing**: `index.md` (copia de `00-Indice.md`) se muestra al abrir la raíz del sitio.
- **Mockups**: usan CSS de `stylesheets/mockups.css`. Frame smartphone + headers app + badges GPS + grilla de categorías + preview foto + lista pendientes.
- **Wikilinks**: solo se usan en la fuente Obsidian. `build.py` los convierte a links markdown estándar antes de publicar.
- **Carpetas internas (`02-…` a `99-…`)**: NO están en el `nav` de mkdocs.yml, por lo tanto no se publican. Son documentación técnica interna que solo se ve en Obsidian.

## Contenido interno (fuera de la guía pública)

- `02-Arquitectura-Tecnica/` — diagramas del sistema, componentes, flujo de datos
- `03-Origen-e-Historia/` — contexto institucional, decisiones fundacionales
- `04-Desarrollo-y-Estado-Actual/` — bitácora cronológica del proyecto
- `05-Roadmap-y-Proyecciones/` — hoja de ruta, features planeadas
- `06-Decisiones-Tecnicas/` — ADRs (Architecture Decision Records)
- `99-Informes-Gerenciales/` — plantillas de informes oficiales DVBA
