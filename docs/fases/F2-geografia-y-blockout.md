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
| 2.5 | S1 Cusco preimperial | **Base implementada** | Plaza, recinto, ayllus, mercado y talleres en blockout | `cusco_blockout_check`; 28 casas, 6 POI, 247 draw calls |
| 2.6 | S4–S6 | **Base implementada** | Quebrada, paso y frontera con POI y límites naturales | `frontier_sectors_check`; 5+3+5 POI y presupuestos |
| 2.7 | POI y descubrimiento | **Base implementada** | 30 POI con ID, función, clasificación y disparador | `poi_discovery_check`; 30 POI, diario, mapa y guardado |
| 2.8 | Recorrido completo | **Automatizado; falta prueba humana** | 20–30 min a pie sin bloqueos ni pantallas exteriores | `region_walkthrough_check`; 2.758 m y 23 min |

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

## 2.5. F2.5 — S1 Cusco preimperial

**Escena:** `campaigns/01_pachacutec/scenes/world/sectors/s1_cusco.tscn`; se carga al acercarse al sector S1.

**Contenido de blockout:**

- Plaza de 28 m de radio.
- **28 casas de ayllu** en cuadrícula con callejones, fuera del anillo de 42 m y de los corredores de R1/R3.
- Recinto del Coricancha sobre plataforma, con muros perimetrales y recinto interior.
- Mercado con seis puestos y toldos.
- Taller textil con dos casas y tres telares.
- Cuatro depósitos.
- Acequia urbana de 280 m.
- Seis etiquetas de POI: 17–22.

**Comprobación:** `cusco_blockout_check` valida 28 casas, 6 POI, 111 mallas, 43 colisiones y rutas a afueras y llacta. Salida: `CUSCO_OK houses=28 pois=6`.

**Medición:** tres pasadas a 1920 × 1080, perfil Medio, vsync off, carga 1,0–1,4: **76,4/79,2/82,3 FPS** de media, p1 60,0–65,8, **247 draw calls** y **128–137 MB** de VRAM. Dentro del presupuesto de 350 draw calls y 250 MB.

**Pendiente:** interiores, materiales definitivos, muralla y quebrada de límite, multitud de 30–40 NPC, mercado funcional y descubrimiento de POI.

```bash
godot --headless --path . --script res://tests/cusco_blockout_check.gd
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_cusco.tscn
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_cusco_blockout.tscn
```

La captura queda en `build/evidencia/cusco_blockout.png`.

## 2.6. F2.6 — S4 quebrada, S5 paso y S6 frontera

**Escenas:** `s4_quebrada.tscn`, `s5_paso.tscn` y `s6_frontera.tscn`; se cargan con el streamer al oeste de la llacta.

**S4 — Quebrada alta:**

- Cinco terrazas altas de papa.
- Ocho queñuas, salto de agua con poza, cueva, cantera y refugio de pastores.
- Cinco POI: terrazas (10), queñua (11), salto (13), cantera (14) y cueva (25).
- Baja densidad; el blockout pesa 146 draw calls y 127 MB.

**S5 — Paso:**

- Zigzag de 2,6 m de ancho, refugio de pirca con techo, mirador con parapeto, altar de altura y tres manchas de nieve.
- Tres POI: mirador (23), refugio (24) y altar (30).
- 103 draw calls y 127 MB.

**S6 — Frontera chanca:**

- Bofedal, tambo abandonado, seis marcas de piedra, campamento de cuatro tiendas con empalizada y fuegos, puesto de vigilancia y campo de batalla con enterramientos.
- Cinco POI: bofedal (12), tambo (26), marcas (27), campamento (28) y campo (29).
- 83 draw calls y 127 MB.

**Comprobación:** `frontier_sectors_check` valida POI, mallas, colisiones y rutas S4→llacta y S5→S6. Salida: `FRONTERA_OK s4=5 s5=3 s6=5`.

**Medición:** una pasada por sector a 1920 × 1080, perfil Medio, vsync off, carga 1,3–1,5:

| Sector | FPS medio | p1 | Draw calls | VRAM |
|---|---|---|---|---|
| S4 | 80,0 | 79,4 | 146 | 127,1 MB |
| S5 | 95,5 | 94,3 | 103 | 127,1 MB |
| S6 | 103,0 | 90,3 | 83 | 126,9 MB |

Los tres quedan por debajo de sus presupuestos (180, 150 y 220 draw calls) y de 250 MB.

**Pendiente:** clima y nieve estacional, refugios con interior, campamento funcional, facciones y combate, y el recorrido de F2.8.

```bash
godot --headless --path . --script res://tests/frontier_sectors_check.gd
godot --path . --disable-vsync --resolution 1920x1080 \
    res://tests/scenes/measure_west.tscn
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_west.tscn
```

