# 13 — Pipeline de escenarios

- **Versión:** 1.0 — 2026-11-19
- **Ámbito:** cómo se construye un territorio y un sector, desde la geografía hasta la escena jugable.
- **Marco:** [arquitectura](02_arquitectura.md), [GDD de mundo](11_diseno_de_mundo.md), [rendimiento](08_entorno_y_rendimiento.md) y [convenciones históricas](07_convenciones_historicas.md).
- **Estado:** adopción provisional; F1 cerrada y F2 en curso. La revisión definitiva se hace con el sector real de F2, no por moda.

## 1. Herramientas y versiones

| Herramienta | Versión de trabajo | Licencia | Uso | Estado |
|---|---|---|---|---|
| Godot | 4.7.2 stable | MIT | Motor, ensamblaje, navegación, audio, UI | Verificado |
| Terrain3D | 1.1.0 stable | MIT | Terreno, texturas, LOD, vegetación | **Instalado para F1.1; adopción provisional** |
| Cyclops Level Builder | 1.5.2 | MIT | Blockout de niveles, pircas, plazas, escaleras | **Instalado para F1.2; adopción provisional** |
| Blender | 5.3.0 | GPL (herramienta) | Arquitectura, props, personajes, exportación GLB | Verificado |

> **Regla de licencias:** las herramientas MIT/GPL no contaminan los assets del juego. Cada modelo, textura, audio y addon se registra con autor, origen, licencia y fecha en el `LICENSE.md` correspondiente. No se usan assets de pago.

## 2. Advertencias verificadas

### 2.1. Terrain3D

- La versión 1.1.0 soporta Godot 4.5–4.8+; encaja con 4.7.2.
- **No incluye streaming de regiones**; está previsto para 1.2. El plan no puede depender de esa función.
- El shader por defecto es complejo; para la GPU integrada se evalúa el shader `lightweight` o uno propio.
- La colisión y el navmesh sobre el terreno deben medirse; no se asumen gratuitos.
- El fondo lejano puede ser cielo, malla de montañas o *world background*; la opción más cara no es la mejor.

### 2.1.1. Resultado del spike

La escena de prueba de 512 × 512 m, con 4 regiones de 256 m, 50 árboles y 20 NPC de relleno, midió **113–115 FPS de media** en perfil Medio, 68 draw calls y 97 MB de VRAM en la UHD 770. La colisión se validó con un rayo vertical. La malla simple de referencia quedó en 300 FPS (tope de la medición), 13 draw calls y 87,8 MB. El registro de la instalación y la licencia está en `addons/terrain_3d/REGISTRO.md`.

**Decisión provisional:** adoptar Terrain3D para el blockout de F2. No es adopción definitiva: faltan texturas, vegetación densa, edificios, el sector real y la medición con el equipo descargado. El navmesh ya se hornea sobre el relieve (ver §3.5). Si el sector real baja de 60 FPS Medio, se activa el respaldo de malla.

### 2.2. Cyclops Level Builder

- Es un plugin de editor. La versión 1.5.0+ está pensada para Godot 4.7+.
- Los bloques tienen colisión, pero para la escena final se convierten a malla y colisión propias.
- El addon puede registrar un autoload; hay que verificar que no se necesita en runtime y que la exportación funciona sin él.
- Su valor es el blockout rápido, no la geometría final.

**Resultado del spike:** `cyclops_probe` construye un `ConvexBlockData` cúbico, lo asigna a un `CyclopsBlock` y comprueba que genera una malla con una superficie y una forma de colisión. La conversión es viable. El addon deja un aviso de objetos sin liberar al salir en Godot 4.7.2; se vigila en F2. El plugin no se habilita por defecto para no registrar su autoload en el juego. El addon se excluye de la exportación con `addons/cyclops_level_builder/*` en ambos presets: el blockout se convierte a malla y colisión propias antes de la escena final.

### 2.3. Blender

- Los scripts de generación viven en `campaigns/<campaña>/assets/blender/` o `tools/`.
- Exportación GLB con metros, origen en la base, colisión nombrada y colores por vértice.
- Los modelos finales se validan con `tests/asset_validation.gd` y `test_model_validator`.

## 3. Pipeline

```text
Expediente histórico y geográfico
        ↓
Mapa conceptual y clasificación
        ↓
Heightmap (DEM + esculpido + declaración de escala)
        ↓
Terrain3D: relieve, texturas, LOD, colisión
        ↓
Cyclops: blockout de pircas, plazas, escaleras, volúmenes
        ↓
Blender: arquitectura, props, personajes, GLB
        ↓
Godot: ensamblaje, materiales, colisiones, navegación, luz, audio
        ↓
Sectores, streaming, LOD, MultiMesh, auditoría
        ↓
Validación histórica, visual, de rendimiento y de guardado
```

### 3.1. Geografía

1. Reunir fuentes históricas y cartográficas.
2. Delimitar el territorio y su escala de juego.
3. Clasificar cada elemento: documentado, aproximado o ficción.
4. Dibujar el mapa conceptual: sectores, rutas, hidrografía, asentamientos, POI.
5. Definir las experiencias de exploración antes de modelar.
6. Aprobar el dossier antes de tocar el terreno.

