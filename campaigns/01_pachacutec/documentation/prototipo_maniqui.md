# Prototipo de maniquíes UAL1 y panel de objetivo

> Estado: **diez looks capturados, pendientes de aprobación e integración**. La
> mano de primera persona está integrada, pero **pendiente de revisión**: el
> responsable no está conforme con su resultado. El elenco UBC sigue activo
> hasta cerrar la migración.

## 1. Qué se ha probado

- **Diez maniquíes** con el mismo cuerpo UAL1 de Quaternius y diez looks:
  - **Curaca:** unku crema, franja de t'oqapu roja y ocre, manto rojo, cinta
    ocre y chuspa azul. Sin orejeras, vara, oro ni metales.
  - **Sisa:** anacu pardo con ruedo rojo, lliclla crema con tupu, faja y cinta
    rojas y melena posterior.
  - **Chanca:** unku carbón, faldón pizarra, faja y cinta teal y manto pesado;
    las armas van en el actor de combate.
  - **Anca:** anacu arena y pardo, lliclla ocre con tupu, faja y cinta rojas y
    melena posterior. Es también el look de la Tejedora.
  - **Puma:** unku oliva, manto, faja y cinta ocres y chuspa oscuro; autoridad
    sin t'oqapu.
  - **Madre:** anacu gris, lliclla clara con tupu, paño oscuro y melena.
  - **Hermano:** unku crema, manto pardo, faja roja y chuspa pequeño.
  - **Joven:** unku arena y chuspa clara; es el Agricultor, el HijoPuma a
    1,20 m y el arquetipo de multitud.
  - **Anciana:** anacu gris, lliclla plateada con tupu, paño gris y canas.
  - **Mensajero:** ropa de viaje parda, paño oscuro, chuspa ocre, correa y
    bulto a la espalda.
- **Mano del jugador** de maniquí: antebrazo extraído del UAL1 y palma, cuatro
  dedos separados y pulgar primitivos, con los colores de piel y juntas. Tiene
  pose abierta para interactuar y puño cerrado para la honda y la porra; ambas
  se hornean en dos mallas (piel y juntas) para no multiplicar draw calls.
  **Queda pendiente de revisión.**
- **Panel de objetivo** arriba a la izquierda, con fondo oscuro y texto cálido,
  integrado en el HUD actual; aprobado tal como está.

Capturas:

| Prototipo | Imagen |
|---|---|
| Cinco papeles principales | ![Maniquíes principales](img/prototipo/maniquies_principales.png) |
| Familia, multitud y mensajero | ![Maniquíes de apoyo](img/prototipo/maniquies_apoyo.png) |
| Mano abierta en la llacta | ![Mano abierta](img/prototipo/mano.png) |
| Puño con la honda | ![Mano con la honda](img/prototipo/mano_honda.png) |
| Puño con la porra | ![Mano con la porra](img/prototipo/mano_porra.png) |
| Panel de objetivo en la llacta | ![Objetivo](img/prototipo/objetivo.png) |

## 2. Cómo se ejecuta

```bash
godot --path . res://tests/scenes/mannequin_prototype.tscn
godot --path . res://tests/scenes/mannequin_hand_prototype.tscn
```

La primera guarda `user://maniquies_principales.png` y
`user://maniquies_apoyo.png`; la segunda, `user://mano_abierta.png` y
`user://mano_agarre.png`. El antebrazo se regenera con:

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

1. **Aprobar los diez looks** con las dos capturas.
2. ~~Crear los looks de los diez papeles.~~ **Hecho:** los diez looks viven en
   `MannequinLooks`, con alturas de la tabla de la llacta.
3. Integrar el maniquí en `NpcActor`/`CharacterModelVisual` y retirar los UBC,
   caras, texturas, mandíbula, parpadeo, cejas y manto con muelles.
4. Multitud: maniquí liso sin piezas o con muy pocas, para no disparar draw calls.
5. ~~Integrar la mano en `FirstPersonHands` y en el arma.~~ **Hecho, pero
   pendiente de revisión:** el resultado actual no convence al responsable.
6. Panel de objetivo: aprobado tal como está, sin temporizador ni rediseño.
7. Pruebas de los diez looks, capturas, rendimiento y documentación final.

## 5. Decisiones y riesgos

- **Se usa el UAL1 Standard de Quaternius** (CC0), el mismo que ya estaba en
  `shared_assets/characters/mannequin/`. En el proyecto de referencia figura
  como recurso de prototipo; usarlo como estilo final es una decisión
  consciente de este proyecto.
- **Los diez looks son código** (`MannequinLooks`): colores y piezas primitivas,
  sin texturas. Se podrán serializar a `.tres` cuando el estilo quede cerrado.
- **La ropa es reconstrucción (R)** sobre PCH-017/018/024: unku, anacu, lliclla,
  manto, faja, chuspa, tupu, cinta y paño. No copia una pieza concreta. Los
  personajes son ficción (N).
- **Correcciones al prototipo de tres:** el Curaca ya no lleva orejeras ni oro;
  la guía visual reserva ese adorno para el Inca, no para la autoridad local.
  El Chanca pasa de túnica teal a unku oscuro con acento teal. Se añaden la
  lliclla delantera con tupu, la melena posterior o el paño y el bulto del
  mensajero.
- **El maniquí no tiene cara, pelo ni barba:** las mujeres se leen por el anacu
  largo, la lliclla con tupu y la melena posterior o el paño; los hombres, por
  el unku corto, el manto y la chuspa. La edad se sugiere con la paleta
  gris/plateada y el paño. No hay retratos ni expresión facial.
- **La lliclla delantera y el manto son paneles planos;** de frente se ve el
  panel delantero de la lliclla, pero el manto y el bulto del mensajero quedan
  sobre todo de espaldas. Es el precio del estilo de primitivas.
- **HijoPuma** es el Joven a 1,20 m; se lee como un adulto pequeño, no como un
  niño. La base infantil gratuita sigue sin existir.
- **La mano de primera persona** conserva el antebrazo UAL1 y una mano
  primitiva con pose abierta y puño; está integrada en el juego, pero el
  responsable no está conforme con el resultado y queda en revisión.
- **Licencia y procedencia**: UAL1 es CC0; el antebrazo es una derivación del
  mismo GLB y las piezas de la mano son código propio; los scripts
  `CharacterLook`, `LookPart` y `CharacterOutfit` están adaptados del proyecto de
  referencia del mismo autor. Se registra en
  `shared_assets/characters/mannequin/LICENSE.md`.

## 6. Pruebas

- `test_mannequin_prototype.gd`: los diez looks, huesos reales, piezas con
  malla, Curaca sin orejeras, nodo `OutfitMannequin` y antebrazo UAL1.
- `test_first_person_hands.gd`: mano de maniquí abierta y puños cerrados de la
  honda y la porra, con dos mallas por mano.
- `test_hud_objective.gd`: el objetivo está arriba a la izquierda, con fondo y
  fuente de 26 px.
- Suite completa: **144 pruebas, 0 fallos**.
