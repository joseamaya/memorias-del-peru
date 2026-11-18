# Personajes Quaternius — elenco único

**Estado:** elenco único · 2026-11-17 · Fase 4.12.
**Manda:** [docs/09](../../../docs/09_biblia_narrativa.md) en lo narrativo,
[docs/07](../../../docs/07_convenciones_historicas.md) en lo histórico y la
[guía visual](guia_visual.md) en lo visual.

## 1. Qué es

Todo el elenco de la campaña usa el set **Quaternius** de Universal Base
Characters (UBC, CC0). No hay set anterior, ni bandera de selección, ni modo
híbrido: una partida normal carga los diez GLB Q. Los papeles que no tienen un
modelo propio reutilizan un arquetipo; el catálogo está en
`CharacterCatalog` y los clips en `QuaterniusClips`.

| Papel | Modelo Q | Nota |
|---|---|---|
| Tejedora | Anca Q | Clip `weave`; el telar sigue en la escena |
| Agricultor | Joven Q | Clip `work`; chaquitaclla `pch_prop_chaquitaclla.glb` plantada en la terraza |
| Curaca / CuracaVecino | Curaca Q | Autoridad, t’oqapu y manto |
| Principal2 / `principal` | Puma Q | Autoridad comunal, sin t’oqapu |
| Habitante1 / Habitante2 / Habitante3 | Madre / Hermano / Sisa Q | Familia de Rumi |
| Anca | Anca Q | Anacu, lliclla y tupu |
| Mensajero / `messenger` | Mensajero Q | Ropa de viaje y chuspa |
| HijoPuma | Joven Q | Escalado a 1,20 m; sin base infantil gratuita en UBC Standard (Regular/Teen es Source de pago) |
| Herido1 / Herido2 | Hermano / Madre Q | Clip `tired` |
| Comitiva1 / 2 / 3 | Madre / Hermano / Joven Q | Actos IV–V |
| `curaca`, `farmer`, `weaver`, `villager` del Cusco y el Paso | Curaca / Joven / Anca / arquetipos Q | La multitud rota entre los diez Q |

El cuerpo, la ropa, la cara, el pelo y los clips son los mismos que ya estaban
probados en el prototipo. La diferencia es que ahora **no queda nada del
elenco MakeHuman/Rocketbox** en el juego: se borraron sus GLB, sus capturas y
la documentación del híbrido.

## 2. Assets y licencias

- **Cuerpo, cara, ojos, manos y peinados:** Universal Base Characters
  (Standard gratuito), Quaternius, CC0 1.0.
- **Texturas de rostro:** derivadas de las albedo 2048 de UBC (CC0) con
  `tools/build_face_textures.py`. Tono, labios, ojeras, líneas de edad y grano
  por personaje; reconstrucción (R), no retratos.
- **Clips:** UAL1 y UAL2, Quaternius, CC0 1.0.
- **Ropa, trenzas, cintas, faja, chuspa, tupu y sandalias:** autoría propia,
  generadas por `pch_quaternius.py`.
- **Chaquitaclla del Agricultor:** prop de madera generado por `pch_models.py`
  (`pch_prop_chaquitaclla.glb`), autoría propia; sin metal. Ficha PCH-037.
- **Base infantil:** el Standard gratuito solo incluye los cuerpos «superhero»
  (hombre y mujer); Regular/Teen son de la versión Source de pago. No hay base
  infantil gratuita; HijoPuma usa el Joven Q a 1,20 m (decisión cerrada).
- **No usado:** la versión Source de pago de UBC y el Ultimate Animated
  Character Pack.
- El detalle está en
  [shared_assets/characters/quaternius/LICENSE.md](../../../shared_assets/characters/quaternius/LICENSE.md).

## 3. Rig y rendimiento

