extends RefCounted
## Comprueba que el jugador solo pide capturar el ratón en juego y con la
## ventana enfocada (pedirlo sin foco produce «NO GRAB» en X11).


func test_mouse_capture_requires_focus() -> bool:
	var ok: bool = true
	ok = ok and PlayerFPS.should_capture_mouse(false, true)
	ok = ok and not PlayerFPS.should_capture_mouse(false, false)
	ok = ok and not PlayerFPS.should_capture_mouse(true, true)
	ok = ok and not PlayerFPS.should_capture_mouse(true, false)
	return ok
