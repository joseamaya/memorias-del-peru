# Acta de cierre de F3 — vertical slice

- **Versión:** 0.11 (borrador para firma) — 2026-11-24
- **Fase:** F3 — vertical slice de mundo abierto
- **Campaña:** 01 — *Pachacútec. El despertar del Sol*
- **Firma:** responsable del proyecto (pendiente)
- **Manda:** criterios de fase en [docs/05](../05_plan_de_implementacion.md) §Fase 3 y criterio de cierre en la [ficha de F3](F3-vertical-slice.md) §16.

**Actualización 0.11:** recuento real de la suite (140 pruebas en 62 archivos), protocolo humano v1.2 y correcciones del 2026-11-24 (PRs #56–#60). La pasada humana y la firma siguen pendientes.

## 1. Qué se entrega

La slice jugable de las fases 1 y 2 de la campaña: la ciudad que se queda y el día de Carmenca.

| # | Tarea | Estado | Evidencia |
|---|---|---|---|
| 3.1 | Ciudad habitable | Base implementada | `city_check`, `cusco_blockout_check`, `measure_cusco` |
| 3.2 | Tres interiores | Base implementada | `interiors_check` |
| 3.3 | Ciclo día/noche | Base implementada | `day_night_check` |
| 3.4 | Población | Base implementada | `city_population_check` |
| 3.5 | Misión principal | Base implementada | `mission_check`, `city_save_round_trip` |
| 3.6 | Secundarias y descubrimiento | Base implementada | `side_activities_check`, `mirador_check` |
| 3.7 | Descanso y guardado | Base implementada | `city_save_round_trip` |
| 3.8 | Preparación de la defensa | Base implementada | `defense_works_check` |
| 3.9 | Carmenca | Base implementada | `combat_check`, `carmenca_check` |
| 3.10 | Cierre de la slice | **Protocolo y medición listos; falta la pasada humana y la firma** | Este acta |

**Base implementada** significa: código, contenido, pruebas e integración en el mundo; el arte es blockout y la aprobación estética es de F4.

## 2. Medición de rendimiento

Protocolo de [docs/08](../08_entorno_y_rendimiento.md) §4.2: 1920 × 1080, vsync libre, tres pasadas por perfil, mediana y rango de p1, carga del sistema anotada. Equipo de referencia: i7-13700 con UHD 770 integrada, Ubuntu 24.04. La carga media del sistema durante la tanda estuvo entre 1,9 y 5,2; aun así se cumple el presupuesto.

Escenas de medición: `tests/scenes/measure_cusco.tscn` para la ciudad (S1) y la nueva `tests/scenes/measure_battle.tscn` para la batalla (S2, oleada de 8 chancas con 6 aliados y el jugador dentro).

| Caso | Perfil | FPS medio (3 pasadas) | FPS p1 | Draw calls | Primitivas | VRAM | Peor fotograma |
|---|---|---|---|---|---|---|---|
| S1 — Cusco | Medio | 66,8 · 66,1 · 66,4 (mediana **66,4**) | 51,7–55,1 | 253 | — | 185,2 MB | — |
| S1 — Cusco | Bajo | 59,2 · 61,0 · 61,1 (mediana **61,0**) | 45,5–48,0 | 253 | — | 183,0 MB | — |
| S2 — batalla de Carmenca | Medio | 66,6 · 66,7 · 66,8 (mediana **66,7**) | 50,2–53,2 | 248 | 673.578 | 190,2 MB | 19,7–20,4 ms |
| S2 — batalla de Carmenca | Bajo | 61,1 · 61,1 · 63,0 (mediana **61,1**) | 48,0–48,8 | 248 | 673.578 | 188,0 MB | 22,0–24,0 ms |

Presupuesto ([docs/08](../08_entorno_y_rendimiento.md) §4.2 y ficha de F3 §13):

| Métrica | Límite | Medido | Veredicto |
|---|---|---|---|
| FPS medio | ≥ 60 Medio · ≥ 30 Bajo | 66,4–66,7 Medio · 61,0–61,1 Bajo | Cumple |
| FPS p1 | ≥ 2/3 del medio | 74,6–78,6 % del medio | Cumple |
| Draw calls por sector | ≤ 350 | 248–253 | Cumple |
| Primitivas por sector | ≤ 1,2 M | 673.578 | Cumple |
| VRAM | ≤ 250 MB | 183,0–190,2 MB | Cumple |
| Hitch | < 50 ms | 24,0 ms el peor fotograma | Cumple |
| Interiores | ≤ 15 draw calls | Medido en 3.2 | Cumple |

Observaciones:

- La oleada se mide con **8 chancas al empezar y 5 al terminar**: los aliados matan alguno durante los 300 fotogramas. El promedio incluye ese desgaste; el peor caso de dibujo es el arranque con los ocho.
- **El perfil Bajo mide menos FPS que el Medio** en este equipo (61 frente a 66). La causa es la escala de renderizado: Bajo dibuja el 3D al 75 % y Medio al 68 %, así que Bajo pinta más píxeles. Se anota para la revisión de perfiles de F4; no bloquea el cierre porque ambos superan su umbral.
- La medición no cubre el recorrido completo de 10 minutos con streaming, que sigue siendo la de F2 (`region_walkthrough_check` y `streaming_soak_check`); en F3 el mundo no cambió de escala.
- Las correcciones de la revisión (PR #54) no añaden geometría ni draw calls: el actor de los NPC sube al centro del cuerpo, el menú de pausa es un `Control` oculto y el resto son cambios de lógica y datos. La medición de esta sección sigue vigente; no se repitieron las tres pasadas.
- Las correcciones del 2026-11-24 (PRs #56–#60) tampoco añaden geometría: mueven el centro del campamento y la reaparición, cambian el estado de entrada y la altura de los NPC, y añaden pruebas. **No se repitieron las tres pasadas**: las cifras de esta sección son anteriores al traslado del campamento y `measure_battle` no se ha vuelto a ejecutar.

## 3. Pruebas automatizadas

- Suite completa: **140 métodos `test_` en 62 archivos, 0 fallos** (`tests/run_tests.gd`).
- Recorridos de integración de la slice en verde: `city_check`, `interiors_check`, `day_night_check`, `city_population_check`, `dialogue_check`, `mission_check`, `mission_stage2_check`, `side_activities_check`, `side_manta_load_check`, `mirador_check`, `defense_works_check`, `combat_check`, `carmenca_check`, `city_save_round_trip`, `region_player_check`, `region_walkthrough_check`, `poi_discovery_check`, `lantern_check`, `region_review_check`, `npc_lod_check`.
- Salida de cada ejecución sin errores ni advertencias de `res://` (`tools/check_output.py`).
- `gdlint` y `gdformat --check` limpios en los archivos nuevos; límites de GDScript e inventario de pruebas (**31 recorridos en CI**) OK.
- Exportación de Linux y Windows y arranque headless del build de Linux: OK. Windows se exporta, pero no se ejecuta en la CI ni en esta pasada.
- Correcciones de la revisión (PR #54): catálogos remapeados del build, etapa 1 y etapa 2 cargada, Carmenca tras la victoria, NPC en el centro del cuerpo, manta pendiente, descubrimientos sincronizados, HUD y combate, pausa y salto, guardado con respaldo. Evidencia en la [ficha de F3](F3-vertical-slice.md) §18.
- Correcciones de la revisión jugada del 2026-11-24 (PRs #56–#60): radio y derrota de Carmenca, entrada/pausa/ratón, altura de los NPC en el anillo, respaldo `.bak` ante un principal corrupto, atuendo con pieza nula y pasos etiquetados en las comprobaciones de integración. Evidencia en la [ficha de F3](F3-vertical-slice.md) §19.

## 4. Pasada humana

- Protocolo: [prueba_vertical_slice.md](../../campaigns/01_pachacutec/documentation/prueba_vertical_slice.md) v1.2. 8 bloques, 30–45 min, con registro de bloques, incidencias y las 15 regresiones de §3.1 (pausa, ratón, diálogo, NPC, HUD, etapa 2, manta, victoria, derrota y build).
- **Resultado:** pendiente de la pasada del responsable.
- Criterio que cierra: 30–45 min de juego real con contenido no principal, sin bloqueos, con las incidencias anotadas y la decisión firmada.

## 5. Deuda declarada

Lo que la slice **no** resuelve y pasa a F4, para que nadie lo confunda con un fallo:

| Deuda | Detalle |
|---|---|
| Arte | Casas, personajes, campamento, estandarte, obras y props son blockout. La guía visual y los modelos finales son de F4. |
| Personajes | El jugador es un maniquí y los NPC, cápsulas vestidas; sin animación de trabajo, conversación ni combate propia. |
| Texturas y materiales | Paleta plana de blockout; sin texturas de piedra, textil ni tierra. |
| Audio | Sustitutos declarados en [docs/07](../07_convenciones_historicas.md) §4; sin pasos propios del altiplano ni voces. |
| Equilibrio | 4, 6 y 8 chancas, 60 de salud y 6 aliados son números de bloqueo; los aliados no mueren. |
| Guardado en combate | La batalla no se serializa: cargar a mitad de pelea vuelve al inicio de la oleada, por diseño. |
| Navmesh local | El navmesh del Cusco sigue siendo de terreno; las casas no están talladas (3.4). |
| Actividades de NPC | Las rutinas mueven, pero no hay NPC trabajando ni conversando entre ellos (3.4). |
| Perfiles | La escala de Bajo y Medio se revisa en F4 (§2). |
| Guardado manual | El menú de pausa no guarda; el autoguardado es la cama. Decidir si entra en F4 o se implementa antes. |
| Diálogo y ratón | El panel permite pulsar opciones, pero el puntero sigue capturado durante la conversación. Decidir en F4 si se muestra. |
| Pruebas que guardan | Las comprobaciones comparten la ranura automática de `user://test-saves`; deben ejecutarse en serie o recibir una raíz propia. |
| Catálogo del build | La prueba cubre el árbol de origen; la carga de 11 diálogos y 31 POI del artefacto exportado se comprueba a mano en la pasada. |

El contenido histórico de la slice queda firmado: PCH-039, PCH-040, PCH-041 y PCH-042 se verificaron el 2026-11-21 (ver [hoja de verificación](../../campaigns/01_pachacutec/documentation/hoja_verificacion_fichas.md) §12). PCH-037 y PCH-038 pertenecen a la llacta y no forman parte de la slice.

## 6. Decisión

Marcar una:

- [ ] **Continuar** a F4 con el alcance previsto.
- [ ] **Recortar** antes de F4 (orden de recorte en la ficha de F3 §14).
- [ ] **Replantear** la slice por un problema de fondo.

Motivo y condiciones:

```text
(pendiente de la pasada humana y de la firma del responsable; incluye las regresiones de la revisión de §4)
```

## 7. Si se cierra

1. `docs/05` marca F3 como cerrada y abre F4 con el alcance que fije el responsable.
2. La ficha de F3 pasa a histórica y su §16 queda marcado.
3. La deuda de §5 se reparte en las tareas de F4.
4. La bitácora registra la decisión con su motivo.
