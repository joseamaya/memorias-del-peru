extends RefCounted
## Comprueba que la ofrenda solo se usa una vez y que, ya usada, deja de
## estar disponible para que el HUD no ofrezca la acción (ADR-0008).

var _offered: int = 0


func _on_offered() -> void:
	_offered += 1


func test_offering_once() -> bool:
	var offering: OfrendaPachamama = OfrendaPachamama.new()
	offering.offered.connect(_on_offered)
	var interactor: Node3D = Node3D.new()
	var available_before: bool = offering.is_available()
	offering.interact(interactor)
	offering.interact(interactor)
	var ok: bool = available_before and offering.used and _offered == 1 and not offering.is_available()
	interactor.free()
	offering.free()
	return ok
