# 05 — Plan de implementación

**Fase activa:** Fase 5 — Museo explorable del Cusco.
**Siguiente:** —

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
| 5 — Museo explorable del Cusco | En curso | — |

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

## Fase 5 — Museo explorable del Cusco

### Precondiciones

- [x] Fase 4 cerrada y `v0.1` etiquetada.
- [x] [ADR-0034](adr/0034-una-campana-y-museo.md) aceptado (una campaña y modelo de museo).
- [x] Las nueve fichas de las estaciones están verificadas en el registro histórico.

### Entregables

| # | Entregable | Descripción |
|---|---|---|
| 1 | `core/ui/tour_card` | Tarjeta genérica: título, cuerpo, sello H/A/R/N y fuente; se cierra con E o Esc y bloquea al jugador mientras está abierta |
| 3 | Zonas y señales en el mundo | `Area3D` invisibles para los lugares y señales del quero y la ofrenda; sin objetos ni marcadores |
| 4 | Nueve estaciones | Plaza, quero, chicha, ofrenda, telar, vivienda, terraza, corral y mirador, con textos de 60–80 palabras y fuente |
| 5 | Estado del tour | Tarjetas leídas, una sola vez; sin contador, brújula ni objetivo antes del evento |
| 6 | Integración del evento | Sale al llegar al mirador; respaldo por reloj de 360 s |
| 7 | Pruebas y validación | Lugar visitado una sola vez, tarjeta, disparo del mirador, textos con clave y ficha; validación de autor |

### Criterios de aceptación

- [x] Las nueve tarjetas se abren al estar en el sitio o al hacer la acción, una sola vez. *(2026-11-13: `test_world_tour`, con zonas y señales; la segunda visita no reabre.)*
- [x] No hay contador, brújula ni objetivo antes del evento: el HUD no guía. *(2026-11-13: `test_world_tour` comprueba que el HUD no muestra objetivo al empezar.)*
- [x] La tarjeta muestra título, cuerpo, sello y fuente; se cierra con E o Esc y el jugador recupera el control. *(2026-11-13: `test_tour_card` y `test_world_tour`; captura de la tarjeta del quero con fuente completa.)*
- [x] El evento sale al llegar al mirador; si no se sube, el respaldo por reloj de 360 s lo trae igual. *(2026-11-13: `test_world_tour_mirador_opens_event`; las pruebas del mensajero cubren el respaldo.)*
- [ ] Duración mediana de 6–8 min de exploración con lectura (ADR-0037 y ADR-0031).
- [x] Ninguna tarjeta afirma algo sin ficha; las nueve tienen sello y fuente. *(2026-11-13: revisión de los nueve textos contra PCH-004/005/007/008/010/012/016/021/022; las fuentes citadas son las de las fichas.)*
- [ ] Cero bloqueos y cero errores de consola.
- [ ] ≥ 60 FPS en perfil Medio en la GPU integrada de referencia.
- [x] Cero errores y cero advertencias de GDScript procedentes de `res://`. *(2026-11-13: 107 pruebas en verde, sin advertencias.)*
