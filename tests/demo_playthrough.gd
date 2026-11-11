extends SceneTree
## Partida completa conducida por un guion: comprobación y vídeo de demostración.
##
## Comprobación, sin pantalla (unos 2–3 min reales):
##   godot --headless --path . --fixed-fps 30 --script res://tests/demo_playthrough.gd
## Vídeo con Movie Maker (AVI MJPEG con sonido; luego se puede pasar a MP4):
##   godot --path . --write-movie demo.avi --fixed-fps 30 --script res://tests/demo_playthrough.gd
##
## El jugador recorre la plaza, bebe del quero, deja la ofrenda, habla con la
## tejedora, visita las casas del oeste, sube al mirador, vuelve a la plaza, mira al
## mensajero, toca el pututu y sigue a la comitiva hasta el cierre. Al final
## comprueba que el evento terminó, que el quero y la ofrenda respondieron y que
## el pututu lo tocó el jugador; imprime DEMO_OK o DEMO_FALLO y sale con 0 o 1.
## No forma parte del juego. Como el soak, no usa tipos de la campaña: con
## `--script`, los autoloads aún no existen cuando se compila este archivo.

const PHASE_ARRIVAL: int = 1
const PHASE_MESSAGE: int = 2
const PHASE_CALL: int = 3
const PHASE_DEPARTURE: int = 4
const PHASE_DONE: int = 5
const TURN_RATE: float = 2.2
const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
## Límite de tiempo de juego: la partida dura unos 5 min.
const MAX_GAME_SECONDS: float = 600.0
const ARRIVE_DISTANCE: float = 0.6


class Step:
	var kind: String
	var point: Vector3
	var seconds: float
	var run: bool
	var node_path: String
	var phase: int

	func _init(step_kind: String, step_point: Vector3 = Vector3.ZERO, step_seconds: float = 0.0, step_run: bool = false, step_node: String = "", step_phase: int = -1) -> void:
		kind = step_kind
		point = step_point
		seconds = step_seconds
		run = step_run
		node_path = step_node
		phase = step_phase


var world: Node = null
var player: CharacterBody3D = null
var head: Node3D = null
var event: Node = null
var frames: int = 0
var clock: float = 0.0
var steps: Array[Step] = []
var index: int = 0
var step_time: float = 0.0
var stuck: float = 0.0
var last_pos: Vector3 = Vector3.ZERO
var look_target: Vector3 = Vector3(0.0, 1.5, 0.0)
var closing: bool = false
var quero_responded: bool = false
var talked: bool = false


func _initialize() -> void:
	world = (load(WORLD_PATH) as PackedScene).instantiate()
	root.add_child(world)
	steps = [
		Step.new("look", Vector3(0, 1.4, 0), 4.0),
		Step.new("look", Vector3(-25, 2, 10), 2.5),
		Step.new("look", Vector3(30, 2, 5), 2.5),
		Step.new("walk", Vector3(0, 0, 15)),
		Step.new("walk", Vector3(4, 0, 5.6)),
		Step.new("look", Vector3(4, 0.95, 4), 1.2),
		Step.new("interact", Vector3(4, 0.95, 4), 3.0),
		Step.new("walk", Vector3(-6.4, 0, 8.2)),
		Step.new("look", Vector3(-8, 0.3, 7), 1.2),
		Step.new("interact", Vector3(-8, 0.3, 7), 3.5),
		Step.new("walk", Vector3(-9.3, 0, 6.0)),
		Step.new("look", Vector3(-11, 1.3, 5), 1.0),
		Step.new("interact", Vector3(-11, 1.3, 5), 4.0),
		Step.new("look", Vector3(-10, 0.3, 7.5), 2.0),
		Step.new("walk", Vector3(-12, 0, 0)),
		Step.new("walk", Vector3(-30, 0, 0), 0.0, true),
		Step.new("look", Vector3(-27, 2, 6), 2.0),
		Step.new("look", Vector3(-42, 1.5, 34), 2.5),
		Step.new("walk", Vector3(-4, 0, 0), 0.0, true),
		Step.new("walk", Vector3(28, 0, 0), 0.0, true),
		Step.new("walk", Vector3(52, 0, 0)),
		Step.new("look", Vector3(30, 1, -45), 3.0),
		Step.new("look", Vector3(0, 0.5, -60), 2.5),
		Step.new("look", Vector3(0, 1, 0), 3.0),
		Step.new("walk", Vector3(28, 0, 0), 0.0, true),
		Step.new("walk", Vector3(3, 0, 6), 0.0, true),
		Step.new("look", Vector3(-8, 1.4, 0), 3.0),
		Step.new("look", Vector3(9, 1.4, 3), 3.0),
		Step.new("look", Vector3(0, 1.5, -40), 2.0),
		Step.new("wait_phase", Vector3(0, 1.5, -40), 0.0, false, "", PHASE_ARRIVAL),
		Step.new("track", Vector3.ZERO, 0.0, false, "Llacta/NPCs/Mensajero", PHASE_MESSAGE),
		Step.new("track", Vector3.ZERO, 0.0, false, "Llacta/NPCs/Curaca", PHASE_CALL),
		Step.new("walk", Vector3(-4, 0, 5.6)),
		Step.new("look", Vector3(-4, 1.1, 4), 1.0),
		Step.new("interact", Vector3(-4, 1.1, 4), 3.0),
		Step.new("walk", Vector3(1, 0, 8)),
		Step.new("track", Vector3.ZERO, 0.0, false, "Llacta/NPCs/Curaca", PHASE_DEPARTURE),
		Step.new("track", Vector3.ZERO, 0.0, false, "Llacta/NPCs/Curaca", PHASE_DONE),
		Step.new("look", Vector3(0, 1.5, -40), 9.0),
	]


