extends RefCounted
## Comprueba que la escena del quero instancia y su raíz es interactuable.


func test_quero_scene_loads() -> bool:
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/objects/quero_chicha.tscn") as PackedScene
	if packed == null:
		return false
	var quero: Node = packed.instantiate()
	var ok: bool = (
		quero is QueroChicha
		and quero is Interactable
		and quero.get_node_or_null("CollisionShape3D") != null
	)
	quero.free()
	return ok
