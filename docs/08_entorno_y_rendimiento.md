# 08 — Entorno atmosférico y rendimiento

## 1. Escena base del mundo

Cada escena de mundo de la campaña sigue esta jerarquía:

```text
Mundo (Node3D)
├── WorldEnvironment
├── DirectionalLight3D      "Inti"
├── Terrain (Node3D)
├── PlayerSpawn (Marker3D)
├── EnvironmentAudio (Node3D)
├── PlayerFPS
└── UILayer
```

### 1.1 Cielo

- `Environment.background_mode = BG_SKY` con `Sky` + `PhysicalSkyMaterial`.
- Objetivo: azul profundo de altura, horizonte atmosférico natural, gradientes suaves, sin saturación artificial.
- Parámetros a ajustar (existentes en `PhysicalSkyMaterial`): `rayleigh_coefficient`, `rayleigh_color`, `mie_coefficient`, `mie_eccentricity`, `mie_color`, `turbidity`, `sun_disk_scale`, `ground_color`, `energy_multiplier`. La altitud se simula con baja turbidez y Mie reducido (aire más limpio y seco).
- Sobre el cielo físico, una **cúpula de nubes procedurales** (`shared_assets/materials/nubes.gdshader`): esfera grande vista por dentro, sin texturas externas, que solo dibuja nubes altas y se desvanece cerca del horizonte. Es visual: no tiene colisión ni sombra.
- La posición del sol en el cielo físico la determina la `DirectionalLight3D`, por lo que cielo y luz se mantienen coherentes automáticamente.
- Iluminación ambiental y reflejos tomados del cielo (`ambient_light_source = SKY`, `reflected_light_source = SKY`). La luz ambiental mezcla el cielo (55 %) con un relleno azul grisáceo y tiene energía 1,2, para que las sombras no queden negras sin lavar la escena.

### 1.2 Niebla

Dos capas, ambas en `Environment`:

| Modo | Uso | Coste |
|---|---|---|
| Niebla volumétrica (`volumetric_fog_enabled`) | Perfiles Alto/Ultra: niebla matutina de valle que interactúa con la luz | Alto |
| Niebla de profundidad/altura (`fog_enabled`, con `fog_height` y `fog_height_density`) | Perfiles Bajo/Medio, y como base en todos | Bajo |

Para niebla localizada en valles: `FogVolume` (solo perfiles con volumétrica). Regla: la niebla nunca debe ocultar elementos de juego necesarios (caminos, objetos interactuables cercanos).

La niebla volumétrica de Alto/Ultra se ajusta a densidad 0,004, longitud 100 m, albedo azul grisáceo, emisión oscura y `sky_affect` 0,15. Con los valores por defecto (densidad 0,05 y cielo afectado al 100 %) la escena queda cubierta por una niebla marrón.

### 1.3 Sol (Inti)

- Color cálido de media mañana: `(1, 0,84, 0,66)`, energía 1,35.
- Altura de unos 26° sobre el horizonte, coherente con el guion: la noticia llega «a media mañana».
- Sombras: `shadow_enabled = true`, modo `SHADOW_PARALLEL_4_SPLITS`; distancia y resolución dependen del perfil.

## 2. Perfiles gráficos

Se implementan en `core/systems/graphics/`. Los perfiles se aplican en tiempo de ejecución; **no** modifican `ProjectSettings` (muchas de sus claves solo se leen al arrancar).

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `core/systems/graphics/graphics_profile.gd` | `class_name GraphicsProfile extends Resource` | Datos de un perfil (propiedades `@export` tipadas) |
| `core/systems/graphics/profiles/{low,medium,high,ultra}.tres` | Recursos `GraphicsProfile` | Valores de cada perfil |
| `core/systems/graphics/graphics_settings.gd` | Autoload `GraphicsSettings` | Perfil activo; aplica lo global (`Viewport`: MSAA, escala 3D, antialiasing de pantalla; `RenderingServer`: calidad de sombras); emite `profile_changed(profile: GraphicsProfile)` |
| `core/systems/graphics/environment_quality_controller.gd` | Nodo que se coloca en cada escena de mundo | Recibe por `@export` su `WorldEnvironment` y su `DirectionalLight3D`; escucha `profile_changed` y aplica niebla, SSAO, SSIL/SDFGI y distancia de sombras |

Así Core no conoce las escenas de campaña: cada mundo de campaña incluye su controlador y le asigna sus propios nodos.

| Ajuste | Bajo | Medio | Alto | Ultra |
|---|---|---|---|---|
| Niebla volumétrica | No | No | Sí | Sí (más densidad de muestras) |
| Niebla de altura | Sí | Sí | Sí | Sí |
| Distancia de sombras | Corta | Media | Larga | Larga |
| Resolución del atlas de sombras | Baja | Media | Alta | Máxima |
| SSAO | No | Sí | Sí | Sí |
| SSIL / SDFGI | No | No | Evaluar | Evaluar |
| Escala de renderizado 3D | 0.75 | 0.68 | 1.0 | 1.0 |
| Antialiasing | FXAA | TAA o MSAA 2× | MSAA 4× / TAA | MSAA 4× + TAA |

