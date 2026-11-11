extends RefCounted
## Comprueba que el pututu convoca la reunión cuando el jugador lo toca.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MAX_STEPS: int = 200
const STEP_SECONDS: float = 0.5


func test_pututu_convenes_meeting() -> bool:
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
	while event.phase != MessengerEvent.Phase.CALL and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		steps += 1
	if event.phase != MessengerEvent.Phase.CALL:
		world.free()
		return false
	pututu.interact(player)
	var ok: bool = (
		event.phase == MessengerEvent.Phase.DEPARTURE
		and event.pututu_by_player
		and pututu.used
	)
	world.free()
	return ok
