extends SceneTree
## Comprueba el streaming de los seis sectores sobre el terreno regional
## continuo: carga por cercanía, descarga al alejarse y sin cambio de escena.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const TIMEOUT_SECONDS: float = 5.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("REGION_STREAMING_FAIL no scene")
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
	for _i: int in 3:
		await process_frame
	var region: CampaignRegion = world.get_region()
	var ok: bool = region != null and region.get_terrain() != null
	ok = ok and streamer != null and streamer.sectors.size() == 6
	ok = ok and await _wait_loaded(streamer, &"s3_llacta")
	ok = ok and _marker_loaded(streamer, &"s3_llacta")
	world.set_target_position(Vector3(1200.0, 0.0, 400.0))
	ok = ok and await _wait_loaded(streamer, &"s1_cusco")
	world.set_target_position(Vector3(-1650.0, 0.0, 0.0))
	print(
		"DEBUG before s6 loaded=",
		streamer.get_loaded_ids(),
		" pending=",
		streamer.get_pending_ids()
	)
	ok = ok and await _wait_loaded(streamer, &"s6_frontera")
	print(
		"DEBUG after s6 loaded=", streamer.get_loaded_ids(), " pending=", streamer.get_pending_ids()
	)
	ok = ok and await _wait_unloaded(streamer, &"s3_llacta")
	ok = ok and await _wait_unloaded(streamer, &"s1_cusco")
	ok = ok and region.is_inside_tree() and region.get_terrain() != null
	ok = ok and failures.is_empty()
	var loaded: int = streamer.get_loaded_ids().size()
	print("REGION_STREAMING_OK sectors=6 loaded=", loaded, " failures=", failures.size())
	world.queue_free()
	await process_frame
	quit(0 if ok else 1)


func _marker_loaded(streamer: SectorStreamer, id: StringName) -> bool:
	var node: Node3D = streamer.get_loaded_node(id)
	return node is CampaignSectorMarker or node is LlactaBlockout or node is CuscoBlockout


func _wait_loaded(streamer: SectorStreamer, id: StringName) -> bool:
	var deadline: int = Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if streamer.is_loaded(id):
			return true
		await process_frame
	return false


func _wait_unloaded(streamer: SectorStreamer, id: StringName) -> bool:
	var deadline: int = Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if not streamer.is_loaded(id):
			return true
		await process_frame
	return false
