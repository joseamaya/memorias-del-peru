# F1 · Spikes técnicos — tareas

**Estado:** cerrada · **Apertura:** 2026-11-19 · **Cierre:** 2026-11-19.
**Criterio de salida:** el de [docs/05](../05_plan_de_implementacion.md) §F1.
**Alcance:** validar con medidas, no con suposiciones, la arquitectura de mundo abierto.

## 1. Tareas

| # | Spike | Estado | Criterio de paso | Evidencia |
|---|---|---|---|---|
| 1.1 | Terrain3D | **Base implementada; adopción provisional** | Importa, renderiza, colisiona y exporta en 4.7.2; sector a 60 FPS Medio | `terrain3d_check`, `measure_terrain`; 113–115 FPS |
| 1.2 | Cyclops | **Base implementada** | Blockout de una plaza y conversión a malla/colisión; export sin addon | `cyclops_probe`; cubo convertido a malla y colisión |
| 1.3 | Streaming | **Base implementada y medida** | Carga/descarga sin hitches; < 150 ms por sector | `test_sector_streamer`, `sector_streaming_check`, `streaming_soak_check`; 21,4 ms medio, 32,2 ms máximo, 15,6 ms de hitch y 1 KB de crecimiento |
| 1.4 | Navegación | **Implementada en el sector gris** | 20 NPC recorren llacta–manantial–paso sin atascos | `test_navigation_service`, `navigation_check`, `grey_sector_check`; navmesh sobre el terreno y 20 NPC que llegan caminando |
| 1.5 | NPC y horarios | **Implementada en el sector gris** | 60 NPC, 25 animados, sin caída > 20 % | `test_npc_schedule`, `test_npc_lod`, `npc_lod_check`; 60/25 y caída del 15,9 % |
| 1.6 | Guardado y reloj | **Base implementada** | Esquema versionado y round-trip de mundo/reloj/jugador | `test_world_clock`, `test_world_state`, `test_save_round_trip` |
| 1.7 | Rendimiento | **Implementada en el blockout** | ≤ 350 draw calls, ≤ 250 MB VRAM, 30/60 FPS, hitch < 50 ms | `sector_blockout_check`, `measure_blockout_compare`; 255–287 draw calls, 101,7 MB, 61–66 FPS, frame máximo 30,3 ms |

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
- `core/npc/npc_director.gd`: registro de definiciones y anclas, horario, spawn/despawn por distancia, presupuesto y snapshot.
- `core/npc/npc_sim_actor.gd`: cuerpo y animación de marcador; el nombre evita la clase heredada `NpcActor` de la campaña lineal.
- `tests/test_npc_schedule.gd` y `tests/test_npc_lod.gd`.
- `tests/npc_lod_check.gd`: escena de 60 NPC con 60 activos y 25 animados.

**Pendiente de F1.5:**

- Sustituir la animación de marcador por los personajes y clips reales.
- 60 NPC en el sector de la campaña, con interiores y multitud ambiente.
- Reanudar una secuencia controlada con el snapshot del director en una escena real.

## 2.2. F1.3 — Base de streaming de sectores

**Implementado:**

- `SectorDefinition`: id, escena, celda y `always_loaded`.
- `SectorStreamer`: índice de sectores, celda por posición, radio de carga y descarga con histéresis, carga asíncrona con `ResourceLoader.load_threaded_request`, descarga y señales.
- `tests/test_sector_streamer.gd`: celdas, radio, distancia, siempre cargado y registro.
- `tests/sector_streaming_check.gd`: carga real de escenas, descarga y persistencia del sector siempre cargado.
- `tests/streaming_soak_check.gd`: 60 ciclos de carga/descarga con escenas reales; 21,4 ms de media, 32,2 ms el peor ciclo, 15,6 ms de hitch máximo y 1 KB de crecimiento de memoria estática.

**Pendiente de F1.3:**

- Medir tiempo de carga y hitch con arte y edificios reales.
- Integrar sectores de la región (props, edificios, vegetación y NPC).
- Cancelar cargas pendientes cuando el objetivo se aleja mucho.
- Recorrido real de 10 minutos; el soak de 60 ciclos es la aproximación de CI.

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

## 2.7. F1.5 — Director de NPC y LOD

**Implementado:**

- `NpcDirector`: los tier B se descargan al alejarse y los narrativos siguen activos; el presupuesto se reparte por cercanía (60 activos, 25 animados). Histéresis de 10 m para no alternar en el borde.
- Tier C: radio de simulación y animación al 55 % del tier B; no se guarda en el snapshot.
- `NpcSimActor`: cápsula de marcador, `NpcMover` y un balanceo de malla que solo se reproduce en el nivel animado. En F2 lo sustituyen los personajes reales.
- `get_snapshot()` / `restore_snapshot()`: minuto, posición y ancla de los tier A/B, guardados dentro del diccionario del jugador.
- `tests/scenes/npc_lod.tscn`: 60 NPC, simulación a 120 m y animación a 70 m.
- Pruebas: `test_npc_lod` (distancias, presupuesto, despawn, snapshot y horario) y `npc_lod_check` (60 activos, 25 animados, vista lejana, rutas y guardado).

