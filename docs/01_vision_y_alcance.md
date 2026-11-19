# 01 — Visión y alcance

## 1. Visión

**Memorias del Perú** es una antología de cuatro **RPG históricos de mundo abierto regional** en primera persona. Cada campaña tiene un protagonista común, un periodo histórico, una región continua y explorable, una comunidad con vida propia y una historia que se vive desde abajo.

El jugador no controla a los grandes protagonistas de la historia. Vive los acontecimientos desde la perspectiva de personas comunes que, por sus circunstancias, se encuentran cerca de ellos.

La campaña en desarrollo es **Pachacútec — El despertar del Sol** (siglo XV, guerra contra los chancas). Las otras tres —Túpac Amaru II, la independencia y la Campaña de la Breña— tienen concepto y región propuestos, pero no se construyen hasta que les toque su fase.

> **Nota de transición.** La versión lineal de 40–50 minutos, con cinco actos y tres escenarios, se conserva como historial y banco de pruebas. El producto que se define aquí es un mundo abierto regional. El cambio se registra en la [bitácora](bitacora.md).

## 2. Pilares de diseño

| Pilar | Significado práctico | Cómo se evalúa |
|---|---|---|
| **El territorio primero** | La región tiene valor por sí misma: rutas, oficios, gente, ruinas, rumores. La misión principal no es la única razón para salir de casa | El jugador explora, descubre y recuerda lugares sin que se los marque una misión |
| **Vida cotidiana** | Trabajar, comer, descansar, conversar, ayudar, negociar. La reciprocidad andina es mecánica, no decorado | Las actividades cotidianas tienen consecuencia económica o social |
| **Historia desde abajo** | Los hechos documentados enmarcan la ficción; el protagonista no sustituye a los grandes personajes | Cada elemento histórico tiene ficha y clasificación; el resultado histórico no cambia |
| **Consecuencia y memoria** | El mundo recuerda: NPC, casas, caminos y comunidades cambian por lo que hace el jugador y por la fase histórica | Un cambio del jugador sigue ahí después de guardar, cargar y volver |
| **Densidad, no escala** | 2–4 km² de área densa bien poblada valen más que 20 km² vacíos | Cada sector tiene una función y contenido; no hay áreas de relleno |
| **Legibilidad y rendimiento** | El juego debe verse y jugarse bien en la GPU integrada de referencia | Presupuesto por sector medido; 30 FPS en Bajo y 60 en Medio |
| **Identidad histórica diferenciada** | Cada campaña tiene paisaje, economía, sociedad y tono propios | Revisión de dirección artística y expediente histórico por campaña |

**Regla de desempate:** cuando dos pilares entran en conflicto, la coherencia histórica y la legibilidad prevalecen sobre la espectacularidad y la escala.

## 3. Público objetivo

- Jugadores de aventura/exploración narrativa en primera persona.
- Público interesado en historia andina y peruana, incluido uso educativo.
- Plataforma: PC de escritorio con teclado y ratón. El soporte de mando queda fuera del alcance inicial, pero el Input Map se diseña para permitirlo sin reescribir el jugador.

## 4. Alcance del producto

### Incluido en el horizonte del producto

- Cuatro campañas independientes, seleccionables desde la portada. En esta etapa solo la 01 es jugable; las otras tres se muestran como “en diseño” hasta que les toque su fase.
- Una región continua y explorable por campaña, con **2–4 km² de área densa** y hasta ~8 km² incluyendo wilderness.
- Una comunidad principal, núcleos secundarios, caminos, campos, ríos, quebradas y montañas.
- NPC con identidad, oficio, rutinas, relaciones y estados persistentes.
- Historia principal, historias secundarias, encargos cotidianos, descubrimientos y acontecimientos.
- Progresión por habilidades, reputación, relaciones y conocimiento del territorio.
- Economía de trueque/reciprocidad coherente con cada época.
- Combate contextual, subordinado al relato.
- Guardado completo en disco, ciclo día/noche, mapa del diario y opciones de accesibilidad.

### Fuera de alcance

