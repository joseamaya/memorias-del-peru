class_name ValleyBackdrop
extends Node3D
## Fondo de valle que se ve por el paso del norte: campos, un caserío lejano y
## las montañas que ya dibuja [DistantRange]. Es una malla sin colisión, sin
## sombras y sin GI; existe para dar profundidad, no para recorrerse.

const HALF_WIDTH: float = 300.0
const NEAR_Z: float = -68.0
const FAR_Z: float = -320.0
const GRID_X: int = 28
const GRID_Z: int = 30
const TOWN_CENTER: Vector2 = Vector2(0.0, -145.0)
const TOWN_HALF_X: float = 18.0
const TOWN_ROWS: int = 3
const HOUSES_PER_ROW: int = 8
const TOWN_HOUSE: Vector3 = Vector3(3.1, 2.15, 2.6)

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func build_default(parent: Node3D) -> ValleyBackdrop:
	var backdrop: ValleyBackdrop = ValleyBackdrop.new()
	backdrop.name = "Backdrop"
	parent.add_child(backdrop)
	backdrop.build()
	return backdrop


func build() -> void:
	_rng.seed = 421
	_build_floor()
	_build_town()


func height_at(x: float, z: float) -> float:
	var t: float = clampf((z - NEAR_Z) / (FAR_Z - NEAR_Z), 0.0, 1.0)
	var y: float = lerpf(-1.4, -5.5, t)
	y += sin(x * 0.035 + 0.6) * cos(z * 0.025) * 0.35 * smoothstep(0.0, 0.25, t)
	return y


func _build_floor() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	for zi: int in range(GRID_Z):
		for xi: int in range(GRID_X):
			var x0: float = lerpf(-HALF_WIDTH, HALF_WIDTH, float(xi) / GRID_X)
			var x1: float = lerpf(-HALF_WIDTH, HALF_WIDTH, float(xi + 1) / GRID_X)
			var z0: float = lerpf(NEAR_Z, FAR_Z, float(zi) / GRID_Z)
			var z1: float = lerpf(NEAR_Z, FAR_Z, float(zi + 1) / GRID_Z)
			var p00: Vector3 = Vector3(x0, height_at(x0, z0), z0)
			var p10: Vector3 = Vector3(x1, height_at(x1, z0), z0)
			var p01: Vector3 = Vector3(x0, height_at(x0, z1), z1)
			var p11: Vector3 = Vector3(x1, height_at(x1, z1), z1)
			surface.set_color(_field_color((x0 + x1) * 0.5, (z0 + z1) * 0.5))
			for vertex: Vector3 in [p00, p10, p11, p00, p11, p01]:
				surface.add_vertex(vertex)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "ValleyFloor"
	mesh.mesh = surface.commit()
	mesh.material_override = _far_material()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(mesh)


func _build_town() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	for row: int in range(TOWN_ROWS):
		for index: int in range(HOUSES_PER_ROW):
			if index == HOUSES_PER_ROW / 2 and row == TOWN_ROWS - 1:
				continue
			var x: float = lerpf(-TOWN_HALF_X, TOWN_HALF_X, float(index) / (HOUSES_PER_ROW - 1))
			var z: float = TOWN_CENTER.y - float(row) * 6.5 + _rng.randf_range(-0.8, 0.8)
			_house(surface, Vector3(x, height_at(x, z), z), _rng.randf_range(0.0, TAU))
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "Town"
	mesh.mesh = surface.commit()
	mesh.material_override = _far_material()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(mesh)


func _house(surface: SurfaceTool, at: Vector3, yaw: float) -> void:
	var rotation_basis: Basis = Basis(Vector3.UP, yaw)
	var half: Vector3 = TOWN_HOUSE * 0.5
	var adobe: Color = Color(0.58, 0.45, 0.32, 1.0).srgb_to_linear()
	var thatch: Color = Color(0.66, 0.53, 0.30, 1.0).srgb_to_linear()
	var corners: Array[Vector3] = [
		rotation_basis * Vector3(-half.x, 0.0, -half.z) + at,
		rotation_basis * Vector3(half.x, 0.0, -half.z) + at,
		rotation_basis * Vector3(half.x, 0.0, half.z) + at,
		rotation_basis * Vector3(-half.x, 0.0, half.z) + at,
	]
	var top: Array[Vector3] = []
	for corner: Vector3 in corners:
		top.append(corner + Vector3(0.0, TOWN_HOUSE.y, 0.0))
	_quad(surface, corners[0], corners[1], top[1], top[0], adobe)
	_quad(surface, corners[1], corners[2], top[2], top[1], adobe)
	_quad(surface, corners[2], corners[3], top[3], top[2], adobe)
	_quad(surface, corners[3], corners[0], top[0], top[3], adobe)
	var ridge_a: Vector3 = at + rotation_basis * Vector3(-half.x - 0.25, TOWN_HOUSE.y + 1.0, 0.0)
	var ridge_b: Vector3 = at + rotation_basis * Vector3(half.x + 0.25, TOWN_HOUSE.y + 1.0, 0.0)
	var eave_l: Vector3 = at + rotation_basis * Vector3(-half.x - 0.25, TOWN_HOUSE.y, -half.z - 0.2)
	var eave_l2: Vector3 = at + rotation_basis * Vector3(-half.x - 0.25, TOWN_HOUSE.y, half.z + 0.2)
	var eave_r: Vector3 = at + rotation_basis * Vector3(half.x + 0.25, TOWN_HOUSE.y, -half.z - 0.2)
	var eave_r2: Vector3 = at + rotation_basis * Vector3(half.x + 0.25, TOWN_HOUSE.y, half.z + 0.2)
	_quad(surface, eave_l, ridge_a, ridge_b, eave_r, thatch)
	_quad(surface, eave_l2, ridge_b, ridge_a, eave_r2, thatch)


func _quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3,
		color: Color) -> void:
	surface.set_color(color)
	for vertex: Vector3 in [a, b, c, a, c, d]:
		surface.add_vertex(vertex)


func _field_color(x: float, z: float) -> Color:
	var cell: Vector2i = Vector2i(floori(x / 24.0), floori(z / 20.0))
	var hash_value: float = absf(sin(float(cell.x) * 12.9898 + float(cell.y) * 78.233) * 43758.5453)
	hash_value -= floorf(hash_value)
	if Vector2(x, z).distance_to(TOWN_CENTER) < 28.0:
		return Color(0.34, 0.29, 0.23, 1.0).srgb_to_linear()
	var green: Color = Color(0.20, 0.38, 0.16, 1.0).srgb_to_linear()
	var ochre: Color = Color(0.55, 0.40, 0.18, 1.0).srgb_to_linear()
	return green.lerp(ochre, hash_value)


func _far_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material
