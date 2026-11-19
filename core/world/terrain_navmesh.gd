class_name TerrainNavmesh
extends RefCounted
## Hornea el navmesh de un sector a partir de las alturas de Terrain3D.
##
## Terrain3D no expone su malla ni su colisión como nodos de escena, así que
## `NavigationRegion3D.bake_navigation_mesh()` no puede verlas. Este módulo
## muestrea la altura del terreno, construye la geometría con la orientación
## que espera Recast y la hornea de forma síncrona. Los obstáculos se declaran
## como huellas en XZ y se proyectan sobre el terreno para recortar el navmesh.

## Protección contra bounds demasiado finos: por encima de este número de
## vértices el horneado bloquea el hilo principal y hay que subir el paso.
const MAX_VERTICES: int = 40000


## Devuelve el navmesh horneado, o `null` si faltan datos o el área es inválida.
static func bake(
	terrain: Terrain3D,
	bounds: AABB,
	profile: NavmeshProfile = null,
	obstacles: Array[PackedVector3Array] = [],
) -> NavigationMesh:
	if terrain == null or terrain.data == null:
		return null
	if bounds.size.x <= 0.0 or bounds.size.z <= 0.0:
		return null
	var settings: NavmeshProfile = profile if profile != null else NavmeshProfile.new()
	var geometry: NavigationMeshSourceGeometryData3D = _terrain_geometry(
		terrain, bounds, settings.step
	)
	if geometry == null:
		return null
	_add_obstructions(geometry, terrain, obstacles, settings)
	var navigation_mesh: NavigationMesh = _create_mesh(settings)
	NavigationServer3D.bake_from_source_geometry_data(navigation_mesh, geometry)
	return navigation_mesh


## Altura del terreno en un punto, o 0 si el terreno no tiene datos.
static func height_at(terrain: Terrain3D, point: Vector3) -> float:
	if terrain == null or terrain.data == null:
		return 0.0
	return terrain.data.get_height(point)


static func _create_mesh(settings: NavmeshProfile) -> NavigationMesh:
	var navigation_mesh: NavigationMesh = NavigationMesh.new()
	navigation_mesh.cell_size = settings.cell_size
	navigation_mesh.cell_height = settings.cell_height
	navigation_mesh.agent_radius = settings.agent_radius
	navigation_mesh.agent_height = settings.agent_height
	navigation_mesh.agent_max_climb = settings.agent_max_climb
	navigation_mesh.agent_max_slope = settings.agent_max_slope
	navigation_mesh.region_min_size = settings.region_min_size
	return navigation_mesh


static func _terrain_geometry(
	terrain: Terrain3D, bounds: AABB, step: float
) -> NavigationMeshSourceGeometryData3D:
	var safe_step: float = maxf(step, 0.5)
	var cells_x: int = maxi(ceili(bounds.size.x / safe_step), 1)
	var cells_z: int = maxi(ceili(bounds.size.z / safe_step), 1)
	var columns: int = cells_x + 1
	var rows: int = cells_z + 1
	if columns * rows > MAX_VERTICES:
		push_error(
			(
				"TerrainNavmesh: %d vértices supera el límite de %d; sube el paso."
				% [columns * rows, MAX_VERTICES]
			)
		)
		return null
	var vertices: PackedFloat32Array = PackedFloat32Array()
	vertices.resize(columns * rows * 3)
	var cursor: int = 0
	for row: int in rows:
		for column: int in columns:
			var wx: float = bounds.position.x + float(column) * safe_step
			var wz: float = bounds.position.z + float(row) * safe_step
			vertices[cursor] = wx
			vertices[cursor + 1] = height_at(terrain, Vector3(wx, bounds.position.y, wz))
			vertices[cursor + 2] = wz
			cursor += 3
	var indices: PackedInt32Array = PackedInt32Array()
	indices.resize(cells_x * cells_z * 6)
	var index_cursor: int = 0
	for row: int in cells_z:
		for column: int in cells_x:
			var corner: int = row * columns + column
			# Sentido antihorario visto desde arriba: Recast descarta lo demás.
			indices[index_cursor] = corner
			indices[index_cursor + 1] = corner + columns
			indices[index_cursor + 2] = corner + 1
			indices[index_cursor + 3] = corner + 1
			indices[index_cursor + 4] = corner + columns
			indices[index_cursor + 5] = corner + columns + 1
			index_cursor += 6
	var geometry: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	geometry.append_arrays(vertices, indices)
	return geometry


static func _add_obstructions(
	geometry: NavigationMeshSourceGeometryData3D,
	terrain: Terrain3D,
	obstacles: Array[PackedVector3Array],
	settings: NavmeshProfile,
) -> void:
	for footprint: PackedVector3Array in obstacles:
		if footprint.size() < 3:
			continue
		var ground: float = INF
		for point: Vector3 in footprint:
			ground = minf(ground, height_at(terrain, point))
		if is_inf(ground):
			continue
		geometry.add_projected_obstruction(
			footprint, ground - 0.5, settings.obstruction_height, true
		)
