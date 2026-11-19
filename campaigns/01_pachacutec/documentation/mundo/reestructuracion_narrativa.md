# Reestructuración narrativa — de cinco actos a un territorio

- **Versión:** 0.1 — 2026-11-19
- **Estado:** propuesta para F0–F2.
- **Objetivo:** conservar el valor narrativo de *El despertar del Sol* sin conservar cinco mapas separados.

## 1. Diagnóstico

La versión lineal funciona: Rumi, su familia, la noticia, el viaje, la defensa, el coste y la reconstrucción están escritos y probados. El problema no es la historia; es el **modelo de puesta en escena**:

- Cinco actos = cinco escenas que se cargan y se abandonan.
- Los NPC existen mientras la escena existe.
- Las decisiones se leen en la escena siguiente, no en el mundo.
- La llacta de posguerra y la de obra son duplicados del mismo terreno.
- El jugador no puede salir del guion ni descubrir nada que no esté previsto.

## 2. Decisión

La campaña conserva **cinco actos como unidades dramáticas**, pero se juega en **una sola región** con cinco **fases históricas**. El territorio cambia; no se sustituye.

| Acto lineal | Fase de mundo | Pregunta dramática | Puesta en escena |
|---|---|---|---|
| I — La casa que se vacía | Paz / vida cotidiana | ¿Qué haces cuando la noticia llega? | Escenas de mundo en la llacta, el camino y el Cusco |
| II — El paso y la ciudad dividida | Noticia / movilización | ¿Hasta dónde estás dispuesto a llegar? | Viaje por el territorio, campamento, Cusco como hub |
| III — La guerra de los chancas | Guerra | ¿Quién sostiene la línea? | Preparación en el mundo; defensa como secuencia controlada |
| IV — El precio de la victoria | Posguerra | ¿Qué queda cuando la victoria llega? | Regreso al mismo territorio, NPC y casas cambiados |
| V — El nombre nuevo | Reconstrucción | ¿Qué se hace con lo que queda? | Obras y vida cotidiana en la llacta; cierre |

## 3. Qué se conserva

- Rumi, su familia, Sisa, Puma, Asto, Anca, el curaca y Cusi Yupanqui.
- La noticia chanca, la asamblea, el viaje, la emboscada, la defensa, el coste, la posguerra y el nombre nuevo.
- Las decisiones principales y sus banderas, reinterpretadas como estado del mundo.
- El rigor histórico y las fichas PCH.
- El diario como superficie de lectura.
- El combate con honda, porra y escudo, ahora contextual.

## 4. Qué cambia

| Elemento lineal | Modelo de mundo |
|---|---|
| Cinco mapas | Una región con seis sectores y cinco fases |
| Acto I empieza en la llacta y termina al salir | La llacta es el hogar; el jugador puede quedarse, trabajar y volver |
| Acto II es un viaje guionizado | El viaje es una ruta explorable con campamento y atajos |
| Acto III es una escena de defensa | La defensa es una secuencia controlada dentro del Cusco; la preparación ocurre en el mundo |
| Acto IV es otra escena de llacta | La misma llacta, con NPC, casas y recursos cambiados |
| Acto V es otra escena | La misma llacta en obra; el cambio físico se guarda |
| Puntos de control | Guardado completo |
| Marcadores de objetivo | Indicaciones, hitos y mapa del diario; guía opcional |
| Misiones en cadena | Historia principal + secundarias + descubrimientos + acontecimientos |

## 5. Estructura propuesta de la historia principal

> Los títulos son provisionales. La numeración de fases es de diseño, no de guion cerrado.

### Fase 0 — Paz

- **0.1 La mañana:** despertar, casa, primeras tareas. Tutorial diegético.
- **0.2 Los encargos:** agua, maíz, telar, pirca. El jugador elige tres; los recursos quedan.
- **0.3 La duda:** Puma y Asto discuten; el jugador escucha o calla.
- **0.4 El mensajero:** llega agotado; darle agua o maíz tiene consecuencia.

### Fase 1 — La noticia