### 3.2. Terreno

**Blockout de sector (F2.4–F2.6).** S3 y S1 comparten `BlockoutKit` (cajas, cilindros, cintas y etiquetas con colisión simple) y se cargan con el streamer. S3 usa `LlactaBlockout`: plaza, casas, manantial, acequia y POI. S1 aporta Coricancha, ayllus, mercado, talleres y depósitos; S4–S6, quebrada, paso y frontera con sus POI y límites naturales. Las capturas de revisión son ortográficas y ocultan las etiquetas para leer la planta.

**Modo de revisión (F2.8).** La escena regional arranca con cámara cercana y etiquetas ocultas; `H` muestra la más cercana y `T` alterna la vista cenital. Es una herramienta de blockout, no una cámara de juego.

**Mundo caminable (F2.9).** `region_world` instancia `player_fps.tscn` en el camino de entrada a la llacta y deja que la colisión dinámica de Terrain3D sostenga al jugador. El objetivo del streaming sigue al jugador, así que los sectores cargan a su alrededor. Las capturas y mediciones que necesitan la cámara de revisión instancian la escena con `first_person = false`. La prueba humana de 20–30 min, con rutas y registro de incidencias, está en [prueba_blockout.md](../campaigns/01_pachacutec/documentation/mundo/prueba_blockout.md).

**Entorno de revisión.** La escena regional no usa el arte final: añade cielo físico, ambiente neutro, sol con sombras, relleno frío, bruma suave y dos texturas planas de pradera/roca para el autoshader de Terrain3D. Las casas apoyan el cimiento en su esquina más baja y la plaza es una malla que sigue el terreno; un disco plano a la altura del centro flotaba sobre la ladera y el jugador pasaba por debajo. El objetivo es que el blockout se pueda mirar; no sustituye la iluminación ni los materiales de F3.

**Geometría apoyada.** `tools/blockout_float_audit.gd` recorre los seis sectores y las cintas, clasifica cada malla por `blockout_kind` y falla si la cara inferior de un volumen se separa más de 0,30 m del terreno. Los discos (plaza, nieve, bofedal, poza), las cintas y las terrazas usan muestreo por borde o por huella; `add_box` extiende las cajas hacia abajo hasta el terreno, salvo techos, toldos, vigas y casas con cimiento. Techos, toldos, copas, vigas y casas no se eximen por nombre: se comprueba que exista una malla de apoyo debajo, con solape en XZ y a menos de 0,35 m. El refugio de S5 tenía el techo 0,5 m sobre las pircas; ahora las pircas suben a 1,8 m y el techo se apoya en su remate. El Coricancha se apoya en la cota más alta de su huella, no en la del centro, para que la ladera no lo entierre. La auditoría corre en CI. La prueba humana se explica sin brújula: plaza como centro, cuesta abajo al Cusco y cuesta arriba a quebrada, paso y frontera, con `H` y `T` como ayuda.

**Recorrido regional (F2.8).** `region_walkthrough_check` recorre el navmesh Cusco → frontera con el streamer y el descubrimiento activos; valida continuidad, carga de los seis sectores, POI y guardado. La prueba humana de 20–30 min es la que cierra F2.

**POI y descubrimiento (F2.7).** Cada POI es un recurso `PoiDefinition` con posición, radio, disparador y rango de fase; `DiscoveryService` los descubre y alimenta diario y mapa sin conocer IDs concretos.

**Rutas y navmesh (F2.3).** Las rutas viven en `CampaignRoute` y se dibujan como cintas de blockout; el navmesh se hornea por sector con `TerrainNavmesh` y se une con `NavigationLink3D` en los cruces. Los enlaces se crean cuando el mapa ya sincronizó las regiones. Cada borde de la cinta se muestrea con `get_surface_height` (la superficie interpolada, no el dato de la heightmap), con paso de 1,5 m; `route_network_check` comprueba que ningún vértice flote más de 0,30 m.

**Sectores transmitidos (F2.2).** `region_world.tscn` mantiene el terreno regional y transmite seis escenas de sector con `SectorStreamer`; cada escena lleva su transformación mundial y su marcador de blockout. No hay pantallas de carga exteriores: el terreno no se descarga.

**Blockout regional (F2).** `campaigns/01_pachacutec/scripts/world/region_terrain.gd` genera un Terrain3D de 1024 con paso de 4 m para los 3,5 × 2,5 km de la región. El perfil es GN/GR: valle este-oeste, río, quebrada, paso y cumbres. Se genera en memoria al cargar (~1,5 s en la referencia) y se sustituirá o pregenerará cuando el expediente geográfico tenga DEM. Los sectores tendrán terreno local de 1 m en F2.2.

1. Base DEM recortada (SRTM/Copernicus 30 m u otra fuente citada).
2. Esculpido manual para valles, quebradas, pasos y terrazas.
3. Declarar exageración vertical, compresión de distancias y elementos ficticios.
4. Importar a Terrain3D; fijar regiones, vertex spacing, texturas y LOD.
5. Medir colisión, draw calls, VRAM y FPS antes de añadir props.

