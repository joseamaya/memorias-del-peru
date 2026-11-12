# ADR-0014 — Texturas de detalle triplanares

- Estado: Aceptado
- Fecha: 2026-11-11
- Matiza: [ADR-0010](0010-modelos-generados-con-blender.md) (la consecuencia «colores planos por material, sin texturas»)

## Contexto

La primera persona del piloto dijo que el juego «no se siente muy realista». Las capturas lo explican:

- Todo era color plano: los modelos por vértice y el terreno, la plaza y los caminos con un solo color. La plaza y los caminos eran losas de bordes rectos.
- El alcance (§6.2) pedía texturas de 1K–2K y materiales en `shared_assets/materials/`, pero no se habían hecho.
- No había corrección de tono (*tonemap* lineal), y los colores del mundo se trataban como lineales mientras los de los modelos estaban en sRGB. Por eso los muros de las terrazas salían casi blancos junto a las casas.

El responsable del proyecto aprobó el 2026-11-11 empezar por la luz y las texturas, y autorizó las descargas.

## Opciones consideradas

1. Pintar texturas por modelo en Blender, con su UV. Rechazada: 20 modelos generados por script tendrían que desplegar UV y hornear texturas, y el generador dejaría de ser sencillo.
2. Un material por tipo de superficie en cada modelo. Rechazada: un modelo tiene varias superficies en una sola malla (ADR-0010), y separarlas multiplicaría las draw calls.
3. Proyección triplanar con una capa por clase de superficie. Aceptada.

## Decisión

- **Texturas:** 9 texturas CC0 de Poly Haven, de 1K (piedra, barro, paja, madera, tejido, hierba, tierra, roca y suelo de cultivo), unidas en dos `Texture2DArray`: detalle y normales (`shared_assets/textures/`, con su [LICENSE.md](../../shared_assets/textures/LICENSE.md)).
- **El detalle es relativo:** cada textura se divide por su color medio. El color final sigue siendo el de la paleta (color por vértice o tinte), y la textura solo añade variación, rugosidad y relieve. La paleta de las fichas no cambia.
- **Un solo shader** triplanar (`shared_assets/materials/superficie_triplanar.gdshader`):
  - Los modelos eligen la capa por la **clase de superficie** que el generador de Blender escribe en `UV.x` de cada cara (`SURFACE_CLASS`). Siguen siendo una malla con un material.
  - El terreno mezcla hierba, roca en las pendientes y en lo alto, y tierra en la plaza y los caminos con borde irregular. Las losas de la plaza y los caminos se conservan ocultas como referencia de esas zonas.
  - Los planos de la proyección sin peso no se leen. Las normales no se leen a más de 35 m. El filtrado es trilineal: el anisotrópico costaba unos 4 FPS en la GPU integrada.
- **Color:** las constantes de color del mundo pasan a sRGB, como la paleta de los modelos. Se ajustan los tonos del pasto (seco, de puna), la roca y la tierra.
- **Luz:** *tonemap* AgX con un leve ajuste de contraste (1,08) y saturación (1,12).
- El código del juego está en `campaigns/01_pachacutec/scripts/world/surface_materials.gd`. `core/` no cambia.

## Consecuencias

- El alcance pasa a v3.6 (§6.2).
- **Rendimiento** (docs/08, medición del 2026-11-11):
  - El perfil Bajo baja de unos 217 a unos 150 FPS: el objetivo vinculante de 30 FPS se sigue cumpliendo con margen.
  - El perfil Medio baja de unos 77 a unos 54 FPS en la GPU integrada. Los 60 FPS recomendados se definen para una referencia con GPU dedicada, que aún no existe.
- El repositorio crece unos 14 MB (dos WebP).
- Para añadir una superficie hay que añadir una capa a las dos tiras, su escala en `SurfaceMaterials.LAYER_SCALES` y su clase en el generador.
- Pruebas: `test_surface_materials` comprueba los arrays, las clases de superficie de la casa, el material de todos los modelos y las cinco zonas de tierra del terreno.
