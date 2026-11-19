class_name GreyBlockout
extends Node3D
## Blockout de prueba para F1.7: casas y pircas de Cyclops, multitud ambiente y
## ichu en MultiMesh.
##
## No es contenido de campaña ni arte final: es geometría de presupuesto para
## medir draw calls, VRAM y FPS antes del blockout de F2.

const HOUSE_SPOTS: Array[Vector3] = [
	Vector3(-22.0, 0.0, 6.0),
	Vector3(-24.0, 0.0, 24.0),
	Vector3(8.0, 0.0, 26.0),
	Vector3(30.0, 0.0, 12.0),
	Vector3(-26.0, 0.0, -10.0),
	Vector3(34.0, 0.0, -10.0),
]
const HOUSE_SIZE: Vector3 = Vector3(6.0, 2.6, 4.5)
const ROOF_SIZE: Vector3 = Vector3(6.8, 0.35, 5.2)

var _terrain: Terrain3D = null
var _house_count: int = 0
var _crowd_instance: MultiMeshInstance3D = null
var _vegetation_instance: MultiMeshInstance3D = null


func build(terrain: Terrain3D, with_houses: bool, crowd_count: int, vegetation_count: int) -> void:
	_terrain = terrain
	if with_houses:
		_build_houses()
	if crowd_count > 0:
		_build_crowd(crowd_count)
	if vegetation_count > 0:
		_build_vegetation(vegetation_count)


func get_house_count() -> int:
	return _house_count


func get_crowd_count() -> int:
	if _crowd_instance == null or _crowd_instance.multimesh == null:
		return 0
	return _crowd_instance.multimesh.instance_count


func get_vegetation_count() -> int:
	if _vegetation_instance == null or _vegetation_instance.multimesh == null:
		return 0
	return _vegetation_instance.multimesh.instance_count


## Huellas que recortan el navmesh para casas y pircas del blockout.
static func footprints() -> Array[PackedVector3Array]:
	var result: Array[PackedVector3Array] = []
	for spot: Vector3 in HOUSE_SPOTS:
		(
			result
			. append(
				_rectangle(
					spot,
					Vector3(HOUSE_SIZE.x * 0.5 + 0.3, 0.0, HOUSE_SIZE.z * 0.5 + 0.3),
				)
			)
		)
	result.append(_rectangle(Vector3(-4.0, 0.0, -14.0), Vector3(0.3, 0.0, 4.0)))
	result.append(_rectangle(Vector3(4.0, 0.0, -14.0), Vector3(0.3, 0.0, 4.0)))
	return result


static func cube_data(width: float, height: float, depth: float) -> ConvexBlockData:
	var data: ConvexBlockData = ConvexBlockData.new()
	var half_x: float = width * 0.5
	var half_y: float = height * 0.5
	var half_z: float = depth * 0.5
	data.vertex_points = PackedVector3Array(
		[
			Vector3(-half_x, -half_y, -half_z),
			Vector3(half_x, -half_y, -half_z),
			Vector3(half_x, half_y, -half_z),
			Vector3(-half_x, half_y, -half_z),
			Vector3(-half_x, -half_y, half_z),
			Vector3(half_x, -half_y, half_z),
			Vector3(half_x, half_y, half_z),
			Vector3(-half_x, half_y, half_z),
		]
	)
	data.vertex_selected = PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0])
	data.edge_selected = PackedByteArray()
	data.face_material_indices = PackedInt32Array([0, 0, 0, 0, 0, 0])
	data.face_uv_transform = []
	for _i: int in 6:
		data.face_uv_transform.append(Transform2D.IDENTITY)
	data.face_visible = PackedByteArray([1, 1, 1, 1, 1, 1])
	data.face_color = PackedColorArray(
		[Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]
	)
	data.face_selected = PackedByteArray([0, 0, 0, 0, 0, 0])
	data.edge_vertex_indices = PackedInt32Array()
	data.edge_face_indices = PackedInt32Array()
	data.face_vertex_count = PackedInt32Array([4, 4, 4, 4, 4, 4])
	data.face_vertex_indices = PackedInt32Array(
		[0, 3, 2, 1, 4, 5, 6, 7, 0, 4, 7, 3, 1, 2, 6, 5, 0, 1, 5, 4, 3, 7, 6, 2]
	)
	var normals: PackedVector3Array = PackedVector3Array()
	for _i: int in 4:
		normals.append(Vector3(0, 0, -1))
	for _i: int in 4:
		normals.append(Vector3(0, 0, 1))
	for _i: int in 4:
		normals.append(Vector3(-1, 0, 0))
	for _i: int in 4:
		normals.append(Vector3(1, 0, 0))
	for _i: int in 4:
		normals.append(Vector3(0, -1, 0))
	for _i: int in 4:
		normals.append(Vector3(0, 1, 0))
	data.face_vertex_normal = normals
	return data


