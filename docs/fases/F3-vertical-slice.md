# F3 · Vertical slice de mundo abierto — tareas

**Estado:** en curso · **Apertura:** 2026-11-20.
**Precondiciones:** F2 cerrada; campaña 01 rediseñada ([docs/09](../09_biblia_narrativa.md) §3); fichas PCH-039 y PCH-040 en el registro.
**Objetivo:** demostrar que el mundo se puede **habitar y jugar**: la ciudad que se queda y el día de Carmenca.
**Alcance:** fases 1 y 2 de la campaña. Fuera: la embajada a la llacta, Xaquixaguana y el epílogo político.
**Criterio de fase:** el de [docs/05](../05_plan_de_implementacion.md) §Fase 3.

## 1. Tareas

| # | Tarea | Estado | Criterio de paso | Evidencia |
|---|---|---|---|---|
| 3.1 | Ciudad habitable | **Base implementada; falta prueba humana** | Aparición en el arrabal; arrabal, plaza y Coricancha recorribles sin huecos; 60 FPS Medio | `city_check`, `cusco_blockout_check`; 38 casas, 10 en el arrabal, 234 draw calls y 69,3 FPS |
| 3.2 | Tres interiores | **Base implementada; falta prueba humana** | Casa del jugador, casa de la curáca y taller transitables; ≤ 15 draw calls por interior | `interiors_check`; 3 puertas, 3 vestidos y vuelta exacta |
| 3.3 | Ciclo día/noche | **Base implementada; falta prueba humana** | `WorldClock` mueve sol, ambiente y niebla; amanecer, tarde y noche legibles | `day_night_check`; sin saltos en 96 muestras |
| 3.4 | Población | **Base implementada; falta prueba humana** | 24 NPC, 8 nombrados, rutinas de mañana, tarde y noche; sin atascos en 20 min | `city_population_check`; 24 y 8, 0 dentro de casas |
| 3.5 | Misión principal | **Base implementada; falta prueba humana** | Tres etapas con estado persistente y diario | `mission_check`, `city_save_round_trip` |
| 3.6 | Secundarias y descubrimiento | **Base implementada; falta prueba humana** | Dos actividades con consecuencia y un lugar descubierto sin marcador | `side_activities_check` |
| 3.7 | Descanso y guardado | **Base implementada; falta prueba humana** | Dormir avanza el día; guardar/cargar conserva hora, NPC, misión e inventario | `city_save_round_trip`; día 4 a las 8:00, 8 NPC y posición a 0,1 m |
| 3.8 | Preparación de la defensa | **Base implementada; falta prueba humana** | Fosos y púas construibles, persistentes y leídos por la batalla | `defense_works_check` |
| 3.9 | Carmenca | **Base implementada; falta prueba humana** | Tres oleadas, aliados y estandarte como objetivo; sin bloqueos | `carmenca_check` |
| 3.10 | Cierre de la slice | **Protocolo y medición listos; falta la pasada humana y la firma** | 30–45 min jugados, presupuesto medido y acta del responsable | [Protocolo](../../campaigns/01_pachacutec/documentation/prueba_vertical_slice.md), [acta](F3-acta-de-cierre.md), `measure_battle` |

## 2. F3.1 — Ciudad habitable

**Escenas:** `campaigns/01_pachacutec/scenes/world/sectors/s1_cusco.tscn` y `region_world.tscn`.
**Contenido mínimo:**

- Arrabal de Chocos-chacona en el borde oeste de S1: 8–12 casas, plaza menor, callejones, acceso a Carmenca.
- Plaza del Cusco y Coricancha exterior como hitos visibles; el resto de la ciudad se cierra con desnivel y pircas, no con una pared falsa.
- Punto de aparición movido al arrabal (`RegionWorld.SPAWN_POINT`), con vista de la plaza y de Carmenca.

**Criterio:** el jugador aparece en el arrabal y recorre arrabal → plaza → Coricancha sin huecos, sin flotantes y sin caídas; la auditoría sigue en 0 flotantes.

**Implementado (2026-11-20):**

- Arrabal de Chocos-chacona al suroeste de S1: plaza de 13 m de radio, 10 casas, callejón de 4 m hacia el camino de entrada y pirca de borde con abertura al oeste.
- Punto de aparición movido a la plaza del arrabal (1088, 294) y rumbo a la plaza del Cusco.
- Evidencia: `city_check` (10 casas de arrabal, aparición a 0 m del centro, 154 m a la plaza, jugador en el suelo), `cusco_blockout_check` (38 casas, 7 POI), auditoría con **314 mallas y 0 flotantes**, y `measure_cusco` con **234 draw calls, 184,9 MB y 69,3 FPS** de media.
- Santuario (2026-11-20): el recinto estaba al norte de la plaza; en el Cusco real está al sur. Se mueve a 86 m al sur (comprimido), con terraza de piedra de 38 × 12 m, escalinata medida contra la ladera y recinto que sobresale del muro. `CuscoSanctuary` lo construye aparte; POI-18 y el ancla de los NPC se mueven con él. Rótulo: «Santuario del Sol» (PCH-027).

## 3. F3.2 — Tres interiores

- Casa del jugador, casa de Chanan Cury Coca y taller textil.
- Puerta interactiva; interior instanciado al entrar y liberado al salir; luz propia que no depende del sol.
- Presupuesto: ≤ 15 draw calls por interior y ≤ 80 MB de memoria.

**Criterio:** entrar y salir de los tres sin huecos ni teletransportes; el guardado conserva la posición y el estado del interior.

**Implementado (2026-11-20):**

