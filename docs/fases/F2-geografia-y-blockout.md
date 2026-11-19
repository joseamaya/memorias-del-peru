# F2 · Geografía y blockout — tareas

**Estado:** en curso · **Apertura:** 2026-11-19.
**Precondiciones:** F1 cerrada; expediente geográfico aprobado para blockout.
**Objetivo:** construir el territorio de la campaña 01 en gris, con escala real, rutas, sectores y lugares, antes de producir arte definitivo.
**Criterio de fase:** el de [docs/05](../05_plan_de_implementacion.md) §Fase 2.

## 1. Tareas

| # | Tarea | Estado | Criterio de paso | Evidencia |
|---|---|---|---|---|
| 2.1 | Heightmap regional | **Base implementada** | 3,5 × 2,5 km con valle, río, quebrada, paso y cumbres; alturas por sector | `region_terrain_check`, captura aérea |
| 2.2 | Sectores y streaming | **Base implementada** | Seis sectores con función y presupuesto; carga sin pantallas | `region_streaming_check`; 6 escenas, 3 cargadas en la llacta |
| 2.3 | Rutas | **Base implementada** | R1–R8 conectan los sectores; navmesh por sector | `route_network_check`; 8 rutas, 6 navmeshes y rutas continuas |
| 2.4 | S3 Llacta de Rumi | **Base implementada** | 12–18 casas, plaza, manantial, telar, corral y acequia en blockout | `llacta_blockout_check`; 17 casas, 9 POI, 120 draw calls |
| 2.5 | S1 Cusco preimperial | Pendiente | Plaza, recinto, ayllus, mercado y talleres en blockout | Captura y presupuesto |
| 2.6 | S4–S6 | Pendiente | Quebrada, paso y frontera con POI y límites naturales | Captura y presupuesto |
| 2.7 | POI y descubrimiento | Pendiente | 30 POI con ID, función, clasificación y disparador | `DiscoveryRegistry` |
| 2.8 | Recorrido completo | Pendiente | 20–30 min a pie sin bloqueos ni pantallas exteriores | Prueba humana y capturas |

## 2. F2.1 — Heightmap regional

**Escena:** `campaigns/01_pachacutec/scenes/world/region.tscn`.
**Escala:** 3,5 km E–O × 2,5 km N–S; una región de Terrain3D de 1024 con paso de 4 m cubre el bloqueo con margen.
**Clasificación:** GN/GR. El relieve es una propuesta de blockout basada en el [mapa conceptual](../../campaigns/01_pachacutec/documentation/mundo/mapa_conceptual.md), no una reconstrucción topográfica. Se sustituirá o ajustará con DEM cuando el expediente geográfico pase de hipótesis a aprobado.

**Perfil de alturas:**

| Zona | Altura objetivo | Sector |
|---|---|---|
| Cusco preimperial | 3.380–3.500 m | S1 |
| Llacta de Rumi | 3.500–3.700 m | S3 |
| Quebrada alta | 3.800–4.050 m | S4 |
| Paso | 4.000–4.300 m | S5 |
| Frontera chanca | 3.900–4.250 m | S6 |
| Cumbres visuales | 4.500–4.800 m | Fondo |

**Elementos del relieve:**

- Valle principal este-oeste con el fondo subiendo hacia el oeste.
- Río serpenteante con canal excavado y vega.
- Quebrada alta al noroeste y paso en el extremo occidental.
- Puna y bofedal al oeste; cumbres al norte y al sur.
- Ruido suave para romper la planitud; sin simulación geológica.

**Comprobación:** `region_terrain_check` valida la región, las alturas de los seis centros de sector, el rango de alturas y que el río queda por debajo de la vega. Salida: `REGION_OK sectors=6`; alturas comprobadas: S1 3.392 m, S3 3.619 m y S5 4.090 m.

