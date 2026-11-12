# Licencias de los modelos de la campaña 01

## Modelos de `pch_models.py`

Viviendas, objetos, vegetación, telar, cántaros y leña. Son de autoría propia del proyecto ([ADR-0010](../../../../docs/adr/0010-modelos-generados-con-blender.md)).

## Personajes (`pch_npc_*.glb`), de `pch_people.py`

Proceso descrito en [ADR-0016](../../../../docs/adr/0016-personajes-realistas-makehuman.md).

| Parte | Origen | Licencia | Añadido |
|---|---|---|---|
| Malla base y objetivos de boca, mallas *proxy* `male1591` y `female1605`, pieles (`young_/middleage_/old_asian_*`), ojos `low-poly` con material `brown`, cejas `eyebrow001`, pestañas `eyelashes01` y pelo `short02` y `long01` | MakeHuman system assets, `makehuman_system_assets_cc0.zip`: https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html. Cada archivo declara: «This asset was explicitly released as CC0 in september 2020». Copyright previo de Data Collection AB, Joel Palmius y Jonas Hauquier. | CC0 1.0 | 2026-11-12 |
| Esqueleto `cmu_mb` y sus pesos | MPFB2 2.0.18, datos del complemento (https://extensions.blender.org/add-ons/mpfb/). El código del complemento es GPL v3 y no se distribuye; sus recursos son CC0. | CC0 1.0 | 2026-11-12 |
| Movimientos: reposo (82_08, «stand still»), paseo (07_01), carrera (09_01), gestos (18_08), cavar (79_04) y coser (79_05) | CMU Graphics Lab Motion Capture Database, http://mocap.cs.cmu.edu/. Su portada dice: «This dataset of motions is free for all uses». Se usan los ASF/AMC originales. | Uso libre; se acredita la fuente | 2026-11-12 |
| Ropa, tocados, ojotas, chuspa, bulto y chaquitaclla | Autoría propia, generada por `pch_people.py`. | Propia | 2026-11-12 |

### Transformaciones aplicadas

- Pieles y pelo de MakeHuman teñidos hacia un color medio y reducidos a 1024 px; se exportan en WebP.
- Iris oscurecido a castaño y blanco del ojo aclarado, porque el iris marrón original es rojizo.
- Boca cerrada con objetivos de MakeHuman.
- Captura con la columna en parte enderezada, cuello y cabeza estabilizados, cara nivelada y dedos relajados.
- La postura arrodillada de la tejedora se calcula a partir del esqueleto; sobre ella van los brazos de la toma de coser.
- Los movimientos se trasladan al esqueleto alineando cada hueso, se recortan en ciclos cerrados y se hornean a 30 fps.

Los recursos originales de MakeHuman y de CMU no se versionan: se descargan para regenerar (ver la cabecera de `pch_people.py`).
