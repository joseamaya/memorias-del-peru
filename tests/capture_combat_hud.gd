extends Node
## Herramienta de desarrollo: captura el HUD durante la emboscada.
##
##   godot --path . --resolution 1920x1080 res://tests/scenes/capture_combat_hud.tscn


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var paso: Node3D = (load("res://campaigns/01_pachacutec/scenes/world/paso.tscn") as PackedScene).instantiate() as Node3D
	add_child(paso)
	await get_tree().process_frame
	var player: PlayerFPS = paso.get_node("PlayerFPS") as PlayerFPS
	player.global_position = Vector3(0.0, 0.15, 8.0)
	player.rotation.y = 0.0
	var head: Node3D = player.get_node("Head") as Node3D
	head.rotation.x = deg_to_rad(-5.0)
	paso.call("_start_ambush")
	paso.call("apply_player_damage", 24.0)
	for _i: int in range(8):
		await get_tree().process_frame
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("user://combat_hud.png")
	print("CAPTURA combat_hud")
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		get_tree().quit()
