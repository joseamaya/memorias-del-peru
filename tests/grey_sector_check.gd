extends SceneTree
## Comprueba el sector gris de integración: Terrain3D, pirca Cyclops, navmesh,
## 20 NPC con horario y guardado/carga.

const SCENE_PATH: String = "res://tests/scenes/grey_sector.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("GREY_SECTOR_FAIL no scene")
		quit(1)
		return
	var sector: GreySector = packed.instantiate() as GreySector
	root.add_child(sector)
	for _i: int in 20:
		await physics_frame
	var npc_ok: bool = sector.get_npc_count() == 20
	var terrain: Terrain3D = sector.get_terrain()
	var terrain_ok: bool = (
		terrain != null and terrain.data != null and terrain.data.get_region_count() >= 1
	)
	var block: CyclopsBlock = sector.get_cyclops_block()
	var block_ok: bool = (
		block != null and block.mesh_instance != null and block.mesh_instance.mesh != null
	)
	block_ok = block_ok and block.collision_shape != null and block.collision_shape.shape != null
	var path: PackedVector3Array = sector.get_navmesh_path(
		Vector3(-20.0, 0.0, -20.0), Vector3(20.0, 0.0, 20.0)
	)
	var path_ok: bool = path.size() >= 2
	var ok: bool = npc_ok and terrain_ok and block_ok and path_ok
	sector.update_npcs(200, true)
	var home_anchor: StringName = sector.get_npc_anchor(0, 200)
	var home_position: Vector3 = sector.get_npc_position(0)
	ok = ok and home_anchor == &"casa"
	ok = ok and home_position.distance_to(Vector3(-8.0, 0.9, 8.0)) < 0.1
	sector.update_npcs(600, true)
	var work_anchor: StringName = sector.get_npc_anchor(1, 600)
	var work_position: Vector3 = sector.get_npc_position(1)
	ok = ok and work_anchor == &"trabajo"
	ok = ok and work_position.distance_to(Vector3(8.0, 0.9, -8.0)) < 0.1
	var manager: SaveManagerService = SaveManagerService.new()
	var world: WorldStateService = WorldStateService.new()
	var clock: WorldClockService = WorldClockService.new()
	world.clear()
	world.set_phase(&"guerra")
	world.set_flag(&"pirca_levantada", 1)
	clock.autostart = false
	clock.set_time(2, 600.0)
	var campaign: StringName = StringName("test_grey_%d" % Time.get_ticks_msec())
	var slot: StringName = &"auto"
	ok = ok and manager.save_world(campaign, slot, world, clock, {"npc_count": 20})
	var loaded_world: WorldStateService = WorldStateService.new()
	var loaded_clock: WorldClockService = WorldClockService.new()
	loaded_clock.autostart = false
	var player: Dictionary = manager.load_world(campaign, slot, loaded_world, loaded_clock)
	ok = ok and loaded_world.get_phase() == &"guerra"
	ok = ok and loaded_world.get_flag(&"pirca_levantada") == 1
	ok = ok and loaded_clock.get_day() == 2
	ok = ok and loaded_clock.get_minute_of_day() == 600
	ok = ok and str(player.get("npc_count", "0")).to_int() == 20
	ok = ok and manager.delete_slot(campaign, slot)
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.SAVE_DIR.path_join(String(campaign)))
	)
	world.free()
	clock.free()
	loaded_world.free()
	loaded_clock.free()
	manager.free()
	sector.queue_free()
	await process_frame
	if ok:
		print("GREY_SECTOR_OK npcs=20 path=", path.size())
	else:
		printerr("GREY_SECTOR_FAIL")
	quit(0 if ok else 1)
