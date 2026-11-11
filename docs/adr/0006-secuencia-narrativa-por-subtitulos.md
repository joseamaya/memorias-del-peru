# ADR-0006 — Secuencia narrativa por subtítulos

- Estado: Aceptado
- Fecha: 2026-11-10
- Decisión delegada por el usuario y confirmada en la sesión de trabajo del 2026-11-10

## Contexto

La métrica 5 de [docs/01](../01_vision_y_alcance.md) §5 exige que 4 de 6 jugadores de prueba expliquen, con sus palabras, quién amenaza el Cusco y qué hace la élite. El vertical slice no tiene voces y, según [docs/02](../02_arquitectura.md) §6, el diálogo es un sistema reservado a una fase posterior con su propio ADR.

El texto de interacción del HUD no sirve para narrar: solo se muestra mientras el jugador apunta a un objeto. Sin otro vehículo, la información histórica no llega al jugador y la métrica 5 no puede cumplirse.

## Opciones consideradas

1. **Sistema de diálogo con opciones.** Permite caracterizar personajes, pero exige retratos, ramas, estados y un ADR de sistema nuevo; además introduce decisiones que el alcance excluye expresamente.
2. **Texto diegético en el mundo (`Label3D`).** Se lee mal a distancia, no permite cola de mensajes, compite con la escena y dificulta la traducción.
3. **Narración de voz.** Requiere voces, casting, grabación y licencias; el alcance de la fase excluye voces.
4. **Subtítulos temporizados en el HUD.** Un texto breve, localizado, con duración propia y sin interacción: cuenta lo mínimo (amenaza y respuesta) sin añadir sistemas de decisión.

## Decisión

Opción 4.

- **Widget:** `core/ui/hud.tscn` incorpora un `Label` de subtítulos y `core/ui/hud.gd` expone `show_subtitle(text: String, seconds: float)` y `clear_subtitle()`. Es UI genérica: no conoce la campaña.
- **Secuencia:** los textos y sus tiempos viven en la campaña, en `campaigns/01_pachacutec/scenes/world/narrative_beats.tscn` (recurso con las claves y duraciones). La escena del mundo conecta el evento con el HUD; ni el HUD ni el evento se conocen entre sí.
- **Textos:** claves en `campaigns/01_pachacutec/localization/pachacutec_texts.csv` (`PCH_NARR_*`), obtenidas con `tr()`.
- **Reglas:** un subtítulo a la vez; uno nuevo reemplaza al anterior; máximo dos líneas; se oculta solo; no pausa el juego, no bloquea la entrada y no ramifica.
- **Accesibilidad:** al no haber voces, los subtítulos están siempre activos y no se pueden desactivar en esta fase.

## Consecuencias

- `core/ui` gana un widget reutilizable por cualquier campaña; la secuencia concreta no se filtra a `core/`.
- Cualquier texto con opciones, avance manual o retrato exige un ADR nuevo: este ADR no autoriza un sistema de diálogo.
- La métrica 5 pasa a depender de dos textos concretos, que se fijan en el alcance del vertical slice y se auditan con las pruebas del evento.
- Riesgo aceptado: un jugador que ignore la pantalla puede perder el mensaje. Se mitiga repitiendo el subtítulo de la noticia una vez y con el aviso del HUD sobre el pututu.
