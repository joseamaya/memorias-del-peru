# F1 · Spikes técnicos — tareas

**Estado:** en curso · **Apertura:** 2026-11-19.
**Criterio de salida:** el de [docs/05](../05_plan_de_implementacion.md) §F1.
**Alcance:** validar con medidas, no con suposiciones, la arquitectura de mundo abierto.

## 1. Tareas

| # | Spike | Estado | Criterio de paso | Evidencia |
|---|---|---|---|---|
| 1.1 | Terrain3D | **Base implementada; adopción provisional** | Importa, renderiza, colisiona y exporta en 4.7.2; sector a 60 FPS Medio | `terrain3d_check`, `measure_terrain`; 113–115 FPS |
| 1.2 | Cyclops | Pendiente | Blockout de una plaza y conversión a malla/colisión; export sin addon | Escena y captura |
| 1.3 | Streaming | **Base implementada** | Carga/descarga sin hitches; < 150 ms por sector | `test_sector_streamer`, `sector_streaming_check` |
| 1.4 | Navegación | **Base implementada** | 20 NPC recorren llacta–manantial–paso sin atascos | `test_navigation_service`, `navigation_check` |
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

## 2.3. F1.4 — Base de consulta y rutas de navegación

**Implementado:**

- `NavigationService`: mapa del `World3D`, ruta entre puntos, comprobación de alcance, longitud y punto más cercano.
- `tests/test_navigation_service.gd`: consulta fuera del árbol y longitud.
- `tests/navigation_check.gd`: dos regiones de navegación separadas por un hueco de 5 m, unidas por `NavigationLink3D`, con ruta completa.

**Pendiente de F1.4:**

- Navmesh horneado por sector sobre el terreno real.
- Enlaces de puertas, escaleras y desniveles en la región.
- 20 NPC recorriendo llacta–manantial–paso sin atascos.
- Coste de generación y actualización del navmesh.

## 2.4. F1.1 — Terrain3D

**Instalado:** Terrain3D 1.1.0 stable, MIT, en `addons/terrain_3d` (Linux, Windows y macOS; se retiraron Android/iOS/Web). Registro en `addons/terrain_3d/REGISTRO.md`.

**Escena de prueba:** 512 × 512 m, 4 regiones de 256 m, 50 árboles y 20 NPC de relleno, sin texturas de terreno, edificios ni vegetación densa. Cámara en órbita fija; perfil por defecto (Medio), 1920 × 1080, vsync off.

| Pasada | FPS medio | p1 | Frame ms | Draw calls | VRAM | Carga |
|---|---|---|---|---|---|---|
| 1 | 113,5 | 106,7 | 8,81 | 68 | 97,0 MB | 1,06 |
| 2 | 114,0 | 103,4 | 8,77 | 68 | 97,0 MB | 0,98 |
| 3 | 114,5 | 110,0 | 8,73 | 68 | 97,0 MB | 0,90 |

**Línea base de malla simple:** 300 FPS (tope de la medición), 13 draw calls y 87,8 MB. La malla es mucho más simple; sirve para comprobar que la diferencia no es catastrófica, no como comparación exacta.

**Colisión:** validada con un rayo vertical sobre el terreno en `terrain3d_check`.

**Pendiente:** navmesh horneado sobre Terrain3D, texturas/materiales, vegetación densa, edificios, exportación Linux/Windows y sector real. La adopción definitiva se decide después de F2.

**Decisión provisional:** adoptar Terrain3D para el blockout de F2, con el presupuesto de [docs/08](../../docs/08_entorno_y_rendimiento.md) §4.2 y el respaldo de malla si el sector real baja de 60 FPS Medio.

**Comandos:**

```bash
godot --headless --path . --script res://tests/terrain3d_check.gd
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_terrain.tscn -- --mode=terrain
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_terrain.tscn -- --mode=baseline
```

## 3. Orden de trabajo

1. **Hecho:** F1.6 base (reloj, estado y guardado).
2. **Hecho:** F1.1 base (Terrain3D importa, colisiona y mide 113–115 FPS en la escena de prueba).
3. **Siguiente:** F1.2 Cyclops y blockout sobre el terreno.
4. F1.3 streaming con sectores de la región.
5. F1.4 navmesh sobre Terrain3D y 20 NPC en ruta; F1.5 `NpcDirector` y LOD.
6. F1.7 presupuesto final con arte y edificios.
7. Exportación Linux/Windows con Terrain3D y prueba de humo.

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
