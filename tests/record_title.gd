extends SceneTree
## Portada para el vídeo: abre el título, deja respirar la pantalla y sale.
##
##   godot --path . --write-movie build/titulo.avi --fixed-fps 30 \
##       --script res://tests/record_title.gd
##
## No forma parte del juego.

const TITLE: String = "res://core/ui/title_screen.tscn"
const SECONDS: float = 4.0

var _elapsed: float = 0.0


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	change_scene_to_file(TITLE)
	await process_frame
	await process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> bool:
	_elapsed += delta
	if _elapsed >= SECONDS:
		print("RECORD_TITLE_OK")
		quit(0)
		return true
	return false
