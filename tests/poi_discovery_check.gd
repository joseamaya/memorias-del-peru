extends SceneTree
## Comprueba los 31 POI: inicio, proximidad, diario, mapa, fases y guardado.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveManagerService.set_save_root("user://test-saves")
	var state: WorldStateService = root.get_node_or_null("WorldState") as WorldStateService
	if state != null:
		state.clear()
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("POI_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	world.first_person = false
	root.add_child(world)
	world.autowalk = false
	world.set_target_position(Vector3(300.0, 0.0, 0.0))
	for _i: int in 5:
		await process_frame
	var discovery: DiscoveryService = world.get_discovery()
	var ok: bool = discovery != null and discovery.get_count() == 31
	ok = ok and discovery.is_discovered(&"poi_01") and discovery.is_discovered(&"poi_02")
	ok = ok and discovery.get_journal().size() >= 2
	ok = ok and discovery.get_map_points().size() == discovery.get_discovered_count()
	world.set_target_position(Vector3(355.0, 0.0, 45.0))
	for _i: int in 6:
		await process_frame
	ok = ok and discovery.is_discovered(&"poi_03")
	world.set_target_position(Vector3(1200.0, 0.0, 400.0))
	for _i: int in 6:
		await process_frame
	ok = ok and discovery.is_discovered(&"poi_17")
	world.set_target_position(Vector3(-1215.0, 0.0, 170.0))
	for _i: int in 6:
		await process_frame
	ok = ok and discovery.is_discovered(&"poi_23")
	ok = ok and not discovery.is_discovered(&"poi_29")
	discovery.world_stage = 0
	ok = ok and not discovery.discover(&"poi_28")
	discovery.world_stage = 2
	discovery.discover(&"poi_28")
	ok = ok and discovery.is_discovered(&"poi_28")
	ok = ok and discovery.get_map_points().size() == discovery.get_discovered_count()
	ok = ok and _journal_has(discovery, "Casa de la familia")
	ok = ok and _check_save()
	var discovered: int = discovery.get_discovered_count()
	world.queue_free()
	await process_frame
	if ok:
		print("POI_OK total=31 discovered=", discovered, " start=2")
	else:
		printerr("POI_FAIL")
	quit(0 if ok else 1)


func _journal_has(discovery: DiscoveryService, name: String) -> bool:
	for entry: Dictionary in discovery.get_journal():
		if str(entry.get("name", "")) == name:
			return true
	return false


func _check_save() -> bool:
	var manager: SaveManagerService = SaveManagerService.new()
	var state: WorldStateService = root.get_node_or_null("WorldState") as WorldStateService
	if state == null:
		return false
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.set_time(3, 720.0)
	var campaign: StringName = StringName("test_poi_%d" % Time.get_ticks_msec())
	var slot: StringName = &"auto"
	var ok: bool = manager.save_world(campaign, slot, state, clock, {})
	var loaded_world: WorldStateService = WorldStateService.new()
	var loaded_clock: WorldClockService = WorldClockService.new()
	loaded_clock.autostart = false
	manager.load_world(campaign, slot, loaded_world, loaded_clock)
	ok = ok and loaded_world.is_discovered(&"poi_03")
	ok = ok and loaded_world.is_discovered(&"poi_28")
	ok = ok and manager.delete_slot(campaign, slot)
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.save_root().path_join(String(campaign)))
	)
	loaded_world.free()
	loaded_clock.free()
	clock.free()
	manager.free()
	return ok
