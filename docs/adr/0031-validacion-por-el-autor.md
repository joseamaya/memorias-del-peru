# ADR-0031 — Validación del vertical slice por el autor
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

La métrica 5 de [docs/01](../01_vision_y_alcance.md) §5 exige **6 jugadores
ajenos al desarrollo**, con al menos 2/3 explicando con sus palabras quién
amenaza el Cusco y qué hace la élite. [docs/05](../05_plan_de_implementacion.md)
la convierte en criterio de cierre de la Fase 4 y el alcance de la campaña (§9)
detalla el protocolo: consentimiento, facilitador, dos evaluadores y
reclutamiento externo.

Es la única métrica que mide el valor para el público y la única que el
responsable no puede cumplir: no dispone de personas ajenas a quienes convocar.
Mantener el criterio literal deja la fase abierta sin fecha; retirarlo en
silencio escondería el único dato de comprensión del proyecto.

## Opciones consideradas

1. Mantener la muestra externa: máximo rigor, cierre sin fecha posible.
2. Validación por el autor, con protocolo escrito y umbrales medibles.
3. Validación asíncrona: demo pública con el registro de sesión (`--session`).
   Es la única que recupera la métrica de verdad, pero exige una compilación
   distribuible y una página de tienda.

## Decisión

Se adopta **la opción 2 ahora, con la 3 como camino para recuperar la métrica**:

- La métrica 5 queda **declarada «no verificada»** en docs/01 §5; su definición
  no se borra y sigue siendo el objetivo recuperable.
- La Fase 4 se cierra con **validación de autor**: tres pasadas con `--session`,
  un cuestionario escrito antes de releer las fichas y estos umbrales:
  - primera interacción en **≤ 20 s** desde que se toma el control;
  - duración mediana de **4–10 min** (quien desarrolla conoce la ruta: su
    mediana es un límite inferior de la de un jugador nuevo);
  - **cero bloqueos y cero errores** de consola en las tres pasadas;
  - preguntas **1 y 2** correctas; las demás son diagnóstico.
- El informe declarará la limitación: mide si el contenido es legible, no si un
  jugador nuevo lo comprende. No sustituye a la métrica 5.
- Con una compilación pública, el registro de sesión permitirá leer duración,
  bloqueos y ritmo de jugadores reales sin convocarlos; con esos datos se podrá
  reevaluar la métrica 5 sin otro ADR.

## Consecuencias

- docs/01 §5 anota la métrica como no verificada y enlaza este ADR; docs/05
  cambia la precondición y el criterio de la Fase 4; el alcance reescribe
  §9.1–§9.5 y se anota como v4.19.
- La Fase 4 puede cerrarse con la validación de autor, con la métrica de
  audiencia declarada sin verificar.
- Se conserva `--session` como instrumento de esta validación y de la futura
  prueba asíncrona. Sin datos personales, vídeo ni audio.
- No cambia el rigor histórico, las validaciones técnicas ni las fichas.