**Medición (carga del equipo 47–50):**

| Escena | FPS medio (3 pasadas) | Mediana | Draw calls | VRAM |
|---|---|---|---|---|
| 20 NPC | 75,4 / 76,8 / 77,2 | 76,8 | 110–114 | 98,7 MB |
| 60 NPC, 25 animados | 62,4 / 71,6 / 64,6 | 64,6 | 209–223 | 101,6 MB |

La caída es del **15,9 %**, dentro del 20 %. El p1 no es comparable con esta carga; se repite en F1.7. Los 60 NPC son mallas individuales: F2 debe usar MultiMesh para la multitud ambiente y revisar el presupuesto de draw calls.

```bash
godot --headless --path . --script res://tests/npc_lod_check.gd
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_npc_lod.tscn
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_npc_lod.tscn
```

La captura de los 60 NPC queda en `build/evidencia/npc_lod.png`.
## 2.8. F1.7 — Blockout y presupuesto

**Escena:** `tests/scenes/sector_blockout.tscn`, variante del sector gris con:

- Seis casas y dos pircas de Cyclops convertidas a malla y colisión; sus huellas recortan el navmesh.
- 120 cápsulas de multitud y 180 matas de ichu en dos `MultiMesh` (un draw call cada uno).
- 60 NPC con 25 animados.
- Terreno de 256 m y navmesh de 128 polígonos.

**Comprobación:** `sector_blockout_check` valida 6 casas, 120 de multitud, 180 de vegetación, 60 NPC activos, 25 animados y que la ruta entre (−30, 6) y (−14, 6) rodea la casa de (−22, 6). Salida: `BLOCKOUT_OK npcs=60 houses=6 crowd=120 vegetation=180 active=60 animated=25`.

**Medición comparativa** en el mismo proceso y franja de carga 52–57 (tres pasadas, 1920 × 1080, Medio, vsync off):

| Escena | FPS medio | Mediana | Draw calls | VRAM | Frame máximo |
|---|---|---|---|---|---|
| 60 NPC | 63,9 / 74,0 / 62,0 | 63,9 | 180–189 | 101,6 MB | 28,7–32,0 ms |
| Blockout | 62,1 / 65,7 / 61,3 | 62,1 | 255–287 | 101,7 MB | 23,1–30,3 ms |

El blockout cuesta un **2,8 %** de FPS de mediana; todo queda por debajo de 350 draw calls y 250 MB, por encima de 61 FPS y con frame máximo inferior a 50 ms. Las pasadas con carga 74–79 (41–54 FPS) se descartaron por contención del equipo.

**Pendiente:** arte real, LOD de edificios, sombras selectivas, rutina de multitud sobre MultiMesh y el sector de campaña.

```bash
godot --headless --path . --script res://tests/sector_blockout_check.gd
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_blockout_compare.tscn
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_sector_blockout.tscn
```

La captura queda en `build/evidencia/sector_blockout.png`.

## 3. Orden de trabajo

1. **Hecho:** F1.6 base (reloj, estado y guardado).
2. **Hecho:** F1.1 base (Terrain3D importa, colisiona y mide 113–115 FPS en la escena de prueba).
3. **Hecho:** F1.2 base (Cyclops convierte un bloque en malla y colisión).
4. **Hecho:** F1.3–F1.4 en el sector gris (streaming base, navmesh sobre el terreno, 20 NPC en ruta y guardado).
5. **Hecho:** F1.5 en el sector gris (`NpcDirector`, LOD, 60 NPC, 25 animados y snapshot).
6. **Hecho:** F1.7 en el blockout (casas y pircas Cyclops, multitud y vegetación MultiMesh, presupuesto medido).
7. **Hecho:** exportación Linux/Windows con ambos addons y prueba de humo.
8. **Siguiente:** aprobación del responsable para cerrar F1 y abrir F2 con el expediente geográfico.

## 4. Riesgos

| Riesgo | Mitigación |
|---|---|
| Terrain3D no rinde en UHD 770 | Respaldo con malla/LOD propio; decisión en 1.1 |
| Cyclops rompe exportación | Usarlo solo como blockout y convertir |
| Sin streaming de regiones en Terrain3D 1.1 | Terreno siempre cargado; stream de props/NPC |
| Navmesh inestable | Waypoints de ancla y movimiento local |
| Guardado grande y lento | Serialización por IDs, no por nodos; medir en F3 |

## 5. Criterio de cierre

- [x] 1.1–1.5 y 1.7 con prueba reproducible y medición publicada (1.2 valida conversión y exportación, no rendimiento).
- [x] 1.6 con round-trip completo e integración mínima.
- [x] CI verde con los addons.
- [x] Decisión de adopción provisional de Terrain3D/Cyclops aprobada para F2; la revisión definitiva se hace con el sector real.
- [x] Presupuesto por sector fijado con números medidos: ≤ 350 draw calls, ≤ 250 MB, 60 FPS Medio y frame < 50 ms.
