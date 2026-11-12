# ADR-0015 — Personajes con esqueleto y animaciones generadas

- Estado: Aceptado
- Fecha: 2026-11-12
- Sustituye: la decisión de personajes «sin rig» del alcance v3.3, matizada en v3.5 y en [ADR-0013](0013-ritmo-orientacion-y-cierre.md) (balanceo de piernas y brazos por nodos sueltos)
- Matiza: [ADR-0010](0010-modelos-generados-con-blender.md) (los modelos de personaje dejan de ser estáticos)

## Contexto

El alcance v3.3 dejó los personajes sin rig para llegar al piloto: se desplazan, se giran y, desde la v3.5, balancean piernas y brazos como piezas rígidas. Tronco y cabeza no se mueven. La tabla de personajes (alcance §5) pide gestos que así no se pueden hacer:

- la tejedora teje y gira la cabeza hacia el jugador;
- el agricultor trabaja;
- el mensajero llega corriendo, agotado, y habla con gestos.

La primera persona del piloto dijo que el juego no se siente realista. Las texturas (ADR-0014) resolvieron parte. Los personajes siguen pareciendo figuras rígidas que se deslizan. El 2026-11-12, el responsable del proyecto pidió añadir el rig con su ADR.

## Opciones consideradas

1. **Rig de terceros** (Mixamo u otro con animaciones capturadas). Rechazada por tres motivos:
   - exige cuenta y licencias que no son CC0;
   - el cuerpo y la ropa tendrían que adaptarse a un esqueleto ajeno;
   - rompe el generador por script de ADR-0010.
2. **Pesos automáticos de Blender** (`ARMATURE_AUTO`). Rechazada: el cuerpo está hecho de piezas sueltas (prenda, lliclla, manto, trenzas), y el cálculo por calor falla o da pesos distintos según la malla.
3. **Esqueleto y animaciones generados por el mismo script**, con pesos asignados por pieza. Aceptada.

## Decisión

### Esqueleto y pesos

`pch_models.py` añade a cada personaje un esqueleto de 18 huesos:

- **Tronco:** `root`, `hips`, `spine`, `chest`, `neck` y `head`.
- **Brazos:** `upper_arm`, `forearm` y `hand`, en los lados `.L` y `.R` según el lado anatómico.
- **Piernas:** `thigh`, `shin` y `foot`, también en `.L` y `.R`.

El cuerpo se construye por piezas y cada una recibe sus pesos con una regla explícita:

- la prenda se reparte entre cadera, columna y pecho según la altura;
- las piernas y los brazos se reparten a lo largo de su eje, con una transición en rodilla y codo;
- la cabeza, el pelo, las trenzas y el tocado van a cuello y cabeza;
- el manto, la lliclla y el bulto van al pecho; la chuspa va a la cadera;
- la chaquitaclla va a la mano.

El resultado es determinista, como el resto del generador.

### Animaciones

Se definen con funciones periódicas en el script, sin captura de movimiento, y se exportan en el mismo `.glb`:

| Animación | Uso |
|---|---|
| `idle` | Respiración, cambio de peso y brazos sueltos |
| `walk` | Paseo; ciclo de dos pasos de 0,75 m |
| `run` | Carrera del mensajero; ciclo de dos zancadas de 1,3 m |
| `talk` | Gestos de una mano y asentimiento al hablar |
| `tired` | Agotamiento: tronco inclinado y respiración fuerte |
| `weave` | Tejedora arrodillada ante el telar de cintura, con el golpe de la trama |
| `work` | Agricultor que hinca y levanta la chaquitaclla |

La tejedora pasa a tejer **arrodillada**, como en el dibujo 80 de Guamán Poma que ya cita PCH-010. Es una reconstrucción (R) sobre esa misma fuente: no se añade ninguna fuente nueva. La parte baja del anacu queda bajo el terreno, como una falda extendida en el suelo.

### En Godot

- `NpcActor` usa el `AnimationPlayer` del modelo:
  - por debajo de 2,6 m/s pone `walk` y, por encima, `run`;
  - ajusta la velocidad de reproducción a la de desplazamiento, para que los pies no patinen;
  - quieto, vuelve a la animación de reposo de cada personaje (`idle`, `weave`, `work`, `tired` o `talk`).
- Un `LookAtModifier3D` de Godot (API nativa desde 4.4, comprobada en 4.7.2) gira la cabeza hacia el jugador cuando está cerca y el personaje no camina, dentro de límites de cuello. La tejedora no gira el cuerpo al hablar: gira solo la cabeza, para no apartarse del telar.
- Los nodos sueltos `LegL`, `LegR`, `ArmL` y `ArmR`, y el balanceo calculado por código, se retiran.
- La comitiva (curaca y hombres principales) pasa de 3,2 a 1,8 m/s. A 3,2 m/s solo cabía correr o un paso acelerado poco natural; la marcha sigue cabiendo de sobra en los tiempos del evento.

## Consecuencias

- Los personajes respiran, caminan con todo el cuerpo y hacen los gestos que pide el alcance §5. Se cumple la «animación idle» que exigen los objetivos medibles de la Fase 4.
- Cada personaje pasa a ser una sola malla con piel (`Skeleton3D`), de unos 1100–1200 triángulos.
- Con el viento del punto 4 incluido, en la GPU integrada de referencia el coste fue de unos 0,5 ms por fotograma: Bajo pasa de 166,8 a 153,9 FPS y Medio se queda en unos 59–60 FPS. La medición está en [docs/08](../08_entorno_y_rendimiento.md).
- La textura de tejido usa la proyección en coordenadas del objeto, así que en los miembros que se mueven se desliza un poco. Es poco visible porque brazos y piernas son piel sin textura y la prenda apenas se deforma.
- Las animaciones son procedurales: más rígidas que una captura de movimiento, pero sin licencias ajenas. Una versión posterior podría sustituirlas sin cambiar el contrato de `NpcActor`.
- Si se cambia una animación hay que regenerar los `.glb` de personaje; el generador sigue siendo la única fuente.
