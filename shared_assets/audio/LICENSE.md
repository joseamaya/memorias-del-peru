# Licencias de audio

Toda pieza de `shared_assets/audio/` se registra aquí con autor, origen, licencia y fecha de descarga. El proyecto exige licencia compatible con uso comercial y sin addons ([AGENTS.md](../../AGENTS.md) §3).

| Archivo | Uso | Autor | Origen | Licencia | Añadido |
|---|---|---|---|---|---|
| `ambiente_viento_andes.ogg` | Ambiente de la llacta (bucle de 90 s) | felix.blume | Freesound n.º 156414, «Wind blowing into some cactus spine, on the top of the mountain, in the desert of Atacama (Chile)»: https://freesound.org/people/felix.blume/sounds/156414/ | CC0 1.0 | 2026-11-11 |
| `pututu_caracola.wav` | Interacción del pututu | Ohrwurm | Freesound n.º 64830, «Snailhorn.wav»: https://freesound.org/people/Ohrwurm/sounds/64830/ | CC0 1.0 | 2026-11-11 |
| `pasos_tierra_01.wav`, `pasos_tierra_02.wav`, `pasos_tierra_03.wav` | Pasos del jugador en tierra | PotatokingXII | Freesound n.º 352870, «Footsteps Dirt Gravel»: https://freesound.org/people/PotatokingXII/sounds/352870/ | CC0 1.0 | 2026-11-11 |
| `pasos_piedra_01.wav`, `pasos_piedra_02.wav`, `pasos_piedra_03.wav` | Pasos del jugador en las terrazas | Fission9 | Freesound n.º 521590, «Hiking Boot Footsteps on Stone»: https://freesound.org/people/Fission9/sounds/521590/ | CC0 1.0 | 2026-11-11 |
| `murmullo_plaza.wav` | Murmullo de la plaza durante el evento (bucle de 13,5 s) | craigsmith | Freesound n.º 480808, «R16-17-Men Murmuring.wav»: https://freesound.org/people/craigsmith/sounds/480808/ | CC0 1.0 | 2026-11-11 |
| `quero_bebida.wav` | Interacción del quero | OwlStorm | Freesound n.º 320139, «Drink Sip and Swallow»: https://freesound.org/people/OwlStorm/sounds/320139/ | CC0 1.0 | 2026-11-11 |
| `ofrenda_grano.wav` | Interacción de la ofrenda | lucasfuchs | Freesound n.º 556974, «Pouring grain or seeds»: https://freesound.org/people/lucasfuchs/sounds/556974/ | CC0 1.0 | 2026-11-11 |
| `telar_golpe.wav` | Golpe del batán de la tejedora en el telar (3D, ADR-0015) | Autoría propia del proyecto | Síntesis con Python y NumPy: golpe sordo de 95–245 Hz con caída de tono, ruido filtrado en dos resonancias de madera (820 y 1450 Hz) y un segundo golpe más débil a 75 ms | Propia | 2026-11-12 |
| `agua_arroyo.wav` | Arroyo del paso (bucle de 10 s) | Autoría propia del proyecto | Síntesis con Python/NumPy (`tools/synthesize_audio.py`): ruido de banda 350–3200 Hz con modulaciones lentas y rumor grave, fundido cruzado de 0,5 s | Propia | 2026-11-14 |
| `fuego_campamento.wav` | Fuego del campamento (bucle de 10 s) | Autoría propia del proyecto | Síntesis con Python/NumPy: rumor grave, chasquidos de banda 800–6000 Hz y golpes cortos, fundido cruzado de 0,5 s | Propia | 2026-11-14 |
| `tambor_defensa.wav` | Tambor de la emboscada y la defensa (bucle de 8 s) | Autoría propia del proyecto | Síntesis con Python/NumPy: golpes graves de 95–120 Hz con caída de tono y tinya de 240 Hz | Propia | 2026-11-14 |
| `honda_zumbido.wav` | Zumbido de la honda al atacar | Autoría propia del proyecto | Síntesis con Python/NumPy: ruido de banda 500–4000 Hz y silbido descendente de 1200 a 200 Hz | Propia | 2026-11-14 |
| `honda_impacto.wav` | Impacto de la honda | Autoría propia del proyecto | Síntesis con Python/NumPy: seno grave de 110 Hz con caída y ruido de ataque | Propia | 2026-11-14 |
| `golpe_porra.wav` | Golpe de la porra chanca | Autoría propia del proyecto | Síntesis con Python/NumPy: seno grave de 70 Hz con caída y ruido de ataque | Propia | 2026-11-14 |
| `respiracion.wav` | Respiración del jugador según el aliento | Autoría propia del proyecto | Síntesis con Python/NumPy (`tools/synthesize_audio.py`): ruido de banda 180–1400 Hz con dos envolventes, inhalación y exhalación | Propia | 2026-11-16 |
| `musica_intro_over_the_andes.ogg` | Música de la introducción (ADR-0029) | u_98673jp944 | Pixabay, «Over The Andes»: https://pixabay.com/music/main-title-over-the-andes-339710/. **Generada con IA** según la propia página | Pixabay Content License (uso comercial, sin atribución obligatoria; prohíbe redistribuirla sola) | 2026-11-12 |

