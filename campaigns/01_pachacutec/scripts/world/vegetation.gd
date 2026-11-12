class_name LlactaVegetation
extends Node3D
## Vegetación de la llacta (alcance §3; ficha PCH-013, reconstrucción R).
##
## Reparte matas de ichu con MultiMesh, agrupadas en bloques que se ocultan
## a distancia (`visibility_range`, docs/08 §LOD), y bosquecillos de queñua
## con colisión en el tronco. El reparto es determinista y deja libres la
## plaza, los caminos, las casas, las terrazas y el rincón de la tejedora.
## Sin los modelos no se crea nada: la vegetación no tiene bloqueo.

## Una mata o un árbol: transformación global y variante de modelo.
class Placement:
	var transform: Transform3D
	var variant: int

	func _init(placement_transform: Transform3D, model_variant: int) -> void:
		transform = placement_transform
		variant = model_variant


const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const ICHU_FILES: Array[String] = ["pch_ichu_a.glb", "pch_ichu_b.glb"]
const QUENUA_FILES: Array[String] = ["pch_quenua_a.glb", "pch_quenua_b.glb"]
const SEED: int = 13
## Semilla aparte para la queñua: cambiar el ichu no mueve los árboles.
const QUENUA_SEED: int = 29
## Medio lado del área con vegetación (los muros de respaldo están a 70 m).
const AREA_HALF: float = 67.0
## Rejilla con desplazamiento aleatorio: una mata como máximo por celda.
const ICHU_SPACING: float = 2.1
const ICHU_JITTER: float = 0.45
## La densidad crece desde el borde de la plaza hasta el campo abierto.
const ICHU_INNER_RADIUS: float = 15.0
const ICHU_FULL_RADIUS: float = 30.0
const ICHU_MIN_DENSITY: float = 0.25
## En la roca de la cresta, algo menos de matas que en el campo.
const ICHU_ROCK_HEIGHT: float = 3.0
const ICHU_ROCK_FACTOR: float = 0.85
const ICHU_SCALE_MIN: float = 0.75
const ICHU_SCALE_MAX: float = 1.35
## Las matas se hunden un poco para que la base no flote en la pendiente.
const ICHU_SINK: float = 0.04
const CHUNK_SIZE: float = 22.0
const ICHU_VISIBILITY_END: float = 50.0
const ICHU_VISIBILITY_MARGIN: float = 10.0
## Zonas libres.
const PATH_HALF_WIDTH: float = 3.5
## Los caminos este y oeste llegan hasta las terrazas y las casas exteriores.
const EAST_WEST_PATH_END: float = 37.0
const HOUSE_CLEARANCE: float = 5.5
const FREE_RECTS: Array[Rect2] = [
	Rect2(-14.5, -14.5, 29.0, 29.0), # plaza
	Rect2(28.0, -16.0, 30.0, 32.0), # terrazas y mirador
	Rect2(-14.0, 2.5, 7.0, 7.5), # tejedora y telar
]
## Bosquecillos de queñua: (x, z, radio). Árboles por bosquecillo y
## separación mínima entre troncos.
const QUENUA_GROVES: Array[Vector3] = [
	Vector3(-42.0, 34.0, 7.0),
	Vector3(-50.0, -30.0, 7.0),
	Vector3(40.0, 42.0, 7.0),
	Vector3(30.0, -48.0, 6.0),
]
const QUENUA_PER_GROVE: int = 6
const QUENUA_SPACING: float = 3.0
const QUENUA_ATTEMPTS: int = 40
const QUENUA_SCALE_MIN: float = 0.8
const QUENUA_SCALE_MAX: float = 1.2
const TRUNK_RADIUS: float = 0.4
const TRUNK_HEIGHT: float = 2.5

var _height_source: Callable = Callable()
var _houses: Array[Vector3] = []


## Crea la vegetación. [param height_source] es `func(x: float, z: float) -> float`
## con la altura del terreno; [param house_positions], el centro de cada casa.
func build(height_source: Callable, house_positions: Array[Vector3]) -> void:
	configure(height_source, house_positions)
	var ichu_meshes: Array[Mesh] = load_meshes(ICHU_FILES)
	if ichu_meshes.size() == ICHU_FILES.size():
		_build_ichu(ichu_meshes)
	var quenua_meshes: Array[Mesh] = load_meshes(QUENUA_FILES)
	if quenua_meshes.size() == QUENUA_FILES.size():
		_build_quenua(quenua_meshes)


## Fija la fuente de alturas y las casas sin crear nodos (lo usan las pruebas).
func configure(height_source: Callable, house_positions: Array[Vector3]) -> void:
	_height_source = height_source
	_houses = house_positions.duplicate()


## Malla del primer MeshInstance3D de cada archivo existente.
static func load_meshes(files: Array[String]) -> Array[Mesh]:
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


## Verdadero si en [param point] (x, z) puede crecer vegetación.
static func is_free(point: Vector2, houses: Array[Vector3]) -> bool:
	if absf(point.x) > AREA_HALF or absf(point.y) > AREA_HALF:
		return false
	if absf(point.x) < PATH_HALF_WIDTH:
		return false
	if absf(point.y) < PATH_HALF_WIDTH and absf(point.x) < EAST_WEST_PATH_END:
		return false
	for rect: Rect2 in FREE_RECTS:
		if rect.has_point(point):
			return false
	for house: Vector3 in houses:
		if Vector2(house.x, house.z).distance_to(point) < HOUSE_CLEARANCE:
			return false
	return true


