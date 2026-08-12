# Wiki MkDocs · Experimento paralelo al Quartz actual

Prueba de **MkDocs Material** como alternativa a Quartz para la Guía de Usuario.
No toca el `DVBA-wiki` que ya está publicado en `lemeit.github.io/DVBA-wiki/` — es
un experimento para comparar antes de decidir cuál va como link final.

## Diferencias contra Quartz

|                | Quartz (actual)                        | MkDocs Material (experimento) |
|----------------|----------------------------------------|-------------------------------|
| Público objetivo | Digital gardens con grafo             | Guías / docs lineales |
| Wikilinks      | Nativos `[[Nota]]`                     | Requiere conversión a markdown estándar |
| Navegación     | Backlinks + grafo + sidebar            | Sidebar jerárquico + tabs + TOC integrado |
| Búsqueda       | Client-side (Fuse.js)                  | Client-side (lunr con highlight) |
| Instalación    | Node + Quartz build                    | Python + `pip install mkdocs-material` |
| Personalización| CSS + componentes React (complejo)    | YAML declarativo + CSS ad-hoc |
| Renderizado    | React con hidratación                  | HTML estático puro |
| Peso final     | ~600 KB por página (React runtime)     | ~100 KB por página (HTML plano) |
| Modo oscuro    | Sí                                     | Sí (auto según sistema) |

## Estructura de este experimento

```
wiki-mkdocs-experimento/
├── build.py         # Convierte wiki/01-Guia-de-Usuario/*.md → docs/ (wikilinks → md links)
├── mkdocs.yml       # Configuración del sitio + tema Material
├── docs/            # (generado) Fuente lista para mkdocs
│   ├── 00-Indice.md
│   ├── 01-Que-es-el-sistema.md
│   ├── ... (14 notas)
│   ├── Guia-Visual-Complementaria.md
│   └── index.md
└── README.md        # Este archivo
```

## Cómo probarlo (local)

Requisitos: Python 3.9+, pip.

```bash
# 1. Instalar dependencias (solo la primera vez)
pip install mkdocs mkdocs-material pymdown-extensions

# 2. Regenerar los .md desde la wiki original (opcional si ya está en docs/)
cd wiki-mkdocs-experimento
python build.py            # o `python build.py --clean` para regenerar de cero

# 3. Preview local (http://localhost:8000)
mkdocs serve

# 4. Build estático para publicar
mkdocs build               # genera ./site/
```

## Cómo publicar (dos opciones)

### Opción A · Deploy manual desde local

```bash
mkdocs gh-deploy --force
```

Esto crea/actualiza la rama `gh-pages` del repo actual. Configurable en
`mkdocs.yml` con `site_url` para el subpath correcto.

### Opción B · GitHub Actions (auto-deploy en cada push)

Crear `.github/workflows/mkdocs-experimento.yml` en el repo padre:

```yaml
name: Deploy MkDocs Experimento
on:
  push:
    branches: [main]
    paths: ['wiki-mkdocs-experimento/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: '3.11'}
      - run: pip install mkdocs mkdocs-material pymdown-extensions
      - working-directory: wiki-mkdocs-experimento
        run: mkdocs build
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: wiki-mkdocs-experimento/site
          publish_branch: gh-pages-mkdocs
          destination_dir: mkdocs-experimento
```

Después habilitar GitHub Pages desde branch `gh-pages-mkdocs` → subpath `/mkdocs-experimento/`.

## Sincronización con la wiki de Obsidian

La wiki de Obsidian está en `../wiki/` (gitignored, editada en Obsidian localmente).
Cuando actualices notas en Obsidian, correr:

```bash
python build.py --clean
```

Y `docs/` se regenera con los wikilinks convertidos. Después `mkdocs serve` o
`mkdocs build`.

## Qué comparar contra Quartz

1. **Legibilidad** — ¿se lee más cómodo? ¿Encoder Sans institucional se usa bien?
2. **Navegación** — sidebar + tabs vs Quartz grafo/backlinks: ¿cuál es más rápida para técnicos/gerencia?
3. **Búsqueda** — probar términos: "sello", "modo básico", "zona V" — ver relevancia.
4. **Modo móvil** — abrir en el celular ambas versiones: ¿cuál es más usable?
5. **Peso/velocidad** — DevTools Network en cada sitio: primer paint + tamaño total.
6. **Mantenimiento** — Quartz requiere Node build (más frágil), MkDocs solo Python (más simple).

## Decisión final

Después de comparar, tres opciones:

- **Quedar con Quartz** — si el grafo/backlinks aportan valor y la estética engancha.
- **Migrar a MkDocs Material** — si la guía es más lineal y prevalece la simplicidad.
- **Coexistir** — Quartz para navegación exploratoria + MkDocs para consulta rápida.
  (Cambiar `link` en el README del proyecto según el uso.)

## Notas técnicas

- El script `build.py` NO modifica los .md originales de `../wiki/` — solo los copia
  y convierte a `./docs/`.
- Los `[[wikilinks|Alias]]` se convierten preservando el texto alias visible.
- Los enlaces relativos a imágenes / assets no se procesan (heredan tal cual).
- Si Obsidian usa embeds `![[Imagen.png]]`, hay que agregar al regex del build.py
  (por ahora no se detectaron embeds en las 14 notas).
