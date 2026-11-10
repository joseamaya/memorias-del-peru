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
- Iluminación ambiental y reflejos tomados del cielo (`ambient_light_source = SKY`, `reflected_light_source = SKY`).

### 1.2 Niebla

Dos capas, ambas en `Environment`:

| Modo | Uso | Coste |
|---|---|---|
| Niebla volumétrica (`volumetric_fog_enabled`) | Perfiles Alto/Ultra: niebla matutina de valle que interactúa con la luz | Alto |
| Niebla de profundidad/altura (`fog_enabled`, con `fog_height` y `fog_height_density`) | Perfiles Bajo/Medio, y como base en todos | Bajo |

Para niebla localizada en valles: `FogVolume` (solo perfiles con volumétrica). Regla: la niebla nunca debe ocultar elementos de juego necesarios (caminos, objetos interactuables cercanos).

### 1.3 Sol (Inti)

- Color cálido de amanecer (temperatura objetivo ~3000–4000 K; si la versión soporta unidades físicas de luz, documentar la configuración usada).
- Ángulo bajo inicial (amanecer) coherente con el cielo.
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
| FPS medio | Monitor de rendimiento del editor / `Performance` | **Vinculante:** ≥ 30 FPS, perfil Bajo, 1080p, en el equipo de gama baja. **Recomendado:** ≥ 60 FPS, perfil Medio, 1080p, en el equipo de gama media (se verifica cuando exista) |
| FPS del percentil 1 % | Medición en script durante un recorrido fijo | Registrar base; no inferior a 2/3 del FPS medio |
| Tiempo de frame (CPU/GPU) | Profiler y monitores del editor | Vinculante: < 33,3 ms. Recomendado: < 16,6 ms |
| Draw calls | `Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME` | Registrar base |
| Memoria de vídeo | `Performance.RENDER_VIDEO_MEM_USED` | Registrar base |
| Tiempo de carga de escena | Medición en script | Registrar base |

### Equipos de referencia (propuesta — requiere aprobación antes de la Fase 3)

Son los equipos **donde se mide**, no los requisitos de sistema que se publicarán. Los requisitos mínimos y recomendados de sistema se definirán más adelante, a partir de estas mediciones.

| Equipo | CPU | GPU | RAM | SO | Origen |
|---|---|---|---|---|---|
| **Referencia de gama baja** (el más débil disponible) | Intel Core i7-13700 | Intel UHD Graphics 770 (integrada) | 32 GB | Ubuntu 24.04 LTS | Máquina de desarrollo actual (consultada el 2026-11-10) |
| **Referencia de gama media** | Por definir | GPU dedicada de gama media (modelo por definir) | 16 GB | Por definir | Pendiente de decisión del equipo |

Consecuencias de que el equipo de gama baja tenga GPU integrada:

- El perfil Bajo debe funcionar bien sin niebla volumétrica, SSAO ni SDFGI, y con escala de renderizado 3D reducida.
- La niebla volumétrica es exclusiva de Alto/Ultra y no puede considerarse parte imprescindible de la identidad visual: la niebla de altura debe lograr por sí sola la lectura de valle andino.
- Sin un equipo de gama media disponible, el objetivo recomendado de 60 FPS no puede verificarse; esa falta se declarará en el informe de la Fase 3 y no bloquea su cierre (solo el objetivo vinculante lo hace).
