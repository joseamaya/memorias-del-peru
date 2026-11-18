# Maniquí UAL1 — Universal Animation Library

- **Archivo:** `ual1_standard.glb`
- **Origen:** [Universal Animation Library · Standard](https://quaternius.itch.io/universal-animation-library), paquete `Universal Animation Library[Standard].zip`, carpeta `Unreal-Godot/UAL1_Standard.glb`
- **Autor:** Quaternius
- **Licencia:** [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)
- **Fecha de incorporación:** 2026-11-13
- **Uso:** maniquí de prototipo para los personajes del juego. 43 animaciones sin root motion: locomoción, conversación, trabajo de rodillas, ataque, golpe y muerte.
- **Nota:** el `ual1_bone_map.tres` es propio, generado con el `SkeletonProfileHumanoid` de Godot para retargeting futuro.

Queda como base del elenco activo de maniquíes. Desde 2026-11-18, el juego usa
los diez looks de `MannequinLooks` sobre este cuerpo; `QuaterniusClips` añade
los clips lógicos de UAL1/UAL2. El antiguo elenco UBC se retiró de las
escenas.

## Antebrazo extraído

- **Archivo:** `mannequin_forearm.glb`
- **Origen:** derivado de `ual1_standard.glb` (Quaternius, CC0): antebrazo
  derecho con sus dos superficies (piel y juntas).
- **Script:** `tools/blender_mannequin_forearm.py` (autoría propia, reproducible).
- **Fecha:** 2026-11-18.
- **Uso:** antebrazo de la mano en primera persona. La palma, los cuatro dedos y
  el pulgar son piezas primitivas construidas en
  `core/player/mannequin_hand.gd`; no son assets externos.

## Código de atuendo

`CharacterLook`, `LookPart`, `CharacterOutfit` y `OutfitMannequin` son código
propio adaptado del proyecto de referencia del mismo autor
(`/home/jamaya/Projects/el-despertar-del-sol`). No son assets externos; se
versionan en `core/characters/`.
