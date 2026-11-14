extends RefCounted
## Comprueba el estado de campaña entre escenas (ADR-0041).


func test_campaign_state_flags() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var state: CampaignStateService = tree.root.get_node_or_null("CampaignState") as CampaignStateService
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
