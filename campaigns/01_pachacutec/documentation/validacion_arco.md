# Validación de autor — arco completo

Protocolo para la pasada que cierra los dos criterios de la Fase 8 que siguen
abiertos: **duración de 40–50 min** y **comprensión, primera interacción y
cierre sin errores**. Sustituye al protocolo del vertical slice
([autovalidación 2026-11-13](sesiones/autovalidacion-2026-11-13.md)), que medía
solo el acto I.

## 1. Antes de jugar

```bash
godot --path . -- --session ARCO-1
```

El registro se escribe en `user://sesiones/ARCO-1.log`. No hace falta
cronómetro: cada marca lleva el tiempo transcurrido desde el arranque.

| Marca | Qué mide |
|---|---|
| `campaign_start` | Fin de la introducción y entrega del control |
| `task` | Cada encargo del acto I, cuando se acepta |
| `phase` | Fases del evento del mensajero |
| `pututu` | La llamada, y si la tocó el jugador |
| `end_card` | Cierre del acto I |
| `act` | Entrada a `paso` y a `cusco` |
| `ambush_start` / `ambush_end` | Emboscada: enfoque y enemigos vivos al cerrar |
| `flag` | Cada decisión guardada (`descanso`, `herido_salvado`, `maiz_guardado`, `scout_spared`) |
| `recruit` | Cada grupo del Cusco, con `si`/`no` |
| `defense_start` / `defense_end` | Defensa: aliados y salud final |

Condiciones: perfil Medio (el de por defecto), sin ayudas externas, una sola
pasada por registro. Se anota la carga de la máquina si es alta.

## 2. Qué observar mientras se juega

Momentos que hay que poder describir al terminar, sin mirar la pantalla de
objetivos:

1. **Por qué empieza todo.** Quién amenaza la llacta y quién pide la respuesta.
2. **Qué hace cada interacción del acto I.** No solo cuál se usó, sino para qué
   servía.
3. **Qué cambia en el paso.** Por qué el campamento importa y qué decide el
   jugador con el maíz y con el explorador herido.
4. **Por qué el Cusco recibe al jugador como lo recibe.** Qué recuerda la gente
   de lo que hizo antes.
5. **Cómo termina.** Qué se lleva el jugador de la defensa y del epílogo.

## 3. Cuestionario (responder por escrito antes de releer la bitácora)

1. ¿Quién amenaza al Cusco y por qué?
2. ¿Qué han hecho el inca y su heredero?
3. ¿Qué papel tiene el jugador en la defensa?
4. ¿Qué decidiste en el paso y qué consecuencia tuvo en el Cusco?
5. ¿Qué te quedó claro y qué no?

## 4. Tabla de la pasada

| Marca | ARCO-1 | ARCO-2 | ARCO-3 |
|---|---|---|---|
| Perfil | Medio | Medio | Medio |
| Fin de la introducción | | | |
| Primera interacción | | | |
| Acto I terminado | | | |
| Entrada al paso | | | |
| Emboscada resuelta | | | |
| Entrada al Cusco | | | |
| Defensa terminada | | | |
| **Duración total** | | | |
| Bloqueos | | | |
| Errores de consola | | | |

## 5. Umbrales

| Criterio | Umbral | Cómo se comprueba |
|---|---|---|
| Duración | **40–50 min** | Tiempo de la última marca de la pasada |
| Primera interacción | ≤ 20 s desde el control | Diferencia entre `campaign_start` y la primera marca de interacción |
| Comprensión | Preguntas 1 y 2 correctas; 4 responde al menos una consecuencia | Cuestionario |
| Cierre sin bloqueos | 0 bloqueos y 0 errores en el registro | El propio `.log` anexa los errores del motor |
| Cero errores de consola | Ninguna línea de error en el registro | El propio `.log` |

Si la duración queda por debajo de 40 min, hay dos salidas y hay que elegir una
antes de seguir puliendo: **añadir contenido** (más encargos, más decisiones,
más recorrido) o **rebasear el objetivo** y anotarlo en la bitácora, como se
hizo con la duración del vertical slice.

## 6. Registro de la sesión

Al terminar, guardar aquí `ARCO-1.md` con la tabla, el cuestionario respondido
y las observaciones de diagnóstico. El `.log` se copia junto a él.
