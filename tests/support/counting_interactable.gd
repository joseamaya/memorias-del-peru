class_name CountingInteractable
extends Interactable
## Interactuable de prueba que cuenta cuántas veces se interactúa con él.

var interactions: int = 0


func interact(_interactor: Node3D) -> void:
	interactions += 1
