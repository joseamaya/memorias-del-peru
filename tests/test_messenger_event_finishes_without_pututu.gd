extends RefCounted
## Comprueba que el evento termina aunque el jugador nunca toque el pututu.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MAX_STEPS: int = 600
const STEP_SECONDS: float = 0.5


func test_messenger_event_finishes_without_pututu() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	if event == null or player == null or pututu == null:
		world.free()
		return false
	# El driver de audio «Dummy» de las pruebas sin pantalla no libera las
	# reproducciones; el sonido no es objeto de esta prueba.
	pututu.audio_stream = null
	player.global_position = Vector3(0.0, 0.05, 2.0)
	var steps: int = 0
	while event.phase != MessengerEvent.Phase.DONE and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		steps += 1
	var finished_without_pututu: bool = (
		event.phase == MessengerEvent.Phase.DONE
		and event.completed
		and not event.pututu_by_player
		and pututu.used
	)
	world.free()
	return finished_without_pututu
