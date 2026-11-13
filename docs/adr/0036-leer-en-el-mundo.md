# ADR-0036 — Leer en el mundo: sin estelas, contador ni brújula
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

[ADR-0035](0035-tour-libre.md) resolvió que «Observar» no funcionaba poniendo
una estela de piedra a la altura del pecho, y dejó una brújula opcional, un
contador y un objetivo neutro. Al usarlo, la estela se reveló como lo que era:
un objeto artificial puesto para que el rayo de interacción tuviera un blanco.
En una llacta del siglo XV no hay monolitos de museo, y el contador y la flecha
obligan a mirar el HUD en vez del mundo.

El responsable del proyecto lo rechazó: la prioridad es la **sensación de
lugar**, no la fontanería de lectura. La lectura debe ocurrir en el objeto o el
sitio real.

## Opciones consideradas

1. **Mantener las estelas** y seguir puliendo el HUD. Insiste en el andamio.
2. **Leer en el mundo**: sin objetos nuevos, sin contador ni brújula; la tarjeta
   se abre al estar en el sitio o al hacer la acción.
3. **Quitar también las tarjetas** y dejar solo el evento. Pierde las fichas
   jugables.

## Decisión

Se adopta **la opción 2**:

- Se eliminan las estelas, el contador, la brújula y la acción `guide` (Q).
- Las tarjetas se abren una sola vez:
  - **Plaza, telar, chicha, vivienda, terraza, corral y mirador** mediante zonas
    invisibles (`Area3D`) que detectan al jugador al entrar.
  - **Quero** al beber y **ofrenda** al dejarla, por sus señales.
- El mirador abre su tarjeta y pide la llegada del mensajero; el respaldo por
  reloj de 360 s sigue.
- Mientras no hay evento no hay objetivo en el HUD: el mundo no señala nada.
- Se conservan la tarjeta y los nueve textos.

El trabajo de sensación de lugar (sol más bajo, polvo en suspensión y rutas más
largas de los vecinos) va en la misma entrega, como presentación en bitácora.

## Consecuencias

- ADR-0035 queda reemplazado. El alcance de la campaña se anota como v5.2 y la
  Fase 5 cambia sus criterios: no hay HUD de tour que probar.
- La acción `guide` desaparece del Input Map y del aviso de controles.
- La lectura depende de recorrer el espacio: quien no entre en una zona no ve
  su tarjeta.
- El contador `n/9` desaparece; no hay forma de saber cuántas quedan, que es
  coherente con un museo que se descubre.
- La duración sigue pendiente de validación y ahora depende por completo de la
  exploración.
