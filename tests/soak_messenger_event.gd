extends SceneTree
## Prueba de humo del evento con tiempo real acelerado.
##
## Uso: godot --headless --path . --script res://tests/soak_messenger_event.gd
##
## Carga el mundo, acelera el reloj y comprueba que el evento llega a `DONE` sin
## intervención. Complementa las pruebas de `step()`: aquí el avance viene de
## `_process`, como en la partida real. No forma parte del juego.
##
## No usa tipos estáticos de la campaña: al ejecutarse con `--script`, los
## autoloads todavía no existen cuando el motor compila este archivo.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const TIME_SCALE: float = 20.0
const MAX_REAL_MS: int = 60000
const PHASE_DONE: int = 5

var _world: Node = null
var _event: Node = null
var _start_ms: int = 0
var _finished: bool = false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		printerr("SOAK: no se pudo cargar el mundo")
		_quit(1)
		return
	_world = packed.instantiate()
	root.add_child(_world)
	_event = _world.get_node_or_null("EventController")
	var pututu: Node = _world.get_node_or_null("Pututu")
	if _event == null or pututu == null:
		printerr("SOAK: falta el evento o el pututu")
		_quit(1)
		return
	pututu.set("audio_stream", null)
	_event.connect("finished", _on_finished)
	Engine.time_scale = TIME_SCALE
	_start_ms = Time.get_ticks_msec()
	process_frame.connect(_on_frame)


func _on_frame() -> void:
	if _finished:
		return
	if Time.get_ticks_msec() - _start_ms > MAX_REAL_MS:
		printerr("SOAK: el evento no terminó; fase=", _event.get("phase"))
		_quit(1)


func _on_finished() -> void:
	_finished = true
	print("SOAK_OK fase=", _event.get("phase"), " pututu_by_player=", _event.get("pututu_by_player"))
	_quit(0)


func _quit(code: int) -> void:
	Engine.time_scale = 1.0
	var audio: Node = root.get_node_or_null("AudioManager")
	if audio != null:
		audio.call("stop_all")
	if _world != null:
		_world.queue_free()
	quit(code)
