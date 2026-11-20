extends RefCounted
## Comprueba el estado de campaña entre escenas (ADR-0041).


func test_campaign_state_flags() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var state: CampaignStateService = (
		tree.root.get_node_or_null("CampaignState") as CampaignStateService
	)
	if state == null:
		return false
	state.clear()
	var ok: bool = state.get_flag(&"x") == 0
	state.set_flag(&"x", 2)
	ok = ok and state.get_flag(&"x") == 2 and state.has_flag(&"x")
	state.set_flag(&"x", 0)
	ok = ok and not state.has_flag(&"x")
	state.set_flag(&"descanso", 1)
	ok = ok and state.get_flags().size() == 1
	state.clear()
	ok = ok and state.get_flags().is_empty()
	return ok


func test_campaign_state_round_trip() -> bool:
	var state: CampaignStateService = CampaignStateService.new()
	state.clear()
	state.set_flag(&"mision", 2)
	state.set_data(&"inventario", ["honda", "porra"])
	state.set_data(&"oficio", &"tejedora")
	state.set_data(&"notas", {"paso": 3, "hecho": true})
	var data: Dictionary = state.to_dict()
	var restored: CampaignStateService = CampaignStateService.new()
	var ok: bool = restored.from_dict(data)
	ok = ok and restored.get_flag(&"mision") == 2
	var inventory: Variant = restored.get_data(&"inventario")
	ok = ok and inventory is Array
	if inventory is Array:
		ok = ok and _as_array(inventory).size() == 2
	ok = ok and str(restored.get_data(&"oficio", "")) == "tejedora"
	var notes: Variant = restored.get_data(&"notas")
	ok = ok and notes is Dictionary
	if notes is Dictionary:
		var note: Dictionary = notes
		ok = ok and str(note.get("paso", 0)) == "3"
	ok = ok and not restored.from_dict({"flags": 5})
	state.free()
	restored.free()
	return ok


static func _as_array(value: Variant) -> Array:
	@warning_ignore("unsafe_cast")
	return value as Array
