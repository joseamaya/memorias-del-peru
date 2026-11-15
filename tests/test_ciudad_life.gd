extends RefCounted
## Comprueba la vida cotidiana y el terreno del Cusco: rutinas de la multitud,
## puestos atendidos, pareja que conversa y relieve con colisión trimesh.

const CIUDAD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


func _spawn() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(CIUDAD_PATH) as PackedScene
	if packed == null:
		return null
	var ciudad: Node = packed.instantiate()
	tree.root.add_child(ciudad)
	return ciudad


func test_crowd_routines_and_vendors() -> bool:
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var crowd: Node = ciudad.get_node_or_null("Crowd")
	if crowd == null:
		crowd = ciudad.get_node_or_null("Crowd")
	if crowd == null:
		ciudad.free()
		return false
	var starts: Array[Vector3] = []
	for i: int in range(crowd.get_child_count()):
		starts.append((crowd.get_child(i) as CharacterModelVisual).position)
	# Veinte segundos de rutina: los paseantes deben haberse movido y las
	# parejas y puestos deben alternar gesto y reposo.
	for _i: int in range(200):
		ciudad.call("_process", 0.1)
	var moved: int = 0
	var gestures: int = 0
	for i: int in range(crowd.get_child_count()):
		var visual: CharacterModelVisual = crowd.get_child(i) as CharacterModelVisual
		if visual.position.distance_to(starts[i]) > 0.4:
			moved += 1
		var clip: StringName = visual.current_animation()
		if clip == &"talk" or clip == &"idle_b" or clip == &"tired":
			gestures += 1
	var ok: bool = moved >= 3 and gestures >= 4
	# Los dos puestos tienen su figura detrás del mostrador.
	for index: int in [2, 5]:
		var vendor: CharacterModelVisual = crowd.get_child(index) as CharacterModelVisual
		ok = ok and absf(vendor.position.x) > 7.5 and vendor.position.z < -5.5
	# La pareja del centro se mira.
	var pair_one: CharacterModelVisual = crowd.get_child(7) as CharacterModelVisual
	var pair_two: CharacterModelVisual = crowd.get_child(8) as CharacterModelVisual
	var to_two: Vector3 = pair_two.global_position - pair_one.global_position
	to_two.y = 0.0
	ok = ok and to_two.length() > 0.1 and (-pair_one.global_transform.basis.z).dot(to_two.normalized()) > 0.45
	ciudad.free()
	return ok


func test_ciudad_relief_and_collision() -> bool:
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var terrain: MeshInstance3D = ciudad.get_node_or_null("Terrain/TerrainMesh") as MeshInstance3D
	var body: StaticBody3D = ciudad.get_node_or_null("Terrain/TerrainBody") as StaticBody3D
	var collision: CollisionShape3D = body.get_node_or_null("TerrainCollision") as CollisionShape3D if body != null else null
	var flat_value: Variant = ciudad.call("_height_at", 0.0, 0.0)
	var near_value: Variant = ciudad.call("_height_at", 48.0, 0.0)
	var far_value: Variant = ciudad.call("_height_at", 120.0, 0.0)
	var flat: float = flat_value if flat_value is float else 999.0
	var near: float = near_value if near_value is float else -999.0
	var far: float = far_value if far_value is float else -999.0
	var ok: bool = terrain != null and terrain.mesh != null and collision != null
	ok = ok and collision.shape is ConcavePolygonShape3D
	ok = ok and is_zero_approx(flat)
	ok = ok and near > 0.05
	ok = ok and far > near
	ciudad.free()
	return ok


func test_house_variants() -> bool:
	var ciudad: Node = _spawn()
	if ciudad == null:
		return false
	var houses: Node = ciudad.get_node_or_null("Houses")
	var variants: Dictionary[String, bool] = {}
	if houses != null:
		for house: Node in houses.get_children():
			var slot: ModelSlot = house.get_node_or_null("ModelSlot") as ModelSlot
			if slot != null and not slot.model_paths.is_empty():
				variants[slot.model_paths[0]] = true
	var ok: bool = houses != null and variants.size() >= 4
	ciudad.free()
	return ok
