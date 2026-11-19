extends SceneTree
## Comprueba el sector gris de integración: Terrain3D, pirca Cyclops, navmesh
## horneado sobre el terreno, 20 NPC en ruta y guardado/carga.

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
	var ok: bool = sector.get_npc_count() == 20
	var terrain: Terrain3D = sector.get_terrain()
	ok = ok and terrain != null and terrain.data != null
	ok = ok and terrain.data.get_region_count() >= 1
	var block: CyclopsBlock = sector.get_cyclops_block()
	ok = ok and block != null and block.mesh_instance != null
	ok = ok and block.mesh_instance.mesh != null
	ok = ok and block.collision_shape != null and block.collision_shape.shape != null
	ok = ok and _check_navmesh(sector)
	ok = ok and _check_routes(sector)
	ok = ok and _check_walk(sector)
	ok = ok and _check_save_load()
	var polygons: int = 0
	if sector.get_navmesh() != null:
		polygons = sector.get_navmesh().get_polygon_count()
	sector.queue_free()
	await process_frame
	if ok:
		print("GREY_SECTOR_OK npcs=20 navmesh_polys=", polygons)
	else:
		printerr("GREY_SECTOR_FAIL")
	quit(0 if ok else 1)


## El navmesh cubre el terreno y tiene relieve, no es una plaza plana.
func _check_navmesh(sector: GreySector) -> bool:
	var navmesh: NavigationMesh = sector.get_navmesh()
	if navmesh == null or navmesh.get_polygon_count() <= 0:
		return false
	if sector.get_navigation_region() == null:
		return false
	var minimum: float = INF
	var maximum: float = -INF
	for vertex: Vector3 in navmesh.get_vertices():
		minimum = minf(minimum, vertex.y)
		maximum = maxf(maximum, vertex.y)
	return minimum < 0.5 and maximum > 1.5


## Las rutas llegan a pie hasta el campo y rodean la pirca.
func _check_routes(sector: GreySector) -> bool:
	var home: Vector3 = sector.get_anchor_position(&"casa")
	var field: Vector3 = sector.get_anchor_position(&"campo")
	var to_field: PackedVector3Array = sector.get_navmesh_path(home, field)
	var field_ok: bool = to_field.size() >= 2 and to_field[to_field.size() - 1].y > 1.0
	var detour: PackedVector3Array = sector.get_navmesh_path(
		Vector3(0.0, 0.0, -10.0), Vector3(0.0, 0.0, -26.0)
	)
	var detour_ok: bool = false
	for point: Vector3 in detour:
		if absf(point.x) >= 3.5:
			detour_ok = true
	return field_ok and detour_ok


## Los 20 NPC cambian de ancla y llegan caminando por el navmesh.
func _check_walk(sector: GreySector) -> bool:
	sector.update_npcs(200, true)
	if sector.get_npc_anchor(0, 200) != &"casa":
		return false
	if sector.get_npc_position(0).distance_to(sector.get_npc_goal_position(0)) > 0.1:
		return false
	sector.update_npcs(600, false)
	if sector.get_npc_target(0) != &"campo" or sector.get_npc_target(1) != &"trabajo":
		return false
	sector.advance_npcs(90.0, 0.2)
	var arrived: bool = true
	for index: int in sector.get_npc_count():
		if not sector.is_npc_at_target(index, 0.9):
			arrived = false
	var work_ok: bool = (
		sector.get_npc_position(1).distance_to(sector.get_npc_goal_position(1)) < 0.9
	)
	var field_ok: bool = (
		sector.get_npc_position(0).distance_to(sector.get_npc_goal_position(0)) < 0.9
	)
	return arrived and work_ok and field_ok


func _check_save_load() -> bool:
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
	var ok: bool = manager.save_world(campaign, slot, world, clock, {"npc_count": 20})
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
	return ok
