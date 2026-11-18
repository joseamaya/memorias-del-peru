extends SceneTree
## Partida continua del arco completo, sin pantalla:
## llacta → paso → Cusco → llacta de posguerra → llacta en obra → título.
##
##   godot --headless --path . --script res://tests/arc_playthrough.gd
##
## Comprueba que las cinco escenas se encadenan, que las decisiones sobreviven
## y que ningún acto se bloquea.

const ACT_ONE: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const ACT_TWO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const ACT_THREE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"
const ACT_FOUR: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"
const ACT_FIVE: String = "res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn"
const TITLE: String = "res://core/ui/title_screen.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var ok: bool = await _act_one()
	if ok:
		ok = await _act_two()
	if ok:
		ok = await _act_three()
	if ok:
		ok = await _act_four()
	if ok:
		ok = await _act_five()
	if ok:
		ok = _check_title()
	await _stop_audio()
	if ok:
		print("ARCO_OK")
	else:
		printerr("ARCO_FALLO")
	quit(0 if ok else 1)


## Acto I: tres encargos, asamblea y salida al paso.
func _act_one() -> bool:
	var world: Node = await _open(ACT_ONE)
	if world == null:
		return false
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		return false
	var ok: bool = true
	for task_name: String in ["TaskAgua", "TaskPirca", "TaskTelar"]:
		var task: Node = world.get_node_or_null(task_name)
		if task == null:
			ok = false
			break
		task.call("interact", player)
	var doubt: Node = world.get_node_or_null("DudaPoint")
	if doubt == null:
		print("ACTO_I_SIN_DUDA")
		return false
	doubt.call("interact", player)
	# Apoyar al curaca conserva la reputación ante el Cusco; reclutar al
	# curaca vecino en el acto III depende de ella.
	_choose(hud, 1)
	world.call("_on_dialogue_advanced")
	var messenger: Node = world.get_node_or_null("MessengerPoint")
	if messenger == null:
		print("ACTO_I_SIN_MENSAJERO")
		return false
	messenger.call("interact", player)
	_choose_last(hud)
	world.call("_on_dialogue_advanced")
	ok = ok and _flag(&"noticia_chanca")
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.1)
	ok = ok and hud.call("is_dialogue_open") == true
	_choose(hud, 1)
	world.call("_on_dialogue_advanced")
	ok = ok and world.call("get", "_assembly_done") == true
	ok = ok and _flag(&"ofrecio")
	if not ok:
		print("ACTO_I_FALLO")
		return false
	print("ACTO_I_OK")
	_press_restart(world)
	await _settle()
	return current_scene != null and String(current_scene.scene_file_path) == ACT_TWO


## Acto II: campamento, combate, herido, maíz y perdón.
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
	camp.call("interact", player)
	ok = ok and hud.call("is_dialogue_open") == true
	_choose(hud, 2)
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	ok = ok and _flag(&"descanso")
	paso.call("_on_sneak_requested")
	ok = ok and _flag(&"mensaje_chanca")
	paso.call("_start_ambush")
	for index: int in range(1, 5):
		var enemy: Node = paso.get_node_or_null("Ambusher%d" % index)
		if enemy != null:
			enemy.call("take_hit", 200.0)
	paso.call("_physics_process", 0.1)
	ok = ok and hud.call("is_dialogue_open") == true
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	ok = ok and _flag(&"herido_salvado")
	_choose(hud, 0)
	paso.call("_on_dialogue_advanced")
	ok = ok and _flag(&"maiz_guardado")
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


