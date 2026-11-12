# 08 — Entorno atmosférico y rendimiento

## 1. Escena base del mundo (Fase 3)

`campaigns/01_pachacutec/scenes/world/mundo_base.tscn`

```text
MundoBase (Node3D)
├── WorldEnvironment
├── DirectionalLight3D      "Inti"
├── Terrain (Node3D)
├── PlayerSpawn (Marker3D)
└── EnvironmentAudio (Node3D)
```

### 1.1 Cielo

- `Environment.background_mode = BG_SKY` con `Sky` + `PhysicalSkyMaterial`.
- Objetivo: azul profundo de altura, horizonte atmosférico natural, gradientes suaves, sin saturación artificial.
- Parámetros a ajustar (existentes en `PhysicalSkyMaterial`): `rayleigh_coefficient`, `rayleigh_color`, `mie_coefficient`, `mie_eccentricity`, `mie_color`, `turbidity`, `sun_disk_scale`, `ground_color`, `energy_multiplier`. La altitud se simula con baja turbidez y Mie reducido (aire más limpio y seco).
- La posición del sol en el cielo físico la determina la `DirectionalLight3D`, por lo que cielo y luz se mantienen coherentes automáticamente.
- Iluminación ambiental y reflejos tomados del cielo (`ambient_light_source = SKY`, `reflected_light_source = SKY`). La luz ambiental mezcla el cielo (60 %) con un relleno azul grisáceo y tiene energía 1,5, para que las sombras no queden negras.

### 1.2 Niebla

Dos capas, ambas en `Environment`:

| Modo | Uso | Coste |
|---|---|---|
| Niebla volumétrica (`volumetric_fog_enabled`) | Perfiles Alto/Ultra: niebla matutina de valle que interactúa con la luz | Alto |
| Niebla de profundidad/altura (`fog_enabled`, con `fog_height` y `fog_height_density`) | Perfiles Bajo/Medio, y como base en todos | Bajo |

Para niebla localizada en valles: `FogVolume` (solo perfiles con volumétrica). Regla: la niebla nunca debe ocultar elementos de juego necesarios (caminos, objetos interactuables cercanos).

### 1.3 Sol (Inti)

- Color cálido de amanecer (temperatura objetivo ~3000–4000 K; si la versión soporta unidades físicas de luz, documentar la configuración usada).
- Sol de media mañana, a unos 26° sobre el horizonte, coherente con el cielo y con el guion: el mensajero llega «a media mañana» y la señal de espera dice que el sol ya está alto. Hasta el 2026-11-11 estaba a 12°, al amanecer: dejaba la plaza en sombras largas casi negras.
- Sombras: `shadow_enabled = true`, modo `SHADOW_PARALLEL_4_SPLITS`; distancia y resolución dependen del perfil.

## 2. Perfiles gráficos

Se implementan en Fase 3 dentro de `core/systems/graphics/`. Los perfiles se aplican en tiempo de ejecución; **no** modifican `ProjectSettings` (muchas de sus claves solo se leen al arrancar).

| Archivo | Tipo | Responsabilidad |
|---|---|---|
| `core/systems/graphics/graphics_profile.gd` | `class_name GraphicsProfile extends Resource` | Datos de un perfil (propiedades `@export` tipadas) |
| `core/systems/graphics/profiles/{low,medium,high,ultra}.tres` | Recursos `GraphicsProfile` | Valores de cada perfil |
| `core/systems/graphics/graphics_settings.gd` | Autoload `GraphicsSettings` | Perfil activo; aplica lo global (`Viewport`: MSAA, escala 3D, antialiasing de pantalla; `RenderingServer`: calidad de sombras); emite `profile_changed(profile: GraphicsProfile)` |
| `core/systems/graphics/environment_quality_controller.gd` | Nodo que se coloca en cada escena de mundo | Recibe por `@export` su `WorldEnvironment` y su `DirectionalLight3D`; escucha `profile_changed` y aplica niebla, SSAO, SSIL/SDFGI y distancia de sombras |

Así Core no conoce las escenas de campaña: cada mundo de campaña incluye su controlador y le asigna sus propios nodos. La persistencia del perfil elegido se añade cuando exista `SaveManager`.

