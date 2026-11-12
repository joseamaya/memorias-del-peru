# ADR-0026 — Cierre corto y partida del mensajero

- Estado: Aceptado (aprobado por el responsable del proyecto el 2026-11-12)
- Fecha: 2026-11-12
- Sustituye en parte: [ADR-0013](0013-ritmo-orientacion-y-cierre.md) (retraso de la tarjeta de fin)

## Contexto

El responsable del proyecto jugó el slice completo el 2026-11-12 y señaló dos problemas:

1. **El mensajero se queda con los hombres después de dar la noticia.** Al sonar el pututu, el curaca y los dos hombres principales parten por el camino norte, pero el mensajero se queda de pie en la plaza, mirándolos, hasta el final. Parece que no sabe qué hacer.
2. **Después del pututu no se entiende qué hacer.** Tras el segundo subtítulo de cierre, el evento esperaba a que la comitiva llegara al camino norte (hasta 45 s), y la tarjeta de fin tardaba otros 50 s (ADR-0013). Pasaba más de un minuto y medio sin nada que hacer. Esos 50 s se habían elegido para que la tarjeta coincidiera con el fin de sesión del protocolo («60 s tras el cierre»).

## Opciones consideradas

1. **Mantener la exploración libre** y mostrar enseguida «R para volver a empezar · Esc para salir». Rechazada: deja la escena abierta, sin un final claro, justo después del momento más importante.
2. **Que el mensajero se quede descansando.** Rechazada: no hay animación de sentarse, y quedarse de pie es justo lo que se lee como un error.
3. **El mensajero parte con la comitiva, y el cierre es corto.** Aceptada.

## Decisión

- **Mensajero:** forma parte de la comitiva. Al sonar el pututu vuelve al Cusco con el curaca y los hombres principales, al paso del grupo (ya no corre). Es una reconstrucción (R) que se anota en PCH-011: las fuentes no dicen qué hizo quien llevó la noticia después de darla.
- **Cierre:**
  - el evento pasa a `DONE` 8 s después del segundo subtítulo de cierre («La llacta queda en silencio…»), aunque la comitiva siga a la vista;
  - la tarjeta «Fin del fragmento» se funde medio segundo después, mientras el grupo se aleja;
  - la comitiva sigue caminando y desaparece al llegar al camino norte, o a los 45 s como mucho.
- Desde el pututu hasta la tarjeta de fin pasan unos 20 s, frente a más de 90 s antes.

## Consecuencias

- **Protocolo de sesiones:** la sesión termina al aparecer la tarjeta de fin, no 60 s tras el subtítulo de cierre. Cambian el alcance §9.2, el guion del facilitador y la plantilla de sesión.
- **Duración:** la sesión dura unos 50 s menos. Si la mediana de las sesiones queda por debajo de 5 min, el alcance §10 ya prevé añadir contenido antes de la noticia, no alargar la espera.
- **Pruebas:**
  - `test_party_leaves_and_neighbors_stay`: el evento termina en el cierre corto con la comitiva aún a la vista, y después el mensajero y el curaca salen por el camino norte;
  - `test_hud_feedback::test_end_card`: la tarjeta llega en cuanto termina el evento.
- **Alcance v4.8** (§2.2, §5, §9.2 y §10).
