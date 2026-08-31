> [← App móvil · Modo Básico](07-App-Movil-Modo-Basico.md) · [Índice](00-Indice.md) · [Plan de Seguridad en la Circulación →](09-Plan-Seguridad-Circulacion.md)

# App móvil · Modo Avanzado

Es la app tradicional con wizard completo. Se accede desde el link **⚙ Modo Avanzado** del footer de la lite o directamente en [dvba_campo.html](https://lemeit.github.io/DVBA/app.html).

### Quién puede usarla

El Modo Avanzado es accesible para cualquier agente DVBA con usuario activo — no hay filtro por rol dentro de la app. Los perfiles habituales:

- **Técnico** de la División Técnica de zona (uso principal en relevamientos).
- **Capataz** — para reportar detalles del avance de una tarea asignada.
- **Jefe de la División Técnica** — cuando quiere clasificar directamente en campo lo que releva.
- **Jefes de otras divisiones** y **Jefe de Zona** — para acompañamientos u observaciones puntuales.
- **Admin** — con acceso pleno para pruebas y soporte.

Igual que en Modo Básico, cada registro cargado desde el celular queda automáticamente asignado a la zona del partido donde se sacó la foto, sin importar la zona del usuario que lo cargó. El sistema se encarga de rutearlo al jefe de la zona geográfica correspondiente, y guarda también quién cargó el registro (nombre + rol + zona en ese momento) para que la cola de aprobación de oficina muestre el origen de cada foto.

### Cuándo usarla

- Cuando el operario tiene fluidez con la app y quiere clasificar en el momento.

- Cuando el registro requiere datos que no se pueden completar en oficina (ej. testigo directo del incidente).

- Para editar un registro cargado previamente.

### Flujo de captura

1. **Elegir categoría** — Grilla de 10 iconos (Calzada · Drenaje · Estructura · Señalización · Demarcación · Iluminación · Entorno · Seguridad · Mantenimiento · Otro).

2. **Elegir tipo específico** — Dentro de la categoría. Ej. Calzada → Bache · Bache crítico · Pavimento fisurado · etc.

3. **Elegir estado** — El dropdown se puebla automáticamente con los estados válidos para esa categoría.

4. **Sub-atributos condicionales** — Si aplica: superficie (asfalto/hormigón/tierra…), modalidad (manual/mecánico/mixto). Si el nombre del tipo ya incluye la modalidad (ej. "Desmalezado mecánico"), el selector se oculta y el valor se guarda solo.

5. **Ruta / camino + progresiva** — Toggle RP / Camino secundario. Autocomplete inteligente. Progresiva con coma decimal formato oficial DVBA.

6. **Foto + GPS** — Sacar foto con la cámara del sistema. GPS se toma automático (con posibilidad de editar).

7. **Guardar** — Sube a Supabase o queda en cola offline. La foto se sube **sin sello**: el sellado se hace en oficina cuando se aprueba (workflow campo→oficina).

### Modo SOL (alto contraste)

Botón ☀ en el header. Aumenta el contraste y engrosa los botones para uso al aire libre bajo el sol directo.

> Complemento visual (capturas/paso a paso simplificado): [ver acá](Guia-Visual-Complementaria.md#uso-del-modo-avanzado)
