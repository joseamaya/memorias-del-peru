extends RefCounted
## Comprueba la vegetación de la llacta (PCH-013): reparto determinista,
## ninguna mata ni árbol en la plaza, los caminos, las casas, las terrazas o
## el rincón de la tejedora, matas apoyadas en el terreno, bloques de ichu que
## se ocultan a distancia sin sombra y troncos de queñua con colisión.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MIN_ICHU: int = 1500
const MIN_QUENUA: int = 20
## Puntos que deben quedar despejados: inicio, plaza, salida de la comitiva,
## tejedora, extremo del telar y mirador.
const BLOCKED_POINTS: Array[Vector2] = [
	Vector2(0.0, 45.0),
	Vector2(0.0, 2.0),
	Vector2(-1.5, -52.0),
	Vector2(1.5, -52.0),
	Vector2(0.0, -60.0),
	Vector2(-11.0, 5.0),
	Vector2(-10.0, 8.0),
	Vector2(52.0, 0.0),
	Vector2(20.0, 0.0),
	Vector2(-20.0, 0.0),
]
## Campo abierto donde sí debe poder crecer.
const OPEN_POINT: Vector2 = Vector2(-40.0, 30.0)


func _house_positions(world: Node) -> Array[Vector3]:
	var houses: Array[Vector3] = []
	var root: Node = world.get_node_or_null("Llacta/Houses")
	if root == null:
		return houses
	for child: Node in root.get_children():
		var house: Node3D = child as Node3D
		if house != null:
			houses.append(house.global_position)
	return houses


func _same(a: Array[LlactaVegetation.Placement], b: Array[LlactaVegetation.Placement]) -> bool:
	if a.size() != b.size() or a.is_empty():
		return false
	for index: int in [0, int(a.size() / 2.0), a.size() - 1]:
		if not a[index].transform.is_equal_approx(b[index].transform) or a[index].variant != b[index].variant:
			return false
	return true


func test_vegetation() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var ok: bool = true
	var vegetation: LlactaVegetation = world.get_node_or_null("Llacta/Vegetation") as LlactaVegetation
	var houses: Array[Vector3] = _house_positions(world)
	var height_source: Callable = Callable(world, "_height_at")
	ok = ok and vegetation != null and houses.size() == 8
	if not ok:
		world.free()
		return false

	# Zonas despejadas.
	for point: Vector2 in BLOCKED_POINTS:
		ok = ok and not LlactaVegetation.is_free(point, houses)
	for house: Vector3 in houses:
		ok = ok and not LlactaVegetation.is_free(Vector2(house.x, house.z), houses)
	ok = ok and LlactaVegetation.is_free(OPEN_POINT, houses)

	# Ichu: libre, apoyado en el terreno y determinista.
	var ichu: Array[LlactaVegetation.Placement] = vegetation.ichu_placements()
	ok = ok and ichu.size() >= MIN_ICHU
	for placement: LlactaVegetation.Placement in ichu:
		var origin: Vector3 = placement.transform.origin
		var ground: float = height_source.call(origin.x, origin.z)
		ok = ok and LlactaVegetation.is_free(Vector2(origin.x, origin.z), houses)
		ok = ok and absf(origin.y - (ground - LlactaVegetation.ICHU_SINK)) < 0.001
	var again: LlactaVegetation = LlactaVegetation.new()
	again.configure(height_source, houses)
	ok = ok and _same(ichu, again.ichu_placements())

	# Bloques de ichu: todas las matas, ocultos a distancia y sin sombra.
	var total: int = 0
	var chunks: Array[Node] = vegetation.find_children("IchuChunk*", "MultiMeshInstance3D", true, false)
	for node: Node in chunks:
		var chunk: MultiMeshInstance3D = node as MultiMeshInstance3D
		total += chunk.multimesh.instance_count
		ok = ok and is_equal_approx(chunk.visibility_range_end, LlactaVegetation.ICHU_VISIBILITY_END)
		ok = ok and chunk.visibility_range_fade_mode == GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		ok = ok and chunk.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ok = ok and not chunks.is_empty() and total == ichu.size()

	# Queñua: separada, libre, determinista y con tronco sólido.
	var quenua: Array[LlactaVegetation.Placement] = vegetation.quenua_placements()
	ok = ok and quenua.size() >= MIN_QUENUA
	ok = ok and _same(quenua, again.quenua_placements())
	for i: int in range(quenua.size()):
		var a: Vector3 = quenua[i].transform.origin
		ok = ok and LlactaVegetation.is_free(Vector2(a.x, a.z), houses)
		for j: int in range(i + 1, quenua.size()):
			var b: Vector3 = quenua[j].transform.origin
			ok = ok and Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z)) >= LlactaVegetation.QUENUA_SPACING
	var trunks: Array[Node] = vegetation.find_children("QuenuaTrunk*", "StaticBody3D", true, false)
	ok = ok and trunks.size() == quenua.size()
	for node: Node in trunks:
		var trunk: StaticBody3D = node as StaticBody3D
		ok = ok and trunk.collision_layer == 1 and trunk.get_child_count() == 1
	again.free()
	world.free()
	return ok
