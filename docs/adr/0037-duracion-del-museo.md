# ADR-0037 — La duración del museo: 6–8 minutos de exploración con lectura
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

La Fase 5 fijó como criterio «duración mediana de 6–8 min en ruta guiada». Ese
texto procede de [ADR-0034](0034-una-campana-y-museo.md), cuando el museo tenía
estaciones sugeridas y un contador. [ADR-0036](0036-leer-en-el-mundo.md) eliminó
la ruta guiada: ahora las nueve tarjetas se descubren recorriendo la llacta.

Con el criterio tal como está, la fase no se puede cerrar: no existe una «ruta
guiada» que cronometrar. Además, [docs/01](../01_vision_y_alcance.md) §5 fija
2–3 min para el vertical slice y este documento pide 6–8, sin decir si son
incompatibles.

## Opciones consideradas

1. **Mantener «ruta guiada»** y medir un recorrido que ya no existe. No es
   medible.
2. **Volver a 2–3 min**, la cifra del slice, y renunciar a que la lectura cuente.
   Contradice el modelo de museo: leer nueve tarjetas no cabe en tres minutos.
3. **Rebasar el criterio a «6–8 min de exploración con lectura»**, y separar esa
   cifra de los 2–3 min de la ruta directa sin leer.

## Decisión

Se adopta **la opción 3**:

- La duración del museo se mide **desde Comenzar hasta la tarjeta de fin**, con
  el jugador recorriendo la llacta y leyendo las tarjetas que encuentre. El
  objetivo es **6–8 min**.
- Los **2–3 min de [ADR-0033](0033-duracion-del-slice.md)** describen la ruta
  directa del vertical slice, sin detenerse a leer; siguen vigentes como
  referencia del fragmento, no como duración del museo.
- La medición se hace con el registro de sesión (`--session`), que ya marca el
  inicio, las fases del evento y la tarjeta de fin. Desde esta entrega marca
  además cada tarjeta abierta y cerrada (`spot`, `spot_closed`), para saber qué
  se leyó y cuánto.
- La cifra no se declara cumplida hasta medirla. Si la sesión da menos de 6 min,
  se decide con el número delante entre añadir contenido o rebasar el objetivo
  con otro ADR; no se ajusta el criterio a la medición.

## Consecuencias

- El criterio de la Fase 5 queda expresado en términos medibles y coherentes con
  ADR-0036.
- La duración depende de la exploración: quien no lea, tardará menos, y eso es
  correcto en un museo que se descubre.
- `docs/05` y el alcance de la campaña se corrigen para no hablar de estelas ni
  de ruta guiada.
- Instrumentar las tarjetas no cambia el juego: solo escribe en el registro
  cuando hay una sesión activa.
