# ADR-0025 — Imágenes de fondo en la introducción

- Estado: Aceptado (pedido y aprobado por el responsable del proyecto el 2026-11-12)
- Fecha: 2026-11-12
- Amplía: [ADR-0023](0023-introduccion-del-slice.md) y [ADR-0024](0024-titulo-nota-historica-y-controles.md)

## Contexto

Con ADR-0023 y ADR-0024 la introducción son cuatro tarjetas de texto sobre fondo negro. El responsable del proyecto pidió imágenes de fondo que ayuden a entender la historia. Los juegos educativos de referencia acompañan así su prólogo; Attentat 1942, por ejemplo, usa imágenes de archivo.

Condiciones:

- ninguna imagen puede mostrar a los chancas, una guerra ni al inca saliendo del Cusco, para no adelantar las preguntas 1 y 2 del cuestionario (alcance §9.3);
- todo contenido histórico necesita ficha (docs/07 §3);
- no se añaden recursos de terceros ni contenido generado por IA sin un ADR propio.

## Opciones consideradas

1. **Tomas del propio juego.** Aceptada para el paisaje y la llacta: no hacen falta recursos ni licencias nuevas, el estilo es el del juego y se actualizan solas si el mundo cambia.
2. **Dibujos de Guamán Poma (1615, dominio público).** Rechazada por ahora: muchos muestran la ciudad colonial, iglesias o españoles, y habría que elegirlos y declararlos uno a uno como posteriores a 1532.
3. **Mapa propio.** Aceptada para la tarjeta del Cusco: explica el «dónde» mejor que el texto.
4. **Imágenes generadas con IA.** Rechazada: necesitarían su propio ADR, son difíciles de justificar históricamente y obligan a declararlas en tiendas.

## Decisión

### 1. Fondo de cada tarjeta

| Tarjeta | Fondo |
|---|---|
| Nota histórica | Negro, como en ADR-0024: es un aviso, no parte del relato |
| «Los Andes, siglo XV.» | Toma lenta del valle y de las montañas desde lo alto del suroeste |
| «En el valle del Cusco gobiernan los incas…» | Mapa esquemático propio (PCH-023) |
| «Tú vives en una llacta…» | Toma que baja por el camino sur hasta los ojos del jugador. Al terminar, la cámara del jugador toma el relevo sin corte |

- Sobre las tomas y el mapa, el texto va en el tercio inferior, sobre una franja oscura semitransparente. Sobre negro sigue centrado.
- Entre una tarjeta negra y una con imagen, el fondo se funde.

### 2. Dónde vive

- **`core/ui/intro_cards.gd`** acepta, por tarjeta, fondo negro o transparente y una capa propia (`set_overlay`), y emite `card_shown(index, seconds)`. Sigue sin conocer ninguna campaña.
- **Campaña:**
  - `scripts/world/intro_director.gd` tiene la cámara de la introducción y reproduce las tomas que le da el mundo;
  - `scripts/ui/intro_map.gd` dibuja el mapa en código, sin imágenes;
  - `mundo_base.gd` define los encuadres.
- **Toma final:** el encuadre del jugador se lee al empezar la toma, no al construir el mundo, porque hasta entonces su cámara no tiene la posición definitiva. Si se salta la última tarjeta, la cámara salta a ese encuadre antes de devolver el control.

### 3. El mapa

- Solo muestra el Cusco al norte, la llacta al sur, el camino que las une, un relieve de montañas dibujado y la flecha del norte.
- No marca territorios, fronteras, ríos ni pueblos vecinos.
- La llacta queda al sur porque en el juego el camino del norte es el que va al Cusco: lo dice el agricultor, y el mensajero llega por él.
- Rótulos: `PCH_MAP_CUSCO` «Cusco», `PCH_MAP_LLACTA` «Tu llacta» y `PCH_MAP_NORTH` «N».

## Consecuencias

- **Ficha nueva PCH-023 «Mapa de la introducción»** (R / N). No afirma nada documentado más allá de PCH-006 («cerca del Cusco»), pero docs/07 §3 exige que esté verificada para cerrar la Fase 4.
- **Pruebas:**
  - fondos por tarjeta (negro, transparente y con capa) y la señal `card_shown`;
  - cámara de la introducción activa durante las tarjetas, mapa como capa de la tarjeta del Cusco, y cámara del jugador activa y en el mismo encuadre al terminar.
- **Rendimiento:** las tomas renderizan el mundo durante unos 15 s de introducción, con el mismo coste que el juego. El rendimiento del juego no cambia, porque la cámara de la introducción deja de usarse al terminar.
- **Alcance v4.7** (§2.2 y §6.4).
