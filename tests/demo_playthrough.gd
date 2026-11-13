extends SceneTree
## Partida completa conducida por un guion: comprobación y vídeo de demostración.
##
## Comprobación, sin pantalla (unos 2–3 min reales):
##   godot --headless --path . --fixed-fps 30 --script res://tests/demo_playthrough.gd
## Vídeo con Movie Maker (AVI MJPEG con sonido; luego se puede pasar a MP4):
##   godot --path . --write-movie demo.avi --fixed-fps 30 --script res://tests/demo_playthrough.gd
## Vídeo de promoción, con el perfil gráfico Alto y el HUD limpio:
##   godot --path . --disable-vsync --write-movie build/demo.avi --fixed-fps 30 \
##       --script res://tests/demo_playthrough.gd -- --promo
##
## Tras la introducción, el jugador recorre la plaza, bebe del quero, deja la ofrenda, habla con la
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
## En promoción se reduce el balanceo para un vídeo más limpio. El giro se
## mantiene igual que en la partida normal: bajar su velocidad desincroniza
## los pasos de interacción del guion.
const PROMO_TURN_RATE: float = 2.2
const PROMO_BOB_WALK: float = 0.024
const PROMO_BOB_RUN: float = 0.045
## GraphicsSettings: Bajo = 0, Medio = 1, Alto = 2, Ultra = 3.
const PROMO_PROFILE_INDEX: int = 2
const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
## Límite de tiempo de juego: la partida dura unos 5 min.
const MAX_GAME_SECONDS: float = 600.0
const ARRIVE_DISTANCE: float = 0.6
## MundoBase.IntroMode.ALWAYS (sin usar el tipo, ver la cabecera).
const INTRO_MODE_ALWAYS: int = 1


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
var saw_intro: bool = false
var promo: bool = false
var _turn_rate: float = TURN_RATE


func _initialize() -> void:
	promo = OS.get_cmdline_user_args().has("--promo")
	if promo:
		_turn_rate = PROMO_TURN_RATE
	world = (load(WORLD_PATH) as PackedScene).instantiate()
	# La partida real empieza con la introducción (ADR-0023): se fuerza, porque
	# aquí el mundo no es la escena principal.
	world.set("intro_mode", INTRO_MODE_ALWAYS)
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
		# La tejedora teje arrodillada al extremo del telar (ADR-0015).
		Step.new("walk", Vector3(-8.9, 0, 7.6)),
		Step.new("look", Vector3(-10.35, 0.6, 6.35), 1.0),
		Step.new("interact", Vector3(-10.35, 0.6, 6.35), 4.0),
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
	player.rotation.y = lerp_angle(player.rotation.y, desired_yaw, minf(1.0, _turn_rate * delta))
	var eye: Vector3 = head.global_position
	var desired_pitch: float = atan2(target.y - eye.y, Vector2(target.x - eye.x, target.z - eye.z).length())
	head.rotation.x = lerpf(head.rotation.x, desired_pitch, minf(1.0, _turn_rate * delta))


func _press_interact() -> void:
	var action: InputEventAction = InputEventAction.new()
	action.action = "interact"
	action.pressed = true
	Input.parse_input_event(action)
	var release: InputEventAction = InputEventAction.new()
	release.action = "interact"
	release.pressed = false
	Input.parse_input_event(release)


## Perfil gráfico de la captura de promoción. No cambia el perfil por defecto
## del juego: solo se aplica mientras dura este guion.
func _apply_promo_profile() -> void:
	var settings: Node = root.get_node_or_null("GraphicsSettings")
	if settings == null:
		print("DEMO promo: GraphicsSettings no disponible")
		return
	settings.call("set_profile_by_index", PROMO_PROFILE_INDEX)
	print("DEMO promo: perfil gráfico ", PROMO_PROFILE_INDEX, " (Alto) y HUD limpio")


## Quita del encuadre la barra de estamina, el aviso de interacción y la
## indicación de controles. Los subtítulos y la tarjeta de fin se mantienen.
func _hide_promo_hud() -> void:
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if hud == null:
		return
	for node_name: String in ["InteractionLabel", "StaminaBar", "HintLabel", "ObjectiveLabel", "EndPanel/EndHint"]:
		var item: CanvasItem = hud.get_node_or_null(node_name) as CanvasItem
		if item != null:
			item.visible = false


func _process(delta: float) -> bool:
	frames += 1
	if frames == 3:
		player = world.get_node("PlayerFPS") as CharacterBody3D
		head = player.get_node("Head") as Node3D
		event = world.get_node("EventController")
		var talk: Node = world.get_node_or_null("Llacta/NPCs/Tejedora/Talk")
		if talk != null:
			talk.connect("spoke", _on_spoke)
			talk.connect("dialogue_requested", _on_dialogue_requested)
		if promo:
			player.set("bob_walk_amplitude", PROMO_BOB_WALK)
			player.set("bob_run_amplitude", PROMO_BOB_RUN)
			_apply_promo_profile()
	if frames < 3 or closing:
		return false
	# Las tarjetas de lugar se abren solas: el guion las cierra para seguir.
	# Cerrar una tarjeta que no está abierta no hace nada.
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if hud != null:
		hud.call("close_tour_card")
		var panel: DialoguePanel = hud.get_node_or_null("DialoguePanel") as DialoguePanel
		if panel != null and panel.is_open():
			var count: int = panel.get_choice_count()
			if count > 0:
				panel.choice_selected.emit(count - 1)
			else:
				panel.advanced.emit()
	if promo:
		_hide_promo_hud()
	# Se espera a que terminen las tarjetas, sin pulsar nada, como quien lee.
	if world.call("is_intro_playing"):
		saw_intro = true
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
			# El guion no recorre las estaciones del museo: fuerza el evento para
			# seguir comprobando la secuencia narrativa completa.
			if _phase() < step.phase:
				event.call("start")
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


func _on_dialogue_requested(_actor: Node3D, _graph: DialogueGraph) -> void:
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
		"introducción mostrada": saw_intro,
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
