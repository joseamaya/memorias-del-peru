class_name CampaignRoutes
extends Node3D
## Red de rutas de blockout y navmesh por sector.
##
## Las rutas son datos (`CampaignRoute`); este nodo dibuja una cinta sobre el
## terreno y hornea un navmesh por sector para que el recorrido sea continuo.
## La geometría es de blockout: no es el camino final ni arte.

const ROUTE_PATHS: Array[String] = [
	"res://campaigns/01_pachacutec/data/routes/r1_camino_principal.tres",
	"res://campaigns/01_pachacutec/data/routes/r2_ruta_del_paso.tres",
	"res://campaigns/01_pachacutec/data/routes/r3_ruta_del_rio.tres",
	"res://campaigns/01_pachacutec/data/routes/r4_sendero_pastores.tres",
	"res://campaigns/01_pachacutec/data/routes/r5_ruta_oculta.tres",
	"res://campaigns/01_pachacutec/data/routes/r6_callejones_cusco.tres",
	"res://campaigns/01_pachacutec/data/routes/r7_acequia_madre.tres",
	"res://campaigns/01_pachacutec/data/routes/r8_camino_frontera.tres",
]

const SECTOR_BOUNDS: Dictionary[StringName, Vector2] = {
	&"s1_cusco": Vector2(175.0, 150.0),
	&"s2_afueras": Vector2(200.0, 150.0),
	&"s3_llacta": Vector2(150.0, 125.0),
	&"s4_quebrada": Vector2(200.0, 150.0),
	&"s5_paso": Vector2(165.0, 150.0),
	&"s6_frontera": Vector2(200.0, 175.0),
}
const NAVMESH_STEP: float = 6.0
const LINK_POINTS: Array[Vector3] = [
	Vector3(1040.0, 0.0, 320.0),
	Vector3(940.0, 0.0, 250.0),
	Vector3(440.0, 0.0, 80.0),
	Vector3(570.0, 0.0, 130.0),
	Vector3(160.0, 0.0, 110.0),
	Vector3(-520.0, 0.0, 260.0),
	Vector3(-870.0, 0.0, 330.0),
	Vector3(-1160.0, 0.0, 190.0),
	Vector3(-1450.0, 0.0, 90.0),
	Vector3(-1520.0, 0.0, 40.0),
]
const RIBBON_STEP: float = 1.5
## La cinta es solo visual y no tiene colisión: se apoya en el terreno. Con
## 0,8 m quedaba a la altura del pecho y tapaba la vista al caminar.
const RIBBON_LIFT: float = 0.15

var _routes: Array[CampaignRoute] = []
var _meshes: Array[MeshInstance3D] = []
var _regions: Array[NavigationRegion3D] = []
var _bake_ms: int = 0


func _ready() -> void:
	var start: int = Time.get_ticks_msec()
	for path: String in ROUTE_PATHS:
		var route: CampaignRoute = load(path) as CampaignRoute
		if route != null and route.is_valid():
			_routes.append(route)
	_build_ribbons()
	_build_navmeshes()
	_bake_ms = Time.get_ticks_msec() - start
	_build_links_async()


func get_route(id: StringName) -> CampaignRoute:
	for route: CampaignRoute in _routes:
		if route.id == id:
			return route
	return null


func get_route_count() -> int:
	return _routes.size()


func get_mesh_count() -> int:
	return _meshes.size()


func get_region_count() -> int:
	return _regions.size()


func get_bake_ms() -> int:
	return _bake_ms


func get_navmesh_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	if not is_inside_tree():
		return PackedVector3Array()
	var map: RID = get_world_3d().navigation_map
	if not map.is_valid() or not NavigationServer3D.map_is_active(map):
		return PackedVector3Array()
	return NavigationServer3D.map_get_path(map, from, to, true)


func _build_ribbons() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.46, 0.38, 0.27)
	material.roughness = 1.0
	for route: CampaignRoute in _routes:
		var mesh: ArrayMesh = _ribbon_mesh(route)
		if mesh == null:
			continue
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.name = "Route_%s" % route.id
		instance.mesh = mesh
		instance.material_override = material
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(instance)
		_meshes.append(instance)


