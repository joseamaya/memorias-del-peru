# Guion del facilitador — sesiones de prueba del vertical slice

- Estado: **Listo para el piloto** (2026-11-11)
- Aplica: [alcance_vertical_slice.md](alcance_vertical_slice.md) §9 (protocolo aprobado). Si este guion y el alcance difieren, prevalece el alcance.
- Registro de cada sesión: [plantilla_sesion.md](plantilla_sesion.md)

## 1. Piloto y sesiones oficiales

| | Piloto | Oficial |
|---|---|---|
| Personas | 1–2 | 6 (P1–P6) |
| Versión del juego | El slice en el commit anotado (alcance v4.15: personajes con esqueleto y animación, reconstrucción R) | La misma versión, con los cambios que salgan del piloto |
| ¿Cuenta para la métrica 5 y la duración? | **No** | Sí |
| Código | PIL-1, PIL-2 | P1–P6 |

Las personas del piloto quedan excluidas de las sesiones oficiales: ya conocen la historia.

El piloto responde a dos preguntas antes de las sesiones oficiales:

1. **¿Se entiende la historia?** Preguntas 1 y 2 del cuestionario.
2. **¿Se lee la espera como un fallo?** El mensajero sale a los 75 s si la persona está en la plaza, y si no la espera, como tarde hasta los 150 s (ADR-0013; antes, 4 min y luego 2) ([ADR-0009](../../../docs/adr/0009-duracion-y-disparo-del-slice.md)). Hay que observar si la persona cree que el juego se ha quedado parado, lo pregunta o abandona.

## 2. Medición de la duración

Definida en el alcance §9.2 (v3.1, aprobada el 2026-11-11). Resumen:

- **Inicio:** aparece la primera tarjeta de la introducción. Deja el juego en la pantalla de título mientras explicas los controles; la persona pulsa Comenzar (alcance v4.6, ADR-0024). Anota también cuándo termina la introducción. No leas ni comentes las tarjetas: la persona las lee sola.
- **Fin:** lo primero que ocurra de lo siguiente:
  - La persona dice que ha terminado.
  - Aparece la tarjeta «Fin del fragmento», unos 8 s después de «La llacta queda en silencio…» (alcance v4.8, ADR-0026; antes, 60 s).
  - Se llega a 12 min.
- Se anota también el momento del cierre, para separar el tiempo de la historia del tiempo de exploración libre.

Con el registro de sesión (§3.2), estos momentos quedan además con hora en el archivo del registro. Si el cronómetro y el registro difieren, prevalece el registro y se anota la diferencia.

## 3. Preparación (10 min antes)

- [ ] Equipo de referencia con auriculares. Volumen al 50 % antes de empezar; la persona puede ajustarlo.
- [ ] Repositorio en un commit conocido; anotar su hash en la hoja.
- [ ] Validación limpia: `godot --headless --path . --import` y `godot --headless --path . --script res://tests/run_tests.gd` sin fallos.
- [ ] Cerrar el resto de ventanas. Abrir el juego desde un terminal visible al facilitador (no a la persona) para ver la consola, con el registro de la sesión: `godot --path . -- --session <código>`.
- [ ] Anotar la ruta del registro que imprime el arranque (`[SESION]`). El reloj del mensajero espera a que termine la introducción (v4.5), así que no hay que reiniciar si la persona tarda en pulsar Comenzar.
- [ ] Cronómetro y la hoja de [plantilla_sesion.md](plantilla_sesion.md), impresa o en otra pantalla.

## 3.1 Invitación

Por invitación directa y fuera del círculo del equipo (alcance §9.1). El mensaje **no** menciona la historia, los incas, los chancas ni el tema histórico, para no sesgar las respuestas ni atraer solo a quien ya le interesa. Texto orientativo:

> «Hola, estoy probando un videojuego corto en desarrollo y busco personas que no lo hayan visto para jugarlo unos 10 minutos y responder cinco preguntas. Son unos 20 minutos en total, en [lugar], el [día] a la [hora]. No hace falta experiencia con videojuegos. ¿Te animas?»

Para el piloto basta con 1–2 personas. Anotar aparte, fuera del repositorio, quién es cada código; en el repositorio solo figura el código (PIL-1, PIL-2).

## 3.2 Registro de sesión

El argumento `--session <código>` escribe `user://sesiones/<código>.log` (en Linux, `~/.local/share/godot/app_userdata/Memorias del Perú/sesiones/<código>.log`) con una línea por marca y el tiempo transcurrido desde el arranque:

| Marca | Significado |
|---|---|
| `campaign_start` | Se pulsó Comenzar en el título |
| `intro_card` | Aparece una tarjeta de la introducción |
| `control_taken` | Termina la introducción y la persona toma el control |
| `profile` | Perfil gráfico fijado (Bajo) |
| `subtitle` | Subtítulo mostrado, por su clave (`PCH_NARR_NEWS_1`, `PCH_NARR_CLOSING_1`, etc.) |
| `phase` | Fase del evento: `arrival`, `message`, `call`, `departure`, `done` |
| `pututu` | Suena el pututu, con `jugador` o `curaca` como detalle |
| `end_card` | Aparece la tarjeta «Fin del fragmento» |
| `console` | Error, advertencia o error de script del motor |
| `session_end` | Se cierra el juego |