| Ajuste | Bajo | Medio | Alto | Ultra |
|---|---|---|---|---|
| Niebla volumétrica | No | No | Sí | Sí (más densidad de muestras) |
| Niebla de altura | Sí | Sí | Sí | Sí |
| Distancia de sombras | Corta | Media | Larga | Larga |
| Resolución del atlas de sombras | Baja | Media | Alta | Máxima |
| SSAO | No | Sí | Sí | Sí |
| SSIL / SDFGI | No | No | Evaluar | Evaluar |
| Escala de renderizado 3D | 0.75 | 1.0 | 1.0 | 1.0 |
| Antialiasing | FXAA | TAA o MSAA 2× | MSAA 4× / TAA | MSAA 4× + TAA |

Implementación actual de sombras: atlas de 1024 / 2048 / 4096 / 4096 y filtro `SOFT_VERY_LOW` / `SOFT_LOW` / `SOFT_MEDIUM` / `SOFT_HIGH`. La distancia de sombras la aplica el controlador del mundo según el perfil.

El atlas se fija con `RenderingServer.directional_shadow_atlas_set_size(size, is_16bits)`. **El segundo parámetro es `is_16bits`, no “alta calidad”**: pasar `false` cambia el atlas a 32 bits y duplica su memoria. Los perfiles pasan `true` (`GraphicsSettingsService.SHADOW_ATLAS_16_BITS`). La diferencia se comprobó en la memoria de vídeo: −2 MB en Bajo (1024²) y −8 MB en Medio (2048²) al corregirlo.

Los valores concretos se fijan tras medir (ver §4). La tabla es una intención, no un compromiso.

## 3. Escalabilidad prevista

- **LOD:** usar LOD automático de mallas importadas y `visibility_range` para vegetación y objetos lejanos.
- **Culling:** frustum culling del motor; oclusión (`OccluderInstance3D`) solo si las mediciones lo justifican en la llacta.
- **Materiales:** materiales compartidos en `shared_assets/materials/`; preferir instancias de un mismo shader con parámetros a materiales duplicados.
- **Vegetación:** `MultiMeshInstance3D` para elementos repetidos (ichu, piedras).
- **Carga de escenas:** carga en segundo plano (`ResourceLoader.load_threaded_request`) cuando existan varias zonas.
- **Iluminación:** luz principal dinámica (ciclo de amanecer); evaluar baking (`LightmapGI`) solo para interiores estáticos.

**No se optimiza sin medir.** Cada optimización se justifica con una medición antes/después.

## 4. Métricas de referencia

Se establecen al cerrar la Fase 3, antes de ampliar escenarios.

| Métrica | Herramienta | Objetivo inicial |
|---|---|---|
| FPS medio | Monitor de rendimiento del editor / `Performance` | **Vinculante:** ≥ 30 FPS, perfil Bajo, 1080p, en la referencia con GPU integrada. **Recomendado:** ≥ 60 FPS, perfil Medio, 1080p, en la referencia con GPU dedicada (se verifica cuando exista) |
| FPS del percentil 1 % | Medición en script durante un recorrido fijo | Registrar base; no inferior a 2/3 del FPS medio |
| Tiempo de frame (CPU/GPU) | Profiler y monitores del editor | Vinculante: < 33,3 ms. Recomendado: < 16,6 ms |
| Draw calls | `Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME` | Registrar base |
| Memoria de vídeo | `Performance.RENDER_VIDEO_MEM_USED` | Registrar base |
| Tiempo de carga de escena | Medición en script | Registrar base |

### Equipos de referencia (aprobados para la Fase 3)

Son los equipos **donde se mide**, no los requisitos de sistema que se publicarán. Los requisitos mínimos y recomendados de sistema se definirán más adelante, a partir de estas mediciones.

| Equipo | CPU | GPU | RAM | SO | Origen |
|---|---|---|---|---|---|
| **Referencia con GPU integrada** (el más débil disponible) | Intel Core i7-13700 | Intel UHD Graphics 770 (integrada) | 32 GB | Ubuntu 24.04 LTS | Máquina de desarrollo actual (consultada el 2026-11-10) |
| **Referencia con GPU dedicada** | Por definir | GPU dedicada (modelo por definir) | 16 GB | Por definir | Pendiente de decisión del equipo |

> La referencia con GPU integrada no describe la gama del equipo completo: el i7-13700 y los 32 GB son de gama alta; la UHD 770 es el componente limitante para 3D.

Consecuencias de que la referencia tenga GPU integrada:

- El perfil Bajo debe funcionar bien sin niebla volumétrica, SSAO ni SDFGI, y con escala de renderizado 3D reducida.
- La niebla volumétrica es exclusiva de Alto/Ultra y no puede considerarse parte imprescindible de la identidad visual: la niebla de altura debe lograr por sí sola la lectura de valle andino.
- Sin una referencia con GPU dedicada, el objetivo recomendado de 60 FPS no puede verificarse; esa falta se declarará en el informe de la Fase 3 y no bloquea su cierre (solo el objetivo vinculante lo hace).

### Medición con recorrido fijo (2026-11-10)

Comando: `godot --path . --script res://tests/measure_performance.gd`

Condiciones: 1920 × 1080, referencia con GPU integrada, recorrido circular de ~32,5 m corriendo, estamina restaurada para no detenerse, 3 s de calentamiento y 8 s de medida por perfil, **sin vsync** y con `Engine.max_fps = 0`, Godot 4.7.2.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 311,5 | 250,0 | 3,21 ms | 4,0 ms | 5 | 84,7 MB |
| Medio | 97,5 | 83,3 | 10,25 ms | 12,0 ms | 5 | 163,5 MB |

En ambos perfiles el jugador terminó apoyado en el terreno (`is_on_floor = true`). La medición sin límite muestra el margen real; en el juego, vsync lo limita a ~60 FPS.

El objetivo vinculante (≥ 30 FPS) se cumple con amplio margen. La referencia con GPU dedicada sigue sin definir, por lo que los 60 FPS recomendados en esa referencia quedan sin verificar.

> La medición anterior (55,92 FPS, jugador quieto y con `Engine.max_fps = 60`) queda invalidada por no usar un recorrido fijo y por ocultar el margen. También quedó invalidada la primera medición con el terreno invertido.

### Medición con cresta, pasos y murmullo (Fase 4, provisional, 2026-11-11)

Mismo comando y condiciones que la medición anterior. La escena añade la cresta del borde (mismo número de triángulos del terreno, con color por vértice), terrazas macizas, pasos por superficie y los huecos de modelo (`ModelSlot`) sin modelos todavía. Se repitió tres veces con la carga del sistema entre 2,5 y 3. Una primera tanda con carga ~30 por procesos ajenos dio cifras de hasta 46 FPS en Medio y se descartó. Se da la mediana de las tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 276,3 (273,2–282,1) | 200,0 | 3,62 ms | 5,0 ms | 43–44 | 92,5 MB |
| Medio | 92,0 (89,9–95,9) | 83,3 (76,9–83,3) | 10,87 ms | 12–13 ms | 32–33 | 165,3 MB |

Sin cambios apreciables respecto a la medición anterior: el objetivo vinculante se cumple con margen y el perfil Medio supera los 60 FPS. Las cifras cambiarán con los modelos definitivos y la vegetación; para que una medición sea comparable, la carga del sistema debe ser baja (comprobarla con `cat /proc/loadavg`).

### Medición con los primeros modelos (Fase 4, provisional, 2026-11-11)

Mismo comando y condiciones que la medición anterior, con la carga del sistema entre 0,6 y 0,9. La escena carga los seis modelos generados ([ADR-0010](adr/0010-modelos-generados-con-blender.md)): 8 viviendas de ~9 000–10 000 triángulos cada una, más el quero, el pututu, el adoratorio y el telar. Los personajes siguen como bloqueo. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 237,0 (230,1–238,7) | 166,7 (142,9–200,0) | 4,22 ms | — | 118–124 | — |
| Medio | 87,1 (79,8–87,9) | 71,4 (55,6–71,4) | 11,48 ms | — | 81–122 | — |

El objetivo vinculante (≥ 30 FPS) se sigue cumpliendo con margen y el perfil Medio supera los 60 FPS. Las draw calls se triplican porque cada vivienda usa unos nueve materiales planos. Si hiciera falta recuperar margen, la primera medida sería agrupar esos materiales.

### Medición con vegetación (Fase 4, provisional, 2026-11-11)

Mismo comando y condiciones que la medición anterior, con la carga del sistema entre 2,2 y 2,6. La escena añade la vegetación de `vegetation.gd`: unas 3 100 matas de ichu (75–100 triángulos cada una) en 96 bloques `MultiMeshInstance3D` que se ocultan a 50 m y no proyectan sombra, y 24 queñuas de ~1 000 triángulos con sombra. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 204,1 (199,9–206,9) | 166,7 | 4,90 ms | 6,0 ms | 201–202 | 94,0 MB |
| Medio | 73,2 (72,0–75,1) | 58,8 (52,6–58,8) | 13,66 ms | 17–19 ms | 165 | 166,8 MB |