- `InteriorRoom` (core): sala cerrada de 8 × 6 × 3 m con suelo, muros, techo, luz propia y vestido por casa (`home`, `authority`, `workshop`).
- `InteriorDoor` (core, `Interactable`): puerta con marco, panel, colisionador y etiqueta «Entrar»/«Salir» por `tr()`.
- `InteriorController` (core): instancia la sala a la misma XZ de la puerta y 400 m por debajo del terreno; el streaming no cambia de celda y el mundo sigue vivo.
- Puertas colocadas en el arrabal (casa del jugador y casa de Chanan Cury Coca) y en el taller textil.
- Evidencia: `interiors_check` (3 puertas, vestidos `home`, `authority` y `workshop`, vuelta a menos de 2 m) y captura `build/evidencia/interior_home.png`.
- Guardado (3.7): la única forma de guardar es dormir, y antes de guardar se sale de la sala. La sala no tiene estado propio que conservar —su contenido lo fija la puerta—, así que la partida nunca queda apuntando a un interior que ya no existe.
- Lecho (2026-11-20): la cama con patas y colchón era anacrónica. Se sustituye por el lecho andino de **PCH-041**: poyo bajo de piedra de 0,32 m, estera de totora y manta doblada. La puerta de la casa del jugador lleva la leyenda «Tu casa» para no confundirla con la de la curáca, que tiene el mismo mueble sin interacción.
- Etiquetas (2026-11-20): el modo de revisión del blockout ocultaba **todas** las `Label3D` de los sectores, incluidas las de las puertas, así que «Entrar» nunca se veía. Ahora solo gobierna las de POI (`review_label`); las de interacción quedan siempre visibles y `interiors_check` lo comprueba. La leyenda se separa además del panel, donde quedaba embebida.
- Mano de interacción (2026-11-21): el antebrazo del maniquí venía del prototipo a escala 0,52 y centrado; con la antorcha encendida de noche tapaba media pantalla. Ahora la mano entra desde la esquina inferior derecha, a escala 0,42, y el antebrazo sale de cuadro. Evidencia: `mano_puerta.png`, `mano_agua.png` y `mano_despues_dia.png`.

## 4. F3.3 — Ciclo día/noche

`WorldClock` (ya existe) pasa a gobernar el sol, el ambiente, la niebla y la exposición. Franjas legibles: amanecer, mañana, mediodía, tarde, noche. Los interiores usan luz propia.

**Criterio:** a las 07:00, 13:00, 19:00 y 23:00 la luz es distinguible y no hay saltos al cambiar de hora; el perfil Medio mantiene 60 FPS.

**Implementado (2026-11-20):**

- `DayNightCycle` en `core/world`: lee `WorldClock` y mueve el sol (elevación y azimut), su color y energía, y el ambiente, la niebla y la luz de relleno.
- A mediodía conserva los valores del blockout aprobado; amanecer, atardecer y noche son reconstrucción de ambiente (R).
- La energía del sol entra con una rampa suave desde el horizonte: sin ella saltaba de 0 a 0,26 en quince minutos.
- Evidencia: `day_night_check` (96 muestras cada 15 min, sin saltos; noche a 0 de energía y ambiente 0,35) y capturas `day_dawn`, `day_noon`, `day_dusk` y `day_night`.

**Pendiente resuelto (2026-11-21) — antorcha de mano:**

- `PlayerLantern` en `core/player`: antorcha en la mano izquierda que se enciende sola al caer el sol y se apaga de día. Comparte con `DayNightCycle` la fórmula de luz diurna (`daylight_at`), así que no hay dos relojes que se contradigan.
- Luz `OmniLight3D` de 10 m, cálida y **sin sombras**, con un parpadeo leve. El nivel es 0 con sol y sube de forma gradual en el atardecer.
- Cierra el pendiente anotado en la bitácora el 2026-11-20: hasta ahora no se podía jugar de noche.
- Evidencia: `lantern_check` (apagada a mediodía, encendida a las 22:00, encendido gradual de 17:00 a 19:00) y captura `build/evidencia/noche_antorcha.png`.

## 5. F3.4 — Población

- 24 NPC activos en S1, 8 de ellos nombrados con rol y casa. Entre ellos, Chanan Cury Coca.
- Rutinas de mañana, tarde y noche con `NpcDirector`, `ScheduleEntry` y `NpcMover` sobre el navmesh de S1.
- LOD: 24 activos, 12 animados; los lejanos se simulan sin malla.

**Criterio:** 20 min de recorrido sin atascos ni NPC atravesando muros; el estado de los NPC sobrevive al guardado.

**Implementado (2026-11-20):**

- `CityPopulation` en campaña: 24 NPC (8 nombrados) con casa, mañana, tarde y noche sobre 11 anclas del sector; usa `NpcDirector`, `NpcDefinition` y `ScheduleEntry` de Core.
- Nombres en la tabla de localización; Chanan Cury Coca incluida como NPC narrativo.
- El navmesh de S1 sigue siendo de terreno: las anclas se colocaron con holgura de las casas y la prueba simula 20 min comprobando que nadie queda dentro de una huella. Se probó a tallar las casas en el navmesh, pero desconectaba los enlaces entre sectores y rompía el recorrido regional; queda pendiente con otra técnica.
- El destino de cada NPC se calcula sobre el suelo del punto desplazado por el anillo, no sobre la altura del ancla: en pendiente el NPC quedaba enterrado o flotando hasta 0,7 m. `NpcDirector` acepta un muestreador de altura y la carga corrige la Y guardada.
- Evidencia: `city_population_check` (24/8, 0 dentro de casas, 8 nombrados a 0,9 ± 0,10 m del suelo) y `build/evidencia/city_population.png`.

## 6. F3.5 — Misión principal

Tres etapas, sin sistema genérico de misiones: recursos de misión y banderas en `WorldState`.

1. **La mañana del arrabal:** encargos cotidianos, rumores de la retirada y presentación del ayllu.
2. **La partida:** Viracocha abandona la ciudad; el jugador se queda y ayuda a preparar la defensa.
3. **Carmenca:** el asalto y la resistencia hasta la retirada chanca.

**Criterio:** la misión avanza y termina con una consecuencia persistente; se puede guardar y cargar en cualquier etapa sin perder estado.

**Implementado (2026-11-21) — capa de conversación y diario (3.5.a):**

