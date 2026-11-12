# ADR-0023 — Introducción del vertical slice

- Estado: Aceptado (textos aprobados por el responsable del proyecto el 2026-11-12)
- Fecha: 2026-11-12
- Sustituye en parte: [ADR-0012](0012-ajustes-tras-el-primer-piloto.md) §B (el rótulo de lugar y época pasa a la introducción)
- Desviación declarada de: [docs/01](../01_vision_y_alcance.md), pilar «Narrativa ambiental» («sin texto explicativo»)

## Contexto

La primera persona del piloto ([ADR-0012](0012-ajustes-tras-el-primer-piloto.md)) resumió su partida con «no se entiende nada». No sabía dónde estaba ni qué lugar era, y solo percibía que era «la época inca». ADR-0012 añadió el rótulo «Una llacta de la sierra, cerca del Cusco · siglo XV» y una frase de apertura. Sigue sin explicarse:

- qué es el Cusco ni quiénes son los incas en ese momento;
- qué es una llacta;
- quién es el jugador y qué relación tiene su aldea con el Cusco.

Quien no conozca la historia andina llega a la noticia del mensajero sin el marco necesario para entenderla. El responsable del proyecto pidió una introducción antes de las sesiones con jugadores (2026-11-12).

**Lo que la introducción no puede hacer.** Las sesiones miden si el juego transmite la noticia (métrica 5, [alcance](../../campaigns/01_pachacutec/documentation/alcance_vertical_slice.md) §2.1 y §9.3). Las preguntas 1 y 2 piden quién amenaza al Cusco y qué hacen el inca y su heredero. Si la introducción lo contara, el cuestionario mediría la introducción y no el juego.

## Opciones consideradas

1. **Sin introducción; probar antes con la segunda persona del piloto.** Rechazada: el problema ya se observó en el primer piloto, y gastar el segundo en confirmarlo retrasa las sesiones sin aportar datos nuevos. El segundo piloto comprobará esta introducción.
2. **Introducción que cuente también la amenaza chanca.** Rechazada: invalida las preguntas 1 y 2 del cuestionario.
3. **Introducción que sitúe sin adelantar la noticia.** Aceptada.
4. **Menú principal o códice con el contexto.** Rechazada: el menú corresponde a `core/` cuando exista el selector de campañas (docs/05, Fase 1), y el códice está fuera de alcance (alcance §12).

## Decisión

### 1. Textos

Tres tarjetas, antes de que el jugador tome el control:

| Clave | Texto | Clasificación | Ficha |
|---|---|---|---|
| `PCH_INTRO_1` | Los Andes, siglo XV. | H | PCH-022 |
| `PCH_INTRO_2` | En el valle del Cusco gobiernan los incas. Todavía no son un imperio: son el señorío más fuerte de la región. | A / R | PCH-022 |
| `PCH_INTRO_3` | Tú vives en una llacta, una pequeña aldea de la sierra cerca del Cusco. Hoy se esperan noticias. | R | PCH-006 |

- Sin año exacto, por la misma razón que ADR-0012: la fecha de la guerra chanca es discutida (1438 es la cronología de Rowe).
- Ninguna tarjeta menciona a los chancas, una amenaza, al inca gobernante, a su heredero ni a Cusi Yupanqui.
- `PCH_TITLE_PLACE` deja de mostrarse: lugar y época pasan a las tarjetas 1 y 3. `PCH_NARR_OPENING` se mantiene como primer subtítulo de juego.

### 2. Presentación

- Fondo negro, texto centrado con la letra de los subtítulos (ADR-0012 §A), fundido de entrada y de salida.
- Cada tarjeta dura su tiempo de lectura con la regla de ADR-0012: largo ÷ 13 caracteres por segundo + 1,5 s, con un mínimo de 4 s.
- La acción `interact` pasa a la tarjeta siguiente; una indicación discreta lo dice. No hay forma de saltarse la introducción entera de golpe, para que nadie la omita sin querer en las sesiones.
- Durante la introducción el jugador no se mueve ni mira, y **el reloj del mensajero no corre**: empieza al terminar la última tarjeta.
- La introducción se muestra también al reiniciar con R.
- Solo se muestra cuando el mundo es la escena principal: en la partida real y al reiniciar. Las pruebas que cargan el mundo directamente no la ven, salvo que la fuercen (`intro_mode`), como hace `demo_playthrough.gd`.

### 3. Dónde vive

- **`core/ui/`:** un componente genérico de tarjetas de texto, sin claves ni textos de ninguna campaña. Recibe la lista de textos y emite una señal al terminar.
- **`campaigns/01_pachacutec/`:** las claves, el orden y la conexión con el arranque de `mundo_base.gd` y con el reloj del evento.

Así `core/` sigue sin depender de `campaigns/` (AGENTS.md §3).

### 4. Ficha nueva: PCH-022

«El Cusco antes de la expansión inca», clasificación A / R. Fuente candidata: Covey, Quave y otros (2025), *Antiquity* 99, ya citada y verificada en PCH-006 para otros datos. Hay que localizar en ese artículo el pasaje que sostiene que, antes de la expansión, el Cusco era un estado regional y no un imperio, y citarlo con página. Mientras no esté verificada, PCH-022 bloquea el cierre de la Fase 4 (docs/07 §3).

## Consecuencias

- **Alcance v4.5:** secuencia (§2.2, nueva fase previa a `IDLE`), textos (§6.4), duración (§10) y la nota de que el rótulo de ADR-0012 se sustituye.
- **Protocolo de sesiones:** el facilitador sigue sin explicar la historia (§9.2). El inicio de la medición pasa a ser el comienzo de la introducción, y se anota aparte el momento en que termina, para separar su tiempo del de juego. Hay que actualizar el [guion del facilitador](../../campaigns/01_pachacutec/documentation/guion_facilitador.md).
- **Duración:** la introducción suma unos 20 s (tres tarjetas de 4–9 s). Acerca la mediana estimada (4–6 min) al mínimo de 5 min del objetivo.
- **docs/01:** el pilar «sin texto explicativo» se mantiene para el resto del juego; esta es la única excepción, y queda declarada aquí.
- **Pruebas nuevas:**
  - el componente de tarjetas muestra los textos en orden, con la duración de lectura, y `interact` avanza;
  - el reloj del mensajero no avanza durante la introducción;
  - ninguna clave de la introducción contiene «chanca», «heredero» ni «Cusi Yupanqui»;
  - `demo_playthrough.gd` pasa por la introducción antes de moverse.
- **Segunda persona del piloto:** comprueba la introducción antes de las sesiones oficiales. Su resultado puede pedir ajustar los textos.
- El responsable del proyecto debe aprobar el tono y la redacción de las tres tarjetas antes de implementarlas.
