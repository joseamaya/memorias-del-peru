extends Node
## Herramienta de desarrollo: captura la vida cotidiana del Cusco.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_ciudad_life.tscn
##
## Deja correr la multitud unos segundos y guarda dos vistas en `user://`.

const SCENE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var ciudad: Node3D = (load(SCENE) as PackedScene).instantiate() as Node3D
	add_child(ciudad)
	await get_tree().process_frame
	var player: PlayerFPS = ciudad.get_node("PlayerFPS") as PlayerFPS
	(ciudad.get_node("UILayer") as CanvasLayer).visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = Vector3(0.0, 0.05, 24.0)
	player.rotation.y = 0.0
	var head: Node3D = player.get_node("Head") as Node3D
	head.rotation.x = deg_to_rad(-4.0)
	# Cinco segundos de rutina.
	for _i: int in range(300):
		await get_tree().process_frame
	_save("ciudad_life_plaza")

	player.global_position = Vector3(0.0, 0.05, 2.0)
	player.rotation.y = deg_to_rad(-10.0)
	head.rotation.x = deg_to_rad(-2.0)
	for _i: int in range(120):
		await get_tree().process_frame
	_save("ciudad_life_market")
	print("CAPTURA_CIUDAD_LIFE_OK")
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		get_tree().quit()


func _save(file_name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("user://" + file_name + ".png")
	print("CAPTURA ", file_name)
