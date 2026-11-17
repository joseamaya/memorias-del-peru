extends Node
## Herramienta de desarrollo: captura el prototipo Quaternius en sus escenas.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_quaternius.tscn \
##       -- --visual-set=quaternius
##
## Guarda `user://quaternius_llacta.png`, `..._sisa.png`, `..._curaca.png`,
## `..._mensajero.png` y `..._chanca.png`. No es una prueba: es la referencia
## visual del prototipo.

const LLACTA: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const SETTLE_FRAMES: int = 90


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var prefix: String = "quaternius" if CharacterCatalog.enabled() else "legacy"
	var llacta: Node = (load(LLACTA) as PackedScene).instantiate()
	add_child(llacta)
	await _frames(SETTLE_FRAMES)
	_hide_ui(llacta)
	llacta.call("_spawn_messenger")
	await _frames(8)
	var camera: Camera3D = Camera3D.new()
	camera.name = "CaptureCamera"
	camera.fov = 55.0
	add_child(camera)
	camera.current = true
	await _shot(camera, Vector3(7.6, 1.5, 5.2), Vector3(7.0, 1.15, 8.0), prefix + "_sisa")
	await _shot(camera, Vector3(7.0, 1.66, 6.4), Vector3(7.0, 1.62, 8.0), prefix + "_rostro")
	await _shot(camera, Vector3(-6.4, 1.5, -6.6), Vector3(-7.0, 1.15, -3.0), prefix + "_curaca")
	await _shot(camera, Vector3(-2.4, 1.5, 0.2), Vector3(-3.0, 1.15, 3.0), prefix + "_mensajero")
	await _shot(camera, Vector3(1.0, 1.65, 14.0), Vector3(0.0, 1.0, 4.0), prefix + "_llacta")
	llacta.queue_free()
	await _frames(3)

	var paso: Node = (load(PASO) as PackedScene).instantiate()
	add_child(paso)
	await _frames(45)
	_hide_ui(paso)
	paso.set("_sneak", false)
	var player: Node3D = paso.get_node_or_null("PlayerFPS") as Node3D
	if player != null:
		player.global_position = Vector3(0.0, 0.05, 1.0)
		player.rotation.y = 0.0
	paso.call("_start_ambush")
	await _frames(90)
	var enemy: Node3D = paso.get_node_or_null("Ambusher1") as Node3D
	var at: Vector3 = Vector3(0.0, 1.6, 4.8)
	var target: Vector3 = Vector3(0.0, 1.0, 0.0)
	if enemy != null:
		at = enemy.global_position + Vector3(0.0, 1.55, 4.0)
		target = enemy.global_position + Vector3.UP * 1.0
	await _shot(camera, at, target, prefix + "_chanca")
	paso.queue_free()
	await _frames(3)
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		get_tree().quit()


func _shot(camera: Camera3D, at: Vector3, target: Vector3, slug: String) -> void:
	camera.global_position = at
	camera.look_at(target, Vector3.UP)
	await _frames(5)
	var image: Image = get_viewport().get_texture().get_image()
	var file: String = "user://%s.png" % slug
	image.save_png(file)
	print("CAPTURA ", slug, " -> ", file)


func _frames(count: int) -> void:
	for _i: int in range(count):
		await get_tree().process_frame


func _hide_ui(root: Node) -> void:
	for node: Node in root.find_children("*", "CanvasLayer", true, false):
		(node as CanvasLayer).visible = false
