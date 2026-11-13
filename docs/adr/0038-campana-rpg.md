# ADR-0038 — La campaña 01 pasa a RPG en primera persona
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

[docs/00](../00_especificacion.md) define el género como «Aventura histórica / RPG /
Exploración en primera persona» y enumera «combate y progresión» entre las
prioridades. [docs/01](../01_vision_y_alcance.md) recortó esa visión a un
vertical slice de exploración y dejó el combate, el inventario, el diálogo y las
misiones en el horizonte, sin fase.

La Fase 5 convirtió la campaña en un museo explorable
([ADR-0034](0034-una-campana-y-museo.md)) y luego en lectura dentro del mundo
([ADR-0036](0036-leer-en-el-mundo.md)). Funciona como recorrido, pero no como
juego: no hay decisiones, no hay riesgo, no hay progresión. El responsable del
proyecto decide volver al RPG y diseñar los tres actos de la campaña de una vez
para probarlos completos.

## Opciones consideradas

1. **Mantener el museo** y cerrar la Fase 5 con la validación pendiente. Es el
   camino seguro, pero deja el juego sin las mecánicas que `docs/00` pide.
2. **RPG con combate cuerpo a cuerpo completo.** Es el RPG de manual, pero
   expone a los personajes a corta distancia —el punto débil conocido— y añade
   meses de animación y equilibrio.
3. **RPG en primera persona con combate a distancia** (honda) y cuerpo a cuerpo
   mínimo, con estado, habilidades, inventario, diálogo, diario y reputación.

## Decisión

Se adopta **la opción 3**:

- La campaña 01 se organiza como **RPG histórico en primera persona de tres
  actos** (ADR-0039). El jugador es un joven de la llacta; no sustituye a Cusi
  Yupanqui ni cambia el resultado histórico.
- Entran en alcance los sistemas de **estado y habilidades, inventario, diálogo
  con opciones, diario, reputación, combate a distancia y puntos de control**.
  No hay niveles, XP, loot aleatorio, magia ni guardado completo en esta etapa.
- Las nueve tarjetas del museo **dejan de ser el centro**. Sus textos pasan a
  diálogos de los personajes y a la «Memoria» del diario. Las tarjetas
  automáticas se retiran.
- El combate principal es la **honda**; la porra y el escudo existen como
  último recurso. Así los personajes se ven a la distancia en la que los
  recursos actuales se sostienen.
- La **Fase 5 queda superada**, no cumplida: sus criterios de duración, HUD y
  validación dejan de aplicar. Se cierra como modelo sustituido y no se le
  exige la validación pendiente.

## Consecuencias

- [docs/01](../01_vision_y_alcance.md), [docs/02](../02_arquitectura.md),
  [docs/05](../05_plan_de_implementacion.md) y [docs/06](../06_estrategia_de_pruebas.md)
  se actualizan: el género, los sistemas, las fases y las pruebas.
- Nace la [biblia de la campaña](../../campaigns/01_pachacutec/documentation/biblia_campana.md)
  con los tres actos, y el alcance del vertical slice se conserva como
  referencia del acto I.
- El mundo, el jugador, la interacción, el evento del mensajero, el audio y el
  pipeline de assets se conservan. No se reescribe la base técnica.
- El contenido histórico nuevo (armas, Cusco de 1438, paso, batalla) exige
  fichas verificadas antes de entrar en el juego.
- La validación de autor pasa a medir el arco completo (40–50 min), no la
  lectura de nueve tarjetas.