Una primera versión más densa en triángulos (150 por mata y 2 000 por árbol) bajaba el perfil Medio a 61–66 FPS con p1 de 40–45. Al quitar por separado el ichu o la queñua se recuperaban unos 70 FPS en cada caso, así que se aligeraron los dos modelos. El objetivo vinculante (≥ 30 FPS) se sigue cumpliendo con margen y el perfil Medio queda por encima de 60 FPS de media, aunque su p1 baja de 60. Si hiciera falta más margen, las palancas son la distancia de ocultación del ichu y la sombra de las queñuas.

### Medición con personajes (Fase 4, provisional, 2026-11-11)

Mismo comando y condiciones, con la carga del sistema entre 1,9 y 2,2. La escena sustituye las cápsulas de los 9 personajes por modelos estáticos de ~950–1 100 triángulos (alcance v3.3). Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 195,4 (192,1–201,7) | 142,9 (142,9–166,7) | 5,12 ms | 6–7 ms | 182–198 | 94,5 MB |
| Medio | 72,3 (70,9–75,7) | 55,6 (50,0–58,8) | 13,83 ms | 17–20 ms | 164–172 | 167,4 MB |

Sin cambios apreciables respecto a la medición con vegetación.

### Medición con mallas agrupadas (Fase 4, provisional, 2026-11-11)

Mismo comando y condiciones, con la carga del sistema entre 0,7 y 2,2. Cada modelo generado pasa a ser una sola malla, sin material y con color por vértice, de una cara salvo las hojas del ichu. Antes eran varias mallas, con hasta nueve materiales a dos caras por vivienda. Además, los personajes recuperan el balanceo de reposo. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 224,8 (222,9–225,6) | 166,7 | 4,45 ms | 6 ms | 62–70 | 94,6 MB |
| Medio | 80,7 (71,8–83,7) | 66,7 (55,6–71,4) | 12,39 ms | 14–18 ms | 57–65 | 167,4 MB |

Las draw calls bajan de unas 165–200 a unas 60. El perfil Medio sube de ~72 a ~81 FPS y su p1 queda por encima de 60 en dos de las tres ejecuciones.

### Medición con personajes de MakeHuman (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU. Los nueve personajes pasan a ser los de MakeHuman con ropa propia y captura de CMU ([ADR-0016](adr/0016-personajes-realistas-makehuman.md)): unos 8500–10 100 triángulos y 5–6 mallas cada uno.

La carga del sistema estaba entre 5,2 y 6,7 por procesos ajenos y varió mucho entre ejecuciones. Por eso el commit anterior (1f53822) se midió justo después, en condiciones parecidas.

| Perfil | FPS medio (3 ejecuciones) | Draw calls | Vídeo |
|---|---|---|---|
| Bajo | 141,2 (140,1–147,1) | 54–72 | 182,7 MB |
| Medio | 55,6 (54,6–59,5) | 55–150 | 255,5 MB |
| Bajo, commit anterior, carga parecida | 143,5–157,6 | — | — |
| Medio, commit anterior, carga parecida | 50,1–52,9 | — | — |

- Las diferencias entran en el ruido de la medición. La memoria de vídeo sube unos 37 MB por las texturas de piel, pelo y ojos.
- Tras corregir postura, boca y ojos (con pestañas y sin dientes), una ejecución con carga 5,1 dio Bajo 142,5 FPS y Medio 53,6 FPS: sin cambio apreciable.
- El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con margen.

### Medición con personajes con esqueleto y viento (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU que la medición con texturas de detalle. La escena añade:

- nueve personajes con esqueleto de 18 huesos y animaciones ([ADR-0015](adr/0015-personajes-con-esqueleto.md));
- la cabeza que gira hacia el jugador;
- el viento en el ichu y la queñua;
- los pasos y los golpes de trabajo en 3D.

La carga del sistema estaba entre 4,3 y 4,5 por procesos ajenos, así que el commit anterior (433a54f) se midió en las mismas condiciones. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | Frame medio | Draw calls | Vídeo |
|---|---|---|---|---|
| Bajo | 153,9 (153,6–154,0) | 6,5 ms | 57 | 145,7 MB |
| Medio | 59,0 (58,7–60,0) | 17,0 ms | 56 | 218,8 MB |
| Bajo, commit anterior, misma carga | 166,8 | — | — | — |
| Medio, commit anterior, misma carga | 60,1 | — | — | — |

