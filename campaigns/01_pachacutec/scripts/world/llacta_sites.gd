class_name LlactaSites
extends RefCounted
## Hitos de la llacta que la biblia pide y el bloqueo no tenía: el manantial
## con su acequia y el mirador del camino del norte. No conocen la campaña:
## reciben la altura del suelo y devuelven un nodo listo para el mundo.

const SPRING_POSITION: Vector3 = Vector3(29.0, 0.0, 4.0)
const MIRADOR_POSITION: Vector3 = Vector3(0.0, 0.0, -70.0)
const STONE_TINT: Color = Color(0.55, 0.53, 0.49, 1.0)
const WATER_TINT: Color = Color(0.18, 0.30, 0.32, 0.90)


static func build_spring(parent: Node3D, height_source: Callable) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Spring"
	root.position = _ground(SPRING_POSITION, height_source)
	parent.add_child(root)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, STONE_TINT)
	# Pileta rectangular con abertura al oeste, hacia el camino.
	_basin_wall(root, "BasinNorth", Vector3(0.0, 0.45, -1.0), Vector3(3.2, 0.45, 0.35), stone)
	_basin_wall(root, "BasinSouth", Vector3(0.0, 0.45, 1.0), Vector3(3.2, 0.45, 0.35), stone)
	_basin_wall(root, "BasinEast", Vector3(1.45, 0.45, 0.0), Vector3(0.35, 0.45, 2.0), stone)
	_basin_wall(root, "BasinWest", Vector3(-1.45, 0.45, 0.8), Vector3(0.35, 0.45, 0.7), stone)
	_water(root, "SpringWater", Vector3(0.0, 0.26, 0.0), Vector3(2.5, 0.03, 1.45))
	_rock(root, "SpringSource", Vector3(1.35, 0.38, 0.0), 0.55, stone)
	_rock(root, "SpringSource2", Vector3(1.65, 0.22, 0.55), 0.32, stone)
	# Acequia corta hacia las terrazas del este.
	water_strip(root, "Acequia", Vector3(1.2, 0.12, 0.0), 3.8, 0.38)
	_stone_box(root, "AcequiaNorth", Vector3(3.1, 0.18, -0.24), Vector3(3.8, 0.28, 0.16), stone, false)
	_stone_box(root, "AcequiaSouth", Vector3(3.1, 0.18, 0.24), Vector3(3.8, 0.28, 0.16), stone, false)
	_stone_box(root, "SpringStep", Vector3(-0.9, 0.08, 0.65), Vector3(0.7, 0.16, 0.9), stone, false)
	_reed(root, "Reed0", Vector3(-1.8, 0.0, -1.2), 1.0)
	_reed(root, "Reed1", Vector3(-2.0, 0.0, 1.1), 0.9)
	_reed(root, "Reed2", Vector3(1.9, 0.0, -1.3), 0.8)
	return root


static func build_mirador(parent: Node3D, height_source: Callable) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Mirador"
	root.position = _ground(MIRADOR_POSITION, height_source)
	parent.add_child(root)
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, STONE_TINT)
	var parapet_stone: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color(0.44, 0.42, 0.38, 1.0))
	# Parapeto bajo: deja ver el valle y evita que el jugador se caiga.
	_stone_wall(root, "Parapet", Vector3(0.0, 0.0, -3.0), Vector3(14.0, 0.72, 0.45), parapet_stone)
	var wood: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.WOOD, Color(0.42, 0.30, 0.19, 1.0))
	_stone_box(root, "BenchSupportWest", Vector3(2.2, 0.22, -0.8), Vector3(0.22, 0.44, 0.55), stone, true)
	_stone_box(root, "BenchSupportEast", Vector3(4.0, 0.22, -0.8), Vector3(0.22, 0.44, 0.55), stone, true)
	_stone_box(root, "BenchSeat", Vector3(3.1, 0.47, -0.8), Vector3(2.2, 0.12, 0.62), wood, true)
	var view: Marker3D = Marker3D.new()
	view.name = "View"
	view.position = Vector3(0.0, 1.2, -3.8)
	root.add_child(view)
	_build_crags(parent, height_source)
	return root


static func _ground(at: Vector3, height_source: Callable) -> Vector3:
	if not height_source.is_valid():
		return at
	var raw: Variant = height_source.call(at.x, at.z)
	var y: float = raw if raw is float else 0.0
	return Vector3(at.x, y, at.z)


