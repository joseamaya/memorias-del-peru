# ADR-0034 — Una campaña y modelo de museo explorable
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

La visión original ([docs/01](../01_vision_y_alcance.md)) describe una antología
de campañas, cada una de una época. La Fase 4 entregó un fragmento de 2–3 min de
la campaña 01 y la validación de autor ([ADR-0031](0031-validacion-por-el-autor.md))
mostró que el recorrido directo dura 121 s: el contenido existe, pero es corto.

El proyecto tiene 23 fichas históricas verificadas y un mundo construido que
apenas se usa: la ruta alta, las terrazas, el corral y el mirador. La antología
multiplica el coste de arte, investigación y campañas de marketing sin que
exista todavía una sola experiencia cerrada. El responsable del proyecto decidió
concentrarse en una campaña y en un modelo de museo explorable.

## Opciones consideradas

1. **Mantener la antología** y empezar la campaña 02. Multiplica el trabajo y
   deja la 01 como fragmento.
2. **Una campaña, modelo de museo**: 9 estaciones con tarjeta, contador y
   brújula; el evento del mensajero como clímax. Aprovecha el mundo y las fichas.
3. **Una campaña narrativa larga** con misiones y diálogos. Requiere sistemas
   nuevos (misiones, inventario, diálogo) que hoy no existen.

## Decisión

Se adopta **la opción 2**:

- La etapa actual es **una campaña**: *Pachacútec — La defensa del Cusco*. Las
  demás épocas quedan como horizonte, no como compromiso.
- El producto es un **museo explorable**: 9 estaciones con tarjeta de 60–80
  palabras, sello de clasificación H/A/R/N y fuente; contador y brújula.
- Las estaciones se activan con «Observar» (E), como el resto de interactuables.
- El evento del mensajero sale al visitar **5 estaciones incluido el mirador**;
  el resto son opcionales. El respaldo por reloj de ADR-0032 se amplía a
  **360 s** para no cortar el recorrido.
- La duración objetivo es **6–8 min** en ruta guiada, y el horizonte de 10–15
  min queda para la campaña completa.
- La UI de tarjeta es genérica de Core; las estaciones y el tour son contenido
  de la campaña.

## Consecuencias

- docs/01 cambia su visión de antología por una campaña con horizonte de
  antología; se abre la Fase 5 en docs/05 con entregables y criterios.
- El sistema de objetivos actual se sustituye por el puntero de estación: el HUD
  sugiere la siguiente y cuenta las visitadas.
- Nueve fichas pasan a ser contenido jugable; ninguna tarjeta puede afirmar algo
  sin ficha.
- Se añade UI de Core (tarjeta, contador, brújula) y una escena de estación en la
  campaña.
- El alcance de la campaña se anota como v5.0.
