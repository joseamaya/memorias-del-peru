extends SceneTree
## Comprueba una ruta entre dos regiones de navegación unidas por un enlace.
##
## La región A cubre x = 0..10 y la B x = 15..25, con un hueco de 5 m. El
## `NavigationLink3D` une (10,0,0) con (15,0,0), como una puerta o un escalón.

const TIMEOUT_FRAMES: int = 30


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var stage: Node3D = Node3D.new()
	root.add_child(stage)
	_add_region(stage, Vector3(0.0, 0.0, 0.0))
	_add_region(stage, Vector3(15.0, 0.0, 0.0))
	var link: NavigationLink3D = NavigationLink3D.new()
	link.start_position = Vector3(10.0, 0.0, 0.0)
	link.end_position = Vector3(15.0, 0.0, 0.0)
	link.bidirectional = true
	stage.add_child(link)
	var service: NavigationService = NavigationService.new()
	stage.add_child(service)
	var ok: bool = await _wait_for_map(service)
	# El mapa registra regiones antes de que el servidor termine de unirlas.
	for _settle: int in 8:
		await physics_frame
	var path: PackedVector3Array = service.find_path(
		Vector3(2.0, 0.0, 0.0), Vector3(22.0, 0.0, 0.0)
	)
	ok = ok and path.size() >= 4
	ok = ok and path[path.size() - 1].distance_to(Vector3(22.0, 0.0, 0.0)) < 0.5
	ok = ok and service.is_reachable(Vector3(2.0, 0.0, 0.0), Vector3(22.0, 0.0, 0.0))
	ok = ok and service.path_length(path) > 19.0
	var closest: Vector3 = service.closest_point(Vector3(12.0, 0.0, 0.0))
	ok = ok and closest.distance_to(Vector3(12.0, 0.0, 0.0)) < 10.0
	if ok:
		print("NAVIGATION_OK path=", path.size(), " length=", service.path_length(path))
	else:
		printerr("NAVIGATION_FAIL path=", path)
	stage.queue_free()
	await process_frame
	quit(0 if ok else 1)


func _wait_for_map(service: NavigationService) -> bool:
	for _frame: int in TIMEOUT_FRAMES:
		await physics_frame
		var map: RID = service.get_map()
		if service.is_map_ready() and NavigationServer3D.map_get_regions(map).size() >= 2:
			if NavigationServer3D.map_get_links(map).size() >= 1:
				return true
	return false


func _add_region(stage: Node3D, offset: Vector3) -> void:
	var navmesh: NavigationMesh = NavigationMesh.new()
	(
		navmesh
		. set_vertices(
			PackedVector3Array(
				[
					offset + Vector3(0.0, 0.0, -10.0),
					offset + Vector3(10.0, 0.0, -10.0),
					offset + Vector3(10.0, 0.0, 10.0),
					offset + Vector3(0.0, 0.0, 10.0),
				]
			)
		)
	)
	navmesh.add_polygon(PackedInt32Array([0, 1, 2]))
	navmesh.add_polygon(PackedInt32Array([0, 2, 3]))
	var region: NavigationRegion3D = NavigationRegion3D.new()
	region.navigation_mesh = navmesh
	stage.add_child(region)
