# F1 · Spikes técnicos — tareas

**Estado:** en curso · **Apertura:** 2026-11-19.
**Criterio de salida:** el de [docs/05](../05_plan_de_implementacion.md) §F1.
**Alcance:** validar con medidas, no con suposiciones, la arquitectura de mundo abierto.

## 1. Tareas

| # | Spike | Estado | Criterio de paso | Evidencia |
|---|---|---|---|---|
| 1.1 | Terrain3D | Pendiente | Importa, renderiza, colisiona y exporta en 4.7.2; sector a 60 FPS Medio | Medición y captura |
| 1.2 | Cyclops | Pendiente | Blockout de una plaza y conversión a malla/colisión; export sin addon | Escena y captura |
| 1.3 | Streaming | **Base implementada** | Carga/descarga sin hitches; < 150 ms por sector | `test_sector_streamer`, `sector_streaming_check` |
| 1.4 | Navegación | Pendiente | 20 NPC recorren llacta–manantial–paso sin atascos | `test_navigation_route` |
| 1.5 | NPC y horarios | **Base implementada** | 60 NPC, 25 animados, sin caída > 20 % | `test_npc_schedule`; `test_npc_lod` pendiente |
| 1.6 | Guardado y reloj | **Base implementada** | Esquema versionado y round-trip de mundo/reloj/jugador | `test_world_clock`, `test_world_state`, `test_save_round_trip` |
| 1.7 | Rendimiento | Pendiente | ≤ 350 draw calls, ≤ 250 MB VRAM, 30/60 FPS, hitch < 50 ms | `scene_audit`, `measure_performance` |

## 2. F1.6 — Base de reloj, estado y guardado

**Implementado:**

- `core/world/world_clock.gd`: día, hora, franjas, pausa, `minutes_until`, serialización.
- `core/world/world_state.gd`: fase, banderas, descubrimientos, estado de NPC, cambios físicos, serialización.
- `core/save/save_manager.gd`: ranuras, JSON versionado, escritura con temporal, listado, borrado y ciclo mundo/reloj/jugador.
- Autoloads `WorldClock`, `WorldState` y `SaveManager` registrados en `project.godot`.
- Pruebas: `tests/test_world_clock.gd`, `tests/test_world_state.gd`, `tests/test_save_round_trip.gd`.

**Pendiente de F1.6:**

- Integrar el guardado con la posición real del jugador y la escena de mundo (F3).
- Autoguardado al dormir, cambiar de fase y entrar/salir de sector (F3).
- Migración real de esquema cuando exista una versión 2.
- Medir el coste de guardar un mundo con 60–100 NPC (F3).

**Comandos:**

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
```

## 2.1. F1.5 — Base de definición y horario de NPC

**Implementado:**

- `core/npc/schedule_entry.gd`: franja con inicio/fin, cruce de medianoche, ancla, actividad y condiciones.
- `core/npc/npc_definition.gd`: identidad, nivel de simulación, casa, trabajo, facción, apariencia, diálogo y horario.
- `tests/test_npc_schedule.gd`: horario diario, medianoche, condiciones, ancla/actividad y validez.

**Pendiente de F1.5:**

- `NpcDirector` con spawn/despawn por sector y LOD de simulación.
- `NpcActor` conectado a la definición y al reloj.
- 60 NPC con 25 animados y presupuesto medido.
- Reanudación de rutina tras una secuencia controlada.

## 2.2. F1.3 — Base de streaming de sectores

**Implementado:**

- `SectorDefinition`: id, escena, celda y `always_loaded`.
- `SectorStreamer`: índice de sectores, celda por posición, radio de carga y descarga con histéresis, carga asíncrona con `ResourceLoader.load_threaded_request`, descarga y señales.
- `tests/test_sector_streamer.gd`: celdas, radio, distancia, siempre cargado y registro.
- `tests/sector_streaming_check.gd`: carga real de escenas, descarga y persistencia del sector siempre cargado.

**Pendiente de F1.3:**

- Medir tiempo de carga y hitch por sector con arte real.
- Integrar sectores de la región (props, edificios, vegetación y NPC).
- Cancelar cargas pendientes cuando el objetivo se aleja mucho.
- Presupuesto de memoria en un recorrido de 10 min.

## 3. Orden de trabajo

1. Cerrar F1.6 con la integración mínima en la escena de prueba.
2. Spike 1.1 Terrain3D: importar, colisionar, exportar y medir en la GPU de referencia.
3. Spike 1.2 Cyclops: blockout y conversión.
4. Spike 1.3 streaming con sectores de prueba.
5. Spike 1.4 navegación y 1.5 NPC/horarios.
6. Spike 1.7 presupuesto final por sector.

## 4. Riesgos

| Riesgo | Mitigación |
|---|---|
| Terrain3D no rinde en UHD 770 | Respaldo con malla/LOD propio; decisión en 1.1 |
| Cyclops rompe exportación | Usarlo solo como blockout y convertir |
| Sin streaming de regiones en Terrain3D 1.1 | Terreno siempre cargado; stream de props/NPC |
| Navmesh inestable | Waypoints de ancla y movimiento local |
| Guardado grande y lento | Serialización por IDs, no por nodos; medir en F3 |

## 5. Criterio de cierre

- [ ] 1.1–1.5 y 1.7 con medición publicada.
- [ ] 1.6 con round-trip completo e integración mínima.
- [ ] CI verde con los addons o con el respaldo.
- [ ] Decisión de adopción de Terrain3D/Cyclops en la bitácora.
- [ ] Presupuesto por sector fijado con números medidos.
