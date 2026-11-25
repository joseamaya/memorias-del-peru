# Registro de ajustes de combate

Cada cambio de valores de combate o movimiento, con su motivo. Más reciente arriba.
Los valores viven en `core/systems/combat/` y en los recursos de arma; este registro
conserva el porqué para no repetir pruebas ya hechas.

| Fecha | Archivo | Cambio | Motivo |
|---|---|---|---|
| 2026-11-25 | `allied_warrior.gd` | Seis huecos de espera: 3 columnas × 2 filas, 1,5 m lateral y 1,2 m de fondo; órbita a 2,4 m con margen de 0,25 m | Los seis compartían un punto y temblaban en el borde del espacio personal. La órbita rodea al jugador en vez de cruzar por delante; los huecos evitan el apilamiento |
| 2026-11-25 | `chanca_warrior.gd`, `allied_warrior.gd` | Evitación de tiendas con 1,3 m de anticipación, 0,55 de empuje hacia fuera y desempate por hueco | Con la colisión de las tiendas, el movimiento en línea recta dejaba a los chancas clavados contra los conos y la oleada no cerraba |
| 2026-11-25 | `carmenca_spawn.gd` | El anillo prueba 5 radios × 11 ángulos y exige 0,5 m libre de cada tienda; el reflejo por distancia al jugador se mantiene | El hueco 1 de la oleada 1 nacía dentro de la tienda 4; los aliados también podían nacer dentro |
| 2026-11-16 | `combat_loadout.gd` | Honda: anticipación 0,30 s, activa 0,10 s, recuperación 0,40 s; porra: 0,22 / 0,14 / 0,34; parry 0,15 s; bloqueo 70 % y 5 de aliento | Primer pase de sensación: el ataque instantáneo no se leía. Los tiempos separan anticipación, impacto y recuperación; la honda queda más lenta y la porra más seca. Valores iniciales, pendientes de probar con mando y teclado |
| 2026-11-16 | `combat_loadout.gd` | Hitstop 0,055 s a `time_scale` 0,05; golpe de cámara −1,8° al acertar y −1,4° al recibir | El impacto necesita peso. El hitstop es breve para no cortar el ritmo; el golpe de cámara se recupera en 0,16 s |
| 2026-11-16 | `ambush_enemy.gd` | Anticipación 0,45 s con esfera y signo «!» de aviso; ficha de ataque máximo 2; separación 1,4 m; amago al no recibir ficha | Sin aviso, el golpe enemigo era impredecible; sin fichas, los cuatro chancas golpeaban a la vez. El aviso se ve y suena antes del impacto; la esfera sola se perdía con el enemigo de espaldas |
| 2026-11-16 | `ambush_enemy.gd` | El cuerpo derribado desactiva colisión | El bot de la arena descubrió que el cadáver seguía bloqueando el rayo: después de matar al primero, los demás quedaban detrás y el combate se atascaba |
| 2026-11-16 | `paso.gd` y `ciudad.gd` | `_attack` solo escribe `_pending_damage` si el golpe arrancó | Pulsar ataque durante un golpe dejaba el daño pendiente en 0 y la ventana activa no conectaba. Ahora el golpe en curso conserva su daño |

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