- HUD de Core instanciado en el mundo regional, con retícula, interacción y aliento.
- `DialoguePresenter` (Core): conecta `DialogueRunner` con el HUD, siembra las banderas del mundo, escribe en `WorldState` las que fija el diálogo y bloquea al jugador mientras habla.
- `NpcInteractable` (Core): colisionador en la capa `interactable` sobre los NPC con `dialogue_id`; el rótulo es «Hablar · <nombre>». Solo existen mientras el LOD mantiene al NPC.
- Diario abierto y cerrado con **J**; Esc también lo cierra. Queda pendiente el contenido de la misión (3.5.b).
- Seis grafos de diálogo en `data/dialogues/` (curáca, molendera, tejedora, agricultor, mensajero y la partida) con textos en la tabla de la campaña.
- Evidencia: `dialogue_check` (6 grafos, bandera `m01_encargos`, diario) y captura `build/evidencia/dialogo_curaca.png`.

**Implementado (2026-11-21) — misión (3.5.b):**

- `MissionDefinition` y `MissionStage` en `data/missions/m01_la_ciudad_que_se_queda.tres`: tres etapas con sus banderas, sin motor genérico.
- Etapa 1, «La mañana del arrabal»: la curáca pide agua, lana y maíz; cada encargo se acepta en una conversación y se cumple en un punto del mundo (`FlagInteractable`: pila del arrabal, atado del taller y saco de los depósitos).
- Etapa 2, «La partida»: una columna de vecinos y orejones abandona la ciudad hacia el oeste; la curáca cambia de conversación y el jugador se queda.
- Etapa 3, «Carmenca»: se arma con la fase de guerra y la cierra la batalla (3.9) con la bandera `m01_victoria`.
- Diario reconstruido desde la etapa guardada; guardado y carga a mitad de misión probados.
- Evidencia: `mission_check` (etapas 1→2→3, tres puntos, partida, fase `guerra`, guardado y carga, diario de 3 entradas) y capturas `mision_partida.png` y `mision_diario.png`.

## 7. F3.6 — Secundarias y descubrimiento

- **Social:** mediar entre dos familias por el turno del agua o del horno; la decisión deja reputación.
- **Económica:** preparar chicha o tejer una manta para quien va a la defensa; el objeto se usa en la batalla.
- **Descubrimiento sin marcador:** el mirador sobre Carmenca, desde donde se ven las tiendas chancas.

**Criterio:** ninguna es un recado vacío; la consecuencia se lee en el mundo o en el diario; el descubrimiento se registra sin marcador.

**Implementado (2026-11-21) — social y económica:**

- `SideActivities` (campaña): escucha las banderas de `WorldState`, cambia la conversación de la molendera, el agricultor y la tejedora, y escribe el diario. Al cargar se reconstruye desde las banderas; no serializa nada aparte.
- **El turno del agua:** al entregar el agua, la molendera plantea el reparto entre la molienda y la chacra. Tres desenlaces (molienda, chacra, turnos) dejan su bandera, su contador de reputación (`rep_molendera`, `rep_chacra`) y una **memoria propia** en el diario con clasificación. La molendera y el agricultor cambian de conversación después.
- **La manta:** al entregar la lana, la tejedora pide una manta para quien salga a la defensa. El telar del taller —los tres postes que ya dibujaba el blockout— la teje; la manta queda colgada y visible. En 3.9 reducirá el daño recibido.
- Evidencia: `side_activities_check` (dos cadenas, negativo del telar sin encargo, diario y guardado/carga) y capturas `secundaria_telar.png` y `secundaria_diario.png`.
- **Descubrimiento sin marcador:** el **mirador de Carmenca**, en S2, marcado por un montón de piedras (apacheta) y con el campamento chanca a la vista. El POI-31 se descubre por proximidad, sin etiqueta ni marcador, y al descubrirlo el diario recibe su memoria y el HUD avisa una sola vez.
- Evidencia de 3.6.b: `mirador_check` (descubrimiento por radio, negativo antes de llegar, campamento de 12 tiendas y carga sin duplicar la memoria) y captura `mirador_carmenca.png`.
- El campamento son tiendas de bloqueo: en 3.9 se poblará para la batalla. La apacheta entra en la lista de elementos apilados a propósito de la auditoría de flotantes.

## 8. F3.7 — Descanso y guardado

Dormir en la casa del jugador avanza a la mañana siguiente. Guardar desde la cama; cargar restaura hora, NPC, misión, inventario y obras.

**Criterio:** ciclo guardar → salir → cargar conserva los cinco estados y la hora avanzada.

**Implementado (2026-11-20):**

- `RestCycle` (Core): la hora de despertar es la misma con la que empieza la partida, **8:00**; dormir después de esa hora salta al día siguiente.
- `SleepSpotInteractable` (Core): el lecho solo responde dentro de una sesión de campaña y pide el descanso por grupo (`campaign_session`). Solo la casa del jugador tiene lecho utilizable.
- `CampaignSession` (campaña): al dormir sale del interior de bolsillo, avanza el reloj, despierta a los NPC en su ancla de mañana y guarda la ranura `auto`. El payload lleva posición, orientación, `CampaignState` (misión e inventario) e instantánea de los 8 NPC con nombre; las obras van en `WorldState.changes`.
- `SleepOverlay` (Core): fundido negro con «Has dormido hasta la mañana · Día N · 08:00 · Partida guardada».
- `SaveManager`: carga pendiente (`request_load` / `consume_pending_load`) y ranura `AUTO_SLOT`.
- `TitleScreen`: botón **Continuar**, activo solo si existe la ranura; «Comenzar» cancela la carga y reinicia mundo, reloj y banderas.
- `CampaignInfo.id`: identificador estable de campaña que da nombre a su carpeta de guardado.
- Límite conocido: misión e inventario todavía no existen como sistemas (llegan con 3.5 y 3.6); su canal de guardado (`player.campaign`) está implementado y probado con datos de esa forma. Las obras se probaron con `WorldState.set_change`, que es la API de 3.8.
- Evidencia: `city_save_round_trip` (día 4 a las 8:00, 8 NPC restaurados, posición a 0,1 m) y capturas `rest_bed`, `rest_sleep`, `rest_morning` y `title_continue`.

