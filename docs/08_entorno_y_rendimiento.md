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

La niebla volumétrica de Alto/Ultra se ajusta en el `Environment` a densidad 0,004, longitud 100 m, albedo azul grisáceo, emisión oscura y `sky_affect` 0,15. Con los valores por defecto (densidad 0,05 y cielo afectado al 100 %) la escena quedaba cubierta por una niebla marrón; los valores actuales son los que se ven en el vídeo de promoción.

### 1.3 Sol (Inti)

- Color cálido de media mañana, coherente con el guion; energía 1,35. El color actual del `DirectionalLight3D` es `(1, 0,84, 0,66)`.
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
| FPS medio | Monitor de rendimiento del editor / `Performance` | **Vinculante:** ≥ 30 FPS, perfil Bajo, salida a 1080p, en la referencia con GPU integrada. **Comprometido:** ≥ 60 FPS, perfil Medio, salida a 1080p con el 3D al 83 %, en la misma referencia |
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
- El objetivo de 60 FPS se mide en la GPU integrada, no se aplaza a una GPU dedicada. Con el 3D al 83 % de 1080p y la interfaz a resolución completa, los tres actos lo superan con margen (2026-11-14).

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

Mismo comando y condiciones que la medición anterior, con la carga del sistema entre 0,6 y 0,9. La escena carga los seis modelos generados (ADR-0010): 8 viviendas de ~9 000–10 000 triángulos cada una, más el quero, el pututu, el adoratorio y el telar. Los personajes siguen como bloqueo. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

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

### Medición con movimiento natural de personajes (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU, con el movimiento de ADR-0019: aceleración y giro en `NpcActor`, pies fijados en los ciclos y segundo reposo. Carga del sistema entre 4,8 y 6,0.

| Perfil | FPS medio (2 ejecuciones) | Vídeo |
|---|---|---|
| Bajo | 141,1–147,2 | 208,6 MB |
| Medio | 56,8–57,0 | 281,4 MB |

Sin cambio apreciable respecto a la medición anterior.

El movimiento se mide aparte con `tests/measure_motion.gd`: deslizamiento del pie de apoyo, giros por fotograma y aceleración. Los valores están en ADR-0019.

### Medición con ropa cortada y cosida (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU, con la ropa de ADR-0020:
- prendas cortadas y caídas en la postura de reposo;
- sin la piel que la ropa tapa;
- tejido de lana Fabric031.

Cada personaje tiene entre 8700 y 9900 triángulos (600–1300 más que antes): la ropa pasa de unos 2400–3600 triángulos a 3300–4300, y el cuerpo pierde unos 270–400.

| Perfil | FPS medio (1 ejecución) | FPS p1 | Vídeo |
|---|---|---|---|
| Bajo | 151,2 | 125,0 | 208,8 MB |
| Medio | 56,5 | 50,0 | 281,9 MB |

Sin cambio apreciable respecto a la medición anterior. El movimiento medido con `tests/measure_motion.gd` tampoco cambia.

### Medición con construcciones de pirca (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU, con las construcciones de ADR-0021:
- casas y terrazas de piedra tosca;
- tercera variante de casa;
- poyos de pirca;
- dos corrales.

Las casas pasan de 9000–10 300 triángulos a 11 300–21 300. La carga del sistema estaba entre 8 y 17 por procesos ajenos, así que el commit anterior (aa88d48) se midió alternando con el actual, en una copia aparte.

| Medición | Bajo | Medio |
|---|---|---|
| Ahora (2 ejecuciones) | 122,6–132,6 FPS | 51,7–51,9 FPS |
| Commit anterior, misma carga (2 ejecuciones) | 138,8–140,6 FPS | 52,5–55,4 FPS |

- **Coste:** la pirca cuesta un 5–12 % en Bajo y un 1–6 % en Medio. El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con margen.
- **Palanca si hiciera falta:** una versión simplificada de las piedras a distancia.

### Medición tras la corrección del `smoothstep` de pendiente (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU, en el commit 2cbeb56. Se buscaba repetir con el equipo descargado, pero la carga del sistema varió entre 1,8 y 18 por procesos ajenos (navegador y aplicaciones de escritorio).

