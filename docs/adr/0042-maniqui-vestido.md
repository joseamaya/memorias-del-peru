# ADR-0042 — Maniquí UAL1 como base, con ropa y rostro como capas
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

La dirección de arte anterior venía de ADR-0015 (personajes con esqueleto),
ADR-0016 (cuerpos MakeHuman y captura de CMU) y ADR-0017 (cabezas Rocketbox).
El resultado, visto de cerca, cae en el valle inquietante: cuerpos y caras
realistas que no llegan al fotorrealismo y que el responsable del proyecto
describe como «modelos horribles» que «dan miedo».

El pase de maniquí UAL1 (CC0) se hizo como prototipo para juzgar escala,
rutinas y sensación de lugar. El responsable del proyecto confirma que esa es
la dirección correcta: **maniquí como base, ropa y cara encima**. El realismo
debe venir de la silueta, el vestuario, la luz y el color, no de una cara
hiperrealista.

## Opciones consideradas

1. **Mantener MakeHuman/Rocketbox y mejorar las caras.** Rechazada: el problema
   no es solo la cara; el cuerpo y la ropa tampoco sostienen el primer plano, y
   cada iteración depende de recalcular mallas y capturas.
2. **Maniquí UAL1 como base definitiva, con ropa y rostro como capas.** Elegida:
   conserva 43 animaciones, un esqueleto humanoide estándar y una silueta
   neutra sobre la que se puede iterar sin tocar la animación.
3. **Modelar personajes realistas nuevos desde cero.** Queda como camino
   futuro si el estilo estilizado no basta; hoy multiplica el coste antes de
   validar el arco.

## Decisión

- **UAL1 (Quaternius, CC0) es la base definitiva** de cuerpo, esqueleto y
  animación de todos los personajes.
- **La ropa es una capa aparte**, anclada a huesos con `BoneAttachment3D` en la
  primera pasada y skinned cuando haga falta caída. No se esculpe sobre el
  cuerpo del maniquí.
- **El rostro es una capa estilizada**: cabeza, ojos, boca, pelo y vincha
  simples, sin cabezas fotorrealistas.
- **Los GLB de MakeHuman/Rocketbox quedan como referencia** en el repositorio,
  pero no se cargan en ninguna escena.
- **Orientación:** UAL1 mira hacia +Z; los actores giran el modelo 180° para
  que su cara coincida con el -Z que usa la lógica de movimiento y mirada.
- **Rigor histórico:** la ropa sigue las fichas PCH; no se inventan insignias
  ni prendas sin ficha. Los modelos viejos sirven de referencia de silueta y
  textil, no de cuerpo.
- **Licencias:** UAL1 es CC0; la ropa y el rostro son del proyecto; cualquier
  textura reutilizada debe conservar su licencia.

## Consecuencias

- ADR-0016 y ADR-0017 quedan **reemplazados** por este ADR.
- El maniquí deja de ser un prototipo temporal: es la base del juego.
- La ropa rígida puede clavarse o flotar en posturas extremas (arrodillarse,
  correr). Se prueba primero en la tejedora; si una pieza falla, se pasa a
  skinned o se retira.
- El prototipo se valida con la tejedora antes de extenderlo a los nueve
  personajes del acto I, a los actos II y III.
- La lliclla rígida se retira del primer prototipo: necesita una pasada de tela
  con peso o simulación. El resto del vestuario sigue.
- Cada conjunto comparte materiales y fusiona piezas para no multiplicar draw
  calls.
- Los archivos viejos se conservan para referencia; su retirada definitiva
  puede hacerse cuando el vestuario cubra todos los roles.