## 9. F3.8 — Preparación de la defensa

Fosos con piedra tapados con ramas y púas de palma (PCH-039). De tres a cinco puntos construibles en los accesos del arrabal. Cada obra es una modificación persistente del mundo y la batalla la lee.

**Criterio:** construir, guardar y cargar conserva las obras; en la batalla, una obra reduce o daña la oleada correspondiente.

**Implementado (2026-11-21):**

- `DefenseWorks` (campaña): **cuatro puntos** en el anillo oeste y sur del arrabal. Antes de construir se ve el foso abierto (tierra removida con borde de piedra); al construirlo, se cubre con ramas y nueve púas de palma.
- `ChangeInteractable` (Core): hermano de `FlagInteractable` para las obras; escribe en `WorldState.changes` y deja de responder una vez hecho.
- Solo se puede construir después de decidir quedarse (`m01_queda`): el punto existe, pero no responde antes.
- Persistencia: la obra vive en `WorldState.changes`, que ya viaja en el guardado; al cargar se reconstruye la geometría cubierta.
- La geometría usa el rango de altura de las esquinas: la tapa va arriba y el borde baja hasta el suelo, así no flota en la ladera.
- Evidencia: `defense_works_check` (4 obras, negativo antes de quedarse, construcción, guardado/carga y recuento) y capturas `defensa_fosos.png`, `defensa_foso_abierto.png` y `defensa_foso_cubierto.png`.
- **Falta** la lectura por la batalla: 3.9 hará que cada obra desgaste la oleada de su acceso.

## 10. F3.9 — Carmenca

- Cerro al oeste con la bajada chanca y los accesos documentados.
- Tres oleadas con encuentros authored; aliados de Cusi Yupanqui; estandarte como objetivo final.
- Armas: honda (a distancia) y porra (cuerpo a cuerpo). Sin hacha de guerra salvo como útil de trabajo.
- Sin ejército simulado: máximo 25 enemigos activos y 10 aliados.

**Criterio:** la defensa se puede completar sin bloqueos; perder reinicia la oleada, no la partida; el presupuesto se mantiene.

**Implementado (2026-11-21) — combate del jugador (3.9.a):**

- `PlayerCombat` (Core): envuelve `CharacterState`, `Combatant` y `CombatLoadout` y añade lo que falta: entrada del jugador, rayo hacia el enemigo, arma en pantalla, aviso de munición y daño con parry o bloqueo. Desarmado no hay arma ni golpes; la batalla lo arma.
- Armas: honda (a distancia, 12 piedras), porra (cuerpo a cuerpo) y escudo (bloqueo y parry). Cambio con 1, 2 y 3; ataque con el botón de ataque y carga por pulsación.
- `ChancaWarrior` (campaña): cápsula de bloqueo con `EnemyCombatant`, se acerca, ataca con porra y cae. Sin ejército simulado.
- El HUD recibe salud, estallido de daño y munición sin conocer la campaña.
- Evidencia: `combat_check` (desarme, golpe que quita salud, golpe recibido, escudo que absorbe 6 de 20 y honda que gasta piedra) y captura `combate_chanca.png`.
- **Falta** para cerrar 3.9: las tres oleadas, los aliados, el estandarte, la derrota que reinicia la oleada y el cierre de la misión (3.9.b).

**Implementado (2026-11-21) — la batalla (3.9.b):**

- `CarmencaBattle`: se dispara al **entrar en el campamento** (30 m del estandarte) con la etapa 3. El centro es el de las tiendas de `CarmencaOverlook`, no un punto intermedio: el mirador queda a 42 m y se puede descubrir sin que empiece la batalla. Tres oleadas de 4, 6 y 8 chancas; **cada obra construida resta un enemigo por oleada**, hasta dos. Nunca hay más de 8 enemigos ni más de 6 aliados.
- **Aliados:** seis vecinos (`AlliedWarrior`) que buscan al chanca más cercano, se le acercan y golpean; si no queda ninguno, vuelven junto al jugador.
- **Estandarte:** en el centro del campamento; al caer la tercera oleada se activa y llegar a él fija `m01_victoria` y cierra la misión.
- **Derrota:** caer reinicia la oleada actual (no la partida): se limpian los chancas, se revive al jugador, se le devuelve al borde este del campamento (20 m, fuera del anillo de aparición) junto con los aliados y la oleada vuelve a empezar. Ningún chanca aparece a menos de 6 m del jugador.
- **Manta:** con `s01_manta` el daño recibido baja al 85 %.
- **Director:** máximo dos chancas atacan a la vez; se separan para no solaparse. El chanca colisiona con el jugador y se detiene a 1,15 m, así no se mete en la cámara.
- La batalla **no se serializa**: guardar durante el combate devuelve a la etapa 3 antes de empezar.
- Evidencia: `carmenca_check` (radio de activación por fuera y por dentro, porra inicial y aviso de teclas, tres oleadas, obras que restan, aliados, derrota con reaparición y aliados, estandarte, victoria y diario) y captura `batalla_carmenca.png`.

## 11. F3.10 — Cierre de la slice

- Pasada humana de 30–45 min con contenido no principal.
- Medición por sector y perfil (Medio y Bajo).
- Acta del responsable con decisión: continuar, recortar o replantear.

**Preparado (2026-11-21):**

