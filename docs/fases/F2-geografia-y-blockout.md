# F2 · Geografía y blockout — tareas

**Estado:** en curso · **Apertura:** 2026-11-19.
**Precondiciones:** F1 cerrada; expediente geográfico aprobado para blockout.
**Objetivo:** construir el territorio de la campaña 01 en gris, con escala real, rutas, sectores y lugares, antes de producir arte definitivo.
**Criterio de fase:** el de [docs/05](../05_plan_de_implementacion.md) §Fase 2.

## 1. Tareas

| # | Tarea | Estado | Criterio de paso | Evidencia |
|---|---|---|---|---|
| 2.1 | Heightmap regional | **Base implementada** | 3,5 × 2,5 km con valle, río, quebrada, paso y cumbres; alturas por sector | `region_terrain_check`, captura aérea |
| 2.2 | Sectores y streaming | Pendiente | Seis sectores con función y presupuesto; carga sin pantallas | `sector_streaming_check` ampliado |
| 2.3 | Rutas | Pendiente | R1–R8 conectan los sectores; navmesh por sector | Recorrido y `navigation_check` |
| 2.4 | S3 Llacta de Rumi | Pendiente | 12–18 casas, plaza, manantial, telar, corral y acequia en blockout | Captura y presupuesto |
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
- Terreno local de 1 m por sector; la malla regional es de 4 m.
- Texturas, materiales y vegetación.
- Rutas y POI sobre el relieve.

**Comandos:**

```bash
godot --headless --path . --script res://tests/region_terrain_check.gd
godot --path . --resolution 1280x720 \
    res://tests/scenes/capture_region.tscn
```

## 3. Orden de trabajo

1. **Hecho:** F2.1 base (heightmap regional de blockout).
2. **Siguiente:** F2.2 sectores y streaming.
3. F2.3 rutas; F2.4–F2.6 blockout de sectores.
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
