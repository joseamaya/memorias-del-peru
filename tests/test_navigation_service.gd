extends RefCounted
## Comprueba la consulta de rutas fuera del árbol y la longitud de una ruta.


func test_navigation_service_off_tree() -> bool:
	var service: NavigationService = NavigationService.new()
	var ok: bool = not service.is_map_ready()
	ok = ok and service.find_path(Vector3.ZERO, Vector3.ONE).is_empty()
	ok = ok and not service.is_reachable(Vector3.ZERO, Vector3.ONE)
	ok = ok and service.closest_point(Vector3(1.0, 2.0, 3.0)) == Vector3(1.0, 2.0, 3.0)
	service.free()
	return ok


func test_navigation_service_path_length() -> bool:
	var service: NavigationService = NavigationService.new()
	var path: PackedVector3Array = PackedVector3Array(
		[
			Vector3(0.0, 0.0, 0.0),
			Vector3(3.0, 0.0, 0.0),
			Vector3(3.0, 0.0, 4.0),
		]
	)
	var length: float = service.path_length(path)
	var ok: bool = is_equal_approx(length, 7.0)
	ok = ok and is_zero_approx(service.path_length(PackedVector3Array()))
	service.free()
	return ok
