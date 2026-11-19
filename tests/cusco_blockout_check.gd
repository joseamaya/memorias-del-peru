extends SceneTree
## Comprueba el blockout de S1: ayllus, Coricancha, mercado, talleres y rutas.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const TIMEOUT_SECONDS: float = 5.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("CUSCO_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	world.autowalk = false
	world.set_target_position(Vector3(1200.0, 0.0, 400.0))
	var streamer: SectorStreamer = world.get_streamer()
	var ok: bool = await _wait_loaded(streamer, &"s1_cusco")
	for _i: int in 5:
		await process_frame
	var blockout: CuscoBlockout = streamer.get_loaded_node(&"s1_cusco") as CuscoBlockout
	ok = ok and blockout != null
	ok = ok and blockout.get_house_count() >= 24
	ok = ok and blockout.get_poi_count() >= 6
	ok = ok and blockout.get_mesh_count() > 60
	ok = ok and blockout.get_collision_count() >= blockout.get_house_count()
	var routes: CampaignRoutes = world.get_node("Routes") as CampaignRoutes
	var region: CampaignRegion = world.get_region()
	var cusco: Vector3 = _ground(region, Vector3(1200.0, 0.0, 400.0))
	var afueras: Vector3 = _ground(region, Vector3(750.0, 0.0, 150.0))
	var llacta: Vector3 = _ground(region, Vector3(300.0, 0.0, 0.0))
	var to_afueras: PackedVector3Array = PackedVector3Array()
	var to_llacta: PackedVector3Array = PackedVector3Array()
	for _retry: int in 30:
		to_afueras = routes.get_navmesh_path(cusco, afueras)
		to_llacta = routes.get_navmesh_path(cusco, llacta)
		if to_afueras.size() >= 2 and to_llacta.size() >= 2:
			break
		await process_frame
	ok = ok and to_afueras.size() >= 2
	ok = ok and to_llacta.size() >= 2
	print(
		"CUSCO houses=",
		blockout.get_house_count(),
		" pois=",
		blockout.get_poi_count(),
		" meshes=",
		blockout.get_mesh_count(),
		" collisions=",
		blockout.get_collision_count()
	)
	var houses: int = blockout.get_house_count()
	var pois: int = blockout.get_poi_count()
	world.queue_free()
	await process_frame
	if ok:
		print("CUSCO_OK houses=", houses, " pois=", pois)
	else:
		printerr("CUSCO_FAIL")
	quit(0 if ok else 1)


func _wait_loaded(streamer: SectorStreamer, id: StringName) -> bool:
	var deadline: int = Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if streamer.is_loaded(id):
			return true
		await process_frame
	return false


func _ground(region: CampaignRegion, point: Vector3) -> Vector3:
	return Vector3(point.x, region.height_at(point.x, point.z), point.z)