static func _rectangle(center: Vector3, half: Vector3) -> PackedVector3Array:
	return PackedVector3Array(
		[
			Vector3(center.x - half.x, 0.0, center.z - half.z),
			Vector3(center.x + half.x, 0.0, center.z - half.z),
			Vector3(center.x + half.x, 0.0, center.z + half.z),
			Vector3(center.x - half.x, 0.0, center.z + half.z),
		]
	)


func _height_at(x: float, z: float) -> float:
	if _terrain == null or _terrain.data == null:
		return 0.0
	return _terrain.data.get_height(Vector3(x, 0.0, z))


func _build_houses() -> void:
	var wall_material: StandardMaterial3D = StandardMaterial3D.new()
	wall_material.albedo_color = Color(0.72, 0.67, 0.56)
	var roof_material: StandardMaterial3D = StandardMaterial3D.new()
	roof_material.albedo_color = Color(0.40, 0.33, 0.25)
	var pirca_material: StandardMaterial3D = StandardMaterial3D.new()
	pirca_material.albedo_color = Color(0.55, 0.43, 0.30)
	for spot: Vector3 in HOUSE_SPOTS:
		var base: float = _height_at(spot.x, spot.z)
		_add_cyclops_box(
			HOUSE_SIZE, Vector3(spot.x, base + HOUSE_SIZE.y * 0.5, spot.z), wall_material
		)
		var roof: MeshInstance3D = MeshInstance3D.new()
		var roof_mesh: BoxMesh = BoxMesh.new()
		roof_mesh.size = ROOF_SIZE
		roof.mesh = roof_mesh
		roof.material_override = roof_material
		roof.position = Vector3(spot.x, base + HOUSE_SIZE.y + ROOF_SIZE.y * 0.5, spot.z)
		add_child(roof)
		_house_count += 1
	_add_cyclops_box(Vector3(0.6, 1.0, 8.0), Vector3(-4.0, 0.5, -14.0), pirca_material)
	_add_cyclops_box(Vector3(0.6, 1.0, 8.0), Vector3(4.0, 0.5, -14.0), pirca_material)


func _add_cyclops_box(size: Vector3, box_position: Vector3, material: Material) -> CyclopsBlock:
	var block: CyclopsBlock = CyclopsBlock.new()
	block.block_data = cube_data(size.x, size.y, size.z)
	block.position = box_position
	add_child(block)
	if block.mesh_instance != null:
		block.mesh_instance.material_override = material
	return block


## Multitud ambiente en un solo MultiMesh: presupuesto de draw calls, no rutina.
func _build_crowd(count: int) -> void:
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.28
	capsule.height = 1.55
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.60, 0.54, 0.46)
	capsule.material = material
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = capsule
	multimesh.instance_count = count
	for index: int in count:
		var angle: float = float(index) * 2.399963
		var radius: float = 6.0 + float(index % 12) * 0.9
		var x: float = cos(angle) * radius
		var z: float = sin(angle) * radius
		var orientation: Basis = Basis(Vector3.UP, -angle)
		multimesh.set_instance_transform(
			index, Transform3D(orientation, Vector3(x, _height_at(x, z) + 0.85, z))
		)
	_crowd_instance = MultiMeshInstance3D.new()
	_crowd_instance.name = "AmbientCrowd"
	_crowd_instance.multimesh = multimesh
	add_child(_crowd_instance)


## Ichu de marcador en MultiMesh alrededor del sector jugable.
func _build_vegetation(count: int) -> void:
	var grass: CylinderMesh = CylinderMesh.new()
	grass.top_radius = 0.05
	grass.bottom_radius = 0.22
	grass.height = 0.9
	grass.radial_segments = 4
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.45, 0.48, 0.30)
	grass.material = material
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = grass
	multimesh.instance_count = count
	for index: int in count:
		var angle: float = float(index) * 2.399963
		var radius: float = 38.0 + float(index % 20) * 1.6
		var x: float = cos(angle) * radius
		var z: float = sin(angle) * radius
		var instance_scale: float = 0.8 + float(index % 5) * 0.1
		var orientation: Basis = Basis(Vector3.UP, angle).scaled(
			Vector3(instance_scale, 1.0, instance_scale)
		)
		multimesh.set_instance_transform(
			index, Transform3D(orientation, Vector3(x, _height_at(x, z) + 0.45, z))
		)
	_vegetation_instance = MultiMeshInstance3D.new()
	_vegetation_instance.name = "Ichu"
	_vegetation_instance.multimesh = multimesh
	add_child(_vegetation_instance)
