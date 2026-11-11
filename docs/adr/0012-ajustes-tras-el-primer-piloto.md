# ADR-0012 — Ajustes tras el primer piloto

- Estado: Aceptado
- Fecha: 2026-11-11
- Sustituye en parte: [ADR-0006](0006-secuencia-narrativa-por-subtitulos.md) (reglas de los subtítulos) y [ADR-0009](0009-duracion-y-disparo-del-slice.md) (reloj del mensajero)

## Contexto

La primera persona del piloto (PIL-1, 2026-11-11) jugó el slice siguiendo el [guion del facilitador](../../campaigns/01_pachacutec/documentation/guion_facilitador.md). Su resumen:

- «No se entiende nada».
- Los textos se van muy rápido.
- Al inicio no hay nada que indique qué hacer; solo se siente que es la época inca.
- Con los personajes quietos no sabe qué lugar es; no parece el Cusco, sino «un poblado X».
- Se aburrió de no hacer nada.

En el juego:

- Todos los subtítulos duraban 6 s, fuera cual fuera su largo, y uno nuevo reemplazaba al anterior (ADR-0006). La noticia tiene 78 caracteres y la segunda frase llegaba a los 6 s.
- El juego nunca dice dónde estás. La llacta no es el Cusco, sino un poblado cercano, pero eso solo lo sabía quien leía el alcance.
- El mensajero llegaba a los 240 s (ADR-0009). Tras el quero y la ofrenda no quedaba nada que hacer.
- Los vecinos estaban plantados hasta la noticia.

El guion (§8) prevé justo esto: si alguien interpreta la espera como un fallo, se propone un ADR que acorte el reloj o añada señales. Si no se superan las preguntas 1 y 2, se revisan los textos.

## Opciones consideradas

1. Esperar a la segunda persona del piloto antes de cambiar nada. Rechazada: los cuatro problemas se ven en el código sin necesidad de más datos, y la segunda persona servirá para comprobar las correcciones.
2. Añadir un sistema de misiones o un indicador de objetivo. Rechazada: el alcance excluye las misiones y rompe la exploración libre.
3. Corregir legibilidad, orientación, espera y vida del poblado sin cambiar la estructura del evento. Aceptada.

## Decisión

**A. Subtítulos legibles** (sustituye las reglas de ADR-0006 sobre duración y reemplazo):
- Cada subtítulo dura lo que pide el evento, con un mínimo de 4 s y siempre el tiempo de lectura: largo ÷ 13 caracteres por segundo + 1,5 s. La noticia pasa de 6 a unos 8 s.
- Un subtítulo nuevo **espera su turno** en una cola de hasta 4, con una pausa de 0,3 s entre uno y otro, en lugar de reemplazar al visible. No se repite el mismo texto seguido.
- Letra más grande (30 px sobre una base de 1080 px) con contorno.
- Siguen vigentes las demás reglas de ADR-0006: sin pausa del juego, sin bloqueo de la entrada y sin ramificación.

**B. Orientación al empezar:**
- Un rótulo de lugar y época, con fundidos, durante 7 s: «Una llacta de la sierra, cerca del Cusco · siglo XV». Sin año exacto, porque la fecha de la guerra chanca es discutida.
- Nuevo texto de apertura, que da un propósito sin convertirlo en misión: «Hoy se espera a un mensajero del Cusco. Mientras llega, recorre la llacta y habla con su gente».

**C. Espera más corta y con algo que hacer** (sustituye el reloj de ADR-0009):
- `arrival_delay` pasa de 240 a **120 s** y `arrival_grace` de 120 a **60 s**: el mensajero sale como tarde a los 180 s.
- **Señal intermedia** a los 70 s: «El sol ya está alto. Por el camino del norte todavía no viene nadie».
- **«Hablar»** con la tejedora, el agricultor, el curaca y los tres vecinos: cada uno dice una sola frase, sin opciones, que sitúa la llacta y anticipa la noticia. Solo está disponible antes de la noticia (regla de disponibilidad de ADR-0008). El personaje se gira hacia el jugador, y si es un vecino se detiene unos segundos.

**D. Vida en el poblado:**
- Los tres vecinos pasean despacio (1,4 m/s) entre la plaza y las casas antes de la noticia, con una pausa en cada punto. Al llegar el mensajero se detienen y se vuelven hacia él.
- Siguen sin animación de piernas (alcance v3.3). Si el deslizamiento molesta en el piloto, el siguiente paso es el rig, con su propio ADR.

## Consecuencias

- El alcance pasa a v3.4: secuencia (§2.2), personajes (§5), textos (§6.4) y duración (§10).
- Las frases de los personajes son **licencia narrativa (N)**. La mención de los chancas «allá por Andahuaylas» se apoya en PCH-003. El responsable del proyecto debe revisar el tono.
- La duración baja. El objetivo de 5–8 min de ADR-0009 se mantiene como hipótesis y lo medirán las sesiones. Si queda corta, las conversaciones y el paseo son el sitio donde añadir contenido, no el reloj.
- La segunda persona del piloto comprueba estas correcciones antes de las sesiones oficiales. Su resultado puede pedir otro ajuste.
- Pruebas:
  - `test_subtitle_widget` cubre el tiempo de lectura, la cola y el rótulo.
  - `test_narrative_beats_order` incluye la señal intermedia.
  - `test_npc_talk_and_wander` cubre las conversaciones y el paseo.
  - `demo_playthrough.gd` habla con la tejedora.
