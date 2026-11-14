extends SceneTree
## Capturas de cerca de la multitud del Cusco.
##
## Carga la ciudad sin HUD, coloca al jugador frente a tres figuras y guarda
## cuatro vistas en `user://capturas_crowd_close/`: dos vecinos, un agricultor
## y la fila oeste desde dentro de la plaza. Sirve para juzgar los modelos de
## la multitud contra el mismo encuadre, no para probar lógica.

const OUT: String = "user://capturas_crowd_close"
const SCENE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var ciudad: Node3D = (load(SCENE) as PackedScene).instantiate() as Node3D
	root.add_child(ciudad)
	await process_frame
	var player: CharacterBody3D = ciudad.get_node("PlayerFPS") as CharacterBody3D
	player.process_mode = Node.PROCESS_MODE_DISABLED
	(ciudad.get_node("UILayer") as CanvasLayer).visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Cada figura mira al centro de la plaza: la cámara se pone entre ella y el
	# centro para verle la cara.
	await _shot(player, "01_vecino", Vector3(-14.5, 0.15, 7.2), Vector3(-18.0, 1.15, 10.0))
	await _shot(player, "02_vecina", Vector3(14.5, 0.15, 7.2), Vector3(18.0, 1.15, 10.0))
	await _shot(player, "03_agricultor", Vector3(-9.0, 0.15, 12.0), Vector3(-9.0, 1.15, 16.0))
	await _shot(player, "04_fila", Vector3(-8.0, 0.15, 5.0), Vector3(-18.0, 1.2, 5.0))
	print("CROWD_CLOSE_OK")
	quit(0)


func _shot(player: CharacterBody3D, name: String, from: Vector3, target: Vector3) -> void:
	player.global_position = from
	var eye: Vector3 = from + Vector3(0.0, 1.6, 0.0)
	var to: Vector3 = target - eye
	player.rotation.y = atan2(-to.x, -to.z)
	var head: Node3D = player.get_node("Head") as Node3D
	head.rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	for _i: int in range(10):
		await process_frame
	root.get_texture().get_image().save_png(OUT + "/" + name + ".png")
