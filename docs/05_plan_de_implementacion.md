# 05 — Plan de implementación

**Fase activa:** Fase 8 — Arte, audio y cierre.
**Siguiente:** validación de autor del arco completo y pulido de personajes.

Reglas:

- No se inicia una fase mientras la anterior tenga errores críticos o criterios de aceptación incumplidos ([AGENTS.md](../AGENTS.md) §5).
- Cada fase tiene **precondiciones** (lo que debe ser cierto para empezarla) y **criterios de aceptación** (lo que debe ser cierto para cerrarla). Una precondición no es un criterio de la fase anterior: así ninguna fase depende de trabajo de la siguiente.
- Cada fase cierra con un informe de entrega (formato en [AGENTS.md](../AGENTS.md) §4) y la actualización de la tabla de estado.

## Estado

| Fase | Estado | Fecha de cierre |
|---|---|---|
| 0 — Documentación | Cerrada | 2026-11-10 |
| 1 — Fundación técnica | Cerrada | 2026-11-10 |
| 2 — Interacción | Cerrada | 2026-11-10 |
| 3 — Entorno | Cerrada | 2026-11-10 |
| 4 — Vertical Slice Pachacútec | Cerrada | 2026-11-13 |
| 5 — Museo explorable del Cusco | Superada | 2026-11-13 |
| 6 — Núcleo RPG y acto I | Cerrada | 2026-11-13 |
| 7 — Actos II y III en gris | Cerrada | 2026-11-13 |
| 8 — Arte, audio y cierre | En curso | — |

La Fase 4 cerró con la autovalidación del 2026-11-13 ([registro](../campaigns/01_pachacutec/documentation/sesiones/autovalidacion-2026-11-13.md)): comprensión, primera interacción, bloqueos y cierre sin errores superados; la duración se rebaseó a **2–3 min** con [ADR-0033](adr/0033-duracion-del-slice.md) tras medir 121,2 s. La métrica 5 de audiencia queda declarada «no verificada» ([ADR-0031](adr/0031-validacion-por-el-autor.md)). La pasada de materiales y el modelo Discovery Tour quedan fuera de esta fase.

---

## Fase 0 — Documentación

Entregables: `README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/00`–`08`, `docs/adr/` (ADR-0001 a 0003), documentación inicial de la campaña 01, `.gitignore`.

Criterios de aceptación:

- [x] El equipo revisó y aprobó los documentos.
- [x] Repositorio git inicializado con la documentación como primer commit.

**Criterio de suficiencia (cierre de las revisiones).** La Fase 0 no busca documentos perfectos, sino documentos sin contradicciones que bloqueen la Fase 1. Una vez aprobada:

- La documentación queda **congelada**. Solo cambia (a) mediante ADR, (b) al abrir una fase, para enumerar sus pruebas o concretar lo que esa fase necesita, o (c) al cerrar una fase, para reflejar lo que realmente se construyó.
- Una observación nueva sobre los documentos se clasifica así: si **bloquea la Fase 1**, se corrige antes de empezarla; si afecta a una fase posterior, se anota y se resuelve al abrir esa fase; si es solo de redacción, se corrige cuando se edite ese documento por otro motivo.
- No se hacen nuevas rondas de revisión completa de la documentación antes de la Fase 1.

---

## Fase 1 — Fundación técnica

### Precondiciones

- [x] Fase 0 cerrada.
- [x] Godot instalado y accesible como `godot` en el `PATH`.
- [x] ADR-0002 en estado “Aceptado” con la versión exacta registrada.
- [x] Indicadores de línea de comandos de [06_estrategia_de_pruebas.md](06_estrategia_de_pruebas.md) §2 confirmados con `godot --help` (y el documento corregido si difieren).

### Entregables

