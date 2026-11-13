# ADR-0032 — Objetivo del mirador y anuncio de la espera
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

[ADR-0030](0030-ritmo-y-disparo-del-mensajero.md) sustituyó el reloj por un
disparo por acción y añadió la aproximación visible. La validación de autor
([ADR-0031](0031-validacion-por-el-autor.md)) midió tres pasadas completas:
**77,7–97,9 s** de duración total (mediana 86 s), frente al umbral de 4–10 min.

El registro de sesión muestra la causa: las tres tareas están a menos de 20 m de
la plaza y se completan en unos 25 s; el mensajero sale en cuanto terminan. El
recorrido directo se convirtió en un pasillo de minuto y medio. La ruta alta y
el mirador existen desde la Fase 3, pero la partida directa nunca los usa.

El aviso «El sol sube… aún no viene nadie» se emitía por reloj a los 20 s, a
menudo mientras el HUD pedía todavía dejar la ofrenda: un desajuste visible.

## Opciones consideradas

1. **Rebasear el objetivo** a ~2 min y corregir docs/01 y docs/05. Barato, pero
   abandona el compromiso de 5–8 min sin intentar cumplirlo.
2. **Añadir el mirador como cuarto objetivo** y disparar la llegada desde allí.
   Alarga el recorrido con contenido que ya existe y da sentido al aviso.
3. **Añadir tres hitos** (mirador, casas del oeste, corral). Apunta a 5–6 min,
   pero es una semana de contenido antes de saber si el mirador basta.

## Decisión

Se adopta **la opción 2**:

- La secuencia pasa a: quero → ofrenda → conversación → **mirador** → espera →
  escucha → pututu → partida.
- El mirador está en (52, 2,45, 0), al final de la ruta alta. A 6 m o menos se
  cumple el objetivo.
- Al llegar, el mundo avanza a «Espera al mensajero en la plaza» y emite el
  aviso con `MessengerEvent.announce_wait()`; desde allí se ve bajar al
  mensajero por el camino del norte.
- La llegada se pide al alcanzar ese objetivo, pero sigue esperando a que el
  jugador esté a 10 m de la plaza: la petición queda pendiente durante la vuelta.
- El respaldo por reloj sube a **80 s + 20 s** (máx. 100 s) para que la subida y
  la vuelta quepan sin que el evento se adelante.

Se mantienen de ADR-0030 el disparo por acción, la aproximación visible desde
los 18 s y el resto del ritmo.

## Consecuencias

- El suelo medido sube de ~1,5 a ~2,5–3 min. **Sigue por debajo de 4**: si la
  re-medición lo confirma, la decisión entre añadir el tercer hito o rebasear el
  objetivo se toma con ese dato, no antes.
- El aviso de espera deja de depender de un reloj y coincide con la mirada al
  camino del norte.
- Cambian `test_narrative_beats_order`, `test_npc_talk_and_wander` y
  `test_world_objective`; la partida de demostración ya pasaba por el mirador y
  termina en 121,8 s con `DEMO_OK`.
- El alcance de la campaña se anota como v4.20. ADR-0030 queda ampliado por este
  documento, no reemplazado.
