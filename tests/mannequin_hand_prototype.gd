extends Node3D
## Captura aislada de la mano de maniquí en primera persona.
##
##   godot --path . res://tests/scenes/mannequin_hand_prototype.tscn
##
## Monta la misma mano que usa el jugador (`MannequinHand`) delante de la
## cámara y guarda `user://mano_abierta.png` y `user://mano_agarre.png`.

const HAND_SCALE: float = 0.55
const HAND_POSITION: Vector3 = Vector3(0.16, -0.19, -0.52)
const HAND_ROTATION: Vector3 = Vector3(70.0, 36.0, 0.0)

var _hand: MannequinHand = null


func _ready() -> void:
	_build_world()
	_capture.call_deferred()


func _build_world() -> void:
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.46, 0.56, 0.66)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.82, 0.86)
	environment.ambient_light_energy = 1.0
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40.0, -30.0, 0.0)
	sun.light_energy = 1.2
	add_child(sun)
	var camera: Camera3D = Camera3D.new()
	camera.fov = 70.0
	camera.current = true
	add_child(camera)


func _show_hand(grip: bool) -> void:
	if _hand != null:
		_hand.queue_free()
		_hand = null
	_hand = MannequinHand.new()
	_hand.grip = grip
	_hand.scale = Vector3.ONE * HAND_SCALE
	_hand.position = HAND_POSITION
	_hand.rotation_degrees = HAND_ROTATION
	add_child(_hand)


func _capture() -> void:
	for grip: bool in [false, true]:
		_show_hand(grip)
		for _i: int in range(4):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var suffix: String = "agarre" if grip else "abierta"
		get_viewport().get_texture().get_image().save_png(
			"user://mano_%s.png" % suffix)
		print("MANO_PROTOTIPO_OK ", suffix)
	get_tree().quit()