**Medición:** heightmap de 1024 × 1024 con paso de 4 m; 16 regiones internas de Terrain3D; generación en memoria de ~1,5 s en la máquina de referencia (carga 55–65). No es una ruta de carga de sector: si el blockout se abre en partida, el heightmap se pregenerará o guardará. La captura aérea queda en `build/evidencia/region_overview.png`.

**Pendiente:**

- DEM real o ajuste aprobado por el responsable.
- Terreno local de 1 m por sector; la malla regional es de 4 m y el detalle llega en F3.
- Texturas, materiales y vegetación.
- Rutas y POI sobre el relieve.

**Comandos:**

```bash
godot --headless --path . --script res://tests/region_terrain_check.gd
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_region.tscn
```

## 2.2. F2.2 — Sectores y streaming

**Mundo:** `campaigns/01_pachacutec/scenes/world/region_world.tscn`. El terreno regional queda cargado; los sectores aportan props, edificios y NPC sin cambiar de escena ni mostrar pantallas de carga.

| Sector | Centro (x, z) | Celda | Clasificación | Presupuesto |
|---|---|---|---|---|
| S1 Cusco | (1200, 400) | (2, 0) | GD/GR | 350 draw calls |
| S2 Afueras | (750, 150) | (1, 0) | GR | 250 |
| S3 Llacta | (300, 0) | (0, 0) | GN | 300 |
| S4 Quebrada | (−700, 350) | (−2, 0) | GR/GN | 180 |
| S5 Paso | (−1300, 100) | (−3, 0) | GN/GR | 150 |
| S6 Frontera | (−1650, 0) | (−4, 0) | GN/GR | 220 |

**Streaming:** `SectorStreamer` con celdas de 512 m, radio de carga 2 y descarga 3. El objetivo se mueve sin cambiar de escena; el terreno y los sectores ya cargados no se recargan. Cada escena de sector lleva su transformación mundial y un marcador de blockout con nombre y clasificación.

**Comprobación:** `region_streaming_check` valida las seis definiciones, la carga de S3 al inicio, la de S1 al este, la de S6 al oeste, la descarga de S1/S3 al alejarse y que el terreno regional sigue cargado. Salida: `REGION_STREAMING_OK sectors=6 loaded=3 failures=0`.

**Pendiente:** contenido real de cada sector (F2.4–F2.6), rutas R1–R8 (F2.3), POI (F2.7) y recorrido de 20–30 min (F2.8). Los marcadores son blockout, no arte.

```bash
godot --headless --path . --script res://tests/region_streaming_check.gd
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_region_stream.tscn
```

La captura queda en `build/evidencia/region_streaming.png`.

## 2.3. F2.3 — Rutas y navmesh

**Datos:** ocho `CampaignRoute` en `campaigns/01_pachacutec/data/routes/` con ID, nombre, clasificación, ancho y puntos. Son trazados de blockout GN/GR; ningún camino se presenta como documentado.

| Ruta | Recorrido | Ancho |
|---|---|---|
| R1 Camino principal | Llacta → afueras → Cusco | 4,0 m |
| R2 Ruta del paso | Llacta → quebrada → paso → frontera | 3,0 m |
| R3 Ruta del río | Llacta → vado → acequia → Cusco | 2,5 m |
| R4 Sendero de pastores | Quebrada → cueva → mirador | 2,0 m |
| R5 Ruta oculta | Quebrada → tambo → frontera | 2,0 m |
| R6 Callejones del Cusco | Plaza → ayllus → talleres | 2,0 m |
| R7 Acequia madre | Manantial → terrazas → río | 1,5 m |
| R8 Camino de la frontera | Paso → campamento → puesto | 2,0 m |

**Dibujo:** una cinta de blockout de 3 m de muestreo por ruta, apoyada en el terreno y separada 0,8 m para no recortarse con la malla de 4 m.

**Navmesh:** seis regiones horneadas con `TerrainNavmesh` sobre los límites de cada sector (paso de 6 m), unidas con cinco `NavigationLink3D` en los cruces. Los enlaces se crean cuando el mapa sincronizó las regiones y sus extremos se proyectan al navmesh.