- **Protocolo humano:** [prueba_vertical_slice.md](../../campaigns/01_pachacutec/documentation/prueba_vertical_slice.md), ocho bloques cronometrados de la mañana del arrabal al estandarte, con registro de incidencias. Falta la pasada del responsable.
- **Medición F3:** S1 y la batalla de Carmenca, perfil Medio y Bajo, tres pasadas por caso, 1920 × 1080 y vsync libre. Nueva escena `tests/scenes/measure_battle.tscn`, que fuerza la oleada de ocho chancas con los seis aliados y muestrea 300 fotogramas.
  - S1: **66,4 FPS** de mediana en Medio y **61,0** en Bajo; 253 draw calls y 185 MB.
  - Batalla: **66,7 FPS** de mediana en Medio y **61,1** en Bajo; 248 draw calls, 673.578 primitivas y 190 MB; peor fotograma de 24,0 ms.
  - Todo dentro del presupuesto (§13). Detalle y observaciones en el [acta](F3-acta-de-cierre.md) §2.
- **Acta:** [F3-acta-de-cierre.md](F3-acta-de-cierre.md). Borrador con medición, deuda declarada y decisión pendiente de firma.

**Actualizado (2026-11-24):**

- Protocolo v1.2: 15 regresiones (incluye ratón, diálogo, derrota y NPC en el suelo).
- Acta 0.11: recuento real de **140 pruebas en 62 archivos** y correcciones del lote #56–#60 (§19). La medición de §2 no se repitió tras el traslado del campamento; no añade geometría.
- Sigue faltando la pasada humana y la firma.
- **Fallo corregido en el cierre:** al morir un chanca, su nodo se liberaba a los 1,4 s y la batalla seguía guardando la referencia en su lista; al recorrerla, GDScript lanzaba «Trying to assign invalid previously freed instance» cada fotograma. Ahora el chanca se quita de la lista al salir del árbol (`_forget_enemy`) y `carmenca_check` lo comprueba esperando a que uno caiga y se libere.

## 12. Orden de trabajo y dependencias

| Orden | Tarea | Depende de |
|---|---|---|
| 1 | 3.1 Ciudad habitable | F2 |
| 2 | 3.2 Interiores | 3.1 |
| 3 | 3.3 Día/noche | 3.1 |
| 4 | 3.7 Descanso y guardado | 3.2, 3.3 |
| 5 | 3.4 Población | 3.1, 3.3 |
| 6 | 3.5 Misión principal | 3.4, 3.7 |
| 7 | 3.6 Secundarias | 3.5 |
| 8 | 3.8 Preparación de la defensa | 3.5 |
| 9 | 3.9 Carmenca | 3.8 |
| 10 | 3.10 Cierre | todas |

## 13. Presupuesto

| Métrica | Límite | Dónde se mide |
|---|---|---|
| Draw calls por sector | ≤ 350 | `scene_audit.gd` y `measure_cusco.tscn` |
| Memoria de vídeo | ≤ 250 MB | `measure_cusco.tscn` |
| FPS | ≥ 30 Bajo / ≥ 60 Medio, 1080p, UHD 770 | `measure_cusco.tscn` y `measure_battle.tscn` |
| Hitch | < 50 ms | `sector_streaming_check.gd` y `measure_battle.tscn` |
| Carga de sector | < 150 ms | `sector_streaming_check.gd` |
| Interiores | ≤ 15 draw calls cada uno | `scene_audit.gd` |

## 14. Orden de recorte

Si no cabe, se recorta en este orden:

1. **F3.6** (secundarias y descubrimiento): se posponen a F4.
2. **Población**: de 24 NPC a 16, manteniendo los 8 nombrados.
3. **Interiores**: de tres a uno (la casa del jugador).
4. **Carmenca**: de tres oleadas a una, con el estandarte como objetivo.

**No se recorta nunca:** guardado/carga, misión principal y presupuesto medido.

## 15. Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| La IA de oleadas se atasca o se desborda | Alto | Encuentros authored, máximo 25 enemigos, perder reinicia la oleada |
| Los interiores se comen el presupuesto | Medio | Instanciar al entrar, luz propia barata, medir con `scene_audit` |
| 24 NPC en callejones estrechos | Alto | Navmesh revisado por sector, rutas cortas y LOD |
| El día/noche rompe la lectura del blockout | Bajo | Franjas fijas para revisión y captura |
| S1 crece de blockout a hub jugable | Alto | Recorte declarado y entrega por tareas |

## 16. Criterio de cierre

- [ ] Sector S1 jugable: arrabal, plaza y Coricancha sin huecos ni flotantes.
- [ ] Tres interiores transitables.
- [ ] Ciclo día/noche con descanso funcional.
- [ ] 20–30 NPC, 8 nombrados, con rutinas de mañana, tarde y noche.
- [ ] Misión principal de tres etapas con consecuencia persistente.
- [ ] Dos actividades secundarias con sentido social o económico.
- [ ] Un descubrimiento sin marcador.
- [ ] Preparación de la defensa persistente y leída por la batalla.
- [ ] Carmenca completable sin bloqueos.
- [ ] Guardado/carga conserva misión, NPC, inventario, hora y obras.
- [ ] ≥ 30 FPS en Bajo y ≥ 60 FPS en Medio; ≤ 350 draw calls; ≤ 250 MB; hitch < 50 ms; carga de sector < 150 ms.
- [ ] Cero errores y advertencias de GDScript procedentes de `res://`.
- [ ] Suite y recorrido de la slice en verde.
- [ ] 30–45 min de juego real en una pasada humana, con contenido no principal.
- [ ] 100 % del contenido usado clasificado y con fuente.
- [ ] Acta de revisión con decisión: continuar, recortar o replantear.

## 17. Deuda de arte declarada

La slice se aprueba en **blockout**: los sistemas, el contenido y el flujo están probados, pero casi todo lo que se ve es geometría de bloqueo. Esta lista evita que la deuda se confunda con un fallo y sirve de entrada a F4.

