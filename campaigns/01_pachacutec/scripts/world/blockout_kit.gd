class_name BlockoutKit
extends RefCounted
## Piezas repetibles para los blockouts de sector de la campaña 01.
##
## Cajas, cilindros, cintas y etiquetas con malla y colisión simples. No es arte
## final: es la geometría gris que fija escala, calles y presupuesto.

const DEFAULT_LABEL_FONT: int = 64
const DEFAULT_LABEL_PIXEL: float = 0.12
## Elementos que no se entierran: ya tienen cimiento o están apoyados encima.
const NO_GROUND_EXTEND: Array[String] = [
	"Foundation", "Casa", "Techo", "Toldo", "PuestoTecho", "TelarViga", "Salto",
	"Canopia",
]


static func add_box(
	parent: Node3D,
	size: Vector3,
	box_position: Vector3,
	color: Color,
	collision: bool,
	orientation: Basis,
	name_hint: String,
) -> Node3D:
	var final_size: Vector3 = size
	var final_position: Vector3 = box_position
	# Extiende la caja hacia abajo hasta el terreno. Si el objeto se apoya en
	# una sola altura, el extremo cuesta abajo queda flotando; el techo y las
	# casas con cimiento quedan fuera de esta regla.
	if not name_hint in NO_GROUND_EXTEND and parent.has_method(&"_ground"):
		var source: Callable = Callable(parent, &"_ground")
		var min_y: float = min_ground(
			source, box_position.x, box_position.z, size, orientation
		)
		var bottom: float = parent.global_position.y + box_position.y - size.y * 0.5
		var added: float = bottom - min_y
		if added > 0.05:
			final_size.y += added
			final_position.y -= added * 0.5
	var root: Node3D = Node3D.new()
	root.name = name_hint
	root.set_meta(&"blockout_kind", name_hint)
	root.position = final_position
	root.basis = orientation
	parent.add_child(root)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = final_size
	mesh.mesh = box
	mesh.material_override = material(color)
	root.add_child(mesh)
	if collision:
		var body: StaticBody3D = StaticBody3D.new()
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = final_size
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
	name_hint: String = "Cylinder",
) -> MeshInstance3D:
	var final_height: float = height
	var final_position: Vector3 = mesh_position
	if parent.has_method(&"_ground"):
		var source: Callable = Callable(parent, &"_ground")
		var min_y: float = min_ground(
			source, mesh_position.x, mesh_position.z, Vector3(radius * 2.0, 0.0, radius * 2.0)
		)
		var bottom: float = parent.global_position.y + mesh_position.y - height * 0.5
		var added: float = bottom - min_y
		if added > 0.05:
			final_height += added
			final_position.y -= added * 0.5
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = name_hint
	mesh.set_meta(&"blockout_kind", name_hint)
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = final_height
	mesh.mesh = cylinder
	mesh.material_override = material(color)
	mesh.position = final_position
	parent.add_child(mesh)
	return mesh


## Disco que sigue el terreno. Sirve para plazas, nieve, bofedales y pozas:
## un cilindro plano a la altura del centro flota en cuanto la superficie tiene
## pendiente. [param height_at] recibe (x, z) en coordenadas del padre.
static func add_terrain_disk(
	parent: Node3D,
	radius: float,
	lift: float,
	color: Color,
	height_at: Callable,
	segments: int = 64,
	rings: int = 8,
	center: Vector2 = Vector2.ZERO,
	name_hint: String = "TerrainDisk",
) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var middle: Vector3 = _disk_point(0.0, 0.0, height_at, lift, center)
	for segment: int in segments:
		var angle0: float = TAU * float(segment) / float(segments)
		var angle1: float = TAU * float(segment + 1) / float(segments)
		var p0: Vector3 = _disk_point(
			radius / float(rings), angle0, height_at, lift, center
		)
		var p1: Vector3 = _disk_point(
			radius / float(rings), angle1, height_at, lift, center
		)
		_add_disk_triangle(surface, middle, p0, p1)
	for ring: int in range(1, rings):
		var radius0: float = radius * float(ring) / float(rings)
		var radius1: float = radius * float(ring + 1) / float(rings)
		for segment: int in segments:
			var angle0: float = TAU * float(segment) / float(segments)
			var angle1: float = TAU * float(segment + 1) / float(segments)
			var p00: Vector3 = _disk_point(radius0, angle0, height_at, lift, center)
			var p01: Vector3 = _disk_point(radius1, angle0, height_at, lift, center)
			var p11: Vector3 = _disk_point(radius1, angle1, height_at, lift, center)
			var p10: Vector3 = _disk_point(radius0, angle1, height_at, lift, center)
			_add_disk_triangle(surface, p00, p01, p11)
			_add_disk_triangle(surface, p00, p11, p10)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = name_hint
	mesh_instance.set_meta(&"blockout_kind", name_hint)
	mesh_instance.mesh = surface.commit()
	var disk_material: StandardMaterial3D = material(color)
	disk_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = disk_material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	parent.add_child(mesh_instance)
	return mesh_instance


static func _disk_point(
	radius: float,
	angle: float,
	height_at: Callable,
	lift: float,
	center: Vector2,
) -> Vector3:
	var x: float = center.x + cos(angle) * radius
	var z: float = center.y + sin(angle) * radius
	var value: Variant = height_at.call(x, z)
	var height: float = str(value).to_float()
	return Vector3(x, height + lift, z)


static func _add_disk_triangle(
	surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3
) -> void:
	for vertex: Vector3 in [a, b, c]:
		surface.set_normal(Vector3.UP)
		surface.add_vertex(vertex)


static func add_sphere(
	parent: Node3D,
	radius: float,
	mesh_position: Vector3,
	color: Color,
) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "Canopia"
	mesh.set_meta(&"blockout_kind", "Canopia")
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 8
	sphere.rings = 4
	mesh.mesh = sphere
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
	step: float = 1.5,
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
		# Cada borde sigue su propia altura; en ladera, heredar la del centro
		# dejaba el lado cuesta abajo flotando.
		vertices.append(_on_height(centers[index] + side, height_at, lift))
		vertices.append(_on_height(centers[index] - side, height_at, lift))
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
	instance.name = "Ribbon"
	instance.set_meta(&"blockout_kind", "Ribbon")
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


## Altura mínima del terreno bajo la huella de una caja. Sirve para apoyar
## muros y plataformas largas en ladera sin dejarlos flotando por un extremo.
static func min_ground(
	height_at: Callable,
	x: float,
	z: float,
	size: Vector3,
	orientation: Basis = Basis.IDENTITY,
) -> float:
	var minimum: float = INF
	for ix: int in 3:
		for iz: int in 3:
			var offset: Vector3 = Vector3(
				(float(ix) - 1.0) * size.x * 0.5,
				0.0,
				(float(iz) - 1.0) * size.z * 0.5,
			)
			var rotated: Vector3 = orientation * offset
			var value: Variant = height_at.call(x + rotated.x, z + rotated.z)
			var height: float = str(value).to_float()
			minimum = minf(minimum, height)
	return minimum if minimum < INF else 0.0
