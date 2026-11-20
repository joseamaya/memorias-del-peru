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
| 3.2 | Tres interiores | Prevista | Casa del jugador, casa de la curáca y taller transitables; ≤ 15 draw calls por interior | `interiors_check` |
| 3.3 | Ciclo día/noche | Prevista | `WorldClock` mueve sol, ambiente y niebla; amanecer, tarde y noche legibles | `day_night_check` |
| 3.4 | Población | Prevista | 24 NPC, 8 nombrados, rutinas de mañana, tarde y noche; sin atascos en 20 min | `city_population_check`, `npc_lod_check` |
| 3.5 | Misión principal | Prevista | Tres etapas con estado persistente y diario | `mission_check`, `city_save_round_trip` |
| 3.6 | Secundarias y descubrimiento | Prevista | Dos actividades con consecuencia y un lugar descubierto sin marcador | `side_activities_check` |
| 3.7 | Descanso y guardado | Prevista | Dormir avanza el día; guardar/cargar conserva hora, NPC, misión e inventario | `city_save_round_trip` |
| 3.8 | Preparación de la defensa | Prevista | Fosos y púas construibles, persistentes y leídos por la batalla | `defense_works_check` |
| 3.9 | Carmenca | Prevista | Tres oleadas, aliados y estandarte como objetivo; sin bloqueos | `carmenca_check` |
| 3.10 | Cierre de la slice | Prevista | 30–45 min jugados, presupuesto medido y acta del responsable | Protocolo y capturas |

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

## 3. F3.2 — Tres interiores

- Casa del jugador, casa de Chanan Cury Coca y taller textil.
- Puerta interactiva; interior instanciado al entrar y liberado al salir; luz propia que no depende del sol.
- Presupuesto: ≤ 15 draw calls por interior y ≤ 80 MB de memoria.

**Criterio:** entrar y salir de los tres sin huecos ni teletransportes; el guardado conserva la posición y el estado del interior.

## 4. F3.3 — Ciclo día/noche

`WorldClock` (ya existe) pasa a gobernar el sol, el ambiente, la niebla y la exposición. Franjas legibles: amanecer, mañana, mediodía, tarde, noche. Los interiores usan luz propia.

**Criterio:** a las 07:00, 13:00, 19:00 y 23:00 la luz es distinguible y no hay saltos al cambiar de hora; el perfil Medio mantiene 60 FPS.

## 5. F3.4 — Población

- 24 NPC activos en S1, 8 de ellos nombrados con rol y casa. Entre ellos, Chanan Cury Coca.
- Rutinas de mañana, tarde y noche con `NpcDirector`, `ScheduleEntry` y `NpcMover` sobre el navmesh de S1.
- LOD: 24 activos, 12 animados; los lejanos se simulan sin malla.

**Criterio:** 20 min de recorrido sin atascos ni NPC atravesando muros; el estado de los NPC sobrevive al guardado.

## 6. F3.5 — Misión principal

Tres etapas, sin sistema genérico de misiones: recursos de misión y banderas en `WorldState`.

1. **La mañana del arrabal:** encargos cotidianos, rumores de la retirada y presentación del ayllu.
2. **La partida:** Viracocha abandona la ciudad; el jugador se queda y ayuda a preparar la defensa.
3. **Carmenca:** el asalto y la resistencia hasta la retirada chanca.

**Criterio:** la misión avanza y termina con una consecuencia persistente; se puede guardar y cargar en cualquier etapa sin perder estado.

## 7. F3.6 — Secundarias y descubrimiento

- **Social:** mediar entre dos familias por el turno del agua o del horno; la decisión deja reputación.
- **Económica:** preparar chicha o tejer una manta para quien va a la defensa; el objeto se usa en la batalla.
- **Descubrimiento sin marcador:** el mirador sobre Carmenca, desde donde se ven las tiendas chancas.

**Criterio:** ninguna es un recado vacío; la consecuencia se lee en el mundo o en el diario; el descubrimiento se registra sin marcador.

## 8. F3.7 — Descanso y guardado

Dormir en la casa del jugador avanza a la mañana siguiente. Guardar desde la cama; cargar restaura hora, NPC, misión, inventario y obras.

**Criterio:** ciclo guardar → salir → cargar conserva los cinco estados y la hora avanzada.

## 9. F3.8 — Preparación de la defensa

Fosos con piedra tapados con ramas y púas de palma (PCH-039). De tres a cinco puntos construibles en los accesos del arrabal. Cada obra es una modificación persistente del mundo y la batalla la lee.

**Criterio:** construir, guardar y cargar conserva las obras; en la batalla, una obra reduce o daña la oleada correspondiente.

## 10. F3.9 — Carmenca

- Cerro al oeste con la bajada chanca y los accesos documentados.
- Tres oleadas con encuentros authored; aliados de Cusi Yupanqui; estandarte como objetivo final.
- Armas: honda (a distancia) y porra (cuerpo a cuerpo). Sin hacha de guerra salvo como útil de trabajo.
- Sin ejército simulado: máximo 25 enemigos activos y 10 aliados.

**Criterio:** la defensa se puede completar sin bloqueos; perder reinicia la oleada, no la partida; el presupuesto se mantiene.

## 11. F3.10 — Cierre de la slice

- Pasada humana de 30–45 min con contenido no principal.
- Medición por sector y perfil (Medio y Bajo).
- Acta del responsable con decisión: continuar, recortar o replantear.

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
| FPS | ≥ 30 Bajo / ≥ 60 Medio, 1080p, UHD 770 | `measure_cusco.tscn` |
| Hitch | < 50 ms | `sector_streaming_check.gd` |
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
