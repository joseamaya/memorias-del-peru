# 05 — Plan de implementación

> La prioridad es el mundo habitable y su aspecto; las únicas reglas duras son licencias/procedencia, rigor histórico y pruebas. Cada fase tiene precondiciones y criterios de aceptación; una fase no se cierra con errores críticos ni con criterios incumplidos.

**Fase activa:** **F3 — Vertical slice de mundo abierto.** F2 se cerró el 2026-11-20 con el blockout aprobado **con cambios**; Terrain3D y Cyclops siguen en adopción provisional hasta el sector real. **El 2026-11-20 el responsable decidió retirar la campaña lineal y su trama inventada** y repensar la campaña desde el contexto histórico. Por eso el orden de F3 es: retirar lo lineal, revisar el contexto histórico, repensar la campaña y escribir la ficha de alcance. La campaña 01 se redefine como un territorio continuo con fases históricas, no como cinco escenas.

## Estado

| Fase | Estado | Fecha de cierre |
|---|---|---|
| 0 — Documentación original | Cerrada (historial) | 2026-11-15 |
| 1 — Fundación y núcleo RPG | Cerrada (historial) | 2026-11-15 |
| 2 — Guion lineal de la campaña 01 | Cerrada (historial) | 2026-11-15 |
| 3 — Arco jugable I–V lineal | Cerrada (historial) | 2026-11-15 |
| F4-L — Arte, audio y equilibrio (lineal) | **Retirada** (historial de git) | — |
| F5-L — Validación y cierre (lineal) | **Retirada** (historial de git) | — |
| **F0 — Redefinición a mundo abierto** | **Cerrada** | 2026-11-19 |
| **F1 — Spikes técnicos** | **Cerrada** (2026-11-19) | [Ficha de F1](fases/F1-spikes-tecnicos.md) |
| **F2 — Geografía y blockout** | **Cerrada** (aprobada con cambios) | 2026-11-20 · [Ficha de F2](fases/F2-geografia-y-blockout.md) |
| **F3 — Vertical slice** | **En curso** (3.1–3.4 y 3.7 con base implementada; [ficha](fases/F3-vertical-slice.md)) | — |
| F4 — Producción de la campaña 01 | Prevista | — |
| F5 — Validación y cierre de la campaña 01 | Prevista | — |
| F6 — Campañas II–IV | Futura | — |

**Qué significa “retirada”:** el trabajo de la fase lineal no continúa, no se cierra y no bloquea el plan nuevo. Sus escenas, pruebas y documentación salen del repositorio en la retirada y solo quedan en el historial de git. No se cita como canon ni se reutiliza sin decisión expresa del responsable.

**Nomenclatura:** **F4-L** y **F5-L** son las fases lineales retiradas: su contenido sale del repositorio y solo queda en el historial de git. **F4** y **F5** sin sufijo son las fases nuevas de producción y cierre de la campaña de mundo abierto.

---

## Fase 0 — Redefinición a mundo abierto (documentación)

**Precondiciones:** decisión del responsable de cambiar la dirección del producto.

**Objetivo:** sustituir las fuentes de verdad lineales por un diseño coherente de mundo abierto regional, sin tocar código ni assets.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Diagnóstico | [docs/14](14_auditoria_y_migracion.md): estado, límites, activos reutilizables, riesgos y migración |
| 2 | Visión y GDD | [docs/01](01_vision_y_alcance.md) y [docs/11](11_diseno_de_mundo.md) |
| 3 | Campañas | [docs/12](12_campanas.md) con las cuatro campañas y sus regiones propuestas |
| 4 | Arquitectura | [docs/02](02_arquitectura.md) con mundo, NPC, persistencia, navegación y streaming |
| 5 | Pipeline | [docs/13](13_pipeline_de_escenarios.md) con Terrain3D, Cyclops, Blender y Godot |
| 6 | Región Pachacútec | Dossier geográfico y reestructuración narrativa en `campaigns/01_pachacutec/documentation/mundo/` |
| 7 | Plan y pruebas | [docs/05](05_plan_de_implementacion.md) y [docs/06](06_estrategia_de_pruebas.md) |
| 8 | Bitácora | Decisión, alternativas y consecuencias |

**Criterios de aceptación:**

