> [[07-App-Movil-Modo-Basico|← App móvil · Modo Básico]] · [[00-Indice|Índice]] · [[09-Plan-Seguridad-Circulacion|Plan de Seguridad en la Circulación →]]

# App móvil · Modo Avanzado

Es la app tradicional con wizard completo. Se accede desde el link **⚙ Modo Avanzado** del footer de la lite o directamente en [dvba_campo.html](https://lemeit.github.io/DVBA/app.html).

### Cuándo usarla

- Cuando el operario tiene fluidez con la app y quiere clasificar en el momento.

- Cuando el registro requiere datos que no se pueden completar en oficina (ej. testigo directo del incidente).

- Para editar un registro cargado previamente.

### Flujo de captura

1

Elegir categoría

Grilla de 10 iconos (Calzada · Drenaje · Estructura · Señalización · Demarcación · Iluminación · Entorno · Seguridad · Mantenimiento · Otro).

2

Elegir tipo específico

Dentro de la categoría. Ej. Calzada → Bache · Bache crítico · Pavimento fisurado · etc.

3

Elegir estado

El dropdown se puebla automáticamente con los estados válidos para esa categoría.

4

Sub-atributos condicionales

Si aplica: superficie (asfalto/hormigón/tierra…), modalidad (manual/mecánico/mixto). Si el nombre del tipo ya incluye la modalidad (ej. "Desmalezado mecánico"), el selector se oculta y el valor se guarda solo.

5

Ruta / camino + progresiva

Toggle RP / Camino secundario. Autocomplete inteligente. Progresiva con coma decimal formato oficial DVBA.

6

Foto + GPS

Sacar foto con la cámara del sistema. GPS se toma automático (con posibilidad de editar).

7

Guardar

Sube a Supabase o queda en cola offline. La foto se sube **sin sello**: el sellado se hace en oficina cuando se aprueba (workflow campo→oficina).

### Modo SOL (alto contraste)

Botón ☀ en el header. Aumenta el contraste y engrosa los botones para uso al aire libre bajo el sol directo.

════════════════════════════════════════════════════════════

> Complemento visual (capturas/paso a paso simplificado): [[Guia-Visual-Complementaria#Uso del Modo Avanzado|ver acá]]
