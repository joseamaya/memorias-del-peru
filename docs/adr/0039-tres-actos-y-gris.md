# ADR-0039 — Tres actos y construcción en gris
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

Con el giro a RPG ([ADR-0038](0038-campana-rpg.md)) hace falta una estructura
narrativa completa y una forma de probarla sin esperar al arte de dos escenarios
nuevos. La campaña tiene un final histórico claro —la defensa del Cusco— y un
camino natural desde la llacta.

El riesgo de construir acto por acto, puliendo el primero, es repetir el error
del museo: meses en una pieza y ninguna visión del conjunto.

## Opciones consideradas

1. **Un acto cada vez**, cerrado y pulido antes del siguiente. Máxima calidad por
   pieza, pero el arco no se puede jugar hasta el final.
2. **Los tres actos a la vez y completamente detallados** desde el primer día.
   Da visión, pero multiplica el coste antes de saber si los sistemas funcionan.
3. **Los tres actos diseñados y construidos en gris**, con los sistemas reales y
   arte provisional; el arte llega cuando el arco completo se sostiene.

## Decisión

Se adopta **la opción 3**:

- La campaña tiene **tres actos**:
  1. **La llacta** (12–15 min): oficios, favores y la llegada de la noticia.
  2. **El paso** (12–15 min): la comitiva, la emboscada y una decisión con
     consecuencias.
  3. **El Cusco** (16–18 min): la llamada a los ayllus, la defensa y el
     epílogo.
- Duración objetivo: **40–50 min** en una partida completa.
- Los actos II y III se construyen primero en **gris**: geometría de bloqueo,
  materiales provisionales y los sistemas definitivos. El arte y el audio
  llegan en la fase de cierre.
- Se añaden **selector de acto** (`--act=1|2|3`), **puntos de control** y una
  **partida automatizada del arco** para probar sin repetir 45 minutos.
- No hay guardado completo en esta etapa. El estado de la partida vive en
  memoria y se reanuda desde el punto de control.

## Consecuencias

- [docs/05](../05_plan_de_implementacion.md) abre las fases 6, 7 y 8: núcleo y
  acto I, actos II–III en gris, arte y cierre.
- El Cusco de 1438 se construye con la arquitectura de la llacta a mayor escala:
  es más riguroso que la ciudad monumental —posterior— y más barato.
- La validación de autor se hace una vez, sobre el arco completo, no tres veces
  sobre piezas.
- Si el arco no funciona en gris, se corrige antes de invertir en arte.
- El alcance del vertical slice queda como referencia del acto I; la biblia de
  la campaña manda sobre los actos.
