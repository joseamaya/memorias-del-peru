extends RefCounted
## Comprueba el contrato base de Interactable.


func test_interactable_contract() -> bool:
	var interactable: Interactable = Interactable.new()
	var text: String = interactable.get_interaction_text()
	var ok: bool = text == "Interactuar"
	interactable.free()
	return ok
