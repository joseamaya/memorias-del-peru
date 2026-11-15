extends Node
## Herramienta de desarrollo: captura la llacta del acto I.
##
##   godot --path . --resolution 1920x1080 res://tests/scenes/capture_llacta.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		get_tree().quit(1)
		return
	var world: Node = packed.instantiate()
	add_child(world)
	for _i: int in range(20):
		await get_tree().process_frame
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("user://llacta.png")
	print("CAPTURA llacta")
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		get_tree().quit()
