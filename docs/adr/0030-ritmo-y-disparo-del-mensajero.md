# ADR-0030 — Ritmo y disparo del mensajero: por acción y con aproximación visible
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

[ADR-0013](0013-ritmo-orientacion-y-cierre.md) fijó el disparo del mensajero en
`arrival_delay = 75 s` con `arrival_grace = 75 s`: el evento arranca a los 75 s
si el jugador está en la plaza y, como tarde, a los 150 s. La decisión se tomó
cuando el jugador no tenía ninguna tarea que hacer durante la espera.

Desde entonces el HUD muestra un objetivo que avanza con el quero, la ofrenda y
la primera conversación. Un jugador que las completa tarda unos 40 s, así que
le quedan entre 35 y 110 s de espera sin nada que hacer ni nada que mirar: el
mensajero espera fuera del camino norte, invisible. La prueba del responsable
del proyecto lo señaló como el problema de ritmo principal.

## Opciones consideradas

1. **Acortar el reloj** a 40 s con 20 s de espera. Simple, pero deja el mismo
   problema si el jugador tarda más o menos en hacer las tareas.
2. **Disparo por acción**, con el reloj como respaldo. El ritmo lo marca el
   jugador y la espera desaparece cuando ha hecho lo que había que hacer.
3. **Mantener el reloj y hacer visible al mensajero** mientras espera. Llena la
   espera, pero el jugador sigue esperando aunque haya terminado.

## Decisión

Se adopta **la opción 2, con la 3 como complemento**:

- El mundo llama a `MessengerEvent.request_arrival()` cuando el objetivo llega a
  «Espera al mensajero», es decir, cuando el jugador bebió del quero, dejó la
  ofrenda y habló con alguien.
- La petición solo arranca si el jugador está a **10 m** o menos de la plaza
  (`request_radius`); si no, queda pendiente y arranca en cuanto llega.
- Respaldo por reloj: `arrival_delay = 45 s` y `arrival_grace = 20 s` (máximo
  65 s, frente a los 150 s anteriores).
- Desde los **18 s** el mensajero baja por el camino del norte a 1,4 m/s y se
  detiene a 24 m de la plaza. Al empezar la llegada recupera su velocidad de
  carrera (5,2 m/s).
- El aviso de espera (`PCH_NARR_WAIT`) pasa a los **20 s**.

Se mantienen de ADR-0013 el vecino que recibe en el camino sur, el paseo de los
vecinos, el aviso de llamada a la plaza y el cierre; y de ADR-0007, la garantía
de que el evento termina aunque el jugador no toque el pututu.

## Consecuencias

- La espera máxima baja de 150 s a 65 s y, en el caso normal, desaparece.
- El evento puede empezar antes de que el jugador haya visto toda la llacta;
  las tareas son opcionales y el evento manda cuando arranca.
- Hay que actualizar `test_messenger_event_starts_on_clock`,
  `test_messenger_event_waits_for_plaza`, `test_narrative_beats_order`,
  `test_npc_talk_and_wander` y la partida de demostración. La demostración
  medida tras el cambio termina en 115 s con `DEMO_OK` (antes, 127 s).
- `docs/05` §Fase 4 y el alcance de la campaña (§5, §9.2 y §10) cambian sus
  cifras de ritmo; el alcance se anota como v4.18.
- ADR-0013 queda reemplazado por este documento.