| # | Archivo | Descripción |
|---|---|---|
| 1 | `project.godot` | Según [04_configuracion_del_proyecto.md](04_configuracion_del_proyecto.md) |
| 2 | `core/autoload/game_manager.gd` | Mínimo: estado de pausa, `set_paused(paused: bool)`, `is_paused()`, señal `pause_changed` y la acción `pause` que alterna el estado (docs/02 §3–4) |
| 3 | `core/player/player_fps.gd` | Movimiento, cámara, reacción a la pausa, head bobbing |
| 4 | `core/player/player_fps.tscn` | Jerarquía según arquitectura §4 (incluye `InteractionRay` deshabilitado) y capas de colisión según docs/04 §7 |
| 5 | `tests/scenes/player_sandbox.tscn` | Escena de prueba (ver “Escena sandbox”) |
| 6 | `tests/run_tests.gd` + `tests/test_*.gd` | Validaciones automatizadas de Fase 1 |
| 7 | Documentación | README (controles), este plan, ADR si se toma alguna decisión nueva |

`InteractionRay` se incluye porque forma parte de la jerarquía obligatoria, pero queda con `enabled = false` hasta la Fase 2.

### Escena sandbox

Escena de **prueba**, no de juego. Contenido y medidas, para que los criterios sean reproducibles:

| Elemento | Medidas | Resultado esperado |
|---|---|---|
| Suelo | 40 × 40 m, capa `world` | El jugador se apoya y camina |
| Rampa A | Inclinación **30°** | El jugador la sube caminando y corriendo |
| Rampa B | Inclinación **50°** | El jugador **no** la sube (supera `floor_max_angle` = 45°, valor por defecto que se mantiene) |
| Paredes | 3 m de alto rodeando el suelo | El jugador no las atraviesa a ninguna velocidad |
| Plataforma | 2 m de altura con borde libre | Al salir del borde, el jugador cae por gravedad |
| Luz | `DirectionalLight3D` + `WorldEnvironment` sencillo | Visibilidad suficiente; no es el entorno final |

No se incluyen escalones: `CharacterBody3D` no los sube automáticamente y subir escalones no es requisito de la Fase 1.

### Escena principal (`application/run/main_scene`)

| Período | Escena principal | Motivo |
|---|---|---|
| Fases 1–2 | `res://tests/scenes/player_sandbox.tscn` | No existe todavía escena de juego |
| Desde Fase 3 | `res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn` | Primera escena de juego real; el sandbox sigue disponible como escena de prueba |
| Desde ADR-0024 (2026-11-12) | `res://core/ui/title_screen.tscn` | Las campañas no deben ser el punto de entrada de la antología. La pantalla de título abre la campaña configurada en `memorias/campaign/first`; el selector de campañas llegará con la segunda campaña |

El cambio de la Fase 3 es un criterio de aceptación de esa fase. Ninguna exportación distribuible se crea mientras la escena principal esté en `tests/`.

### Tareas en orden

1. Crear el proyecto desde el editor (Forward+); ajustar `project.godot` (ventana, renderizador, advertencias, Input Map, capas).
2. Crear `game_manager.gd` y registrarlo como autoload.
3. Crear `player_fps.tscn` con la jerarquía, la cápsula y las capas.
4. Implementar `player_fps.gd` por partes, validando tras cada una: movimiento → ratón/pitch → reacción a la pausa → head bobbing.
5. Crear la escena sandbox y fijarla como escena principal.
6. Escribir y ejecutar las pruebas automatizadas.
7. Verificación manual en ejecución ([06_estrategia_de_pruebas.md](06_estrategia_de_pruebas.md) §4).
8. Evaluar el escalonamiento del balanceo a alta frecuencia de refresco; decidir interpolación (ADR si se activa).
9. Informe de entrega.

### Valores iniciales propuestos (ajustables por `@export`)

| Parámetro | Valor | Unidad |
|---|---|---|
| Altura de cápsula / radio | 1.75 / 0.35 | m |
| Centro de la cápsula (origen a los pies) | 0.875 | m |
| Altura de `Head` (ojos sobre los pies) | 1.60 | m |
| `walk_speed` | 3.5 | m/s |
| `run_speed` | 6.5 | m/s |
| `acceleration` | 10.0 | m/s² |
| `deceleration` | 12.0 | m/s² |
| `mouse_sensitivity` | 0.15 | grados/píxel |
| `pitch_limit_degrees` | 80.0 | grados |
| `floor_max_angle` | 45 (por defecto del motor) | grados |
| Bobbing caminar: frecuencia / amplitud | 1.8 / 0.035 | Hz / m |
| Bobbing correr: frecuencia / amplitud | 2.6 / 0.06 | Hz / m |
| `bob_blend_speed` | 6.0 | 1/s |
| `bob_min_speed` | 0.1 | m/s |

