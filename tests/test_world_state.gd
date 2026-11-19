extends RefCounted
## Comprueba el estado persistente del mundo (F1.6).


func test_world_state_flags_and_phase() -> bool:
	var state: WorldStateService = WorldStateService.new()
	state.clear()
	var ok: bool = state.get_phase() == WorldStateService.INITIAL_PHASE
	state.set_phase(&"guerra")
	ok = ok and state.get_phase() == &"guerra"
	state.set_flag(&"mensajero_ayudado", 1)
	state.set_flag(&"valor", 3)
	ok = ok and state.has_flag(&"mensajero_ayudado")
	ok = ok and state.get_flag(&"valor") == 3
	state.set_flag(&"valor", 0)
	ok = ok and not state.has_flag(&"valor")
	ok = ok and state.get_flags().size() == 1
	state.clear()
	ok = ok and state.get_phase() == WorldStateService.INITIAL_PHASE
	ok = ok and state.get_flags().is_empty()
	state.free()
	return ok


func test_world_state_discoveries_and_changes() -> bool:
	var state: WorldStateService = WorldStateService.new()
	state.clear()
	state.discover(&"poi_mirador")
	state.discover(&"poi_mirador")
	var ok: bool = state.is_discovered(&"poi_mirador")
	ok = ok and state.get_discoveries().size() == 1
	state.set_change(&"corral_reparado", 1)
	ok = ok and state.has_change(&"corral_reparado")
	ok = ok and state.get_change(&"corral_reparado") == 1
	state.set_change(&"corral_reparado", 0)
	ok = ok and not state.has_change(&"corral_reparado")
	state.free()
	return ok


func test_world_state_npc_copy() -> bool:
	var state: WorldStateService = WorldStateService.new()
	state.clear()
	var original: Dictionary = {"anchor": "plaza", "relation": 2}
	state.set_npc_state(&"npc_sisa", original)
	original["relation"] = 0
	var loaded: Dictionary = state.get_npc_state(&"npc_sisa")
	var ok: bool = loaded.get("relation", -1) == 2
	loaded["relation"] = 0
	ok = ok and state.get_npc_state(&"npc_sisa").get("relation", -1) == 2
	ok = ok and state.has_npc_state(&"npc_sisa")
	state.free()
	return ok


func test_world_state_round_trip() -> bool:
	var state: WorldStateService = WorldStateService.new()
	state.clear()
	state.set_phase(&"posguerra")
	state.set_flag(&"casa_reconstruida", 1)
	state.discover(&"poi_cueva")
	state.set_npc_state(&"npc_puma", {"alive": false, "relation": 1})
	state.set_change(&"acequia_limpia", 1)
	var data: Dictionary = state.to_dict()
	var restored: WorldStateService = WorldStateService.new()
	var ok: bool = restored.from_dict(data)
	ok = ok and restored.get_phase() == &"posguerra"
	ok = ok and restored.get_flag(&"casa_reconstruida") == 1
	ok = ok and restored.is_discovered(&"poi_cueva")
	ok = ok and restored.get_npc_state(&"npc_puma").get("alive", true) == false
	ok = ok and restored.get_change(&"acequia_limpia") == 1
	ok = ok and not restored.from_dict({"flags": []})
	state.free()
	restored.free()
	return ok
