# ADR-0028 — Música épica de la introducción

- Estado: Aceptado (elegida por el responsable del proyecto el 2026-11-12)
- Fecha: 2026-11-12
- Sustituye: [ADR-0027](0027-musica-de-la-introduccion.md)
- Desviación declarada de: [docs/07](../07_convenciones_historicas.md) §4 (sonido) y de [ADR-0025](0025-imagenes-de-la-introduccion.md), que dejaba el contenido generado con IA para un ADR propio

## Contexto

La pieza de ADR-0027, compuesta con notas sueltas de quena, un bordón y una tinya, no le sonó andina al responsable del proyecto. Pidió música andina épica y dijo expresamente que no importaba que no existiera en el siglo XV.

Se buscó música andina épica de uso libre (2026-11-12):

- **Freesound:** solo fragmentos sueltos.
- **Bibliotecas comerciales** (TunePocket, Audio Network, Motion Array): de pago.
- **Pixabay:** las piezas andinas épicas que tiene están generadas con IA. La única hecha por personas que se encontró, «Andean Peru Acoustic», es tranquila, no épica.

El responsable del proyecto escuchó las candidatas y eligió «Atlas • Bolivia» (Vadim_Makes_Sound): música de sikuri con sikus, bombo y orquesta, que la página marca como enérgica, épica y generada con IA.

## Opciones consideradas

1. **Mantener la pieza de quena.** Rechazada por el responsable del proyecto.
2. **Pieza hecha por personas y con licencia libre.** Rechazada: no se encontró ninguna épica.
3. **Pieza de Pixabay generada con IA.** Aceptada por decisión expresa del responsable del proyecto.

## Decisión

- **La música de la introducción** son los primeros 44 s de «Atlas • Bolivia», con un fundido de salida de 5 s y un nivel de −20 dB RMS: `shared_assets/audio/musica_intro_atlas_bolivia.ogg`. El comportamiento en el juego no cambia: suena durante las tarjetas y se funde en 3 s al tomar el control.
- **Licencia:** Pixabay Content License. Permite el uso comercial y la modificación sin atribución; no permite distribuirla sola. Se acredita igualmente en `shared_assets/audio/LICENSE.md`.
- **Anacronismo declarado:** la música de sikuri, la orquesta y la estética épica no corresponden al siglo XV. Queda declarado en docs/07 §4 como decisión de diseño del responsable del proyecto, no como reconstrucción.
- **Contenido generado con IA:** este ADR autoriza solo esta pieza. Cualquier otro contenido generado con IA sigue necesitando su propio ADR, según ADR-0025.
- Se retiran del repositorio la pieza de quena y su generador (`musica_intro_quena.ogg`, `componer_musica_intro.py`).

## Consecuencias

- **Tiendas:** si el juego se publica en una tienda que pregunte por contenido generado con IA (por ejemplo, Steam), hay que declarar esta pieza. El registro de `LICENSE.md` sirve para responder.
- **Pruebas:** las mismas de ADR-0027. `test_intro_holds_event` comprueba que la música suena, se funde y se detiene; solo cambia el archivo.
- **No verificado por el agente:** el agente no puede escuchar la pieza. El responsable del proyecto la eligió tras escucharla, pero falta que valide en el juego el tramo elegido y su volumen frente al texto.
- **Alcance v4.10** (§6.3).