### Criterios de aceptación

- [x] El proyecto abre en la versión fijada sin errores.
- [x] El motor reconoce todos los scripts (`class_name` registrados, sin errores de análisis).
- [x] El jugador camina y corre; la velocidad de carrera solo se aplica con Shift y entrada de movimiento.
- [x] Aceleración y desaceleración perceptibles (sin arranques ni frenazos instantáneos).
- [x] El movimiento es relativo a la orientación horizontal; mirar hacia arriba o abajo no altera la velocidad.
- [x] Sube la rampa de 30°, no sube la de 50°, no atraviesa paredes y cae desde la plataforma.
- [x] El ratón controla la cámara; pitch limitado a ±80°.
- [x] Escape libera el ratón y pausa; pulsar Escape de nuevo reanuda y recaptura el ratón (prueba automatizada de la lógica + verificación manual).
- [x] Head bobbing diferenciado caminar/correr, se detiene suavemente, sin saltos ni deriva.
- [x] Cero errores y cero advertencias de GDScript procedentes de `res://`.
- [x] Cero errores en consola durante la ejecución.
- [x] Pruebas automatizadas en verde.

**Verificación manual:** realizada por el usuario el 2026-11-10 a 60 Hz; los 10 puntos del checklist de [06_estrategia_de_pruebas.md](06_estrategia_de_pruebas.md) §4 pasaron. La interpolación de física sigue desactivada; el escalonamiento a frecuencias superiores a 60 Hz queda sin evaluar y no bloquea la fase.

**Corrección posterior (2026-11-10):** se corrigieron la altura de ojos (la cápsula estaba centrada en el origen y elevaba la cámara a 2,475 m) y el salto lateral del balanceo al envolver la fase en `TAU`. Ambas correcciones tienen prueba automatizada (`test_player_eye_height`, `test_head_bob_max_step`).

**Verificación manual del balanceo:** realizada por el usuario el 2026-11-10; el balanceo es suave, sin salto lateral, caminando y corriendo.

---

## Fase 2 — Interacción

### Precondiciones

- [x] Fase 1 cerrada.
- [x] ADR-0003 aceptado (o reemplazado).
- [x] Ficha PCH-004 (quero) y PCH-005 (chicha) con fuentes identificadas, aunque no estén verificadas aún.

### Entregables

Primera tarea: enumerar las pruebas de la fase en docs/06 §3.

`core/interaction/interactable.gd`; cambios en `player_fps.gd` (`InteractionRay` activo, detección, señales de enfoque, llamada a `interact`, reglas de carrera con estamina de docs/02 §5); `StaminaComponent` añadido como hijo en `player_fps.tscn`; indicación de interacción en UI (`core/ui/`); `core/systems/stamina/stamina_component.gd` según el contrato de docs/02 §5 (incluido el consumo al correr); `AudioManager` mínimo; tabla de textos de Core y de la campaña (docs/02 §7); `campaigns/01_pachacutec/scenes/objects/quero_chicha.tscn` y `scripts/interactions/quero_chicha.gd`.

Comportamiento del quero: enfoque → indicación → E → respuesta visual (animación) → sonido → recuperación de estamina configurable → UI actualizada por señal.

### Criterios de aceptación

- [x] Un objeto nuevo se vuelve interactuable sin modificar `player_fps.gd`.
- [x] La detección funciona cuando el collider es hijo (directo o indirecto) del interactuable.
- [x] No se interactúa a través de paredes.
- [x] La estamina se actualiza y la UI lo refleja vía señales.
- [x] El quero no contiene rutas a nodos de UI.
- [x] Ningún texto para el jugador está escrito literalmente en código: todos pasan por `tr()`.
- [x] Cero errores y cero advertencias de GDScript procedentes de `res://`; pruebas en verde.

