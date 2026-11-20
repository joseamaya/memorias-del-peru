extends SceneTree
## Comprueba los blockouts de S4, S5 y S6: contenido, colisiones y rutas.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const TIMEOUT_SECONDS: float = 5.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("FRONTERA_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	world.first_person = false
	root.add_child(world)
	world.autowalk = false
	var streamer: SectorStreamer = world.get_streamer()
	world.set_target_position(Vector3(-700.0, 0.0, 350.0))
	var ok: bool = await _wait_loaded(streamer, &"s4_quebrada")
	for _i: int in 4:
		await process_frame
	var quebrada: QuebradaBlockout = streamer.get_loaded_node(&"s4_quebrada") as QuebradaBlockout
	ok = ok and quebrada != null
	ok = ok and quebrada.get_poi_count() >= 5
	ok = ok and quebrada.get_mesh_count() >= 20
	ok = ok and quebrada.get_collision_count() >= 8
	world.set_target_position(Vector3(-1300.0, 0.0, 100.0))
	ok = ok and await _wait_loaded(streamer, &"s5_paso")
	for _i: int in 4:
		await process_frame
	var paso: PasoBlockout = streamer.get_loaded_node(&"s5_paso") as PasoBlockout
	ok = ok and paso != null
	ok = ok and paso.get_poi_count() >= 3
	ok = ok and paso.get_mesh_count() >= 8
	ok = ok and paso.get_collision_count() >= 4
	world.set_target_position(Vector3(-1650.0, 0.0, 0.0))
	ok = ok and await _wait_loaded(streamer, &"s6_frontera")
	for _i: int in 4:
		await process_frame
	var frontera: FronteraBlockout = streamer.get_loaded_node(&"s6_frontera") as FronteraBlockout
	ok = ok and frontera != null
	ok = ok and frontera.get_poi_count() >= 5
	ok = ok and frontera.get_mesh_count() >= 25
	ok = ok and frontera.get_collision_count() >= 8
	var routes: CampaignRoutes = world.get_node("Routes") as CampaignRoutes
	var region: CampaignRegion = world.get_region()
	var paso_center: Vector3 = _ground(region, Vector3(-1300.0, 0.0, 100.0))
	var frontera_center: Vector3 = _ground(region, Vector3(-1650.0, 0.0, 0.0))
	var quebrada_center: Vector3 = _ground(region, Vector3(-700.0, 0.0, 350.0))
	var llacta: Vector3 = _ground(region, Vector3(300.0, 0.0, 0.0))
	var to_frontera: PackedVector3Array = PackedVector3Array()
	var to_llacta: PackedVector3Array = PackedVector3Array()
	for _retry: int in 30:
		to_frontera = routes.get_navmesh_path(paso_center, frontera_center)
		to_llacta = routes.get_navmesh_path(quebrada_center, llacta)
		if to_frontera.size() >= 2 and to_llacta.size() >= 2:
			break
		await process_frame
	ok = ok and to_frontera.size() >= 2
	ok = ok and to_llacta.size() >= 2
	print(
		"FRONTERA s4_pois=",
		quebrada.get_poi_count(),
		" s5_pois=",
		paso.get_poi_count(),
		" s6_pois=",
		frontera.get_poi_count(),
		" s6_meshes=",
		frontera.get_mesh_count()
	)
	world.queue_free()
	await process_frame
	if ok:
		print("FRONTERA_OK s4=5 s5=3 s6=5")
	else:
		printerr("FRONTERA_FAIL")
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