func _ribbon_mesh(route: CampaignRoute) -> ArrayMesh:
	var terrain: Terrain3D = _get_terrain()
	if terrain == null:
		return null
	var centers: PackedVector3Array = PackedVector3Array()
	for index: int in range(route.points.size() - 1):
		var from: Vector3 = route.points[index]
		var to: Vector3 = route.points[index + 1]
		var distance: float = from.distance_to(to)
		var steps: int = maxi(ceili(distance / RIBBON_STEP), 1)
		for step: int in steps:
			var t: float = float(step) / float(steps)
			var point: Vector3 = from.lerp(to, t)
			centers.append(_on_terrain(terrain, point, RIBBON_LIFT))
	centers.append(_on_terrain(terrain, route.points[route.points.size() - 1], RIBBON_LIFT))
	if centers.size() < 2:
		return null
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var half_width: float = route.width * 0.5
	for index: int in centers.size():
		var direction: Vector3 = _direction(centers, index)
		var side: Vector3 = Vector3(-direction.z, 0.0, direction.x).normalized() * half_width
		# Cada borde se apoya en su propia altura: en una ladera transversal,
		# heredar la altura del centro dejaba el borde cuesta abajo flotando.
		vertices.append(_on_terrain(terrain, centers[index] + side, RIBBON_LIFT))
		vertices.append(_on_terrain(terrain, centers[index] - side, RIBBON_LIFT))
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
	for index: int in range(centers.size() - 1):
		var base: int = index * 2
		indices.append_array([base, base + 1, base + 2])
		indices.append_array([base + 1, base + 3, base + 2])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _direction(points: PackedVector3Array, index: int) -> Vector3:
	var from: Vector3 = points[maxi(index - 1, 0)]
	var to: Vector3 = points[mini(index + 1, points.size() - 1)]
	var flat: Vector3 = Vector3(to.x - from.x, 0.0, to.z - from.z)
	if flat.length_squared() < 0.0001:
		return Vector3.FORWARD
	return flat.normalized()


func _on_terrain(terrain: Terrain3D, point: Vector3, lift: float) -> Vector3:
	# `get_height` devuelve el dato de la heightmap; la superficie que se ve y
	# se pisa es la interpolada. Usar la primera dejaba la cinta hasta 4 m por
	# encima del terreno en las laderas.
	var height: float = terrain.data.get_surface_height(point)
	if is_nan(height):
		height = terrain.data.get_height(point)
	return Vector3(point.x, height + lift, point.z)


func _build_navmeshes() -> void:
	var terrain: Terrain3D = _get_terrain()
	if terrain == null:
		push_error("CampaignRoutes: falta el terreno regional.")
		return
	for id: StringName in CampaignRegion.SECTORS.keys():
		var center: Vector3 = CampaignRegion.SECTORS[id]
		var extents: Vector2 = SECTOR_BOUNDS.get(id, Vector2(150.0, 125.0))
		var bounds: AABB = AABB(
			Vector3(center.x - extents.x, -2.0, center.z - extents.y),
			Vector3(extents.x * 2.0, 10.0, extents.y * 2.0)
		)
		var profile: NavmeshProfile = NavmeshProfile.new()
		profile.step = NAVMESH_STEP
		var navmesh: NavigationMesh = TerrainNavmesh.bake(terrain, bounds, profile)
		if navmesh == null or navmesh.get_polygon_count() == 0:
			push_error("CampaignRoutes: no se pudo hornear el sector %s." % id)
			continue
		var region: NavigationRegion3D = NavigationRegion3D.new()
		region.name = "SectorNavmesh_%s" % id
		region.navigation_mesh = navmesh
		add_child(region)
		_regions.append(region)
	# Los enlaces se crean en `_process`, cuando el mapa ya sincronizó las
	# regiones y puede proyectar sus extremos sobre el navmesh.


## Espera a que el mapa sincronice las regiones y crea los enlaces entre
## sectores con sus extremos proyectados sobre el navmesh.
func _build_links_async() -> void:
	for _frame: int in 60:
		await get_tree().process_frame
		var map: RID = get_world_3d().navigation_map
		if not NavigationServer3D.map_is_active(map):
			continue
		if NavigationServer3D.map_get_regions(map).size() < _regions.size():
			continue
		if NavigationServer3D.map_get_iteration_id(map) == 0:
			continue
		if _create_links(map) == LINK_POINTS.size() / 2:
			return


func _create_links(map: RID) -> int:
	var terrain: Terrain3D = _get_terrain()
	if terrain == null:
		return 0
	var starts: Array[Vector3] = []
	var ends: Array[Vector3] = []
	for index: int in range(0, LINK_POINTS.size() - 1, 2):
		var start_hint: Vector3 = _on_terrain(terrain, LINK_POINTS[index], 0.5)
		var end_hint: Vector3 = _on_terrain(terrain, LINK_POINTS[index + 1], 0.5)
		var start: Vector3 = NavigationServer3D.map_get_closest_point(map, start_hint)
		var end: Vector3 = NavigationServer3D.map_get_closest_point(map, end_hint)
		if start.is_zero_approx() or end.is_zero_approx():
			return 0
		starts.append(start)
		ends.append(end)
	for index: int in starts.size():
		var link: NavigationLink3D = NavigationLink3D.new()
		link.name = "SectorLink_%d" % index
		link.start_position = starts[index]
		link.end_position = ends[index]
		link.bidirectional = true
		add_child(link)
	return starts.size()


func _get_terrain() -> Terrain3D:
	var region: CampaignRegion = (
		get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	)
	if region == null:
		return null
	return region.get_terrain()