| Medición | Bajo | Medio | Vídeo (Bajo / Medio) |
|---|---|---|---|
| Ahora, 3 ejecuciones seguidas con carga 2,1–2,6 | 124,7–126,4 FPS (p1 91–100) | 43,0–48,3 FPS (p1 31–43) | 213 / 286 MB |
| Ahora, alternando con el commit anterior (97c4165), sin la de carga 14,8 | 122–132 FPS | 49–52 FPS | — |
| Commit anterior, alternando | 118–131 FPS | 51–55 FPS | — |
| Shader nuevo en la copia del commit anterior (3 ejecuciones alternas) | 124–130 FPS | 52–55 FPS | — |
| Shader antiguo, misma copia | 122–132 FPS | 47–54 FPS | — |

- La corrección del `smoothstep` no tiene coste medible: alternando las dos versiones del shader en la misma copia, los rangos se solapan.
- Entre copias, el perfil Medio queda unos 3 FPS por debajo en el commit actual, pero el código del juego solo difiere en esa línea y la prueba en la misma copia no lo reproduce. Se atribuye al ruido.
- El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con margen. El perfil Medio sigue por debajo de 60 FPS en esta GPU integrada, como en las mediciones anteriores.
- La medición con el equipo de verdad descargado sigue pendiente.

### Medición con textiles, caída y manto con muelles (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU. La ropa lleva textiles de 768 × 1024 por personaje, caída simulada (horneada) y, en los personajes con manto, un `SpringBoneSimulator3D` de tres cadenas (ADR-0018). Carga del sistema entre 10,8 y 13,8 por procesos ajenos.

| Perfil | FPS medio (2 ejecuciones) | Vídeo |
|---|---|---|
| Bajo | 141,6–148,1 | 208,6 MB |
| Medio | 51,4–54,9 | 281,7 MB |

- Frente a la medición con cabezas de Rocketbox, los FPS no cambian de forma apreciable y la memoria de vídeo sube unos 10 MB.
- Con textiles de 1536 × 2048, la memoria subía unos 62 MB; por eso se reducen a la mitad.

### Medición con cabezas de Rocketbox (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU. Diez personajes con cabeza de Rocketbox (ADR-0017): entre 6900 y 8600 triángulos cada uno, con texturas de cara de 1K y mapa de normales. La carga del sistema rondaba 10 por procesos ajenos (navegador sin ventana, base de datos), así que el commit anterior (e05b752) se midió justo antes, en las mismas condiciones.

| Medición | Bajo | Medio | Vídeo (Medio) |
|---|---|---|---|
| Ahora (3 ejecuciones) | 124,3–138,0 FPS | 29,6–49,6 FPS | 272 MB |
| Commit anterior, misma carga | 137,6 FPS | 51,5 FPS | — |

- Con esta carga, las diferencias entran en el ruido. El 29,6 de Medio es una ejecución aislada; las otras dos dieron 49,5 y 49,6.
- La memoria de vídeo sube unos 16 MB por las texturas de cara.
- El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con margen.
- Conviene repetir la medición con el equipo descargado.

### Medición con personajes de MakeHuman (Fase 4, provisional, 2026-11-12)

Mismo comando y GPU. Los nueve personajes pasan a ser los de MakeHuman con ropa propia y captura de CMU (ADR-0016): unos 8500–10 100 triángulos y 5–6 mallas cada uno.

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

- nueve personajes con esqueleto de 18 huesos y animaciones (ADR-0015);
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

Mismo comando, en la GPU integrada de referencia (Intel Graphics RPL-S, Vulkan, Forward+). La escena añade el shader triplanar con texturas de detalle (ADR-0014), el *tonemap* AgX y la plaza y los caminos pintados en el terreno. La carga del sistema estaba entre 3 y 6 por procesos ajenos (navegador sin ventana), así que el commit anterior se midió en las mismas condiciones para comparar. Se da la mediana de tres ejecuciones y, entre paréntesis, el rango.

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

### Medición con nubes, cordillera y luz cálida (Fase 4, provisional, 2026-11-13)

Mismo comando y recorrido circular. La escena incluye la cúpula de nubes procedurales, la cordillera lejana de dos capas, la niebla volumétrica corregida, la iluminación más cálida, las manos en primera persona, las puertas de las viviendas y los mantos ajustados. Se da la mediana de tres ejecuciones con una carga del sistema de 2–3.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 127,1 | 100,0 | 7,87 ms | 10 ms | 141 | 193,7 MB |
| Medio | 46,0 | 38,5 | 21,8 ms | 26 ms | 115 | 266,5 MB |