- [x] `README.md`, `AGENTS.md` y `docs/01`–`15` describen el producto nuevo, no el lineal.
- [x] La campaña 01 tiene región, sectores, rutas, POI, experiencias, fases y criterio de vertical slice.
- [x] Las cuatro campañas tienen concepto, región propuesta, protagonista provisional y estado de investigación.
- [x] La arquitectura separa Core de campaña y define persistencia, navegación, streaming y NPC.
- [x] El pipeline fija versiones y licencias verificadas, y declara lo que no se ha probado.
- [x] Cada sistema existente está clasificado como conservar, adaptar, reconstruir o retirar.
- [x] Los enlaces relativos resuelven y no hay afirmaciones que contradigan el código.
- [x] La bitácora registra el giro y las fases lineales retiradas.
- [x] El responsable aprueba el plan antes de abrir F1.

**Fuera de F0:** implementar terreno, añadir addons, producir assets, reescribir escenas o borrar contenido lineal.

---

## Fase 1 — Spikes técnicos

**Precondiciones:** F0 entregada y aprobada por el responsable; PR de documentación pendiente de merge.

**Objetivo:** comprobar con medidas, no con suposiciones, que la arquitectura elegida funciona en Godot 4.7.2 y en la GPU integrada de referencia.

**Estado:** F1 cerrada (2026-11-19) con los siete spikes medidos; Terrain3D y Cyclops quedan en adopción provisional hasta el sector real. Sobre esta base se construyó el relieve regional de 3,5 × 2,5 km y los seis sectores de F2, cerrada el 2026-11-20. El detalle vive en la [ficha de F1](fases/F1-spikes-tecnicos.md) y en la [ficha de F2](fases/F2-geografia-y-blockout.md).

| # | Spike | Pregunta | Criterio de paso |
|---|---|---|---|
| 1.1 | Terrain3D | ¿Importa, renderiza, colisiona y exporta en 4.7.2 y en CI? | Sector de prueba a 60 FPS Medio; sin errores en importación ni exportación |
| 1.2 | Cyclops | ¿Blockout ágil y conversión limpia a malla/colisión? | Una plaza y una pirca convertidas; exportación sin el addon en runtime |
| 1.3 | Streaming | ¿Carga/descarga de sectores sin tirones? | Hitch < 50 ms; carga de sector < 150 ms; memoria estable en un recorrido de 10 min |
| 1.4 | Navegación | ¿Rutas estables en terreno irregular? | 20 NPC recorren llacta–manantial–paso sin atascos |
| 1.5 | NPC y horarios | ¿Rutinas y LOD con 60 NPC? | 60 NPC, 25 animados, sin caída > 20 %; estados persistentes |
| 1.6 | Guardado | ¿Esquema versionado y round-trip? | Guardar/cargar conserva todo el estado declarado; migración probada |
| 1.7 | Rendimiento | ¿Presupuesto real por sector? | ≤ 350 draw calls, ≤ 250 MB VRAM, 30/60 FPS, hitch < 50 ms |

**Criterios de aceptación:**

- [x] Cada spike tiene una escena o prueba reproducible y una medición publicada.
- [x] Terrain3D y Cyclops se adoptan o se descartan con evidencia; si fallan, se activa el respaldo. (Adopción provisional hasta el sector real de F2.)
- [x] El presupuesto de rendimiento por sector está fijado con números medidos.
- [x] La CI importa y ejecuta con los addons (o con el respaldo) sin errores.
- [x] La bitácora registra versiones, licencias, medidas y decisiones.

**Riesgo de salida:** si un spike no cumple, no se “arregla” subiendo el presupuesto sin decisión del responsable; se recorta alcance o se cambia de técnica.

---

## Fase 2 — Geografía y blockout

**Precondiciones:** F1 cerrada; expediente geográfico aprobado para blockout.

**Estado:** **cerrada el 2026-11-20, aprobada con cambios.** F2.1 (heightmap), F2.2 (sectores y streaming), F2.3 (rutas y navmesh), F2.4 (blockout de S3), F2.5 (blockout de S1), F2.6 (S4–S6), F2.7 (30 POI y descubrimiento), F2.8 (recorrido automatizado: 2.758 m, 23 min, seis sectores y ocho POI) y F2.9 (jugador en primera persona con colisión, streaming y rescate) están implementadas y con prueba. El detalle, la evidencia y lo no verificado viven en la [ficha de F2](fases/F2-geografia-y-blockout.md).

