# ADR-0008 — Disponibilidad de interactuables

- Estado: Aceptado
- Fecha: 2026-11-10

## Contexto

El contrato de [Interactable](../../core/interaction/interactable.gd) solo define `interact()` y `get_interaction_text()`. El jugador enfoca cualquier objeto con ese script y muestra su texto.

El pututu necesitaba estar en la plaza desde el principio (forma parte de la ficción) pero solo tenía sentido durante la reunión. Al no existir forma de expresar “ahora no”, el jugador podía gastarlo antes de tiempo y el evento se quedaba sin respuesta: un bloqueo de progreso real.

## Opciones consideradas

1. **Dejar el objeto siempre disponible** y tolerar el uso temprano dentro del evento. No resuelve el aviso: el HUD ofrece una acción que no hace nada.
2. **Ocultar el objeto hasta la fase de llamada.** Rompe la escena: el pututu está en el pedestal desde el principio.
3. **Devolver un texto vacío** y ocultar la etiqueta cuando el texto está vacío. Funciona, pero sobrecarga el significado de “texto vacío” y no impide la interacción.
4. **Añadir `is_available()` al contrato** con valor por defecto `true`. El jugador no enfoca ni ejecuta lo que no está disponible; cada objeto decide cuándo puede usarse.

## Decisión

Opción 4.

- `Interactable.is_available() -> bool` devuelve `true` por defecto; los objetos con estado lo sobrescriben.
- `PlayerFPS.update_interaction()` resuelve el candidato al cambiar el collider y recalcula el foco cuando cambia la disponibilidad, sin esperar a mover la mirada.
- `try_interact()` comprueba la disponibilidad antes de ejecutar.
- El HUD oculta la etiqueta si el texto de interacción está vacío, para que ningún objeto muestre una acción vacía.
- El pututu expone `set_armed(bool)`: el evento lo arma al entrar en la llamada y lo desarma al salir.

## Consecuencias

- Un objeto puede existir, estar a la vista y no ofrecer interacción: el HUD no miente.
- El cambio es retrocompatible: ningún interactuable existente necesita cambios.
- La disponibilidad es estado de partida en memoria, coherente con la ausencia de guardado.
- El contrato de `docs/02` §5 crece con un método; cualquier objeto nuevo puede ignorarlo.
