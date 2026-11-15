extends RefCounted
## Comprueba el bloqueo suave de controles, el encuadre de diálogo y el
## retorno de la cámara a la orientación previa.

const PLAYER_PATH: String = "res://core/player/player_fps.tscn"


func _spawn() -> Array[Node]:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return []
	var packed: PackedScene = load(PLAYER_PATH) as PackedScene
	if packed == null:
		return []
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	var target: Node3D = Node3D.new()
	target.name = "Interlocutor"
	target.position = Vector3(0.0, 0.0, -3.0)
	tree.root.add_child(player)
	tree.root.add_child(target)
	var nodes: Array[Node] = [player, target]
	return nodes


func test_dialogue_camera_focus_and_return() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var player: PlayerFPS = nodes[0] as PlayerFPS
	var target: Node3D = nodes[1] as Node3D
	player.rotation.y = deg_to_rad(35.0)
	var before_yaw: float = player.rotation.y
	player.begin_dialogue(target)
	var ok: bool = player.is_controls_locked()
	ok = ok and player.is_dialogue_focused()
	# La transición no termina en el mismo tick: la cámara va hacia el objetivo.
	player.call("_update_focus", 0.45)
	ok = ok and absf(wrapf(player.rotation.y, -PI, PI)) < deg_to_rad(8.0)
	# El interlocutor está a la altura de los ojos: la cámara no debe mirar al
	# cielo por confundir la altura de Head con la posición local de la cámara.
	var pitch: float = player.get("_pitch")
	ok = ok and absf(pitch) < deg_to_rad(10.0)
	player.end_dialogue()
	ok = ok and player.is_controls_locked()
	player.call("_update_focus", 0.6)
	ok = ok and not player.is_controls_locked()
	ok = ok and absf(wrapf(player.rotation.y - before_yaw, -PI, PI)) < deg_to_rad(3.0)
	player.free()
	target.free()
	return ok


func test_journal_lock_and_footsteps() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var player: PlayerFPS = nodes[0] as PlayerFPS
	player.set_controls_locked(true)
	var ok: bool = player.is_controls_locked()
	# Un jugador detenido no produce pasos ni balanceo.
	ok = ok and not player.advance_footstep(3.5, true, 0.5)
	player.set_controls_locked(false)
	ok = ok and not player.is_controls_locked()
	player.free()
	(nodes[1] as Node3D).free()
	return ok


func test_running_opens_fov() -> bool:
	var nodes: Array[Node] = _spawn()
	if nodes.is_empty():
		return false
	var player: PlayerFPS = nodes[0] as PlayerFPS
	var camera: Camera3D = player.get_node("Head/Camera3D") as Camera3D
	var initial: float = camera.fov
	for _i: int in range(30):
		player.call("_update_fov", 6.5, 1.0 / 60.0)
	var running_fov: float = camera.fov
	player.set_controls_locked(true)
	for _i: int in range(30):
		player.call("_update_fov", 0.0, 1.0 / 60.0)
	var dialogue_fov: float = camera.fov
	var ok: bool = running_fov > initial + 1.0 and dialogue_fov < running_fov
	player.free()
	(nodes[1] as Node3D).free()
	return ok