**Objetivo:** construir el territorio de la campaña 01 en gris, con escala real, rutas, sectores y lugares, antes de producir arte definitivo.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Heightmap | Base DEM + esculpido; valles, quebradas, paso y fondo |
| 2 | Sectores | Seis sectores del valle del Cusco y la aproximación occidental |
| 3 | Rutas | Camino principal, ruta del paso, río, crestas y ruta oculta |
| 4 | Comunidades | Llacta, Cusco preimperial y núcleos secundarios en blockout |
| 5 | POI | 20–30 lugares con función, nombre y clasificación |
| 6 | Navegación | Navmesh por sector y ruta a pie completa |
| 7 | Recorrido | Prueba de caminata de 20–30 min sin bloqueos |

**Criterios de aceptación:**

- [x] La región se recorre de punta a punta sin pantallas de carga exteriores. Verificado por `region_walkthrough_check` (2.758 m, 23 min, seis sectores) y a pie por el responsable en la ruta A.
- [x] Cada sector tiene función, contenido y presupuesto; no hay relleno vacío. S1, S3, S4, S5 y S6 tienen contenido y medición; S2 es el corredor de afueras: no tiene arquitectura y su contenido son las rutas y el río que lo cruzan.
- [x] La escala se lee: comunidad, campos, paso y Cusco se reconocen desde lejos en las capturas.
- [x] La clasificación geográfica está declarada.
- [x] El blockout se aprueba antes de producir arquitectura definitiva: **aprobado con cambios** por el responsable el 2026-11-20, tras recorrer la ruta A.

**Acta de cierre (2026-11-20).** El responsable recorrió el blockout a pie y aprobó la fase **con cambios**: los bloqueantes detectados en la revisión (marcador de S2 atravesable, Coricancha hundido y sin colisión, corral y muros flotantes, río sin agua, R7 dibujada como camino falso, acequia del Cusco bajo una casa) están corregidos y cubiertos por prueba. Queda **no verificado**: la prueba humana de la ruta oeste (S4–S6, solo automatizada), el contenido de S4–S6, el parpadeo de aristas al caminar (head bob + FXAA con render al 68 %; la decisión de antialiasing se aplaza al arte definitivo del Cusco), el muestreo de 4 m del terreno para caminar (F3 prevé terreno local de 1 m) y la adopción definitiva de Terrain3D/Cyclops. Nada de eso bloquea F3; se retoma en la fase que corresponda.

---

## Fase 3 — Vertical slice de mundo abierto

**Precondiciones:** F2 cerrada; presupuesto y navegación validados. **Estado:** **en curso** desde el 2026-11-20. Arranque completado: retirada de la campaña lineal, revisión del contexto histórico (PCH-039 y PCH-040), rediseño de la campaña y ficha de alcance escrita: [ficha de F3](fases/F3-vertical-slice.md). Las tareas 3.1–3.10 se ejecutan en el orden que fija la ficha; ninguna se adelanta sin su predecesora.

**Cierre preparado (2026-11-21):** 3.1–3.9 están implementadas y probadas; 3.10 tiene el [protocolo humano](../campaigns/01_pachacutec/documentation/prueba_vertical_slice.md) y la medición por sector y perfil (S1 y la batalla: 66,4/66,7 FPS en Medio, 61,0/61,1 en Bajo, dentro del presupuesto). Falta la pasada del responsable y su firma en el [acta](fases/F3-acta-de-cierre.md) para cerrar la fase.

**Objetivo:** demostrar que el mundo se puede **habitar y jugar**, no solo recorrer.

**Contenido mínimo:** la slice demuestra la **ciudad habitable y la defensa** (fases 1 y 2 de la campaña). El detalle, los criterios por tarea y el orden de recorte viven en la [ficha de F3](fases/F3-vertical-slice.md).

- Sector S1 Cusco jugable como hub: plaza, ayllus, arrabal de Chocos-chacona y límite natural.
- 8–12 casas habitables, 3 interiores transitables y el arrabal como barrio reconocible.
- 20–30 NPC, 8 nombrados, rutinas de mañana, tarde y noche.
- Carmenca al oeste, con los accesos y las defensas documentadas (fosos, púas).
- 1 misión principal de 3 etapas: la ciudad que se queda y el día de Carmenca.
- 2 actividades secundarias con sentido social o económico.
- 1 descubrimiento no marcado.
- Ciclo día/noche y descanso.
- Persistencia de un cambio del jugador en la ciudad.
- Guardado/carga completo.

**Criterios de aceptación:**

