extends RefCounted
## Comprueba que la ofrenda solo se usa una vez.

var _offered: int = 0


func _on_offered() -> void:
	_offered += 1


func test_offering_once() -> bool:
	var offering: OfrendaPachamama = OfrendaPachamama.new()
	offering.offered.connect(_on_offered)
	var interactor: Node3D = Node3D.new()
	offering.interact(interactor)
	offering.interact(interactor)
	var ok: bool = offering.used and _offered == 1
	interactor.free()
	offering.free()
	return ok
