> [← Reportes de Red Vial Provincial](10-Reportes-Red-Vial.md) · [Índice](00-Indice.md) · [Sello institucional v4 →](12-Sello-Institucional.md)

# Módulo Reportes (dashboard gerencial)

Módulo escritorio (`reportes.html`) accesible desde el link 📊 **Reportes** del header. **Solo visible para roles gerencia y admin**. Distinto del panel de reportes del portal (sección 7), este módulo consolida *relevamientos + partes diarios + vehículos* con dashboard gerencial y charts.

### Contenido

4 KPIs

Total km · tareas ejecutadas · partidos activos · categorías intervenidas.

4 charts

Km por tarea (paleta oficial 8 colores) · Timeline mensual (5 meses + tendencia) · Uso de vehículos · Acciones por vía.

Filtros en vivo

Fecha desde/hasta · zona · partido · RP/camino · tarea. Debounce para no recalcular en cada tecla.

Tabla

Fecha · tarea · vía · partido · km · equipos · foto ✓/✗. Ordenable, filtrable.

### Exports

- **CSV** · headers oficiales, todas las filas filtradas.

- **PDF institucional** · portada + página de charts + tabla completa. Layout cotejado contra el Informe Mensual Gerencia Ejecutiva (paleta oficial de 8 colores).

!!! note "📷 Screenshot:"
    vista de Reportes con los 4 charts renderizados y filtros aplicados.
