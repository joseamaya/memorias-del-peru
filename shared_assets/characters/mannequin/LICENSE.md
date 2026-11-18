# Maniquí UAL1 — Universal Animation Library

- **Archivo:** `ual1_standard.glb`
- **Origen:** [Universal Animation Library · Standard](https://quaternius.itch.io/universal-animation-library), paquete `Universal Animation Library[Standard].zip`, carpeta `Unreal-Godot/UAL1_Standard.glb`
- **Autor:** Quaternius
- **Licencia:** [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)
- **Fecha de incorporación:** 2026-11-13
- **Uso:** maniquí de prototipo para los personajes del juego. 43 animaciones sin root motion: locomoción, conversación, trabajo de rodillas, ataque, golpe y muerte.
- **Nota:** el `ual1_bone_map.tres` es propio, generado con el `SkeletonProfileHumanoid` de Godot para retargeting futuro.

Queda como base del prototipo de maniquíes. Desde 2026-11-16, `QuaterniusClips`
usa sus clips para los cuerpos UBC (`pch_npc_*_q.glb`); el elenco por defecto
sigue siendo UBC hasta aprobar el prototipo de maniquíes. Se conserva también
como figura de fondo o prototipo rápido.

## Mano extraída

- **Archivo:** `mannequin_hand_open.glb`
- **Origen:** derivado de `ual1_standard.glb` (Quaternius, CC0): mano y antebrazo
  derechos, con sus dos superficies.
- **Script:** `tools/blender_mannequin_hand.py` (autoría propia, reproducible).
- **Fecha:** 2026-11-18.
- **Uso:** prototipo de mano en primera persona; sin falanges articuladas.

## Código de atuendo

`CharacterLook`, `LookPart`, `CharacterOutfit` y `OutfitMannequin` son código
propio adaptado del proyecto de referencia del mismo autor
(`/home/jamaya/Projects/el-despertar-del-sol`). No son assets externos; se
versionan en `core/characters/`.