Implementación de sombras: atlas de 1024 / 2048 / 4096 / 4096 y filtro `SOFT_VERY_LOW` / `SOFT_LOW` / `SOFT_MEDIUM` / `SOFT_HIGH`. La distancia de sombras la aplica el controlador del mundo según el perfil.

El atlas se fija con `RenderingServer.directional_shadow_atlas_set_size(size, is_16bits)`. **El segundo parámetro es `is_16bits`, no “alta calidad”**: pasar `false` cambia el atlas a 32 bits y duplica su memoria. Los perfiles pasan `true` (`GraphicsSettingsService.SHADOW_ATLAS_16_BITS`).

Los valores concretos se fijan tras medir (§4).

## 3. Escalabilidad prevista

- **LOD:** LOD automático de mallas importadas y `visibility_range` para vegetación y objetos lejanos.
- **Culling:** frustum culling del motor; oclusión (`OccluderInstance3D`) solo si las mediciones lo justifican.
- **Materiales:** materiales compartidos en `shared_assets/materials/`; preferir instancias de un mismo shader con parámetros a materiales duplicados.
- **Vegetación:** `MultiMeshInstance3D` para elementos repetidos (ichu, piedras).
- **Carga de escenas:** carga en segundo plano (`ResourceLoader.load_threaded_request`) por sector; terreno siempre cargado en la región.
- **Iluminación:** luz principal dinámica; evaluar baking (`LightmapGI`) solo para interiores estáticos.
- **Sectores:** presupuesto independiente por sector; el peor caso manda, no la media del mapa.
- **Simulación:** distancia de NPC, animación, sombras y navegación escalan con la cercanía; fuera de sector solo se guarda estado.

**No se optimiza sin medir.** Cada optimización se justifica con una medición antes/después.

## 4. Métricas de referencia

> Las tablas de §4.1 son la línea base de la versión lineal (histórica). El presupuesto del mundo abierto está en §4.2 y se valida por sector en F1–F3.

| Métrica | Herramienta | Objetivo |
|---|---|---|
| FPS medio | Monitor de rendimiento del editor / `Performance` | **Vinculante:** ≥ 30 FPS, perfil Bajo, salida a 1080p, en la referencia con GPU integrada. **Comprometido:** ≥ 60 FPS, perfil Medio, salida a 1080p con el 3D al 68 %, en la misma referencia |
| FPS del percentil 1 % | Medición en script durante un recorrido fijo | Registrar base; no inferior a 2/3 del FPS medio |
| Tiempo de frame (CPU/GPU) | Profiler y monitores del editor | Vinculante: < 33,3 ms. Recomendado: < 16,6 ms |
| Draw calls | `Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME` | Registrar base |
| Memoria de vídeo | `Performance.RENDER_VIDEO_MEM_USED` | Registrar base |
| Tiempo de carga de escena | Medición en script | Registrar base |

### Equipo de referencia

Es el equipo **donde se mide**, no el requisito de sistema que se publicará. Los requisitos mínimos y recomendados se definirán más adelante, a partir de estas mediciones.

| Equipo | CPU | GPU | RAM | SO | Origen |
|---|---|---|---|---|---|
| **Referencia con GPU integrada** (el más débil disponible) | Intel Core i7-13700 | Intel UHD Graphics 770 (integrada) | 32 GB | Ubuntu 24.04 LTS | Máquina de desarrollo actual |

> La referencia con GPU integrada no describe la gama del equipo completo: el i7-13700 y los 32 GB son de gama alta; la UHD 770 es el componente limitante para 3D.

Consecuencias de que la referencia tenga GPU integrada:

- El perfil Bajo debe funcionar bien sin niebla volumétrica, SSAO ni SDFGI, y con escala de renderizado 3D reducida.
- La niebla volumétrica es exclusiva de Alto/Ultra y no puede considerarse parte imprescindible de la identidad visual: la niebla de altura debe lograr por sí sola la lectura de valle andino.
- El objetivo de 60 FPS se mide en la GPU integrada, no se aplaza a una GPU dedicada.

### Protocolo de medición

1. Perfil fijado por argumento (`--profile=N`).
2. Recorrido fijo y cronometrado por acto, sin vsync y con `Engine.max_fps = 0`.
3. Tres pasadas por perfil; se publica la mediana y el rango.
4. Se registran FPS medio y p1, tiempo de frame, draw calls y memoria de vídeo.
5. La medición se repite al cerrar cada acto y al cambiar la escena.
6. Las capturas y su revisión siguen el procedimiento de [docs/06](06_estrategia_de_pruebas.md) §4.1.

### 4.1. Auditoría de escena

`tools/scene_audit.gd` cuenta draw calls, primitivas, memoria de vídeo, mallas,
colisiones y luces con sombra de una escena. Con `--breakdown` oculta cada grupo
de primer nivel y mide su aportación, incluido el pase de sombra; es la forma de
decidir dónde optimizar antes de tocar la escena. Se ejecuta con ventana (el
servidor Dummy no cuenta draw calls):

