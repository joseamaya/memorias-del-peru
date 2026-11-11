extends RefCounted
## Comprueba el orden y la unicidad de los subtítulos narrativos.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MAX_STEPS: int = 600
const STEP_SECONDS: float = 0.5

var _keys: Array[StringName] = []


func _on_subtitle(text_key: StringName, _seconds: float) -> void:
	_keys.append(text_key)


func test_narrative_beats_order() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	if event == null:
		world.free()
		return false
	event.subtitle_requested.connect(_on_subtitle)
	tree.root.add_child(world)
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if player == null:
		world.free()
		return false
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	if pututu == null:
		world.free()
		return false
	# El driver de audio de las pruebas sin pantalla no libera las
	# reproducciones; el sonido no es objeto de esta prueba.
	pututu.audio_stream = null
	player.global_position = Vector3(0.0, 0.05, 2.0)
	var steps: int = 0
	while event.phase != MessengerEvent.Phase.DONE and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		steps += 1
	var expected: Array[StringName] = [
		&"PCH_NARR_OPENING",
		&"PCH_NARR_NEWS_1",
		&"PCH_NARR_NEWS_2",
		&"PCH_NARR_CLOSING_1",
		&"PCH_NARR_CLOSING_2",
	]
	var ordered: bool = _keys.size() == expected.size()
	if ordered:
		for index: int in range(expected.size()):
			if _keys[index] != expected[index]:
				ordered = false
				break
	var ok: bool = event.phase == MessengerEvent.Phase.DONE and ordered
	world.free()
	return ok
