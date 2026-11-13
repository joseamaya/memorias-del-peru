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
| Primera impresión (alcance v4.17) | Perfil Medio por defecto con SSAO y sin MSAA 2× (63 FPS en la GPU integrada), luz ambiental más baja, niebla más tenue, borde de la plaza fundido y cordillera lejana más contrastada; argumentos `--profile=N`, `--skip-intro` y `--spawn` (spawn, plaza o mirador) para iterar; aparición a 22 m de la plaza | `0b2fe00` |
| Objetivo en pantalla (alcance v4.17) | Línea de objetivo en el HUD que avanza con el quero, la ofrenda, la conversación, la llegada del mensajero, la llamada y la partida; `QueroChicha.drank`; textos narrativos acortados | `0b2fe00` |
| Suelo bajo los personajes (alcance v4.17) | Mancha de contacto radial bajo los nueve NPC, sin luz ni sombra propia | `0b2fe00` |
| Sesiones sin perfil forzado (alcance v4.17) | El registro de sesión anota el perfil activo en vez de imponer Bajo | `0b2fe00` |
| Mensajero por acción (ADR-0030, alcance v4.18) | Sale al completar las tareas cerca de la plaza, con respaldo a los 45 s y 20 s de espera; se le ve bajar por el camino del norte desde los 18 s; aviso de espera a los 20 s | `0b2fe00` |
| Museo a distancia (alcance v4.18) | Piel y ojos más mates; el vecino que recibe pasa a 10 m de la aparición; dos hombres principales conversan de perfil | `0b2fe00` |
| Validación por el autor (ADR-0031, alcance v4.19) | La métrica 5 de audiencia queda declarada «no verificada»; la Fase 4 se valida con tres pasadas registradas, cuestionario escrito y umbrales medibles; se conserva el registro de sesión para una futura demo pública | — |
| Autovalidación del 2026-11-13 (AUTO-1 a AUTO-4) | Comprensión superada (preguntas 1 y 2 correctas), primera interacción en 10,9–13,8 s y cero bloqueos; AUTO-4 cierra sin errores y confirma el aviso en el mirador. No superada la duración: 121,2 s (2,0 min) frente a 4–10. Registro en [sesiones/](../campaigns/01_pachacutec/documentation/sesiones/autovalidacion-2026-11-13.md) | — |
| Objetivo del mirador (ADR-0032, alcance v4.20) | Cuarto objetivo entre la conversación y la espera; el aviso «El sol sube…» se emite al llegar al mirador y la llegada se pide desde allí, con respaldo a 80 s + 20 s | — |
| Cierre sin fugas de audio | Se pausa el árbol antes del barrido, se sueltan los flujos de los reproductores y el drenaje pasa a 250 ms; probado con el mundo cargado y audio sonando, sin fugas al salir | — |
| Duración del slice y cierre de la Fase 4 (ADR-0033, alcance v4.21) | La duración comprometida pasa a 2–3 min en ruta directa (medido: 121,2 s en AUTO-4); se cierra la Fase 4 y se etiqueta `v0.1`; el horizonte de 10–15 min queda para la campaña completa | `7ae8dbf` |
| Pasada de materiales (posterior a v0.1) | Suelo con manchas macro y menos grava, escalas de detalle por capa, corrección de color por clase (piedra y cal), relieve a 1.0, tercios de cordillera y nubes más altas; herramienta `tests/capture_views.gd`; SSIL probado en Medio y descartado (50 FPS) | `472f77e` |
| Piedra plana en casas y muros (posterior a v0.1) | `rough_stone` y `StoneWall._add_stone` pasan de cara abombada con pico a cara plana con bisel; juntas más finas, menos saliente y contorno más angular; regeneradas `pch_house_a/b/c.glb` con menos triángulos que antes (18 183 / 13 304 / 10 017). Capturas en `build/capturas/`; medición de rendimiento pendiente con el equipo descargado | — |
| Museo explorable (ADR-0034, alcance v5.0) | Nueve estaciones con «Observar» y marcador de piedra, tarjeta de Core con sello y fuente, contador y brújula; el evento sale tras cinco estaciones con el mirador. La cadena de objetivos anterior queda sustituida; el quero y la ofrenda conservan su interacción | — |
| Tour libre (ADR-0035, alcance v5.1) | Estela de piedra a la altura del pecho con colisionador de 1,7 m; sin umbral de cinco estaciones; el evento sale al observar el mirador (respaldo 360 s); brújula oculta salvo con Q o tres segundos tras observar; objetivo neutro y contador n/9; acción `guide` en el Input Map | — |
| Leer en el mundo (ADR-0036, alcance v5.2) | Se eliminan estelas, contador, brújula y la acción Q; las nueve tarjetas se abren con zonas invisibles y con las señales del quero y la ofrenda; el mirador dispara el evento. El HUD no guía antes del evento | — |
| Sensación de lugar | Sol más bajo y cálido, polvo en suspensión con textura radial y rutas más largas de los tres vecinos, con pausas en casas y plaza | — |
| Instrumentación de lectura (ADR-0037) | El registro de sesión marca cada tarjeta abierta (`spot`) y cerrada (`spot_closed`), para medir la duración del museo sin cronómetro manual; nueva prueba que abre las nueve tarjetas en orden | — |
