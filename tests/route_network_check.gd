extends SceneTree
## Comprueba la red de rutas de F2.3: ocho rutas dibujadas, seis navmeshes de
## sector y rutas continuas entre la llacta, el Cusco y la frontera.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const TIMEOUT_SECONDS: float = 5.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("ROUTES_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	world.first_person = false
	root.add_child(world)
	world.autowalk = false
	var routes: CampaignRoutes = world.get_node("Routes") as CampaignRoutes
	var region: CampaignRegion = world.get_region()
	var map: RID = world.get_world_3d().navigation_map
	var ok: bool = routes != null and region != null
	for _i: int in 10:
		await process_frame
	ok = ok and await _wait_map(map, 6)
	ok = ok and routes.get_route_count() == 8
	ok = ok and routes.get_mesh_count() == 8
	ok = ok and routes.get_region_count() == 6
	var llacta: Vector3 = _ground(region, Vector3(300.0, 0.0, 0.0))
	var cusco: Vector3 = _ground(region, Vector3(1200.0, 0.0, 400.0))
	var frontera: Vector3 = _ground(region, Vector3(-1650.0, 0.0, 0.0))
	var to_cusco: PackedVector3Array = PackedVector3Array()
	var to_frontera: PackedVector3Array = PackedVector3Array()
	for _retry: int in 30:
		to_cusco = routes.get_navmesh_path(llacta, cusco)
		to_frontera = routes.get_navmesh_path(llacta, frontera)
		if to_cusco.size() >= 2 and to_frontera.size() >= 2:
			break
		await process_frame
	ok = ok and to_cusco.size() >= 2 and _length(to_cusco) > 800.0
	ok = ok and to_frontera.size() >= 2 and _length(to_frontera) > 1800.0
	print(
		"ROUTES routes=",
		routes.get_route_count(),
		" regions=",
		routes.get_region_count(),
		" bake_ms=",
		routes.get_bake_ms(),
		" path_cusco=",
		int(_length(to_cusco)),
		" path_frontera=",
		int(_length(to_frontera))
	)
	world.queue_free()
	await process_frame
	if ok:
		print("ROUTES_OK routes=8 regions=6")
	else:
		printerr("ROUTES_FAIL")
	quit(0 if ok else 1)


func _wait_map(map: RID, regions: int) -> bool:
	var deadline: int = Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if NavigationServer3D.map_is_active(map):
			if NavigationServer3D.map_get_regions(map).size() >= regions:
				return true
	return false


func _ground(region: CampaignRegion, point: Vector3) -> Vector3:
	return Vector3(point.x, region.height_at(point.x, point.z), point.z)


func _length(path: PackedVector3Array) -> float:
	var total: float = 0.0
	for index: int in range(1, path.size()):
		total += path[index - 1].distance_to(path[index])
	return total
