# ADR-0033 — Duración del vertical slice: fragmento de 2–3 minutos
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

[docs/01](../01_vision_y_alcance.md) §5 fijó 10–15 min para el vertical slice y
[ADR-0009](0009-duracion-y-disparo-del-slice.md) lo ajustó a 5–8 min. La
autovalidación del 2026-11-13 midió cuatro pasadas completas: **77,7 s, 86,3 s,
97,9 s y 121,2 s**, esta última ya con el objetivo del mirador
([ADR-0032](0032-objetivo-del-mirador.md)).

El registro muestra por qué: las tareas están en la plaza, el mirador añade unos
35 s y el evento dura 41 s. Cada hito lejano aporta 30–45 s, así que llegar a
4 min exigiría tres o cuatro hitos más, y a 5–8 min, el doble. El slice existe
para validar el bucle completo —movimiento, interacción, objetivos, evento,
cierre—, no para ser la experiencia final. La duración de la campaña la
resolverá el modelo de estaciones del Discovery Tour, con contenido diseñado
para eso.

## Opciones consideradas

1. **Añadir contenido hasta 4–5 min.** Tres hitos más; una semana. Sigue por
   debajo de los 5–8 originales y el contenido se rehará en el tour.
2. **Rebasear el slice a 2–3 min** y cerrar la Fase 4. Honesto con lo medido y
   con el propósito de la etapa.
3. **Dejar la fase abierta** y resolver la duración en el Discovery Tour. No
   cierra nada y deja el proyecto sin un hito entregable.

## Decisión

Se adopta **la opción 2**:

- La duración comprometida del vertical slice es de **2–3 min de mediana en
  ruta directa**. La medición de AUTO-4 (121,2 s) cumple.
- El umbral de duración de [ADR-0031](0031-validacion-por-el-autor.md) pasa de
  4–10 min a **2–3 min**; el resto del protocolo de validación no cambia.
- El horizonte de **10–15 min** de docs/01 §6 se mantiene para la **campaña
  completa**, no para el slice. El slice es un fragmento, y así se presenta.
- La Fase 4 se cierra con la autovalidación registrada.

## Consecuencias

- docs/01 §5 (objetivo y métrica 1), docs/05 (objetivo, criterio y estado) y el
  alcance de la campaña (§1, §10 y v4.21) cambian sus cifras.
- ADR-0009 queda reemplazado; ADR-0031 queda ampliado en su umbral de duración.
- El registro de sesiones anota la duración como superada y enlaza este ADR.
- Una fase posterior (Discovery Tour) decidirá si la experiencia crece; no se
  añade contenido ahora para inflar la duración.