**Comprobación:** `route_network_check` valida 8 rutas, 8 cintas, 6 regiones, y rutas continuas llacta–Cusco (~1.039 m) y llacta–frontera (~2.190 m). Salida: `ROUTES_OK routes=8 regions=6`.

**Medición:** horneado completo de las seis regiones en ~3,4 s en la referencia con carga alta. Es coste de blockout; si se convierte en ruta de carga, se pregenerará o se reducirá el paso.

**Pendiente:** caminos con ancho y material definitivos, puentes, vados, cierres de fase, navmesh local de 1 m y el recorrido a pie de F2.8.

```bash
godot --headless --path . --script res://tests/route_network_check.gd
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_routes.tscn
```

La captura queda en `build/evidencia/routes.png`.

## 2.4. F2.4 — S3 Llacta de Rumi

**Escena:** `campaigns/01_pachacutec/scenes/world/sectors/s3_llacta.tscn`; se carga con el sector S3 sobre el terreno regional.

**Contenido de blockout:**

- Plaza circular de 18 m de radio y 17 casas: 12 en anillo exterior, 4 interiores y la casa de Rumi.
- Casa de Rumi, casa del curaca, telar, corral, manantial, acequia, huerto, horno de cerámica y fogón.
- Nueve etiquetas de POI: 01–08 y el huerto (POI-10).
- 20 cuerpos estáticos de colisión en casas, corral y plataformas.
- Los caminos R1, R2, R3 y R7 salen de la plaza; las casas se colocan fuera del anillo de 21 m para no bloquear las salidas.

**Comprobación:** `llacta_blockout_check` valida 17 casas, 9 POI, 69 mallas, 20 colisiones, la plaza despejada y rutas al manantial y a las afueras. Salida: `LLACTA_OK houses=17 pois=9`.

**Medición:** tres pasadas a 1920 × 1080, perfil Medio, vsync off, carga 18–30: **78,0/81,3/85,3 FPS** de media, p1 59,7–76,5, **120 draw calls** y **152 MB** de VRAM. Dentro del presupuesto de 300 draw calls y 250 MB.

**Pendiente:** interiores transitables, materiales definitivos, conversión a malla final, rutinas de NPC y POI con descubrimiento. La geometría es de blockout.

```bash
godot --headless --path . --script res://tests/llacta_blockout_check.gd
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_llacta.tscn
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_llacta_blockout.tscn
```

La captura queda en `build/evidencia/llacta_blockout.png`.

## 3. Orden de trabajo

1. **Hecho:** F2.1 base (heightmap regional de blockout).
2. **Hecho:** F2.2 base (seis sectores y streaming sin pantallas).
3. **Hecho:** F2.3 base (ocho rutas y navmesh por sector con enlaces).
4. **Hecho:** F2.4 base (blockout de S3 con 17 casas y nueve POI).
5. **Siguiente:** F2.5 Cusco preimperial y F2.6 S4–S6.
4. F2.7 POI y descubrimiento.
5. F2.8 recorrido completo y cierre.

## 4. Riesgos

| Riesgo | Mitigación |
|---|---|
| El relieve inventado se lee como reconstrucción | Clasificación GN/GR visible en la ficha y el diario |
| Terreno de 4 m demasiado tosco para caminar | Terreno local de 1 m por sector en F2.2/F3 |
| Seis sectores sin contenido | Cada uno se aprueba con función, POI y presupuesto antes de construir |
| El fondo visual promete contenido | Fondo no recorrible y declarado |
| Coste de generación al cargar | Medir; pregenerar y guardar el heightmap si supera el presupuesto |

## 5. Criterio de cierre

- [ ] La región se recorre de punta a punta sin pantallas de carga exteriores.
- [ ] Cada sector tiene función, contenido y presupuesto.
- [ ] La escala se lee: comunidad, campos, paso y Cusco se reconocen desde lejos.
- [ ] La clasificación geográfica está declarada.
- [ ] El blockout se aprueba antes de producir arquitectura definitiva.
