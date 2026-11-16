# Registro de ajustes de combate

Cada cambio de valores de combate o movimiento, con su motivo. Más reciente arriba.
Los valores viven en `core/systems/combat/` y en los recursos de arma; este registro
conserva el porqué para no repetir pruebas ya hechas.

| Fecha | Archivo | Cambio | Motivo |
|---|---|---|---|
| 2026-11-16 | `combat_loadout.gd` | Honda: anticipación 0,30 s, activa 0,10 s, recuperación 0,40 s; porra: 0,22 / 0,14 / 0,34; parry 0,15 s; bloqueo 70 % y 5 de aliento | Primer pase de sensación: el ataque instantáneo no se leía. Los tiempos separan anticipación, impacto y recuperación; la honda queda más lenta y la porra más seca. Valores iniciales, pendientes de probar con mando y teclado |
| 2026-11-16 | `combat_loadout.gd` | Hitstop 0,055 s a `time_scale` 0,05; golpe de cámara −1,8° al acertar y −1,4° al recibir | El impacto necesita peso. El hitstop es breve para no cortar el ritmo; el golpe de cámara se recupera en 0,16 s |
| 2026-11-16 | `ambush_enemy.gd` | Anticipación 0,45 s con esfera y signo «!» de aviso; ficha de ataque máximo 2; separación 1,4 m; amago al no recibir ficha | Sin aviso, el golpe enemigo era impredecible; sin fichas, los cuatro chancas golpeaban a la vez. El aviso se ve y suena antes del impacto; la esfera sola se perdía con el enemigo de espaldas |
| 2026-11-16 | `ambush_enemy.gd` | El cuerpo derribado desactiva colisión | El bot de la arena descubrió que el cadáver seguía bloqueando el rayo: después de matar al primero, los demás quedaban detrás y el combate se atascaba |

## Invariantes

- `windup_seconds > 0`, `active_seconds > 0`, `recovery_seconds >= 0`.
- La ventana de parry (0,15 s) es menor que la anticipación enemiga (0,45 s): se puede
  leer y reaccionar, pero no pulsar al azar.
- El bloqueo normal reduce el 70 % y consume 5 de aliento; el parry perfecto no consume.
- Como máximo dos enemigos atacan a la vez; el resto rodea o amaga.

## No verificado

- La sensación real con teclado y mando: la decide una persona jugando.
- El equilibrio de daño y aliento en una partida completa.
- El golpe de cámara en personas sensibles al movimiento; si molesta, se baja o se
  convierte en opción de accesibilidad.