**Verificación manual:** realizada por el usuario el 2026-11-10; la indicación aparece, E interactúa, el quero se inclina, suena y recupera estamina; la pausa sigue funcionando.

---

## Fase 3 — Entorno

### Precondiciones

- [x] Fase 2 cerrada.
- [x] Equipo de referencia con GPU integrada aprobado ([08_entorno_y_rendimiento.md](08_entorno_y_rendimiento.md) §4). El de GPU dedicada puede seguir sin definir.

### Entregables

Primera tarea: enumerar las pruebas de la fase en docs/06 §3.

`campaigns/01_pachacutec/scenes/world/mundo_base.tscn` y su script `scripts/world/mundo_base.gd` (composición según docs/02 §4; WorldEnvironment, `PhysicalSkyMaterial`, niebla volumétrica con alternativa, `DirectionalLight3D` “Inti”, `Terrain`, `PlayerSpawn`, `EnvironmentAudio`); sistema de perfiles gráficos en `core/systems/graphics/` (docs/08 §2); métricas de referencia medidas.

### Criterios de aceptación

- [x] La escena carga sin errores y es la escena principal del proyecto.
- [x] Iluminación coherente entre cielo, sol y ambiente.
- [x] La niebla aporta profundidad sin ocultar caminos ni objetos interactuables a menos de 30 m.
- [x] El perfil gráfico se cambia en ejecución y la niebla volumétrica puede desactivarse o sustituirse.
- [x] Métricas de referencia registradas en docs/08 §4.
- [x] Objetivo **vinculante** cumplido: ≥ 30 FPS de media en perfil Bajo, 1080p, en el equipo de referencia con GPU integrada. El objetivo recomendado (≥ 60 FPS, perfil Medio) se mide si existe el equipo de referencia con GPU dedicada; si no, se declara “no verificado” en el informe sin bloquear el cierre.

**Verificación manual:** realizada por el usuario el 2026-11-10; cielo, sol y niebla coherentes, terreno visible y transitable, y F2 cambia el perfil con la diferencia esperada.

**Medición con recorrido fijo (2026-11-10):** Bajo **311,5 FPS** de media y **250,0 FPS** de percentil 1 %; Medio **97,5 FPS** de media y **83,3 FPS** de percentil 1 %. Sin vsync y con `Engine.max_fps = 0`, sobre un recorrido circular corriendo. El jugador queda apoyado en el terreno. La referencia con GPU dedicada sigue sin definir.

---

## Fase 4 — Vertical Slice de Pachacútec

### Precondiciones

- [x] Fase 3 cerrada.
- [x] Documento de alcance del vertical slice aprobado en `campaigns/01_pachacutec/documentation/` (guion, mapa, lista de assets y protocolo de validación de autor de [ADR-0031](adr/0031-validacion-por-el-autor.md): tres pasadas, cuestionario de comprensión, criterio de corrección y umbrales). Puede ajustar los objetivos de abajo, pero solo mediante un ADR.

> **Corrección de proceso (2026-11-10).** La revisión de la primera versión del alcance encontró que la precondición se había marcado como cumplida sin estarlo: faltaban el cuestionario, el criterio de corrección y el reclutamiento. La Fase 4 quedó bloqueada hasta aprobar la revisión 2, que ya incluye el protocolo completo y la secuencia con disparo garantizado. El bloqueo de la llacta construido mientras tanto se conserva como trabajo provisional y se ajusta ahora a la revisión 2.

### Objetivo medible

| Aspecto | Objetivo |
|---|---|
| Duración | 2–3 minutos de mediana en ruta directa ([ADR-0033](adr/0033-duracion-del-slice.md)); medido en 121,2 s (AUTO-4). El horizonte de 10–15 min queda para la campaña completa |
| Espacio | Una llacta de ~150 × 150 m explorables |
| Viviendas | 6–8 |
| Caminos | Al menos 2 rutas distintas entre el inicio y el punto narrativo final |
| Objetos interactuables | Mínimo 3 de tipos distintos (incluido el quero) |
| Personajes | Mínimo 2 NPC con presencia (animación idle; diálogo solo si su sistema se ha incorporado por ADR) |
| Narrativa | 1 evento narrativo con inicio y cierre (llegada de noticias del avance chanca) |
| Sonido | Ambiente de exteriores + efectos de las interacciones |

