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
- **Carga de escenas:** carga en segundo plano (`ResourceLoader.load_threaded_request`) cuando existan varias zonas.
- **Iluminación:** luz principal dinámica; evaluar baking (`LightmapGI`) solo para interiores estáticos.

**No se optimiza sin medir.** Cada optimización se justifica con una medición antes/después.

## 4. Métricas de referencia

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

### 4.1. Auditoría de escena

`tools/scene_audit.gd` cuenta draw calls, primitivas, memoria de vídeo, mallas,
colisiones y luces con sombra de una escena. Con `--breakdown` oculta cada grupo
de primer nivel y mide su aportación, incluido el pase de sombra; es la forma de
decidir dónde optimizar antes de tocar la escena. Se ejecuta con ventana (el
servidor Dummy no cuenta draw calls):

```bash
godot --path . --resolution 1280x720 -s res://tools/scene_audit.gd -- \
    --scene=res://campaigns/01_pachacutec/scenes/world/ciudad.tscn --frames=20 \
    --breakdown
```

**Línea base del Cusco (2026-11-16):** 488 draw calls, 1,48 M primitivas, 250 mallas,
1 luz con sombra, 211 MB de vídeo. El presupuesto de la referencia es ≤ 350 draw calls y
≤ 1,2 M primitivas; el Cusco lo superaba. La mediana de FPS seguía por encima de 60
porque el coste es de relleno, no de CPU.

**Actualización 2026-11-17:** `StaticMeshBatch` fusiona por material/tinte casas,
props, mercado, mobiliario, puerta, remates de muro, terrazas, santuario y vegetación
del Cusco y la llacta. Antes del LOD de personaje, el Cusco quedaba en **349 draw
calls con Quaternius** (328 con el elenco anterior) y 245/225 MB; la llacta, en
**310**. El Cusco estaba a un draw call del presupuesto: no admitía la multitud Q
completa sin LOD. La memoria sube ~8 MB por la copia de vértices fusionados; los
originales quedan ocultos y sus colisiones siguen activas. La medición se hizo con
carga 6–16: falta repetirla en un equipo descargado.

**Elenco Quaternius completo y política de sombras (2026-11-17).** El desglose de
`scene_audit.gd --breakdown` mostró que la multitud del Cusco pesaba **173 draw
calls** y el pase de sombra del sol, **266**. Dos medidas los recortan: la multitud
oculta el tupu por material (el alfiler no se lee a distancia; las cejas se
conservan porque sin ellas la cara parece vacía) y solo cuerpo y ropa proyectan
sombra; ojos, cejas, tupu y pelo quedan fuera del pase de sombra. La sombra del
cuerpo sigue apoyando las figuras y los primeros planos no pierden volumen.
Resultado con el elenco Q completo:

| Acto | Draw calls | Memoria de vídeo | FPS medio | p1 |
|---|---|---|---|---|
| I — Llacta | 220 | 222,8 MB | 95,4 | 73,8 |
| II — Paso | 258 | 162,9 MB | 119,7 | 110,0 |
| III — Cusco | 297 | 230,9 MB | 69,4 | 60,0 |
| IV — Posguerra | 218 | 223,3 MB | 107,4 | 97,6 |
| V — Obra | 243 | 218,0 MB | 101,7 | 98,3 |

Los cinco actos cumplen el presupuesto de **≤ 350 draw calls**. Son tres pasadas
por acto con carga 1,1–1,6; se publica la mediana. La chaquitaclla del
Agricultor añade 1 draw call; el puño que sostiene el arma suma unos 9 en
primera persona. Las casas de la llacta usan un único material de superficie y
bajan a 220. La comprobación del pase visual (2026-11-18) midió estos draw
calls con carga variable (2,1–37); los FPS de la tabla son de la pasada en
reposo anterior. Con carga 2,1–2,3, llacta dio 90,0/87,2 FPS y Cusco 66,4/66,1;
siguen por encima de 60. El Cusco es el acto más ajustado
(69,4 FPS de media y p1 60,0); el resto supera 60 FPS con holgura. En una
pasada aislada del Cusco la media bajó a 53,8 y el p1 a 40,7; se vigila al
añadir arte final.

### Elenco de maniquíes (2026-11-18)

Medición con `measure_performance.tscn`, 1280×720, vsync off y dos pasadas por
acto, con el elenco de maniquíes UAL1 integrado. El atuendo se fusiona por hueso
y la multitud usa un look reducido.

| Acto | Draw calls | Memoria de vídeo | FPS mediana | p1 |
|---|---|---|---|---|
| I — Llacta | 257 | 145,2 MB | 94,0–96,1 | 86,6–88,4 |
| II — Paso | 270 | 121,1 MB | 118,3–120,7 | 82,4–110,0 |
| III — Cusco | 334 | 158,5 MB | 67,8–70,7 | 62,0–65,1 |
| IV — Posguerra | 259 | 145,3 MB | 94,0–95,6 | 75,5–90,0 |
| V — Obra | 275 | 140,2 MB | 88,1–91,0 | 69,6–77,2 |

