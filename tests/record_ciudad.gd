extends SceneTree
## Partida guionada del acto III para vídeo: reclutamiento, Cusi y defensa.
##
##   godot --path . --write-movie build/acto3.avi --fixed-fps 30 \
##       --script res://tests/record_ciudad.gd
##
## Recorre la plaza, habla con los tres grupos, escucha a Cusi Yupanqui, sostiene
## la defensa y llega al epílogo. No forma parte del juego.

const SCENE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"
const RECRUITS: Array[Vector3] = [
	Vector3(-15.0, 0.0, 0.0),
	Vector3(15.0, 0.0, 0.0),
	Vector3(0.0, 0.0, 12.0),
]
const RECRUIT_STAND: Array[Vector3] = [
	Vector3(-13.0, 0.0, 1.6),
	Vector3(13.0, 0.0, 1.6),
	Vector3(0.0, 0.0, 14.2),
]
const CUSI: Vector3 = Vector3(0.0, 0.0, -12.0)
const CUSI_STAND: Vector3 = Vector3(0.0, 0.0, -9.2)
const ARRIVE_DISTANCE: float = 0.9
const TURN_RATE: float = 2.4
const ATTACK_INTERVAL: float = 1.5
const COMBAT_LIMIT: float = 60.0
const MAX_GAME_SECONDS: float = 240.0

var _world: Node = null
var _player: CharacterBody3D = null
var _head: Node3D = null
var _clock: float = 0.0
var _step: int = 0
var _step_time: float = 0.0
var _attack_cooldown: float = 0.0
var _combat_time: float = 0.0
## Cusi abre la defensa con la primera opción («estoy listo»); el resto de
## conversaciones eligen la última.
var _prefer_first: bool = false
var _frames: int = 0


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	# Lienzo fijo a 1080p: con el aspecto "expand" del proyecto, una ventana
	# más ancha ensancha el lienzo y el vídeo recorta el HUD por la izquierda.
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_size = Vector2i(1920, 1080)
	change_scene_to_file(SCENE)
	await process_frame
	await process_frame
	_world = current_scene
	_player = _world.get_node("PlayerFPS") as CharacterBody3D
	_head = _player.get_node("Head") as Node3D
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# El acto III se graba solo, así que las decisiones del acto II se dan por
	# tomadas: sin ellas los tres grupos rechazan unirse y la defensa queda
	# vacía. Es el camino con aliados.
	var state: CampaignStateService = root.get_node_or_null("CampaignState") as CampaignStateService
	if state != null:
		state.set_flag(&"descanso", 1)
		state.set_flag(&"herido_salvado", 1)
		state.set_flag(&"maiz_guardado", 1)
		state.set_flag(&"scout_spared", 1)
	# Solo para el vídeo: el jugador aguanta la defensa sin morir y con aliento
	# de sobra; la honda del Cusco cuesta 10 por disparo y sin esto el guion se
	# queda sin atacar.
	var pc: CharacterState = _world.get_node_or_null("PlayerFPS/CharacterState") as CharacterState
	if pc != null:
		pc.health = pc.max_health
	var stamina: StaminaComponent = _player.get_node_or_null("StaminaComponent") as StaminaComponent
	if stamina != null:
		stamina.max_stamina = 1000.0
		stamina.restore(1000.0)


func _process(delta: float) -> bool:
	_frames += 1
	if _frames < 4:
		return false
	_clock += delta
	_step_time += delta
	_keep_health()
	_close_dialogue()
	if _step >= 12 or _clock > MAX_GAME_SECONDS:
		return _finish()
	match _step:
		0, 2, 4:
			_walk(RECRUIT_STAND[_step / 2], delta)
		1, 3, 5:
			var index: int = _step / 2
			_turn_towards(RECRUITS[index] + Vector3(0.0, 1.1, 0.0), delta)
			if _step_time > 0.9:
				_prefer_first = true
				_interact()
				print("CIUDAD habla con el grupo ", index)
				_advance()
		6:
			_walk(CUSI_STAND, delta)
		7:
			_turn_towards(CUSI + Vector3(0.0, 1.1, 0.0), delta)
			if _step_time > 1.0:
				_prefer_first = true
				_interact()
				print("CIUDAD habla con Cusi")
				_advance()
		8:
			if _step_time > 2.5:
				_advance()
		9:
			_combat(delta)
		10:
			# Plano final: el santuario y la plaza, no la pared de una casa.
			_turn_towards(Vector3(0.0, 2.2, -15.0), delta)
			if _step_time > 5.0:
				_advance()
		11:
			_turn_towards(Vector3(-9.0, 1.4, 4.0), delta)
			if _step_time > 4.0:
				_advance()
	return false