- **76 huesos**: los 65 de UBC/UAL1/UAL2, 6 de manto (`Cape_L/C/R_1/2`),
  1 de mandíbula (`Jaw`) y 4 de expresión (`Blink_L/R`, `Brow_L/R`). El manto
  se mueve con `SpringBoneSimulator3D`; `CharacterFace` anima la mandíbula al
  hablar, parpadea y alza las cejas. `QuaterniusClips` combina UAL1
  (`idle`, `walk`, `run`, `talk`, `attack`, `death`) con 11 clips de UAL2;
  `idle_b`, `work` y `hit` vienen de UAL2.
- Los GLB salen **sin animaciones**; `QuaterniusClips` copia los clips una vez
  y los añade al `AnimationPlayer` de cada personaje.
- **19,5 k triángulos** por personaje; 5–7 mallas; **GLB de 1,4–2,1 MB**.
- Los GLB **embeben el atlas textil de la ropa** (768×1024 por personaje); las
  texturas de cuerpo, cara, pelo y ojos se cargan una vez desde
  `QuaterniusMaterials`.
- **LOD de multitud:** las figuras del Cusco ocultan el tupu por material
  (`crowd` en `CharacterModelVisual`); conservan cuerpo, ropa, pelo, ojos y
  cejas. Las cejas se conservan porque sin ellas la cara parece vacía y su
  coste es mínimo una vez que no proyectan sombra.
- **Política de sombras:** solo cuerpo y ropa proyectan sombra. Ojos, cejas,
  tupu y pelo no: cada superficie suma un draw call por split del sol y no
  aporta a la silueta. La sombra del cuerpo sigue apoyando las figuras.
- **Manto:** tres cadenas de dos huesos con muelles, cápsulas en pelvis y
  cintura. La multitud no simula muelles para no gastar CPU.
- **Mano en primera persona:** malla propia con falanges articuladas; los dedos
  se cierran al beber o golpear y se abren al ofrecer o soplar. La honda y la
  porra se sostienen con un puño de bloqueo con manga, para que no floten en la
  esquina de la cámara; la mano articulada queda para las interacciones.
- **Mandíbula de habla:** el hueso `Jaw` mueve el labio inferior, el mentón y
  la barba mientras suena `talk`. Es animación de habla, no fonemas ni
  sincronía labial completa.
- **Parpadeo y cejas:** `Blink_L/R` baja el párpado superior y `Brow_L/R` alza
  la ceja de su lado. `CharacterFace` parpadea cada 2,8–6,2 s (con doble
  parpadeo ocasional) y mantiene las cejas alzadas mientras habla. La multitud
  también parpadea.
- **HijoPuma** es el joven Q a 1,20 m: se lee como un adulto pequeño, no como
  un niño. Se revisó el pack UBC Standard: solo trae los dos cuerpos
  «superhero» (hombre y mujer); las proporciones Regular/Teen son de la versión
  Source de pago, que no se usa. No hay base infantil gratuita compatible con
  el rig Q, y mezclar otro set rompería la decisión de elenco único. **Decisión
  cerrada:** se mantiene el escalado.

### Medición del elenco completo

Medición con el set Q completo, sin bandera. Tres pasadas por acto con carga
1,1–1,6; se publica la mediana:

| Acto | Draw calls | Memoria de vídeo | FPS medio | p1 |
|---|---|---|---|---|
| I — Llacta | 220 | 222,8 MB | 95,4 | 73,8 |
| II — Paso | 258 | 162,9 MB | 119,7 | 110,0 |
| III — Cusco | 297 | 230,9 MB | 69,4 | 60,0 |
| IV — Posguerra | 218 | 223,3 MB | 107,4 | 97,6 |
| V — Obra | 243 | 218,0 MB | 101,7 | 98,3 |

Los cinco actos cumplen el presupuesto de **≤ 350 draw calls**. Son tres pasadas
por acto con carga 1,1–1,6 y se publica la mediana. La chaquitaclla del
Agricultor añade 1 draw call; el puño que sostiene el arma suma unos 9 en
primera persona y deja la llacta en 220, el paso en 258, el Cusco en 297, la posguerra en 218 y la obra en 243. El
desglose del Cusco mostró que la multitud pesaba 173 draw calls y el pase de
sombra 266; el LOD por material y la política de sombras los dejan en torno a
100 y 140. El Cusco es el acto más ajustado (69,4 FPS de media, p1 60,0); en una
pasada aislada la media bajó a 53,8 y el p1 a 40,7, así que se vigila. No se
vuelve al elenco anterior: la decisión es Q único.

