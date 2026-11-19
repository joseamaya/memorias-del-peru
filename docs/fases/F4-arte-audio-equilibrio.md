# F4 · Arte, audio y equilibrio — tareas

**Estado:** en curso · **Organización aprobada:** 2026-11-19.
**Criterio de salida:** el de [docs/05](../../docs/05_plan_de_implementacion.md) §Fase 4.
La partida humana cronometrada de 40–50 min es criterio de la **Fase 5**, no de esta fase.

## 1. Alcance

- Pase visual y sonoro de los cinco actos, con el elenco de maniquíes UAL1.
- Props finos de detalle y mezcla de audio escuchada.
- Equilibrio numérico: salud, aliento, daño, munición y economía de objetos.
- Rendimiento dentro del presupuesto de 350 draw calls y 60 FPS de mediana en la GPU de referencia.

**Fuera de esta fase:** campañas II–IV, códice histórico y guardado en disco (posteriores a la campaña 01); mando físico, build de Windows probado en otra máquina y duración real de la campaña (Fase 5).

## 2. Tareas

| # | Tarea | Estado | Depende de | Criterio de aceptación | Evidencia |
|---|---|---|---|---|---|
| 4.1–4.7 | Cierre jugable, puesta en escena, alineación con la biblia y combate | Cerrado | — | Cada bloque con sus pruebas y su fila de bitácora | [docs/05](../../docs/05_plan_de_implementacion.md) §historial y bitácora |
| 4.8 | Equilibrio numérico | Cerrado el 2026-11-19 | 4.11 | Valores de salud, aliento, daño, munición y economía cubiertos por pruebas y arena | `test_combat*`, `combat_arena_check.gd`, [combat-tuning-log](../combat-tuning-log.md) |
| 4.9 | Arte y audio por acto | **Abierto** | 4.10, 4.12 | Los cinco actos con pase visual y sonoro aprobado por el responsable; audio medido antes de escuchar; sin anacronismos sin declarar | Capturas antes/después ([procedimiento](../06_estrategia_de_pruebas.md) §4.1); `audio_levels.py`; [guía visual](../../campaigns/01_pachacutec/documentation/guia_visual.md) |
| 4.10 | Rendimiento | Cerrado el 2026-11-16 | 4.9 (arte base) | ≥ 30 FPS en Bajo y ≥ 60 FPS en Medio, 1080p, GPU integrada de referencia | [docs/08](../08_entorno_y_rendimiento.md) §4 |
| 4.11 | Sensación de combate | Cerrado el 2026-11-16 | — | Fases del golpe, parry, hitstop, aviso enemigo y fichas; arena con ≤ 2 atacantes | `test_combat_feel.gd`, [combat-tuning-log](../combat-tuning-log.md) |
| 4.12 | Elenco de maniquíes UAL1 | **Abierto** | — | Diez looks integrados y aprobados; legado UBC retirado; mano en primera persona revisada | [prototipo_maniqui.md](../../campaigns/01_pachacutec/documentation/prototipo_maniqui.md) |
| 4.13 | Composición del territorio del acto I | Cerrado el 2026-11-19 | — | Caminos, pirca, manantial, mirador, roquedales y fondo de valle con recorrido real y pruebas | `test_llacta_layout.gd`, `llacta_walk_check.gd`, capturas del acto I |
| 4.14 | Cierre de F4 | **Pendiente** | 4.9, 4.12 | Checklist de cierre completo, nota de fase y build exportada | Este documento §7 |

## 3. Detalle de los bloques cerrados (4.1–4.7)

| Bloque | Qué dejó cerrado |
|---|---|
| 4.1 Cierre jugable | Campamento en dos páginas, resaltado acotado al objetivo, diario navegable con teclado y puntero, tarjetas de fin con E/Intro/R que bloquean al jugador y objetivo «Sostén la plaza» |
| 4.2 Puesta en escena | Cusi recibe en la puerta y pasa al santuario, preparaciones con puesto visible, trampa con el curaca vecino y obligatoria, cuentas en casas reales que varían con el coste, oficio anotado en el diario |
| 4.3 Cierre narrativo | Coste de Anca y del hijo de Puma escenificado, Anca consume provisiones o reduce el aliento máximo, casa de Rumi al este, posguerra con heridos y luz fría, asamblea que paga maíz y apoyo, mensajeros de IV.4 y V.2, familia reunida en el cierre y oficio en la obra del acto V |
| 4.4 Alineación con la biblia | Casa al este, cuentas variables, Puma reconciliado con y sin coste, trampa obligatoria, cruce que activa la emboscada y Anca testificando en la asamblea |
| 4.5 Guion de escenas | Plantilla `docs/10` y 22 fichas de la campaña con bloqueo, cámara, textos, banderas, aceptación y deudas |
| 4.6 Cierre de escenas | Las siete escenas parciales cerradas, banderas muertas retiradas, rótulos de nombre y coste en la última oleada |
| 4.7 Combate y HUD | Honda, porra y escudo; munición de piedras; viñeta de salud, respiración y sin barra fija de estado |

