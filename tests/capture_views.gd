extends SceneTree
## Herramienta de desarrollo: capturas fijas del mundo para comparar materiales.
##
## Uso: godot --path . --resolution 1280x720 --script res://tests/capture_views.gd
## Guarda cinco PNG en `user://capturas/`. No forma parte del juego.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const OUTPUT_DIR: String = "user://capturas"
const SETTLE_FRAMES: int = 10
## MundoBase.IntroMode.NEVER (sin usar el tipo, ver la cabecera del mundo).
const INTRO_NEVER: int = 2


func _initialize() -> void:
	_capture_all.call_deferred()


func _capture_all() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	var world: Node3D = packed.instantiate() as Node3D
	world.set("intro_mode", INTRO_NEVER)
	root.add_child(world)
	await process_frame
	var event: Node = world.get_node("EventController")
	event.set_process(false)
	var player: CharacterBody3D = world.get_node("PlayerFPS") as CharacterBody3D
	player.process_mode = Node.PROCESS_MODE_DISABLED
	var ui: CanvasLayer = world.get_node("UILayer") as CanvasLayer
	ui.visible = false
	var hands: Node3D = player.get_node_or_null("Head/Camera3D/FirstPersonHands") as Node3D
	if hands != null:
		hands.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	await _shot(player, "01_aparicion", Vector3(0.0, 0.05, 22.0), Vector3(0.0, 1.6, -10.0))
	await _shot(player, "02_suelo", Vector3(0.0, 0.05, 10.0), Vector3(0.4, 0.0, 8.0))
	await _shot(player, "03_muro", Vector3(-19.0, 0.1, 4.5), Vector3(-19.0, 1.4, 8.0))
	await _shot(player, "04_casa", Vector3(-13.0, 0.1, 6.0), Vector3(-19.0, 2.0, 10.0))
	await _shot(player, "05_horizonte", Vector3(52.0, 2.5, 0.0), Vector3(0.0, 6.0, -60.0))
	print("CAPTURAS_OK")
	# Cierre ordenado para no ensuciar la salida con fugas de audio.
	var manager: Node = root.get_node_or_null("GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		quit()


func _shot(player: CharacterBody3D, file_name: String, from: Vector3, target: Vector3) -> void:
	player.global_position = from
	var eye: Vector3 = from + Vector3(0.0, 1.6, 0.0)
	var to: Vector3 = target - eye
	player.rotation.y = atan2(-to.x, -to.z)
	var head: Node3D = player.get_node("Head") as Node3D
	head.rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	for _i: int in range(SETTLE_FRAMES):
		await process_frame
	var image: Image = root.get_texture().get_image()
	image.save_png(OUTPUT_DIR + "/" + file_name + ".png")
	print("CAPTURA ", file_name)
