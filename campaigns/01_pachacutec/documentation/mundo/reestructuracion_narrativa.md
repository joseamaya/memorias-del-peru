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

## 5. Estructura de la historia principal (15 misiones)

> Los títulos son provisionales. La numeración de fases es de diseño, no de guion cerrado.

| Fase | Misión | Objetivo del jugador | Decisión / consecuencia |
|---|---|---|---|
| 0 — Paz | 0.1 La mañana y los encargos | Despertar, ayudar en casa, completar tres de cuatro encargos | Recursos, oficio y relación familiar |
| 0 — Paz | 0.2 La duda | Escuchar a Puma y Asto, o callar | Reputación y línea de Puma |
| 0 — Paz | 0.3 El mensajero | Atender al mensajero agotado | Información y recurso que gasta |
| 1 — Noticia | 1.1 La asamblea | Decidir si Rumi va con la comitiva | Comitiva, Sisa y despedida |
| 1 — Noticia | 1.2 El camino | Cruzar el valle y acampar | Recursos, clima y primera evidencia |
| 1 — Noticia | 1.3 La emboscada | Pasar el paso sin ser detectado o enfrentarlo | Sigilo, herido, información |
| 1 — Noticia | 1.4 El Cusco dividido | Entrar, escuchar, reclutar y preparar | Aliados, preparación y reputación |
| 2 — Guerra | 2.1 La víspera | Preparar la defensa con el oficio elegido | Trampa, santuario y orden |
| 2 — Guerra | 2.2 La defensa | Sostener la plaza y el santuario | Oleadas y resultado del combate |
| 2 — Guerra | 2.3 El coste | Ver quién cae y qué se pierde | Coste con nombre; estado del mundo |
| 3 — Posguerra | 3.1 El regreso | Volver por el mismo camino | Refugiados, ruinas y ausencias |
| 3 — Posguerra | 3.2 Las cuentas | Visitar casas y rendir cuentas | Recursos, reputación y duelo |
| 3 — Posguerra | 3.3 La asamblea y la noticia | Hablar o callar; recibir la noticia de Viracocha | Reconciliación y fin del orden antiguo |
| 4 — Obra | 4.1 La reconstrucción | Reparar terraza, corral, acequia, telar y casa | Obras persistentes y oficio |
| 4 — Obra | 4.2 El nombre y el cierre | Vivir el nombre nuevo y cerrar la historia | Variantes de final |

### 5.1. Matriz de consecuencias

| Decisión | Se fija en | Se lee en | Efecto |
|---|---|---|---|
| `apoyo_puma` / `apoyo_curaca` / `silencio` | 0.2 | 3.3, 4.2 | Reconciliación, reputación, variante de cierre |
| Recursos `agua/maiz/manta/cuerda` | 0.1 | 1.2, 1.3, 2.1 | Aliento, ánimo, frío y distracción |
| `mensajero_ayudado` | 0.3 | 1.2, 1.3 | Información y ruta |
| `comitiva` / `sisa` | 1.1 | 1.4, 3.3 | Aliados y cierre |
| `scout_spared` / `mensaje_chanca` | 1.3 | 2.1, 3.2 | Preparación y reputación |
| `preparacion_hecha` / `santuario_protegido` | 1.4, 2.1 | 2.2, 4.1 | Defensa y obras |
| `costo_anca` / `costo_joven` | 2.3 | 3.1, 3.2, 4.2 | Duelo y variantes |
| `casa_reconstruida` / `obra_oficio` | 4.1 | 4.2 | Cierre y epílogo |

### 5.2. Contenido no principal

Las 25 experiencias de [experiencias_de_exploracion.md](experiencias_de_exploracion.md) se reparten entre las fases. Ninguna es obligatoria para avanzar, pero varias cambian relaciones, recursos o el estado del mundo. La historia principal no llena el territorio: el jugador puede pasar una tarde tejiendo, reparando una acequia o buscando una llama.

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
