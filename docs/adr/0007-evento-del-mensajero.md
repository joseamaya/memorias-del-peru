# ADR-0007 — Evento del mensajero: máquina de estados y progreso garantizado

- Estado: Aceptado
- Fecha: 2026-11-10
- Decisión delegada por el usuario y confirmada en la sesión de trabajo del 2026-11-10

## Contexto

El vertical slice necesita un evento narrativo con inicio y cierre. La primera implementación lo disparaba solo con el pututu: si el jugador no lo tocaba, la experiencia no terminaba. Eso convierte un interactuable opcional en un bloqueo de progreso, que la métrica 4 de [docs/01](../01_vision_y_alcance.md) §5 prohíbe.

Además hay que definir la secuencia, el comportamiento de los personajes, el estado de “un solo uso por partida”, el final de la experiencia y el audio, sin introducir un sistema de misiones ni de guardado.

## Opciones consideradas

1. **Solo el pututu dispara el evento.** Coherente con “el pututu convoca”, pero deja la experiencia sin final si el jugador no interactúa. Rechazada.
2. **Solo un temporizador.** Garantiza el final, pero el evento puede ocurrir mientras el jugador explora lejos y no lo ve. Rechazada.
3. **Zona de disparo con temporizador de respaldo.** El evento empieza cuando el jugador entra en la plaza o, si no entra, tras un tiempo máximo. El pututu convoca la reunión y abre el cierre; si el jugador no lo toca, lo toca el curaca. Aceptada.

## Decisión

Opción 3.

### Máquina de estados

| Fase | Entra cuando | Ocurre |
|---|---|---|
| `IDLE` | inicio de la partida | el mensajero espera fuera del camino norte; el pututu existe pero no dispara el evento |
| `ARRIVAL` | el jugador entra en el área de la plaza **o** pasan `arrival_timeout` segundos | el mensajero corre hasta la plaza; el resto de NPC giran hacia él |
| `MESSAGE` | el mensajero llega | subtítulo de la noticia; el curaca y los hombres principales convergen; se muestra el aviso del pututu |
| `CALL` | termina `MESSAGE` | el jugador puede tocar el pututu; al agotarse `call_timeout`, lo toca el curaca |
| `DEPARTURE` | suena el pututu | el grupo parte hacia el norte; subtítulo de cierre |
| `DONE` | el grupo sale del área | la plaza queda vacía; se emite `finished`; el jugador sigue libre |

### Parámetros

Ajustables sin ADR nuevo, porque no cambian la decisión:

| Parámetro | Valor inicial |
|---|---|
| Radio del área de llegada | 22 m desde el centro de la plaza |
| `arrival_timeout` | 120 s |
| `call_timeout` | 60 s |
| Velocidad del mensajero | 5,2 m/s |
| Velocidad de la comitiva | 3,2 m/s |

### Reglas

- El estado es un `enum Phase` y solo avanza; las llamadas repetidas son idempotentes (`start()` durante `ARRIVAL` no reinicia nada).
- Señales: `started`, `phase_changed(phase)`, `finished`. El evento no conoce el HUD ni el jugador; la escena del mundo conecta las señales.
- El pututu emite `played`; el evento lo escucha durante `CALL`. Se registra `pututu_by_player: bool` para pruebas y telemetría, pero la experiencia nunca depende de él.
- El “un solo uso por partida” de la ofrenda y el pututu es un `bool` en memoria de cada interactuable. No hay sistema de guardado en el alcance ([docs/01](../01_vision_y_alcance.md) §4); serializarlo exigirá un ADR.
- El final no muestra pantalla de créditos ni fundido: la plaza vacía y el viento son el cierre.
- El tiempo se acumula en `step(delta: float)`, llamado desde `_process`, para que las pruebas puedan avanzar la máquina sin esperas reales.

### Ubicación

| Pieza | Ruta | Capa |
|---|---|---|
| Máquina de estados | `campaigns/01_pachacutec/scenes/world/messenger_event.gd` | campaña |
| Comportamiento de NPC | `campaigns/01_pachacutec/scenes/world/npc_actor.gd` | campaña |
| Subtítulos | `core/ui/hud.gd` (ADR-0006) | core |
| Efectos y ambiente | `AudioManager` (autoload) y `AudioStreamPlayer` en `EnvironmentAudio` | core / escena |

## Consecuencias

- La experiencia siempre termina, tanto si el jugador interactúa como si no.
- El pututu conserva sentido narrativo y deja de ser obligatorio.
- El evento es verificable con pruebas deterministas mediante `step()`.
- El comportamiento de los NPC se limita a desplazarse, orientarse y esperar; las animaciones reales llegan con los assets de Blender y no cambian esta máquina.
- Cualquier estado persistente, misión o rama narrativa exige un ADR nuevo.