| Área | Estado en F3 | Qué falta |
|---|---|---|
| Arquitectura | Casas, muros, plaza y Coricancha con `BlockoutKit`: cajas, pircas y tejados planos; sin texturas | Modelos y materiales finales por tipología; vanos, dinteles, cubiertas y desgaste |
| Personajes | Jugador maniquí; NPC como cápsulas vestidas con cabeza cónica | Mallas, ropa, peinados y variantes; sin animaciones de trabajo, conversación o combate propias |
| Interiores | Tres salas de 8 × 6 × 3 m con vestido de bloqueo y luz propia | Mobiliario, textiles y objetos domésticos finales; vestidos por casa |
| Campamento chanca | Doce tiendas de bloqueo, empalizada y estandarte de cajas | Tiendas, pertrechos, estandarte y atrezo de campamento |
| Obras de defensa | Foso con borde de piedra, tapa de ramas y nueve púas de caja | Foso, ramas, piedra y púas finales; variantes por acceso |
| Mirador | Terraza de piedra con parapeto y apacheta de cantos | Piedra, parapeto y apacheta finales; vegetación de altura |
| Naturaleza | Terreno con paleta plana; sin texturas ni vegetación de detalle | Terreno texturizado, pastos, arbustos y rocas; LOD de vegetación |
| Cielo y luz | `DayNightCycle` mueve sol, ambiente y niebla; sin cielo ni nubes finales | Cielo, nubes, bruma y exposición finales por franja |
| Audio | Música y ambientes sustitutos declarados en [docs/07](../07_convenciones_historicas.md) §4; pasos de botas filtrados | Registros propios del altiplano, pasos de ojota, voces y mezcla |
| Interfaz | HUD de Core funcional con tipografía y paneles de trabajo | Arte de HUD, iconos, retícula y diario; revisión de accesibilidad |
| Personajes secundarios | Sin retratos ni voces; nombre y rol por tabla de localización | Retratos o modelos de apoyo, si el responsable los aprueba |

No es deuda de arte la **batalla sin serializar** ni el **navmesh de terreno**: son límites de diseño declarados, no falta de producción.

## 18. Correcciones de la revisión (2026-11-21)

Una revisión de la partida real detectó fallos que la suite no cubría. Se corrigieron en una rama propia (`fix/f3-correcciones-revision`) y cada uno tiene prueba o comprobación dirigida.

| Área | Corrección | Evidencia |
|---|---|---|
| Exportación | Diálogos y POI se listan con `ResourceLoader.list_directory`, que resuelve `.tres.remap`; antes el build cargaba 0 de 11 y 0 de 31 | `test_resource_catalog`; `.pck` exportado y montado: 11/31 recursos lógicos |
| Etapa 1 | El reparto del agua ya no cambia al agricultor a la conversación de eco si aún no dio `m01_maiz_pedido`; el cambio llega cuando lo da | `side_activities_check` |
| Etapa 2 | `MissionController` reaplica la conversación de la curáca cuando la población termina de construirse | `mission_stage2_check` |
| Carmenca | La batalla no se reinicia con `m01_victoria`; el diario cierra la etapa al cargar | `carmenca_check` |
| NPC | El actor vive en el centro del cuerpo (`BODY_OFFSET`), la conversación alcanza la cabeza; un NPC que estuvo dormido retoma su ruta al reaparecer | `city_population_check`, `npc_lod_check` |
| Manta | Al cargar con la lana entregada se vuelve a ofrecer la manta aunque no se hubiera aceptado | `side_manta_load_check` |
| Descubrimientos | El servicio se resincroniza con `WorldState` después de cargar | `mirador_check` |
| HUD | El aviso «Hablar» se limpia al perder el foco; la munición solo se ve con la honda en la mano; el arma no reaparece al cerrar el diario si estaba desarmado | `test_hud_interaction`, `test_combat_input`, `test_player_camera_dialogue` |
| Combate | La batalla empieza con la porra y avisa de las teclas; el clic del escudo suelta el bloqueo; el aturdimiento no adelanta la espera | `carmenca_check`, `test_combat_input`, `test_combat` |
| Derrota | Al caer se vuelve al campamento (8 m del estandarte), no a la casa a 320 m | `carmenca_check` |
| Pausa y salto | Esc abre un menú con continuar, volver al título y salir; la acción `jump` despega en el suelo | `test_pause_menu`, `test_jump`, `region_player_check` |
| Ayuda de desarrollo | La etiqueta fija solo queda en la vista de revisión; en partida se muestra el aviso temporal de controles | `region_review_check`, `region_player_check` |
| Guardado | Se aparta la ranura anterior como `.bak` antes de renombrar el temporal y `load_slot` la recupera; las pruebas guardan en `user://test-saves` | `test_save_round_trip`, `city_save_round_trip` |

**Validación ejecutada:** suite completa en verde, recorridos de integración afectados en verde, `gdlint` y `gdformat --check` en los archivos nuevos, importación de las tablas de traducción, exportación Linux/Windows y arranque headless del build de Linux. **No verificado:** la pasada humana de 3.10, la ejecución del `.exe` de Windows y el arranque interactivo del binario exportado.

## 19. Correcciones de la revisión jugada (2026-11-24)

Una segunda pasada sobre la partida real encontró fallos que las pruebas no cubrían porque medían el caso feliz, no el umbral ni el estado de entrada. Se corrigieron en cinco ramas por área, con una prueba o comprobación dirigida por fallo. Las afirmaciones de §18 sobre la porra, el aviso de teclas y el respawn de 8 m no estaban cubiertas por `carmenca_check`; quedan sustituidas por las de esta sección.

