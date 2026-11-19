class_name NavigationService
extends Node3D
## Consulta rutas en el mapa de navegación del mundo.
##
## No crea ni hornea navmeshes: los sectores las aportan con
## `NavigationRegion3D` y los enlaces de puertas, escaleras y desniveles con
## `NavigationLink3D`. Este servicio solo resuelve consultas y mide rutas.

@export var optimize: bool = true

## Mapa alternativo para pruebas o para un mundo aislado. Vacío = mapa del
## `World3D` de este nodo.
var map_override: RID = RID()


## Mapa de navegación activo, o un RID vacío si el nodo no está en el árbol.
func get_map() -> RID:
	if map_override.is_valid():
		return map_override
	if not is_inside_tree():
		return RID()
	return get_world_3d().navigation_map


## Indica si el mapa existe y está activo.
func is_map_ready() -> bool:
	var map: RID = get_map()
	return map.is_valid() and NavigationServer3D.map_is_active(map)


## Ruta entre dos puntos. Devuelve un array vacío si no hay mapa o no hay ruta.
func find_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var map: RID = get_map()
	if not map.is_valid() or not NavigationServer3D.map_is_active(map):
		return PackedVector3Array()
	return NavigationServer3D.map_get_path(map, from, to, optimize)


## Indica si existe una ruta con al menos dos puntos.
func is_reachable(from: Vector3, to: Vector3) -> bool:
	return find_path(from, to).size() >= 2


## Longitud acumulada de una ruta.
func path_length(path: PackedVector3Array) -> float:
	var length: float = 0.0
	for index: int in range(1, path.size()):
		length += path[index - 1].distance_to(path[index])
	return length


## Punto de navegación más cercano a una posición, o la misma posición si no
## hay mapa.
func closest_point(point: Vector3) -> Vector3:
	var map: RID = get_map()
	if not map.is_valid() or not NavigationServer3D.map_is_active(map):
		return point
	return NavigationServer3D.map_get_closest_point(map, point)
