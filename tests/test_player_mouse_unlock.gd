extends RefCounted
## Comprueba que al liberar los controles se vuelve a pedir la captura del
## ratón. Antes, un diálogo pausado o el diario dejaban el puntero visible y el
## jugador no podía mirar hasta hacer clic.
##
## En headless `Input.mouse_mode` siempre se lee visible, así que la prueba
## intercepta la aplicación del modo en una subclase de [PlayerFPS].


class MouseSpy:
	extends PlayerFPS
	var applied: Array[Input.MouseMode] = []

	func _init() -> void:
		# Los @onready del jugador real buscan estos nodos al entrar al árbol.
		var head_node: Node3D = Node3D.new()
		head_node.name = "Head"
		add_child(head_node)
		var camera_node: Camera3D = Camera3D.new()
		camera_node.name = "Camera3D"
		head_node.add_child(camera_node)
		var ray: RayCast3D = RayCast3D.new()
		ray.name = "InteractionRay"
		camera_node.add_child(ray)

	func _ready() -> void:
		# El jugador real ata aquí su capturador; el resto de la escena no hace
		# falta para probar el puntero.
		super._ready()

	func _apply_mouse_mode(mode: Input.MouseMode) -> void:
		applied.append(mode)


func test_unlock_requests_capture() -> bool:
	var player: MouseSpy = _spawn()
	if player == null:
		return false
	player.set_controls_locked(true)
	var before: int = player.applied.size()
	player.set_controls_locked(false)
	var ok: bool = player.applied.size() > before
	ok = ok and player.applied[player.applied.size() - 1] == Input.MOUSE_MODE_CAPTURED
	ok = ok and not player.is_controls_locked()
	player.free()
	return ok


func test_end_dialogue_requests_capture() -> bool:
	var player: MouseSpy = _spawn()
	if player == null:
		return false
	player.set_controls_locked(true)
	var before: int = player.applied.size()
	# Sin encuadre activo el diálogo libera los controles de inmediato.
	player.end_dialogue()
	var ok: bool = player.applied.size() > before
	ok = ok and player.applied[player.applied.size() - 1] == Input.MOUSE_MODE_CAPTURED
	ok = ok and not player.is_controls_locked()
	player.free()
	return ok


func _spawn() -> MouseSpy:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var player: MouseSpy = MouseSpy.new()
	tree.root.add_child(player)
	return player
