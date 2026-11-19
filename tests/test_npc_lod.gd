extends RefCounted
## Comprueba el LOD de simulación y el presupuesto del `NpcDirector`.


func test_npc_lod_distances() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var director: NpcDirector = _director(tree)
	var target: Node3D = Node3D.new()
	tree.root.add_child(target)
	director.set_target(target)
	director.simulate_distance = 90.0
	director.animate_distance = 40.0
	var anchors: Dictionary[StringName, Vector3] = {
		&"cerca": Vector3(0.0, 0.9, 0.0),
		&"medio": Vector3(0.0, 0.9, 50.0),
		&"lejos": Vector3(0.0, 0.9, 200.0),
		&"ambiente": Vector3(0.0, 0.9, 10.0),
	}
	var definitions: Array[NpcDefinition] = [
		_definition(&"comun_cerca", NpcDefinition.Tier.COMMUNITY, &"cerca"),
		_definition(&"comun_medio", NpcDefinition.Tier.COMMUNITY, &"medio"),
		_definition(&"comun_lejos", NpcDefinition.Tier.COMMUNITY, &"lejos"),
		_definition(&"narrativo_lejos", NpcDefinition.Tier.NARRATIVE, &"lejos"),
		_definition(&"ambiente_cerca", NpcDefinition.Tier.AMBIENT, &"ambiente"),
	]
	var ok: bool = director.register(definitions, anchors)
	director.set_time(600)
	director.update_lod()
	ok = ok and director.get_lod(&"comun_cerca") == NpcSimActor.Lod.ANIMATED
	ok = ok and director.get_lod(&"comun_medio") == NpcSimActor.Lod.SIMULATED
	ok = ok and director.get_lod(&"comun_lejos") == NpcSimActor.Lod.DORMANT
	ok = ok and director.get_lod(&"narrativo_lejos") == NpcSimActor.Lod.SIMULATED
	ok = ok and director.get_lod(&"ambiente_cerca") == NpcSimActor.Lod.ANIMATED
	ok = ok and director.get_active_count() == 4
	_cleanup(tree, director)
	target.free()
	return ok


func test_npc_lod_budget() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var director: NpcDirector = _director(tree)
	var target: Node3D = Node3D.new()
	tree.root.add_child(target)
	director.set_target(target)
	director.simulate_distance = 100.0
	director.animate_distance = 100.0
	director.max_active = 60
	director.max_animated = 25
	var anchors: Dictionary[StringName, Vector3] = {&"plaza": Vector3(0.0, 0.9, 0.0)}
	var definitions: Array[NpcDefinition] = []
	for index: int in 70:
		definitions.append(
			_definition(StringName("npc_%d" % index), NpcDefinition.Tier.COMMUNITY, &"plaza")
		)
	var ok: bool = director.register(definitions, anchors)
	director.update_lod()
	ok = ok and director.get_active_count() == 60
	ok = ok and director.get_animated_count() == 25
	_cleanup(tree, director)
	target.free()
	return ok


func test_npc_director_despawn() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var director: NpcDirector = _director(tree)
	var target: Node3D = Node3D.new()
	tree.root.add_child(target)
	director.set_target(target)
	director.simulate_distance = 90.0
	var anchors: Dictionary[StringName, Vector3] = {&"casa": Vector3(0.0, 0.9, 0.0)}
	var definitions: Array[NpcDefinition] = [
		_definition(&"npc", NpcDefinition.Tier.COMMUNITY, &"casa"),
	]
	var ok: bool = director.register(definitions, anchors)
	director.update_lod()
	ok = ok and director.get_active_count() == 1
	target.position = Vector3(200.0, 0.0, 200.0)
	director.update_lod()
	ok = ok and director.get_active_count() == 0
	target.position = Vector3.ZERO
	director.update_lod()
	ok = ok and director.get_active_count() == 1
	_cleanup(tree, director)
	target.free()
	return ok


func test_npc_director_snapshot() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var director: NpcDirector = _director(tree)
	var anchors: Dictionary[StringName, Vector3] = {
		&"casa": Vector3(0.0, 0.9, 0.0),
		&"trabajo": Vector3(10.0, 0.9, 0.0),
	}
	var definitions: Array[NpcDefinition] = [
		_definition(&"npc", NpcDefinition.Tier.COMMUNITY, &"casa"),
		_definition(&"ambiente", NpcDefinition.Tier.AMBIENT, &"casa"),
	]
	var ok: bool = director.register(definitions, anchors)
	director.set_time(600)
	var snapshot: Dictionary = director.get_snapshot()
	var npcs: Dictionary = snapshot.get("npcs", {})
	ok = ok and npcs.size() == 1 and npcs.has("npc")
	director.set_time(200)
	director.teleport_to_goal()
	ok = ok and director.get_anchor(&"npc") == &"casa"
	ok = ok and director.restore_snapshot(snapshot)
	ok = ok and director.get_anchor(&"npc") == &"casa"
	ok = ok and director.get_minute() == 600
	_cleanup(tree, director)
	return ok


func test_npc_director_schedule() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var director: NpcDirector = _director(tree)
	var anchors: Dictionary[StringName, Vector3] = {
		&"casa": Vector3(0.0, 0.9, 0.0),
		&"trabajo": Vector3(10.0, 0.9, 0.0),
	}
	var definition: NpcDefinition = _definition(&"npc", NpcDefinition.Tier.COMMUNITY, &"casa")
	definition.schedule.append(_entry(0, 360, &"casa"))
	definition.schedule.append(_entry(360, 1080, &"trabajo"))
	var definitions: Array[NpcDefinition] = [definition]
	var ok: bool = director.register(definitions, anchors)
	director.set_time(200)
	ok = ok and director.get_anchor(&"npc") == &"casa"
	var changes: Array[StringName] = []
	director.schedule_applied.connect(
		func(_id: StringName, anchor: StringName) -> void: changes.append(anchor)
	)
	director.set_time(600)
	ok = ok and director.get_anchor(&"npc") == &"trabajo"
	ok = ok and changes.size() == 1 and changes[0] == &"trabajo"
	_cleanup(tree, director)
	return ok


func _definition(id: StringName, tier: int, anchor: StringName) -> NpcDefinition:
	var definition: NpcDefinition = NpcDefinition.new()
	definition.id = id
	definition.tier = tier
	definition.home_anchor = anchor
	return definition


func _entry(start: int, end: int, anchor: StringName) -> ScheduleEntry:
	var entry: ScheduleEntry = ScheduleEntry.new()
	entry.start_minute = start
	entry.end_minute = end
	entry.anchor_id = anchor
	return entry


func _director(tree: SceneTree) -> NpcDirector:
	var director: NpcDirector = NpcDirector.new()
	director.autostart = false
	tree.root.add_child(director)
	return director


func _cleanup(tree: SceneTree, director: NpcDirector) -> void:
	tree.root.remove_child(director)
	director.free()
