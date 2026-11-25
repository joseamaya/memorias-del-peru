class_name MouseCapture
extends RefCounted
## Captura del puntero del jugador: foco, pausa y controles bloqueados.
##
## La captura se pide al arrancar, al recuperar el foco, con un clic y al
## liberar los controles. El reintento al liberar es imprescindible: si la
## pausa o el foco la rechazaron mientras había un diálogo o el diario, el
## jugador volvía al mundo con el puntero visible y sin poder mirar.
##
## La aplicación del modo se puede interceptar en las pruebas; en headless
## `Input.mouse_mode` siempre se lee visible.

var apply_mode: Callable = Callable()

var _node: Node = null
var _locked: Callable = Callable()


## Ata el capturador al jugador. `locked` devuelve si los controles están
## bloqueados. Se llama una sola vez, al entrar en el árbol.
func setup(node: Node, locked: Callable, apply_func: Callable) -> void:
	_node = node
	_locked = locked
	apply_mode = apply_func


## Muestra el puntero al pausar; al reanudar reintenta la captura.
func on_pause_changed(paused: bool) -> void:
	if paused:
		apply(MousePolicy.mode_for_pause(true))
		return
	request()


## Pide la captura si la política lo permite. Devuelve si se aplicó.
func request() -> bool:
	if _node == null or not is_instance_valid(_node) or not _node.is_inside_tree():
		return false
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return false
	var allowed: bool = MousePolicy.should_capture(
		MousePolicy.is_paused(), DisplayServer.window_is_focused(), _is_locked()
	)
	if not allowed:
		return false
	apply(Input.MOUSE_MODE_CAPTURED)
	return true


## Puntero visible para la pausa o una UI modal.
func show_pointer() -> void:
	apply(Input.MOUSE_MODE_VISIBLE)


## Aplica el modo; las pruebas inyectan aquí su interceptación.
func apply(mode: Input.MouseMode) -> void:
	if apply_mode.is_valid():
		apply_mode.call(mode)
	else:
		Input.mouse_mode = mode


func _is_locked() -> bool:
	return _locked.call() if _locked.is_valid() else false
