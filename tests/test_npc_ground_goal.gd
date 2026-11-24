extends RefCounted
## Comprueba que el destino de un NPC sigue la altura del suelo en el punto
## desplazado del anillo, no la del ancla.


func _register(director: NpcDirector, with_sampler: bool) -> NpcDefinition:
	var definition: NpcDefinition = NpcDefinition.new()
	definition.id = &"npc_cuesta"
	definition.home_anchor = &"cuesta"
	var definitions: Array[NpcDefinition] = [definition]
	var anchors: Dictionary[StringName, Vector3] = {&"cuesta": Vector3(0.0, 10.0, 0.0)}
	if with_sampler:
		director.set_ground_sampler(func(x: float, _z: float) -> float: return x * 0.5)
	director.register(definitions, anchors)
	return definition


func test_goal_follows_ground_on_slope() -> bool:
	var director: NpcDirector = NpcDirector.new()
	director.autostart = false
	_register(director, true)
	var goal: Vector3 = director.get_goal(&"npc_cuesta")
	var expected: float = goal.x * 0.5 + NpcDirector.BODY_OFFSET
	var ok: bool = absf(goal.y - expected) <= 0.001
	# Y no es la altura del ancla, que es lo que fallaba en pendiente.
	ok = ok and absf(goal.y - (10.0 + NpcDirector.BODY_OFFSET)) > 0.5
	director.free()
	return ok


func test_goal_keeps_anchor_height_without_sampler() -> bool:
	var director: NpcDirector = NpcDirector.new()
	director.autostart = false
	_register(director, false)
	var goal: Vector3 = director.get_goal(&"npc_cuesta")
	var ok: bool = absf(goal.y - (10.0 + NpcDirector.BODY_OFFSET)) <= 0.001
	director.free()
	return ok


func test_restore_recomputes_height() -> bool:
	var director: NpcDirector = NpcDirector.new()
	director.autostart = false
	_register(director, true)
	var snapshot: Dictionary = director.get_snapshot()
	var npcs: Dictionary = snapshot["npcs"]
	var state: Dictionary = npcs["npc_cuesta"]
	state["position"] = [2.0, 999.0, 0.0]
	npcs["npc_cuesta"] = state
	snapshot["npcs"] = npcs
	var ok: bool = director.restore_snapshot(snapshot)
	var restored: Vector3 = director.get_npc_position(&"npc_cuesta")
	ok = ok and absf(restored.y - (2.0 * 0.5 + NpcDirector.BODY_OFFSET)) <= 0.001
	director.free()
	return ok
