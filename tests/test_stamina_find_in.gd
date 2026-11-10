extends RefCounted
## Comprueba la búsqueda del componente de estamina entre hijos directos.


func test_stamina_find_in() -> bool:
	var owner_node: Node = Node.new()
	var stamina: StaminaComponent = StaminaComponent.new()
	owner_node.add_child(stamina)
	var empty_owner: Node = Node.new()
	var found: StaminaComponent = StaminaComponent.find_in(owner_node)
	var missing: StaminaComponent = StaminaComponent.find_in(empty_owner)
	var ok: bool = found == stamina and missing == null
	owner_node.free()
	empty_owner.free()
	return ok