Los originales se descargaron con la cuenta del responsable del proyecto el 2026-11-11 y **no se versionan**: son WAV de 48–96 kHz que pesan hasta 66 MB. Lo que entra en el juego es una versión procesada con ffmpeg y Python:

- Pasos: un paso por archivo; pasa-altos a 80 Hz y pasa-bajos a 9 kHz (para suavizar el golpe de bota). Cada paso se iguala por su ventana de 100 ms más fuerte, a unos −13 dB, como los pasos sintéticos anteriores; un recorte suave mantiene el pico por debajo de −1 dBFS.
- Pututu: primer soplido (1,25–5,6 s) con la cola desvanecida, normalizado a −18 dB RMS.
- Ofrenda: tramo 2,0–3,7 s del grano vertido. Quero: sorbo y trago completos, con compresión suave.
- Murmullo: sin el tintineo inicial; pasa-banda de 150 Hz a 3,5 kHz para alejarlo; bucle con fundido cruzado de 1,5 s.
- Ambiente: estéreo a 44,1 kHz; bucle de 90 s con fundido cruzado de 4 s; −34 dB RMS por canal (unos −31 dB en mono, el nivel del ambiente anterior).

Los sonidos de agua, fuego, tambor, honda y porra son de autoría propia y se
generan con `tools/synthesize_audio.py`; se versionan como WAV mono a 44,1 kHz.
El agua y el fuego se reproducen en bucle con fundido cruzado; el tambor, en
bucle de 8 s; los golpes son de un solo disparo. El agente no puede escucharlos:
la validación auditiva corresponde al responsable del proyecto.

`pasos_tierra_02.wav` sirve también, a 0,62 de velocidad, como la chaquitaclla que entra en la tierra en el trabajo del agricultor, y los tres pasos en tierra suenan además en 3D para los pasos de los personajes.

Sustituyen a los placeholders sintéticos anteriores (`pututu_propio.wav`, `ofrenda_tierra.wav` y las versiones sintéticas de pasos, quero y murmullo) y al ambiente `ambience_wind_birds.ogg` (PDSounds n.º 129, dominio público), que tenía aves no identificadas como andinas.

## Criterios

- Se prefieren obras propias, CC0 o de dominio público.
- Una licencia con atribución (CC BY) solo se admitiría como placeholder y exigiría la atribución en los créditos del juego, que esta fase no tiene; por eso se descartó el pututu de Wikimedia Commons (CC BY-SA) y hoy se usa la caracola CC0 de Freesound.
- No se usa material de licencia dudosa ni descargas que exijan cuenta sin permiso del responsable del proyecto.
- Cada archivo importado por Godot conserva su `.import` versionado.
- Las grabaciones de Freesound son **sustitutos declarados**: solo el viento tiene origen andino conocido (Atacama, Chile); del resto no consta el lugar, y la caracola es de tipo asiático porque no hay ningún pututu andino en CC0. Para la versión definitiva se prefieren grabaciones propias en la sierra.

## Música de la introducción

`musica_intro_over_the_andes.ogg` (40,3 s) es un montaje de «Over The Andes» (u_98673jp944, Pixabay; zampoñas, cuerdas y percusión, etiquetada como tema principal). La descargó el responsable del proyecto el 2026-11-12 desde su cuenta (MP3 de 1:52, 256 kb/s, SHA-256 `f7a12e6e…`), y el original **no se versiona**.

- **Forma de la pieza:** secciones de 16 s, con compases fuertes en 16,01, 32,0, 48,03 y 104,01 s (medidos con su envolvente de ataques).
- **Montaje:** de 0 a 32,0 s (entrada de zampoñas, crecimiento y primera sección completa), enlazado en el compás con el final real, de 104,0 a 112,3 s, mediante un fundido cruzado de 60 ms. Se añadió un fundido final de 1,5 s, se igualó a −20 dB RMS (pico a −4,5 dBFS) y se guardó en Ogg Vorbis.
- **Licencia:** Pixabay Content License (https://pixabay.com/service/license-summary/). Permite el uso comercial y la modificación sin atribución; no permite venderla ni distribuirla sola. Se acredita igualmente: «Music by u_98673jp944 from Pixabay».
- **Contenido generado con IA:** la página de Pixabay la marca así. Hay que declararla en las encuestas de las tiendas que lo pidan (por ejemplo, el apartado de IA de Steam).
- Sustituye a `musica_intro_atlas_bolivia.ogg` (ADR-0028), una música de procesión sin forma de apertura, y esa a su vez a `musica_intro_quena.ogg` (ADR-0027).
