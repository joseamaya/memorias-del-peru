# ADR-0019 — Movimiento natural de los personajes

- Estado: Aceptado
- Fecha: 2026-11-12
- Matiza: [ADR-0015](0015-personajes-con-esqueleto.md) (contrato de `NpcActor`) y [ADR-0016](0016-personajes-realistas-makehuman.md) (ciclos de la captura)

## Contexto

El responsable del proyecto pidió revisar a fondo el realismo del movimiento. Se midió en el juego, con un script que sigue los huesos de los pies fotograma a fotograma.

| Medida | Valor | Valor correcto |
|---|---|---|
| Deslizamiento del pie apoyado, caminando | mediana 0,58 m/s | casi 0 |
| Deslizamiento del pie apoyado, corriendo | mediana 3,1 m/s | casi 0 |
| Arranques y paradas | 42–156 m/s² (de golpe) | arranque de medio segundo |
| Giros al llegar a cada punto | hasta 113° en un fotograma | progresivos |

Además, todos los personajes repetían el mismo reposo de 4 s, solo desfasado.

Al revisarlo fotograma a fotograma salieron dos problemas más:

- **Cuerpo girado:** al estar quietos o gesticular, los personajes quedaban girados unos 24° respecto a donde debían mirar.
- **Gestos casi quietos:** al hablar, los brazos apenas se movían.

Causas:

- La velocidad de cada ciclo se calculaba con el avance de la raíz de la toma. Pero la pierna de MakeHuman no recorre exactamente lo mismo: los ciclos reales eran entre un 15 % y un 30 % más lentos.
- Dentro de cada paso la cadera no avanza a velocidad constante.
- `NpcActor` se movía a velocidad fija y giraba con `look_at`.
- **Orientación del sujeto:** se calculaba con un solo hueso de la cadera de CMU, que también apunta hacia delante. Por eso la caminata avanzaba 24° de lado y el pie apoyado se deslizaba lateralmente 0,6 m/s.
- **Elección del tramo:** el tramo de cada toma se elegía solo por lo bien que cierra el bucle, y eso favorece los tramos más quietos.

## Decisión

1. **Pies fijos (`lock_feet` en `pch_people.py`).**
   - Tras hornear el paseo y la carrera, se mide la punta del pie de apoyo en cada fotograma.
   - Su velocidad media hacia atrás es la velocidad real del ciclo, y viaja al juego en los extras glTF.
   - La cadera se corrige fotograma a fotograma, con una corrección periódica y suavizada, para que el pie de apoyo retroceda a esa velocidad constante.
2. **Arranque, frenada y giro (`NpcActor`).**
   - Acelera al arrancar: 2 m/s² caminando y 4,5 m/s² corriendo.
   - Frena para parar justo en el destino.
   - Gira poco a poco: 260°/s caminando, 360°/s corriendo y 200°/s quieto. Frena en los giros cerrados.
   - La velocidad de la animación sigue a la velocidad real en cada fotograma.
   - `face()` gira poco a poco y, si el personaje camina, aplaza el giro hasta que llega, para que no camine de lado. `face(punto, true)` coloca de golpe.
3. **Orientación con las dos caderas.** El eje lateral del sujeto se toma como cadera izquierda menos cadera derecha, y se anula la componente hacia delante. `lock_feet` corrige además el desplazamiento lateral del pie apoyado.
4. **Tramos con movimiento.** Para hablar, trabajar y tejer, el tramo se elige premiando también el movimiento de los brazos (`find_cycle(..., motion_weight=...)`).
5. **Reposo variado.** Un segundo reposo, sacado de la toma 77_02 («standing»). Quieto, cada personaje alterna entre los dos cada 6–13 s con una mezcla de 0,8 s.

## Consecuencias

- **Medido en el juego, deslizamiento del pie apoyado:**
  - caminando: de 0,58 a 0,15–0,24 m/s; lo que queda es sobre todo el rodar del pie del talón a la punta;
  - corriendo: de 3,1 a 0,6 m/s.
- **Giros:** como mucho 9–12° por fotograma (antes, hasta 113°).
- Los pies dejan de patinar en la marcha estable. Los arranques, las paradas y los giros parecen de persona.
- Los tiempos del evento cambian poco: la comitiva tarda algo más en salir, porque acelera y frena.
- Las pruebas que esperaban un giro instantáneo dejan pasar un tiempo antes de comprobar la orientación.