## Acto III: tres reclutas, Cusi y defensa.
func _act_three() -> bool:
	var ciudad: Node = current_scene
	if ciudad == null:
		return false
	var player: Node3D = ciudad.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = ciudad.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		return false
	var ok: bool = true
	var arrival: Node = ciudad.get_node_or_null("ArrivalPoint")
	if arrival == null:
		print("ACTO_III_SIN_LLEGADA")
		return false
	arrival.call("interact", player)
	_choose(hud, 0)
	ciudad.call("_on_dialogue_advanced")
	ok = ok and _flag(&"mensaje_entregado")
	for index: int in range(3):
		var point: Node = ciudad.get_node_or_null("Recruit%d" % index)
		if point == null:
			ok = false
			break
		point.call("interact", player)
		_choose(hud, 0)
		ciudad.call("_on_dialogue_advanced")
	ok = ok and ciudad.call("ally_count") == 3
	var trap: Node = ciudad.get_node_or_null("TrapPoint")
	if trap == null:
		return false
	trap.call("interact", player)
	_choose(hud, 0)
	ciudad.call("_on_dialogue_advanced")
	ok = ok and _flag(&"trampa_resuelta")
	var cusi: Node = ciudad.get_node_or_null("CusiPoint")
	if cusi == null:
		return false
	cusi.call("interact", player)
	_choose(hud, 0)
	ciudad.call("_on_dialogue_advanced")
	ok = ok and ciudad.call("is_ambush_active") == true
	for _wave: int in range(3):
		for child: Node in ciudad.get_children():
			if child is AmbushEnemy and (child as AmbushEnemy).is_alive():
				child.call("take_hit", 200.0)
		ciudad.call("_physics_process", 0.1)
	ok = ok and ciudad.call("is_completed") == true
	ok = ok and hud.call("is_end_card_visible") == true
	if not ok:
		print("ACTO_III_FALLO")
		return false
	print("ACTO_III_OK")
	_press_restart(ciudad)
	await _settle()
	return current_scene != null and String(current_scene.scene_file_path) == ACT_FOUR


## Acto IV: la asamblea de posguerra.
func _act_four() -> bool:
	var world: Node = current_scene
	if world == null:
		return false
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		return false
	for index: int in range(3):
		var account: Node = world.get_node_or_null("Account%d" % index)
		if account != null:
			account.call("interact", player)
	player.global_position = Vector3(0.0, 0.05, 2.0)
	world.call("_process", 0.1)
	var ok: bool = hud.call("is_dialogue_open") == true
	_choose(hud, 0)
	world.call("_on_dialogue_advanced")
	ok = ok and world.call("get", "_act_four_done") == true
	ok = ok and _flag(&"hablo_en_asamblea")
	if not ok:
		print("ACTO_IV_FALLO")
		return false
	print("ACTO_IV_OK")
	_press_restart(world)
	await _settle()
	return current_scene != null and String(current_scene.scene_file_path) == ACT_FIVE


## Acto V: reconstrucción y nombre nuevo.
func _act_five() -> bool:
	var world: Node = current_scene
	if world == null:
		return false
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	if player == null or hud == null:
		return false
	var ok: bool = true
	for task_name: String in ["RebuildPirca", "RebuildTerraza", "RebuildAcequia", "RebuildTelar", "RebuildCasa"]:
		var task: Node = world.get_node_or_null(task_name)
		if task == null:
			ok = false
			break
		task.call("interact", player)
	ok = ok and world.call("get", "_act_five_done") == true
	ok = ok and hud.call("is_end_card_visible") == true
	ok = ok and _flag(&"casa_reconstruida")
	if not ok:
		print("ACTO_V_FALLO")
		return false
	print("ACTO_V_OK")
	_press_restart(world)
	await _settle()
	return current_scene != null and String(current_scene.scene_file_path) == TITLE


## El título es el final del arco y las banderas siguen vivas.
func _check_title() -> bool:
	if current_scene == null or String(current_scene.scene_file_path) != TITLE:
		print("TITULO_FALLO")
		return false
	var ok: bool = _flag(&"descanso") and _flag(&"herido_salvado") and _flag(&"maiz_guardado")
	ok = ok and _flag(&"scout_spared") and _flag(&"casa_reconstruida")
	print("TITULO_OK")
	return ok


func _open(path: String) -> Node:
	var error: int = change_scene_to_file(path)
	if error != OK:
		return null
	await _settle()
	return current_scene


func _settle() -> void:
	await process_frame
	await process_frame


func _choose(hud: Node, index: int) -> void:
	var panel: Node = hud.get_node_or_null("DialoguePanel")
	if panel != null:
		panel.emit_signal("choice_selected", index)


func _choose_last(hud: Node) -> void:
	var panel: DialoguePanel = hud.get_node_or_null("DialoguePanel") as DialoguePanel
	if panel != null:
		panel.emit_signal("choice_selected", panel.get_choice_count() - 1)


func _press_restart(scene: Node) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_R
	scene.call("_unhandled_input", event)


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
