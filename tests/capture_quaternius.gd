extends Node
## Herramienta de desarrollo: captura el elenco Quaternius en sus escenas.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_quaternius.tscn
##
## Guarda `user://quaternius_llacta.png`, `..._sisa.png`, `..._sisa_close.png`,
## `..._curaca.png`, `..._curaca_close.png`, `..._rostro.png`, `..._mensajero.png`,
## `..._chanca.png`, `..._mano.png`, `..._anciana.png`, `..._joven.png`,
## `..._madre.png`, `..._hermano.png`, `..._puma.png`, `..._anca.png` y sus
## versiones `_close`, además de `..._crowd_anciana.png` en el Cusco. Fija el
## acto I limpio y sin la vista de introducción para que la cámara de captura no
## la sustituya la del jugador. No es una prueba: es la referencia visual.

const LLACTA: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const CIUDAD: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const PASO: String = "res://campaigns/01_pachacutec/scenes/world/paso.tscn"
const SETTLE_FRAMES: int = 90


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	# La captura debe ser reproducible: acto I limpio y sin la vista de intro,
	# que mueve la cámara del jugador y tapa la cámara de captura.
	CampaignState.clear()
	CampaignState.set_flag(&"intro_vista")
	var prefix: String = "quaternius"
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
	await _shot(camera, Vector3(7.0, 1.42, 6.4), Vector3(7.0, 1.38, 8.0), prefix + "_rostro")
	await _shot(camera, Vector3(7.0, 1.42, 7.45), Vector3(7.0, 1.38, 8.0), prefix + "_sisa_close")
	await _shot(camera, Vector3(-6.4, 1.5, -6.6), Vector3(-7.0, 1.15, -3.0), prefix + "_curaca")
	await _shot(camera, Vector3(-6.9, 1.58, -3.68), Vector3(-7.0, 1.55, -3.0), prefix + "_curaca_close")
	# Arquetipos de multitud: se muestran aparte para no depender de que la
	# escena los tenga colocados. El visual ajusta la altura y los materiales.
	await _showcase(MODEL_DIR + "pch_npc_anciana_q.glb", Vector3(0.0, 0.0, 18.0), prefix + "_anciana")
	await _showcase(MODEL_DIR + "pch_npc_joven_q.glb", Vector3(0.0, 0.0, 18.0), prefix + "_joven")
	await _showcase(MODEL_DIR + "pch_npc_madre_q.glb", Vector3(0.0, 0.0, 18.0), prefix + "_madre")
	await _showcase(MODEL_DIR + "pch_npc_hermano_q.glb", Vector3(0.0, 0.0, 18.0), prefix + "_hermano")
	await _showcase(MODEL_DIR + "pch_npc_puma_q.glb", Vector3(0.0, 0.0, 18.0), prefix + "_puma")
	await _showcase(MODEL_DIR + "pch_npc_anca_q.glb", Vector3(0.0, 0.0, 18.0), prefix + "_anca")
	await _shot(camera, Vector3(-2.4, 1.5, 0.2), Vector3(-3.0, 1.15, 3.0), prefix + "_mensajero")
	await _shot(camera, Vector3(1.0, 1.65, 14.0), Vector3(0.0, 1.0, 4.0), prefix + "_llacta")
	# El Agricultor y su chaquitaclla, en la primera terraza.
	await _shot(camera, Vector3(32.4, 1.75, -0.4), Vector3(36.0, 1.05, -2.7), prefix + "_agricultor")
	# Mano en primera persona: se usa la cámara del jugador.
	var llacta_player: Node3D = llacta.get_node_or_null("PlayerFPS") as Node3D
	if llacta_player != null:
		var player_camera: Camera3D = llacta_player.get_node_or_null("Head/Camera3D") as Camera3D
		var hand: FirstPersonHands = llacta_player.get_node_or_null(
			"Head/Camera3D/FirstPersonHands") as FirstPersonHands
		if player_camera != null and hand != null:
			player_camera.current = true
			hand.play(&"offer")
			await _frames(7)
			_save(prefix + "_mano")
	llacta.queue_free()
	await _frames(3)

	# Cusco: los dos arquetipos ocupan dos puestos de la multitud. La captura
	# confirma que el catálogo los coloca y que la ropa se lee en la plaza.
	var ciudad: Node = (load(CIUDAD) as PackedScene).instantiate()
	add_child(ciudad)
	await _frames(60)
	_hide_ui(ciudad)
	var ciudad_camera: Camera3D = Camera3D.new()
	ciudad_camera.name = "CiudadCaptureCamera"
	ciudad_camera.fov = 45.0
	add_child(ciudad_camera)
	ciudad_camera.current = true
	await _shot(ciudad_camera, Vector3(-0.5, 1.45, 7.4), Vector3(-3.6, 1.25, 7.4), prefix + "_crowd_anciana")
	ciudad.queue_free()
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


func _showcase(model_path: String, at: Vector3, slug: String) -> void:
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "Showcase_" + slug
	visual.model_path = model_path
	visual.target_height = 1.58
	visual.height_variation = 0.0
	visual.position = at
	add_child(visual)
	await _frames(20)
	var camera: Camera3D = Camera3D.new()
	camera.name = "ShowcaseCamera"
	camera.fov = 42.0
	add_child(camera)
	camera.current = true
	await _shot(camera, at + Vector3(0.0, 1.42, -2.3), at + Vector3(0.0, 1.20, 0.0), slug)
	await _shot(camera, at + Vector3(0.0, 1.42, -1.15), at + Vector3(0.0, 1.20, 0.0), slug + "_close")
	camera.queue_free()
	visual.queue_free()
	await _frames(3)


func _save(slug: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	var file: String = "user://%s.png" % slug
	image.save_png(file)
	print("CAPTURA ", slug, " -> ", file)


func _shot(camera: Camera3D, at: Vector3, target: Vector3, slug: String) -> void:
	camera.current = true
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
