# 05 — Plan de implementación

> La prioridad es el RPG jugable y su aspecto; las únicas reglas duras son licencias/procedencia y pruebas. Cada fase tiene precondiciones y criterios de aceptación; una fase no se cierra con errores críticos ni con criterios incumplidos.

**Fase activa:** Fase 4 — Arte, audio y equilibrio. El arco completo (I–V), el guion, los sistemas de campaña y el rendimiento en Medio están cerrados; quedan el pase visual y sonoro, la duración real y la prueba de humo.

## Estado

| Fase | Estado | Fecha de cierre |
|---|---|---|
| 0 — Documentación | Cerrada | 2026-11-15 |
| 1 — Fundación y núcleo RPG | Cerrada | 2026-11-15 |
| 2 — Guion de la campaña 01 | Cerrada | 2026-11-15 |
| 3 — Arco jugable en gris (I–V) | Cerrada (duración se mide en Fase 5) | 2026-11-15 |
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

- [x] Cada misión especifica contexto, objetivo narrativo, objetivo del jugador, personajes, desarrollo, conflicto, resolución, consecuencias e información histórica.
- [x] Todas las banderas de la biblia tienen origen y pago declarados.
- [x] Las fichas nuevas están verificadas; ninguna escena usa una ficha pendiente.
- [x] La duración estimada por acto suma 40–50 min (8–9 + 11–13 + 9–10 + 9–11 + 6–7).

---

## Fase 3 — Arco jugable en gris (I–V)

**Precondiciones:** Fase 2 cerrada; fichas nuevas verificadas.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Acto I | Llacta, elenco, encargos, duda, mensajero y asamblea |
| 2 | Acto II | Paso, campamento, emboscada, Cusco, reclutamiento, preparación y víspera |
| 3 | Acto III | Defensa en tres fases y costo con nombre |
| 4 | Acto IV | Regreso, cuentas, asamblea y noticia de la muerte de Viracocha |
| 5 | Acto V | Reconstrucción, nombre nuevo y cierre |
| 6 | Sistemas nuevos | Recursos, oficio aplicado, confianza de Sisa, asamblea y puntos de control |
| 7 | Pruebas | Unitarias de los sistemas nuevos, por acto y partida guionizada I→V |
| 8 | Registro de sesión | Marcas por acto, decisiones y duración |

**Objetivo medible:** una partida guionizada recorre los cinco actos sin bloqueos y sin arte final. La duración real de 40–50 min se mide en la Fase 5 con una partida humana cronometrada; la pasada guionizada de revisión dura 74,6 s y no sustituye esa métrica.

**Criterios de aceptación:**

- [x] Los cinco actos cargan y se encadenan con las transiciones reales.
- [x] Cada acto responde a su pregunta dramática y tiene clímax.
- [x] Las decisiones del acto I se notan en los actos II, IV y V.
- [x] El costo del acto III depende de las banderas y se ve en el acto IV.
- [x] El punto de control restaura salud, aliento, ánimo, inventario y posición.
- [x] `ARCO_OK` con los cinco actos; cero errores en consola.
- [x] Todas las claves de texto existen en la tabla de localización.

---

## Fase 4 — Arte, audio y equilibrio

**Precondiciones:** Fase 3 cerrada.

**Bloques 4.1–4.7 — Cierre jugable, puesta en escena, alineación con la biblia y combate (cerrados):** el campamento reparte sus opciones en dos páginas, el resaltado no ilumina la escena entera, el diario se navega con teclado y puntero, las tarjetas de fin aceptan E/Intro/R y bloquean al jugador, y la defensa muestra «Sostén la plaza». Cusi recibe en la puerta y se traslada al santuario, las preparaciones tienen puesto visible, la trampa tiene al curaca vecino y es obligatoria antes de la defensa, las cuentas se hacen en casas reales y varían con el coste, y el oficio queda anotado en el diario. El costo de Anca y del hijo de Puma se escenifica, Anca consume provisiones o reduce el aliento máximo, la casa de Rumi está al este, la posguerra tiene heridos y luz fría, la asamblea paga maíz, apoyo al curaca y aliados, los mensajeros de IV.4 y V.2 aparecen, la familia se reúne en el cierre y la obra del acto V marca el oficio. La campaña 01 cuenta con guion de escenas, matriz de banderas y criterios de aceptación por escena; no quedan escenas parciales. El combate usa honda, porra y escudo, con munición de piedras, viñeta de salud, respiración y sin barra fija de estado; el pase 4.11 añade fases del golpe, parry, hitstop, cámara, aviso enemigo y fichas de ataque. El rendimiento en Medio cumple el objetivo de 60 FPS y la guía visual fija paleta y escala por acto. Quedan la partida humana cronometrada, la prueba de humo y la mezcla de audio escuchada.

**Estado de la fase 4:**