Los cinco actos quedan bajo el presupuesto de 350 draw calls. El Cusco es el
más ajustado (334 y p1 62,0) y la llacta sube de 220 a 257 por las piezas de
los maniquíes; la memoria baja unos 80 MB porque no hay texturas de cara ni de
ropa. Las mediciones anteriores del elenco UBC quedan como histórico. La retirada del legado UBC no cambió draw calls ni memoria.

### Flujo de objetivos del acto I (2026-11-18)

Pasada con `measure_performance.tscn` a 1920×1080, vsync off, estado de campaña
limpio y una sola pasada. La carga del equipo estuvo entre 17 y 27, así que los
FPS **no son concluyentes**; los draw calls y la memoria sí sirven de termómetro.

| Acto | Draw calls | Memoria de vídeo |
|---|---|---|
| I — Llacta | 265 | 171,4 MB |
| II — Paso | 270 | 151,7 MB |
| III — Cusco | 334 | 184,1 MB |
| IV — Posguerra | 272 | 172,4 MB |
| V — Obra | 283 | 171,6 MB |

Los cinco actos siguen bajo 350 draw calls. El acto I suma el marcador de la
madre y el panel de pasos; una prueba quitando `QuestTracker` midió 265 → 262
draw calls y 171,4 → 171,2 MB, de modo que el panel no explica la diferencia de
memoria frente a la tabla anterior (probablemente caché de fuentes y carga de
la GPU). El entrenamiento de honda y sus marcadores solo existen durante su
paso. Falta repetir la medición con el equipo descargado.

**Línea base de Medio (2026-11-16):** medido sobre el arco nuevo el 2026-11-16 en la GPU integrada de referencia (Intel UHD 770), a 1920 × 1080, sin vsync y con el estado de campaña limpio entre actos. La herramienta es `tests/scenes/measure_performance.tscn`: calienta 60 fotogramas y muestrea 300, con FPS medio y p1 (percentil 99 del tiempo de fotograma). La tabla es la medición final del 2026-11-16, con las cordilleras con volumen, el shader aligerado y la escala 3D de Medio en 0,68. El Medio se midió con carga 1,8–2,7 y el Bajo con carga 1,6–3,8.

| Acto | Bajo (3 pasadas, mediana) | Medio (3 pasadas, mediana) | Rango de Medio | Draw calls (Medio) | Memoria de vídeo (Medio) |
|---|---|---|---|---|---|
| I — Llacta | 102,4 FPS | 89,4 FPS | 86,1–93,7 | 352 | 205,1 MB |
| II — Paso | 102,0 FPS | 93,4 FPS | 92,4–93,7 | 273 | 197,8 MB |
| III — Cusco | 74,2 FPS | 63,6 FPS | 63,2–65,8 | 476 | 231,8 MB |
| IV — Posguerra | 124,5 FPS | 97,5 FPS | 90,9–101,6 | 342 | 226,1 MB |
| V — Obra | 105,3 FPS | 90,5 FPS | 82,9–93,2 | 362 | 225,5 MB |

La tabla es la línea base del 2026-11-16. La pasada del elenco Q y la política de
sombras del 2026-11-17 deja el Cusco en 288 draw calls y la llacta en 249; los FPS de la
pasada nueva están en
[personajes_quaternius.md](../campaigns/01_pachacutec/documentation/personajes_quaternius.md).

Ambos perfiles cumplen: el Bajo supera el objetivo vinculante de ≥ 30 FPS (mínimo 73,8 en el Cusco) y el Medio supera el comprometido de ≥ 60 FPS en mediana. El Cusco era el acto más ajustado de Medio (63,6 FPS de mediana, 63,2 en la peor pasada) porque concentraba 476 draw calls y el SSAO; tras la fusión de estática y los textiles baja a 349 draw calls (328 legacy); la política de sombras del elenco Q la deja en 288. Se mantuvo el SSAO y la escala 3D de Medio bajó de 0,83 a 0,68 en dos pasos: 0,70 tras el primer pase visual y 0,68 al añadir las cordilleras con volumen. Sin SSAO el Cusco subía a 71–74 FPS, pero se perdía la oclusión ambiental que asienta los volúmenes. El p1 del Cusco (60,0 de mediana, 40,7 en la peor pasada) está en el límite del objetivo; se vigila al añadir arte final.

El acto V mostró un p1 de 49,1 FPS en una pasada por un tirón aislado; la mediana no se ve afectada, pero queda bajo observación. En la medición de Bajo de 2026-11-16, los draw calls son 297 (llacta), 232 (paso), 406 (Cusco), 297 (posguerra) y 310 (obra), con 195,2, 192,3, 226,3, 220,7 y 220,1 MB de memoria de vídeo.
