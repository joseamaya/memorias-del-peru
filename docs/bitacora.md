# Bitácora de cambios

Registro cronológico de los cambios que **no** llegan al umbral de un ADR: contenido, presentación, textos, instrumentación y correcciones menores. Una fila por entrega, con la fecha y el commit.

El criterio para decidir entre bitácora y ADR está en [adr/README.md](adr/README.md): si revertir cuesta menos de una hora y no cambia contratos de Core, dependencias, licencias ni arquitectura, va aquí.

La bitácora **no es una fuente de verdad**: no crea reglas ni prevalece sobre `docs/00`–`08`, los ADR o `AGENTS.md` ([AGENTS.md](../AGENTS.md) §1). El historial anterior a su creación sigue en la tabla de versiones de [alcance_vertical_slice.md](../campaigns/01_pachacutec/documentation/alcance_vertical_slice.md).

## 2026-11-13

| Cambio | Detalle | Commit |
|---|---|---|
| Realismo visual y de personajes (alcance v4.13–v4.14) | Nubes altas, cordillera lejana, niebla y luz más cálida; manos en primera persona; puertas de tablones y paja envejecida | `8c2efbd` |
| Mantos y llicllas (alcance v4.15) | Post-proceso de los GLB para cerrar la apertura lateral y añadir un pliegue suave | `3980c09` |
| Medición y vídeos | Rendimiento final con los personajes procesados y vídeos regenerados | `66bef8c` |
| Registro de sesiones de prueba (alcance v4.16) | Argumento `--session`, marcas de tiempo e incidencias de consola | `aadc58a` |
| Política de ADR y bitácora | Umbral de ADR, límite de extensión y este registro | — |
