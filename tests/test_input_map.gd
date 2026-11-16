extends RefCounted
## Comprueba que las acciones del Input Map existen y tienen eventos.


func test_input_map() -> bool:
	var actions: Array[StringName] = [
		&"move_forward",
		&"move_backward",
		&"move_left",
		&"move_right",
		&"run",
		&"interact",
		&"jump",
		&"pause",
		&"journal",
		&"attack",
		&"block",
		&"weapon_1",
		&"weapon_2",
		&"weapon_3",
	]
	for action: StringName in actions:
		if not InputMap.has_action(action):
			return false
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.is_empty():
			return false
		# En Godot 4.7 el teclado es DEVICE_ID_KEYBOARD (16), no 0. La prueba
		# reproduce el evento real de teclado para detectar un device que no
		# corresponda.
		var stored: InputEvent = events[0]
		if stored is InputEventKey:
			var probe: InputEventKey = (stored as InputEventKey).duplicate() as InputEventKey
			probe.device = InputEvent.DEVICE_ID_KEYBOARD
			probe.pressed = true
			if not InputMap.event_is_action(probe, action):
				printerr("La acción ", action, " no responde al teclado")
				return false
	return true
