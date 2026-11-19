class_name BlockoutKit
extends RefCounted
## Piezas repetibles para los blockouts de sector de la campaña 01.
##
## Cajas, cilindros, cintas y etiquetas con malla y colisión simples. No es arte
## final: es la geometría gris que fija escala, calles y presupuesto.

const DEFAULT_LABEL_FONT: int = 64
const DEFAULT_LABEL_PIXEL: float = 0.12


static func add_box(
	parent: Node3D,
	size: Vector3,
	box_position: Vector3,
	color: Color,
	collision: bool,
	orientation: Basis,
	name_hint: String,
) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = name_hint
	root.position = box_position
	root.basis = orientation
	parent.add_child(root)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material(color)
	root.add_child(mesh)
	if collision:
		var body: StaticBody3D = StaticBody3D.new()
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
		root.add_child(body)
	return root


static func add_cylinder(
	parent: Node3D,
	radius: float,
	height: float,
	mesh_position: Vector3,
	color: Color,
) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	mesh.mesh = cylinder
	mesh.material_override = material(color)
	mesh.position = mesh_position
	parent.add_child(mesh)
	return mesh


static func add_ribbon(
	parent: Node3D,
	points: PackedVector3Array,
	height_at: Callable,
	width: float,
	color: Color,
	lift: float,
	step: float = 4.0,
) -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var centers: PackedVector3Array = PackedVector3Array()
	for index: int in range(points.size() - 1):
		var from: Vector3 = points[index]
		var to: Vector3 = points[index + 1]
		var steps: int = maxi(ceili(from.distance_to(to) / step), 1)
		for sub: int in steps:
			var t: float = float(sub) / float(steps)
			var point: Vector3 = from.lerp(to, t)
			centers.append(_on_height(point, height_at, lift))
	centers.append(_on_height(points[points.size() - 1], height_at, lift))
	for index: int in centers.size():
		var flat_direction: Vector3 = direction(centers, index)
		var side: Vector3 = Vector3(-flat_direction.z, 0.0, flat_direction.x) * (width * 0.5)
		vertices.append(centers[index] + side)
		vertices.append(centers[index] - side)
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
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material(color)
	parent.add_child(instance)
	return instance


static func add_label(
	parent: Node3D,
	text: String,
	label_position: Vector3,
	font_size: int = DEFAULT_LABEL_FONT,
	pixel_size: float = DEFAULT_LABEL_PIXEL,
) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font_size = font_size
	label.pixel_size = pixel_size
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = label_position
	parent.add_child(label)
	return label


static func material(color: Color) -> StandardMaterial3D:
	var result: StandardMaterial3D = StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 1.0
	return result


static func direction(points: PackedVector3Array, index: int) -> Vector3:
	var from: Vector3 = points[maxi(index - 1, 0)]
	var to: Vector3 = points[mini(index + 1, points.size() - 1)]
	var flat: Vector3 = Vector3(to.x - from.x, 0.0, to.z - from.z)
	if flat.length_squared() < 0.0001:
		return Vector3.FORWARD
	return flat.normalized()


static func _on_height(point: Vector3, height_at: Callable, lift: float) -> Vector3:
	var value: Variant = height_at.call(point.x, point.z)
	var height: float = str(value).to_float()
	return Vector3(point.x, height + lift, point.z)