- [ ] Se cumplen todos los criterios de la [ficha de F0](fases/F0-redefinicion-mundo-abierto.md) §5.
- [ ] 30–45 min de juego real en una pasada humana, con contenido no principal.
- [ ] El jugador puede volver al arrabal sin marcador y describir un lugar descubierto.
- [ ] Rendimiento y estabilidad dentro del presupuesto.
- [ ] Cero errores y advertencias de GDScript procedentes de `res://`.
- [ ] Acta de revisión con decisión: continuar, recortar o replantear.

---

## Fase 4 — Producción de la campaña 01

**Precondiciones:** F3 aprobada.

**Objetivo:** convertir la vertical slice en la campaña completa, con las cinco fases históricas, el contenido principal y secundario, el arte y el audio.

**Entregables:**

| # | Entregable | Descripción |
|---|---|---|
| 1 | Región completa | 3,5 × 2,5 km; seis sectores; Cusco, llacta, quebrada, paso y frontera |
| 2 | Fases históricas | Paz, noticia, guerra, posguerra y obra sobre el mismo territorio |
| 3 | Historia principal | 12–16 misiones, con secuencias controladas para asamblea y defensa |
| 4 | Contenido secundario | 15–20 historias, encargos cotidianos, 20–30 descubrimientos |
| 5 | NPC | 60–100 persistentes, 15–20 narrativos, rutinas y relaciones |
| 6 | Arte y audio | Arquitectura, props, vegetación, personajes, ambiente y mezcla |
| 7 | Persistencia | Guardado completo, autoguardado y migraciones |
| 8 | Accesibilidad | Guía opcional, textos legibles, opciones de cámara y audio |

**Criterios de aceptación:**

- [ ] La campaña se juega de principio a fin sin bloqueos.
- [ ] Las cinco fases se sienten como el mismo lugar transformado, no como cinco mapas.
- [ ] Las decisiones de la fase 1 se notan en las fases 3–5.
- [ ] El mundo sigue ofreciendo contenido no principal después del clímax.
- [ ] Rendimiento y duración dentro de objetivo.
- [ ] Rigor histórico completo y revisado.

---

## Fase 5 — Validación y cierre de la campaña 01

**Precondiciones:** F4 cerrada.

**Entregables:**

1. Checklist de la biblia por fase.
2. Partida completa cronometrada, con y sin contenido secundario.
3. Informe de duración por fase y total.
4. Suite completa y recorrido de la slice.
5. Documentación, registro histórico y bitácora al día.
6. Build de Linux y Windows; arranque del build.

**Criterios de aceptación:**

- [ ] Duración real entre 6 y 8 h de historia principal.
- [ ] 100 % de las fichas usadas están verificadas.
- [ ] Cero errores y advertencias de GDScript procedentes de `res://`.
- [ ] Cero bloqueos de progreso; guardado/carga fiable.
- [ ] La checklist de la biblia se supera en las cinco fases.
- [ ] Informe de entrega con el formato de [AGENTS.md](../AGENTS.md) §7.

---

## Fase 6 — Campañas II–IV

**Precondiciones:** campaña 01 cerrada y arquitectura validada.

Cada campaña empieza por su **expediente histórico y geográfico**, sigue por su biblia y su región, y reutiliza los sistemas de Core sin copiar contenido. No se abren dos campañas a la vez.

| Campaña | Región propuesta | Estado de partida |
|---|---|---|
| II — Túpac Amaru II | Vilcanota: Tinta–Tungasuca–Sangarará–Sicuani y punas | Expediente por hacer |
| III — Independencia | Candidata Ayacucho–Huanta–Cangallo; alternativas Jauja–Tarma o Lima–Huarochirí | Expediente comparativo |
| IV — Campaña de la Breña | Valle del Mantaro y puna hacia Ayacucho | Expediente por hacer |

---

## Reglas de recorte

Si una fase se pasa de alcance, se recorta en este orden:

1. Tamaño de región: de 3,5 × 2,5 km a 2 × 2 km.
2. Multitud ambiente y NPC tier C.
3. Interiores: 3 por comunidad en vez de 8–12.
4. Clima: solo claro/lluvia.
5. Combate: solo encuentros authored.
6. Viaje rápido: eliminado.
7. Campañas II–IV: solo documentos de diseño, sin producción.

No se recorta: rigor histórico, guardado, navegación básica, rendimiento, pruebas de bloqueo.