### 3.3. Blockout

1. Construir a escala 1:1 con referencia humana de 1,70 m.
2. Marcar caminos, plazas, pircas, escaleras, puertas y volúmenes.
3. Recorrer a pie; corregir pendientes, cuellos de botella y líneas de visión.
4. Convertir los bloques a malla/colisión para la escena final.
5. Aprobar el blockout antes del arte definitivo.

### 3.4. Arte

1. Kits modulares por cultura y época.
2. GLB optimizados, con LOD y colisión.
3. Materiales compartidos; evitar duplicados.
4. Vegetación con MultiMesh o instancer, LOD y distancia de visibilidad.
5. Props interactuables separados del decorado.

### 3.5. Ensamblaje en Godot

1. Escena de sector con raíz, terreno, geometría estática, navegación y anclas.
2. `SectorStreamer` carga/descarga sectores por distancia.
3. Interiores en escenas aditivas con retorno a puerta.
4. `NavigationRegion3D` por sector; enlaces para puertas y desniveles.
5. Luces, ambiente y audio por sector; sin duplicar `WorldEnvironment`.
6. Pruebas de recorrido y de guardado.

**Navmesh sobre Terrain3D.** El addon no expone su malla ni su colisión como nodos de escena: la colisión es un `Terrain3DCollision` con RID propio. Por eso no sirve `NavigationRegion3D.bake_navigation_mesh()` sobre el terreno. `core/world/terrain_navmesh.gd` muestrea la altura, construye una rejilla de triángulos con la orientación de Recast y hornea de forma síncrona con `NavigationMeshSourceGeometryData3D`. `NavmeshProfile` declara paso, radio de agente y pendiente. Los muros y edificios del blockout se declaran como huellas en XZ y se recortan con `add_projected_obstruction`; los que tengan malla propia pueden añadirse al horneado. En el sector gris, 120 × 120 m de terreno con la pirca recortada dieron 128 polígonos y una ruta que sube el relieve hasta el campo.

**Blockout de presupuesto (F1.7).** `tests/grey_blockout.gd` levanta seis casas y dos pircas con Cyclops, una multitud de 120 cápsulas y 180 matas de ichu en dos `MultiMesh`. Las casas y pircas recortan el navmesh por huella. No es arte ni contenido de campaña: sirve para fijar el presupuesto de draw calls, VRAM y FPS antes del blockout real de F2.

```bash
godot --headless --path . --script res://tests/grey_sector_check.gd
```

## 4. Estructura de archivos propuesta

```text
campaigns/01_pachacutec/
├── data/
│   ├── npcs/
│   ├── quests/
│   ├── locations/
│   ├── items/
│   └── schedules/
├── scenes/
│   ├── world/
│   │   ├── region.tscn
│   │   ├── sector_cusco.tscn
│   │   ├── sector_llacta.tscn
│   │   └── ...
│   ├── interiors/
│   └── sequences/
├── assets/
│   ├── models/
│   ├── textures/
│   ├── audio/
│   ├── animations/
│   └── blender/
└── documentation/
    └── mundo/
```

Los directorios se crean solo con su primer archivo funcional.

## 5. Validación

| Nivel | Qué se comprueba |
|---|---|
| Importación | Recursos, addons, scripts, cero errores/advertencias de `res://` |
| Geografía | Escala, rutas, sector, POI y clasificación |
| Recorrido | Se cruza el sector y la región sin bloqueos |
| Navegación | Rutas de NPC entre anclas y puertas |
| Rendimiento | Draw calls, primitivas, VRAM, FPS, carga y hitch |
| Persistencia | Guardar/cargar conserva el estado del sector |
| Histórico | Fichas, fuentes y anacronismos declarados |
| Visual | Capturas fijas antes/después y revisión de escala/paleta |

## 6. Riesgos y respaldos

| Riesgo | Respaldo |
|---|---|
| Terrain3D no rinde en UHD 770 | Terreno por malla + LOD propio; el diseño no depende del addon |
| Terrain3D no funciona en CI o exportación | Vendorizar binarios o usar el respaldo; decisión en F1 |
| Cyclops rompe la exportación | Usarlo solo como blockout y convertir antes de la escena final |
| Navmesh inestable en terreno | Waypoints de ancla + movimiento local |
| Streaming con tirones | Pre-carga de sector adyacente, carga por prioridad, reducción de props |
| Fondo lejano caro | Cielo + malla de montañas + niebla; evitar *world background* ruidoso |

## 7. Criterio de adopción

Un addon se adopta solo si:

1. Funciona en Godot 4.7.2 en Linux y Windows.
2. Importa y exporta en CI.
3. Cumple el presupuesto de rendimiento en la GPU de referencia.
4. Tiene licencia compatible y mantenimiento verificable.
5. Se puede retirar sin rehacer el contenido.
6. La decisión queda en la bitácora con medidas y alternativas.