El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con más de cuatro veces el margen. El perfil Medio queda por debajo de 60 FPS en esta GPU integrada, como en las mediciones anteriores; el perfil recomendado en esta máquina sigue siendo Bajo.

### Medición con el perfil Medio por defecto y oclusión ambiental (Fase 4, 2026-11-13)

El juego pasa a arrancar en **Medio** ([bitácora](bitacora.md)): el perfil Bajo se reserva para equipos lentos y para la medición de referencia. Para que Medio llegue a 60 FPS en la GPU integrada se desactiva su MSAA 2× y se mantiene el FXAA: la oclusión ambiental (SSAO) se conserva porque es la que da profundidad a la escena. Mismo comando y recorrido circular que las mediciones anteriores.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Bajo | 118,6 | 90,9 | 8,43 ms | 12 ms | 114–158 | 219,7 MB |
| Medio | 61,8 | 52,6 | 16,2 ms | 19 ms | 155 | 265,1 MB |

- El perfil Medio supera los 60 FPS de media en la GPU integrada de referencia: el objetivo recomendado de docs/01 §5 se cumple también ahí, sin esperar a la referencia con GPU dedicada. Es la mediana de tres ejecuciones; una de ellas, con el equipo cargado, dio 53,1 FPS y 299 draw calls, así que las cifras se leen como orden de magnitud.
- El jugador termina apoyado en el terreno en ambos perfiles.
- La medición se hizo con la carga del sistema habitual del equipo; las cifras se leen como orden de magnitud.


### Medición del paso con paisaje (Fase 8, provisional, 2026-11-13)

Comando: `godot --path . --script res://tests/measure_paso_performance.gd`.
Condiciones: 1920 × 1080, la misma GPU integrada de referencia, vista girando
sobre el paso, 3 s de calentamiento y 8 s de medida por perfil, sin vsync y con
`Engine.max_fps = 0`. La escena incluye el terreno del desfiladero con cresta,
sendero y campamento pintados, arroyo, roquedales, refugio de pirca, ichu y
queñua con viento, cielo físico con nubes y cuatro exploradores con modelo
propio. El jugador está quieto en la aparición y la vista gira 0,35 rad/s.

| Perfil | FPS medio | FPS p1 | Frame medio | Frame p99 | Vídeo |
|---|---|---|---|---|---|
| Bajo | 125,7 (123,5–128,6) | 83,3–100,0 | 7,95–8,10 ms | 10–12 ms | 152,5 MB |
| Medio | 58,4 (57,9–60,6) | 50,0–52,6 | 16,9–17,3 ms | 19–20 ms | 180,7–184,4 MB |

- El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con más de cuatro veces
  el margen.
- El perfil Medio queda en el límite de 60 FPS. Las tres ejecuciones con carga
  8,5 dieron 57,9–59,1 FPS; las ejecuciones con carga 0,7–1,3 dieron 60,5–64,6.
  La diferencia es la carga del equipo, no un cambio de escena: debe repetirse
  en reposo antes de dar la cifra por buena.
- Las draw calls variaron entre 14 y 272 por la misma carga y no se usan como
  referencia. La medición es un orden de magnitud, como las anteriores.
- La medición se hizo con los actores de modelo propio; después cambiaron a
  maniquíes con vestuario (ADR-0042), que añaden
  mallas y draw calls, así que debe repetirse para dar la cifra por buena.
- El Cusco con multitud y batalla se mide en la sección final de la Fase 8.


### Medición con maniquíes vestidos (Fase 8, 2026-11-14)

Mismos comandos y condiciones que las mediciones del acto I y del paso, con
carga del sistema 1,04, 1920 × 1080, sin vsync y con `Engine.max_fps = 0`. La
llacta y el paso usan ahora maniquíes UAL1 con vestuario y rostro anclados a
huesos (ADR-0042); el Cusco queda pendiente.

| Escena | Perfil | FPS medio | FPS p1 |
|---|---|---|---|
| Llacta (acto I) | Bajo | 139,6 | 111,1 |
| Llacta (acto I) | Medio | 70,6 | 62,5 |
| Paso (acto II) | Bajo | 144,1 | 125,0 |
| Paso (acto II) | Medio | 63,2 | 58,8 |

