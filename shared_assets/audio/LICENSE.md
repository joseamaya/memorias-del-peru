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

Los originales se descargaron con la cuenta del responsable del proyecto el 2026-11-11 y **no se versionan**: son WAV de 48–96 kHz que pesan hasta 66 MB. Lo que entra en el juego es una versión procesada con ffmpeg y Python:

- Pasos: un paso por archivo; pasa-altos a 80 Hz y pasa-bajos a 9 kHz (para suavizar el golpe de bota). Cada paso se iguala por su ventana de 100 ms más fuerte, a unos −13 dB, como los pasos sintéticos anteriores; un recorte suave mantiene el pico por debajo de −1 dBFS.
- Pututu: primer soplido (1,25–5,6 s) con la cola desvanecida, normalizado a −18 dB RMS.
- Ofrenda: tramo 2,0–3,7 s del grano vertido. Quero: sorbo y trago completos, con compresión suave.
- Murmullo: sin el tintineo inicial; pasa-banda de 150 Hz a 3,5 kHz para alejarlo; bucle con fundido cruzado de 1,5 s.
- Ambiente: estéreo a 44,1 kHz; bucle de 90 s con fundido cruzado de 4 s; −34 dB RMS por canal (unos −31 dB en mono, el nivel del ambiente anterior).

`pasos_tierra_02.wav` sirve también, a 0,62 de velocidad, como la chaquitaclla que entra en la tierra en el trabajo del agricultor, y los tres pasos en tierra suenan además en 3D para los pasos de los personajes.

Sustituyen a los placeholders sintéticos anteriores (`pututu_propio.wav`, `ofrenda_tierra.wav` y las versiones sintéticas de pasos, quero y murmullo) y al ambiente `ambience_wind_birds.ogg` (PDSounds n.º 129, dominio público), que tenía aves no identificadas como andinas.

## Criterios

- Se prefieren obras propias, CC0 o de dominio público.
- Una licencia con atribución (CC BY) solo se admitiría como placeholder y exigiría la atribución en los créditos del juego, que esta fase no tiene; por eso se descartó el pututu de Wikimedia Commons (CC BY-SA) y hoy se usa la caracola CC0 de Freesound.
- No se usa material de licencia dudosa ni descargas que exijan cuenta sin permiso del responsable del proyecto.
- Cada archivo importado por Godot conserva su `.import` versionado.
- Las grabaciones de Freesound son **sustitutos declarados**: solo el viento tiene origen andino conocido (Atacama, Chile); del resto no consta el lugar, y la caracola es de tipo asiático porque no hay ningún pututu andino en CC0. Para la versión definitiva se prefieren grabaciones propias en la sierra.