### Criterios de aceptación

- [x] La experiencia puede jugarse de principio a fin sin bloqueos ni errores. *(2026-11-13: `DEMO_OK` en la partida de demostración y cuatro pasadas AUTO-1 a AUTO-4 sin bloqueos; el cierre sin fugas se corrigió y AUTO-4 terminó sin errores.)*
- [x] Se cumplen los objetivos medibles de la tabla (o los ajustados por ADR). *(2026-11-12, inspección de `mundo_base.tscn` cargada y `demo_playthrough.gd` con `DEMO_OK`: espacio de 140 × 140 m dentro de los límites a ±70 m; 8 viviendas; 4 caminos y dos rutas, la baja por las viviendas del oeste y la alta por las terrazas, las rampas y el mirador; 3 interactuables de tipos distintos (quero, ofrenda y pututu) más «Hablar» en 6 personajes; 9 NPC, con la tejedora y el agricultor en su animación de trabajo; el evento del mensajero llega de principio a fin; ambiente de viento y sonido en las tres interacciones. 2026-11-13: la duración se midió en 121,2 s con el objetivo del mirador, dentro del objetivo de 2–3 min de ADR-0033.)*
- [x] Rendimiento: objetivo vinculante de docs/01 §5 (métrica 2) cumplido con el vertical slice completo. *(2026-11-12, commit 2cbeb56, con todo el contenido del slice: 122–132 FPS de media en perfil Bajo en la GPU integrada de referencia, frente a ≥ 30 exigidos; [docs/08](08_entorno_y_rendimiento.md) §4. La carga del equipo varió entre 1,8 y 18; la medición con el equipo descargado sigue pendiente y no bloquea, porque el margen es de más de cuatro veces. 2026-11-13: el perfil Medio por defecto mide 61,8 FPS de media en la misma GPU.)*
- [x] Validación de autor ([ADR-0031](adr/0031-validacion-por-el-autor.md), con el umbral de duración de [ADR-0033](adr/0033-duracion-del-slice.md); sustituye a la muestra de 6 jugadores de la métrica 5, que queda declarada «no verificada»). *(2026-11-13: AUTO-1 a AUTO-4; primera interacción en 10,9–13,8 s, duración de 121,2 s en la última pasada, cero bloqueos, cierre sin errores y preguntas 1 y 2 correctas sin consultar el registro. Registro en [sesiones/](../campaigns/01_pachacutec/documentation/sesiones/autovalidacion-2026-11-13.md).)*
- [x] Todo contenido histórico tiene ficha en estado “verificado”. *(2026-11-11: las 19 fichas de elementos del juego están verificadas; 2026-11-12: también PCH-021, el corral de pirca añadido con ADR-0021. PCH-022, la ficha de la introducción de ADR-0023, se verificó el mismo día. PCH-023, el mapa de ADR-0025, también se verificó ese día. PCH-014 no está en el juego y no bloquea, según [ADR-0011](adr/0011-fichas-fuera-del-slice.md).)*
- [x] Ningún anacronismo de la lista de control (docs/07 §4) queda sin justificar. *(2026-11-12: revisión de las diez categorías en la [hoja de verificación](../campaigns/01_pachacutec/documentation/hoja_verificacion_fichas.md) §7; peinados de Rocketbox y pasos con botas declarados como limitación, y murmullo comprobado sin palabras inteligibles.)*

---

## Fase 5 — Museo explorable del Cusco (superada)

Cerrada el 2026-11-13 como **modelo superado**, no como fase cumplida. El
[ADR-0038](adr/0038-campana-rpg.md) sustituye el museo por un RPG en primera
persona: la duración de 6–8 min, el HUD de tour y su validación dejan de
aplicar. No se le exige la validación pendiente porque el modelo ya no existe.

