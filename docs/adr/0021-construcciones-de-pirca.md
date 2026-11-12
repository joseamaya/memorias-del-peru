# ADR-0021 — Construcciones de pirca: casas, poyos, terrazas y corrales

- Estado: Aceptado
- Fecha: 2026-11-12
- Matiza: [ADR-0010](0010-modelos-generados-con-blender.md) (modelos generados) y [ADR-0014](0014-texturas-de-detalle-triplanares.md) (los muros de las terrazas, generados en Godot)

## Contexto

En la revisión de realismo del 2026-11-12, las construcciones eran lo que más alejaba del siglo XV:

- **Muros:** las casas y las terrazas tenían piedras como cajas iguales en hiladas rectas. Con la textura se leían como ladrillo o bloque moderno. Contradecía la propia ficha PCH-007, que cita a Cobo: piedra «tosca y puesta sin orden y concierto», unida con «pelladas de barro».
- **Techos:** de ichu, planos y limpios.
- **Asiento:** las casas parecían apoyadas sobre el pasto.
- **Pedestales:** cajas grises de hormigón bajo el quero y el pututu.
- **Trazado:** todas las casas miraban de frente a la plaza, como en un pueblo planificado.

El responsable del proyecto eligió empezar por las construcciones.

## Decisión

### 1. Pirca de piedra tosca (`pch_models.py` y `stone_wall.gd`)

- Cada piedra tiene un contorno casi rectangular e irregular (superelipse con ruido y un pequeño giro), un bisel hasta la junta y la cara algo abombada.
- **Hiladas irregulares:**
  - la primera, de piedras grandes que asientan el muro;
  - cada piedra de altura y posición distintas dentro de su hilada;
  - cuñas pequeñas en algunas juntas.
- El barro de la junta (casas) o la piedra seca (terrazas y corrales) asoma entre las piedras.
- Cada cara se orienta hacia fuera, porque Godot no dibuja el reverso.
- La paleta de piedra se oscurece un poco.

### 2. Casas

- **Muros en talud:** se cierran 1,2 cm por metro de altura.
- **Enlucido:** la variante B tiene enlucido de barro en cerca de la mitad del muro y la nueva variante C, en tres cuartos. Su borde desconchado deja ver la piedra. El pie y las esquinas quedan sin enlucir.
- **Puerta y dintel:** puerta más baja (1,55 m, «pequeñas y bajas» según Cobo) con dintel de dos palos.
- **Techo de ichu:**
  - más grueso;
  - haces de largo desigual, casi del mismo tono;
  - mechones largos y caídos en el alero y en los bordes de los hastiales;
  - correas de madera que asoman por los hastiales y caballete grueso atado.
- **Asiento:** tierra pisada de borde irregular alrededor de cada casa, con piedras sueltas al pie del muro.
- **Variedad:** tercera variante, `pch_house_c` (4,8 × 4,0 m); las ocho casas alternan A, B y C.
- **Orientación:** cada casa gira entre 4° y 11° respecto a la plaza (`HOUSE_YAW_JITTER`).

### 3. Poyos y corrales

- **Poyos:** el quero y el pututu se apoyan en un poyo de pirca con losa tosca (`pch_pedestal.glb`). La caja del bloqueo conserva la colisión.
- **Corrales:** dos corrales de pirca seca baja (1 m), con su entrada, en las afueras del oeste y el noroeste (`MundoBase.CORRALS`).
  - Quedan fuera de los caminos y de los paseos de los vecinos.
  - La vegetación los respeta.
  - Por ahora están vacíos: las llamas siguen fuera del slice (PCH-014).

## Consecuencias

- **Aspecto:**
  - Las casas se leen como viviendas de piedra y barro de la sierra, con variedad entre ellas.
  - Las terrazas se leen como piedra seca.
  - Los corrales añaden la huella del pastoreo.
- **Coste:**
  - Las casas pasan de unos 9000–10 300 triángulos a 11 300–21 300; los corrales y los poyos añaden geometría.
  - La medición está en [docs/08](../08_entorno_y_rendimiento.md).
- **Pruebas:** nueva prueba `test_llacta_corrals.gd`.
- **Interpretación:**
  - Siguen a Cobo (PCH-007) la mampostería tosca con barro y la puerta baja.
  - Son reconstrucción (R) el talud, el enlucido parcial, el dintel de palos, las correas, la tierra pisada y los corrales (PCH-021).
  - Los corrales tienen una sola fuente de apoyo, no contrastada directamente.
- **Lo que queda fuera de este paso:**
  - el trazado de caminos rectos en cruz y la plaza cuadrada;
  - las terrazas rectas, aún sin peldaños salientes ni cultivo.
