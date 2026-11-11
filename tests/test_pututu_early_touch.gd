extends RefCounted
## Comprueba que el pututu no puede gastarse antes de la llamada y que el
## evento termina aunque llegue gastado (ADR-0007 y ADR-0008).

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const STEP_SECONDS: float = 2.0
const MAX_STEPS: int = 500

var _departures: int = 0


func _on_phase(phase: int) -> void:
	if phase == MessengerEvent.Phase.DEPARTURE:
		_departures += 1


func _spawn() -> Array:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return []
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return []
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var pututu: Pututu = world.get_node_or_null("Pututu") as Pututu
	if event == null or player == null or pututu == null:
		world.free()
		return []
	# El driver de audio de las pruebas sin pantalla no libera las
	# reproducciones; el sonido no es objeto de estas pruebas.
	pututu.audio_stream = null
	return [world, event, player, pututu]


func _run_to_done(event: MessengerEvent) -> void:
	var steps: int = 0
	while event.phase != MessengerEvent.Phase.DONE and steps < MAX_STEPS:
		event.step(STEP_SECONDS)
		steps += 1


func test_pututu_ignores_early_touch() -> bool:
	var fixture: Array = _spawn()
	if fixture.is_empty():
		return false
	var world: Node = fixture[0]
	var event: MessengerEvent = fixture[1]
	var player: Node3D = fixture[2]
	var pututu: Pututu = fixture[3]
	player.global_position = Vector3(0.0, 0.05, 2.0)
	# Antes del reloj el pututu no está armado: el intento no lo gasta.
	event.step(5.0)
	pututu.interact(player)
	var ignored: bool = not pututu.used and not pututu.is_available()
	_run_to_done(event)
	var finished: bool = event.phase == MessengerEvent.Phase.DONE
	world.free()
	return ignored and finished


func test_event_finishes_with_spent_pututu() -> bool:
	var fixture: Array = _spawn()
	if fixture.is_empty():
		return false
	var world: Node = fixture[0]
	var event: MessengerEvent = fixture[1]
	var player: Node3D = fixture[2]
	var pututu: Pututu = fixture[3]
	player.global_position = Vector3(0.0, 0.05, 2.0)
	# Peor caso: el pututu ya se gastó por cualquier vía antes de la llamada.
	pututu.force_play()
	_run_to_done(event)
	var ok: bool = (
		event.phase == MessengerEvent.Phase.DONE
		and event.completed
		and not event.pututu_by_player
	)
	world.free()
	return ok


func test_curaca_calls_once() -> bool:
	var fixture: Array = _spawn()
	if fixture.is_empty():
		return false
	var world: Node = fixture[0]
	var event: MessengerEvent = fixture[1]
	var player: Node3D = fixture[2]
	player.global_position = Vector3(0.0, 0.05, 2.0)
	event.phase_changed.connect(_on_phase)
	_run_to_done(event)
	var ok: bool = event.phase == MessengerEvent.Phase.DONE and _departures == 1
	world.free()
	return ok
