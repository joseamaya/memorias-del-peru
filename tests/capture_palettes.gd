extends Node
## Herramienta de desarrollo: captura un fotograma de cada acto con su paleta.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_palettes.tscn
##
## Guarda `user://paleta_<acto>.png`. No es una prueba: es la referencia visual
## de `campaigns/01_pachacutec/documentation/guia_visual.md`.

const ACTS: Array[Dictionary] = [
	{"slug": "llacta", "path": "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"},
	{"slug": "paso", "path": "res://campaigns/01_pachacutec/scenes/world/paso.tscn"},
	{"slug": "ciudad", "path": "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"},
	{"slug": "posguerra", "path": "res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn"},
	{"slug": "obra", "path": "res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn"},
]
const SETTLE_FRAMES: int = 24


func _ready() -> void:
	_capture_all.call_deferred()


func _capture_all() -> void:
	for entry: Dictionary in ACTS:
		var packed: PackedScene = load(str(entry["path"])) as PackedScene
		if packed == null:
			printerr("No se pudo cargar ", entry["path"])
			continue
		var world: Node = packed.instantiate()
		add_child(world)
		_hide_ui(world)
		for _i: int in range(SETTLE_FRAMES):
			await get_tree().process_frame
		var image: Image = get_viewport().get_texture().get_image()
		var file: String = "user://paleta_%s.png" % str(entry["slug"])
		image.save_png(file)
		print("CAPTURA ", entry["slug"], " -> ", file)
		world.queue_free()
		await get_tree().process_frame
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		get_tree().quit()


func _hide_ui(root: Node) -> void:
	for node: Node in root.find_children("*", "CanvasLayer", true, false):
		(node as CanvasLayer).visible = false
