extends SceneTree
## Comprueba el LOD del sector con 60 NPC: presupuesto, spawn/despawn,
## movimiento por rutas y snapshot de guardado.

const SCENE_PATH: String = "res://tests/scenes/npc_lod.tscn"
const NARRATIVE_COUNT: int = 6


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("NPC_LOD_FAIL no scene")
		quit(1)
		return
	var sector: GreySector = packed.instantiate() as GreySector
	root.add_child(sector)
	sector.set_npc_autostart(false)
	sector.set_process(false)
	for _i: int in 20:
		await physics_frame
	var director: NpcDirector = sector.get_npc_director()
	var ok: bool = sector.get_npc_count() == 60 and director != null
	ok = ok and sector.get_active_npc_count() == 60
	ok = ok and sector.get_animated_npc_count() == 25
	ok = ok and _check_view_change(sector, director)
	ok = ok and await _check_dormant_schedule(sector, director)
	ok = ok and _check_walk(sector)
	ok = ok and _check_snapshot(director)
	var active: int = sector.get_active_npc_count()
	var animated: int = sector.get_animated_npc_count()
	sector.queue_free()
	await process_frame
	if ok:
		print("NPC_LOD_OK npcs=60 active=", active, " animated=", animated)
	else:
		printerr("NPC_LOD_FAIL")
	quit(0 if ok else 1)


## Al alejar la vista, los tier B desaparecen y los narrativos siguen activos.
func _check_view_change(sector: GreySector, director: NpcDirector) -> bool:
	var camera: Camera3D = sector.find_child("GreySectorCamera", true, false) as Camera3D
	if camera == null:
		return false
	camera.global_position = Vector3(200.0, 16.0, 200.0)
	director.update_lod()
	var far_ok: bool = sector.get_active_npc_count() == NARRATIVE_COUNT
	far_ok = far_ok and sector.get_animated_npc_count() == 0
	camera.global_position = Vector3(0.0, 16.0, 0.0)
	director.update_lod()
	var near_ok: bool = sector.get_active_npc_count() == 60
	near_ok = near_ok and sector.get_animated_npc_count() == 25
	return far_ok and near_ok


## Un NPC que estuvo dormido mientras cambió su horario debe recibir ruta al
## volver a existir, no quedarse en el ancla anterior.
func _check_dormant_schedule(sector: GreySector, director: NpcDirector) -> bool:
	var camera: Camera3D = sector.find_child("GreySectorCamera", true, false) as Camera3D
	if camera == null:
		return false
	sector.update_npcs(200, true)
	camera.global_position = Vector3(200.0, 16.0, 200.0)
	director.update_lod()
	await process_frame
	if director.get_node_or_null("npc_gris_2") != null:
		return false
	director.set_time(600)
	camera.global_position = Vector3(0.0, 16.0, 0.0)
	director.update_lod()
	await process_frame
	var actor: NpcSimActor = director.get_node_or_null("npc_gris_2") as NpcSimActor
	if actor == null or actor.mover.get_path().is_empty():
		return false
	sector.advance_npcs(90.0, 0.2)
	return director.is_at_goal(&"npc_gris_2", 0.9)


func _check_walk(sector: GreySector) -> bool:
	sector.update_npcs(200, true)
	if sector.get_npc_anchor(0, 200) != &"casa":
		return false
	sector.update_npcs(600, false)
	if sector.get_npc_target(0) != &"campo" or sector.get_npc_target(1) != &"trabajo":
		return false
	sector.advance_npcs(90.0, 0.2)
	for index: int in sector.get_npc_count():
		if not sector.is_npc_at_target(index, 0.9):
			return false
	return true


func _check_snapshot(director: NpcDirector) -> bool:
	var snapshot: Dictionary = director.get_snapshot()
	var npcs: Dictionary = snapshot.get("npcs", {})
	if npcs.size() != 60 or not npcs.has("npc_gris_1"):
		return false
	var manager: SaveManagerService = SaveManagerService.new()
	var world: WorldStateService = WorldStateService.new()
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.set_time(2, 600.0)
	var campaign: StringName = StringName("test_npc_lod_%d" % Time.get_ticks_msec())
	var slot: StringName = &"auto"
	var ok: bool = manager.save_world(campaign, slot, world, clock, {"npc_snapshot": snapshot})
	var loaded_world: WorldStateService = WorldStateService.new()
	var loaded_clock: WorldClockService = WorldClockService.new()
	loaded_clock.autostart = false
	var player: Dictionary = manager.load_world(campaign, slot, loaded_world, loaded_clock)
	var restored_value: Variant = player.get("npc_snapshot", null)
	ok = ok and restored_value is Dictionary
	director.set_time(200)
	director.teleport_to_goal()
	ok = ok and director.get_anchor(&"npc_gris_1") == &"casa"
	if restored_value is Dictionary:
		var restored: Dictionary = restored_value
		ok = ok and director.restore_snapshot(restored)
		ok = ok and director.get_minute() == 600
		ok = ok and director.get_anchor(&"npc_gris_1") == &"trabajo"
	ok = ok and manager.delete_slot(campaign, slot)
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(campaign)))
	)
	world.free()
	clock.free()
	loaded_world.free()
	loaded_clock.free()
	manager.free()
	return ok