- Multijugador, consolas, móviles, VR.
- Mundos de escala nacional o continental; mapas gigantes vacíos.
- Cuatro campañas construidas a la vez.
- Vínculo sobrenatural entre protagonistas o sistema de memorias ancestrales.
- Niveles, XP, loot aleatorio, magia, crafting profundo.
- Cambiar el resultado histórico documentado.
- Voces, retratos o árboles de diálogo enormes.
- Simulación compleja para cada NPC.
- Códice histórico completo en la primera versión (el diario no lo sustituye).

## 5. Definición de éxito

**Objetivo comprometido:** entregar la campaña 01 jugable de principio a fin como mundo abierto regional, con su región, su historia, su vida cotidiana y su contenido histórico verificado.

| # | Métrica | Umbral | Cómo se mide |
|---|---|---|---|
| 1 | Duración de la campaña | **6–8 h** de historia principal; 8–12 h con actividades | Partida humana cronometrada y registro de sesión |
| 2 | Rendimiento | **Vinculante:** ≥ 30 FPS de media en Bajo, 1080p, GPU integrada de referencia. **Comprometido:** ≥ 60 FPS en Medio | Recorrido fijo por sector con `Performance` y `scene_audit` |
| 3 | Rigor histórico | 100 % del contenido histórico con ficha “verificado” | Registro histórico de la campaña |
| 4 | Estabilidad técnica | 0 errores, 0 bloqueos de progreso; guardado/carga fiable | Pruebas automatizadas + sesiones de prueba |
| 5 | Mundo habitable | El jugador puede describir una experiencia no principal (descubrimiento, relación, oficio) y volver a casa sin marcador | Prueba con jugadores y checklist de la vertical slice |
| 6 | Coherencia con la biblia | 100 % de las fases superan la checklist de la biblia de la campaña | Revisión de diseño y partida guionizada |

La métrica 5 sustituye a la validación con jugadores externos en la primera etapa; después se mide con una muestra pequeña. La comprensión por parte del público queda como objetivo futuro, con el registro de sesión como base.

## 6. Horizonte por etapas

| Etapa | Contenido | Estado |
|---|---|---|
| F0 | Redefinición documental y auditoría | **Entregada** (PR pendiente de merge) |
| F1 | Spikes técnicos: terreno, streaming, navegación, NPC, guardado y rendimiento | **En curso** (1.6 base) |
| F2 | Geografía y blockout de la región Pachacútec | Prevista |
| F3 | Vertical slice de mundo abierto | Prevista |
| F4 | Producción de la campaña 01 | Prevista |
| F5 | Validación y cierre de la campaña 01 | Prevista |
| F6 | Campañas II–IV, una a una | Futura |

Nada de una etapa se implementa antes de que la anterior cumpla su criterio de salida. Las otras tres campañas no se construyen hasta que la campaña 01 esté cerrada y su arquitectura esté validada.

## 7. Glosario

| Término | Definición en este proyecto |
|---|---|
| Core | Sistemas compartidos por todas las campañas (`core/`) |
| Shared Assets | Recursos reutilizables sin lógica de campaña (`shared_assets/`) |
| Campaña | Contenido de una época: región, personajes, misiones, datos (`campaigns/NN_nombre/`) |
| Región | Territorio continuo y explorable de una campaña (2–4 km² de área densa; hasta ~8 km² con wilderness) |
| Sector | Unidad de composición y streaming del territorio (256–512 m) |
| Fase histórica | Estado del mundo que cambia la región y la historia (paz, guerra, posguerra) |
| Secuencia controlada | Escena con control limitado del jugador: batalla, asamblea, sueño, clímax |
| Expediente | Dossier histórico y geográfico de una campaña antes de escribir su guion |
| Llacta | Asentamiento/pueblo andino |
| Quero | Vaso ceremonial de madera. Forma quechua (*qiru* / *q'iru*) pendiente de verificar con la norma de la campaña |
| Chicha de jora | Bebida fermentada de maíz germinado (jora) |
| Inti | Sol; nombre de la `DirectionalLight3D` principal |