func _note(text: String) -> void:
	print("[%6.1f s] %s" % [clock, text])


func _phase() -> int:
	var value: Variant = event.get("phase")
	return value if value is int else -1


func _turn_towards(target: Vector3, delta: float) -> void:
	var to: Vector3 = target - player.global_position
	var desired_yaw: float = atan2(-to.x, -to.z)
	player.rotation.y = lerp_angle(player.rotation.y, desired_yaw, minf(1.0, TURN_RATE * delta))
	var eye: Vector3 = head.global_position
	var desired_pitch: float = atan2(target.y - eye.y, Vector2(target.x - eye.x, target.z - eye.z).length())
	head.rotation.x = lerpf(head.rotation.x, desired_pitch, minf(1.0, TURN_RATE * delta))


func _press_interact() -> void:
	var action: InputEventAction = InputEventAction.new()
	action.action = "interact"
	action.pressed = true
	Input.parse_input_event(action)
	var release: InputEventAction = InputEventAction.new()
	release.action = "interact"
	release.pressed = false
	Input.parse_input_event(release)


func _process(delta: float) -> bool:
	frames += 1
	if frames == 3:
		player = world.get_node("PlayerFPS") as CharacterBody3D
		head = player.get_node("Head") as Node3D
		event = world.get_node("EventController")
		var talk: Node = world.get_node_or_null("Llacta/NPCs/Tejedora/Talk")
		if talk != null:
			talk.connect("spoke", _on_spoke)
	if frames < 3 or closing:
		return false
	clock += delta
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if index >= steps.size() or clock > MAX_GAME_SECONDS:
		_close()
		return false
	var step: Step = steps[index]
	step_time += delta
	match step.kind:
		"look":
			look_target = step.point
			_turn_towards(look_target, delta)
			if step_time >= step.seconds:
				_next()
		"interact":
			_turn_towards(step.point, delta)
			if step_time - delta <= 0.4 and step_time > 0.4:
				_press_interact()
				_note("interactúa con %s" % str(step.point))
			if step_time - delta <= 0.6 and step_time > 0.6:
				_record_quero()
			if step_time >= step.seconds:
				_next()
		"walk":
			_walk(step, delta)
		"wait_phase":
			# Paneo lento mientras espera la llegada del mensajero.
			var sweep: float = sin(clock * 0.15) * 25.0
			_turn_towards(Vector3(sweep, 1.6, -30.0), delta)
			if _phase() >= step.phase:
				_next()
		"track":
			var actor: Node3D = world.get_node_or_null(step.node_path) as Node3D
			if actor != null and actor.is_visible_in_tree():
				_turn_towards(actor.global_position + Vector3(0.0, 1.3, 0.0), delta)
			if _phase() >= step.phase:
				_next()
	return false


func _walk(step: Step, delta: float) -> void:
	var pos: Vector3 = player.global_position
	var target: Vector3 = step.point
	if Vector2(target.x - pos.x, target.z - pos.z).length() < ARRIVE_DISTANCE:
		_next()
		return
	_turn_towards(Vector3(target.x, pos.y + 1.55, target.z), delta * 2.0)
	Input.action_press("move_forward")
	if step.run:
		Input.action_press("run")
	stuck = stuck + delta if pos.distance_to(last_pos) < 0.01 else 0.0
	last_pos = pos
	if stuck > 3.0:
		_note("atascado camino de %s" % str(target))
		_next()


func _next() -> void:
	Input.action_release("move_forward")
	Input.action_release("run")
	_note("paso %d hecho (%s); fase %d" % [index, steps[index].kind, _phase()])
	index += 1
	step_time = 0.0
	stuck = 0.0


func _on_spoke(_actor: Node3D, _line_key: StringName) -> void:
	talked = true


## El quero no guarda si se usó: se mira su espera entre usos justo después.
func _record_quero() -> void:
	var quero: Node = world.get_node_or_null("QueroChicha")
	if quero == null:
		return
	var cooldown: Variant = quero.get("_cooldown_remaining")
	if cooldown is float and cooldown > 0.0:
		quero_responded = true


func _close() -> void:
	closing = true
	Input.action_release("move_forward")
	Input.action_release("run")
	var ofrenda: Node = world.get_node_or_null("OfrendaPachamama")
	var offering_used: Variant = ofrenda.get("used") if ofrenda != null else false
	var by_player: Variant = event.get("pututu_by_player")
	var checks: Dictionary[String, bool] = {
		"evento terminado": _phase() == PHASE_DONE,
		"quero respondió": quero_responded,
		"habló con la tejedora": talked,
		"ofrenda dejada": offering_used is bool and offering_used,
		"pututu tocado por el jugador": by_player is bool and by_player,
	}
	var ok: bool = true
	for key: String in checks:
		_note("%s: %s" % [key, "sí" if checks[key] else "NO"])
		ok = ok and checks[key]
	print("DEMO_OK" if ok else "DEMO_FALLO")
	# Cierre ordenado del juego (GameManager detiene el audio antes de salir).
	var manager: Node = root.get_node_or_null("GameManager")
	if manager != null:
		manager.call("request_quit", 0 if ok else 1)
	else:
		quit(0 if ok else 1)