| Área | Corrección | Evidencia |
|---|---|---|
| Carmenca | El estandarte y el radio de activación cuelgan del campamento de las tiendas; el radio baja a 30 m, así que el mirador (42 m) se descubre antes de la batalla. La derrota devuelve al borde este (20 m), mirando al campamento y con los aliados; ningún chanca nace a menos de 6 m del jugador | `carmenca_check` |
| Entrada y pausa | «Volver al título» y la pantalla de título dejan el puntero visible; el diálogo no avanza ni elige con el árbol en pausa; un clic fuera del diario no recaptura el ratón; el foco de interacción detecta instancias liberadas y retira el aviso | `test_dialogue_panel`, `test_mouse_capture_requires_focus`, `test_interaction_focus`; el puntero al volver al título, en la pasada humana |
| Combate | La suelta de ataque y escudo se atiende siempre; si llega con los controles bloqueados o en pausa, cancela la carga sin golpear. La carga también se cancela si la suelta se perdió | `test_combat_input` |
| NPC | El destino se calcula sobre el suelo del punto desplazado por el anillo, no sobre la altura del ancla; la carga corrige la Y guardada. Los 8 NPC nombrados quedan a 0,9 ± 0,10 m del suelo | `city_population_check`, `test_npc_ground_goal` |
| Guardado y robustez | `load_slot` reintenta con `.bak` si el principal está corrupto o el esquema no vale; el atuendo tolera una pieza nula | `test_save_round_trip`, `test_character_outfit` |
| Pruebas | `carmenca_check`, `mission_stage2_check` y `defense_works_check` imprimen cada paso con etiqueta y nombran los fallidos. El catálogo exige 11 diálogos y 31 POI por las entradas reales. La etapa 2 fija `m01_queda` recorriendo el grafo de la curáca | Los tres recorridos en verde (`CARMENCA_OK pasos=55`, `STAGE2_OK pasos=18`, `DEFENSE_OK pasos=27`) y `test_resource_catalog` |
| Documentación | El protocolo corrige quién reparte los encargos (la curáca encarga; la molendera, la tejedora y el agricultor aceptan) y deja de presentar `test_resource_catalog` como cobertura del build exportado | [Protocolo](../../campaigns/01_pachacutec/documentation/prueba_vertical_slice.md) §3 y §3.1 |

**Validación ejecutada:** suite completa en verde; `carmenca_check`, `mission_stage2_check`, `defense_works_check`, `city_population_check`, `city_save_round_trip`, `npc_lod_check`, `dialogue_check` e `interiors_check` en verde; `tools/check_test_inventory.py` y `tools/check_gdscript_limits.py` en verde; `gdlint` y `gdformat --check` limpios en los archivos nuevos y reescritos; CI de los cinco PRs en verde (pruebas, lint, inventario y exportación Linux/Windows). **No verificado:** la pasada humana de 3.10 y el modo de ratón en headless (se comprueba en la pasada).

## 20. Correcciones de la segunda revisión jugada (2026-11-24)

La segunda revisión confirmó nueve fallos: dos de entrada, dos del campamento y cinco de cobertura de las pruebas. Se corrigieron en una rama con tres commits por área; cada uno tiene prueba dirigida.

| Área | Corrección | Evidencia |
|---|---|---|
| Ratón | Al liberar los controles se reintenta la captura; cubre el diálogo pausado o con alt-tab y el diario, que tampoco recapturaba | `test_player_mouse_unlock`; el modo real se comprueba en la pasada humana |
| Escudo | El botón derecho guarda su estado y baja en `_process` si la suelta se perdió en pausa o al cambiar de ventana | `test_combat_input` |
| Aliados | Esperan detrás del jugador y ceden en diagonal si los tiene encima; ya no se plantan de frente en la entrada del campamento | `test_allied_follow`, `carmenca_check` |
| Tiendas | Cada tienda lleva la colisión convexa de su cono; el jugador no la atraviesa | `mirador_check` (doce tiendas con `Collision`) |
| Aparición | El anillo se extrae a `CarmencaSpawn.offset` y `carmenca_check` coloca al jugador sobre un hueco de la oleada 2; el paso falla si se desactiva el reflejo | `test_carmenca_spawn`, `carmenca_check` (`pasos=56`) |
| Robustez | `carmenca_check` y `defense_works_check` comprueban el mundo y el foso antes de usarlos y salen con `quit(1)` informando del paso | Los dos recorridos en verde con las guardas |
| Aislamiento | `run_tests.gd` limpia `WorldState` antes de cada archivo; el catálogo ya no contagia descubrimientos | `run_tests` completo en verde |
| Altura al caminar | `NpcMover` aplica el muestreador de suelo en cada tramo | `test_npc_walk_height`, `city_population_check`, `grey_sector_check` |

**Validación ejecutada:** 153 métodos `test_` en verde; `carmenca_check` (`CARMENCA_OK pasos=56`), `defense_works_check` (`DEFENSE_OK pasos=27`), `mirador_check`, `city_population_check`, `grey_sector_check`, `npc_lod_check` y `dialogue_check` en verde; `tools/check_test_inventory.py` y `tools/check_gdscript_limits.py` en verde; `gdlint` limpio en los archivos nuevos y `gdformat --check` limpio en los nuevos y en los tocados que ya estaban formateados (`player_fps.gd` queda sin reformatear por ser heredado). Se comprobó por mutación que el paso de aparición falla al desactivar el reflejo. **No verificado:** el modo de ratón real (headless lee siempre `VISIBLE`), la pasada humana y el presupuesto del sector con las doce colisiones nuevas.

## 21. Correcciones de la revisión de la batalla (2026-11-25)

La revisión de la entrega anterior encontró que la batalla ya no se cerraba: con el jugador quieto, la oleada 1 tardaba 91 s y la 3 no terminaba en 7 min. La causa era doble: el hueco 1 de la oleada 1 nacía dentro de la tienda 4 y los chancas y aliados iban en línea recta contra las tiendas, que ahora tienen colisión. La bitácora del PR anterior declaraba la limitación del navmesh, pero no medía su efecto en la batalla.

| Área | Corrección | Evidencia |
|---|---|---|
| Campamento | `CampLayout` es la única fuente de las doce tiendas: la usan el mirador, la batalla y la aparición | `test_camp_avoidance`, `mirador_check` (12 tiendas) |
| Aparición | `CarmencaSpawn` busca un hueco libre de tiendas con radios y ángulos crecientes, conserva el reflejo por distancia al jugador y los aliados usan el mismo despeje | `test_carmenca_spawn`, `test_camp_avoidance` |
| Movimiento | `CampAvoidance.steer` añade una componente tangencial al rodear una tienda y desempata el caso radial; lo aplican chancas y aliados | `test_camp_avoidance` (simulación de cada hueco), `carmenca_flow_check` |
| Aliados | Seis huecos distintos (tres columnas por dos filas) y órbita del espacio personal en vez del ciclo de ceder y volver al punto | `test_allied_follow`, `carmenca_flow_check` |
| Pruebas | `carmenca_check` comprueba el mundo antes de añadir; `carmenca_flow_check` deja al jugador quieto, juega las tres oleadas (2, 4 y 6) y exige cerrarlas en ≤ 90 s | `CARMENCA_FLOW_OK pasos=14` (tres oleadas en 46,3 s; aliados separados en 7,5 s) y CI |

