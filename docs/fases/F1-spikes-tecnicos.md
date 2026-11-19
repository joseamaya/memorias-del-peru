# F1 · Spikes técnicos — tareas

**Estado:** en curso · **Apertura:** 2026-11-19.
**Criterio de salida:** el de [docs/05](../05_plan_de_implementacion.md) §F1.
**Alcance:** validar con medidas, no con suposiciones, la arquitectura de mundo abierto.

## 1. Tareas

| # | Spike | Estado | Criterio de paso | Evidencia |
|---|---|---|---|---|
| 1.1 | Terrain3D | **Base implementada; adopción provisional** | Importa, renderiza, colisiona y exporta en 4.7.2; sector a 60 FPS Medio | `terrain3d_check`, `measure_terrain`; 113–115 FPS |
| 1.2 | Cyclops | **Base implementada** | Blockout de una plaza y conversión a malla/colisión; export sin addon | `cyclops_probe`; cubo convertido a malla y colisión |
| 1.3 | Streaming | **Base implementada** | Carga/descarga sin hitches; < 150 ms por sector | `test_sector_streamer`, `sector_streaming_check` |
| 1.4 | Navegación | **Implementada en el sector gris** | 20 NPC recorren llacta–manantial–paso sin atascos | `test_navigation_service`, `navigation_check`, `grey_sector_check`; navmesh sobre el terreno y 20 NPC que llegan caminando |
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
- `TerrainNavmesh` y `NavmeshProfile`: horneado síncrono sobre 120 × 120 m de Terrain3D, con huellas de obstáculo recortadas.
- `NpcMover`: seguimiento de ruta por tramos, con altura de cuerpo y fin de trayecto.
- `tests/test_navigation_service.gd`: consulta fuera del árbol y longitud.
- `tests/test_npc_mover.gd`: avance por tramos, altura, fin de ruta y ruta vacía.
- `tests/navigation_check.gd`: dos regiones de navegación separadas por un hueco de 5 m, unidas por `NavigationLink3D`, con ruta completa.
- `tests/grey_sector_check.gd`: navmesh de 128 polígonos sobre el terreno, ruta hasta el campo con relieve, desvío alrededor de la pirca y 20 NPC que llegan caminando.

**Pendiente de F1.4:**

- Ruta real llacta–manantial–paso de la campaña (F2).
- Enlaces de puertas, escaleras y desniveles en la región.
- Coste de generación y actualización del navmesh con el sector real y streaming.

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

## 2.5. F1.2 — Cyclops Level Builder

**Instalado:** Cyclops Level Builder 1.5.2, MIT, en `addons/cyclops_level_builder`. Registro en `addons/cyclops_level_builder/REGISTRO.md`. El plugin de editor no se habilita por defecto para no registrar su autoload en el juego.

**Validado:** `cyclops_probe` construye un `ConvexBlockData` cúbico, lo asigna a un `CyclopsBlock` y comprueba que el nodo genera una malla con una superficie y una forma de colisión. La conversión a malla/colisión propia es, por tanto, viable.

**Pendiente:** blockout real de una plaza y una pirca en el editor, exportación GLB/escena y captura visual. La escena final no depende del addon: se excluye de la exportación con `addons/cyclops_level_builder/*` y el blockout se convierte a malla y colisión. La adopción definitiva se decide en F2.

**Comando:**

```bash
godot --headless --path . --script res://tests/cyclops_probe.gd
```

> El addon deja un aviso de objetos sin liberar al salir en Godot 4.7.2. Es un problema del addon, no de la escena de juego; se vigila al convertirlo en herramienta de F2.

## 2.6. Sector gris de integración (F1.3–F1.5)

**Escena:** `tests/scenes/grey_sector.tscn`, 256 m de Terrain3D, pirca de Cyclops convertida a malla/colisión, navmesh horneado sobre el terreno y 20 NPC que caminan por él.

**Navmesh sobre el terreno.** Terrain3D no expone su malla ni su colisión como nodos: la colisión es un `Terrain3DCollision` con RID propio, fuera del árbol. Por eso `NavigationRegion3D.bake_navigation_mesh()` no puede verla. `core/world/terrain_navmesh.gd` muestrea la altura del terreno, construye la geometría con la orientación que espera Recast y hornea de forma síncrona. `NavmeshProfile` declara paso, radio, altura, pendiente y resolución. Los obstáculos se declaran como huellas en XZ (`add_projected_obstruction` con recorte); la pirca recorta su huella y obliga a rodearla.

**Rutas.** `core/npc/npc_mover.gd` sigue una ruta con velocidad, altura de cuerpo y final de trayecto. El sector pide la ruta a `NavigationService` cuando el horario cambia de ancla y avanza la simulación con `advance_npcs(segundos, paso)`, de forma determinista para las pruebas.

**Comprobación:** `grey_sector_check` valida 20 NPC, región de terreno, malla y colisión de la pirca, 128 polígonos de navmesh con relieve (de −0,02 a 2,73 m), ruta hasta el campo con altura creciente, desvío alrededor de la pirca, llegada caminando de los 20 NPC y guardado/carga de fase, bandera y reloj. Salida: `GREY_SECTOR_OK npcs=20 navmesh_polys=128`.

**Medición:** tres pasadas a 1920 × 1080, perfil Medio, vsync off, con carga del equipo 3,3–3,7:

| Pasada | FPS medio | p1 | Draw calls | VRAM |
|---|---|---|---|---|
| 1 | 94,2 | 82,5 | 91 | 98,7 MB |
| 2 | 94,8 | 94,3 | 94 | 98,7 MB |
| 3 | 95,0 | 90,0 | 94 | 98,7 MB |

Las pasadas con carga 32–38 (68,8–92,8 FPS) se descartaron por contención del equipo; la escena de terreno sola también bajó de 113–115 a 86,9 FPS en esa franja. La medición se repite en F1.7 con arte y edificios.

**Pendiente:** ruta real llacta–manantial–paso de la campaña, edificios y texturas, horneado por sector con streaming y `NpcDirector` con LOD.

**Comandos:**

```bash
godot --headless --path . --script res://tests/grey_sector_check.gd
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_grey_sector.tscn
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_grey_sector.tscn
```

La captura queda en `build/evidencia/grey_sector_nav.png` (ignorada por Git).
## 3. Orden de trabajo

1. **Hecho:** F1.6 base (reloj, estado y guardado).
2. **Hecho:** F1.1 base (Terrain3D importa, colisiona y mide 113–115 FPS en la escena de prueba).
3. **Hecho:** F1.2 base (Cyclops convierte un bloque en malla y colisión).
4. **Hecho:** F1.3–F1.4 en el sector gris (streaming base, navmesh sobre el terreno, 20 NPC en ruta y guardado).
5. **Siguiente:** F1.5 `NpcDirector` y LOD con 60 NPC; blockout real de plaza/pirca.
6. F1.7 presupuesto final con arte y edificios.
7. Exportación Linux/Windows con ambos addons y prueba de humo.

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