El registro fija el perfil Bajo y desactiva F2 durante la sesión. Al terminar, la hoja se rellena con estos tiempos y se comprueba que no haya ninguna línea `console` (§9.6).

## 4. Texto para leer

**Consentimiento (2 min).** Leer tal cual:

> «Gracias por venir. Vas a probar un fragmento corto de un juego en desarrollo. No evaluamos cómo juegas, sino si el juego se entiende. Voy a cronometrar y a tomar notas sin tu nombre; no grabamos vídeo ni audio. Puedes parar cuando quieras sin dar explicaciones. Al final te haré cinco preguntas abiertas. ¿Te parece bien?»

Si la persona no acepta, la sesión no se hace y no se registra.

**Controles (2 min).** Mostrar la tabla de controles del [README](../../../README.md) y decir solo:

> «Te mueves con W, A, S y D, miras con el ratón, corres manteniendo Shift izquierdo e interactúas con E cuando aparece un texto en el centro. Escape pausa el juego. Juega como quieras; cuando creas que has terminado, dímelo.»

**No** se menciona la historia, el mensajero, los chancas, el pututu ni ningún objetivo.

## 5. Durante el juego

- Silencio. Solo se responden dudas de **controles**; ante cualquier otra, decir: «Haz lo que te parezca».
- Si hay un fallo técnico (cuelgue, caída al vacío, imposibilidad de seguir), anotar la hora y lo ocurrido, y no ayudar con el contenido. Si la sesión no puede continuar, se marca como **incidencia** y no puntúa.
- Anotar con la hora del cronómetro:

| Momento | Qué observar |
|---|---|
| Primeros 30 s | ¿Lee el subtítulo de apertura? ¿Hacia dónde va? |
| Exploración | Ruta (viviendas oeste, terrazas, mirador), interacciones (quero, ofrenda) |
| Espera | Señales de desconcierto: da vueltas sin rumbo, pregunta si «pasa algo», mira al facilitador, intenta salir |
| Llegada del mensajero | ¿Dónde está? ¿Lo ve llegar? ¿Lee la noticia (se detiene, se acerca)? |
| Llamada | ¿Toca el pututu o lo hace el curaca a los 60 s? |
| Cierre | ¿Mira partir al grupo? ¿Qué hace después? |
| Consola | Cualquier línea `ERROR` o `SCRIPT ERROR` (§9.6 exige cero) |

El registro anexa esas líneas con la marca `console`; la consola visible sigue siendo la referencia principal.

## 6. Cuestionario (5 min)

Leer las preguntas de §9.3 **en ese orden**, sin reformularlas ni dar pistas, y anotar la respuesta **literal**. Si la persona pide aclaración, repetir la pregunta tal cual. Las preguntas están en la hoja de registro; si cambian en el alcance, se actualiza la hoja.

Al terminar, agradecer y pedir que no comente la historia con otras personas que vayan a participar.

## 7. Después de la sesión

1. Pasar las notas a una copia de [plantilla_sesion.md](plantilla_sesion.md) en `documentation/sesiones/` con el nombre `<código>.md` (por ejemplo `PIL-1.md`) y copiar en ella los tiempos del registro `user://sesiones/<código>.log`.
2. Dos evaluadores puntúan las preguntas 1 y 2 por separado, sin verse, con el criterio de §9.4. Si discrepan, decide una tercera persona; si sigue sin acuerdo, la sesión no se supera.
3. Toda incidencia técnica se reproduce y se corrige antes de la siguiente sesión (§9.6).

## 8. Qué decidir tras el piloto

**PIL-1 (2026-11-11):** textos demasiado rápidos, ninguna orientación al inicio, lugar sin identificar y aburrimiento en la espera. Se corrigió con [ADR-0012](../../../docs/adr/0012-ajustes-tras-el-primer-piloto.md) (alcance v3.4). Después, una revisión del slice llevó a [ADR-0013](../../../docs/adr/0013-ritmo-orientacion-y-cierre.md) (alcance v3.5): espera de 75 s, vecino que recibe, tarjeta de fin y piernas que se balancean. PIL-2 comprueba todas las correcciones con el commit nuevo.

| Si en el piloto… | Entonces |
|---|---|
| Alguien no supera la pregunta 1 o la 2 | Revisar los textos `PCH_NARR_*` (ADR-0006) antes de modelar assets |
| Alguien interpreta la espera como un fallo | Proponer un ADR que acorte `arrival_delay` o añada señales de la llegada (por ejemplo, un subtítulo intermedio) |
| No aparece ningún problema | Seguir con los assets; el piloto no sustituye a las seis sesiones oficiales |
