# Sectores de la región — campaña 01

- **Versión:** 0.1 — 2026-11-19
- **Estado:** propuesta para blockout (F2); los presupuestos son provisionales hasta F1.
- **Regla:** cada sector se aprueba con función, contenido, presupuesto y clasificación antes de construir geometría.

## 1. Resumen

| Sector | Superficie | Función | Densidad | NPC | Interiores | Presupuesto |
|---|---|---|---|---|---|---|
| S1 Cusco preimperial | 350 × 300 m | Hub político y comercial | Alta | 30–40 | 5–8 | 350 draw calls |
| S2 Afueras y terrazas | 400 × 300 m | Transición y agricultura | Media | 8–12 | 2–3 | 250 draw calls |
| S3 Llacta de Rumi | 300 × 250 m | Hogar y vida cotidiana | Alta | 20–30 | 3–5 | 300 draw calls |
| S4 Quebrada alta | 400 × 300 m | Recursos y descubrimiento | Baja | 3–6 | 1–2 | 180 draw calls |
| S5 Paso | 350 × 300 m | Viaje y peligro | Baja | 2–5 | 1 | 150 draw calls |
| S6 Frontera chanca | 400 × 350 m | Conflicto y clímax | Media | 10–20 | 1–2 | 220 draw calls |

Los NPC de cada sector se solapan con los de la región; no se suman todos a la vez. El `NpcDirector` activa solo los cercanos.

## 2. S1 — Cusco preimperial

- **Clasificación:** GD/GR.
- **Función:** hub urbano; política, comercio, información, autoridad.
- **Contenido:** plaza, recinto del Coricancha, casas de ayllus, mercado, talleres, depósitos, callejones, acequia urbana.
- **Vida:** mercado de mañana, talleres, reuniones, mensajeros, guardia.
- **POI:** Coricancha, plaza, mercado, casa del curaca cusqueño, taller de textil, depósito.
- **Experiencias:** escuchar rumores, comprar/vender, entregar mensajes, presenciar una discusión política, visitar el santuario.
- **Riesgo:** sector más caro; multitud y sombras. Se mide a mediodía.
- **Límite:** muralla/pirca y quebrada; no se puede salir por el fondo visual.

## 3. S2 — Afueras y terrazas

- **Clasificación:** GR.
- **Función:** transición urbano-rural; agricultura y agua.
- **Contenido:** terrazas de maíz, acequias, casas dispersas, corrales, era, camino principal.
- **Vida:** riego, cosecha, pastoreo, acarreo.
- **POI:** acequia madre, era, corral, casa de una familia de agricultores.
- **Experiencias:** ayudar con el riego, reparar una acequia, aprender sobre terrazas, atajar por el río.
- **Riesgo:** pendientes y colisión de terrazas; el jugador no debe quedar atrapado.

## 4. S3 — Llacta de Rumi

- **Clasificación:** GN.
- **Función:** hogar; vida cotidiana, familia, comunidad, primera base del jugador.
- **Contenido:** 12–18 casas, plaza, casa de Rumi, telar, corral, manantial, acequia, huerto, fogón.
- **Vida:** amanecer, desayuno, trabajo, mercado, comida, conversación, noche.
- **POI:** casa de Rumi, plaza, manantial, telar, corral, casa del curaca, mirador bajo.
- **Experiencias:** acarrear agua, moler maíz, tejer, reparar el corral, escuchar una discusión, preparar una ofrenda.
- **Riesgo:** exceso de props y NPC; se usan kits y LOD.
- **Persistencia:** corral reparado, acequia limpia, casa reconstruida, objetos del hogar.

## 5. S4 — Quebrada alta

- **Clasificación:** GR/GN.
- **Función:** recursos, descubrimiento, soledad, riesgo.
- **Contenido:** arroyo, salto de agua, cueva, pastos, queñua, terrazas altas, refugio de pastores.
- **Vida:** pastoreo, recolección, caza menor, descanso.
- **POI:** cueva con ofrendas, salto de agua, poza, bosque de queñua, corral de altura.
- **Experiencias:** descubrir la cueva, seguir el arroyo, encontrar un objeto perdido, refugiarse de la lluvia.
- **Riesgo:** navegación y pendientes; no hay caminos anchos.

## 6. S5 — Paso