Se conservan el mundo, el evento del mensajero, la lectura en el mundo y los
nueve textos, que pasan a diálogo y a la «Memoria» del diario
([biblia de la campaña](../../campaigns/01_pachacutec/documentation/biblia_campana.md)).

---

## Fase 6 — Núcleo RPG y acto I

### Precondiciones

- [x] [ADR-0038](adr/0038-campana-rpg.md) y [ADR-0039](adr/0039-tres-actos-y-gris.md) aceptados.
- [x] Biblia de la campaña aprobada.
- [x] Fichas del acto I verificadas (PCH-004, 005, 007, 008, 010, 012, 016, 019 y 021).

### Entregables

| # | Entregable | Descripción |
|---|---|---|
| 1 | Estado | `character_state.gd`: salud, ánimo, habilidades por uso y reputación por grupo |
| 2 | Inventario | Ocho huecos, tres equipados, objetos como recursos y consumibles |
| 3 | Diálogo | Nodos con opciones, condiciones y efectos; sin retratos |
| 4 | Diario | «Encargos» y «Memoria» con sello H/A/R/N y fuente; tecla J |
| 5 | Combate | Honda con carga y proyectil, porra y escudo, enemigos con moral; reglas probadas y escena en la emboscada del acto II |
| 6 | Acto I | Cuatro encargos (tres obligatorios), quero y ofrenda, mensajero y partida |
| 7 | Interfaz | Panel de diálogo y diario; sin tarjetas automáticas ni HUD de tour |
| 8 | Pruebas | Unitarias de los sistemas y partida del acto I |

### Objetivo medible

| Aspecto | Objetivo |
|---|---|
| Duración del acto I | 12–15 min |
| Encargos | Cuatro, con tres necesarios para la llegada del mensajero |
| Sistemas | Estado, inventario, diálogo, diario y combate probados |
| Errores | Cero en consola; cero advertencias de GDScript desde `res://` |

### Criterios de aceptación

- [x] Los cinco sistemas tienen pruebas unitarias en verde. *(2026-11-13: `test_character_state`, `test_inventory`, `test_dialogue`, `test_journal` y `test_combat`.)*
- [x] El acto I se juega de principio a fin: despertar, tres encargos, mensajero y partida. *(2026-11-13: `test_act_one_tasks` y `test_world_memories` cubren encargos, oficio, memorias y disparo; el responsable del proyecto jugó el acto y confirmó que funciona.)*
- [x] El diálogo presenta opciones con condiciones y efectos comprobables. *(2026-11-13: `test_dialogue` y `test_world_dialogue`.)*
- [x] El diario guarda encargos y entradas de Memoria sin marcadores en el mundo. *(2026-11-13: `test_journal`, `test_journal_panel` y `test_world_dialogue`.)*
- [x] El combate tiene reglas probadas. *(2026-11-13: `test_combat`; la prueba en escena se traslada a la emboscada del acto II, donde el combate es contenido y no un sandbox desechable.)*
- [x] No quedan tarjetas automáticas ni zonas de lectura. *(2026-11-13: `test_act_one_tasks` comprueba que no hay `TourCard` ni `Spot*`.)*
- [x] Todo texto visible pasa por `tr()`; ningún literal en código. *(2026-11-13: pruebas de diálogo, diario y encargos.)*
- [x] Cero errores y cero advertencias de GDScript procedentes de `res://`. *(2026-11-13: 140 pruebas en verde.)*

**Cierre (2026-11-13).** La Fase 6 se cierra con el acto I jugable: cuatro
encargos, oficio, diálogo, diario y mensajero al tercero; el museo ya no existe.
El combate en escena se prueba en la emboscada del acto II, no en un sandbox
aparte.

---

## Fase 7 — Actos II y III en gris

### Precondiciones

- [ ] Fase 6 cerrada.
- [x] Fichas nuevas verificadas: armas andinas (PCH-024), el paso y el refugio (PCH-026), el Cusco de 1438 (PCH-027), la coca (PCH-028), la batalla (PCH-029), los chancas guerreros (PCH-030) y los pururaucas (PCH-031). La armadura (PCH-025) queda fuera del juego y no bloquea. *(2026-11-13: fichas verificadas con las fuentes del Met, Pachacuti Yamqui y las fichas ya verificadas.)*