Las capturas quedan en `build/evidencia/quebrada_blockout.png`, `paso_blockout.png` y `frontera_blockout.png`.

**Capturas del modo de revisión:** `region_review.png` (sin etiquetas) y `region_review_labels.png` (con la etiqueta más cercana). Se generan con `tests/scenes/capture_review.tscn`.

## 2.7. F2.7 — POI y descubrimiento

**Datos:** 30 `PoiDefinition` en `campaigns/01_pachacutec/data/pois/`, uno por POI del catálogo. Cada uno declara ID, nombre, descripción, sector, clasificación, posición, radio, disparador y rango de fase.

**Disparadores:**

- `START`: casa de Rumi y plaza de la llacta se conocen al empezar.
- `PROXIMITY`: el resto se descubre al acercarse.
- `DIALOGUE`: casa del curaca y casa de un ayllu, reservados para conversación.
- `EVENT`: campo de batalla, reservado para la guerra.

**Servicio:** `DiscoveryService` carga el catálogo, consulta `WorldState`, marca los descubrimientos y expone:

- `get_journal()`: entradas de diario solo de lo descubierto.
- `get_map_points()`: puntos de mapa solo de lo descubierto.
- `poi_discovered`: señal para UI, audio o misiones.

**Fases:** cada POI declara `phase_min` y `phase_max`. Casa de un ayllu y depósito del Cusco empiezan en la fase 1; campamento chanca vive entre 2 y 3; campo de batalla, entre 3 y 4.

**Comprobación:** `poi_discovery_check` valida 30 POI, dos de inicio, descubrimiento por proximidad en manantial, plaza del Cusco y mirador, bloqueo por fase del campamento, diario/mapa y persistencia en guardado. Salida: `POI_OK total=30 discovered=6 start=2`.

**Pendiente:** interfaz de diario y mapa, textos definitivos, sonido de descubrimiento y disparadores por diálogo/evento conectados a misiones.

```bash
godot --headless --path . --script res://tests/poi_discovery_check.gd
```

## 2.8. F2.8 — Recorrido completo

**Prueba:** `region_walkthrough_check` recorre el camino Cusco → frontera sobre el navmesh, en pasos de 20 m, con el streamer activo y el descubrimiento de POI encendido.

- **Longitud:** 2.758 m por el navmesh.
- **Tiempo estimado:** 23,0 min a 2 m/s.
- **Sectores vistos:** los seis; S1 se descarga al llegar a S6.
- **POI descubiertos:** 8 durante el recorrido.
- **Fallos de carga:** 0.
- **Pantallas de carga:** ninguna; el terreno regional sigue cargado y no hay cambio de escena.
- **Guardado:** los descubrimientos sobreviven al ciclo guardar/cargar al final.

La prueba avanza el objetivo por muestras del navmesh y espera la carga de cada celda; no simula 23 minutos reales. **Modo de revisión:** `region_world` arranca con una cámara cercana (38, 26, 48) y las etiquetas de POI ocultas. `H` muestra solo la etiqueta más cercana; `T` alterna vista cenital. La barra superior recuerda las teclas. Sirve para revisar el blockout sin que nueve etiquetas se solapen.

La **prueba humana de 20–30 min** sigue pendiente y es la que cierra F2.

```bash
godot --headless --path . --script res://tests/region_walkthrough_check.gd
```

## 3. Orden de trabajo

1. **Hecho:** F2.1 base (heightmap regional de blockout).
2. **Hecho:** F2.2 base (seis sectores y streaming sin pantallas).
3. **Hecho:** F2.3 base (ocho rutas y navmesh por sector con enlaces).
4. **Hecho:** F2.4 base (blockout de S3 con 17 casas y nueve POI).
5. **Hecho:** F2.5 base (blockout de S1 con 28 casas, Coricancha, mercado y talleres).
6. **Hecho:** F2.6 base (S4 quebrada, S5 paso y S6 frontera).
7. **Hecho:** F2.7 base (30 POI, descubrimiento, diario, mapa y persistencia).
8. **Hecho:** F2.8 automatizado (2.758 m, 23 min, seis sectores y ocho POI).
9. **Siguiente:** prueba humana de 20–30 min y aprobación del blockout para cerrar F2.
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

- [x] La región se recorre de punta a punta sin pantallas de carga exteriores (automatizado).
- [x] Cada sector tiene función, contenido y presupuesto medido.
- [x] La escala se lee: comunidad, campos, paso y Cusco se reconocen desde lejos en las capturas.
- [x] La clasificación geográfica está declarada.
- [ ] El blockout se aprueba antes de producir arquitectura definitiva: falta la prueba humana y el veredicto del responsable.
