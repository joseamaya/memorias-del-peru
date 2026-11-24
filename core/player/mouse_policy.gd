class_name MousePolicy
extends RefCounted
## Reglas del puntero del jugador: captura, pausa y UI modal.
##
## Son funciones puras para poder probarlas sin ventana ni modo de ratón real.


## El ratón solo se captura con la ventana enfocada, sin pausa ni controles
## bloqueados por un diálogo o el diario.
static func should_capture(paused: bool, window_focused: bool, controls_locked: bool) -> bool:
	return window_focused and not paused and not controls_locked


## Modo de ratón que corresponde al estado de pausa.
static func mode_for_pause(paused: bool) -> Input.MouseMode:
	return Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED


## Indica si el juego está pausado.
static func is_paused() -> bool:
	var manager: GameManagerService = GameManagerService.instance()
	return manager != null and manager.is_paused()
