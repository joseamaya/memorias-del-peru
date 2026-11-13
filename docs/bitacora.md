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
| Primera impresión (alcance v4.17) | Perfil Medio por defecto con SSAO y sin MSAA 2× (63 FPS en la GPU integrada), luz ambiental más baja, niebla más tenue, borde de la plaza fundido y cordillera lejana más contrastada; argumentos `--profile=N`, `--skip-intro` y `--spawn` (spawn, plaza o mirador) para iterar; aparición a 22 m de la plaza | `81ab4e5` |
| Objetivo en pantalla (alcance v4.17) | Línea de objetivo en el HUD que avanza con el quero, la ofrenda, la conversación, la llegada del mensajero, la llamada y la partida; `QueroChicha.drank`; textos narrativos acortados | `81ab4e5` |
| Suelo bajo los personajes (alcance v4.17) | Mancha de contacto radial bajo los nueve NPC, sin luz ni sombra propia | `81ab4e5` |
| Sesiones sin perfil forzado (alcance v4.17) | El registro de sesión anota el perfil activo en vez de imponer Bajo | `81ab4e5` |
| Mensajero por acción (ADR-0030, alcance v4.18) | Sale al completar las tareas cerca de la plaza, con respaldo a los 45 s y 20 s de espera; se le ve bajar por el camino del norte desde los 18 s; aviso de espera a los 20 s | `81ab4e5` |
| Museo a distancia (alcance v4.18) | Piel y ojos más mates; el vecino que recibe pasa a 10 m de la aparición; dos hombres principales conversan de perfil | `81ab4e5` |