El detalle cronológico está en la [bitácora](../bitacora.md); las pruebas, en [docs/06](../06_estrategia_de_pruebas.md) §3.

## 4. Tareas abiertas

### 4.9 — Arte y audio por acto

Lo cerrado: paletas por acto, guía visual, nubes, cordilleras con volumen y nieve, terreno con más detalle, casas de la llacta con texturas de superficie, llama por shader, tarjetas de los actos III y IV legibles, elenco con reposo, habla, trabajo, caminar y correr, y capturas de referencia de los cinco actos.

Lo que falta:

- pase visual del **Cusco** y del **paso** con la guía visual delante;
- props finos de detalle donde la silueta todavía es pobre;
- mezcla de audio escuchada por acto (ambiente, pasos, combate, interfaz), después de medir niveles.

Criterio de aceptación: cada acto aprobado por el responsable con capturas antes/después; `python3 tools/audio_levels.py` sin clips, sin efectos casi mudos y con picos por debajo de −0,5 dBFS; ningún anacronismo sin declarar en [docs/07](../07_convenciones_historicas.md).

### 4.12 — Elenco de maniquíes UAL1

Lo cerrado: diez looks integrados en llacta, Cusco, paso y chancas; atuendo fusionado por hueso; LOD de multitud; legado UBC retirado; documento histórico conservado en `personajes_quaternius.md`.

Lo que falta: la **mano de primera persona** no convence al responsable y sigue en revisión. El panel de objetivo está aprobado.

Criterio de aceptación: decisión del responsable sobre la mano (se queda, se ajusta o se sustituye) y validación visual del elenco en partida.

### 4.8 — Equilibrio numérico (cerrado)

Los valores de salud, aliento, daño, munición y economía están fijados y cubiertos por `test_combat`, `test_combat_loadout`, `test_combat_feel` y la arena de tres enemigos con ≤ 2 atacantes. El contraste humano de dificultad y la duración real se hacen en la partida completa de F5; aquí no queda trabajo propio.

### 4.13 — Composición del acto I (cerrado)

Caminos con bordes de piedra, pirca con cuatro entradas, manantial con acequia, mirador con parapeto, roquedales, fondo de valle y `HouseKit` compartido con el Cusco. Verificado con `test_llacta_layout`, el recorrido `llacta_walk_check` y capturas. El pase visual pendiente del Cusco y del paso pertenece a 4.9; la mezcla de audio, también.

## 5. Dependencias y riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| El Cusco es el acto más ajustado (331 draw calls de 350; 63,8 FPS de mediana y p1 60,0) | Cualquier prop nuevo puede romper el presupuesto | Auditar con `scene_audit.gd --breakdown` antes de añadir; recortar antes de subir el presupuesto |
| La mezcla de audio depende de una escucha humana | No se puede cerrar en CI | Medir con `audio_levels.py`, escuchar por acto y anotar el veredicto |
| El pase visual depende del responsable | Un agente no puede aprobarlo | Preparar capturas fijas antes/después y una lista de lectura; el veredicto es suyo |
| La mano del maniquí sigue en revisión | Bloquea 4.12 y la sensación en primera persona | Decisión explícita: mantener, ajustar o sustituir; no improvisar un rediseño |
| Medición de rendimiento contaminada por carga externa | Cifras no comparables | Protocolo de tres pasadas, comprobar carga y repetir la tanda |

## 6. Qué se recorta primero

Si la fase se pasa de lo razonable, en este orden:

1. Props finos de detalle: se mantienen silueta, paleta y escala; no se añaden muebles, vasijas ni herramientas nuevas.
2. Mezcla de audio: se conserva el ambiente y los efectos esenciales; se aplaza la música.
3. Pase visual del Cusco: solo luz, paleta y legibilidad, sin geometría nueva.
4. Mano del maniquí: se mantiene la actual con la deuda declarada, en lugar de abrir un rediseño.

## 7. Cierre de F4

- [ ] 4.9: los cinco actos con pase visual y sonoro aprobado.
- [ ] 4.12: mano revisada y elenco validado en partida.
- [ ] Sin anacronismos visuales ni sonoros sin declarar.
- [ ] Interfaz y textos legibles sin esfuerzo.
- [ ] Suite completa, arena, arco y recorridos en verde; cero errores y advertencias de `res://`.
- [ ] Builds de Linux y Windows exportados; el de Linux arranca.
- [ ] Nota de cierre con evidencia, decisiones, «lo aprendido», «no verificado» y deudas que pasan a F5.
- [ ] El responsable confirma el criterio de salida.

## 8. Deudas que pasan a F5

| Deuda | Motivo |
|---|---|
| Partida humana completa y cronometrada (40–50 min) | Es el criterio de duración de F5; F4 no la sustituye con la pasada guionizada ni con la suma de fichas |
| Contraste humano de dificultad y equilibrio | Se observa en la partida completa, con las decisiones y el costo del arco |
| Prueba de humo del build exportado en una sesión real | F5 valida bloqueos y arranque, no solo la exportación |
| Mando físico y build de Windows probado por otra persona | Fuera del alcance de F4 |
| Mezcla de audio si se recorta | Se retoma al cerrar el arte |
