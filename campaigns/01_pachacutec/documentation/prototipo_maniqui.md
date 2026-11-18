# Prototipo de maniquíes UAL1 y panel de objetivo

> Estado: **maniquíes y mano aprobados**. El prototipo fija el aspecto de los
> personajes y de la mano en primera persona. El elenco UBC sigue activo hasta
> extender los maniquíes a los diez roles.

## 1. Qué se ha probado

- **Tres maniquíes** con el mismo cuerpo UAL1 de Quaternius y tres looks:
  - **Curaca:** unku crema, faja y manto rojos, llauto y orejeras.
  - **Sisa:** anacu pardo con ruedo rojo, lliclla, faja, cinta y tupu.
  - **Chanca:** túnica teal, faldón oscuro, faja y cinta.
- **Mano del jugador** de maniquí: antebrazo extraído del UAL1 y palma, cuatro
  dedos separados y pulgar primitivos, con los colores de piel y juntas. Tiene
  pose abierta para interactuar y puño cerrado para la honda y la porra; ambas
  se hornean en dos mallas (piel y juntas) para no multiplicar draw calls.
- **Panel de objetivo** arriba a la izquierda, con fondo oscuro y texto cálido,
  integrado en el HUD actual.

Capturas:

| Prototipo | Imagen |
|---|---|
| Tres maniquíes | ![Maniquíes](img/prototipo/maniquis.png) |
| Mano abierta en la llacta | ![Mano abierta](img/prototipo/mano.png) |
| Puño con la honda | ![Mano con la honda](img/prototipo/mano_honda.png) |
| Puño con la porra | ![Mano con la porra](img/prototipo/mano_porra.png) |
| Panel de objetivo en la llacta | ![Objetivo](img/prototipo/objetivo.png) |

## 2. Cómo se ejecuta

```bash
godot --path . res://tests/scenes/mannequin_prototype.tscn
godot --path . res://tests/scenes/mannequin_hand_prototype.tscn
```

La primera guarda `user://mannequin_prototype.png`; la segunda,
`user://mano_abierta.png` y `user://mano_agarre.png`. El antebrazo se regenera
con:

```bash
blender --background --factory-startup --python tools/blender_mannequin_forearm.py
```

## 3. Qué se aprende del proyecto de referencia

`/home/jamaya/Projects/el-despertar-del-sol` usa un solo maniquí UAL1 para todos
los personajes y separa el aspecto en datos:

- `CharacterLook`: color de piel, color de juntas y lista de piezas.
- `LookPart`: caja, cilindro, anillo o disco; hueso, tamaño, offset, giro y color.
- `CharacterOutfit`: aplica las dos superficies del cuerpo y cuelga las piezas
  de huesos con `BoneAttachment3D`.

No hay caras, texturas de piel ni ropa esculpida. La identidad sale de la
silueta, los colores y cuatro o cinco piezas. Es un estilo de maniquí legible y
barato, y elimina los problemas de rostro y tela del elenco UBC.

De la interfaz se adopta el **panel de objetivo contextual**: arriba a la
izquierda, fondo oscuro, texto cálido y legible, con contadores cuando haga
falta. La referencia lo muestra al cambiar de objetivo y durante el combate, y
oculta el resto del HUD fuera de combate. Nuestro prototipo mantiene el panel
visible mientras la tarea está activa y conserva el diario para el detalle.

Otras ideas que merece la pena conservar:

- Pasos de misión como datos (`SliceStep`): objetivo, tipo, marcador, bandera,
  aviso y checkpoint.
- Checkpoint al empezar cada paso.
- HUD mínimo: barras solo cuando hacen falta y objetivo contextual.
- Códex con etiquetas (Documentado / Según los cronistas / Licencia del juego).
- Pruebas separadas de personaje, atuendo y HUD.

## 4. Qué falta para extenderlo

1. **Aprobar el estilo** con las tres capturas.
2. Crear los looks de los diez papeles (unku, anacu, lliclla, llauto, orejeras,
   tupu, chasqui, colores de facción).
3. Integrar el maniquí en `NpcActor`/`CharacterModelVisual` y retirar los UBC,
   caras, texturas, mandíbula, parpadeo, cejas y manto con muelles.
4. Multitud: maniquí liso sin piezas o con muy pocas, para no disparar draw calls.
5. ~~Mano del jugador: integrarla en `FirstPersonHands` y en el arma.~~
   **Hecho:** mano abierta y puño de agarre, con el antebrazo UAL1.
6. Panel de objetivo: aprobado tal como está. Sin temporizador ni rediseño por
   ahora; el diario conserva el detalle.
7. Pruebas de los diez looks, capturas, rendimiento y documentación final.

## 5. Decisiones y riesgos

- **Se usa el UAL1 Standard de Quaternius** (CC0), el mismo que ya estaba en
  `shared_assets/characters/mannequin/`. En el proyecto de referencia figura
  como recurso de prototipo; usarlo como estilo final es una decisión
  consciente de este proyecto.
- **La mano se posa al construirla**: el UAL1 trae los dedos fusionados en la
  malla y posar sus huesos no los separa. Por eso se conserva su antebrazo y la
  mano se monta con piezas primitivas; la pose abierta o de agarre se hornea al
  fusionar las piezas en dos mallas. No hay falanges animadas en tiempo real. Es
  la adaptación propia de un recurso pensado para tercera persona.
- **La mano se fusiona en dos mallas** (piel y juntas): pasa de ~30 draw calls a
  2 por mano y mantiene el aspecto.
- **Las piezas son primitivas**: a distancia se leen; de cerca son geométricas.
  Es el precio de un estilo consistente y barato.
- **El panel de objetivo** ya está en el HUD real, pero sin temporizador; el
  comportamiento transitorio de la referencia queda para la extensión.
- **Licencia y procedencia**: UAL1 es CC0; el antebrazo es una derivación del
  mismo GLB y las piezas de la mano son código propio; los scripts
  `CharacterLook`, `LookPart` y `CharacterOutfit` están adaptados del proyecto de
  referencia del mismo autor. Se registra en
  `shared_assets/characters/mannequin/LICENSE.md`.

## 6. Pruebas

- `test_mannequin_prototype.gd`: huesos reales de los tres looks, superficies y
  sustitución de atuendo, nodo `OutfitMannequin` y antebrazo UAL1.
- `test_first_person_hands.gd`: mano abierta de interacción y puños cerrados de
  la honda y la porra, con dos mallas por mano.
- `test_hud_objective.gd`: el objetivo está arriba a la izquierda, con fondo y
  fuente de 26 px.
- Suite completa: **144 pruebas, 0 fallos**.
