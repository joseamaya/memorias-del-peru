class_name LlactaPlazaEdges
extends Node3D
## Borde de pirca baja de la plaza con cuatro entradas.
##
## La plaza era un descampado sin límite; las casas flotaban alrededor. Este
## anillo bajo la convierte en un recinto con calles y deja libres los accesos
## a la casa de Rumi, el manantial, el maíz, la pirca, el corral y el norte.

const HEIGHT: float = 0.68
const THICKNESS: float = 0.45
const SEED: int = 1613

var segments: Array[PackedVector2Array] = []


static func build_default(parent: Node3D) -> LlactaPlazaEdges:
	var edges: LlactaPlazaEdges = LlactaPlazaEdges.new()
	edges.name = "PlazaEdges"
	parent.add_child(edges)
	edges.build([
		# Sur: entrada principal.
		PackedVector2Array([Vector2(-13.5, 13.5), Vector2(-4.0, 13.5)]),
		PackedVector2Array([Vector2(4.0, 13.5), Vector2(13.5, 13.5)]),
		# Norte: camino del mirador.
		PackedVector2Array([Vector2(-13.5, -13.5), Vector2(-4.0, -13.5)]),
		PackedVector2Array([Vector2(4.0, -13.5), Vector2(13.5, -13.5)]),
		# Este: manantial y casa de Rumi.
		PackedVector2Array([Vector2(13.5, -13.5), Vector2(13.5, 2.0)]),
		PackedVector2Array([Vector2(13.5, 10.0), Vector2(13.5, 13.5)]),
		# Oeste: maíz/telar y pirca/corral.
		PackedVector2Array([Vector2(-13.5, -13.5), Vector2(-13.5, -10.0)]),
		PackedVector2Array([Vector2(-13.5, -6.0), Vector2(-13.5, 6.0)]),
		PackedVector2Array([Vector2(-13.5, 10.0), Vector2(-13.5, 13.5)]),
	])
	return edges


func build(definitions: Array[PackedVector2Array]) -> void:
	segments.clear()
	segments.assign(definitions)
	_build_mesh()
	_build_collision()


func _build_mesh() -> void:
	var faces: Array[StoneWall.Face] = []
	var cap_surface: SurfaceTool = SurfaceTool.new()
	cap_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment: PackedVector2Array in segments:
		var start: Vector2 = segment[0]
		var end: Vector2 = segment[1]
		var direction: Vector2 = (end - start).normalized()
		var normal: Vector2 = Vector2(-direction.y, direction.x)
		var length: float = start.distance_to(end)
		var half: float = THICKNESS * 0.5
		faces.append(StoneWall.Face.new(
			Vector3(start.x, 0.0, start.y) + Vector3(normal.x, 0.0, normal.y) * half,
			Vector3(direction.x, 0.0, direction.y),
			Vector3(normal.x, 0.0, normal.y), length, HEIGHT))
		faces.append(StoneWall.Face.new(
			Vector3(start.x, 0.0, start.y) - Vector3(normal.x, 0.0, normal.y) * half,
			Vector3(direction.x, 0.0, direction.y),
			Vector3(-normal.x, 0.0, -normal.y), length, HEIGHT))
		_add_cap(cap_surface, start, end, half)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "WallStones"
	mesh_instance.mesh = StoneWall.build(faces, SEED)
	mesh_instance.material_override = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color.WHITE, true)
	add_child(mesh_instance)
	var caps: MeshInstance3D = MeshInstance3D.new()
	caps.name = "WallCaps"
	caps.mesh = cap_surface.commit()
	caps.material_override = SurfaceMaterials.layer_material(
		SurfaceMaterials.Layer.STONE, Color(0.52, 0.50, 0.46, 1.0))
	add_child(caps)


func _add_cap(surface: SurfaceTool, start: Vector2, end: Vector2, half: float) -> void:
	var direction: Vector2 = (end - start).normalized()
	var normal: Vector2 = Vector2(-direction.y, direction.x) * half
	var y: float = HEIGHT
	var corners: Array[Vector3] = [
		Vector3(start.x - normal.x, y, start.y - normal.y),
		Vector3(end.x - normal.x, y, end.y - normal.y),
		Vector3(end.x + normal.x, y, end.y + normal.y),
		Vector3(start.x + normal.x, y, start.y + normal.y),
	]
	surface.set_normal(Vector3.UP)
	for index: int in [0, 1, 2, 0, 2, 3]:
		surface.add_vertex(corners[index])


func _build_collision() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "WallBodies"
	body.collision_layer = 1
	body.collision_mask = 0
	for segment: PackedVector2Array in segments:
		var start: Vector2 = segment[0]
		var end: Vector2 = segment[1]
		var direction: Vector2 = (end - start).normalized()
		var length: float = start.distance_to(end)
		var center: Vector2 = (start + end) * 0.5
		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = Vector3(length, HEIGHT, THICKNESS)
		collision.shape = shape
		collision.position = Vector3(center.x, HEIGHT * 0.5, center.y)
		collision.rotation.y = atan2(-direction.y, direction.x)
		body.add_child(collision)
	add_child(body)
