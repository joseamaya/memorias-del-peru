# Licencias de los modelos de la campaña 01

## Modelos de `pch_models.py`

Viviendas, objetos, vegetación, telar, cántaros y leña. Son de autoría propia del proyecto ([ADR-0010](../../../../docs/adr/0010-modelos-generados-con-blender.md)).

Las viviendas D y E (`pch_house_d.glb`, `pch_house_e.glb`) se añadieron el
2026-11-15 con el mismo generador y la misma licencia propia. D es una casa
mayor enlucida y E una casa menor de piedra; no introducen una tipología nueva,
solo variación de planta, altura y acabado.

## Tejedora vestida (`pch_weaver_dressed.glb`), de `pch_dressed.py`

Prototipo de personaje completo sobre el maniquí UAL1 (ADR-0042).

| Parte | Origen | Licencia | Añadido |
|---|---|---|---|
| Cuerpo, esqueleto de 65 huesos y animaciones | UAL1 de Quaternius, `shared_assets/characters/mannequin/ual1_standard.glb` | CC0 1.0 | 2026-11-14 |
| Cabeza, pelo, ojos, ropa, sandalias y materiales | Autoría propia, generados por `pch_dressed.py` | Propia | 2026-11-14 |

El GLB contiene tres mallas (cuerpo, ropa y cabeza) con el mismo esqueleto y
nueve animaciones recortadas del UAL1. La ropa usa el material `pch_cloth`, que
el juego sustituye por su shader de tejido; el color va por vértice.

## Personajes (`pch_npc_*.glb`), de `pch_people.py`

Estos modelos se usan en la campaña: la llacta, el campamento y
los chancas del acto II, los NPC con nombre y los defensores del acto III y la
multitud del Cusco. UAL1 queda como respaldo, fuera de escena.

Proceso descrito en [ADR-0016](../../../../docs/adr/0016-personajes-realistas-makehuman.md).

| Parte | Origen | Licencia | Añadido |
|---|---|---|---|
| Malla base y objetivos de boca, mallas *proxy* `male1591` y `female1605`, pieles (`young_/middleage_/old_asian_*`), ojos `low-poly` con material `brown`, cejas `eyebrow001`, pestañas `eyelashes01` y pelo `short02` y `long01` | MakeHuman system assets, `makehuman_system_assets_cc0.zip`: https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html. Cada archivo declara: «This asset was explicitly released as CC0 in september 2020». Copyright previo de Data Collection AB, Joel Palmius y Jonas Hauquier. | CC0 1.0 | 2026-11-12 |
| Esqueleto `cmu_mb` y sus pesos | MPFB2 2.0.18, datos del complemento (https://extensions.blender.org/add-ons/mpfb/). El código del complemento es GPL v3 y no se distribuye; sus recursos son CC0. | CC0 1.0 | 2026-11-12 |
| Movimientos: reposo (82_08, «stand still», y 77_02, «standing»), paseo (07_01), carrera (09_01), gestos (18_08), cavar (79_04) y coser (79_05) | CMU Graphics Lab Motion Capture Database, http://mocap.cs.cmu.edu/. Su portada dice: «This dataset of motions is free for all uses». Se usan los ASF/AMC originales. | Uso libre; se acredita la fuente | 2026-11-12 |
| Cabezas y pelo de `Male_Adult_09`, `Male_Adult_10`, `Business_Male_02`, `Business_Male_06`, `Medical_Female_01`, `Female_Adult_11`, `Sports_Female_02` y `Business_Female_01` (ADR-0017) | Microsoft Rocketbox Avatar Library, https://github.com/microsoft/Microsoft-Rocketbox. «MIT License — Copyright (c) 2020 Microsoft». | MIT | 2026-11-12 |
| Ropa, tocados, ojotas, chuspa, bulto y chaquitaclla | Autoría propia, generada por `pch_people.py`. | Propia | 2026-11-12 |

### Transformaciones aplicadas

- Pieles y pelo de MakeHuman teñidos hacia un color medio y reducidos a 1024 px; se exportan en WebP.
- Iris oscurecido a castaño y blanco del ojo aclarado, porque el iris marrón original es rojizo.
- Boca cerrada con objetivos de MakeHuman.
- Captura con la columna en parte enderezada, cuello y cabeza estabilizados, cara nivelada y dedos relajados.
- La postura arrodillada de la tejedora se calcula a partir del esqueleto; sobre ella van los brazos de la toma de coser.
- Los movimientos se trasladan al esqueleto alineando cada hueso, se recortan en ciclos cerrados y se hornean a 30 fps.
- **Pesos de la ropa al torso** (2026-11-14): la prenda venía pesada a los brazos
  y se estiraba como una vela al levantar el brazo. `pch_cloth_weights.py` mueve
  los pesos de brazos y hombros a `Spine1` y reexporta con los mismos ajustes;
  conserva animaciones, esqueleto, UV y materiales.

### Aviso de licencia de Rocketbox (MIT)

> Copyright (c) 2020 Microsoft
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Los recursos originales de MakeHuman, de CMU y de Rocketbox no se versionan: se descargan para regenerar (ver la cabecera de `pch_people.py`).

## Prototipo Quaternius (`pch_npc_*_q.glb`)

Los modelos `pch_npc_mensajero_q.glb`, `pch_npc_sisa_q.glb`,
`pch_npc_curaca_q.glb`, `pch_npc_chanca_q.glb`, `pch_npc_anciana_q.glb`,
`pch_npc_joven_q.glb`, `pch_npc_madre_q.glb`, `pch_npc_hermano_q.glb`,
`pch_npc_puma_q.glb` y `pch_npc_anca_q.glb` son el prototipo de la renovación
visual. Los dos primeros del segundo grupo son arquetipos de multitud; el resto
es la familia de la llacta. Se generan con `../blender/pch_quaternius.py`.

| Parte | Origen | Licencia | Añadido |
|---|---|---|---|
| Cuerpo, cara, ojos, manos y peinados | Universal Base Characters (Standard gratuito), Quaternius, https://quaternius.com/packs/universalbasecharacters.html | CC0 1.0 | 2026-11-16 |
| Texturas de cara por personaje | Derivadas de UBC por `tools/build_face_textures.py`; tono, labios y líneas de edad son reconstrucción (R) | CC0 1.0 (base) + propia | 2026-11-17 |
| Ropa, trenzas, cintas, faja, chuspa, tupu y sandalias | Autoría propia, generada por `pch_quaternius.py` | Propia | 2026-11-16 |
| Clips de locomoción, conversación y combate | UAL1 y UAL2, `shared_assets/characters/mannequin/ual1_standard.glb` y `shared_assets/characters/quaternius/animations/UAL2_Prototype.glb` | CC0 1.0 | 2026-11-17 |

Los GLB no incluyen las texturas: `QuaterniusMaterials` carga desde
`shared_assets/characters/quaternius/base/` y `faces/`, y las comparte entre
personajes.
El detalle de la procedencia, las texturas reducidas y los packs descartados
está en `shared_assets/characters/quaternius/LICENSE.md`. La versión Source de
pago no se usó.
