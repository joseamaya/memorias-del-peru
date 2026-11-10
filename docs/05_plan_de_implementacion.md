# 05 — Plan de implementación

**Fase activa:** ninguna. Fase 0 cerrada; la Fase 1 comienza al cumplirse sus precondiciones.
**Siguiente:** Fase 1 — Fundación técnica.

Reglas:

- No se inicia una fase mientras la anterior tenga errores críticos o criterios de aceptación incumplidos ([AGENTS.md](../AGENTS.md) §5).
- Cada fase tiene **precondiciones** (lo que debe ser cierto para empezarla) y **criterios de aceptación** (lo que debe ser cierto para cerrarla). Una precondición no es un criterio de la fase anterior: así ninguna fase depende de trabajo de la siguiente.
- Cada fase cierra con un informe de entrega (formato en [AGENTS.md](../AGENTS.md) §4) y la actualización de la tabla de estado.

## Estado

| Fase | Estado | Fecha de cierre |
|---|---|---|
| 0 — Documentación | Cerrada | 2026-11-10 |
| 1 — Fundación técnica | No iniciada | — |
| 2 — Interacción | No iniciada | — |
| 3 — Entorno | No iniciada | — |
| 4 — Vertical Slice Pachacútec | No iniciada | — |

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

- [ ] Fase 0 cerrada.
- [ ] Godot instalado y accesible como `godot` en el `PATH`.
- [ ] ADR-0002 en estado “Aceptado” con la versión exacta registrada.
- [ ] Indicadores de línea de comandos de [06_estrategia_de_pruebas.md](06_estrategia_de_pruebas.md) §2 confirmados con `godot --help` (y el documento corregido si difieren).

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
| Cuando exista un menú/selector de campaña | Escena de Core (p. ej. `res://core/ui/main_menu.tscn`) | Las campañas no deben ser el punto de entrada de la antología |

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
| Altura de `Head` | 1.60 | m |
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

- [ ] El proyecto abre en la versión fijada sin errores.
- [ ] El motor reconoce todos los scripts (`class_name` registrados, sin errores de análisis).
- [ ] El jugador camina y corre; la velocidad de carrera solo se aplica con Shift y entrada de movimiento.
- [ ] Aceleración y desaceleración perceptibles (sin arranques ni frenazos instantáneos).
- [ ] El movimiento es relativo a la orientación horizontal; mirar hacia arriba o abajo no altera la velocidad.
- [ ] Sube la rampa de 30°, no sube la de 50°, no atraviesa paredes y cae desde la plataforma.
- [ ] El ratón controla la cámara; pitch limitado a ±80°.
- [ ] Escape libera el ratón y pausa; pulsar Escape de nuevo reanuda y recaptura el ratón (prueba automatizada de la lógica + verificación manual).
- [ ] Head bobbing diferenciado caminar/correr, se detiene suavemente, sin saltos ni deriva.
- [ ] Cero errores y cero advertencias de GDScript procedentes de `res://`.
- [ ] Cero errores en consola durante la ejecución.
- [ ] Pruebas automatizadas en verde.

---

## Fase 2 — Interacción

### Precondiciones

- [ ] Fase 1 cerrada.
- [ ] ADR-0003 aceptado (o reemplazado).
- [ ] Ficha PCH-004 (quero) y PCH-005 (chicha) con fuentes identificadas, aunque no estén verificadas aún.

### Entregables

Primera tarea: enumerar las pruebas de la fase en docs/06 §3.

`core/interaction/interactable.gd`; cambios en `player_fps.gd` (`InteractionRay` activo, detección, señales de enfoque, llamada a `interact`, reglas de carrera con estamina de docs/02 §5); `StaminaComponent` añadido como hijo en `player_fps.tscn`; indicación de interacción en UI (`core/ui/`); `core/systems/stamina/stamina_component.gd` según el contrato de docs/02 §5 (incluido el consumo al correr); `AudioManager` mínimo; tabla de textos de Core y de la campaña (docs/02 §7); `campaigns/01_pachacutec/scenes/objects/quero_chicha.tscn` y `scripts/interactions/quero_chicha.gd`.

Comportamiento del quero: enfoque → indicación → E → respuesta visual (animación) → sonido → recuperación de estamina configurable → UI actualizada por señal.

