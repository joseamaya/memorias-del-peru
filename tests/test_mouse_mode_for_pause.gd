extends RefCounted
## Comprueba el modo de ratón asociado a la pausa.


func test_mouse_mode_for_pause() -> bool:
	return (
		PlayerFPS.mouse_mode_for_pause(true) == Input.MOUSE_MODE_VISIBLE
		and PlayerFPS.mouse_mode_for_pause(false) == Input.MOUSE_MODE_CAPTURED
	)
