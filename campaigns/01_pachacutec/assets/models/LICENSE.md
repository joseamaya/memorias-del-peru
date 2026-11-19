# Licencias de los modelos de la campaña 01

## Modelos de `pch_models.py`

Viviendas, objetos, vegetación, telar, cántaros, leña y la chaquitaclla del
Agricultor. Son de autoría propia del proyecto
(ADR-0010, histórico; registro en la [bitácora](../../../../docs/bitacora.md)).

Las viviendas D y E (`pch_house_d.glb`, `pch_house_e.glb`) se añadieron el
2026-11-15 con el mismo generador y la misma licencia propia. D es una casa
mayor enlucida y E una casa menor de piedra; no introducen una tipología nueva,
solo variación de planta, altura y acabado.

La chaquitaclla (`pch_prop_chaquitaclla.glb`) se añadió el 2026-11-18 con el
mismo generador y licencia propia. Es un prop de madera con punta endurecida y
sin metal; su forma y fuentes están en la ficha PCH-037 del
[registro histórico](../../documentation/registro_historico.md).

## Elenco Quaternius (`pch_npc_*_q.glb`)

Los diez modelos Q son el **único elenco del juego**: cuerpo, ropa, esqueleto y
clips de Universal Base Characters/UAL. Se generan con
`../blender/pch_quaternius.py`.

| Parte | Origen | Licencia | Añadido |
|---|---|---|---|
| Cuerpo, cara, ojos, manos y peinados | Universal Base Characters (Standard gratuito), Quaternius, https://quaternius.com/packs/universalbasecharacters.html | CC0 1.0 | 2026-11-16 |
| Texturas de cara por personaje | Derivadas de UBC por `tools/build_face_textures.py`; tono, labios y líneas de edad son reconstrucción (R) | CC0 1.0 (base) + propia | 2026-11-17 |
| Ropa, trenzas, cintas, faja, chuspa, tupu y sandalias | Autoría propia, generada por `pch_quaternius.py` | Propia | 2026-11-16 |
| Clips de locomoción, conversación, trabajo y combate | UAL1 y UAL2, `shared_assets/characters/mannequin/ual1_standard.glb` y `shared_assets/characters/quaternius/animations/UAL2_Prototype.glb` | CC0 1.0 | 2026-11-17 |

Los GLB **incluyen el atlas textil de la ropa** (768×1024 por personaje), que
da las franjas, rombos y cenefas. Las texturas de cuerpo, cara, pelo y ojos no
se embeben: `QuaterniusMaterials` las carga desde
`shared_assets/characters/quaternius/base/` y `faces/`, y las comparte.
El detalle de la procedencia, las texturas reducidas y los packs descartados
está en `shared_assets/characters/quaternius/LICENSE.md`. La versión Source de
pago no se usó.

## Librería de telas (`pch_people.py`, `pch_dressed.py`)

El pipeline de personajes MakeHuman/Rocketbox está **retirado**: no quedan GLB
de ese elenco en el juego. `pch_people.py` y `pch_dressed.py` se conservan
únicamente como librería de clases de malla y tejido que usa
`pch_quaternius.py` (`Garment`, `BodyInfo`, el lienzo textil y utilidades). No
generan personajes del juego.

| Parte | Origen | Licencia | Añadido |
|---|---|---|---|
| Clases de malla, `BodyInfo`, `Garment`, lienzo textil y paleta | Autoría propia del proyecto | Propia | 2026-11-14 |
| Utilidades de malla, material de tela y `paint_textile` | Autoría propia del proyecto | Propia | 2026-11-14 |

Los antiguos recursos de MakeHuman, CMU y Rocketbox **no se versionan ni se
usan**. Las cabezas, cuerpos y animaciones del elenco anterior se borraron.
