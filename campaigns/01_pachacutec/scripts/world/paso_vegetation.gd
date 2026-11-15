class_name PasoVegetation
extends Node3D
## Vegetación del paso de montaña (ficha PCH-013, reconstrucción R).
##
## Ichu ralo en el corredor y en las laderas, y queñuas en los bordes del
## desfiladero. El reparto es determinista y deja libres el sendero, el arroyo,
## el campamento, el refugio y los roquedales. Reutiliza los modelos y el
## material con viento de la llacta; no crea nada si faltan los modelos.

const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const ICHU_FILES: Array[String] = ["pch_ichu_a.glb", "pch_ichu_b.glb"]
const QUENUA_FILES: Array[String] = ["pch_quenua_a.glb", "pch_quenua_b.glb"]
const SEED: int = 41
const QUENUA_SEED: int = 53
## Medio lado del área con vegetación; las paredes del paso quedan fuera.
const AREA_HALF: float = 33.0
const ICHU_SPACING: float = 2.4
const ICHU_JITTER: float = 0.5
const ICHU_SCALE_MIN: float = 0.7
const ICHU_SCALE_MAX: float = 1.3
const ICHU_SINK: float = 0.04
const ICHU_VISIBILITY_END: float = 55.0
const ICHU_VISIBILITY_MARGIN: float = 10.0
## El sendero y el arroyo, libres de matas.
const PATH_HALF_WIDTH: float = 3.2
const STREAM_X: float = -14.0
const STREAM_HALF_WIDTH: float = 3.4
## Bosquecillos de queñua en los bordes del corredor: (x, z, radio).
const QUENUA_GROVES: Array[Vector3] = [
	Vector3(-18.0, 24.0, 3.0),
	Vector3(18.5, -22.0, 3.0),
	Vector3(-19.5, -10.0, 3.0),
	Vector3(19.0, 16.0, 3.0),
]
const QUENUA_PER_GROVE: int = 3
const QUENUA_SPACING: float = 3.0
const QUENUA_ATTEMPTS: int = 30
const QUENUA_SCALE_MIN: float = 0.8
const QUENUA_SCALE_MAX: float = 1.2
const TRUNK_RADIUS: float = 0.35
const TRUNK_HEIGHT: float = 2.4
const ICHU_WIND_BEND: float = 0.17
const QUENUA_WIND_BEND: float = 0.008
## Entierra un poco el tronco para que la copa no parezca flotar en la ladera.
const QUENUA_SINK: float = 0.22
## Radio libre alrededor de cada roquedal.
const ROCK_CLEARANCE: float = 2.6

## Una mata o un árbol: transformación y variante de modelo.
class Placement:
	var transform: Transform3D
	var variant: int

	func _init(placement_transform: Transform3D, model_variant: int) -> void:
		transform = placement_transform
		variant = model_variant


## Materiales que mece el viento (los recibe [LlactaWind]).
var wind_materials: Array[ShaderMaterial] = []
var _height_source: Callable = Callable()
var _blocked: Array[Rect2] = []
var _rocks: Array[Vector3] = []


## Crea la vegetación. [param height_source] devuelve la altura del terreno;
## [param blocked], las zonas sin matas; [param rocks], los centros de roquedal.
func build(height_source: Callable, blocked: Array[Rect2], rocks: Array[Vector3]) -> void:
	_height_source = height_source
	_blocked = blocked.duplicate()
	_rocks = rocks.duplicate()
	var ichu_meshes: Array[Mesh] = _load_meshes(ICHU_FILES)
	if ichu_meshes.size() == ICHU_FILES.size():
		_build_ichu(ichu_meshes)
	var quenua_meshes: Array[Mesh] = _load_meshes(QUENUA_FILES)
	if quenua_meshes.size() == QUENUA_FILES.size():
		_build_quenua(quenua_meshes)


## Verdadero si en [param point] (x, z) puede crecer vegetación.
func is_free(point: Vector2) -> bool:
	if absf(point.x) > AREA_HALF or absf(point.y) > AREA_HALF:
		return false
	if absf(point.x) < PATH_HALF_WIDTH:
		return false
	if absf(point.x - STREAM_X) < STREAM_HALF_WIDTH:
		return false
	for rect: Rect2 in _blocked:
		if rect.has_point(point):
			return false
	for rock: Vector3 in _rocks:
		if Vector2(rock.x, rock.z).distance_to(point) < ROCK_CLEARANCE:
			return false
	return true


func ichu_placements() -> Array[Placement]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	var result: Array[Placement] = []
	var cells: int = int(ceilf(AREA_HALF * 2.0 / ICHU_SPACING))
	for zi: int in range(cells):
		for xi: int in range(cells):
			# Se consumen siempre los mismos números por celda.
			var jitter_x: float = rng.randf_range(-ICHU_JITTER, ICHU_JITTER)
			var jitter_z: float = rng.randf_range(-ICHU_JITTER, ICHU_JITTER)
			var roll: float = rng.randf()
			var angle: float = rng.randf_range(0.0, TAU)
			var size_factor: float = rng.randf_range(ICHU_SCALE_MIN, ICHU_SCALE_MAX)
			var variant: int = rng.randi_range(0, ICHU_FILES.size() - 1)
			var x: float = -AREA_HALF + ICHU_SPACING * (float(xi) + 0.5 + jitter_x)
			var z: float = -AREA_HALF + ICHU_SPACING * (float(zi) + 0.5 + jitter_z)
			var point: Vector2 = Vector2(x, z)
			if not is_free(point):
				continue
			var height: float = _height_at(x, z)
			# En la roca alta, el ichu escasea; en el fondo, cubre más.
			var density: float = 0.28 if height > 3.5 else 0.62
			if roll >= density:
				continue
			var rotation_basis: Basis = Basis(Vector3.UP, angle).scaled(Vector3.ONE * size_factor)
			result.append(Placement.new(Transform3D(rotation_basis, Vector3(x, height - ICHU_SINK, z)), variant))
	return result


