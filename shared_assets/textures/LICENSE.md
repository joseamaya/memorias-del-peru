# Licencias de texturas

Toda textura de `shared_assets/textures/` se registra aquí con autor, origen, licencia y fecha de descarga. El proyecto exige licencia compatible con uso comercial y sin addons ([AGENTS.md](../../AGENTS.md) §3).

Las dos imágenes del juego son tiras verticales de 9 capas de 1024 × 1024 que Godot importa como `Texture2DArray` ([ADR-0014](../../docs/adr/0014-texturas-de-detalle-triplanares.md)):

- `superficies_detalle.webp`: color de detalle **relativo a su media** (en lineal, × 0,5) en RGB y rugosidad en alfa. El color final lo pone la paleta del juego; la textura solo aporta la variación.
- `superficies_normal.webp`: normales en convención OpenGL.

| Capa | Uso en el juego | Textura | Autor | Origen | Licencia | Añadido |
|---|---|---|---|---|---|---|
| 0 Piedra | Muros de casas y terrazas, rampas | Rock Surface | Amal Kumar | https://polyhaven.com/a/rock_surface | CC0 1.0 | 2026-11-11 |
| 1 Barro | Barro de las juntas y enlucidos | Clay Plaster | Amal Kumar | https://polyhaven.com/a/clay_plaster | CC0 1.0 | 2026-11-11 |
| 2 Paja | Techos de ichu | Thatch Roof Angled | Rob Tuytel, Dimitrios Savva | https://polyhaven.com/a/thatch_roof_angled | CC0 1.0 | 2026-11-11 |
| 3 Madera | Postes, telar, leña, corteza de queñua | Rough Wood | Rob Tuytel | https://polyhaven.com/a/rough_wood | CC0 1.0 | 2026-11-11 |
| 4 Tejido | Ropa de lana y cuerdas | Hessian 230 | colormass, Rico Cilliers | https://polyhaven.com/a/hessian_230 | CC0 1.0 | 2026-11-11 |
| 5 Hierba | Pasto seco del terreno | Grass Ground | Charlotte Baglioni | https://polyhaven.com/a/grass_ground | CC0 1.0 | 2026-11-11 |
| 6 Tierra | Plaza y caminos | Brown Mud Dry | Rob Tuytel | https://polyhaven.com/a/brown_mud_dry | CC0 1.0 | 2026-11-11 |
| 7 Roca | Laderas, cresta y juntas de piedra seca | Rock Face 03 | Dario Barresi, Rico Cilliers | https://polyhaven.com/a/rock_face_03 | CC0 1.0 | 2026-11-11 |
| 8 Suelo de cultivo | Tierra con surcos de las terrazas | Farm Soil | Amal Kumar | https://polyhaven.com/a/farm_soil | CC0 1.0 | 2026-11-11 |

Los originales (mapas *Diffuse*, *nor_gl* y *Rough* a 1K, JPG) se descargaron de la API pública de Poly Haven el 2026-11-11, con permiso del responsable del proyecto, y **no se versionan**. Se procesaron con Python (Pillow y NumPy):

1. Paso a lineal del mapa de color, división por su color medio y × 0,5, recortado a [0, 1].
2. Rugosidad en el canal alfa.
3. Unión de las 9 capas en una tira y guardado en WebP con calidad 92 (alfa 95), para que el repositorio no cargue 47 MB de PNG.

## Criterios

- Se prefieren obras propias, CC0 o de dominio público. Poly Haven publica todo su catálogo en CC0.
- Las texturas son genéricas (piedra, barro, paja, madera, tejido, suelos). No representan objetos históricos concretos ni sustituyen a la paleta, que sigue las fichas del registro histórico.
- Cada archivo importado por Godot conserva su `.import` versionado.
