# Duración del arco: medida, estimación y opciones

Documento de decisión. El criterio de la Fase 8 pide **40–50 min** para el arco
completo ([docs/05 § criterios](../../../docs/05_plan_de_implementacion.md)) y
sigue sin verificarse con una persona. Aquí está lo que sí se ha medido, lo que
se puede estimar y qué haría falta para llegar.

## 1. Lo medido

Pasadas guionadas, con las mismas acciones de entrada que la partida real y sin
detenerse a leer ni a explorar:

| Acto | Recorrido guionado | Qué incluye | Qué falta |
|---|---|---|---|
| I — llacta | **2 min 47 s** | quero, ofrenda, tejedora, mensajero, pututu, recorrido por la llacta | los cuatro encargos (`agua`, `maiz`, `telar`, `pirca`) |
| II — paso | **43 s** | campamento, emboscada, combate, decisiones | explorar el arroyo y el refugio |
| III — Cusco | **49 s** | tres reclutamientos, Cusi, defensa con 3 aliados, epílogo | leer los diálogos, mirar la ciudad |
| **Total** | **4 min 19 s** | | |

Registros: `record_paso.gd`, `record_ciudad.gd` y `demo_playthrough.gd`; el
vídeo `build/demo_pachacutec_arco_1080p.mp4` los recorre.

## 2. Lo estimado para una persona

Factores que la pasada guionada no tiene: caminar sin conocer el mapa, leer
cada línea, completar los cuatro encargos, equivocarse y volver.

| Acto | Guionado | Estimación humana | Supuesto |
|---|---|---|---|
| I | 2:47 | **7–10 min** | +4 encargos (2–3 min) y lectura y deambular (2–4 min) |
| II | 0:43 | **3–5 min** | explorar el paso y leer las decisiones |
| III | 0:49 | **3–5 min** | leer los reclutamientos y mirar la plaza |
| **Total** | **4:19** | **13–20 min** | |

Es una estimación, no una medida: la única forma de cerrarla es una pasada con
`--session` ([protocolo](validacion_arco.md)). Aun con el margen alto, el arco
está **a la mitad o a un tercio** del objetivo de 40–50 min.

## 3. Inventario del contenido actual

| Elemento | Cantidad |
|---|---|
| Encargos del acto I | 4 (`agua`, `maiz`, `telar`, `pirca`) |
| Interactuables del acto I | 3 (quero, ofrenda, pututu) + 9 personajes con diálogo |
| Decisiones del acto II | 2 (maíz y explorador herido) + campamento |
| Enfrentamientos | 1 emboscada (4 chancas) y 1 defensa (1–4 chancas) |
| Reclutamientos del acto III | 3 grupos |
| Líneas localizadas | 171 claves |
| Mapas | llacta 140 × 140 m, paso en corredor, Cusco 150 × 150 m |

## 4. Opciones

### A. Rebasear el objetivo a 15–20 min

- **Coste:** una tarde de documentación y una pasada de validación.
- **Qué implica:** el arco se lee como una sesión corta, no como una campaña de
  40 min. Coherente con el contenido que hay.
- **Precedente:** la duración del vertical slice ya se rebasó una vez, de 5 min
  a 2–3 min, tras medir 121 s.
- **Riesgo:** el producto se aleja de la promesa de «campaña de 40–50 min» que
  figura en la biblia.

### B. Añadir contenido hasta 40 min (recomendada si se mantiene el objetivo)

Harían falta unos **20–25 min más**, es decir, multiplicar por 2,5 el contenido
jugable. Traducido a piezas:

| Pieza | Minutos que añade | Coste |
|---|---|---|
| 4 encargos con ida y vuelta (llevar agua al telar, semilla a la pirca…) | +5 | Bajo: el sistema de encargos ya existe |
| 3 miradores del paso que hay que reconocer antes de la emboscada | +4 | Medio: puntos nuevos y lógica de objetivo |
| Avisar a los tres ayllus casa por casa en el Cusco | +4 | Medio: reutiliza casas y diálogos |
| Una segunda emboscada en el paso con los supervivientes | +3 | Medio: reutiliza enemigos y escenario |
| Una escena de la víspera con los pururaucas como creencia (ya escrita) | +3 | Bajo: el diálogo existe (PCH-031) |
| Diálogos opcionales con los nueve vecinos de la llacta | +4 | Medio: 9 conversaciones nuevas |
| **Total** | **+23** | |

Con eso el arco quedaría en **36–43 min** estimados. Es una fase de contenido,
no de pulido: no cabe en una entrega de arte.

### C. Híbrido

Rebasar a **25–30 min** y añadir solo las piezas baratas (encargos con ida y
vuelta, víspera y avisos): +12–14 min, con un coste de una o dos sesiones.

## 5. Decisión (2026-11-14)

**Opción A para esta fase, con la B como fase siguiente.** El arco de la Fase 8
se compromete a **15–20 min** y los 40–50 pasan a una fase de contenido con el
plan de §4. Motivos:

- El contenido actual da para 15–20 min densos; estirarlo con relleno
  contradice el criterio de «que se juegue bien» ([AGENTS.md §1](../../../AGENTS.md)).
- La decisión es reversible: si se aprueba la fase de contenido, se vuelve a
  40–50 sin deshacer nada de lo construido.
- La medida definitiva sigue pendiente de la pasada del autor
  ([validacion_arco.md](validacion_arco.md)).

## 6. Recomendación original

1. **Hacer la pasada de validación** antes de decidir: si sale 20 min, la
   opción C basta para acercarse; si sale 12, hace falta la B.
2. Mientras tanto, **no añadir contenido a ciegas**: cada pieza nueva arrastra
   textos, fichas históricas y pruebas, y sin la medida real se puede duplicar
   el trabajo para nada.
3. Si el objetivo de 40–50 min es firme, planificar la opción B como **fase 9**
   con su propia tabla de estado, no como pulido de la fase 8.

## 7. Qué NO cambia la duración

- El pulido visual, el audio y el rendimiento.
- Los clips de combate y la caída del enemigo.
- El vídeo de demostración: mide el contenido, no lo sustituye.