### Entregables

| # | Entregable | Descripción |
|---|---|---|
| 1 | Paso | Mapa de ~80 × 80 m en gris con sendero, roquedales, refugio y arroyo |
| 2 | Emboscada | Cuatro exploradores chancas, combate con honda, sigilo y distracción |
| 3 | Decisiones | Herido, carga de maíz, descanso y perdón del explorador, con banderas |
| 4 | Cusco | Mapa de ~150 × 150 m en gris: plaza, casas, terrazas, santuario y muro |
| 5 | Reclutamiento | Ayllus, curaca vecino y jóvenes; los aliados cambian la batalla |
| 6 | Víspera y leyenda | Escena opcional de los pururaucas, contada como creencia (PCH-031, N / H) |
| 7 | Defensa y epílogo | Dos fases, contraofensiva y variantes personales |
| 8 | Pruebas | Selector de acto, puntos de control y partida guionizada del arco |
| 9 | Validación interna | Arco completo jugable, sin arte final |

### Objetivo medible

| Aspecto | Objetivo |
|---|---|
| Duración del arco | 40–50 min |
| Acto II | 12–15 min |
| Acto III | 16–18 min |
| Consecuencias | Las decisiones del acto II cambian aliados y epílogo del III |
| Estabilidad | Cero bloqueos en la partida guionizada del arco |

### Criterios de aceptación

- [x] El arco completo se juega de principio a fin en gris. *(2026-11-13: `arc_playthrough` recorre acto I → paso → Cusco → título en una sola pasada, con las transiciones reales y las banderas de `CampaignState`; `ARCO_OK`.)*
- [x] La emboscada se puede resolver con honda, con sigilo o con distracción. *(2026-11-13: `test_paso_alternatives`; la distracción deja dos enemigos y el sigilo cruza sin combate.)*
- [x] El combate en escena permite acertar con la honda, bloquear con el escudo y ver huir a un enemigo. *(2026-11-13: `test_paso` y `paso_smoke`; la escena del paso en gris.)*
- [x] El herido, el maíz y el descanso cambian el acto III de forma comprobable. *(2026-11-13: `test_ciudad` recluta según `maiz_guardado`, `herido_salvado` y `coca_compartida`; el epílogo cambia con las banderas.)*
- [x] Los aliados reclutados cambian la dificultad de la defensa. *(2026-11-13: la defensa lanza `4 − aliados` enemigos; `test_ciudad` con tres aliados deja uno.)*
- [x] La leyenda de los pururaucas se presenta como creencia, no como hecho, y no altera la batalla. *(2026-11-13: escena opcional de la víspera en el acto III, `test_ciudad_vespera_is_belief`; el texto dice «dicen» y «así lo cuentan», deja `mem_pururaucas` con sello N y fuente PCH-031, y no cambia aliados ni enemigos.)*
- [x] El selector de acto y los puntos de control funcionan. *(2026-11-13: `--act=2|3` en el título; el punto de control es el inicio del acto y morir recarga la escena. No hay punto intermedio.)*
- [x] Todas las fichas nuevas están verificadas. *(2026-11-13: PCH-024 y PCH-026 a PCH-031 verificadas; PCH-025 queda fuera del juego.)*
- [x] Cero errores y advertencias; pruebas en verde. *(2026-11-13: 148 pruebas en verde; `ARCO_OK`, `DEMO_OK` y `PASO_SMOKE` sin errores.)*

**Cierre (2026-11-13).** Fase 7 cerrada. Los tres actos se juegan en gris y
conectados: llacta → paso → Cusco → título. El acto II tiene campamento,
emboscada, sigilo, distracción, herido, maíz, descanso y perdón del explorador
(`scout_spared`, que deja una línea en el epílogo). El acto III tiene
reclutamiento según las banderas, la víspera opcional de los pururaucas —como
creencia, con `mem_pururaucas` en la «Memoria»—, defensa y epílogo. La partida
continua del arco queda automatizada en `arc_playthrough`; la validación de
autor del arco completo corresponde a la Fase 8.

