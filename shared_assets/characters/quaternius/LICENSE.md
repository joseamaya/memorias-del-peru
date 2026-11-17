# Personajes Quaternius — Universal Base Characters

## Qué se usa

- `base/Superhero_Male_FullBody.gltf` y `.bin`
- `base/Superhero_Female_FullBody.gltf` y `.bin`
- Texturas de piel, ojos y pelo de la carpeta `base/`
- `faces/source/T_Superhero_Male_Dark.png` y `faces/source/T_Superhero_Female_Dark_BaseColor.png`: albedo 2048 original de UBC, conservada para reproducir las caras
- `faces/pch_face_*.png`: diez albedo de 1024 (Mensajero, Sisa, Curaca, Chanca, mujer mayor, hombre joven, madre, hermano, Puma y Anca), derivadas con `tools/build_face_textures.py`
- `faces/T_Superhero_*_Normal.png` y `faces/T_Superhero_*_Roughness.png`: normal y rugosidad a 1024, reducidas del original
- `hair/Hair_SimpleParted.gltf`, `Hair_Long.gltf`, `Hair_Buns.gltf` y `Hair_Beard.gltf` con sus `.bin`
- Los clips de **UAL1** que ya viven en `shared_assets/characters/mannequin/ual1_standard.glb` (ver su `LICENSE.md`).
- `animations/UAL2_Prototype.glb`: 11 clips de **Universal Animation Library 2 (Standard gratuito)**, Quaternius, CC0. Se extraen con `pch_ual2_library.py`; no se versiona el paquete completo de 18 MB.

## UAL2 Standard

- **Autor:** Quaternius
- **Pack:** Universal Animation Library 2, versión **Standard gratuita**
- **Origen:** https://quaternius.com/packs/universalanimationlibrary2.html
- **Descarga:** `Universal Animation Library 2[Standard].zip`, 18 MB, descargado el 2026-11-17
- **Licencia:** CC0 1.0
- **Clips conservados:** `Idle_No_Loop`, `Farm_PlantSeed`, `Farm_Harvest`, `TreeChopping_Loop`, `Hit_Knockback`, `Melee_Hook`, `Melee_Hook_Rec`, `Walk_Carry_Loop`, `Sword_Block`, `Yes`, `Chest_Open`.
- **Uso:** `idle_b`, `work` y `hit` del prototipo. La versión Source de pago no se usa.

## Origen y licencia

- **Autor:** Quaternius
- **Pack:** Universal Base Characters, versión **Standard gratuita**
- **Origen:** https://quaternius.com/packs/universalbasecharacters.html
- **Descarga:** `Universal Base Characters[Standard].zip` (122 MB), descargado el 2026-11-16
- **Licencia:** [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
- **Uso:** cuerpo, cara, ojos, manos, pelo y barba de los diez personajes del prototipo (cuatro papeles, dos arquetipos de multitud y la familia de la llacta). La ropa, trenzas, cintas, fajas, chuspas y sandalias son autoría propia, generadas por `campaigns/01_pachacutec/assets/blender/pch_quaternius.py`.

La versión **Source** de pago **no se ha usado**. El estándar gratuito solo incluye dos cuerpos (hombre y mujer “superhero”); los cuerpos regular/teen, los 20 peinados y los shaders de personalización quedan fuera. No se versionan los ZIP originales: solo los archivos usados.

## Transformaciones propias

- Albedo de piel reducida a 512 px en `base/` (ojos a 256 px) para el presupuesto de memoria del juego.
- Caras nuevas: la albedo 2048 de UBC se pinta por personaje en el espacio UV de la cabeza (tono, labios, ojeras, líneas de edad y grano) y se guarda a 1024 px. El normal y la rugosidad bajan a 1024 px. Las texturas se importan con compresión VRAM y mipmaps.
- Referencias de textura corregidas: el glTF gratuito pedía `T_Hair_1_Normal_png.png` y `T_Eye_Normal_png.png`; los archivos reales son `T_Hair_1_Normal.png` y `T_Eye_Normal.png`.
- Materiales de cuerpo por personaje (`pch.body_sisa`, `pch.body_curaca`, `pch.body_mensajero` y `pch.body_chanca`), cejas propias (`pch.brow_*`), pelo (`pch.hair_*`), ojos (`pch.eye`) y ropa (`pch_cloth`). `QuaterniusMaterials` los reconoce.
- Cuerpos girados 180° en el generador para que miren hacia −Z, como el resto del elenco.
- Sin animaciones dentro del GLB: `QuaterniusClips` añade los clips de UAL1/UAL2 en el juego.

## Packs evaluados y no usados

- **Ultimate Animated Character Pack:** descartado. Es de 2019, no trae glTF ni un rig humanoid compartido y su estilo no encaja con la base UBC.

## Aviso

Los rostros de UBC son una base estilizada, **no retratos andinos**. Las texturas de cara por personaje son reconstrucción (R): no hay retratos, tonos de piel ni rasgos documentados para estos personajes concretos. La identidad histórica la aportan la ropa, el pelo, la paleta y los accesorios, documentados como reconstrucción (R) en PCH-017, PCH-018 y PCH-024. No se presentan como documentos ni como retratos de personas concretas.
