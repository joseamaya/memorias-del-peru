# ADR-0011 — Fichas de elementos que no están en el juego

- Estado: Propuesto
- Fecha: 2026-11-11

## Contexto

[docs/07](../07_convenciones_historicas.md) §3 dice: «Las fichas con estado “pendiente” se marcan como bloqueantes para el cierre de la Fase 4». La regla no distingue entre los elementos que están en el juego y los que solo se valoraron.

El registro de la campaña 01 tenía una ficha de este segundo tipo, PCH-014 (llama / alpaca). El alcance la marcaba como opcional y nunca entró en el juego. El 2026-11-11 el responsable del proyecto decidió sacarla del cierre. Se pasó a una sección «Fuera del vertical slice» del registro, con una nota que interpreta que docs/07 §3 se aplica a los elementos del slice.

Esa interpretación no está escrita en docs/07. Según [AGENTS.md](../../AGENTS.md) §1, una contradicción entre documentos no se resuelve en silencio: se propone un ADR.

## Opciones consideradas

1. Verificar también las fichas de elementos que no están en el juego. Rechazada: obliga a trabajo de biblioteca sobre contenido que el jugador no ve y no mejora el rigor de lo que sí ve.
2. Borrar esas fichas. Rechazada: se pierde la investigación ya hecha y habría que repetirla si el elemento se incorpora.
3. Separar esas fichas en una sección del registro que no bloquea el cierre. Si el elemento entra en el juego, la ficha vuelve a la lista principal como pendiente.

## Decisión

Opción 3, si se acepta.

- El registro de cada campaña puede tener una sección **«Fuera del vertical slice»** para fichas de elementos que no están en el juego.
- Esas fichas conservan su clasificación y su estado, pero **no bloquean** el cierre de la fase.
- Si el elemento se incorpora al juego, la ficha vuelve a la lista principal y bloquea el cierre hasta que se verifique.
- Sacar una ficha de la lista principal es una decisión del responsable del proyecto y se anota con su fecha en el alcance §8.

## Consecuencias

- Al aceptar este ADR, docs/07 §3 debe añadir: «Las fichas de elementos que no están en el juego pueden figurar en una sección aparte del registro y no bloquean el cierre (ADR-0011)».
- PCH-014 queda en esa sección. Hasta que se acepte este ADR, su exclusión se apoya en la decisión del responsable del proyecto del 2026-11-11, anotada en el alcance §8.
- Una revisión del cierre de la Fase 4 debe comprobar que ningún elemento de esa sección aparece en el juego.