## Solo para el vídeo: la salud vuelve al máximo para no morir ni mostrar un
## número inflado en el HUD.
func _keep_health() -> void:
	var pc: CharacterState = _world.get_node_or_null("PlayerFPS/CharacterState") as CharacterState
	if pc != null and pc.health < pc.max_health:
		pc.health = pc.max_health


func _combat(delta: float) -> void:
	_combat_time += delta
	_attack_cooldown -= delta
	if _combat_time == delta:
		print("CIUDAD defensa activa=", _world.call("is_ambush_active"))
	var enemy: Node3D = _nearest_enemy()
	if enemy != null:
		_turn_towards(enemy.global_position + Vector3(0.0, 1.1, 0.0), delta)
		if _attack_cooldown <= 0.0:
			_attack()
			_attack_cooldown = ATTACK_INTERVAL
	if _world.call("is_ambush_active") == false or _combat_time > COMBAT_LIMIT:
		_clear_remaining()
		_advance()


func _clear_remaining() -> void:
	for index: int in range(1, 5):
		var enemy: Node = _world.get_node_or_null("Defender%d" % index)
		if enemy != null and enemy.call("is_alive"):
			enemy.call("take_hit", 999.0)


func _alive_count() -> int:
	var count: int = 0
	for index: int in range(1, 5):
		var enemy: Node = _world.get_node_or_null("Defender%d" % index)
		if enemy != null and enemy.call("is_alive"):
			count += 1
	return count


func _nearest_enemy() -> Node3D:
	var best: Node3D = null
	var best_distance: float = 1e9
	for index: int in range(1, 5):
		var enemy: Node3D = _world.get_node_or_null("Defender%d" % index) as Node3D
		if enemy == null or not enemy.call("is_alive"):
			continue
		var distance: float = enemy.global_position.distance_to(_player.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best


func _walk(target: Vector3, delta: float) -> void:
	var pos: Vector3 = _player.global_position
	if Vector2(target.x - pos.x, target.z - pos.z).length() < ARRIVE_DISTANCE:
		_stop()
		_advance()
		return
	_turn_towards(Vector3(target.x, pos.y + 1.55, target.z), delta * 2.0)
	Input.action_press("move_forward")


func _stop() -> void:
	Input.action_release("move_forward")
	Input.action_release("run")


func _advance() -> void:
	_step += 1
	_step_time = 0.0


func _finish() -> bool:
	_stop()
	print("CIUDAD tiempo=%.1f s" % _clock)
	print("RECORD_CIUDAD_OK")
	quit(0)
	return true


func _turn_towards(target: Vector3, delta: float) -> void:
	var to: Vector3 = target - _player.global_position
	if Vector2(to.x, to.z).length() < 0.05:
		return
	var desired: float = atan2(-to.x, -to.z)
	_player.rotation.y = lerp_angle(_player.rotation.y, desired, minf(1.0, TURN_RATE * delta))
	var eye: Vector3 = _head.global_position
	var look: Vector3 = target - eye
	_head.rotation.x = lerp_angle(
		_head.rotation.x, atan2(look.y, Vector2(look.x, look.z).length()), minf(1.0, TURN_RATE * delta))


func _interact() -> void:
	var press: InputEventAction = InputEventAction.new()
	press.action = &"interact"
	press.pressed = true
	Input.parse_input_event(press)
	var release: InputEventAction = InputEventAction.new()
	release.action = &"interact"
	release.pressed = false
	Input.parse_input_event(release)


func _attack() -> void:
	_world.call("_attack")


func _close_dialogue() -> void:
	var hud: Node = _world.get_node_or_null("UILayer/HUD")
	if hud == null:
		return
	var panel: DialoguePanel = hud.get_node_or_null("DialoguePanel") as DialoguePanel
	if panel == null or not panel.is_open():
		return
	var count: int = panel.get_choice_count()
	if count > 0:
		panel.choice_selected.emit(0 if _prefer_first else count - 1)
	else:
		panel.advanced.emit()
