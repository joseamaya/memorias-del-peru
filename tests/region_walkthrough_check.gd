extends SceneTree
## Recorrido continuo Cusco → frontera sobre el mundo regional.
##
## Avanza el objetivo por el navmesh en pasos de 20 m, espera la carga de los
## sectores de cada celda y comprueba que no hay bloqueos, saltos de escena ni
## fallos de carga. Calcula el tiempo a pie a 2 m/s; la prueba humana queda
## fuera de la CI.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const STEP_METERS: float = 20.0
const WALK_SPEED: float = 2.0
const SECTOR_IDS: Array[StringName] = [
	&"s1_cusco",
	&"s2_afueras",
	&"s3_llacta",
	&"s4_quebrada",
	&"s5_paso",
	&"s6_frontera",
]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var state: WorldStateService = root.get_node_or_null("WorldState") as WorldStateService
	if state != null:
		state.clear()
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("WALKTHROUGH_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	world.first_person = false
	root.add_child(world)
	world.autowalk = false
	var failures: Array[StringName] = []
	var streamer: SectorStreamer = world.get_streamer()
	streamer.sector_load_failed.connect(
		func(id: StringName, _error: int) -> void: failures.append(id)
	)
	var routes: CampaignRoutes = world.get_node("Routes") as CampaignRoutes
	var discovery: DiscoveryService = world.get_discovery()
	var region: CampaignRegion = world.get_region()
	world.set_target_position(Vector3(1200.0, 0.0, 400.0))
	var ok: bool = await _wait_loaded(streamer, &"s1_cusco")
	var map: RID = world.get_world_3d().navigation_map
	for _i: int in 10:
		await process_frame
	ok = ok and await _wait_map(map)
	var cusco: Vector3 = _ground(region, Vector3(1200.0, 0.0, 400.0))
	var frontera: Vector3 = _ground(region, Vector3(-1650.0, 0.0, 0.0))
	var path: PackedVector3Array = PackedVector3Array()
	for _retry: int in 30:
		path = routes.get_navmesh_path(cusco, frontera)
		if path.size() >= 2:
			break
		await process_frame
	ok = ok and path.size() >= 2
	if not ok:
		printerr("WALKTHROUGH_FAIL path")
		world.queue_free()
		await process_frame
		quit(1)
		return
	var samples: PackedVector3Array = _sample_path(path, STEP_METERS)
	var seen: Dictionary[StringName, bool] = {}
	for point: Vector3 in samples:
		world.set_target_position(point)
		await process_frame
		await process_frame
		var cell: Vector2i = streamer.get_cell_for_position(point)
		if not await _wait_needed(streamer, cell):
			ok = false
			break
		for id: StringName in streamer.get_loaded_ids():
			seen[id] = true
		if not _is_walkable(map, routes, point):
			ok = false
			printerr("WALKTHROUGH_FAIL navmesh at ", point)
			break
	for id: StringName in SECTOR_IDS:
		ok = ok and seen.has(id)
	ok = ok and streamer.is_loaded(&"s6_frontera")
	ok = ok and not streamer.is_loaded(&"s1_cusco")
	ok = ok and failures.is_empty()
	ok = ok and region.is_inside_tree() and region.get_terrain() != null
	ok = ok and discovery != null and discovery.get_discovered_count() >= 8
	ok = ok and discovery.get_map_points().size() == discovery.get_discovered_count()
	ok = ok and _check_save()
	var length: float = _path_length(path)
	var minutes: float = length / WALK_SPEED / 60.0
	ok = ok and minutes >= 20.0 and minutes <= 40.0
	print(
		"WALKTHROUGH path_m=",
		int(length),
		" walk_min=",
		snappedf(minutes, 0.1),
		" sectors=",
		seen.size(),
		" pois=",
		discovery.get_discovered_count(),
		" failures=",
		failures.size()
	)
	world.queue_free()
	await process_frame
	if ok:
		print("WALKTHROUGH_OK sectors=6")
	else:
		printerr("WALKTHROUGH_FAIL")
	quit(0 if ok else 1)


func _is_walkable(map: RID, routes: CampaignRoutes, point: Vector3) -> bool:
	var closest: Vector3 = NavigationServer3D.map_get_closest_point(map, point)
	if Vector2(closest.x - point.x, closest.z - point.z).length() <= 4.0:
		return true
	for child: Node in routes.get_children():
		if child is NavigationLink3D:
			var link: NavigationLink3D = child as NavigationLink3D
			if _point_to_segment(point, link.start_position, link.end_position) <= 5.0:
				return true
	return false


func _point_to_segment(point: Vector3, from: Vector3, to: Vector3) -> float:
	var flat: Vector3 = Vector3(to.x - from.x, 0.0, to.z - from.z)
	var length_squared: float = flat.length_squared()
	if length_squared < 0.0001:
		return Vector2(point.x - from.x, point.z - from.z).length()
	var relative: Vector3 = Vector3(point.x - from.x, 0.0, point.z - from.z)
	var t: float = clampf(relative.dot(flat) / length_squared, 0.0, 1.0)
	var closest: Vector3 = from + flat * t
	return Vector2(point.x - closest.x, point.z - closest.z).length()


func _sample_path(path: PackedVector3Array, step: float) -> PackedVector3Array:
	var samples: PackedVector3Array = PackedVector3Array()
	for index: int in range(1, path.size()):
		var from: Vector3 = path[index - 1]
		var to: Vector3 = path[index]
		var distance: float = from.distance_to(to)
		var offset: float = 0.0
		while offset < distance:
			samples.append(from.lerp(to, offset / distance))
			offset += step
	samples.append(path[path.size() - 1])
	return samples


func _wait_map(map: RID) -> bool:
	var deadline: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if NavigationServer3D.map_is_active(map):
			if NavigationServer3D.map_get_iteration_id(map) > 0:
				return true
	return false


func _wait_loaded(streamer: SectorStreamer, id: StringName) -> bool:
	var deadline: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline:
		if streamer.is_loaded(id):
			return true
		await process_frame
	return false


func _wait_needed(streamer: SectorStreamer, cell: Vector2i) -> bool:
	var deadline: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline:
		var ready: bool = true
		for definition: SectorDefinition in streamer.get_needed_definitions(cell):
			if not streamer.is_loaded(definition.id):
				ready = false
				break
		if ready:
			return true
		await process_frame
	return false


func _check_save() -> bool:
	var manager: SaveManagerService = SaveManagerService.new()
	var state: WorldStateService = root.get_node_or_null("WorldState") as WorldStateService
	if state == null:
		return false
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.set_time(4, 900.0)
	var campaign: StringName = StringName("test_walk_%d" % Time.get_ticks_msec())
	var slot: StringName = &"auto"
	var ok: bool = manager.save_world(campaign, slot, state, clock, {})
	var loaded_world: WorldStateService = WorldStateService.new()
	var loaded_clock: WorldClockService = WorldClockService.new()
	loaded_clock.autostart = false
	manager.load_world(campaign, slot, loaded_world, loaded_clock)
	ok = ok and loaded_world.is_discovered(&"poi_17")
	ok = ok and loaded_world.get_discoveries().size() == state.get_discoveries().size()
	ok = ok and manager.delete_slot(campaign, slot)
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(campaign)))
	)
	loaded_world.free()
	loaded_clock.free()
	clock.free()
	manager.free()
	return ok


func _ground(region: CampaignRegion, point: Vector3) -> Vector3:
	return Vector3(point.x, region.height_at(point.x, point.z), point.z)


func _path_length(path: PackedVector3Array) -> float:
	var total: float = 0.0
	for index: int in range(1, path.size()):
		total += path[index - 1].distance_to(path[index])
	return total
