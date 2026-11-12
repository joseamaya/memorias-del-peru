# ADR-0029 — Tema de apertura de la introducción

- Estado: Aceptado (elegido por el responsable del proyecto el 2026-11-12)
- Fecha: 2026-11-12
- Sustituye en parte: [ADR-0028](0028-musica-epica-de-la-introduccion.md) (la pieza; la autorización del contenido generado con IA y el anacronismo declarado siguen vigentes y se amplían a esta pieza)

## Contexto

Al escuchar «Atlas • Bolivia» (ADR-0028), el responsable del proyecto dijo que estaba bien, pero que no era música de introducción. Es música de procesión: mantiene la misma intensidad durante los 3 minutos, sin entrada ni final.

Se buscaron piezas andinas pensadas como tema de apertura. En Pixabay, la única etiquetada como tema principal (*Main Title*) y como construcción de tensión (*Build Up Scenes*) es «Over The Andes» (u_98673jp944). Es épica, con zampoñas, cuerdas y percusión, y también está generada con IA. El responsable del proyecto la eligió.

## Decisión

- **La música de la introducción** es un montaje de 40,3 s de «Over The Andes»: `shared_assets/audio/musica_intro_over_the_andes.ogg`.
  - **Forma medida en la pieza:** secciones de 16 s; entrada de zampoñas sin bajo de 0 a 8 s; crecimiento de 8 a 14 s; primera sección completa de 16 a 32 s; final con cadencia de 104 a 112 s.
  - **Montaje:** de 0 a 32,0 s, enlazado con el final real (de 104,0 s al final) en el compás fuerte, con un fundido cruzado de 60 ms.
- **Encaje con las tarjetas:**
  - la entrada suave suena sobre la nota histórica y los Andes;
  - el clímax, sobre el mapa y la bajada a la llacta;
  - el final, cuando el jugador toma el control.
- **En el juego no cambia nada más:** suena durante las tarjetas y se funde en 3 s al tomar el control.
- **Autorización:** la de ADR-0028 para contenido generado con IA se amplía a esta pieza, y sigue declarada como anacronismo en docs/07 §4.
- **Pieza anterior:** se retira «Atlas • Bolivia» del repositorio.

## Consecuencias

- **Pruebas:** las mismas; solo cambia el archivo.
- **Tiendas:** declarar la pieza como contenido generado con IA donde se pida. Está registrada en `shared_assets/audio/LICENSE.md`.
- **No verificado por el agente:** el agente no puede escuchar el montaje. Se comprobó que el empalme no produce un salto de señal mayor que los del resto de la pieza, y la curva de intensidad: −28 dB en la entrada, −20,5 dB en el clímax y caída al final. Falta que el responsable del proyecto lo escuche en el juego.
- **Alcance v4.11** (§6.3).
