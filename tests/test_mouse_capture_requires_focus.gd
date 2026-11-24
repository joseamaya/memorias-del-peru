extends RefCounted
## Comprueba que el jugador solo pide capturar el ratón en juego, con la ventana
## enfocada y sin controles bloqueados (pedirlo sin foco produce «NO GRAB» en
## X11; pedirlo con el diario abierto hace desaparecer el puntero).


func test_mouse_capture_requires_focus() -> bool:
	var ok: bool = MousePolicy.should_capture(false, true, false)
	ok = ok and not MousePolicy.should_capture(false, false, false)
	ok = ok and not MousePolicy.should_capture(true, true, false)
	ok = ok and not MousePolicy.should_capture(true, false, false)
	# Con el diario abierto o un diálogo bloqueando, el clic no recaptura.
	ok = ok and not MousePolicy.should_capture(false, true, true)
	return ok
