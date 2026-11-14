# Licencias de las animaciones de la campaña 01

## Clips de combate (`pch_npc_combat.glb`), de `pch_combat.py`

Golpe con porra (`attack`, 1,25 s) y reacción al golpe (`hit`, 0,75 s) para los
personajes MakeHuman/Rocketbox. El GLB trae **solo la armadura y las dos
acciones**, sin mallas: los personajes ya las tienen y `CharacterModelVisual`
copia los clips a su `AnimationPlayer`.

| Parte | Origen | Licencia | Añadido |
|---|---|---|---|
| Armadura `Human.rig` (37 huesos) | La del personaje `pch_npc_commoner.glb`, generada por `pch_people.py` (MPFB2 + Rocketbox) | CC0 1.0 / MIT, ver `../models/LICENSE.md` | 2026-11-14 |
| Poses de `attack` y `hit` | Autoría propia, generadas por `pch_combat.py` con utilidades de puntería en espacio de armadura | Propia | 2026-11-14 |

Regeneración:

```bash
blender --background --factory-startup --python assets/blender/pch_combat.py
blender --background --factory-startup --python assets/blender/pch_combat.py -- --preview
```

`--preview` renderiza las poses en `/tmp/opencode/combat_preview` sin exportar.
Las rutas de pista (`Human_rig/Skeleton3D:Hueso`) coinciden con las del
personaje porque el clip se exporta desde su misma armadura; si se cambiara el
nombre de la armadura, habría que renombrarla antes de exportar.
