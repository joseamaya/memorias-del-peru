# Guion del facilitador — sesiones de prueba del vertical slice

- Estado: **Listo para el piloto** (2026-11-11)
- Aplica: [alcance_vertical_slice.md](alcance_vertical_slice.md) §9 (protocolo aprobado). Si este guion y el alcance difieren, prevalece el alcance.
- Registro de cada sesión: [plantilla_sesion.md](plantilla_sesion.md)

## 1. Piloto y sesiones oficiales

| | Piloto | Oficial |
|---|---|---|
| Personas | 1–2 | 6 (P1–P6) |
| Versión del juego | Bloqueo actual (cajas y cápsulas) | Slice con assets definitivos |
| ¿Cuenta para la métrica 5 y la duración? | **No** | Sí |
| Código | PIL-1, PIL-2 | P1–P6 |

Las personas del piloto quedan excluidas de las sesiones oficiales: ya conocen la historia.

El piloto responde a dos preguntas antes de invertir en assets:

1. **¿Se entiende la historia?** Preguntas 1 y 2 del cuestionario.
2. **¿Se lee la espera como un fallo?** El mensajero llega a los 4 minutos ([ADR-0009](../../../docs/adr/0009-duracion-y-disparo-del-slice.md)). Hay que observar si la persona cree que el juego se ha quedado parado, lo pregunta o abandona.

## 2. Medición de la duración

Definida en el alcance §9.2 (v3.1, aprobada el 2026-11-11). Resumen:

- **Inicio:** el primer movimiento de la persona tras la explicación de controles.
- **Fin:** lo primero que ocurra de lo siguiente:
  - La persona dice que ha terminado.
  - Pasan 60 s desde que el grupo sale de la plaza (el cierre «La llacta queda en silencio…»).
  - Se llega a 12 min.
- Se anota también el momento del cierre, para separar el tiempo de la historia del tiempo de exploración libre.

## 3. Preparación (10 min antes)

- [ ] Equipo de referencia con auriculares. Volumen al 50 % antes de empezar; la persona puede ajustarlo.
- [ ] Repositorio en un commit conocido; anotar su hash en la hoja.
- [ ] Validación limpia: `godot --headless --path . --import` y `godot --headless --path . --script res://tests/run_tests.gd` sin fallos.
- [ ] Cerrar el resto de ventanas. Abrir el juego desde un terminal visible al facilitador (no a la persona) para ver la consola: `godot --path .`
- [ ] Partida recién abierta: el reloj del mensajero empieza al cargar el mundo. Si la persona tarda en empezar, cerrar y volver a abrir justo antes.
- [ ] Cronómetro y la hoja de [plantilla_sesion.md](plantilla_sesion.md), impresa o en otra pantalla.

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

## 6. Cuestionario (5 min)

Leer las preguntas de §9.3 **en ese orden**, sin reformularlas ni dar pistas, y anotar la respuesta **literal**. Si la persona pide aclaración, repetir la pregunta tal cual. Las preguntas están en la hoja de registro; si cambian en el alcance, se actualiza la hoja.

Al terminar, agradecer y pedir que no comente la historia con otras personas que vayan a participar.

## 7. Después de la sesión

1. Pasar las notas a una copia de [plantilla_sesion.md](plantilla_sesion.md) en `documentation/sesiones/` con el nombre `<código>.md` (por ejemplo `PIL-1.md`).
2. Dos evaluadores puntúan las preguntas 1 y 2 por separado, sin verse, con el criterio de §9.4. Si discrepan, decide una tercera persona; si sigue sin acuerdo, la sesión no se supera.
3. Toda incidencia técnica se reproduce y se corrige antes de la siguiente sesión (§9.6).

## 8. Qué decidir tras el piloto

| Si en el piloto… | Entonces |
|---|---|
| Alguien no supera la pregunta 1 o la 2 | Revisar los textos `PCH_NARR_*` (ADR-0006) antes de modelar assets |
| Alguien interpreta la espera como un fallo | Proponer un ADR que acorte `arrival_delay` o añada señales de la llegada (por ejemplo, un subtítulo intermedio) |
| No aparece ningún problema | Seguir con los assets; el piloto no sustituye a las seis sesiones oficiales |
