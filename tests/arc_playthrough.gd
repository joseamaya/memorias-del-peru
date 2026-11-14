extends SceneTree
## Partida continua del arco, sin pantalla: acto I → paso → Cusco → título.
##
## Cierra el criterio de Fase 7 que faltaba: una sola pasada automatizada por
## los tres actos, con las transiciones reales de escena y las banderas de
## `CampaignState` sobreviviendo al cambio. No sustituye la partida del autor:
## comprueba que el arco no se bloquea y que las decisiones llegan al acto III.
##
##   godot --headless --path . --script res://tests/arc_playthrough.gd
##
## Como `demo_playthrough` y `paso_smoke`, no usa tipos de la campaña: con
## `--script`, los autoloads aún no existen cuando se compila este archivo.

const ACT_ONE: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const ACT_TWO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const ACT_THREE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"
const TITLE: String = "res://core/ui/title_screen.tscn"
## MessengerEvent.Phase.DONE (el tipo no está disponible al compilar).
const EVENT_DONE: int = 5
const MAX_EVENT_STEPS: int = 500
const EVENT_STEP_SECONDS: float = 2.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var ok: bool = await _act_one()
	if ok:
		ok = await _act_two()
	if ok:
		ok = await _act_three()
	if ok:
		ok = _check_title()
	await _stop_audio()
	if ok:
		print("ARCO_OK")
	else:
		printerr("ARCO_FALLO")
	quit(0 if ok else 1)


## Acto I: tres encargos, mensajero y salida al paso.
func _act_one() -> bool:
	var world: Node = await _open(ACT_ONE)
	if world == null:
		return false
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	if player == null:
		return false
	var ok: bool = true
	for task_name: String in ["TaskAgua", "TaskMaiz", "TaskTelar"]:
		var task: Node = world.get_node_or_null(task_name)
		if task == null:
			ok = false
			break
		task.call("interact", player)
	var event: Node = world.get_node_or_null("EventController")
	if event == null:
		return false
	# El mensajero espera en la plaza; se avanza el reloj del evento sin esperar.
	player.global_position = Vector3(0.0, 0.05, 2.0)
	var steps: int = 0
	while event.get("phase") != EVENT_DONE and steps < MAX_EVENT_STEPS:
		event.call("step", EVENT_STEP_SECONDS)
		steps += 1
	ok = ok and event.get("phase") == EVENT_DONE
	ok = ok and event.get("completed") == true
	world.call("advance_end_card", 999.0)
	ok = ok and world.call("is_end_card_shown") == true
	if not ok:
		print("ACTO_I_FALLO")
		return false
	print("ACTO_I_OK")
	_press_restart(world)
	await _settle()
	return current_scene != null and String(current_scene.scene_file_path) == ACT_TWO


## Acto II: descanso, combate, herido y maíz. Deja las tres banderas que
## reclutan a los tres aliados del acto III.
func _act_two() -> bool:
	var paso: Node = current_scene
	if paso == null:
		return false
	var player: Node3D = paso.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = paso.get_node_or_null("UILayer/HUD")
	var camp: Node = paso.get_node_or_null("CampPoint")
	if player == null or hud == null or camp == null:
		return false
	var ok: bool = true
	# Descanso en el campamento.
	camp.call("interact", player)
	ok = ok and hud.call("is_dialogue_open") == true
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	ok = ok and _flag(&"descanso")
	# Emboscada: se resuelve por combate para poder decidir sobre el herido.
	paso.call("_start_ambush")
	for index: int in range(1, 5):
		var enemy: Node = paso.get_node_or_null("Ambusher%d" % index)
		if enemy != null:
			enemy.call("take_hit", 200.0)
	paso.call("_physics_process", 0.1)
	ok = ok and hud.call("is_dialogue_open") == true
	# Salvar al herido.
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	ok = ok and _flag(&"herido_salvado")
	# Guardar el maíz.
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	ok = ok and _flag(&"maiz_guardado")
	# Perdonar al explorador chanca herido.
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	ok = ok and _flag(&"scout_spared")
	ok = ok and paso.call("is_completed") == true
	if not ok:
		print("ACTO_II_FALLO")
		return false
	print("ACTO_II_OK")
	_press_restart(paso)
	await _settle()
	return current_scene != null and String(current_scene.scene_file_path) == ACT_THREE


## Acto III: tres reclutas, Cusi, defensa y salida al título.
func _act_three() -> bool:
	var ciudad: Node = current_scene
	if ciudad == null:
		return false
	var player: Node3D = ciudad.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = ciudad.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		return false
	var ok: bool = true
	for index: int in range(3):
		var point: Node = ciudad.get_node_or_null("Recruit%d" % index)
		if point == null:
			ok = false
			break
		point.call("interact", player)
		_choose(hud, 0)
		ciudad.call("_on_dialogue_advanced")
	ok = ok and ciudad.call("ally_count") == 3
	var cusi: Node = ciudad.get_node_or_null("CusiPoint")
	if cusi == null:
		return false
	cusi.call("interact", player)
	_choose(hud, 0)
	ciudad.call("_on_dialogue_advanced")
	ok = ok and ciudad.call("is_ambush_active") == true
	ok = ok and ciudad.call("alive_enemies") == 1
	for index: int in range(1, 5):
		var enemy: Node = ciudad.get_node_or_null("Defender%d" % index)
		if enemy != null:
			enemy.call("take_hit", 200.0)
	ciudad.call("_physics_process", 0.1)
	ok = ok and ciudad.call("is_completed") == true
	ok = ok and hud.call("is_end_card_visible") == true
	if not ok:
		print("ACTO_III_FALLO")
		return false
	print("ACTO_III_OK")
	_press_restart(ciudad)
	await _settle()
	return true


## El título es el final del arco y las banderas siguen vivas.
func _check_title() -> bool:
	if current_scene == null or String(current_scene.scene_file_path) != TITLE:
		print("TITULO_FALLO")
		return false
	var ok: bool = _flag(&"descanso") and _flag(&"herido_salvado") and _flag(&"maiz_guardado")
	ok = ok and _flag(&"scout_spared")
	ok = ok and _flag(&"aliado_0") and _flag(&"aliado_2")
	print("TITULO_OK")
	return ok


## Carga una escena como escena actual y espera a que esté lista.
func _open(path: String) -> Node:
	var error: int = change_scene_to_file(path)
	if error != OK:
		return null
	await _settle()
	return current_scene


func _settle() -> void:
	# El cambio de escena se aplica al final del fotograma; dos frames cubren
	# también el `_ready` de la escena nueva.
	await process_frame
	await process_frame


func _choose(hud: Node, index: int) -> void:
	var panel: Node = hud.get_node_or_null("DialoguePanel")
	if panel != null:
		panel.emit_signal("choice_selected", index)


func _press_restart(scene: Node) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_R
	scene.call("_unhandled_input", event)


## Detiene la música y los efectos antes de salir; el pututu del acto I puede
## seguir sonando cuando la escena ya se liberó.
func _stop_audio() -> void:
	var audio: Node = root.get_node_or_null("AudioManager")
	if audio != null:
		audio.call("stop_all")
	await create_timer(0.5).timeout
	await process_frame


func _flag(key: StringName) -> bool:
	var state: Node = root.get_node_or_null("CampaignState")
	if state == null:
		return false
	return state.call("has_flag", key) == true