## Probabilidad de mata en [param point] según la distancia a la plaza y la
## altura del terreno.
static func ichu_density(point: Vector2, height: float) -> float:
	var ramp: float = smoothstep(ICHU_INNER_RADIUS, ICHU_FULL_RADIUS, point.length())
	var density: float = lerpf(ICHU_MIN_DENSITY, 1.0, ramp)
	if height > ICHU_ROCK_HEIGHT:
		density *= ICHU_ROCK_FACTOR
	return density


func ichu_placements() -> Array[Placement]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	var result: Array[Placement] = []
	var cells: int = int(ceilf(AREA_HALF * 2.0 / ICHU_SPACING))
	for zi: int in range(cells):
		for xi: int in range(cells):
			# Se consumen siempre los mismos números por celda: el reparto no
			# depende de qué celdas quedan libres.
			var jitter_x: float = rng.randf_range(-ICHU_JITTER, ICHU_JITTER)
			var jitter_z: float = rng.randf_range(-ICHU_JITTER, ICHU_JITTER)
			var roll: float = rng.randf()
			var angle: float = rng.randf_range(0.0, TAU)
			var size_factor: float = rng.randf_range(ICHU_SCALE_MIN, ICHU_SCALE_MAX)
			var variant: int = rng.randi_range(0, ICHU_FILES.size() - 1)
			var x: float = -AREA_HALF + ICHU_SPACING * (float(xi) + 0.5 + jitter_x)
			var z: float = -AREA_HALF + ICHU_SPACING * (float(zi) + 0.5 + jitter_z)
			var point: Vector2 = Vector2(x, z)
			if not is_free(point, _houses):
				continue
			var height: float = _height_at(x, z)
			if roll >= ichu_density(point, height):
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
		for attempt: int in range(QUENUA_ATTEMPTS):
			if placed >= QUENUA_PER_GROVE:
				break
			var angle: float = rng.randf_range(0.0, TAU)
			var distance: float = grove.z * sqrt(rng.randf())
			var heading: float = rng.randf_range(0.0, TAU)
			var size_factor: float = rng.randf_range(QUENUA_SCALE_MIN, QUENUA_SCALE_MAX)
			var variant: int = rng.randi_range(0, QUENUA_FILES.size() - 1)
			var point: Vector2 = Vector2(grove.x, grove.y) + Vector2(cos(angle), sin(angle)) * distance
			if not is_free(point, _houses):
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
			var origin: Vector3 = Vector3(point.x, _height_at(point.x, point.y), point.y)
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


func _build_ichu(meshes: Array[Mesh]) -> void:
	var ichu_root: Node3D = Node3D.new()
	ichu_root.name = "Ichu"
	add_child(ichu_root)
	# Bloques de CHUNK_SIZE por variante; cada uno se oculta por separado.
	var chunks: Dictionary[Vector3i, Array] = {}
	for placement: Placement in ichu_placements():
		var origin: Vector3 = placement.transform.origin
		var key: Vector3i = Vector3i(
			floori((origin.x + AREA_HALF) / CHUNK_SIZE),
			floori((origin.z + AREA_HALF) / CHUNK_SIZE),
			placement.variant)
		if not chunks.has(key):
			chunks[key] = []
		chunks[key].append(placement.transform)
	var keys: Array[Vector3i] = []
	keys.assign(chunks.keys())
	keys.sort()
	for key: Vector3i in keys:
		var center: Vector3 = Vector3(
			-AREA_HALF + CHUNK_SIZE * (float(key.x) + 0.5), 0.0,
			-AREA_HALF + CHUNK_SIZE * (float(key.y) + 0.5))
		var transforms: Array = chunks[key]
		var multimesh: MultiMesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = meshes[key.z]
		multimesh.instance_count = transforms.size()
		for index: int in range(transforms.size()):
			var global_transform_item: Transform3D = transforms[index]
			multimesh.set_instance_transform(index, global_transform_item.translated(-center))
		var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
		instance.name = "IchuChunk_%d_%d_%d" % [key.x, key.y, key.z]
		instance.position = center
		instance.multimesh = multimesh
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.visibility_range_end = ICHU_VISIBILITY_END
		instance.visibility_range_end_margin = ICHU_VISIBILITY_MARGIN
		instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		ichu_root.add_child(instance)


func _build_quenua(meshes: Array[Mesh]) -> void:
	var quenua_root: Node3D = Node3D.new()
	quenua_root.name = "Quenua"
	add_child(quenua_root)
	var placements: Array[Placement] = quenua_placements()
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
		instance.name = "QuenuaTrees_%d" % variant
		instance.multimesh = multimesh
		# Corteza con textura de madera (clase de superficie del generador).
		if SurfaceMaterials.has_surface_class(meshes[variant]):
			instance.material_override = SurfaceMaterials.model_material()
		quenua_root.add_child(instance)
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
		quenua_root.add_child(body)