- **4.8 — Duración y equilibrio (abierto).** Falta la partida humana cronometrada. El registro de sesión marca cada acto y `tools/session_duration.py` resume el total; la suma de fichas da 45,5 min y la pasada guionizada 1:58, pero ninguna es una partida real.
- **4.9 — Arte y audio por acto (abierto, en curso).** El pase visual corrigió las nubes, sustituyó las siluetas planas de montaña por bandas con volumen en la llacta y el Cusco, añadió estratos y nieve en las cumbres y dio más detalle al terreno. La [guía visual](../campaigns/01_pachacutec/documentation/guia_visual.md) fija la idea, la escala, las formas y una `PaletteTuning` por acto; las cinco capturas están en `documentation/img/guia_visual/`. El elenco ya tiene reposo, habla, trabajo, caminar y correr; la biblia excluye retratos y voces. Las casas de la llacta reciben las texturas de superficie (piedra, paja y madera), la llama del fuego es un shader y las tarjetas de los actos III y IV se leen mejor. Faltan props finos de detalle y la mezcla de audio.
- **4.10 — Rendimiento (cerrado el 2026-11-16).** Medición final de Medio a 1080p con las cordilleras, el shader aligerado y la escala 0,68: llacta 89,4, paso 93,4, Cusco 63,6, posguerra 97,5 y obra 90,5 FPS de mediana. Se mantuvo el SSAO. El Cusco es el acto más ajustado (63,2 en la peor pasada). El detalle está en [docs/08](08_entorno_y_rendimiento.md).
- **4.12 — Elenco de maniquíes UAL1 (pulido abierto: retirada del legado UBC y validación humana).** Las escenas de la campaña usan los diez looks de maniquí sobre el cuerpo UAL1 CC0, sin caras ni texturas: Curaca, Sisa, Chanca, Anca, Puma, Madre, Hermano, Joven, Anciana y Mensajero, con las alturas de la tabla de la llacta. `NpcActor` y `CharacterModelVisual` montan `OutfitMannequin`; la multitud usa `MannequinLooks.crowd_from`; las piezas de cada hueso se fusionan en una malla con colores de vértice (tres de ropa y dos del cuerpo). Los clips lógicos de UAL1/UAL2 conservan `idle`, `walk`, `run`, `talk`, `work`, `weave`, `tired`, `attack`, `hit` y `death`; el chanca lleva su porra. Presupuesto de 350 draw calls: llacta 294, paso 270, Cusco 331, posguerra 306 y obra 315; el Cusco es el más ajustado (63,8 FPS de media y p1 60,0 con carga 0,45–0,51). La memoria de vídeo es 172,4/151,7/184,7/173,4/172,6 MB. 141 pruebas, arena y arco completos. Se retiraron los GLB UBC, las caras, `CharacterCatalog`, `CharacterFace`, `CapeSprings`, `QuaterniusMaterials`, la rama UBC de `CharacterModelVisual`/`NpcActor`, sus herramientas y su prueba; el documento histórico queda en `personajes_quaternius.md`. La **mano de maniquí** está integrada pero pendiente de revisión; el panel de objetivo está aprobado. El acto I estrena un flujo de pasos visible (`SliceStep`/`SliceFlow`/`SliceSequence`), panel con los cuatro encargos y contador, marcadores de mundo, checkpoints, entrenamiento de honda de tres aciertos y mensajero tras la duda. Detalle y capturas en [prototipo_maniqui.md](../campaigns/01_pachacutec/documentation/prototipo_maniqui.md).
- **4.13 — Composición del territorio del acto I (abierto).** La llacta deja de ser una plaza plana con casas en anillo: caminos de tierra visibles con bordes de piedra, borde de pirca con cuatro entradas, manantial con acequia y juncos, mirador en el paso norte con parapeto, roquedales y fondo de valle con campos y caserío. `HouseKit` unifica medidas, colisión y variantes de vivienda entre la llacta y el Cusco; la escala y el tinte rompen la repetición. Se añaden pruebas de composición y un recorrido real de entrada, plaza, manantial, casa, mirador, pirca y corrales. 141 pruebas, `ARCO_OK` y arena; draw calls 294/270/331/306/315, Cusco 63,8 FPS y p1 60,0 con carga 0,45–0,51. Pendiente: pase visual del Cusco y el paso, mezcla de audio y prueba humana.
- **4.11 — Sensación de combate (cerrado el 2026-11-16).** El ataque deja de ser instantáneo: `CombatLoadout` separa anticipación, ventana activa y recuperación; el impacto añade hitstop, golpe de cámara y destello; el escudo tiene parry de 0,15 s y bloqueo del 70 %; los chancas avisan el golpe con una esfera y comparten fichas de ataque (máximo dos a la vez); el cuerpo derribado deja de bloquear. La arena de `combat_arena_check.gd` resuelve tres enemigos con ≤ 2 atacantes. El registro está en [combat-tuning-log](combat-tuning-log.md).

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Llacta | Materiales, props, vegetación, iluminación y sonido |
| 2 | Paso | Desfiladero, refugio, arroyo, viento y sonido |
| 3 | Cusco | Plaza, casas, santuario, muro, multitud y sonido |
| 4 | Posguerra y obra | Estado visual de la llacta en IV y V |
| 5 | Personajes | Modelos, ropa y animaciones (la biblia excluye retratos y voces) |
| 6 | Audio | Ambiente, pasos, combate, interfaz y mezcla |
| 7 | Equilibrio | Salud, aliento, daño, munición y economía de objetos |
| 8 | Rendimiento | Optimización y medición en la GPU de referencia |

**Criterios de aceptación:**

- [x] ≥ 30 FPS de media en Bajo y ≥ 60 FPS de media en Medio en la GPU integrada de referencia (medido el 2026-11-16 con el arte final; el mínimo de Bajo es 73,8 en el Cusco y el de Medio 63,2).
- [ ] Cada acto tiene su pase visual y sonoro aprobado.
- [ ] No hay anacronismos visuales ni sonoros sin declarar.
- [ ] La interfaz y los textos se leen sin esfuerzo.

---

## Fase 5 — Validación y cierre

**Precondiciones:** Fase 4 cerrada.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Checklist de la biblia | Una pasada por acto: pregunta, decisión, consecuencia, clasificación ([checklist](../campaigns/01_pachacutec/documentation/checklist_biblia.md)) |
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
- [ ] Informe de entrega con el formato de [AGENTS.md](../AGENTS.md) §7.