---

## Fase 8 — Arte, audio y cierre

### Precondiciones

- [x] Fase 7 cerrada.
- [x] El arco completo funciona en gris y las decisiones se leen. *(2026-11-13: `arc_playthrough`.)*

### Entregables

- **Maniquí UAL1 como base definitiva** (ADR-0042): cuerpo, esqueleto y animación de todos los personajes; los modelos MakeHuman/Rocketbox quedan como referencia y no se cargan en escena.
- **Vestuario y rostro como capas:** aplicado a los nueve del acto I, a la comitiva y los chancas del acto II y a los reclutas, Cusi, aliados y defensores del acto III.
- **Paisaje del acto II:** desfiladero, arroyo, refugio, vegetación y cielo (hecho).
- Arte y audio de los actos II y III: paso, Cusco, personajes nuevos y batalla.
- Equilibrio de combate, economía de objetos y duración.
- Rendimiento del Cusco con multitud y batalla.
- Validación de autor del arco completo (ADR-0031): tres pasadas, cuestionario y umbrales.
- Documentación y bitácora al día.

### Criterios de aceptación

- [ ] El arco completo dura 40–50 min y no tiene bloqueos.
- [x] ≥ 60 FPS de media en perfil Medio en la GPU integrada de referencia; ≥ 30 FPS en Bajo como objetivo vinculante. *(2026-11-14: mediana de tres pasadas a 1920 × 1080 en la Intel UHD 770 de referencia: llacta 70,5 / paso 61,0 / Cusco 66,9 FPS en Medio y 129,1 / 137,8 / 129,2 en Bajo. La llacta y el paso con carga 0,4; el Cusco con SSAO y carga 1,0. Detalle en docs/08.)*
- [x] Cero errores y cero advertencias de GDScript procedentes de `res://`. *(2026-11-14: 155 pruebas en verde.)*
- [ ] Validación de autor superada: comprensión, primera interacción y cierre sin errores.
- [ ] Todo el contenido histórico con ficha verificada.
- [ ] La documentación refleja lo construido.

**Estado (2026-11-14).** Se corrige la dirección de arte con [ADR-0042](adr/0042-maniqui-vestido.md):
todos los actos vuelven al maniquí UAL1, que mira a +Z y se gira 180° para
coincidir con la orientación de la lógica. Los modelos MakeHuman/Rocketbox
quedan como referencia, fuera de escena. El vestuario y el rostro se aplican
como capas ancladas a huesos: los nueve del acto I (tejedora, agricultor,
mensajero, curaca, principales y vecinos), la comitiva y los chancas del acto II
y los reclutas, Cusi, aliados y defensores del acto III. La lliclla es un paño
largo anclado a la cadera, con sandalias que siguen el pie y textiles
procedurales con franjas finas en túnica, falda y lliclla. El acto II conserva
el paisaje del desfiladero, el arroyo, el refugio y la vegetación. El audio de
los actos II y III añade viento, agua, fuego, murmullo del Cusco, tambor de
combate y golpes de honda y porra; los pasos del jugador suenan en tierra y
piedra. El Cusco deja el bloqueo gris: terreno con plaza y caminos de tierra,
santuario de gradas, catorce casas con los modelos definitivos, muro de pirca,
terrazas de cultivo y diez figuras vestidas de multitud. La multitud se retira
al empezar la defensa; el portón con dintel, el remate de la muralla, los bancos,
el altar y el ichu completan la plaza. La tejedora del acto I usa un prototipo
completo vestido en Blender (`pch_dressed.py`): cuerpo y esqueleto UAL1, cabeza,
pelo y ropa propios, exportados como tres mallas con el mismo esqueleto y nueve
animaciones. El resto del elenco conserva las capas procedurales. La tejedora
queda de pie junto al telar porque la falda del prototipo no se deforma bien
arrodillada; la cara y la sastrería fina siguen en pulido. El rendimiento final
en la GPU integrada de referencia supera los 60 FPS en Medio en los tres actos,
también con la multitud y la defensa en curso. 155 pruebas en verde. Pendiente:
validación de autor y pulido de personajes.
