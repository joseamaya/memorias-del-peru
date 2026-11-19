extends SceneTree
## Comprueba la duda del acto I con el rayo y la tecla E reales.
##
## Cubre el fallo que dejaba el objetivo «Escucha la discusión» sin punto: la
## duda no debe poder abrirse antes de su paso ni consumirse al pasar por ella.
##
##   godot --headless --path . --script res://tests/llacta_doubt_check.gd

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var state: Node = root.get_node_or_null("CampaignState")
	if state != null:
		state.call("clear")
		state.call("set_flag", &"intro_vista", 1)
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	var world: Node = packed.instantiate()
	root.add_child(world)
	await _frames(10)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: Node = world.get_node_or_null("UILayer/HUD")
	var director: Node = world.get_node_or_null("ActOneDirector")
	var panel: DialoguePanel = hud.get_node_or_null("DialoguePanel") as DialoguePanel
	var doubt: CampPoint = world.get_node_or_null("DudaPoint") as CampPoint
	if player == null or panel == null or director == null or doubt == null:
		_fail("piezas")
		return

	# 1. En la mañana la duda no se puede abrir: sin foco y sin diálogo.
	if doubt.is_available():
		_fail("duda disponible en la mañana")
		return
	_aim_at(player, doubt.global_position)
	await _frames(4)
	player.update_interaction()
	await physics_frame
	if _focus_name(player) != "ninguno":
		_fail("la duda absorbe el rayo en la mañana")
		return
	_press_e(player)
	await _frames(2)
	if panel.is_open() or world.get("_duda_started"):
		_fail("la duda se abrió antes de su paso")
		return

	# 2. Completar los tres encargos lleva el flujo al paso de la duda.
	for task_name: String in ["TaskAgua", "TaskMaiz", "TaskTelar"]:
		var task: TaskPoint = world.get_node_or_null(task_name) as TaskPoint
		if task != null:
			task.interact(player)
	await _frames(3)
	if _marker(director) != &"Doubt":
		_fail("el flujo no llegó a la duda")
		return
	if not doubt.is_available():
		_fail("la duda sigue apagada en su paso")
		return

	# 3. El rayo la enfoca y E abre la discusión.
	_aim_at(player, doubt.global_position)
	await _frames(4)
	player.update_interaction()
	await physics_frame
	if _focus_name(player) != "DudaPoint":
		_fail("el rayo no enfoca la duda")
		return
	_press_e(player)
	await _frames(2)
	if not panel.is_open():
		_fail("E no abre la discusión")
		return
	if panel.get_choice_count() != 3:
		_fail("la duda no ofrece sus tres opciones")
		return

	# 4. Elegir «Callar y escuchar» y avanzar la respuesta con E.
	panel.choice_selected.emit(2)
	await _frames(2)
	var before: String = panel.get_text()
	_press_e_panel(panel)
	await _frames(2)
	if panel.is_open() and panel.get_text() == before:
		_fail("E no avanza la respuesta de la duda")
		return

	# 5. Al cerrar, el paso pasa al mensajero y su punto existe.
	var guard: int = 0
	while panel.is_open() and guard < 8:
		_press_e_panel(panel)
		await _frames(2)
		guard += 1
	if panel.is_open():
		_fail("la duda no cierra")
		return
	if _marker(director) != &"Messenger":
		_fail("el flujo no pasó al mensajero")
		return
	var messenger: CampPoint = world.get_node_or_null("MessengerPoint") as CampPoint
	if messenger == null or not messenger.is_available():
		_fail("el mensajero no quedó disponible")
		return

	print("DUDA_CHECK_OK")
	if state != null:
		state.call("clear")
	world.queue_free()
	await _frames(5)
	quit(0)


func _aim_at(player: PlayerFPS, target: Vector3) -> void:
	player.global_position = Vector3(target.x, 0.05, target.z + 2.9)
	var to: Vector3 = target - player.global_position
	player.rotation.y = atan2(-to.x, -to.z)
	var pitch: float = atan2(target.y - 1.6, Vector2(to.x, to.z).length())
	player.set("_pitch", pitch)
	player.head.rotation.x = pitch


func _press_e(player: PlayerFPS) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	player._unhandled_input(event)


func _press_e_panel(_panel: DialoguePanel) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	Input.parse_input_event(event)
	var release: InputEventAction = InputEventAction.new()
	release.action = &"interact"
	release.pressed = false
	Input.parse_input_event(release)


func _marker(director: Node) -> StringName:
	var value: Variant = director.call("current_marker")
	if value is StringName:
		return value
	return &""


func _focus_name(player: PlayerFPS) -> String:
	var focused: Variant = player.get("_focused_interactable")
	if focused is Node:
		var node: Node = focused
		return String(node.name)
	return "ninguno"


func _frames(count: int) -> void:
	for _index: int in range(count):
		await physics_frame


func _fail(reason: String) -> void:
	print("DUDA_CHECK_FAIL ", reason)
	var state: Node = root.get_node_or_null("CampaignState")
	if state != null:
		state.call("clear")
	quit(1)