## Roquedales que enmarcan el paso, como los del sector de la referencia.
static func _build_crags(parent: Node3D, height_source: Callable) -> void:
	var stone: ShaderMaterial = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color(0.40, 0.38, 0.35, 1.0))
	for at: Vector2 in [Vector2(8.5, -62.0), Vector2(-8.5, -62.0),
			Vector2(10.5, -67.0), Vector2(-10.5, -67.0)]:
		var y: float = 0.0
		if height_source.is_valid():
			var raw: Variant = height_source.call(at.x, at.y)
			if raw is float:
				y = raw
		_rock(parent, "PassCrag", Vector3(at.x, y + 1.1, at.y), 2.2, stone)


static func _reed(parent: Node3D, node_name: String, at: Vector3, scale_value: float) -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index: int in range(5):
		var angle: float = TAU * float(index) / 5.0 + 0.3
		var side: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * 0.035
		var tip: Vector3 = Vector3(cos(angle) * 0.10, 0.62 + 0.06 * float(index % 3), sin(angle) * 0.10)
		for sgn: float in [-1.0, 1.0]:
			var a: Vector3 = side * sgn
			var b: Vector3 = -side * sgn
			for vertex: Vector3 in [a, b, tip, a, tip, b]:
				surface.add_vertex(vertex)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = at
	mesh_instance.scale = Vector3.ONE * scale_value
	mesh_instance.mesh = surface.commit()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.42, 0.48, 0.22, 1.0)
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	parent.add_child(mesh_instance)


static func _rock(parent: Node3D, node_name: String, at: Vector3, radius: float, material: Material) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = node_name
	mesh.position = at
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 1.5
	sphere.radial_segments = 7
	sphere.rings = 3
	mesh.mesh = sphere
	mesh.scale = Vector3(1.2, 0.8, 1.0)
	mesh.material_override = material
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mesh)


static func _basin_wall(
	parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material
) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name
	body.position = at
	body.collision_layer = 1
	body.collision_mask = 0
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material
	body.add_child(mesh)
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)


static func _stone_box(
	parent: Node3D, node_name: String, at: Vector3, size: Vector3,
	material: Material, collide: bool
) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = node_name
	mesh.position = at
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = material
	parent.add_child(mesh)
	if not collide:
		return
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name + "Body"
	body.position = at
	body.collision_layer = 1
	body.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)


## Pared de pirca de dos caras con remate; una sola malla de piedras.
static func _stone_wall(
	parent: Node3D, node_name: String, at: Vector3, size: Vector3, material: Material
) -> void:
	var half: float = size.z * 0.5
	var faces: Array[StoneWall.Face] = [
		StoneWall.Face.new(at + Vector3(-size.x * 0.5, 0.0, half), Vector3.RIGHT, Vector3.FORWARD, size.x, size.y),
		StoneWall.Face.new(at + Vector3(-size.x * 0.5, 0.0, -half), Vector3.RIGHT, Vector3.BACK, size.x, size.y),
	]
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = node_name
	mesh.mesh = StoneWall.build(faces, 912)
	mesh.material_override = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color.WHITE, true)
	parent.add_child(mesh)
	var cap: MeshInstance3D = MeshInstance3D.new()
	cap.name = node_name + "Cap"
	cap.position = at + Vector3(0.0, size.y - 0.04, 0.0)
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(size.x, 0.08, size.z + 0.08)
	cap.mesh = box
	cap.material_override = material
	parent.add_child(cap)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = node_name + "Body"
	body.position = at + Vector3(0.0, size.y * 0.5, 0.0)
	body.collision_layer = 1
	body.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)


static func _water(parent: Node3D, node_name: String, at: Vector3, size: Vector3) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = node_name
	mesh.position = at
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _water_material()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	parent.add_child(mesh)


static func water_strip(parent: Node3D, node_name: String, at: Vector3,
		length: float, width: float) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = node_name
	mesh.position = at + Vector3(length * 0.5, 0.0, 0.0)
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(length, 0.03, width)
	mesh.mesh = box
	mesh.material_override = _water_material()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	parent.add_child(mesh)


static func _water_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = WATER_TINT
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.12
	material.metallic = 0.0
	material.emission_enabled = true
	material.emission = Color(0.04, 0.10, 0.12, 1.0)
	material.emission_energy_multiplier = 0.16
	return material
