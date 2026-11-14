# ADR-0041 — Estado de campaña para las banderas entre actos
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

Las decisiones del acto II —cargar al herido, conservar el maíz, descansar en
el campamento— tienen que llegar al acto III. Hasta ahora cada escena tenía su
propio [DialogueRunner] y sus banderas morían al cambiar de escena. El acto I y
el acto II funcionan por separado; el arco completo, no.

El guardado completo sigue fuera de alcance. Lo que hace falta ahora es un
estado mínimo que sobreviva a las escenas y que después pueda serializarse.

## Opciones consideradas

1. **Pasar las banderas por parámetro** de escena en escena. Funciona para dos
   actos, pero obliga a conocer todos los flags en cada transición.
2. **Un autoload de Core** con banderas enteras, sin escritura en disco.
3. **Guardado completo ahora**. Es más de lo que la fase necesita y bloquea el
   arco por una decisión que aún no toca.

## Decisión

Se adopta **la opción 2**: `core/autoload/campaign_state.gd`, autoload
`CampaignState`.

- Guarda enteros por clave (`StringName`), con `set_flag`, `get_flag`,
  `has_flag`, `get_flags` y `clear`.
- Emite `flag_changed` para que la UI o los sistemas reaccionen.
- Las escenas escriben y leen; no hay dependencia de campaña en Core.
- No escribe en disco. `clear()` reinicia la campaña; el guardado completo
  seguirá siendo una fase aparte.
- El `DialogueRunner` puede seguir usando sus banderas locales; la escena que
  quiera persistirlas las copia a `CampaignState` al cambiar.

## Consecuencias

- El acto II puede dejar `herido_salvado`, `herido_dejado`, `maiz_guardado`,
  `maiz_abandonado`, `descanso` y `coca_compartida` para el acto III.
- El futuro guardado completo solo tendrá que serializar un diccionario.
- `docs/02` incorpora el autoload y `docs/05` lo usa en la Fase 7.
- No cambia el contrato del jugador ni de las escenas.
