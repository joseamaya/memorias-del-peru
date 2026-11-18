class_name LlactaPaths
extends Node3D
## Red de caminos visibles de la llacta: cinta de tierra y bordes de piedra.
##
## La plaza ya era de tierra, pero los caminos solo existían como un rectángulo
## de tinte en el shader. El jugador no tenía una línea que seguir. Esta malla
## dibuja el camino y llena sus bordes con piedras en una sola llamada.

const WIDTH: float = 3.0
const EDGE_OFFSET: float = 0.15
const EDGE_SPACING: float = 0.95
const PATH_LIFT: float = 0.055
const EDGE_LIFT: float = 0.06
const EDGE_SEED: int = 913
const EDGE_SCALE_MIN: float = 0.65
const EDGE_SCALE_MAX: float = 1.08

var paths: Array[PackedVector2Array] = []
var height_source: Callable = Callable()


static func build_default(parent: Node3D, height: Callable) -> LlactaPaths:
	var network: LlactaPaths = LlactaPaths.new()
	network.name = "Paths"
	parent.add_child(network)
	var home: Node3D = parent.get_node_or_null("Houses/House04") as Node3D
	var home_xz: Vector2 = Vector2(20.0, 9.0)
	if home != null:
		var door: Vector3 = home.to_global(Vector3(0.0, 0.0, -3.5))
		home_xz = Vector2(door.x, door.z)
	var defs: Array[PackedVector2Array] = [
		# Entrada sur y camino del norte, con el mirador al final.
		PackedVector2Array([Vector2(0, 34), Vector2(0, 20), Vector2(0, 13.5)]),
		PackedVector2Array([Vector2(0, -13.5), Vector2(0, -30), Vector2(0, -46), Vector2(0, -70)]),
		# Casa de Rumi y manantial.
		PackedVector2Array([Vector2(13.5, 8), Vector2(15, 5), Vector2(18, 4.3), home_xz]),
		PackedVector2Array([Vector2(13.5, 4), Vector2(20, 4), Vector2(26, 4), Vector2(27.3, 4)]),
		PackedVector2Array([Vector2(26, 4), Vector2(28, 2), Vector2(30, 0)]),
		# Maíz, telar, pirca y corrales.
		PackedVector2Array([Vector2(-13.5, 8), Vector2(-16, 8)]),
		PackedVector2Array([Vector2(-13.5, 8), Vector2(-10, 7), Vector2(-8.6, 6.2)]),
		PackedVector2Array([Vector2(-13.5, -8), Vector2(-16, -12), Vector2(-22, -14), Vector2(-27.5, -12)]),
		PackedVector2Array([Vector2(-22, -14), Vector2(-26, -12), Vector2(-28.5, -12)]),
		PackedVector2Array([Vector2(-22, -14), Vector2(-23, -19), Vector2(-24, -25)]),
	]
	network.build(height, defs)
	return network


func build(height: Callable, definitions: Array[PackedVector2Array]) -> void:
	height_source = height
	paths.clear()
	paths.assign(definitions)
	_build_surface()
	_build_edges()


func distance_to_paths(point: Vector2) -> float:
	var best: float = INF
	for path: PackedVector2Array in paths:
		for index: int in range(path.size() - 1):
			var a: Vector2 = path[index]
			var b: Vector2 = path[index + 1]
			var ab: Vector2 = b - a
			var t: float = clampf((point - a).dot(ab) / maxf(ab.length_squared(), 0.001), 0.0, 1.0)
			best = minf(best, point.distance_to(a + ab * t))
	return best


func _build_surface() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	for path: PackedVector2Array in paths:
		for index: int in range(path.size() - 1):
			var a: Vector2 = path[index]
			var b: Vector2 = path[index + 1]
			var direction: Vector2 = (b - a).normalized()
			var side: Vector2 = Vector2(-direction.y, direction.x) * WIDTH * 0.5
			var pieces: int = maxi(1, int(a.distance_to(b)))
			for piece: int in range(pieces):
				var p0: Vector2 = a.lerp(b, float(piece) / pieces)
				var p1: Vector2 = a.lerp(b, float(piece + 1) / pieces)
				var q0: Vector3 = _ground(p0 - side)
				var q1: Vector3 = _ground(p1 - side)
				var q2: Vector3 = _ground(p1 + side)
				var q3: Vector3 = _ground(p0 + side)
				for vertex: Vector3 in [q0, q1, q2, q0, q2, q3]:
					surface.add_vertex(vertex)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "PathSurface"
	mesh_instance.mesh = surface.commit()
	mesh_instance.material_override = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.DIRT, Color(0.38, 0.30, 0.23, 1.0))
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(mesh_instance)


func _build_edges() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = EDGE_SEED
	var transforms: Array[Transform3D] = []
	for path: PackedVector2Array in paths:
		for index: int in range(path.size() - 1):
			var a: Vector2 = path[index]
			var b: Vector2 = path[index + 1]
			var direction: Vector2 = (b - a).normalized()
			var side: Vector2 = Vector2(-direction.y, direction.x)
			var count: int = maxi(1, int(a.distance_to(b) / EDGE_SPACING))
			for piece: int in range(count):
				var center: Vector2 = a.lerp(b, (float(piece) + 0.5) / count)
				for sgn: float in [-1.0, 1.0]:
					var point: Vector2 = center + side * sgn * (WIDTH * 0.5 + EDGE_OFFSET)
					var at: Vector3 = _ground(point)
					at.y += EDGE_LIFT
					var scale_factor: float = rng.randf_range(EDGE_SCALE_MIN, EDGE_SCALE_MAX)
					var rotation_basis: Basis = Basis(Vector3.UP, rng.randf_range(0.0, TAU)).scaled(
						Vector3(scale_factor, scale_factor * rng.randf_range(0.7, 1.2), scale_factor))
					transforms.append(Transform3D(rotation_basis, at))
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.075
	mesh.height = 0.12
	mesh.radial_segments = 5
	mesh.rings = 2
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "PathEdge"
	instance.multimesh = multimesh
	instance.material_override = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color(0.40, 0.37, 0.33, 1.0))
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(instance)


func _ground(point: Vector2) -> Vector3:
	var y: float = 0.0
	if height_source.is_valid():
		var raw: Variant = height_source.call(point.x, point.y)
		if raw is float:
			y = raw
	return Vector3(point.x, y + PATH_LIFT, point.y)