## 4. Dirección artística

La identidad viene de la ropa, el pelo, la paleta y la silueta:

| Grupo | Prendas | Paleta | Pelo/tocado |
|---|---|---|---|
| Comunidad, hombre | Unku, manto, chuspa, ojotas | Lana marrón/crema, franjas oscuras | Corto, cinta o paño |
| Comunidad, mujer | Anacu, lliclla con tupu, faja, ojotas | Marrón/gris, rojo y ocre | Largo, trenzas, cinta |
| Autoridad | Unku crema, franja de t’oqapu, manto teñido, cinta | Crema, rojo, azul, ocre | Canas, barba, cinta |
| Chanca | Unku oscuro, manto, porra | Marrón/gris + teal `#296B85` | Recogido, cinta |

- **Documentado (A/R):** unku, anacu, lliclla, manto, chuspa, ojotas, tupu,
  cintas, honda, porra y escudo; sin metal. PCH-017, PCH-018 y PCH-024.
- **Reconstrucción (R):** corte, colores, combinaciones, peinados, caras,
  proporciones y la franja de t’oqapu.
- **Ficción (N):** los personajes concretos y la patrulla chanca.
- **Los rostros UBC no son retratos andinos.** Son una base estilizada; la
  lectura histórica la construyen las capas. No hay más intentos de cara
  realista: la cara Quaternius es la definitiva.

## 5. Capturas

| Personaje | Captura |
|---|---|
| Llacta completa | ![Llacta](img/personajes/llacta_q.png) |
| Agricultor y chaquitaclla | ![Agricultor](img/personajes/agricultor_q.png) |
| Sisa | ![Sisa](img/personajes/sisa_q.png) |
| Sisa de cerca | ![Sisa de cerca](img/personajes/sisa_close_q.png) |
| Rostro de Sisa | ![Rostro](img/personajes/rostro_q.png) |
| Curaca | ![Curaca](img/personajes/curaca_q.png) |
| Curaca de cerca | ![Curaca de cerca](img/personajes/curaca_close_q.png) |
| Curaca parpadeando | ![Curaca parpadeando](img/personajes/curaca_blink_q.png) |
| Curaca con las cejas alzadas | ![Curaca con las cejas alzadas](img/personajes/curaca_brows_q.png) |
| Arma en primera persona | ![Arma en primera persona](img/personajes/arma_q.png) |
| Honda en primera persona | ![Honda en primera persona](img/personajes/honda_q.png) |
| Mensajero | ![Mensajero](img/personajes/mensajero_q.png) |
| Chanca | ![Chanca](img/personajes/chanca_q.png) |
| Mujer mayor | ![Mujer mayor](img/personajes/anciana_q.png) |
| Mujer mayor de cerca | ![Mujer mayor de cerca](img/personajes/anciana_close_q.png) |
| Hombre joven | ![Hombre joven](img/personajes/joven_q.png) |
| Hombre joven de cerca | ![Hombre joven de cerca](img/personajes/joven_close_q.png) |
| Multitud del Cusco | ![Multitud](img/personajes/crowd_anciana_q.png) |
| Madre | ![Madre](img/personajes/madre_q.png) |
| Madre de cerca | ![Madre de cerca](img/personajes/madre_close_q.png) |
| Hermano | ![Hermano](img/personajes/hermano_q.png) |
| Hermano de cerca | ![Hermano de cerca](img/personajes/hermano_close_q.png) |
| Puma | ![Puma](img/personajes/puma_q.png) |
| Puma de cerca | ![Puma de cerca](img/personajes/puma_close_q.png) |
| Anca | ![Anca](img/personajes/anca_q.png) |
| Anca de cerca | ![Anca de cerca](img/personajes/anca_close_q.png) |
| Mano en primera persona | ![Mano](img/personajes/mano_q.png) |

