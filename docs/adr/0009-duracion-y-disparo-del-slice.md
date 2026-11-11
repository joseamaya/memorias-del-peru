# ADR-0009 — Duración y disparo del vertical slice

- Estado: Aceptado
- Fecha: 2026-11-10

## Contexto

La métrica 1 de [docs/01](../01_vision_y_alcance.md) §5 compromete 10–15 minutos de mediana para el vertical slice. La revisión del bloqueo de la llacta mostró que el disparo del evento ocurría a los 5–7 s de empezar y que la historia completa duraba unos 2 minutos: el resto de la sesión transcurría con la historia ya terminada.

La aritmética del contenido aprobado es esta: la llacta mide 150 m y se cruza en 43 s a 3,5 m/s; el evento dura 1,5–2 min; las tres interacciones se resuelven en segundos. Un jugador que lo ve todo emplea entre 5 y 7 minutos. Para llegar a 10 harían falta unos cuatro minutos más de actividad real: una ronda de tareas, dos o tres NPC con rutina y dos o tres momentos narrativos más. Eso duplica el slice y pertenece a otra fase.

## Opciones consideradas

1. **Mantener 10–15 min con el contenido actual.** Imposible sin rellenar con espera o con paseo vacío. Rechazada.
2. **Ampliar el contenido hasta 10–15 min.** Duplica el trabajo del slice y mezcla el objetivo de validación con el de producción. Rechazada para esta fase.
3. **Ajustar el objetivo del slice a 5–8 min y situar la noticia al final de la sesión.** El vertical slice valida el bucle (explorar, interactuar, evento, cierre) con una duración honesta; los 10–15 min siguen siendo el objetivo de la campaña completa. Aceptada.

## Decisión

Opción 3.

- **Objetivo medible del slice:** mediana de **5–8 minutos** para un jugador que explora sin prisa. Se registra en `docs/05` y en el alcance del vertical slice.
- **La métrica 1 de docs/01 no se deroga:** se aplaza a la campaña completa. Este ADR solo fija el objetivo del vertical slice.
- **Disparo por reloj:** el mensajero se pone en camino a los `arrival_delay = 240 s` de partida. A partir de ahí, el evento espera a que el jugador esté en la plaza hasta `arrival_grace = 120 s`; si no llega, arranca igualmente.
- La apertura anuncia la llegada (“Dicen que hoy llegará un mensajero del Cusco”), para que el reloj no sea arbitrario.
- La tabla de duración del alcance se rehace con dos escenarios (directo y explorador) en lugar de sumar dos rutas alternativas.
- La prueba con seis personas mide la mediana real; si queda por debajo de 5 min, se añade contenido con datos, no con estimaciones.

## Consecuencias

- La historia deja de ocurrir a los 6 segundos y pasa a cerrar la sesión.
- El criterio de aceptación de la Fase 4 cambia de 10–15 a 5–8 min; sin este ADR la fase no podría cerrarse.
- Un jugador que no vuelva a la plaza en 6 minutos ve el evento igualmente: no hay bloqueo, solo pérdida de puesta en escena.
- Si más adelante se añade contenido, el objetivo puede volver a subir con otro ADR.