### Criterios de aceptación

- [ ] Un objeto nuevo se vuelve interactuable sin modificar `player_fps.gd`.
- [ ] La detección funciona cuando el collider es hijo (directo o indirecto) del interactuable.
- [ ] No se interactúa a través de paredes.
- [ ] La estamina se actualiza y la UI lo refleja vía señales.
- [ ] El quero no contiene rutas a nodos de UI.
- [ ] Ningún texto para el jugador está escrito literalmente en código: todos pasan por `tr()`.
- [ ] Cero errores y cero advertencias de GDScript procedentes de `res://`; pruebas en verde.

---

## Fase 3 — Entorno

### Precondiciones

- [ ] Fase 2 cerrada.
- [ ] Equipo de referencia de gama baja aprobado ([08_entorno_y_rendimiento.md](08_entorno_y_rendimiento.md) §4). El de gama media puede seguir sin definir.

### Entregables

Primera tarea: enumerar las pruebas de la fase en docs/06 §3.

`campaigns/01_pachacutec/scenes/world/mundo_base.tscn` y su script `scripts/world/mundo_base.gd` (composición según docs/02 §4; WorldEnvironment, `PhysicalSkyMaterial`, niebla volumétrica con alternativa, `DirectionalLight3D` “Inti”, `Terrain`, `PlayerSpawn`, `EnvironmentAudio`); sistema de perfiles gráficos en `core/systems/graphics/` (docs/08 §2); métricas de referencia medidas.

### Criterios de aceptación

- [ ] La escena carga sin errores y es la escena principal del proyecto.
- [ ] Iluminación coherente entre cielo, sol y ambiente.
- [ ] La niebla aporta profundidad sin ocultar caminos ni objetos interactuables a menos de 30 m.
- [ ] El perfil gráfico se cambia en ejecución y la niebla volumétrica puede desactivarse o sustituirse.
- [ ] Métricas de referencia registradas en docs/08 §4.
- [ ] Objetivo **vinculante** cumplido: ≥ 30 FPS de media en perfil Bajo, 1080p, en el equipo de referencia de gama baja. El objetivo recomendado (≥ 60 FPS, perfil Medio) se mide si existe el equipo de gama media; si no, se declara “no verificado” en el informe sin bloquear el cierre.

---

## Fase 4 — Vertical Slice de Pachacútec

### Precondiciones

- [ ] Fase 3 cerrada.
- [ ] Documento de alcance del vertical slice aprobado en `campaigns/01_pachacutec/documentation/` (guion, mapa, lista de assets y protocolo de prueba: cuestionario de comprensión, criterio de corrección y reclutamiento de jugadores ajenos al desarrollo). Puede ajustar los objetivos de abajo, pero solo mediante un ADR.

### Objetivo medible (provisional)

| Aspecto | Objetivo |
|---|---|
| Duración | 10–15 minutos de mediana para un jugador que explora sin prisa (métrica 1 de docs/01 §5) |
| Espacio | Una llacta de ~150 × 150 m explorables |
| Viviendas | 6–8 |
| Caminos | Al menos 2 rutas distintas entre el inicio y el punto narrativo final |
| Objetos interactuables | Mínimo 3 de tipos distintos (incluido el quero) |
| Personajes | Mínimo 2 NPC con presencia (animación idle; diálogo solo si su sistema se ha incorporado por ADR) |
| Narrativa | 1 evento narrativo con inicio y cierre (llegada de noticias del avance chanca) |
| Sonido | Ambiente de exteriores + efectos de las interacciones |

### Criterios de aceptación

- [ ] La experiencia puede jugarse de principio a fin sin bloqueos ni errores.
- [ ] Se cumplen los objetivos medibles de la tabla (o los ajustados por ADR).
- [ ] Rendimiento: objetivo vinculante de docs/01 §5 (métrica 2) cumplido con el vertical slice completo.
- [ ] Sesiones de prueba con al menos 6 jugadores ajenos al desarrollo: duración mediana de 10–15 min (métrica 1) y al menos 2/3 superan el cuestionario de comprensión (métrica 5).
- [ ] Todo contenido histórico tiene ficha en estado “verificado”.
- [ ] Ningún anacronismo de la lista de control (docs/07 §4) queda sin justificar.
