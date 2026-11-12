# ADR-0027 — Música de la introducción

- Estado: Reemplazado por [ADR-0028](0028-musica-epica-de-la-introduccion.md)
- Fecha: 2026-11-12
- Amplía: [ADR-0023](0023-introduccion-del-slice.md) y [ADR-0025](0025-imagenes-de-la-introduccion.md)

## Contexto

El responsable del proyecto pidió música andina libre para la introducción. Se buscó el 2026-11-12:

- **En CC0 no hay piezas completas**, solo muestras cortas en Freesound: notas sueltas y bucles de quena, notas de zampoña y un bucle de charango y bombo.
- **Las bibliotecas «libres de derechos»** (TunePocket, Motion Array, Audio Network) son comerciales, y casi todas sus piezas llevan charango.
- **Anacronismo:** el charango, la guitarra, el violín y el arpa llegaron con los españoles o derivan de sus instrumentos. Para el siglo XV solo encajan instrumentos prehispánicos: flautas de caña o hueso, zampoñas, tambores, sonajas y caracolas (docs/07 §4).
- **Licencias CC BY:** exigirían créditos en el juego, y `shared_assets/audio/LICENSE.md` solo las admite como sustituto provisional.

De las tres muestras CC0 elegidas, solo se descargó «quena scale.wav» (MarleneAyni, Freesound 569392). Basta: son 15 notas sueltas de una quena de caña, en dos octavas.

## Opciones consideradas

1. **Pieza completa CC BY.** Rechazada: necesita créditos y es difícil encontrar una sin instrumentos posteriores a 1532.
2. **Síntesis completa.** Rechazada: una flauta sintetizada suena artificial.
3. **Composición propia con las notas de la quena** y un bordón y una tinya sintetizados. Aceptada.

## Decisión

- **Pieza:** `shared_assets/audio/musica_intro_quena.ogg`, de 44 s. Cinco frases lentas sobre la pentatónica de mi (mi, sol, la, si, re), un bordón grave y, entre los 12 y los 34 s, una tinya suave.
- **Reproducibilidad:** la genera `shared_assets/audio/componer_musica_intro.py`, que se versiona. La grabación original no se versiona (`LICENSE.md` guarda su origen y su huella).
- **En el juego:** suena desde la primera tarjeta, con el reproductor a −6 dB y el viento de fondo. Al tomar el control se funde en 3 s y se detiene, de modo que el juego sigue solo con el viento. Si la introducción se salta con `E`, se funde igual.
- **Clasificación:** licencia narrativa (N). Usa instrumentos de tipo prehispánico y una escala pentatónica, pero la quena moderna está afinada en escala occidental y la pieza no reconstruye ninguna música concreta del siglo XV. Queda declarado en docs/07 §4.

## Consecuencias

- **Pruebas:** `test_intro_holds_event` comprueba que la música suena durante las tarjetas, se funde y se detiene.
- **No verificado:** nadie ha escuchado la pieza en el juego. Se comprobó con su espectrograma (frases, bordón y tinya en su sitio, sin saturación ni chasquidos) y con su nivel (de −23 a −25 dB RMS, pico a −7,8 dBFS). El responsable del proyecto debe escucharla y decir si el carácter y el volumen le convencen.
- **Pendiente si se quiere más:** una zampoña (siku) real como bordón, si se encuentra en CC0.
- **Alcance v4.9** (§6.3).