**Validación ejecutada:** 165 métodos `test_` en verde; `carmenca_check` (`CARMENCA_OK pasos=58`), `carmenca_flow_check` (`CARMENCA_FLOW_OK pasos=14`, tres oleadas en 46,3 s y aliados separados en 7,5 s), `mirador_check` (`tiendas=12`); `tools/check_test_inventory.py` (67 archivos, 32 recorridos) y `tools/check_gdscript_limits.py` en verde; `gdlint` y `gdformat --check` limpios en los archivos nuevos y tocados. **No verificado:** la pasada humana y la comparación de 60 s del revisor con su bot. La medición de rendimiento se repitió después del merge y queda en §22.

## 22. Verificación en main (2026-11-25)

Tras el merge del PR #63 se repitieron las comprobaciones que la entrega dejaba abiertas.

| Comprobación | Resultado |
|---|---|
| Flujo completo | `CARMENCA_FLOW_OK pasos=14`: tres oleadas (2/4/6) en **46,3 s** con el jugador quieto; aliados separados en **7,5 s** |
| `measure_battle` Medio | 70,8 · 71,9 · 70,5 FPS (mediana **70,8**); p1 54,8–66,0; 261 draw calls; 698.066 primitivas; 183,4 MB; peor fotograma 22,6 ms |
| `measure_battle` Bajo | 65,3 · 68,6 · 68,6 FPS (mediana **68,6**); p1 43,0–53,0; 265 draw calls; 698.574 primitivas; 181,2 MB; peor fotograma 26,6 ms |
| Captura | `build/evidencia/batalla_carmenca_oleada3.png`, con el HUD «Chancas 3 · oleada 3 de 3» y los chancas entre las tiendas |

Todo queda bajo el presupuesto de [docs/08](../08_entorno_y_rendimiento.md) §4.2. La mediana de p1 Bajo es 53,0 (77,3 % de su media); una primera pasada quedó en 43,0 (65,8 %) con carga 1,82 y se anota como atípica. Sigue pendiente la pasada humana y la comparación con el bot del revisor.

## 23. Correcciones de la revisión de aliados y chancas (2026-11-25)

La revisión posterior al merge del PR #63 encontró cinco fallos que el flujo no cubría: los aliados temblaban con una tienda a la espalda, se apilaban en combate, algunos chancas esperaban quietos a 24 m, el protocolo pedía observarlos después de una victoria que los retira y el respaldo de aparición no miraba las tiendas.

| Área | Corrección | Evidencia |
|---|---|---|
| Formación | `AlliedFormation` resuelve los seis puestos en orden y de forma determinista: si una tienda ocupa un hueco, gira alrededor del jugador, conserva el radio y exige separación entre puestos. No se usa `clear_near` por aliado porque los dos huecos de la fila central acababan en el mismo punto (0,00 m) y dos parejas a 0,65 m. | `test_allied_follow`, `carmenca_flow_check` |
| Seguimiento | El aliado que queda dentro de una tienda sale hacia su puesto; la órbita del espacio personal ya no lo empuja hacia la tienda, y si la salida radial está ocupada primero rodea. | `test_allied_follow` (salida de tienda y borde sin oscilación) |
| Combate | `AlliedFormation.separate_velocity` cancela el acercamiento, empuja en radial y rodea al compañero en tangencial. Se aplica antes y después de la evitación de tiendas. | `carmenca_flow_check` (hueco mínimo **1,05 m** en las tres oleadas) |
| Chancas | `ChancaWarrior.ALERT_RADIUS = 40` cubre el anillo de 24 m y el jugador dentro del radio de activación de 30 m: la oleada asalta el campamento y no espera. Decisión de diseño: es un asalto, no una emboscada. | `carmenca_flow_check` (ningún chanca en `IDLE` 1,5 s después de empezar cada oleada) |
| Aparición | El respaldo de `CarmencaSpawn._search` se aleja más que la huella más lejana de las tiendas y refleja la dirección si queda demasiado cerca del jugador. | `test_carmenca_spawn` (tienda sintética de 30 m que fuerza el respaldo) |
| Protocolo | «Aliados separados» pasa a la etapa del estandarte, antes de tocarlo; al ganar, `_victory()` retira a los aliados. | [Protocolo](../../campaigns/01_pachacutec/documentation/prueba_vertical_slice.md) §3.1, v1.4 |
| Rendimiento | Medición repetida con la separación nueva: los aliados son seis cuerpos más de lógica, no geometría. | `measure_battle`: Medio **71,7** FPS (71,2–72,5), Bajo **67,8** (65,9–68,1), 259–261 draw calls, 183,4/181,2 MB, peor fotograma 25,0 ms |

**Validación ejecutada:** 174 métodos `test_` en verde; `carmenca_flow_check` (`CARMENCA_FLOW_OK pasos=18`, tres oleadas 2/4/6 en **35,5 s**, hueco mínimo **1,05 m**, aliados quietos, separados y fuera de las tiendas tras 10 s), `carmenca_check` (`CARMENCA_OK pasos=58`) y `mirador_check` (`tiendas=12`); `tools/check_test_inventory.py` (67 archivos, 32 recorridos), `tools/check_gdscript_limits.py`, `gdlint` y `gdformat --check` en verde; `tools/check_output.py` limpio; exportación Linux y arranque headless del build. **No verificado:** la pasada humana de 3.10 y la comparación con el bot del revisor.
