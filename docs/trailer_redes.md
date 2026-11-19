# Tráiler de redes — *Pachacútec: El despertar del Sol*

Piezas de promoción para redes sociales de la campaña *Pachacútec — El despertar
del Sol*. No son material del juego ni sustituyen a la partida grabada: son un
montaje de 35 s y otro de 15 s pensados para publicarse.

Las piezas finales viven en `build/trailer/`, que está ignorado por Git. Este
documento, los guiones y las herramientas sí se versionan.

## Piezas

| Archivo | Formato | Duración | Uso |
|---|---|---|---|
| `memorias_del_peru_pachacutec_9x16_35s.mp4` | 1080 × 1920 | 35 s | Reels, TikTok, Shorts (prioritario) |
| `memorias_del_peru_pachacutec_16x9_35s.mp4` | 1920 × 1080 | 35 s | YouTube, web, tienda |
| `memorias_del_peru_pachacutec_9x16_15s.mp4` | 1080 × 1920 | 15 s | Anuncio corto vertical |
| `memorias_del_peru_pachacutec_16x9_15s.mp4` | 1920 × 1080 | 15 s | Anuncio corto horizontal |
| `img/cover_9x16.png` | 1080 × 1920 | — | Portada vertical |
| `img/cover_16x9.png` | 1920 × 1080 | — | Miniatura horizontal |
| `subs/trailer_35s_es.srt`, `subs/trailer_35s_en.srt` | — | 35 s | Subtítulos sueltos |
| `subs/trailer_15s_es.srt`, `subs/trailer_15s_en.srt` | — | 15 s | Subtítulos sueltos |

Especificaciones de vídeo: H.264, 30 fps, `yuv420p`, `+faststart`. Audio: AAC
estéreo a 48 kHz y 192 kb/s, normalizado a −14 LUFS con pico bajo −1 dBTP.

### Verificación

Comprobado el 2026-11-19 con `ffprobe` y fotogramas extraídos de los cuatro
másteres:

| Pieza | Resolución | Duración | Tamaño | Sonoridad |
|---|---|---|---|---|
| 9:16 · 35 s | 1080 × 1920 | 35,000 s | 27,7 MB | −13,9 LUFS |
| 16:9 · 35 s | 1920 × 1080 | 35,000 s | 13,6 MB | −13,9 LUFS |
| 9:16 · 15 s | 1080 × 1920 | 15,000 s | 10,2 MB | −13,7 LUFS |
| 16:9 · 15 s | 1920 × 1080 | 15,000 s | 6,3 MB | −13,7 LUFS |

- 30 fps constantes, H.264 `yuv420p`, audio AAC estéreo a 48 kHz.
- Sin HUD ni manos en primera persona: se ocultan en la captura y la honda se
  graba con la cámara del jugador sin enseñar el brazo.
- Actos I–III y apunte de IV–V con la misma casa en dos estados; no se revela
  el desenlace.
- Rótulos españoles y subtítulos ingleses revisados en los cuatro formatos.
- Las capturas intermedias quedan en `build/trailer/frames_v` y `frames_h`
  (unos 350 MB cada una); se pueden borrar después de montar.

## Guion

Los rótulos van en español; los subtítulos en inglés van quemados abajo para que
la pieza se entienda sin sonido y sin depender de los subtítulos automáticos de
cada red.

| Tiempo | Plano | Texto en pantalla | Subtítulo |
|---|---|---|---|
| 0,6–3,6 | Mirador: banco, parapeto y valle | SIGLO XV. LOS ANDES. / EL CUSCO AÚN NO ES UN IMPERIO. | 15th century. The Andes. / Cusco is not yet an empire. |
| 4,2–6,8 | Plaza, caminos y casas | UNA LLACTA. UNA NOTICIA. / UNA DECISIÓN. | A llacta. News. / A decision. |
| 7,2–9,2 | Casa de Rumi y familia | TU HERMANO QUIERE IR. | Your brother wants to go. |
| 9,7–12,8 | Honda y blanco de paja | APRENDE LA HONDA. | Learn the sling. |
| 13,2–14,8 | Manantial y acequia | LA LLACTA TE NECESITA. | The llacta needs you. |
| 15,2–17,2 | La duda, junto al fuego | NO TODOS QUIEREN RESISTIR. | Not all want to resist. |
| 17,7–19,8 | El mensajero | LOS CHANCAS VIENEN. | The Chancas are coming. |
| 20,2–22,3 | La asamblea | LA RESPUESTA ESTÁ EN TUS MANOS. | The answer is in your hands. |
| 22,7–28,6 | Emboscada del paso y defensa del Cusco | DEFIENDE EL CUSCO. | Defend Cusco. |
| 29,2–31,9 | La casa ausente y la casa reparada | CADA DECISIÓN DEJA UNA CASA EN PIE. | Every decision leaves a house standing. |
| 32,0–35,0 | Tarjeta final | MEMORIAS DEL PERÚ / PACHACÚTEC — EL DESPERTAR DEL SOL / PRÓXIMAMENTE / COMING SOON | — |