- El objetivo vinculante (≥ 30 FPS en Bajo) se cumple con amplio margen.
- El perfil Medio supera los 60 FPS de media en las dos escenas medidas, aun
  con las mallas extra de la ropa y las caras.
- Las cifras siguen siendo un orden de magnitud: la carga del equipo y las
  draw calls varían entre ejecuciones. El Cusco con multitud y batalla se mide en la sección final de la Fase 8.


### Medición con tela, sandalias y textiles (Fase 8, provisional, 2026-11-14)

Mismos comandos y condiciones, con una carga del sistema de 5,6: la lliclla de
paño largo, las sandalias y los textiles con franjas añaden mallas y draw calls.
La cifra no es comparable con la medición anterior (carga 1,04); se repite en
reposo antes de darla por buena.

| Escena | Perfil | FPS medio | FPS p1 |
|---|---|---|---|
| Llacta (acto I) | Bajo | 106,3 | 76,9 |
| Llacta (acto I) | Medio | 52,6 | 41,7 |
| Paso (acto II) | Bajo | 131,3 | 100,0 |
| Paso (acto II) | Medio | 59,1 | 50,0 |

- El objetivo vinculante (≥ 30 FPS en Bajo) se sigue cumpliendo, aun con la
  carga alta.
- El perfil Medio baja respecto a la medición sin tela; no se puede dar por
  bueno hasta repetir con el equipo descargado. La llacta midió ~400 draw calls
  en esa vista: la ropa y las caras añaden muchas mallas pequeñas.
- Si el Medio no llega a 60 en reposo, las palancas son fusionar mallas por
  material (caras y sandalias) y compartir los materiales de la ropa.
- La medición es anterior al audio de los actos II y III; los nodos de audio
  añaden poco coste, pero debe repetirse junto con el resto en reposo.
- El Cusco con multitud y batalla se mide en la sección final de la Fase 8.


### Medición final de la Fase 8 en reposo (2026-11-14)

Comandos:

```bash
godot --path . --script res://tests/measure_performance.gd
godot --path . --script res://tests/measure_paso_performance.gd
godot --path . --script res://tests/measure_ciudad_performance.gd
```

Condiciones: 1920 × 1080, Intel UHD Graphics 770 (RPL-S), Vulkan, Forward+,
3 s de calentamiento y 8 s de medida por perfil, sin vsync y con
`Engine.max_fps = 0`. Tres ejecuciones por escena; se da la mediana y, entre
paréntesis, el rango. La llacta y el paso se midieron con carga 0,4; el Cusco,
con el controlador de calidad activo (SSAO en Medio), con carga 1,0; una pasada
con carga 1,4 dio 67,0. Una medición anterior del Cusco con carga 10,6 dio 62,9,
también por encima de 60. El Cusco se mide con las diez figuras de multitud y
la defensa en curso (cuatro chancas), con el jugador inmune para que la muestra
no termine. Esta sección sustituye a las mediciones provisionales de la misma
fecha.

| Escena | Perfil | Carga | FPS medio | FPS p1 | Draw calls | Vídeo |
|---|---|---|---|---|---|---|
| Llacta (acto I) | Bajo | 0,4 | 129,1 (128,7–130,6) | 100,0 | 85 | 132,0 MB |
| Llacta (acto I) | Medio | 0,4 | 70,5 (70,4–70,5) | 55,6 | 35 | 160,5 MB |
| Paso (acto II) | Bajo | 0,4 | 137,8 (135,5–138,0) | 111,1 | 10 | 121,7 MB |
| Paso (acto II) | Medio | 0,4 | 61,0 (60,4–61,3) | 55,6 | 79 | 150,0 MB |
| Cusco (acto III) | Bajo | 1,0 | 129,2 (125,8–129,4) | 90,9–100,0 | 5 | 140,9 MB |
| Cusco (acto III) | Medio | 1,0 | 66,9 (63,6–67,1) | 55,6–58,8 | 1028 | 169,1 MB |

- Los tres actos superan el objetivo vinculante (≥ 30 FPS en Bajo) y el
  recomendado (≥ 60 FPS en Medio) en la GPU integrada de referencia a 1080p.
  La llacta y el paso, con carga 4,3, dieron 68,2 y 61,1 en Medio; el Cusco,
  con SSAO y carga 1,0, dio 63,6–67,1; una medición anterior con carga 10,6 dio 62,9. Las tres escenas
  mantienen el margen incluso con el escritorio cargado.
