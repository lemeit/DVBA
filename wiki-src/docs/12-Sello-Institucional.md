> [← Módulo Reportes (dashboard gerencial)](11-Reportes-Dashboard-Gerencial.md) · [Índice](00-Indice.md) · [Modo offline y sincronización →](13-Modo-Offline.md)

# Sello institucional v4

Todas las fotos que llegan al sistema se sellan con un banner institucional que las hace **trazables e identificables**. El diseño del sello es idéntico ya sea que la foto venga del campo (sellada al aprobar) o de la subida directa desde partes_diarios.

### Layout de 3 columnas

Izquierda

Logo institucional DVBA en círculo, con fallback a "DVBA" en dorado sobre negro si el logo no carga.

Centro

Localidad · Ruta y km · Tipo de tarea · Lat/Lng (+altitud) · Fecha y hora · Marca de versión.

Derecha

QR code que apunta a Google Maps con las coordenadas exactas. Escaneable desde cualquier celular para abrir la ubicación.

### Trazabilidad

El pie del sello incluye una línea con la versión del sistema y el origen (`vX.YY · campo` o `vX.YY · oficina`), lo que permite auditar cuándo y cómo se estampó cada foto.

### Anti-sobresello

Si una foto ya estampada se vuelve a sellar (por ejemplo tras corregir datos), el sistema detecta el banner viejo, lo corta y aplica el nuevo con la misma métrica. Resultado: el usuario ve la foto sin banners duplicados.

📷

Screenshot:

ejemplo de foto sellada con las 3 columnas visibles.
