extends Node
## Herramienta de desarrollo: captura la pantalla de título.
##
##   godot --path . --resolution 1920x1080 res://tests/scenes/capture_title.tscn

const TITLE_SCENE: String = "res://core/ui/title_screen.tscn"


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var screen: Control = (load(TITLE_SCENE) as PackedScene).instantiate() as Control
	add_child(screen)
	for _i: int in range(10):
		await get_tree().process_frame
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("user://title_screen.png")
	print("CAPTURA title_screen")
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		get_tree().quit()