Generación:

```bash
godot --path . --resolution 1280x720 res://tests/scenes/capture_quaternius.tscn
```

Escribe `user://quaternius_*.png`.

## 6. Qué funciona y qué falta

**Funciona:** los diez modelos Q cubren todos los papeles; altura, orientación,
idle, caminar, correr, hablar, trabajo, tejido, combate del chanca, impacto,
muerte, porra en `hand_r`, foco de diálogo, mirada de cabeza, colisión, multitud
Q, política de sombras, manto con muelles, mano articulada, mandíbula de
habla, chaquitaclla del Agricultor, arena y arco completo.

**Falta:**

- **FPS del Cusco:** 69,4 de media y p1 60,0 con carga 1,1–1,6; en una pasada
  aislada la media bajó a 53,8 y el p1 a 40,7. Se vigila al añadir arte final.
- La cara UBC sigue siendo estilizada. Es la cara definitiva del set; si se
  quiere realismo, es una tarea de escultura/arte, no de código.
- **HijoPuma** es un adulto Q escalado: no hay base infantil gratuita en
  UBC Standard (Regular/Teen es Source de pago). Decisión cerrada; no se
  mezclará otro set.
- **Tejedora** reutiliza Anca Q con el clip `weave`; el Agricultor reutiliza
  Joven Q, ahora con la chaquitaclla plantada en la terraza.
- Heridos y comitiva reutilizan arquetipos; no tienen ropa propia.
- El pelo, la barba y las cejas siguen siendo mallas UBC; a distancia se leen
  bien, de cerca son geométricas.
- **Expresiones finas:** la mandíbula, los párpados y las cejas se animan,
  pero no hay fonemas ni sincronía labial; la cara sigue siendo una textura
  sobre la malla UBC. Una sincronía labial completa requiere shape keys o una
  malla facial nueva.
- **Mano del arma:** es un puño de bloqueo, no la mano articulada; no hay IK ni
  agarre individual de dedos. A distancia de juego se lee, de cerca es
  geométrico.
- Validación humana: movimiento, diálogo, combate y lectura a distancia con el
  elenco completo.

## 7. Pruebas

```bash
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tests/combat_arena_check.gd
godot --headless --path . --script res://tests/arc_playthrough.gd
python3 tools/check_gdscript_limits.py
```

Resultados: **140 pruebas, 0 fallos**; arena (`resolved=3`, `max_attackers=1`)
y `ARCO_OK` con el set Q; importación sin errores ni advertencias de `res://`.
Las pruebas recorren los diez modelos, las diez texturas de cara y el catálogo
de todos los papeles.

Las pruebas del elenco son `test_quaternius_characters.gd` (altura, base,
ausencia de colisión, 76 huesos —65 UBC + 6 de manto + 1 mandíbula + 4 de
expresión—, `Head`/`hand_r`, materiales y clips, incluidos `idle_b`, `work` y
`hit` de UAL2; texturas de cara de 1024, piel con rugosidad, cejas propias,
catálogo de todos los papeles, política de sombras, LOD de multitud, muelles
del manto, mandíbula de habla, parpadeo, cejas y altura de HijoPuma),
`test_first_person_hands.gd` (malla, falanges articuladas y gesto de
interacción) y `test_chaquitaclla.gd` (carga, validador, 1,48 m de alto y
estribo de 22 cm).

## 8. Decisión

Quaternius es el **único** set visual. Se retiraron los modelos
MakeHuman/Rocketbox, el híbrido Rocketbox, el injerto de cabeza MakeHuman y sus
pruebas/capturas. No se vuelve atrás. El rendimiento del Cusco está cerrado
(288 draw calls, cinco actos bajo 350 y la chaquitaclla del Agricultor en la
terraza); HijoPuma queda cerrado con el escalado a 1,20 m. Las cejas y el
parpadeo están cerrados; el siguiente trabajo es la sincronía labial por
fonemas (requiere malla facial nueva) y la validación humana.