- El paso es el más ajustado. Para llegar a 60 se aplicaron dos cambios
  medidos: el terreno del desfiladero recibe sombra pero no la proyecta, y el
  `fbm` de la cúpula de nubes bajó de cinco a tres octavas. Antes de esos
  cambios el paso medía 54–56 FPS en Medio; el cielo conserva las nubes altas y
  el terreno sigue leyéndose por normales, rocas, vegetación y refugio. El
  terreno plano del Cusco también recibe sombra sin proyectarla.
- En Medio, la llacta es la más rápida (70,5); el Cusco (66,9) y el paso (61,0)
  quedan por encima de 60. El Cusco tiene ~1030 draw calls por las figuras
  vestidas, los props y el SSAO; el coste no lo hunde porque la ciudad es plana
  y las catorce casas comparten tres modelos. Si se añaden más figuras o
  efectos, hay que volver a medir.
- Las draw calls y la memoria de vídeo varían entre ejecuciones y no se usan
  como criterio; se incluyen como orden de magnitud. La GPU dedicada sigue sin
  definirse (docs/08 §4), así que el objetivo recomendado para ella no se ha
  verificado.


### Acto I con los modelos MakeHuman/Rocketbox (2026-11-14)

Comando: `godot --path . --script res://tests/measure_performance.gd`.
Condiciones: 1920 × 1080, Intel UHD Graphics 770, Vulkan, Forward+, carga del
sistema 1,1–6,9, tres ejecuciones, sin vsync y con `Engine.max_fps = 0`.

| Escena | Perfil | FPS medio | FPS p1 | Draw calls |
|---|---|---|---|---|
| Llacta (acto I) | Bajo | 128,4 (118,2–130,5) | 83,3–100,0 | 109–182 |
| Llacta (acto I) | Medio | 61,1 (58,7–65,3) | 50,0–58,8 | 109–182 |

- El acto I vuelve a los modelos MakeHuman/Rocketbox, con cara, ropa y
  animaciones propias. El coste sube respecto a UAL1 (70,5 → 61,1 FPS en
  Medio), pero el objetivo de 60 se cumple por mediana.
- El margen es estrecho: una pasada dio 58,7 FPS en Medio. Si hace falta más
  holgura, las palancas son LODs, fusión de mallas/materiales, sombras de
  personaje o reducir el número de figuras visibles. No se aplicaron para no
  perder calidad en esta pasada.
- El paso y el Cusco no cambian: sus mediciones siguen en la sección anterior.


### Actos II y III con los modelos MakeHuman/Rocketbox (2026-11-14)

Comandos: `measure_paso_performance` y `measure_ciudad_performance`.
Condiciones: 1920 × 1080, Intel UHD 770, Vulkan, Forward+, carga 3,8–8,3,
tres ejecuciones, sin vsync y con `Engine.max_fps = 0`.

| Escena | Perfil | FPS medio | FPS p1 | Draw calls |
|---|---|---|---|---|
| Paso (acto II) | Bajo | 130,4 (128,5–131,8) | 100,0–111,1 | 44–54 |
| Paso (acto II) | Medio | 57,5 (57,2–57,6) | 50,0–52,6 | 44–54 |
| Cusco (acto III) | Bajo | 116,7 (114,2–117,4) | 83,3–90,9 | 714–715 |
| Cusco (acto III) | Medio | 59,0 (58,5–60,2) | 41,7–50,0 | 714–715 |

- Los modelos propios (campamento, chancas, reclutas, Cusi, aliados y
  defensores) mejoran mucho el aspecto, pero cuestan ~3–8 FPS frente a UAL1.
  Con carga alta, el paso y el Cusco quedan justo por debajo de 60 en Medio.
- El acto I, medido con carga 1,1, sí supera 60 (61,1 de mediana). Falta
  repetir el paso y el Cusco en reposo para saber si el objetivo se cumple.
- Palancas si no se cumple: reducir la multitud del Cusco (10 → 8), LODs,
  materiales de tela más simples, o dejar UAL1 para figuras de fondo. No se
  aplicaron para no perder el salto visual en esta pasada.


### Multitud del Cusco con modelos propios (2026-11-14)