El corte de 15 s conserva mirador, plaza, honda, hermano, mensajero, emboscada,
defensa y el antes/después de la casa, con la tarjeta final.

## Créditos y licencias

- **Música:** «Over The Andes», de `u_98673jp944` en Pixabay.
  Crédito: «Music by u_98673jp944 from Pixabay». Licencia Pixabay Content
  License (uso comercial, sin atribución obligatoria; no permite redistribuir
  la música sola). Ficha completa en
  [`shared_assets/audio/LICENSE.md`](../shared_assets/audio/LICENSE.md).
- **Contenido generado con IA:** la página de Pixabay marca la música como
  generada con IA. Debe declararse en las tiendas y formularios que lo pidan.
- **Efectos:** viento, agua, honda, tambor, pututu, porra, fuego y murmullo del
  proyecto, sintetizados o procesados para el juego; ver el mismo `LICENSE.md`.
- **Imágenes:** capturas del propio juego, sin assets de pago.
- **Texto y montaje:** autoría del proyecto.

La pieza es una **reconstrucción histórica con licencia narrativa**. No presenta
como hecho documentado ningún diálogo, decisión ni escena inventada. La tarjeta
final lo dice: «Reconstrucción histórica · A work of historical fiction».

## Publicación

Copy sugerido en español:

> El Cusco aún no es un imperio. Un mensajero cruza el valle con una noticia que
> lo cambia todo.
>
> MEMORIAS DEL PERÚ — Pachacútec: El despertar del Sol. Próximamente.
>
> Reconstrucción histórica y ficción. Música: «Over The Andes» de u_98673jp944
> (Pixabay), generada con IA.

Copy sugerido en inglés:

> Cusco is not yet an empire. A messenger crosses the valley with news that
> changes everything.
>
> MEMORIAS DEL PERÚ — Pachacútec: The Awakening of the Sun. Coming soon.
>
> Historical reconstruction and fiction. Music: “Over The Andes” by
> u_98673jp944 (Pixabay), AI-generated.

Etiquetas: `#MemoriasDelPerú` `#Pachacútec` `#HistoriaDelPerú` `#Perú`
`#IndieGame` `#VideojuegoHistórico`.

## Cómo se regenera

Requiere Godot 4.7, ffmpeg con libx264 y Python 3 con Pillow.

```bash
# 1. Capturas: 960 fotogramas por formato (32 s de juego) en build/trailer/.
godot --path . --resolution 1280x720 res://tests/scenes/trailer_capture.tscn \
  -- --out=build/trailer/frames_v --size=1080x1920
godot --path . --resolution 1280x720 res://tests/scenes/trailer_capture.tscn \
  -- --out=build/trailer/frames_h --size=1920x1080

# 2. Montaje completo: tarjetas, rótulos, etalonaje, música y másteres.
tools/trailer_build.sh
```

`tools/trailer_post.py` genera las tarjetas, los guiones de filtros de ffmpeg y
los `.srt`. `tools/trailer_audio.sh` mezcla la música y los efectos.
`tools/trailer_probe.gd` y `tools/trailer_probe_acts.gd` sirven para probar
encuadres sin grabar la secuencia completa.

## Decisiones de montaje

- **Cámara libre para los planos generales; cámara del jugador para la honda.**
  Así se ve el gesto de apuntar sin enseñar la mano en primera persona, que
  sigue pendiente de revisión.
- **HUD oculto y manos ocultas** en todos los planos.
- **Actos I–III completos y apunte de IV–V:** la casa con el paño de ausencia y
  la misma casa reparada, sin revelar el desenlace.
- **Sin voz en off:** el juego no tiene voces; el peso lo llevan los rótulos, la
  música y los efectos.
- **16:9 y 9:16 se graban por separado**, no se recorta uno del otro: en vertical
  los encuadres se cierran y el horizonte se mantiene en el tercio central.
