# 05 — Plan de implementación

> La prioridad es el RPG jugable y su aspecto; las únicas reglas duras son licencias/procedencia y pruebas. Cada fase tiene precondiciones y criterios de aceptación; una fase no se cierra con errores críticos ni con criterios incumplidos.

**Fase activa:** Fase 4 — Arte, audio y equilibrio. El arco completo (I–V) ya se juega en gris.

## Estado

| Fase | Estado | Fecha de cierre |
|---|---|---|
| 0 — Documentación | Cerrada | 2026-11-15 |
| 1 — Fundación y núcleo RPG | Cerrada | 2026-11-15 |
| 2 — Guion de la campaña 01 | En curso (el guion vive en las escenas) | — |
| 3 — Arco jugable en gris (I–V) | Cerrada | 2026-11-15 |
| 4 — Arte, audio y equilibrio | En curso | — |
| 5 — Validación y cierre | Prevista | — |

---

## Fase 0 — Documentación

**Entregables:** `README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/00`–`09`, [biblia de la campaña](../campaigns/01_pachacutec/documentation/biblia_campana.md), [expediente histórico](../campaigns/01_pachacutec/documentation/expediente_historico.md), [registro histórico](../campaigns/01_pachacutec/documentation/registro_historico.md), `.gitignore`.

**Criterios de aceptación:**

- [x] La biblia narrativa general y la de la campaña están aprobadas.
- [x] El expediente histórico cubre los cinco actos y declara la ficción.
- [x] Las 29 fichas del arco narrativo están verificadas; las nuevas están identificadas.
- [x] El repositorio está inicializado con la documentación como primer commit.

---

## Fase 1 — Fundación y núcleo RPG

**Precondiciones:** Fase 0 cerrada.

**Entregables (existentes en el repositorio):**

| # | Sistema | Estado |
|---|---|---|
| 1 | `project.godot` con Forward+, Input Map y perfiles gráficos | Hecho |
| 2 | `PlayerFPS`: movimiento, cámara, head bobbing, interacción por rayo | Hecho |
| 3 | `Interactable` y HUD contextual | Hecho |
| 4 | `StaminaComponent`, inventario, estado, habilidades y reputación | Hecho |
| 5 | Diálogo con opciones, condiciones y efectos | Hecho |
| 6 | Diario con encargos y «Memoria» (sello H/A/R/N y fuente) | Hecho |
| 7 | Combate a distancia y cuerpo a cuerpo con moral enemiga | Hecho |
| 8 | Entorno atmosférico, perfiles de calidad y medición | Hecho |
| 9 | Pruebas automatizadas del motor y los sistemas | Hecho |

**Criterios de aceptación:**

- [x] El proyecto abre, compila y ejecuta sin errores ni advertencias de GDScript procedentes de `res://`.
- [x] El jugador camina, corre, interactúa y combate.
- [x] Los sistemas de estado, inventario, diálogo, diario y combate están probados.
- [x] La pantalla de título es la escena principal y no depende de una campaña concreta.

---

## Fase 2 — Guion de la campaña 01

**Precondiciones:** Fase 1 cerrada; biblia de la campaña aprobada.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | `guion_campana.md` | Las 15 secciones de [docs/09](09_biblia_narrativa.md) §10, con ficha por misión |
| 2 | Fichas nuevas | PCH-032 a PCH-036 verificadas con edición y página |
| 3 | Tabla de textos | Claves de localización por acto, sin texto en el código |
| 4 | Mapa de banderas | Cada bandera con su origen, su pago y su variante de final |
| 5 | Guion de la asamblea | Opciones, condiciones de Palabra y consecuencias |
| 6 | Guion del costo | Quién cae, cuándo y con qué banderas |

**Criterios de aceptación:**

