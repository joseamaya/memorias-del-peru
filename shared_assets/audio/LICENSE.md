# Licencias de audio

Toda pieza de `shared_assets/audio/` se registra aquí con autor, origen, licencia y fecha de descarga. El proyecto exige licencia compatible con uso comercial y sin addons ([AGENTS.md](../../AGENTS.md) §3).

| Archivo | Uso | Autor | Origen | Licencia | Añadido |
|---|---|---|---|---|---|
| `quero_bebida.wav` | Interacción del quero | Equipo del proyecto | Propia (placeholder) | Propia | Fase 2 |
| `ofrenda_tierra.wav` | Interacción de la ofrenda | Equipo del proyecto | Propia, síntesis con Python | Propia | 2026-11-10 |
| `pututu_propio.wav` | Interacción del pututu | Equipo del proyecto | Propia, síntesis con Python | Propia | 2026-11-10 |
| `pasos_tierra_01.wav`, `pasos_tierra_02.wav`, `pasos_tierra_03.wav` | Pasos del jugador en tierra | Equipo del proyecto | Propia, síntesis con Python (ruido con filtro paso bajo y golpe grave) | Propia | 2026-11-10 |
| `ambience_wind_birds.ogg` | Ambiente de la llacta | ezwa | PDSounds n.º 129, vía Wikimedia Commons: `File:Gentle breeze and birds singing.ogg` | Dominio público | 2026-11-10 |

## Criterios

- Se prefieren obras propias, CC0 o de dominio público.
- Una licencia con atribución (CC BY) solo se admitiría como placeholder y exigiría la atribución en los créditos del juego, que esta fase no tiene; por eso se descartó el pututu de Wikimedia Commons y se sintetizó uno propio.
- No se usa material de licencia dudosa ni descargas que exijan cuenta sin permiso del responsable del proyecto.
- Cada archivo importado por Godot conserva su `.import` versionado.
- Los sonidos sintetizados son **placeholders declarados**: se sustituirán por grabaciones propias en la fase de assets definitivos.