- **1.1 La asamblea:** el curaca pregunta quién va; decisión y despedida.
- **1.2 El camino:** viaje por el valle; campamento; primera evidencia de la guerra.
- **1.3 La emboscada:** exploradores chancas; sigilo, distracción o combate.
- **1.4 El Cusco dividido:** llegada, rumores, reclutamiento, preparación.

### Fase 2 — La guerra

- **2.1 La víspera:** preparar defensas, elegir oficio, hablar con aliados.
- **2.2 La defensa:** secuencia controlada en la plaza y el santuario.
- **2.3 El coste:** un NPC querido cae o se pierde; el jugador lo ve en el mundo.

### Fase 3 — La posguerra

- **3.1 El regreso:** el mismo camino, ahora con refugiados y ruinas.
- **3.2 Las cuentas:** casas, ausencias, recursos; varía según el coste.
- **3.3 La asamblea:** hablar o callar; reconciliación o silencio.
- **3.4 La noticia de Viracocha:** el orden antiguo termina.

### Fase 4 — La obra

- **4.1 La reconstrucción:** terraza, corral, acequia, telar y casa.
- **4.2 El nombre:** la tradición del nombre nuevo.
- **4.3 El cierre:** la familia, la casa y el territorio; variantes.

## 6. Secuencias controladas

Solo se controla al jugador cuando la puesta en escena lo exige:

| Secuencia | Por qué | Duración | Estado que deja |
|---|---|---|---|
| Asamblea de la llacta | Decisión colectiva, cámara y elenco | 2–4 min | `apoyo_*`, `comitiva` |
| Emboscada | Acción concentrada | 2–3 min | `mensaje_chanca`, `scout_spared` |
| Defensa del Cusco | Clímax, oleadas, coste | 8–12 min | `santuario_protegido`, `costo_*` |
| Asamblea de posguerra | Consecuencia y reconciliación | 3–5 min | `puma_reconciliado`, `asamblea_silencio` |
| Cierre | Epílogo y nombre | 2–3 min | `casa_reconstruida`, final |

Todo lo demás ocurre en el mundo, sin quitar el control.

## 7. Misiones secundarias y descubrimientos

La historia principal no llena el territorio. Ejemplos de contenido no principal:

- **La pastora que perdió una llama:** seguir el rastro por la quebrada; recompensa en lana y relación.
- **El telar roto:** conseguir fibra y reparar; desbloquea un tejido.
- **La ofrenda del mirador:** descubrir el altar y decidir si dejar algo.
- **El pozo seco:** limpiar la acequia; cambia el agua de la llacta.
- **El niño que quiere ver el Cusco:** acompañarlo o convencerlo de quedarse.
- **El tambo abandonado:** encontrar marcas de un viajero; abre una ruta.
- **La cueva de la quebrada:** descubrir ofrendas y una historia no contada.
- **El perro del corral:** recuperarlo antes de la noche.
- **La cuenta pendiente:** mediar entre dos familias.
- **El canto de la cosecha:** participar en la fiesta; reputación y ánimo.

Cada una debe tener contexto, conflicto, decisión y consecuencia; no solo “trae X”.

## 8. Riesgos narrativos

| Riesgo | Mitigación |
|---|---|
| La historia principal se diluye | Fases claras, diario y secuencias controladas en los clímax |
| El jugador se pierde sin marcadores | Indicaciones de NPC, hitos, mapa descubierto y guía opcional |
| La posguerra se siente vacía | Cambios visibles, NPC con duelo, tareas de reconstrucción |
| El coste pierde fuerza | El NPC perdido tiene presencia previa y su ausencia se nota en el mundo |
| El combate domina | Encuentros authored y opciones de evitarlos |
| El mundo no justifica la historia | Contenido secundario ligado a personas y lugares, no relleno |

## 9. Criterio de aceptación de la reestructuración

- [ ] Las cinco fases se juegan en la misma región, sin mapas duplicados.
- [ ] La historia principal se entiende sin haber jugado la versión lineal.
- [ ] Al menos una decisión de la fase 0 se nota en la fase 4.
- [ ] El coste de la guerra tiene un nombre y una ausencia visible.
- [ ] El jugador puede salir de la comunidad y encontrar contenido no principal.
- [ ] El final conserva el valor narrativo de *El despertar del Sol*.
- [ ] La revisión histórica aprueba la puesta en escena.