- [ ] Cada misión especifica contexto, objetivo narrativo, objetivo del jugador, personajes, desarrollo, conflicto, resolución, consecuencias e información histórica.
- [ ] Todas las banderas de la biblia tienen origen y pago declarados.
- [ ] Las fichas nuevas están verificadas; ninguna escena usa una ficha pendiente.
- [ ] La duración estimada por acto suma 40–50 min.

---

## Fase 3 — Arco jugable en gris (I–V)

**Precondiciones:** Fase 2 cerrada; fichas nuevas verificadas.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Acto I | Llacta, elenco y encargos con recursos (jugable); mensajero y asamblea en curso |
| 2 | Acto II | Paso, campamento, emboscada, Cusco, reclutamiento, preparación y víspera |
| 3 | Acto III | Defensa en tres fases y costo con nombre |
| 4 | Acto IV | Regreso, cuentas, asamblea y noticia de la muerte de Viracocha |
| 5 | Acto V | Reconstrucción, nombre nuevo y cierre |
| 6 | Sistemas nuevos | Recursos, oficio aplicado, confianza de Sisa, asamblea y puntos de control |
| 7 | Pruebas | Unitarias de los sistemas nuevos, por acto y partida guionizada I→V |
| 8 | Registro de sesión | Marcas por acto, decisiones y duración |

**Objetivo medible:** una partida guionizada recorre los cinco actos sin bloqueos y sin arte final; la duración estimada es 40–50 min.

**Criterios de aceptación:**

- [ ] Los cinco actos cargan y se encadenan con las transiciones reales.
- [ ] Cada acto responde a su pregunta dramática y tiene clímax.
- [ ] Las decisiones del acto I se notan en los actos II, IV y V.
- [ ] El costo del acto III depende de las banderas y se ve en el acto IV.
- [ ] El punto de control restaura salud, aliento, ánimo, inventario y posición.
- [ ] `ARCO_OK` con los cinco actos; cero errores en consola.
- [ ] Todas las claves de texto existen en la tabla de localización.

---

## Fase 4 — Arte, audio y equilibrio

**Precondiciones:** Fase 3 cerrada.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Llacta | Materiales, props, vegetación, iluminación y sonido |
| 2 | Paso | Desfiladero, refugio, arroyo, viento y sonido |
| 3 | Cusco | Plaza, casas, santuario, muro, multitud y sonido |
| 4 | Posguerra y obra | Estado visual de la llacta en IV y V |
| 5 | Personajes | Modelos, ropa, animaciones y retratos de diálogo |
| 6 | Audio | Ambiente, pasos, combate, interfaz y mezcla |
| 7 | Equilibrio | Salud, aliento, daño, munición y economía de objetos |
| 8 | Rendimiento | Optimización y medición en la GPU de referencia |

**Criterios de aceptación:**

- [ ] ≥ 30 FPS de media en Bajo y ≥ 60 FPS de media en Medio en la GPU integrada de referencia.
- [ ] Cada acto tiene su pase visual y sonoro aprobado.
- [ ] No hay anacronismos visuales ni sonoros sin declarar.
- [ ] La interfaz y los textos se leen sin esfuerzo.

---

## Fase 5 — Validación y cierre

**Precondiciones:** Fase 4 cerrada.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Checklist de la biblia | Una pasada por acto: pregunta, decisión, consecuencia, clasificación |
| 2 | Partida completa | Recorrido real de los cinco actos, cronometrado |
| 3 | Informe de duración | Minutos por acto y total |
| 4 | Pruebas | Suite completa en verde |
| 5 | Documentación | Biblia, expediente, registro y bitácora al día |

**Criterios de aceptación:**

- [ ] Duración real entre 40 y 50 min.
- [ ] 100 % de las fichas usadas en el juego están verificadas.
- [ ] Cero errores y cero advertencias de GDScript procedentes de `res://`.
- [ ] Cero bloqueos de progreso.
- [ ] La checklist de la biblia se supera en los cinco actos.
- [ ] Informe de entrega con el formato de [AGENTS.md](../AGENTS.md) §5.
