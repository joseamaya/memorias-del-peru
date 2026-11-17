# Personajes Quaternius — Universal Base Characters

## Qué se usa

- `base/Superhero_Male_FullBody.gltf` y `.bin`
- `base/Superhero_Female_FullBody.gltf` y `.bin`
- Texturas de piel, ojos y pelo de la carpeta `base/`
- `hair/Hair_SimpleParted.gltf`, `Hair_Long.gltf`, `Hair_Buns.gltf` y `Hair_Beard.gltf` con sus `.bin`
- Los clips de **UAL1** que ya viven en `shared_assets/characters/mannequin/ual1_standard.glb` (ver su `LICENSE.md`).

## Origen y licencia

- **Autor:** Quaternius
- **Pack:** Universal Base Characters, versión **Standard gratuita**
- **Origen:** https://quaternius.com/packs/universalbasecharacters.html
- **Descarga:** `Universal Base Characters[Standard].zip` (122 MB), descargado el 2026-11-16
- **Licencia:** [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
- **Uso:** cuerpo, cara, ojos, manos, pelo y barba de los personajes del prototipo. La ropa, trenzas, cintas, fajas, chuspas y sandalias son autoría propia, generadas por `campaigns/01_pachacutec/assets/blender/pch_quaternius.py`.

La versión **Source** de pago **no se ha usado**. El estándar gratuito solo incluye dos cuerpos (hombre y mujer “superhero”); los cuerpos regular/teen, los 20 peinados y los shaders de personalización quedan fuera. No se versionan los ZIP originales: solo los archivos usados.

## Transformaciones propias

- Texturas reducidas a 512 px (ojos a 256 px) para el presupuesto de memoria del juego.
- Referencias de textura corregidas: el glTF gratuito pedía `T_Hair_1_Normal_png.png` y `T_Eye_Normal_png.png`; los archivos reales son `T_Hair_1_Normal.png` y `T_Eye_Normal.png`.
- Materiales renombrados a `pch.body`, `pch.hair`, `pch.hair_grey` y `pch.eye` para que `SurfaceMaterials` los reconozca.
- Cuerpos girados 180° en el generador para que miren hacia −Z, como el resto del elenco.
- Sin animaciones dentro del GLB: `QuaterniusClips` añade los clips de UAL1 en el juego.

## Packs evaluados y no usados

- **Universal Animation Library 2 (Standard gratuito):** se verificó su compatibilidad de 65 huesos, pero el prototipo usa UAL1 para no duplicar una librería de 18 MB. Queda como fuente para una fase posterior.
- **Ultimate Animated Character Pack:** descartado. Es de 2019, no trae glTF ni un rig humanoid compartido y su estilo no encaja con la base UBC.

## Aviso

Los rostros de UBC son una base estilizada, **no retratos andinos**. La identidad histórica la aportan la ropa, el pelo, la paleta y los accesorios, documentados como reconstrucción (R) en PCH-017, PCH-018 y PCH-024. No se presentan como documentos ni como retratos de personas concretas.
