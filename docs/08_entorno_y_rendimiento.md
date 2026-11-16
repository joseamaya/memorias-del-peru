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
| Escala de renderizado 3D | 0.75 | 0.70 | 1.0 | 1.0 |
| Antialiasing | FXAA | TAA o MSAA 2× | MSAA 4× / TAA | MSAA 4× + TAA |

Implementación de sombras: atlas de 1024 / 2048 / 4096 / 4096 y filtro `SOFT_VERY_LOW` / `SOFT_LOW` / `SOFT_MEDIUM` / `SOFT_HIGH`. La distancia de sombras la aplica el controlador del mundo según el perfil.

El atlas se fija con `RenderingServer.directional_shadow_atlas_set_size(size, is_16bits)`. **El segundo parámetro es `is_16bits`, no “alta calidad”**: pasar `false` cambia el atlas a 32 bits y duplica su memoria. Los perfiles pasan `true` (`GraphicsSettingsService.SHADOW_ATLAS_16_BITS`).

Los valores concretos se fijan tras medir (§4).

## 3. Escalabilidad prevista

- **LOD:** LOD automático de mallas importadas y `visibility_range` para vegetación y objetos lejanos.
- **Culling:** frustum culling del motor; oclusión (`OccluderInstance3D`) solo si las mediciones lo justifican.
- **Materiales:** materiales compartidos en `shared_assets/materials/`; preferir instancias de un mismo shader con parámetros a materiales duplicados.
- **Vegetación:** `MultiMeshInstance3D` para elementos repetidos (ichu, piedras).
- **Carga de escenas:** carga en segundo plano (`ResourceLoader.load_threaded_request`) cuando existan varias zonas.
- **Iluminación:** luz principal dinámica; evaluar baking (`LightmapGI`) solo para interiores estáticos.

**No se optimiza sin medir.** Cada optimización se justifica con una medición antes/después.

## 4. Métricas de referencia

| Métrica | Herramienta | Objetivo |
|---|---|---|
| FPS medio | Monitor de rendimiento del editor / `Performance` | **Vinculante:** ≥ 30 FPS, perfil Bajo, salida a 1080p, en la referencia con GPU integrada. **Comprometido:** ≥ 60 FPS, perfil Medio, salida a 1080p con el 3D al 70 %, en la misma referencia |
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

**Estado:** medido sobre el arco nuevo el 2026-11-16 en la GPU integrada de referencia (Intel UHD 770), a 1920 × 1080, sin vsync y con un proceso nuevo por acto. La herramienta es `tests/scenes/measure_performance.tscn`: calienta 60 fotogramas y muestrea 300, con FPS medio y p1 (percentil 99 del tiempo de fotograma). La tabla recoge la repetición posterior al pase visual (bloque 4.9), hecha con carga del sistema entre 2,6 y 2,8; las mediciones anteriores, con carga 10–13, quedaron descartadas.

| Acto | Bajo (3 pasadas, mediana) | Medio (3 pasadas, mediana) | Rango de Medio | Draw calls (Medio) | Memoria de vídeo (Medio) |
|---|---|---|---|---|---|
| I — Llacta | 52,7 FPS | 87,2 FPS | 84,8–89,6 | 352 | 207,3 MB |
| II — Paso | 46,6 FPS | 88,5 FPS | 86,8–89,2 | 273 | 201,9 MB |
| III — Cusco | 51,7 FPS | 62,4 FPS | 61,9–62,4 | 476 | 235,8 MB |
| IV — Posguerra | 52,0 FPS | 99,6 FPS | 92,9–102,2 | 343 | 230,2 MB |
| V — Obra | 52,6 FPS | 84,0 FPS | 77,4–87,6 | 363 | 229,6 MB |

Ambos perfiles cumplen: el Bajo supera el objetivo vinculante de ≥ 30 FPS y el Medio supera el comprometido de ≥ 60 FPS en mediana. El Cusco es el acto más ajustado (62,4 FPS de mediana, 61,9 en la peor pasada) porque concentra 476 draw calls y el SSAO. Para cerrar la brecha se mantuvo el SSAO y se bajó la escala 3D de Medio de 0,83 a 0,70: sin SSAO el Cusco subía a 71–74 FPS, pero se perdía la oclusión ambiental que asienta los volúmenes. El p1 del Cusco (55–60 FPS) sigue por debajo del objetivo en los picos; se vigila al añadir arte final.

Dos avisos de la repetición: la obra del acto V marcó 420 draw calls en la primera pasada y 363 en las dos siguientes, y una de sus pasadas tuvo un p1 de 26,6 FPS por un tirón aislado. La mediana no cambia, pero el acto V queda bajo observación.

El perfil Bajo no se volvió a medir en esta pasada: sus valores son los de la medición del 2026-11-15 y sirven de referencia hasta el pase de arte.