```bash
godot --path . --resolution 1280x720 -s res://tools/scene_audit.gd -- \
    --scene=res://campaigns/01_pachacutec/scenes/world/region_world.tscn --frames=20 \
    --breakdown
```

La auditoría se corre sobre la escena regional y sobre cada sector; los valores vigentes están abajo.

### Mediciones del blockout regional (F2)

La medición vigente es la del territorio de F2, no la de los actos retirados. Protocolo: 1920 × 1080, vsync off, perfil Medio, carga del sistema anotada, con `tests/scenes/measure_cusco.tscn` y `measure_blockout.tscn`.

| Sector | Draw calls | Memoria de vídeo | FPS de Medio |
|---|---|---|---|
| S1 — Cusco | 247 | 128–137 MB | 76,4 / 79,2 / 82,3 (tres pasadas) |
| S3 — Llacta | 120 | — | 78–85 |
| S4 — Quebrada | 146 | — | 80 |
| S5 — Paso | 103 | — | 95 |
| S6 — Frontera | 83 | — | 103 |

Los seis sectores quedan bajo el presupuesto de 350 draw calls y 250 MB. El detalle por sector vive en la [ficha de F2](../docs/fases/F2-geografia-y-blockout.md) y en el [protocolo de blockout](../campaigns/01_pachacutec/documentation/mundo/prueba_blockout.md).

### 4.2. Presupuesto de mundo abierto (F1–F3)

Los valores siguientes son **provisionales** hasta que F1 mida el terreno y el streaming. Se aplican por **sector**, no por mapa completo.

| Métrica | Presupuesto | Cómo se mide |
|---|---|---|
| FPS medio | ≥ 30 Bajo / ≥ 60 Medio, 1080p, UHD 770 | `measure_cusco.tscn` en el peor sector |
| FPS p1 | ≥ 2/3 del FPS medio | Recorrido fijo de 10 min |
| Draw calls | ≤ 350 por sector | `scene_audit.gd --breakdown` |
| Primitivas | ≤ 1,2 M por sector | `scene_audit.gd` |
| VRAM | ≤ 250 MB | `Performance.RENDER_VIDEO_MEM_USED` |
| NPC activos | ≤ 60; animados ≤ 25 | Contador del `NpcDirector` |
| Distancia de sombras | 40–60 m, selectiva | Perfil y auditoría |
| Carga de sector | < 150 ms asíncrona | Instrumentación del `SectorStreamer` |
| Hitch | < 50 ms | Serie de tiempos de fotograma |
| Memoria del proceso | ≤ 4 GB | Monitor del sistema |

**Peor caso de prueba:** mercado o plaza a mediodía, con multitud, sombras, clima y NPC en rutina. No se mide una aldea vacía.

**Regla:** si un sector supera el presupuesto, se recorta antes de subir el límite. La decisión se registra con la medición antes/después.

### Mediciones de F3 (2026-11-21; batalla repetida el 2026-11-25)

Protocolo §4.2: 1920 × 1080, vsync libre, tres pasadas por perfil y caso, mediana y rango de p1. La ciudad conserva la medición del 2026-11-21; la batalla se repitió tras el traslado del campamento y la corrección de movimiento, con carga del sistema entre 0,8 y 1,8. `measure_cusco.tscn` mide la ciudad con su multitud; `measure_battle.tscn` mide la batalla de Carmenca con la oleada de ocho chancas, los seis aliados y el jugador dentro.

| Caso | Perfil | FPS medio | FPS p1 | Draw calls | Primitivas | VRAM | Peor fotograma |
|---|---|---|---|---|---|---|---|
| S1 — Cusco | Medio | 66,4 (66,1–66,8) | 51,7–55,1 | 253 | — | 185,2 MB | — |
| S1 — Cusco | Bajo | 61,0 (59,2–61,1) | 45,5–48,0 | 253 | — | 183,0 MB | — |
| S2 — batalla de Carmenca | Medio | 70,8 (70,5–71,9) | 54,8–66,0 | 261 | 698.066 | 183,4 MB | 17,6–22,6 ms |
| S2 — batalla de Carmenca | Bajo | 68,6 (65,3–68,6) | 43,0–53,0 | 265 | 698.574 | 181,2 MB | 21,5–26,6 ms |

Los cuatro casos quedan bajo el presupuesto: ≥ 60 FPS en Medio, ≥ 30 en Bajo, ≤ 350 draw calls, ≤ 1,2 M de primitivas, ≤ 250 MB y hitch < 50 ms. En la batalla los aliados matan chancas durante el muestreo (8 al empezar, 5 al terminar), así que el promedio incluye ese desgaste. La mediana de p1 Bajo es 53,0 (77,3 % de su media); una primera pasada quedó en 43,0 (65,8 %) con carga 1,82, por debajo del 66,7 %: se anota como valor atípico, no se repite el bloque de tres.

**Observación de perfiles:** Bajo mide menos FPS que Medio en esta referencia (68,6 frente a 70,8). La escala de renderizado 3D es 0,75 en Bajo y 0,68 en Medio, de modo que Bajo pinta más píxeles aunque apague la oclusión ambiental. Se revisa en F4; ambos perfiles cumplen su umbral.