- El esqueleto y el viento cuestan aproximadamente 0,5 ms por fotograma: 13 FPS en Bajo y prácticamente nada en Medio, donde manda el sombreado de píxeles.
- El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con margen.
- Los personajes que salen de la escena (la comitiva) dejan de procesarse.

### Medición con texturas de detalle (Fase 4, provisional, 2026-11-11)

Mismo comando, en la GPU integrada de referencia (Intel Graphics RPL-S, Vulkan, Forward+). La escena añade el shader triplanar con texturas de detalle ([ADR-0014](adr/0014-texturas-de-detalle-triplanares.md)), el *tonemap* AgX y la plaza y los caminos pintados en el terreno. La carga del sistema estaba entre 3 y 6 por procesos ajenos (navegador sin ventana), así que el commit anterior se midió en las mismas condiciones para comparar. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | FPS p1 | Draw calls | Vídeo |
|---|---|---|---|---|
| Bajo | 146,4 (141,7–155,2) | 125,0 | 107 | 145,2 MB |
| Medio | 54,1 (53,5–54,6) | 45,5 (45,5–47,6) | 130 | 218,0 MB |
| Medio, commit anterior, misma carga | 76,5 | 66,7 | — | — |

- El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con margen.
- El perfil Medio queda por debajo de 60 FPS en esta GPU integrada. Los 60 FPS recomendados se definen para la referencia con GPU dedicada (§ objetivos), que sigue sin existir; en esta GPU el perfil recomendado es Bajo.
- Aislando el terreno (con un material plano), el perfil Medio sube a ~69 FPS: el shader del terreno cuesta unos 10 FPS y el de los modelos y muros unos 7.
- Ya aplicado para recuperar margen: no se leen los planos de la proyección sin peso, ni las normales a más de 35 m, y el filtrado es trilineal (el anisotrópico costaba unos 4 FPS).
- Si hiciera falta más, la siguiente medida sería bajar las texturas del terreno a 512 px en el perfil Bajo.

### Medición con terrazas de pirka, props y relieve (Fase 4, provisional, 2026-11-11)

Mismo comando y condiciones, con la carga del sistema entre 1,2 y 2,5. La escena añade los muros de pirka de las terrazas, la tierra con surcos, cántaros y leña junto a las casas, el relieve del campo, más ichu en la cresta, la luz ambiental más alta y el balanceo de piernas y brazos. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 217,1 (216,8–218,4) | 166,7 | 4,61 ms | 6 ms | 62 | 117,0 MB |
| Medio | 77,1 (74,5–80,2) | 62,5 (58,8–71,4) | 12,98 ms | 14–17 ms | 56–60 | 190,1 MB |

Respecto a la medición con mallas agrupadas, el perfil Medio baja unos 4 FPS y la memoria de vídeo sube unos 23 MB. El objetivo vinculante y los 60 FPS de media se siguen cumpliendo.

### Medición de la llacta completa (Fase 4, provisional)

Condiciones: mismo comando, perfil Bajo y Medio, recorrido circular de ~10 m dentro de la plaza, corriendo, estamina restaurada, 3 s de calentamiento y 8 s de medida, sin vsync y con `Engine.max_fps = 0`. La escena incluye plaza, 8 viviendas agrupadas, terrazas con rampas, mirador, límites, 3 interactuables, 9 NPC y ambiente de viento y aves. **El evento no arranca durante la medición**: el reloj de llegada es de 240 s y la medida dura unos 25 s.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 259,3 | 142,9 | 3,86 ms | 7,0 ms | 43 | 92,4 MB |
| Medio | 86,2 | 55,6 | 11,60 ms | 18,0 ms | 33 | 165,2 MB |

El jugador termina apoyado en el terreno en ambos perfiles. El objetivo vinculante se sigue cumpliendo con margen y el perfil Medio supera los 60 FPS. La variación entre ejecuciones es apreciable: una primera ejecución en frío dio 216 / 76 FPS y las siguientes 259–262 / 86 FPS, así que las cifras se leen como orden de magnitud.

> La medición anterior de esta misma escena (262,8 / 70,2 FPS y 84,9 / 163,7 MB) queda invalidada: se hizo con el atlas de sombras en 32 bits por el parámetro mal pasado. Los valores actuales usan 16 bits.