- **Clasificación:** GN/GR.
- **Función:** viaje, umbral, peligro, mirador.
- **Contenido:** zigzag, refugio de pirca, parapeto, mirador, nieve estacional, viento.
- **Vida:** arrieros, pastores, centinelas, refugiados.
- **POI:** refugio, mirador, pirca de señalización, altar de altura.
- **Experiencias:** cruzar con niebla, refugiarse, ver el valle desde el mirador, encontrar marcas de otro viajero.
- **Riesgo:** el viento y la niebla afectan la visibilidad; el jugador puede perderse si no sigue el camino.

## 7. S6 — Frontera chanca

- **Clasificación:** GN/GR.
- **Función:** conflicto, campamento, clímax, consecuencias.
- **Contenido:** puna, bofedal, tambo abandonado, marcas de piedra, campamento, puestos de vigilancia, campo de batalla.
- **Vida:** exploradores, guerreros, prisioneros, animales.
- **POI:** tambo, marcas de piedra, campamento, puesto de vigilancia, campo de batalla, enterramientos.
- **Experiencias:** observar sin ser visto, rescatar a alguien, llevar un mensaje, participar en la emboscada, volver después de la guerra.
- **Riesgo:** combate y densidad de NPC; se controla con encuentros authored y LOD.

## 8. Transiciones

| De | A | Tipo | Regla |
|---|---|---|---|
| S3 | S2 | Camino | Sin carga; el jugador ve el cambio |
| S2 | S1 | Camino y puerta | Sin carga exterior; interior aparte |
| S3 | S4 | Sendero | Sin carga; pendiente |
| S4 | S5 | Zigzag | Sin carga; clima |
| S5 | S6 | Paso | Sin carga; control histórico |
| Cualquiera | Interior | Puerta | Carga aditiva < 0,5 s; retorno a la puerta |

## 9. Presupuesto y validación

Cada sector se valida con:

- `scene_audit.gd --breakdown` para draw calls y sombras.
- `measure_performance.tscn` en el peor caso (mediodía, multitud, clima).
- Recorrido a pie completo, sin atascos.
- Ruta de NPC entre casa, trabajo y puerta.
- Guardar/cargar con el sector activo.
- Revisión visual contra la guía.

Si un sector supera el presupuesto, se recorta antes de subir el límite.

## 10. Qué no se construye

- Sectores vacíos de relleno.
- Muros invisibles en mitad del paisaje.
- Casas sin interior cuando la misión las usa.
- Props únicos que no se reutilizan.
- Detalle fino en zonas que solo se ven desde lejos.

## 11. Mapa de contenido

| Sector | POI principales | Experiencias | Interiores | NPC |
|---|---|---|---|---|
| S1 Cusco | POI-17 a POI-22 | E24, E25 | 5–8 | 30–40 |
| S2 Afueras | POI-09, POI-15, POI-16 | E05, E13 | 2–3 | 8–12 |
| S3 Llacta | POI-01 a POI-08 | E01–E08 | 3–5 | 20–30 |
| S4 Quebrada | POI-10 a POI-14, POI-25 | E09–E12, E14 | 1–2 | 3–6 |
| S5 Paso | POI-23, POI-24, POI-30 | E14–E16 | 1 | 2–5 |
| S6 Frontera | POI-26 a POI-29 | E17–E21 | 1–2 | 10–20 |

El catálogo completo está en [rutas_y_poi.md](rutas_y_poi.md) y [experiencias_de_exploracion.md](experiencias_de_exploracion.md).

## 12. Cambios por fase

| Sector | Paz | Noticia | Guerra | Posguerra | Obra |
|---|---|---|---|---|---|
| S1 Cusco | Mercado y talleres | Controles y rumores | Defensa y refugio | Cuentas y ausencias | Reconstrucción |
| S2 Afueras | Campos | Refugiados | Paso restringido | Campos sin cuidar | Acequia reparada |
| S3 Llacta | Rutinas | Asamblea y salida | Ausencias | Casas vacías y heridos | Obras y lumbre |
| S4 Quebrada | Pastoreo | Paso de mensajeros | Escondite | Recursos escasos | Recolección |
| S5 Paso | Camino abierto | Controles | Peligro | Ruinas | Camino reparado |
| S6 Frontera | Puna | Exploradores | Campamento | Campo de batalla | Memoria |

El cambio de fase se guarda y se ve. No se reconstruye el sector desde cero: se activan y desactivan estados, props y NPC.
