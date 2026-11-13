# ADR-0035 — Tour libre: estelas legibles, sin umbral y con guía opcional
- Estado: Aceptado
- Fecha: 2026-11-13

## Contexto

[ADR-0034](0034-una-campana-y-museo.md) convirtió la campaña en un museo
explorable con nueve estaciones, una brújula permanente y un umbral de cinco
estaciones para que saliera el mensajero.

La primera prueba de uso encontró dos problemas. El marcador era un bloque de
55 cm pegado al suelo y el rayo de interacción sale a la altura de los ojos y
mide 2,5 m: había que mirar unos 27° hacia abajo para enfocarlo, y quien miraba
al quero o a la casa no veía «Observar». Además, el tour se sentía como un
pasillo: el objetivo nombraba la estación, la brújula la señalaba siempre y el
evento interrumpía la visita a las cinco.

## Opciones consideradas

1. **Solo agrandar el marcador.** Arregla la interacción, pero la guía sigue
   llevando de la mano.
2. **Estela legible y tour libre**: sin umbral, brújula bajo demanda y objetivo
   neutro. El jugador explora y cierra cuando quiere.
3. **Quitar las estaciones** y dejar solo el evento. Pierde las fichas jugables,
   que son el valor diferencial del proyecto.

## Decisión

Se adopta **la opción 2**:

- La estación pasa a ser una **estela** de piedra: base, losa de 1,3 m y
  colisionador de 1,7 m. Se enfoca caminando y mirando al frente.
- **Sin umbral**: observar estaciones no dispara nada por acumulación.
- El evento sale al **observar la estela del mirador** (mirar el camino del
  norte), que pide la llegada al volver a la plaza; el respaldo por reloj de
  360 s sigue si el jugador no sube.
- La **brújula se oculta** por defecto. Se muestra al mantener **Q** y durante
  tres segundos después de observar una estación.
- El **objetivo** es neutro: «Explora la llacta y observa las estelas». Con Q
  pulsada muestra el nombre de la estación más cercana. El contador `n/9` se
  mantiene.
- Se conservan la tarjeta, el contador y las nueve fichas.

## Consecuencias

- ADR-0034 queda ampliado, no reemplazado.
- El alcance de la campaña se anota como v5.1 y la Fase 5 cambia su criterio de
  cierre: el evento se dispara en el mirador, no a las cinco estaciones.
- Hay una acción nueva en el Input Map (`guide`, Q) y el aviso de controles
  cambia; el jugador puede ignorar la brújula por completo.
- La duración objetivo de 6–8 min sigue pendiente de validación: ahora depende
  de cuánto explore el jugador, no de un umbral.
- El umbral de 5 estaciones desaparece; la partida puede cerrarse con una sola
  estación leída si el jugador va directo al mirador.
