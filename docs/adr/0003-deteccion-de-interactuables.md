# ADR-0003 — Detección de interactuables

- Estado: **Aceptado**
- Fecha: 2026-11-10

## Contexto

La especificación ([docs/00_especificacion.md](../00_especificacion.md) §6) define `class_name Interactable extends Node` con `interact(interactor: Node3D)` y `get_interaction_text()`. El jugador detecta objetos con un `RayCast3D`, sin condiciones particulares por objeto, y el collider detectado puede ser hijo del interactuable.

Problema: el `RayCast3D` devuelve un `CollisionObject3D` (p. ej. `StaticBody3D`), mientras que `Interactable` es un `Node`. Hay que definir cómo se relacionan en una escena y cómo se encuentra uno a partir del otro.

## Opciones consideradas

1. **Script en la raíz + búsqueda ascendente.** El script del objeto (`extends Interactable`) se asigna a la raíz de su escena (un `Node3D`, admisible porque `Node3D` hereda de `Node`). El jugador sube desde el collider por `get_parent()` hasta encontrar un nodo `is Interactable`.
2. **Componente hijo.** Un nodo `Interactable` hijo del `CollisionObject3D`; el jugador busca entre los hijos del collider. Más flexible pero acopla la búsqueda a una posición concreta en el árbol.
3. **Grupos o metadatos.** El collider pertenece a un grupo o tiene metadatos con referencia al interactuable. Depende de cadenas y no es verificable por el tipado.

## Decisión propuesta

Opción 1.

- Búsqueda: desde el collider, recorrer ancestros hasta encontrar `Interactable`; detenerse al llegar a la raíz de la escena actual (`get_tree().current_scene`) o tras un límite de profundidad (`const MAX_INTERACTABLE_SEARCH_DEPTH: int = 8`).
- El resultado se cachea por collider enfocado; solo se recalcula cuando cambia el collider.
- Los scripts derivados acceden a sus nodos visuales mediante `@export` tipados (p. ej. `@export var mesh: MeshInstance3D`), lo que evita depender de que la raíz sea `Node3D` en el tipado estático.
- Los colliders interactuables usan la capa `interactable`.

## Consecuencias

- Añadir un objeto interactuable = crear escena + script derivado; `player_fps.gd` no cambia.
- El contrato base usa parámetros no utilizados: se nombran con prefijo `_` en la implementación base para cumplir la configuración de advertencias.
- Riesgo: un `Interactable` anidado dentro de otro devolvería el más cercano al collider. Se considera el comportamiento correcto y se documenta.