func quenua_placements() -> Array[Placement]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = QUENUA_SEED
	var result: Array[Placement] = []
	var trunks: Array[Vector2] = []
	for grove: Vector3 in QUENUA_GROVES:
		var placed: int = 0
		for _attempt: int in range(QUENUA_ATTEMPTS):
			if placed >= QUENUA_PER_GROVE:
				break
			var angle: float = rng.randf_range(0.0, TAU)
			var distance: float = grove.z * sqrt(rng.randf())
			var heading: float = rng.randf_range(0.0, TAU)
			var size_factor: float = rng.randf_range(QUENUA_SCALE_MIN, QUENUA_SCALE_MAX)
			var variant: int = rng.randi_range(0, QUENUA_FILES.size() - 1)
			var point: Vector2 = Vector2(grove.x, grove.y) + Vector2(cos(angle), sin(angle)) * distance
			if not is_free(point):
				continue
			var crowded: bool = false
			for other: Vector2 in trunks:
				if other.distance_to(point) < QUENUA_SPACING:
					crowded = true
					break
			if crowded:
				continue
			trunks.append(point)
			var rotation_basis: Basis = Basis(Vector3.UP, heading).scaled(Vector3.ONE * size_factor)
			var origin: Vector3 = Vector3(point.x, _height_at(point.x, point.y) - QUENUA_SINK, point.y)
			result.append(Placement.new(Transform3D(rotation_basis, origin), variant))
			placed += 1
	return result


func _height_at(x: float, z: float) -> float:
	if not _height_source.is_valid():
		return 0.0
	var value: Variant = _height_source.call(x, z)
	if value is float:
		return value
	return 0.0


## Malla del primer MeshInstance3D de cada archivo existente.
static func _load_meshes(files: Array[String]) -> Array[Mesh]:
	var meshes: Array[Mesh] = []
	for file: String in files:
		var path: String = MODEL_DIR + file
		if not ResourceLoader.exists(path):
			continue
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			continue
		var instance: Node = packed.instantiate()
		var found: Array[Node] = instance.find_children("*", "MeshInstance3D", true, false)
		if not found.is_empty():
			var mesh_instance: MeshInstance3D = found[0] as MeshInstance3D
			if mesh_instance.mesh != null:
				ModelSlot.enable_vertex_colors(mesh_instance.mesh)
				meshes.append(mesh_instance.mesh)
		instance.free()
	return meshes


func _build_ichu(meshes: Array[Mesh]) -> void:
	var root: Node3D = Node3D.new()
	root.name = "Ichu"
	add_child(root)
	var material: ShaderMaterial = SurfaceMaterials.vegetation_material(ICHU_WIND_BEND)
	wind_materials.append(material)
	var placements: Array[Placement] = ichu_placements()
	for variant: int in range(meshes.size()):
		var transforms: Array[Transform3D] = []
		for placement: Placement in placements:
			if placement.variant == variant:
				transforms.append(placement.transform)
		if transforms.is_empty():
			continue
		var multimesh: MultiMesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = meshes[variant]
		multimesh.instance_count = transforms.size()
		for index: int in range(transforms.size()):
			multimesh.set_instance_transform(index, transforms[index])
		var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
		instance.name = "Ichu%d" % variant
		instance.multimesh = multimesh
		instance.material_override = material
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.visibility_range_end = ICHU_VISIBILITY_END
		instance.visibility_range_end_margin = ICHU_VISIBILITY_MARGIN
		instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		root.add_child(instance)


func _build_quenua(meshes: Array[Mesh]) -> void:
	var root: Node3D = Node3D.new()
	root.name = "Quenua"
	add_child(root)
	var placements: Array[Placement] = quenua_placements()
	var material: ShaderMaterial = SurfaceMaterials.vegetation_material(QUENUA_WIND_BEND)
	wind_materials.append(material)
	for variant: int in range(meshes.size()):
		var transforms: Array[Transform3D] = []
		for placement: Placement in placements:
			if placement.variant == variant:
				transforms.append(placement.transform)
		if transforms.is_empty():
			continue
		var multimesh: MultiMesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = meshes[variant]
		multimesh.instance_count = transforms.size()
		for index: int in range(transforms.size()):
			multimesh.set_instance_transform(index, transforms[index])
		var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
		instance.name = "Quenua%d" % variant
		instance.multimesh = multimesh
		if SurfaceMaterials.has_surface_class(meshes[variant]):
			instance.material_override = material
		root.add_child(instance)
	# Colisión del tronco: el jugador no atraviesa los árboles.
	for index: int in range(placements.size()):
		var body: StaticBody3D = StaticBody3D.new()
		body.name = "QuenuaTrunk%02d" % index
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = placements[index].transform.origin + Vector3(0.0, TRUNK_HEIGHT * 0.5, 0.0)
		var shape: CylinderShape3D = CylinderShape3D.new()
		shape.radius = TRUNK_RADIUS
		shape.height = TRUNK_HEIGHT
		var collision: CollisionShape3D = CollisionShape3D.new()
		collision.shape = shape
		body.add_child(collision)
		root.add_child(body)