Comando: `godot --path . --script res://tests/measure_ciudad_performance.gd`.
Condiciones: 1920 × 1080, Intel UHD 770, Vulkan, Forward+, carga 15,5–22,5
(medición conservadora), tres ejecuciones, sin vsync y con `Engine.max_fps = 0`.

| Cusco (acto III) | Perfil | FPS medio | FPS p1 | Draw calls |
|---|---|---|---|---|
| Antes (multitud procedural) | Medio | 59,0 | 41,7–50,0 | 714–715 |
| Después (multitud con modelos) | Medio | 61,3 (61,1–61,9) | 52,6 | 299–301 |
| Después (multitud con modelos) | Bajo | 115,4 (115,3–117,0) | 83,3–90,9 | 299–301 |

- La hipótesis se cumplió: el vestuario procedural montaba muchas piezas con
  materiales propios por figura. Diez GLB con cuatro o cinco mallas bajan el
  Cusco de **714 a 299 draw calls** (−58 %) y suben el perfil Medio de 59,0 a
  **61,3 FPS**, medido además con más carga que la pasada anterior.
- No hizo falta recortar la multitud ni apagar sombras: las palancas de la
  sección anterior quedan sin usar.
- La ropa oscura del chanca se tiñe con el uniforme `cloth_tint` del shader de
  tela, que multiplica el tejido; antes era un material plano que borraba el
  dibujo.
- El paso (acto II) no cambia con este trabajo. Su medición de 57,5 FPS sigue
  pendiente de repetir en una máquina en reposo.


### Escala del búfer 3D al 83 % en el perfil Medio (2026-11-14)

Comandos: `measure_performance`, `measure_paso_performance`,
`measure_ciudad_performance` y `measure_scale_variants` (variantes de escala).
Condiciones: salida 1920 × 1080, Intel UHD 770, Vulkan, Forward+, carga 6,7–13,0,
tres ejecuciones, sin vsync y con `Engine.max_fps = 0`.

Con el 3D al 100 %, el paso se quedaba en **58,7 FPS** en Medio. La comparación
de variantes en un mismo proceso (paso, 8 s por variante) confirmó que el límite
es el relleno de píxeles, no la geometría: la escena tiene 44–54 draw calls.

| Escala y upscaler | FPS medio |
|---|---|
| 1,00 bilineal | 58,0 |
| 0,95 bilineal | 57,7 |
| 0,83 bilineal | 72,1 |
| 0,83 FSR 1 | 66,0 |
| 0,75 bilineal | 84,1 |
| 0,75 FSR 1 | 77,3 |

- **FSR 1 cuesta un 8–9 % más que el bilineal** en esta GPU, así que el perfil
  usa el bilineal. El campo `scaling_3d_mode` del perfil queda disponible para
  otros equipos.
- Se adopta la práctica del proyecto hermano *El despertar del sol* (decisión
  0005, misma GPU): el 3D se renderiza al **83 %** de 1080p y la interfaz a
  resolución completa. El criterio se lee como «60 FPS con salida a 1080p», no
  «3D nativo a 1080p».

| Escena | Perfil | FPS medio | Draw calls |
|---|---|---|---|
| Llacta (acto I) | Medio | 76,5 (76,4–78,2) | 149–183 |
| Paso (acto II) | Medio | 72,8 (70,8–72,8) | 44–54 |
| Cusco (acto III) | Medio | 73,2 (72,1–73,4) | 300–301 |
| Cusco con mercado (acto III) | Medio | 72,9 (72,2–73,7) | 327–328 |
| Llacta (acto I) | Bajo | 122,3 (120,3–123,6) | 149–183 |
| Paso (acto II) | Bajo | 126,2 (121,5–129,1) | 44–54 |
| Cusco (acto III) | Bajo | 117,3 (115,2–118,6) | 300–301 |

- Los tres actos superan los 60 FPS en Medio **con margen** (12–16 FPS por
  encima) y los 115 en Bajo. Antes del cambio, el paso quedaba en 58,7 y el
  Cusco en 61,3.
- El percentil 1 % se movió entre 41,7 y 66,7 según la carga del sistema en el
  momento de medir; en esta máquina lo dominan los tirones del escritorio, no
  la escena.
- La captura del paso al 83 % conserva el detalle del terreno y del ichu; la
  diferencia con el 100 % no se aprecia a tamaño de juego.
