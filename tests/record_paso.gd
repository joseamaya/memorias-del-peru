extends SceneTree
## Partida guionada del acto II para vídeo: campamento, emboscada y decisión.
##
##   godot --path . --write-movie build/acto2.avi --fixed-fps 30 \
##       --script res://tests/record_paso.gd
##
## Recorre el paso desde la aparición hasta el campamento, escucha, cruza el
## desfiladero para disparar la emboscada, combate con la honda y cierra la
## conversación de la posada. Termina el acto y sale. No forma parte del juego.

const SCENE: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const CAMP: Vector3 = Vector3(-4.0, 0.0, 18.0)
const TRIGGER: Vector3 = Vector3(0.0, 0.0, 6.0)
const ARRIVE_DISTANCE: float = 0.8
const TURN_RATE: float = 2.4
const ATTACK_INTERVAL: float = 1.5
const COMBAT_LIMIT: float = 55.0
const MAX_GAME_SECONDS: float = 180.0

var _world: Node = null
var _player: CharacterBody3D = null
var _head: Node3D = null
var _clock: float = 0.0
var _step: int = 0
var _step_time: float = 0.0
var _attack_cooldown: float = 0.0
var _combat_time: float = 0.0
var _frames: int = 0


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	change_scene_to_file(SCENE)
	await process_frame
	await process_frame
	_world = current_scene
	_player = _world.get_node("PlayerFPS") as CharacterBody3D
	_head = _player.get_node("Head") as Node3D
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Solo para el vídeo: el jugador aguanta el combate sin morir, para que la
	# grabación no acabe en la pantalla de derrota.
	var pc: CharacterState = _world.get_node_or_null("PlayerFPS/CharacterState") as CharacterState
	if pc != null:
		pc.health = pc.max_health


func _process(delta: float) -> bool:
	_frames += 1
	if _frames < 4:
		return false
	_clock += delta
	_step_time += delta
	_keep_health()
	_close_dialogue()
	if _step >= 8 or _clock > MAX_GAME_SECONDS:
		return _finish()
	match _step:
		0:
			_walk(CAMP, delta)
		1:
			_turn_towards(CAMP + Vector3(0.0, 1.0, 0.0), delta)
			if _step_time > 0.8:
				_interact()
				print("PASO interactúa con el campamento")
				_advance()
		2:
			if _step_time > 3.0:
				_advance()
		3:
			_walk(TRIGGER, delta)
		4:
			# La emboscada ya empezó: se combate hasta que se resuelva.
			if _combat_time == 0.0:
				print("PASO emboscada activa=", _world.call("is_ambush_active"))
			_combat(delta)
		5:
			_turn_towards(_player.global_position + Vector3(0.0, 0.0, -8.0), delta)
			if _step_time > 3.0:
				_advance()
		6:
			if _world.call("is_ambush_active") == false:
				_advance()
		7:
			_turn_towards(_player.global_position + Vector3(6.0, 1.2, 4.0), delta)
			if _step_time > 3.0:
				_advance()
	return false


## Solo para el vídeo: la salud vuelve al máximo para no morir.
func _keep_health() -> void:
	var pc: CharacterState = _world.get_node_or_null("PlayerFPS/CharacterState") as CharacterState
	if pc != null and pc.health < pc.max_health:
		pc.health = pc.max_health


func _combat(delta: float) -> void:
	_combat_time += delta
	_attack_cooldown -= delta
	var enemy: Node3D = _nearest_enemy()
	if enemy != null:
		_turn_towards(enemy.global_position + Vector3(0.0, 1.1, 0.0), delta)
		if _attack_cooldown <= 0.0:
			_attack()
			_attack_cooldown = ATTACK_INTERVAL
	if _world.call("is_ambush_active") == false or _combat_time > COMBAT_LIMIT:
		_clear_remaining()
		_advance()


## Si el combate se alarga, se remata a los que quedan para no alargar el vídeo.
func _clear_remaining() -> void:
	for index: int in range(1, 5):
		var enemy: Node = _world.get_node_or_null("Ambusher%d" % index)
		if enemy != null and enemy.call("is_alive"):
			enemy.call("take_hit", 999.0)


func _alive_count() -> int:
	var count: int = 0
	for index: int in range(1, 5):
		var enemy: Node = _world.get_node_or_null("Ambusher%d" % index)
		if enemy != null and enemy.call("is_alive"):
			count += 1
	return count


func _nearest_enemy() -> Node3D:
	var best: Node3D = null
	var best_distance: float = 1e9
	for index: int in range(1, 5):
		var enemy: Node3D = _world.get_node_or_null("Ambusher%d" % index) as Node3D
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
	var pc: CharacterState = _world.get_node_or_null("PlayerFPS/CharacterState") as CharacterState
	var health: float = -1.0
	if pc != null:
		health = pc.health
	print("PASO tiempo=%.1f s vivos=%d salud=%.0f" % [_clock, _alive_count(), health])
	print("RECORD_PASO_OK")
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


## Las conversaciones eligen la última opción para que el guion siga.
func _close_dialogue() -> void:
	var hud: Node = _world.get_node_or_null("UILayer/HUD")
	if hud == null:
		return
	var panel: DialoguePanel = hud.get_node_or_null("DialoguePanel") as DialoguePanel
	if panel == null or not panel.is_open():
		return
	var count: int = panel.get_choice_count()
	if count > 0:
		panel.choice_selected.emit(count - 1)
	else:
		panel.advanced.emit()
